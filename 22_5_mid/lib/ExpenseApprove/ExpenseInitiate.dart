import 'package:flutter/material.dart';
import 'dart:convert'; // for JSON parsing
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiHelper.dart';
import 'package:flutter/services.dart'; // Make sure to add this import

class ExpenseInitiate extends StatefulWidget {
  @override
  _ExpenseInitiateState createState() => _ExpenseInitiateState();
}

class _ExpenseInitiateState extends State<ExpenseInitiate> {
  // Controllers
  final TextEditingController costCentreController = TextEditingController();
  final TextEditingController wbsController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController quotationController = TextEditingController();

  // Dropdown values
  List<String> locations = [];
  List<String> managers = [];
  String? selectedLocation;
  String? selectedManager;

  bool loading = false;

  late String? accesstoken;

  @override
  void initState() {
    super.initState();
    _initData(); // call async method separately
  }



  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString("access_token") ?? "";

    // accesstoken = "eyJ0eXAiOiJKV1QiLCtch from secure storage/session
    fetchDropdownLocation(accesstoken!);
    fetchDropdownManagerList(accesstoken!);
  }


  Future<void> fetchDropdownLocation(String accessToken) async {
    print("📡 Calling Location API...");
    final result = await ApiHelper.callGetApi(
      "ControlValues?\$filter=category eq 'EXP_LOCATION'",
      accessToken,
    );

    print("➡️ Request URL: ControlValues?\$filter=category eq 'EXP_LOCATION'");
    print("⬅️ Response (${result["statusCode"]}): ${result["body"]}");

    switch (result["statusCode"]) {
      case 200:
        final data = jsonDecode(result["body"]);
        final values = data["value"] as List;
        setState(() {
          locations = values.map((e) => e["description"].toString()).toList();
        });
        break;
      case 404:
        _showSnackBar("Data not found. Please contact the Administrator");
        break;
      default:
        _showSnackBar("Unexpected error: ${result["statusCode"]}");
    }
  }

  Future<void> fetchDropdownManagerList(String accessToken) async {
    print("📡 Calling Manager API...");
    final result = await ApiHelper.callGetApi(
      "Approvers?\$filter=department eq 'EXP'",
      accessToken,
    );

    print("➡️ Request URL: Approvers?\$filter=department eq 'EXP'");
    print("⬅️ Response (${result["statusCode"]}): ${result["body"]}");

    switch (result["statusCode"]) {
      case 200:
        final data = jsonDecode(result["body"]);
        final values = data["value"] as List;
        setState(() {
          managers = values.map((e) => "${e["userID"]} - ${e["name"]}").toList();
        });
        break;
      case 404:
        _showSnackBar("Data not found. Please contact the Administrator");
        break;
      default:
        _showSnackBar("Unexpected error: ${result["statusCode"]}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void submitExpense() async {
    if (selectedLocation == null ||
        costCentreController.text.isEmpty ||
        wbsController.text.isEmpty ||
        purposeController.text.isEmpty ||
        quotationController.text.isEmpty ||
        selectedManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final UserID = prefs.getString("username_token") ?? "";

    final managerId = selectedManager!.split(" - ")[0];

    final payload = {
      "reqID": "",
      "action": "SUBMIT",
      "loggedInUser": "$UserID@mahindra.com", // replace with session user
      "remarks": "",
      "data": {
        "location": selectedLocation,
        "costCenter": costCentreController.text,
        "WBSCode": wbsController.text,
        "purpose": purposeController.text,
        "quotationAmount": quotationController.text,
        "manager": managerId,
        "approvalAmount": ""
      }
    };

    print("📡 Calling POST API...");
    print("➡️ Endpoint: EXPApproval");
    print("➡️ Payload: ${jsonEncode(payload)}");

    try {
      final result = await ApiHelper.callPostApi(
        "EXPApproval",
        accesstoken!,
        payload,
      );

      print("⬅️ Response (${result["statusCode"]}): ${result["body"]}");

      final responseJson = jsonDecode(result["body"]);

      if (result["statusCode"] == 200 && responseJson["value"] != null) {
        final msg = responseJson["value"]["message"];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Success"),
            content: Text(msg),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // Navigator.pushReplacementNamed(context, "/NextScreen");
                },
              )
            ],
          ),
        );
      } else {
        final msg = responseJson["error"]?["message"] ?? "Unknown error";
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Error"),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Submit error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <--- Add this line here
      appBar: AppBar(title: Text("Expense Initiator"),
        backgroundColor: Color(0xFFB71C1C),),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedLocation,
              dropdownColor: Colors.grey[200], // popup background light gray
              decoration: InputDecoration(
                labelText: "Select Location",
                labelStyle: const TextStyle(color: Colors.black),

              ),
              hint: const Text(
                "",
                style: TextStyle(color: Colors.black),
              ),
              items: locations.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300), // item separator
                      ),
                    ),
                    child: Text(
                      loc,
                      style: const TextStyle(color: Colors.black), // item text black
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedLocation = val),
              style: const TextStyle(color: Colors.black), // selected value text
            ),


            SizedBox(height: 12),
            TextField(
              controller: costCentreController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(labelText: "Cost Centre",labelStyle: TextStyle(color: Colors.black),),
            ),
            SizedBox(height: 12),
            TextField(
              controller: wbsController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(labelText: "WBS Code",
                labelStyle: TextStyle(color: Colors.black),),
            ),
            SizedBox(height: 12),
            TextField(
              controller: purposeController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(labelText: "Purpose",labelStyle: TextStyle(color: Colors.black),),
            ),
            SizedBox(height: 12),
            TextField(
              controller: quotationController, // Fixed the space in quotationController
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // This blocks all non-numeric characters
              ],
              decoration: InputDecoration(
                labelText: "Quotation Amount",
                prefixText: "₹ ", // Helpful to indicate to the user it's a rupee value
                prefixStyle: TextStyle(color: Colors.black, fontSize: 16),
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedManager,
              dropdownColor: Colors.grey[200], // popup background light gray
              decoration: InputDecoration(
                labelText: "Select Test Manager",
                labelStyle: const TextStyle(color: Colors.black ,),

              ),
              hint: const Text(
                "",
                style: TextStyle(color: Colors.black),
              ),
              items: managers.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300), // item separator
                      ),
                    ),
                    child: Text(
                      loc,
                      style: const TextStyle(color: Colors.black), // item text black
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedManager = val),
              style: const TextStyle(color: Colors.black), // selected value text
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),

              child: SizedBox(
                width: double.infinity, // full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C), // red background
                    foregroundColor: Colors.white, // white text
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: submitExpense,
                  child: Text("SUBMIT"),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ApiHelper.dart';
import 'ExpenseReportModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseApprovalDetails extends StatefulWidget {
  final ExpenseReportModel report;

  ExpenseApprovalDetails({required this.report});

  @override
  _ExpenseApprovalDetailsState createState() => _ExpenseApprovalDetailsState();
}

class _ExpenseApprovalDetailsState extends State<ExpenseApprovalDetails>
{
  bool _loading = false;
  bool _blockingTouch = false;

  late final r = widget.report;

  // Example data (replace with API/shared prefs)
  late String claimId = r.claimId ;
  late String initiatorId = r.initiator;
  late String amount =r.amount;
  late String location = r.location;
  late String costCentre = r.costCenter;
  late String wbsCode = r.wbsCode;
  late String purpose = r.description;

  void _showApprovalDialog() {
    final remarksController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Approve Expense"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Claim ID: $claimId"),
                SizedBox(height: 8),
                Text("Amount: $amount"),
                SizedBox(height: 16),
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(
                    labelText: "Remarks",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // This blocks all non-numeric characters
                  ],
                  decoration: InputDecoration(
                    labelText: "Approved Amount *",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("CANCEL", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: Text("DONE", style: TextStyle(color: Colors.green)),
              onPressed: () {
                if (amountController.text.trim().isEmpty ||
                    amountController.text.trim() == "0") {
                  _showPopup("Error", "Enter Valid Approved Amount");
                } else {
                  Navigator.pop(ctx);

                  setState(() {
                    _loading = true;
                    _blockingTouch = true;
                  });
                  _submitApproval( remarksController.text,
                    amountController.text,);
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _submitApproval(String remarks, String approvedAmount) async {
    // Simulate API call

    final prefs = await SharedPreferences.getInstance();
    final UserID = prefs.getString("username_token") ?? "";



    final payload = {
      "reqID": r.refNo,
      "action": "APPROVE",
      "loggedInUser": "$UserID@mahindra.com", // replace with session user
      "remarks": remarks ,
      "data": {
        "approvalAmount": approvedAmount
      }
    };

    print("📡 Calling POST API...");
    print("➡️ Endpoint: EXPApproval");
    print("➡️ Payload: ${jsonEncode(payload)}");

    final accesstoken = prefs.getString("access_token") ?? "";

    try {
      final result = await ApiHelper.callPostApi(
        "EXPApproval",
        accesstoken!,
        payload,
      );

      print("⬅️ Response (${result["statusCode"]}): ${result["body"]}");

      setState(() {
        _loading = false;
        _blockingTouch = false;
      });

      final responseJson = jsonDecode(result["body"]);

      if (result["statusCode"] == 200 && responseJson["value"] != null) {
        final msg = responseJson["value"]["message"];
        showDialog(
          barrierDismissible: true, // allow closing by tapping outside
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Success"),
            content: Text(msg),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true); // return "true" to parent
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
      print("❌ Approval error: $e");
    }
    finally {
      setState(() {
        _loading = false;
        _blockingTouch = false;
      });
    }


  }

  void _showPopup(String title, String message) {
    showDialog(
      barrierDismissible: false, // Prevents closing when clicking outside
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(ctx);
              if (title == "Success") {
                Navigator.pop(context); // Go back to list screen
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label,
  //             style: TextStyle(color: Colors.grey[700], fontSize: 16)),
  //         Text(value,
  //             style: TextStyle(
  //                 color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Label) - Takes exactly 50% width
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ),

          // Spacer Gap between the columns
          const SizedBox(width: 16),

          // Right Column (Value) - Takes exactly 50% width, aligned left
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start, // Ensures text aligns to the left of its 50% block
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    return Scaffold(
      backgroundColor: Colors.white, // <--- Add this line here
      appBar: AppBar(
        title: Text("Expense Approval Details"),
        leading: BackButton(),backgroundColor: Color(0xFFB71C1C),
      ),
      body: Stack(
      children: [
        SingleChildScrollView(
        child: Column(
          children: [
            _buildDetailRow("Claim ID", r.claimId),
            _buildDetailRow("Initiator ID", r.initiator),
            _buildDetailRow("Amount", r.amount),
            _buildDetailRow("Location", r.location),
            _buildDetailRow("Cost Centre", r.costCenter),
            _buildDetailRow("WBS Code", r.wbsCode),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextField(
                enabled: false,
                style: TextStyle(color: Colors.black),
                controller: TextEditingController(text: purpose),
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Purpose",
                  // 1. Set label text size here
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0, // Adjust size as needed
                    fontWeight: FontWeight.bold,
                  ),
                  // 2. Set border color for disabled state
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  // Also set standard border to match
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust this value for more/less gap
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB71C1C),
                  minimumSize: Size(double.infinity, 50),
                  // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), // This is internal padding
                ),
                child: Text('APPROVE', style: TextStyle(color: Colors.white)),
                onPressed: _showApprovalDialog,
              ),
            )

          ],
        ),
      ),
        if (_blockingTouch)
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
        if (_loading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
      ),
    );
  }
}

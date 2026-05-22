import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ApiHelper.dart';
import 'ExpenseApprove/ExpenseInitiate.dart';
import 'ExpenseApprove/ExpenseApproval.dart';
import 'ExpenseApprove/ExpenseReport.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahindra Rise Login',
      theme: ThemeData.dark(),
      home:  ExpenseScreen(),  // NextScreen , LoginScreen
    );
  }
}


class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  bool _loading = true;
  bool _blockingTouch = true;
  String? _token;

  // final List<Map<String, dynamic>> _menuItems = [
  //   {"title": "Expense Initiator", "icon": Image.asset('assets/bv.png',),},
  //   {"title": "Expense Approval", "icon": Icons.check_circle},
  //   {"title": "Report", "icon": Icons.receipt_long},
  // ];
  final List<Map<String, String>> _menuItems = [
    {"title": "Expense Initiator", "asset": "assets/expense_initiator_white_icon.png"},
    {"title": "Expense Approval", "asset": "assets/expense_approval_white_icon.png"},
    {"title": "Report", "asset": "assets/expense_report_white_icon.png"},
  ];


  @override
  void initState() {
    super.initState();
    _getAccessToken();
  }

  Future<void> _getAccessToken() async {
    print("📡 Calling AccessToken API...");
    final token = await ApiHelper.getAccessToken();

    if (token != null) {
      setState(() => _token = token);

      //save Expense Token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", token );

      await _getLoggedInUser(token);
    } else {
      _showAlert("Authorization Failed", "Please contact administration");
    }
  }

  Future<void> _getLoggedInUser(String token) async {
    //Get UserID
    final prefs = await SharedPreferences.getInstance();
    String? UserID =await prefs.getString("username_token" );

    final result = await ApiHelper.callPostApi(
      "getLoggedInUser",
      token,
      {"loggedInUser": "$UserID@mahindra.com"},
    );

    setState(() {
      _loading = false;
      _blockingTouch = false;
    });

    switch (result["statusCode"]) {
      case 200:
        final data = jsonDecode(result["body"]);
        _showSnackBar(
            "Name: ${data["name"]}\nRole: ${data["role"]}\nDepartment: ${data["department"]}");
        break;
      case 400:
        _showAlert("Access Denial", "User does not exist in SAP. Please contact the Administrator");
        break;
      case 404:
        _showSnackBar("Data not found. Please contact the Administrator");
        break;
      default:
        _showSnackBar("Unexpected error: ${result["statusCode"]}");
    }
  }


  // Future<void> _getAccessToken() async {
  //   try {
  //     // 🔑 First API call (OAuth)
  //     final response = await http.post(
  //       Uri.parse("https://your-auth-server.com/oauth/token"),
  //       body: {"client_id": "xxx", "client_secret": "yyy"},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final token = jsonDecode(response.body)["access_token"];
  //       setState(() {
  //         _token = token;
  //       });
  //
  //       // ✅ Second API call (getLoggedInUser)
  //       await _getLoggedInUser(token);
  //     } else {
  //       _showAlert("Authorization Failed", "Please contact administration");
  //     }
  //   } catch (e) {
  //     _showSnackBar("Network error: $e");
  //   }
  // }
  //
  // Future<void> _getLoggedInUser(String token) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("https://your-api-server.com/getLoggedInUser"),
  //       headers: {"Authorization": "Bearer $token"},
  //       body: jsonEncode({"loggedInUser": "username@mahindra.com"}),
  //     );
  //
  //     setState(() {
  //       _loading = false;
  //       _blockingTouch = false;
  //     });
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final name = data["name"];
  //       final role = data["role"];
  //       final dept = data["department"];
  //       _showSnackBar("Name: $name\nRole: $role\nDepartment: $dept");
  //     } else if (response.statusCode == 400) {
  //       _showAlert("Access Denial", "Bad Request");
  //     } else if (response.statusCode == 404) {
  //       _showSnackBar("Data not found. Please check filter or endpoint...!");
  //     } else {
  //       _showSnackBar("Unexpected error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     _showSnackBar("Network error: $e");
  //   }
  // }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Navigator.pushReplacementNamed(context, "/NextScreen");
            },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        // Navigator.pushNamed(context, "/initiator");
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseInitiate()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseApproval(token: '',)));
        break;
      case 2:
        // Navigator.pushNamed(context, "/report");
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseReport(token: '',)));
        break;
    }
  }

  //ui design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <--- Add this line here
      appBar: AppBar(
        title: Text("Expense Approval"),
        leading: BackButton(), // 🔙 iOS + Android back button
        backgroundColor: Color(0xFFB71C1C),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                child: Card(
                  color: const Color(0xFFB71C1C),
                  child: ListTile(
                    leading: Image.asset(
                      item["asset"]!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    title: Text(
                      item["title"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => _navigateToScreen(index),
                  ),
                ),
              );
            },
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

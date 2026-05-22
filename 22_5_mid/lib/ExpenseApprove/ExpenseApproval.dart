
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ApiHelper.dart';
import 'ExpenseApprovalCard.dart';
import 'ExpenseReportModel.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Example placeholder screens
class ExpenseApproval extends StatefulWidget
{
  final String token;
  ExpenseApproval({required this.token});

  @override
  _ExpenseReportScreenState createState() => _ExpenseReportScreenState();

}



class _ExpenseReportScreenState extends State<ExpenseApproval> with WidgetsBindingObserver {

  List<ExpenseReportModel> reports = [];
  List<ExpenseReportModel> filteredReports = [];
  bool loading = false;
  String searchQuery = "";


  @override
  void initState() {
    super.initState();
    _initData(); // call async method separately

    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App Resumed");
      _initData();
    } else if (state == AppLifecycleState.paused) {
      print("App Paused");
    } else if (state == AppLifecycleState.inactive) {
      print("App Inactive");
    }
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    String? accesstoken = prefs.getString("access_token") ?? "";


    _fetchReports(accesstoken!);

  }



  Future<void> _fetchReports(String accessToken) async {
    setState(() => loading = true);
    print("📡 Calling Search API...");

    //Get UserID
    final prefs = await SharedPreferences.getInstance();
    String? userID =await prefs.getString("username_token" );

    // String accessToken  = "eyJ0eXAiOiJKV1QiLCJqaWQiOiJqdmVYdFNhWjNFTERGRjB4Z2VzZFlSYXdRTDJCVWxmQTcrcVhoMVpZT1lNPSIsImFsZyI6IlJTMjU2Iiwiamt1IjoiaHR0cHM6Ly9tYW11YXQtNmpwYWkwb2YuYXV0aGVudGljYXRpb24uZXUxMC5oYW5hLm9uZGVtYW5kLmNvbS90b2tlbl9rZXlzIiwia2lkIjoiZGVmYXVsdC1qd3Qta2V5LS0xMTUwNDM3OTg0In0"; // fetch from secure storage/session

    final result = await ApiHelper.callGetApi(
        "ExpenseReports?\$filter=pendingWith eq tolower('${userID}@mahindra.com')",
      accessToken!,
    );

    print("➡️ Request URL: ExpenseReports?\$filter=pendingWith eq ${userID}" );
    print("⬅️ Response (${result["statusCode"]}): ${result["body"]}");

    switch (result["statusCode"]) {
      case 200:
        final body = result['body'];
        final jsonData = jsonDecode(body);
        final List<dynamic> values = jsonData['value'];

        final parsedReports =
        values.map((e) => ExpenseReportModel.fromJson(e)).toList();

        setState(() {
          reports = parsedReports;
          filteredReports = parsedReports;
        });
        break;

      case 404:
        _showSnackBar("Data not found. Please contact the Administrator");
        break;

      default:
        _showSnackBar("Unexpected error: ${result["statusCode"]}");
    }

    setState(() => loading = false);
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }





  void _filterReports(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredReports = reports;
      } else {
        filteredReports = reports.where((r) {
          final q = query.toLowerCase();
          return r.claimId.toLowerCase().contains(q) ||
              r.amount.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q) ||
              r.initiator.toLowerCase().contains(q) ||
              r.location.toLowerCase().contains(q) ||
              r.costCenter.toLowerCase().contains(q) ||
              r.wbsCode.toLowerCase().contains(q);
        }).toList();
      }
    });
  }


  void _refreshList() async {
    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("access_token") ?? "";

    await _fetchReports(accessToken);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70, // <--- Add this line here
      appBar: AppBar(title: Text("Expense Approval") ,  backgroundColor: Color(0xFFB71C1C),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // background color
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // shadow color
                    blurRadius: 6, // softness of the shadow
                    offset: Offset(0, 3), // position of the shadow (x, y)
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Here",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none, // remove default underline
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: _filterReports,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return ExpenseApprovalCard(report: report,
                  query: searchQuery, onRefresh: _refreshList,);
              },
            ),
          )
        ],
      ),
    );
  }
}
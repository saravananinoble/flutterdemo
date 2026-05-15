
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ApiHelper.dart';
import 'ExpenseReportCard.dart';
import 'ExpenseReportModel.dart';

import 'package:shared_preferences/shared_preferences.dart';



class ExpenseReport extends StatefulWidget {
  final String token;
  ExpenseReport({required this.token});

  @override
  _ExpenseReportScreenState createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReport> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<ExpenseReportModel> reports = [];
  List<ExpenseReportModel> filteredReports = [];
  bool loading = false;
  String searchQuery = "";

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }



  Future<void> _fetchReports() async {
    setState(() => loading = true);
    print("📡 Calling Search API...");

    //Get UserID
    final prefs = await SharedPreferences.getInstance();
    String? accessToken =await prefs.getString("access_token" );

    // String accessToken  = "eyJ0eXAiOiJKV1QiLCJqaWQiOiJqdmVYdFNhWjNFTERGRjB4Z2VzZFlSYXdRTDJCVWxmQTcrcVhoMVpZT1lNPSIsImFsZyI6IlJTMjU2Iiwiamt1IjoiaHR0cHM6Ly9tYW11YXQtNmpwYWkwb2YuYXV0aGVudGljYXRpb24uZXUxMC5oYW5hLm9uZGVtYW5kLmNvbS90b2tlbl9rZXlzIiwia2lkIjoiZGVmYXVsdC1qd3Qta2V5LS0xMTUwNDM3OTg0In0"; // fetch from secure storage/session

    final result = await ApiHelper.callGetApi(
      "ExpenseReports?\$filter=StartDate ge ${_formatDate(startDate)}T00:00:00Z and StartDate le ${_formatDate(endDate)}T23:59:59Z",
      accessToken!,
    );

    print("➡️ Request URL: ExpenseReports?\$filter=StartDate ge ${_formatDate(startDate)}T00:00:00Z and StartDate le ${_formatDate(endDate)}T23:59:59Z");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Report")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(true),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Start: ${_formatDate(startDate)}"),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(false),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("End: ${_formatDate(endDate)}"),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _fetchReports,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Search Here", prefixIcon: Icon(Icons.search)),
              onChanged: _filterReports,
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return ExpenseReportCard(report: report, query: searchQuery);
              },
            ),
          )
        ],
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import '../ApiHelper.dart';
import 'ExpenseReportModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseReportDetails extends StatefulWidget {
  final ExpenseReportModel report;

  ExpenseReportDetails({required this.report});

  @override
  _ExpenseReportDetailsState createState() => _ExpenseReportDetailsState();
}

class _ExpenseReportDetailsState extends State<ExpenseReportDetails>
{

  late final r = widget.report;

  // Example data (replace with API/shared prefs)
  late String claimId = r.claimId ;
  late String initiatorId = r.initiator;
  late String amount =r.amount;
  late String location = r.location;
  late String costCentre = r.costCenter;
  late String wbsCode = r.wbsCode;
  late String purpose = r.description;




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

              ],
            ),
          ),
        ],
      ),
    );
  }
}

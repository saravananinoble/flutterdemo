import 'package:flutter/material.dart';

import 'ExpenseApprovalDetails.dart';
import 'ExpenseReportModel.dart';

class ExpenseApprovalCard extends StatelessWidget {
  final ExpenseReportModel report;
  final String query;
  final VoidCallback onRefresh;

  ExpenseApprovalCard({required this.report, required this.query,  required this.onRefresh,});

  TextSpan _highlight(String text, String query) {
    if (query.isEmpty) return TextSpan(text: text);
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start < 0) return TextSpan(text: text);

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: text.substring(start, start + query.length),
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: text.substring(start + query.length)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Navigate to details screen
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseApprovalDetails(report: report),
          ),
        );

        // 🔄 Refresh list if approval was successful
        if (result == true) {
          onRefresh(); // ✅ THIS IS THE KEY LINE
          // Call the refresh method from parent
          // We’ll wire this up in ExpenseApproval
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Expense approved successfully")),
          );
        }
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Claim ID + Initiator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [_highlight(report.claimId, query)],
                    ),
                  ),
                  Text(
                    report.initiator,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Amount + Approved icon
              Row(
                children: [
                  Text(
                    report.amount,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  if (report.status.toLowerCase() == "approved")
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.check_circle, color: Colors.green),
                    ),
                ],
              ),
              SizedBox(height: 8),

              // Description
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),

              // Status
              Text(
                "Status: ${report.status}",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

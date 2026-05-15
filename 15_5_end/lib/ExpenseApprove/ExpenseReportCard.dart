import 'package:flutter/material.dart';

import 'ExpenseReportModel.dart';

class ExpenseReportCard extends StatelessWidget {
  final ExpenseReportModel report;
  final String query;

  ExpenseReportCard({required this.report, required this.query});

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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(text: _highlight(report.claimId, query)),
                Text(report.initiator,
                    style: TextStyle(fontSize: 14, color: Colors.black)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(report.amount,
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                if (report.status.toLowerCase() == "approved")
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 8),
            Text("Status: ${report.status}"),
          ],
        ),
      ),
    );
  }
}

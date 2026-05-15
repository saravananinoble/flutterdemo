
import 'package:flutter/material.dart';


// Example placeholder screens
class ExpenseApproval extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
            title: Text("Expense Approval"),
            leading: BackButton(), // 🔙 iOS + Android back button
          ) ,
          body: Center(child: Text("ORC Screen")));
}
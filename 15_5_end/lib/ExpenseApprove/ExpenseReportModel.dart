class ExpenseReportModel {
  final String claimId;
  final String amount;
  final String description;
  final String initiator;
  final String location;
  final String costCenter;
  final String wbsCode;
  final String refNo;
  final String status;
  final String approvedAmount;
  final String manager;

  ExpenseReportModel({
    required this.claimId,
    required this.amount,
    required this.description,
    required this.initiator,
    required this.location,
    required this.costCenter,
    required this.wbsCode,
    required this.refNo,
    required this.status,
    required this.approvedAmount,
    required this.manager,
  });

  factory ExpenseReportModel.fromJson(Map<String, dynamic> json) {
    return ExpenseReportModel(
      claimId: json['ClaimID'] ?? '',
      amount: "₹${json['QuotationAmount'] ?? ''}",
      description: json['Purpose'] ?? '',
      initiator: json['InitiatorID'] ?? '',
      location: json['Location'] ?? '',
      costCenter: json['CostCentre'] ?? '',
      wbsCode: json['WBSCode'] ?? '',
      refNo: json['reqID'] ?? '',
      status: json['Status'] ?? '',
      approvedAmount: json['ApprovedAmount'] ?? '',
      manager: json['ManagerID'] ?? '',
    );
  }
}

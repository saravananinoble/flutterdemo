import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ExpenseApprove/ExpenseReportModel.dart';

class ApiHelper {
  //  Prod values - keys
  // static const String clientId = "sb-MM_DPDE_Workflows-SSO_PRD!t35908";
  // static const String clientSecret =
  //     "f293e263-e603-471d-b691-89107f893ae3\$YGLS_t6CqQPu-gFFun3huvwUtuS0jJF8Cm3ppRq1L1M=";
  // static const String tokenUrl =
  //     "https://sso-prd-64j43vv0.authentication.ap10.hana.ondemand.com/oauth/token";

  //  Prod values - keys
  static const String clientId = "sb-MM_DPDE_Workflows-MAMUAT!t221160";
  static const String clientSecret =
      "fb0508c2-eddd-4707-945f-fa9639e9610b\$SRBBoZXbDik7QSUIYh4c8_GiSBDI13znULzzGX07HWM=";
  static const String tokenUrl =
      "https://mamuat-6jpai0of.authentication.eu10.hana.ondemand.com/oauth/token";



  static Future<String?> getAccessToken() async {
    final credentials = "$clientId:$clientSecret";
    final basicAuth = "Basic ${base64Encode(utf8.encode(credentials))}";

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        "Authorization": basicAuth,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["access_token"];
    } else {
      print("OAuth failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  static Future<Map<String, dynamic>> callPostApi(
      String endpoint, String accessToken, Map<String, dynamic> body) async {

    //Prod
    // const String apiBaseUrl = "https://mahindra---mahindra-limited-sso-prd-64j43vv0-sso-prd-mm28416596.cfapps.ap10.hana.ondemand.com/approval-hub/"; // 🔧 adjust
    //QA
    const String apiBaseUrl = "https://mahindra---mahindra-limited-mamuat-6jpai0of-mamuat-mm-d10287c0c.cfapps.eu10-004.hana.ondemand.com/approval-hub/";


    final response = await http.post(
      Uri.parse(apiBaseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return {
      "statusCode": response.statusCode,
      "body": response.body,
    };
  }


  static Future<Map<String, dynamic>> callGetApi(
      String endpoint, String accessToken) async {

    //Prod
    // const String apiBaseUrl = "https://mahindra---mahindra-limited-sso-prd-64j43vv0-sso-prd-mm28416596.cfapps.ap10.hana.ondemand.com/approval-hub/"; // 🔧 adjust
    //QA
    const String apiBaseUrl = "https://mahindra---mahindra-limited-mamuat-6jpai0of-mamuat-mm-d10287c0c.cfapps.eu10-004.hana.ondemand.com/approval-hub/";

    final response = await http.get(
      Uri.parse(apiBaseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
    );

    return {
      "statusCode": response.statusCode,
      "body": response.body,
    };
  }

  Future<List<ExpenseReportModel>> fetchExpenseReports(
      String startDate, String endDate, String token) async {
    final endpoint =
        "ExpenseReports?\$filter=StartDate ge ${startDate}T00:00:00Z and StartDate le ${endDate}T23:59:59Z";

    final result = await callGetApi(endpoint, token);

    if (result['statusCode'] == 200) {
      final body = result['body'];
      final jsonData = jsonDecode(body);
      final List<dynamic> values = jsonData['value'];
      return values.map((e) => ExpenseReportModel.fromJson(e)).toList();
    } else {
      throw Exception("API Error: ${result['statusCode']}");
    }
  }



}

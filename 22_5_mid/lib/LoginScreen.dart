import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'NextScreen.dart';
import 'MicrosoftWebLogin.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Validate input first
    if (_usernameController.text.trim().isEmpty) {
      _showError("Please enter username");
      return;
    }

    // if (_passwordController.text.trim().isEmpty) {
    //   _showError("Please enter password");
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    const String baseUrl = "https://cordys2.mahindra.com/cordys/com.eibus.web.soap.Gateway.wcp?organization=o=Mahindra,cn=cordys,cn=BOP4,o=corp.mahindra.com";
    const String namespace = "http://schemas.cordys.com/ORCMetadata";

    final String soapRequest = '''
<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">
 <SOAP:Body>
   <UserAuthentication xmlns="$namespace" preserveSpace="no" qAccess="0" qValues="">
     <UserID>${_usernameController.text.trim()}</UserID>
   </UserAuthentication>
 </SOAP:Body>
</SOAP:Envelope>
''';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "$namespace/UserAuthentication"
        },
        body: soapRequest,
      ).timeout(const Duration(seconds: 30));

      print("=== AUTHENTICATION RESPONSE ===");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Clean the response by decoding HTML entities
        String cleanedResponse = _cleanResponse(response.body);
        print("Cleaned Response: $cleanedResponse");

        // Parse the authentication result
        AuthenticationResult result = _parseAuthResponse(cleanedResponse);

        if (result.isSuccess) {
          print("✅ LOGIN SUCCESSFUL! Message: ${result.message}");
          if (mounted) {
            //save session
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("username_token", _usernameController.text.trim());

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NextScreen()),
              // MicrosoftWebLogin(usernameToken: '', )), // MicrosoftWebLogin , NextScreen
            );
          }
        } else {
          print("❌ LOGIN FAILED! Reason: ${result.message}");
          _showError(result.message);
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Connection error: $e");
      _showError("Network error. Please check your connection.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _cleanResponse(String rawResponse) {
    String cleaned = rawResponse;

    // Decode HTML entities
    cleaned = cleaned.replaceAll('&quot;', '"');
    cleaned = cleaned.replaceAll('&amp;', '&');
    cleaned = cleaned.replaceAll('&lt;', '<');
    cleaned = cleaned.replaceAll('&gt;', '>');
    cleaned = cleaned.replaceAll('&apos;', "'");

    // Remove extra whitespace
    cleaned = cleaned.trim();

    return cleaned;
  }

  AuthenticationResult _parseAuthResponse(String response) {
    // Check for SOAP Fault (authentication error)
    if (response.contains('<soap:Fault') ||
        response.contains('<SOAP:Fault')) {

      // Extract fault message
      RegExp faultRegex = RegExp(r'<faultstring>(.*?)</faultstring>', caseSensitive: false);
      RegExpMatch? match = faultRegex.firstMatch(response);
      String faultMessage = match != null ? match.group(1)! : "Authentication failed";

      return AuthenticationResult(false, faultMessage);
    }

    // Check for status code 0 (success in many systems)
    RegExp statusRegex = RegExp(r'"status"\s*:\s*"?(\d+)"?|<status>(\d+)</status>', caseSensitive: false);
    RegExpMatch? statusMatch = statusRegex.firstMatch(response);

    if (statusMatch != null) {
      String statusValue = statusMatch.group(1) ?? statusMatch.group(2) ?? "";
      if (statusValue == "0") {
        return AuthenticationResult(true, "Login successful");
      }
      else if (statusValue == "2") {
        return AuthenticationResult(false, "Authentication failed with status: $statusValue" + " - User Not Found");
      }
      else {
        return AuthenticationResult(false, "Authentication failed with status: $statusValue");
      }
    }

    // Check for success message in description
    RegExp descRegex = RegExp(r'"description"\s*:\s*"([^"]+)"', caseSensitive: false);
    RegExpMatch? descMatch = descRegex.firstMatch(response);

    if (descMatch != null) {
      String description = descMatch.group(1)!;
      if (description.toLowerCase().contains("ok") ||
          description.toLowerCase().contains("success")) {
        return AuthenticationResult(true, description);
      } else {
        return AuthenticationResult(false, description);
      }
    }

    // Check for success elements in XML
    if (response.contains('<result>success</result>') ||
        response.contains('<Success>true</Success>') ||
        response.contains('<authenticated>true</authenticated>')) {
      return AuthenticationResult(true, "Authentication successful");
    }

    // Check for failure elements
    if (response.contains('<result>failure</result>') ||
        response.contains('<Success>false</Success>') ||
        response.contains('<authenticated>false</authenticated>') ||
        response.toLowerCase().contains('invalid credentials')) {
      return AuthenticationResult(false, "Invalid credentials");
    }

    // If response is not empty and status is 200, but no clear indicators
    if (response.isNotEmpty && response.length > 50) {
      print("⚠️ Ambiguous response but non-empty, treating as success");
      return AuthenticationResult(true, "Login successful (ambiguous response)");
    }

    // Default to failure
    return AuthenticationResult(false, "Authentication failed - unknown response format");
  }



  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // UI design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(33.0),
                child:Container(
                    child: Center(
                      child: Image.asset(
                        'assets/rise_logo_xh.png', // Replace with your image path
                        fit: BoxFit.contain,        // Ensures the image fits within the 80 height
                      ),
                    ),
                  ),
              ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      hintText: "Username",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  // TextField(
                  //   controller: _passwordController,
                  //   obscureText: !_showPassword,
                  //   decoration: InputDecoration(
                  //     prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  //     hintText: "Password",
                  //     hintStyle: const TextStyle(color: Colors.white70),
                  //     filled: true,
                  //     fillColor: Colors.black45,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //   ),
                  //   style: const TextStyle(color: Colors.white),
                  // ),
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       value: _showPassword,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _showPassword = value ?? false;
                  //         });
                  //       },
                  //     ),
                  //     const Text("Show Password", style: TextStyle(color: Colors.white)),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SUBMIT", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class for authentication result
class AuthenticationResult {
  final bool isSuccess;
  final String message;

  AuthenticationResult(this.isSuccess, this.message);
}


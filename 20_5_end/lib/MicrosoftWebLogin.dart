import 'package:flutter/material.dart';
import 'package:untitled/NextScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MicrosoftWebLogin extends StatefulWidget {
  final String usernameToken;

  const MicrosoftWebLogin({
    Key? key,
    required this.usernameToken,
  }) : super(key: key);

  @override
  _MicrosoftWebLoginState createState() => _MicrosoftWebLoginState();
}

class _MicrosoftWebLoginState extends State<MicrosoftWebLogin> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            setState(() => _loading = false);

            if (url == "https://login.microsoftonline.com/common/SAS/ProcessAuth") {
              // Store user session in SharedPreferences -- save session
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("username_token", widget.usernameToken);


              // await prefs.setString("user_name", widget.userName);
              // await prefs.setString("user_email", widget.userEmail);
              // await prefs.setString("user_role", widget.userRole);

              // Navigate to your dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>  NextScreen()),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://login.microsoftonline.com/?login_hint=${widget.usernameToken}@mahindra.com"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Microsoft Login")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}


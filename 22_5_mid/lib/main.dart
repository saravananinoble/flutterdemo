import 'package:flutter/material.dart';


import 'NextScreen.dart';
import 'MicrosoftWebLogin.dart';

import 'LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahindra Rise Login',
      theme: ThemeData.dark(),
      home:  const StartupScreen(),   // NextScreen , LoginScreen
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    initialization();
  }
  void initialization() async
  {
    _checkLogin();
    FlutterNativeSplash.remove();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("username_token");

    if (token != null && token.isNotEmpty) {
      // User already logged in → go to NextScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  NextScreen()),
      );
    } else {
      // No stored session → go to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a splash/loading indicator while checking
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}













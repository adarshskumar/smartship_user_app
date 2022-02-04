import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './Utils/smart.dart';
import './screens/emergencyBreakdown_screen.dart';
import './screens/login_screen.dart';
import './screens/main_screen.dart';
import './screens/map_screen.dart';
import './screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
      routes: {
        WelcomeScreen.route: (context) => WelcomeScreen(),
        LoginScreen.route: (context) => LoginScreen(),
        MainScreen.route: (context) => MainScreen(),
        MapScreen.route: (context) => MapScreen(),
        EmergencyBreakdown.route: (context) => EmergencyBreakdown(),
      },
    );
  }
}

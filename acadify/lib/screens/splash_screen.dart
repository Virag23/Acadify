import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:acadify/screens/college_selection.dart';
import 'home.dart';
import 'faculty_home.dart';
import 'adminHome.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String displayedText = "";
  final String fullText = "ACADIFY";
  int charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  // Control splash screen timing
  void _startSplashScreen() async {
    await _startTypingEffect(); // Finish text animation within 1 sec
    await Future.delayed(
        const Duration(milliseconds: 300)); // Stay visible for 1 more sec
    _checkLoginStatus(); // Navigate to the next page
  }

  // Typing animation effect (complete in ~1 sec)
  Future<void> _startTypingEffect() async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 250));
      if (mounted) {
        setState(() {
          displayedText += fullText[i];
        });
      }
    }
  }

  // Check login and navigate accordingly
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? userRole = prefs.getString('userRole');
    final String? collegeName = prefs.getString('college_name');

    Widget nextPage = CollegeSelectionPage(); // Default to college selection

    if (isLoggedIn && userRole != null && collegeName != null) {
      switch (userRole) {
        case "student":
          nextPage = HomePage(
            collegeName: '',
          );
          break;
        case "faculty":
          nextPage = FacultyHomePage(
            collegeName: '',
          );
          break;
        case "admin":
          nextPage = AdminHomePage(
            collegeName: '',
          );
          break;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 63, 133, 255),
              Color.fromARGB(255, 71, 196, 254)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            displayedText,
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.black38,
                  offset: Offset(4.0, 4.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

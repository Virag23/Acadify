import 'package:acadify/screens/admin_timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:acadify/screens/splash_screen.dart';
import 'package:acadify/screens/college_selection.dart';
import 'package:acadify/screens/student_registration.dart';
import 'package:acadify/screens/faculty_registration.dart';
import 'package:acadify/screens/adminRegistration.dart';
import 'package:acadify/screens/login.dart';
import 'package:acadify/screens/faculty_login.dart';
import 'package:acadify/screens/adminLogin.dart';
import 'package:acadify/screens/home.dart';
import 'package:acadify/screens/faculty_home.dart';
import 'package:acadify/screens/adminHome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp(
    initialRoute: '',
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required String initialRoute}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> initialRoute;

  @override
  void initState() {
    super.initState();
    initialRoute = _getInitialRoute();
  }

  Future<String> _getInitialRoute() async {
    await Future.delayed(
        const Duration(seconds: 5)); // Ensure splash is shown for 2s

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? userRole = prefs.getString('userRole');

    if (isLoggedIn && userRole != null) {
      switch (userRole) {
        case 'student':
          return '/studentHome';
        case 'faculty':
          return '/facultyHome';
        case 'admin':
          return '/adminHome';
      }
    }
    return '/collegeSelection';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ACADIFY',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<String>(
        future: initialRoute,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // Keep showing splash while loading
          } else {
            return _getPage(snapshot.data ?? '/collegeSelection');
          }
        },
      ),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/collegeSelection': (context) => CollegeSelectionPage(),
        '/studentRegistration': (context) => StudentRegistrationPage(
              collegeName: '',
            ),
        '/facultyRegistration': (context) => FacultyRegistrationPage(
              collegeName: '',
            ),
        '/adminRegistration': (context) => AdminRegistrationPage(
              collegeName: '',
            ),
        '/login': (context) => LoginPage(
              collegeName: '',
            ),
        '/facultyLogin': (context) => FacultyLogin(
              collegeName: '',
            ),
        '/adminLogin': (context) => AdminLogin(
              collegeName: '',
            ),
        '/studentHome': (context) => HomePage(
              collegeName: '',
            ),
        '/facultyHome': (context) => FacultyHomePage(
              collegeName: '',
            ),
        '/adminHome': (context) => AdminHomePage(
              collegeName: '',
            ),
        '/adminTimeTable': (context) => AdminTimetableScreen(
              collegeName: '',
            ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: const Center(child: Text('404: Page not found')),
        ),
      ),
    );
  }

  Widget _getPage(String route) {
    switch (route) {
      case '/studentHome':
        return HomePage(
          collegeName: '',
        );
      case '/facultyHome':
        return FacultyHomePage(
          collegeName: '',
        );
      case '/adminHome':
        return AdminHomePage(
          collegeName: '',
        );
      case '/collegeSelection':
        return CollegeSelectionPage();
      default:
        return CollegeSelectionPage();
    }
  }
}

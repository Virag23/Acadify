import 'package:acadify/screens/Admin_profile_page.dart';
import 'package:acadify/screens/Faculty_profile_page.dart';
import 'package:acadify/screens/Student_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acadify/screens/home.dart';
import 'package:acadify/screens/faculty_home.dart';
import 'package:acadify/screens/adminHome.dart';
import 'package:acadify/screens/college_selection.dart';
import 'package:acadify/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ACADIFY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const MainScreen(), // Entry point
        '/splash': (context) => SplashScreen(), // Splash screen
        '/collegeSelection': (context) =>
            CollegeSelectionPage(), // College selection
        '/studentHome': (context) => HomePage(
              collegeName: '',
              college: '',
            ), // Student home page
        '/facultyHome': (context) => FacultyHomePage(
              collegeName: '',
              college: '',
            ), // Faculty home page
        '/adminHome': (context) => AdminHomePage(
              collegeName: '',
              college: '',
            ), // Admin home page
        '/StudentProfilePage': (context) => StudentProfilePage(
              collegeName: '',
              college: '',
            ),
        '/FacultyProfilePage': (context) => FacultyProfilePage(
              collegeName: '',
              college: '',
            ),
        '/AdminProfilePage': (context) => AdminProfilePage(
              collegeName: '',
              college: '',
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
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status on app launch
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? userRole = prefs.getString('userRole');

    if (isLoggedIn && userRole != null) {
      _navigateToHomePage(userRole); // Navigate to the home page based on role
    } else {
      // Navigate to splash screen for new users
      Navigator.pushReplacementNamed(context, '/splash');
    }
  }

  void _navigateToHomePage(String role) {
    String routeName;

    switch (role) {
      case 'student':
        routeName = '/studentHome'; // Student home page route
        break;
      case 'faculty':
        routeName = '/facultyHome'; // Faculty home page route
        break;
      case 'admin':
        routeName = '/adminHome'; // Admin home page route
        break;
      default:
        routeName = '/collegeSelection'; // Fallback route
    }

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Loading indicator
      ),
    );
  }
}

import 'package:acadify/screens/adminRegistration.dart';
import 'package:acadify/screens/faculty_registration.dart';
import 'package:acadify/screens/student_registration.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'college_selection.dart'; // Import the CollegeSelectionPage

class UserSelectionPage extends StatefulWidget {
  final String collegeName;
  final String college;

  UserSelectionPage({required this.collegeName, required this.college});

  @override
  _UserSelectionPageState createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  String? collegeName;
  String? college;

  @override
  void initState() {
    super.initState();
    _loadCollegeName();
  }

  // Fetch college name from SharedPreferences
  Future<void> _loadCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collegeName = prefs.getString('college_full_name');
      college = prefs.getString('college_name');
    });

    if (collegeName == null || college == null) {
      Future.delayed(Duration.zero, () {
        showSnackbar(context, "Error: College name not found!", Colors.red);
      });
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('college_full_name'); // Remove selected college name
    await prefs.remove('college_name'); // Remove selected college
    await prefs.remove('isLoggedIn'); // Remove login status (if needed)
    await prefs.remove('userRole'); // Remove user role (if needed)

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CollegeSelectionPage()),
    );
  }

  // Function to show Snackbar
  void showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ACADIFY',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call logout function
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                collegeName ?? 'Loading...',
                textAlign: TextAlign
                    .center, // Ensures text alignment within the widget
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'User Selection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserBox(
                    title: 'Student',
                    icon: Icons.school,
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentRegistrationPage(
                                  collegeName: collegeName ?? '',
                                  college: college ?? '')));
                    },
                  ),
                  UserBox(
                    title: 'Faculty',
                    icon: Icons.person,
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FacultyRegistrationPage(
                                    collegeName: collegeName ?? '',
                                    college: '',
                                  )));
                    },
                  ),
                  UserBox(
                    title: 'Admin',
                    icon: Icons.admin_panel_settings,
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminRegistrationPage(
                                    collegeName: collegeName ?? '',
                                    college: '',
                                  )));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const UserBox({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue[100],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

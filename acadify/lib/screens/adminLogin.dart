import 'package:acadify/screens/adminRegistration.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acadify/screens/adminHome.dart';

Future<void> saveLoginStatus(
    bool status,
    String role,
    String collegeName,
    String college,
    String name,
    String email,
    String number,
    String department,
    String year,
    String division,
    String semester) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', status); // Save login status
  await prefs.setString('userRole', role); // Save user role
  await prefs.setString('college_full_name', collegeName); // Save college name
  await prefs.setString('college_name', college); // Save college
  await prefs.setString('name', name); // Save name
  await prefs.setString('email', email); // Save email
  await prefs.setString('number', number); // Save phone number
  await prefs.setString('department', department); // Save department
  await prefs.setString('year', year); // Save year
  await prefs.setString('division', division); // Save division
  await prefs.setString('semester', semester); // Save semester
}

class AdminLogin extends StatefulWidget {
  final String collegeName;
  final String college;

  AdminLogin({required this.collegeName, required this.college});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? collegeName;
  String? college;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCollegeName();
  }

  Future<void> _loadCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collegeName = prefs.getString('college_full_name');
      college = prefs.getString('college_name');
    });

    if (college == null || collegeName == null) {
      showSnackbar(context, "Error: College name not found!", Colors.red);
    }
  }

  Future<void> saveAdminDetails(Map<String, dynamic> userDetails) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('name', userDetails['name']);
    await prefs.setString('email', userDetails['email']);
    await prefs.setString('number', userDetails['number']);
    await prefs.setString('department', userDetails['department']);
    await prefs.setString('year', userDetails['year']);
    await prefs.setString('semester', userDetails['semester']);
    await prefs.setString('division', userDetails['division']);
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackbar(context, 'Please fill in all fields!', Colors.red);
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@college\.org$")
        .hasMatch(emailController.text)) {
      showSnackbar(context, "Please enter a valid email address!", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.123.47:5000/api/adminLogin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'college': college,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final userDetails = jsonDecode(response.body);

        await saveLoginStatus(
            true,
            'admin',
            collegeName ?? '',
            college ?? '',
            userDetails['name'],
            userDetails['email'],
            userDetails['number'],
            userDetails['department'],
            userDetails['year'],
            userDetails['division'],
            userDetails['semester']);
        await saveAdminDetails(userDetails);

        showSnackbar(context, 'Welcome, ${userDetails['name']}!', Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AdminHomePage(
                    collegeName: collegeName ?? '',
                    college: college ?? '',
                  )),
        );
      } else {
        showSnackbar(
            context, 'Invalid Credentials! Please try again.', Colors.red);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, "Error: Unable to login. Please try again later.",
          Colors.red);
    }
  }

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
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Center(
                  child: Text('Admin Login',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  alignLabelWithHint: true,
                ),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  alignLabelWithHint: true,
                ),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 20),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => login(context),
                        child: Text('Login',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                        ),
                      ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminRegistrationPage(
                                collegeName: collegeName ?? '',
                                college: college ?? '')));
                  },
                  child: Text(
                    "New Admin? Register here",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

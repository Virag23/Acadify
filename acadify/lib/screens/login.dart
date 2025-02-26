import 'package:acadify/screens/student_registration.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:acadify/screens/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginStatus(
    bool status, String role, String collegeName, String college) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', status);
  await prefs.setString('userRole', role);
  await prefs.setString('college_name', collegeName);
  await prefs.setString('college', college);
}

class LoginPage extends StatefulWidget {
  final String collegeName;
  final String college;

  LoginPage({required this.collegeName, required this.college});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? collegeName;
  String? college;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCollegeName(); // Load the college name when screen starts
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

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackbar(context, 'Please fill in all fields!', Colors.red);
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@gmail\.com$")
        .hasMatch(emailController.text)) {
      showSnackbar(context, "Please enter a valid email address!", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.108.47:5000/api/login');
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
        final name = jsonDecode(response.body)['name'];

        await saveLoginStatus(true, "student", collegeName!, college!);

        showSnackbar(context, 'Welcome, $name!', Colors.green);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                    collegeName: collegeName ?? '', college: college ?? '')));
      } else {
        showSnackbar(
            context, 'Invalid Credentials! Please try again.', Colors.red);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, 'Error: Unable to login. Please try again later.',
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
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Center(
                  child: Text('Student Login',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => login(context),
                        child: Text('Login', style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20)),
                      ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentRegistrationPage(
                                  collegeName: collegeName ?? '',
                                  college: college ?? '',
                                )));
                  },
                  child: Text("New student? Register here",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

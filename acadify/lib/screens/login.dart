import 'package:acadify/screens/student_registration.dart';
import 'package:acadify/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:acadify/screens/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    String semester,
    String rollNo) async {
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
  await prefs.setString('roll_no', rollNo); // Save roll number
}

class LoginPage extends StatefulWidget {
  final String collegeName;
  final String college;

  const LoginPage(
      {super.key, required this.collegeName, required this.college});

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

  Future<void> saveStudentDetails(Map<String, dynamic> userDetails) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('name', userDetails['name']);
    await prefs.setString('email', userDetails['email']);
    await prefs.setString('number', userDetails['number']);
    await prefs.setString('prn', userDetails['prn']);
    await prefs.setString('department', userDetails['department']);
    await prefs.setString('year', userDetails['year']);
    await prefs.setString('semester', userDetails['semester']);
    await prefs.setString('division', userDetails['division']);
    await prefs.setString('roll_no', userDetails['roll_no']);
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
      final response = await http.post(
        Uri.parse('http://192.168.38.47:5000/api/login'),
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
            "student",
            collegeName!,
            college!,
            userDetails['name'],
            userDetails['email'],
            userDetails['number'],
            userDetails['department'],
            userDetails['year'],
            userDetails['division'],
            userDetails['semester'],
            userDetails['roll_no']);
        await saveStudentDetails(userDetails);

        showSnackbar(context, 'Welcome, ${userDetails['name']}!', Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
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
          style: TextStyles.acadifyTitle,
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
                    style: TextStyles.collegeName,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Center(
                  child: Text('Student Login', style: TextStyles.headingText),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyles.bodyText.copyWith(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                style: TextStyles
                    .bodyText, // Ensures text inside the TextField also uses Roboto
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyles.bodyText.copyWith(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                style: TextStyles
                    .bodyText, // Ensures text inside the TextField also uses Roboto
              ),
              SizedBox(height: 20),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => login(context),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20)),
                        child: Text('Login', style: TextStyles.headingText),
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
                      style: TextStyles.bodyText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:acadify/screens/faculty_home.dart';
import 'package:acadify/screens/faculty_login.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // HTTP requests
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginStatus(
    bool status,
    String role,
    String collegeName,
    String college,
    String name,
    String email,
    String number,
    String department) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', status); // Save login status
  await prefs.setString('userRole', role); // Save user role
  await prefs.setString('college_full_name', collegeName); // Save college name
  await prefs.setString('college_name', college); // Save college
  await prefs.setString('name', name); // Save name
  await prefs.setString('email', email); // Save email
  await prefs.setString('number', number); // Save phone number
  await prefs.setString('department', department); // Save department
}

class FacultyRegistrationPage extends StatefulWidget {
  final String collegeName;
  final String college;

  FacultyRegistrationPage({required this.collegeName, required this.college});

  @override
  _FacultyRegistrationPageState createState() =>
      _FacultyRegistrationPageState();
}

class _FacultyRegistrationPageState extends State<FacultyRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedDepartment;
  String? collegeName;
  String? college;

  bool isLoading = false; // To track the loading state

  final List<String> departments = [
    "CSE",
    "IT",
    "EnTC",
    "ECE",
    "Civil",
    "Mechanical"
  ];

  @override
  void initState() {
    super.initState();
    _loadCollegeName(); // Load the college name when screen starts
  }

  // Function to get college_name from SharedPreferences
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

  Future<void> registerFaculty(BuildContext context) async {
    if (collegeName == null || college == null) {
      showSnackbar(context, "Error: No college selected!", Colors.red);
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        selectedDepartment == null ||
        numberController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Email validation
    if (!RegExp(r"^[a-zA-Z0-9]+@college\.org$")
        .hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid institutional email!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Phone number validation
    if (numberController.text.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(numberController.text)) {
      print("Invalid phone number!"); // Debug Log 3
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid 10-digit phone number!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.123.47:5000/api/facultyregister');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "college": college,
          'name': nameController.text,
          'email': emailController.text,
          'number': numberController.text,
          'department': selectedDepartment,
          'password': passwordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        // ignore: unused_local_variable
        final name = jsonDecode(response.body)['name'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true); // Set login status to true
        await prefs.setString('name', nameController.text);
        await prefs.setString('email', emailController.text);
        await prefs.setString('number', numberController.text);
        await prefs.setString('department', selectedDepartment!);

        await saveLoginStatus(
            true,
            "faculty",
            collegeName!,
            college!,
            nameController.text,
            emailController.text,
            numberController.text,
            selectedDepartment!);

        showSnackbar(
            context,
            'Faculty registered successfully, Welcome, $nameController',
            Colors.green);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FacultyHomePage(
                      collegeName: collegeName ?? '',
                      college: college ?? '',
                    )));
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration Failed: $error'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      showSnackbar(context,
          "Error: Unable to register. Please try again later.", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                child: Text('Faculty Registration',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 15),
            TextField(
              controller: numberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: InputDecoration(labelText: 'Select Department'),
              items: departments.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
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
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            Center(
              child: isLoading
                  ? CircularProgressIndicator() // Show loading indicator if isLoading is true
                  : ElevatedButton(
                      onPressed: () => registerFaculty(context),
                      child: Text('Register',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20), // Button size
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
                          builder: (context) => FacultyLogin(
                              collegeName: collegeName ?? '', college: '')));
                },
                child: Text(
                  "Already a registered faculty? Log in here.",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

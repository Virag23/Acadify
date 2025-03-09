import 'package:acadify/screens/faculty_home.dart';
import 'package:acadify/screens/faculty_login.dart';
import 'package:acadify/theme/text_styles.dart';
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

  const FacultyRegistrationPage(
      {super.key, required this.collegeName, required this.college});

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
      final url = Uri.parse('http://192.168.38.47:5000/api/facultyregister');
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
        title: Text('ACADIFY', style: TextStyles.acadifyTitle),
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
                  style: TextStyles.collegeName,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Center(
                child:
                    Text('Faculty Registration', style: TextStyles.headingText),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Full Name',
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
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyles.bodyText.copyWith(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: TextStyles
                  .bodyText, // Ensures text inside the TextField also uses Roboto
            ),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              decoration: InputDecoration(labelText: 'Select Department'),
              items: departments.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(
                    dept,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
              style: TextStyles.bodyText,
            ),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
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
                  ? CircularProgressIndicator() // Show loading indicator if isLoading is true
                  : ElevatedButton(
                      onPressed: () => registerFaculty(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20), // Button size
                      ),
                      child: Text('Register', style: TextStyles.headingText),
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
                  style: TextStyles.bodyText,
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

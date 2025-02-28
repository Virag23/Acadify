import 'package:acadify/screens/adminHome.dart';
import 'package:acadify/screens/adminLogin.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
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

class AdminRegistrationPage extends StatefulWidget {
  final String collegeName;
  final String college;

  AdminRegistrationPage({required this.collegeName, required this.college});

  @override
  _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedDepartment;
  String? selectedYear;
  String? selectedSemester;
  String? selectedDivision;
  String? collegeName;
  String? college;

  bool isLoading = false;

  final List<String> departments = [
    "CSE",
    "IT",
    "EnTC",
    "ECE",
    "Civil",
    "Mechanical"
  ];
  final List<String> years = ["FY", "SY", "TY", "BE"];
  final List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];
  final List<String> divisions = ["A", "B", "C"];

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

    if (collegeName == null || college == null) {
      showSnackbar(context, "Error: College name not found!", Colors.red);
    }
  }

  Future<void> registerAdmin(BuildContext context) async {
    if (collegeName == null || college == null) {
      showSnackbar(context, "Error: No college selected!", Colors.red);
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        numberController.text.isEmpty ||
        selectedDepartment == null ||
        selectedYear == null ||
        selectedSemester == null ||
        selectedDivision == null ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All fields are required!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9]+@college\.org$")
        .hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid email!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (numberController.text.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(numberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid phone number!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.123.47:5000/api/adminRegister');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "college": college,
          'name': nameController.text,
          'email': emailController.text,
          'number': numberController.text,
          'department': selectedDepartment,
          'year': selectedYear,
          'semester': selectedSemester,
          'division': selectedDivision,
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

        await saveLoginStatus(
            true,
            "admin",
            collegeName!,
            college!,
            nameController.text,
            emailController.text,
            numberController.text,
            selectedDepartment!,
            selectedYear!,
            selectedDivision!,
            selectedSemester!);

        showSnackbar(
            context,
            'Admin registered successfully, Welcome, $nameController',
            Colors.green);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AdminHomePage(
                      collegeName: collegeName ?? '',
                      college: college ?? '',
                    )));
      } else {
        final error = jsonDecode(response.body)['error'] ?? "Unknown error";
        showSnackbar(context, "Registration Failed: $error", Colors.red);
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
                child: Text('Admin Registration',
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
              items: departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: InputDecoration(labelText: 'Select Year'),
              items: years.map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: InputDecoration(labelText: 'Select Current Semester'),
              items: semesters.map((sem) {
                return DropdownMenuItem<String>(
                  value: sem,
                  child: Text(sem),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedDivision,
              decoration: InputDecoration(labelText: 'Select Division'),
              items: divisions.map((div) {
                return DropdownMenuItem<String>(
                  value: div,
                  child: Text(div),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDivision = value;
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
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => registerAdmin(context),
                      child: Text('Register',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                          builder: (context) => AdminLogin(
                              collegeName: collegeName ?? '',
                              college: college ?? '')));
                },
                child: Text(
                  "Already have an account? Login here",
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

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items.map((value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

void showSnackbar(BuildContext context, String s, MaterialColor red) {}

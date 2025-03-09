import 'package:acadify/screens/home.dart';
import 'package:acadify/screens/login.dart';
import 'package:acadify/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For storing user data

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

class StudentRegistrationPage extends StatefulWidget {
  final String collegeName;
  final String college;

  const StudentRegistrationPage(
      {super.key, required this.collegeName, required this.college});

  @override
  _StudentRegistrationPageState createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController prnController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedDepartment;
  String? selectedYear;
  String? selectedSemester;
  String? selectedDivision;
  String? collegeName; // Store selected college name
  String? college; // Store selected college

  bool isLoading = false; // Track loading state

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

  Future<void> registerStudent(BuildContext context) async {
    if (collegeName == null || college == null) {
      showSnackbar(context, "Error: No college selected!", Colors.red);
      return;
    }

    if (emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        nameController.text.isEmpty ||
        prnController.text.isEmpty ||
        selectedDepartment == null ||
        selectedYear == null ||
        selectedSemester == null ||
        selectedDivision == null ||
        rollNoController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showSnackbar(context, "All fields are required!", Colors.red);
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@gmail\.com$")
        .hasMatch(emailController.text)) {
      showSnackbar(context, "Please enter a valid email address!", Colors.red);
      return;
    }

    // **Phone Number Validation**
    if (phoneController.text.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      showSnackbar(
          context, "Please enter a valid 10-digit phone number!", Colors.red);
      return;
    }

    // **PRN Validation**
    if (prnController.text.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(prnController.text)) {
      showSnackbar(context, "PRN should only contain numbers!", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.38.47:5000/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "college": college, // Send college name dynamically
          "name": nameController.text,
          "email": emailController.text,
          "number": phoneController.text,
          "prn": prnController.text,
          "department": selectedDepartment,
          "year": selectedYear,
          "semester": selectedSemester,
          "division": selectedDivision,
          "roll_no": rollNoController.text,
          "password": passwordController.text
        }),
      );

      if (response.statusCode == 201) {
        // ignore: unused_local_variable
        final name = jsonDecode(response.body)['name'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true); // Set login status to true
        await prefs.setString('name', nameController.text);
        await prefs.setString('email', emailController.text);
        await prefs.setString('number', phoneController.text);
        await prefs.setString('prn', prnController.text);
        await prefs.setString('department', selectedDepartment!);
        await prefs.setString('year', selectedYear!);
        await prefs.setString('semester', selectedSemester!);
        await prefs.setString('division', selectedDivision!);
        await prefs.setString('roll_no', rollNoController.text);

        await saveLoginStatus(
            true,
            "student",
            collegeName!,
            college!,
            nameController.text,
            emailController.text,
            phoneController.text,
            selectedDepartment!,
            selectedYear!,
            selectedDivision!,
            selectedSemester!,
            rollNoController.text);

        showSnackbar(context,
            'Registered successfully, Welcome, $nameController', Colors.green);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      collegeName: collegeName ?? '',
                      college: '',
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
        title: Text('ACADIFY', style: TextStyles.acadifyTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                child:
                    Text('Student Registration', style: TextStyles.headingText),
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
              style: TextStyles.bodyText,
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
              style: TextStyles.bodyText,
            ),
            SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyles.bodyText,
            ),
            SizedBox(height: 15),
            TextField(
              controller: prnController,
              decoration: InputDecoration(
                labelText: 'PRN Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyles.bodyText,
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
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: InputDecoration(labelText: 'Select Current Year'),
              items: years.map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(
                    year,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
              style: TextStyles.bodyText,
            ),
            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: InputDecoration(labelText: 'Select Current Semester'),
              items: semesters.map((sem) {
                return DropdownMenuItem<String>(
                  value: sem,
                  child: Text(
                    sem,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
              style: TextStyles.bodyText,
            ),
            DropdownButtonFormField<String>(
              value: selectedDivision,
              decoration: InputDecoration(labelText: 'Select Your Division'),
              items: divisions.map((div) {
                return DropdownMenuItem<String>(
                  value: div,
                  child: Text(
                    div,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDivision = value;
                });
              },
              style: TextStyles.bodyText,
            ),
            SizedBox(height: 15),
            TextField(
              controller: rollNoController,
              decoration: InputDecoration(
                labelText: 'Roll No.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyles.bodyText,
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                alignLabelWithHint: true,
              ),
              style: TextStyles.bodyText,
            ),
            SizedBox(height: 20),
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => registerStudent(context),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                          builder: (context) => LoginPage(
                                collegeName: collegeName ?? '',
                                college: '',
                              )));
                },
                child: Text("Already a registered student? Log in here.",
                    style: TextStyles.bodyText),
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

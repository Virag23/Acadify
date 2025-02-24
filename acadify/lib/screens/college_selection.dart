import 'package:acadify/screens/user_selection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeSelectionPage extends StatefulWidget {
  @override
  _CollegeSelectionPageState createState() => _CollegeSelectionPageState();
}

class _CollegeSelectionPageState extends State<CollegeSelectionPage> {
  String? selectedCollege;
  List<String> colleges = [];
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedCollege = prefs.getString('collegel_name');
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (savedCollege != null && isLoggedIn) {
      // If a college is already selected and user is logged in, skip to the next screen.
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserSelectionPage(
                  collegeName: selectedCollege ??
                      ''))); // Provide a default value if null
    } else {
      // Fetch colleges if login status is not valid.
      fetchColleges();
    }
  }

  Future<void> saveCollegeName(String collegeName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('college_name', collegeName); // Save the college name
  }

  Future<void> saveLoginStatus(bool status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', status); // Save login status
  }

  Future<void> fetchColleges() async {
    final response =
        await http.get(Uri.parse('http://192.168.108.47:5000/api/colleges'));

    if (response.statusCode == 200) {
      final List<dynamic> collegeList = jsonDecode(response.body);
      setState(() {
        colleges = collegeList
            .map((college) => college['college_name'].toString())
            .toList();
      });
    }
  }

  Future<void> verifyCollege() async {
    if (selectedCollege == null || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a college & enter password")));
      return;
    }

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://192.168.108.47:5000/api/verify_college'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "college_name": selectedCollege,
        "password": passwordController.text
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      await saveCollegeName(selectedCollege!);
      await saveLoginStatus(true);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserSelectionPage(collegeName: selectedCollege ?? '')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid Password!")));
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text(
                'Select Institute',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownButton<String>(
              hint: const Text("Select College",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
              value: selectedCollege,
              isExpanded: true,
              items: colleges.map((college) {
                return DropdownMenuItem(value: college, child: Text(college));
              }).toList(),
              onChanged: (value) => setState(() => selectedCollege = value),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter College Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: verifyCollege,
                      child: const Text("Verify",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

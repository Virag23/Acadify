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
  String? selectedName;
  List<String> colleges = [];
  List<String> names = [];
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedCollege = prefs.getString('college_full_name');
    final String? savedName = prefs.getString('college_name');
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (savedCollege != null && savedName != null && isLoggedIn) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserSelectionPage(
                    collegeName: savedCollege,
                    college: savedName,
                  )));
    } else {
      fetchColleges();
    }
  }

  Future<void> saveCollegeName(String collegeName, String college) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('college_full_name', collegeName);
    await prefs.setString('college_name', college);
  }

  Future<void> saveLoginStatus(bool status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', status);
  }

  Future<void> fetchColleges() async {
    try {
      final collegeResponse =
          await http.get(Uri.parse('http://192.168.123.47:5000/api/colleges'));
      final nameResponse =
          await http.get(Uri.parse('http://192.168.123.47:5000/api/names'));

      if (collegeResponse.statusCode == 200 && nameResponse.statusCode == 200) {
        final List<dynamic> collegeList = jsonDecode(collegeResponse.body);
        final List<dynamic> nameList = jsonDecode(nameResponse.body);

        setState(() {
          colleges = collegeList
              .map((college) => college['college_full_name'].toString())
              .toList();
          names =
              nameList.map((name) => name['college_name'].toString()).toList();
        });
      } else {
        print(
            "Error fetching data: ${collegeResponse.statusCode}, ${nameResponse.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> verifyCollege() async {
    if (selectedCollege == null ||
        selectedName == null ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a college & enter password")));
      return;
    }

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://192.168.123.47:5000/api/verify_college'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "college_full_name": selectedCollege,
        "college_name": selectedName,
        "password": passwordController.text
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      await saveCollegeName(selectedCollege!, selectedName!);
      await saveLoginStatus(true);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserSelectionPage(
                    collegeName: selectedCollege!,
                    college: selectedName!,
                  )));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid Password!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ACADIFY',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Select Institute',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            DropdownButton<String>(
              hint: const Text("Select College Name"),
              value: selectedCollege,
              isExpanded: true,
              items: colleges.map((college) {
                return DropdownMenuItem(value: college, child: Text(college));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCollege = value; // Sync college name
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButton<String>(
              hint: const Text("Select College"),
              value: selectedName,
              isExpanded: true,
              items: names.map((name) {
                return DropdownMenuItem(value: name, child: Text(name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedName = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter College Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: verifyCollege,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text("Verify",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

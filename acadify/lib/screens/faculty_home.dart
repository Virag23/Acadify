import 'package:acadify/screens/Faculty_profile_page.dart';
import 'package:acadify/theme/text_styles.dart';
import 'package:flutter/material.dart';
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
  await prefs.setString('number', number);
  await prefs.setString('department', department);
}

class FacultyHomePage extends StatefulWidget {
  final String collegeName;
  final String college;

  const FacultyHomePage(
      {super.key, required this.collegeName, required this.college});

  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  String? collegeName;
  String? college;
  String name = '', email = '', number = '', department = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCollegeName();
    _loadStudentDetails();
  }

  Future<void> _loadCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collegeName = prefs.getString('college_full_name') ?? widget.collegeName;
      college = prefs.getString('college_name') ?? widget.college;
    });
  }

  Future<void> _loadStudentDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      collegeName = prefs.getString('college_full_name') ?? widget.collegeName;
      college = prefs.getString('college_name') ?? widget.college;
      name = prefs.getString('name') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      number = prefs.getString('number') ?? 'N/A';
      department = prefs.getString('department') ?? 'N/A';
    });
  }

  // Prevent Back Navigation
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ACADIFY',
            style: TextStyles.acadifyTitle,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _logout(context);
              },
            ),
          ],
        ),
        body: SafeArea(
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
                      textAlign: TextAlign.center,
                      style: TextStyles.collegeName,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor:
                            const Color.fromARGB(255, 109, 255, 118),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.person,
                              size: 70, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, $name', style: TextStyles.headText),
                          Text('$department', style: TextStyles.defText),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      featureCard(Icons.person, "Profile"),
                      featureCard(Icons.assignment, "Assignments"),
                      featureCard(Icons.book, "Notes"),
                      featureCard(Icons.school, "Attendance"),
                      featureCard(Icons.calendar_today, "Academic Calenar"),
                      featureCard(Icons.access_time, "Timetable"),
                      featureCard(Icons.event_note, "Exam Schedule"),
                      featureCard(Icons.score, "Results"),
                      featureCard(Icons.groups, "Alumni Network"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Feature Card Widget
  Widget featureCard(IconData icon, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (title == "Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FacultyProfilePage(
                        collegeName: collegeName ?? '',
                        college: '',
                      )),
            );
          } else {
            print("$title clicked");
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Icon(icon, size: 30, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyles.defText,
            ),
          ],
        ),
      ),
    );
  }

  // Logout Function
  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/collegeSelection');
  }
}

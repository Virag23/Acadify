import 'package:acadify/screens/Admin_profile_page.dart';
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

class AdminHomePage extends StatefulWidget {
  final String collegeName;
  final String college;

  const AdminHomePage(
      {super.key, required this.collegeName, required this.college});

  @override
  _AdminHomePage createState() => _AdminHomePage();
}

class _AdminHomePage extends State<AdminHomePage> {
  String? collegeName;
  String? college; //
  String name = '',
      email = '',
      number = '',
      prn = '',
      department = '',
      year = '',
      semester = '',
      division = '',
      rollNo = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCollegeName();
    _loadAdminDetails();
  }

  Future<void> _loadCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collegeName = prefs.getString('college_name') ?? widget.collegeName;
      college = prefs.getString('college') ?? widget.college;
    });

    if (collegeName == null) {
      showSnackbar(context, "Error: College name not found!", Colors.red);
    }
  }

  Future<void> _loadAdminDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      collegeName = prefs.getString('college_full_name') ?? widget.collegeName;
      college = prefs.getString('college_name') ?? widget.college;
      name = prefs.getString('name') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      number = prefs.getString('number') ?? 'N/A';
      department = prefs.getString('department') ?? 'N/A';
      year = prefs.getString('year') ?? 'N/A';
      semester = prefs.getString('semester') ?? 'N/A';
      division = prefs.getString('division') ?? 'N/A';
    });
  }

  void showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> _onWillPop() async {
    return false; // Disable back button
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ACADIFY',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 35, color: Colors.blue),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $name',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
                      featureCard(Icons.schedule, "Timetable"),
                      featureCard(Icons.event, "Academic Calendar"),
                      featureCard(Icons.access_time, "Exam Schedule"),
                      featureCard(Icons.school, "Attendance"),
                      featureCard(Icons.update, "Manage Student"),
                      featureCard(Icons.description, "Previous Year Paper"),
                      featureCard(Icons.notifications, "Updates"),
                      featureCard(Icons.assignment_turned_in, "Semester End"),
                      featureCard(Icons.calendar_today, "Year End"),
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

  Widget featureCard(IconData icon, String title) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          if (title == "Profile") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminProfilePage(
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/collegeSelection');
  }
}

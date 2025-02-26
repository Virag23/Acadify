import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacultyHomePage extends StatefulWidget {
  final String collegeName;
  final String college;

  FacultyHomePage({required this.collegeName, required this.college});

  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  String? collegeName;
  String? college;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCollegeName();
  }

  Future<void> _loadCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collegeName = prefs.getString('college_name') ?? widget.collegeName;
      college = prefs.getString('college') ?? widget.college;
    });

    if (collegeName == null || college == null) {
      showSnackbar(context, "Error: College name not found!", Colors.red);
    }
  }

  void showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> _onWillPop() async {
    // Return false to stop going back, true to allow it
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
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Profile Icon
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 35, color: Colors.blue),
                      ),
                      SizedBox(width: 15), SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, {name ?? "Loading..."}!',
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
                      featureCard(Icons.assignment, "Assignments"),
                      featureCard(Icons.book, "E-Library"),
                      featureCard(Icons.school, "Attendance"),
                      featureCard(Icons.calendar_today, "Events"),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1), // Circular background
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
    await prefs.clear(); // Clear all stored data
    Navigator.pushReplacementNamed(context, '/collegeSelection');
  }
}

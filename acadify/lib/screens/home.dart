import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String collegeName;
  final String college;

  HomePage({required this.collegeName, required this.college});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<HomePage> {
  String? collegeName;
  String? college;

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
                      SizedBox(width: 15),
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
                      featureCard(Icons.person, "Profile"),
                      featureCard(Icons.assignment, "Assignments"),
                      featureCard(Icons.book, "E-Library"),
                      featureCard(Icons.school, "Attendance"),
                      featureCard(Icons.calendar_today, "Events"),
                      featureCard(Icons.access_time, "Timetable"),
                      featureCard(Icons.event_note, "Exam Schedule"),
                      featureCard(Icons.score, "Results"),
                      featureCard(Icons.people, "Faculty Connect"),
                      featureCard(Icons.groups, "Alumni Network"),
                      featureCard(Icons.notifications, "General Updates"),
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
          print('$title clicked');
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

  // Logout Function
  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/collegeSelection');
  }
}

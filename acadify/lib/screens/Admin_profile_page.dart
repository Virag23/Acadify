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

class AdminProfilePage extends StatefulWidget {
  final String collegeName;
  final String college;

  const AdminProfilePage(
      {super.key, required this.collegeName, required this.college});

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String? collegeName;
  String? college;
  String name = '',
      email = '',
      number = '',
      prn = '',
      department = '',
      year = '',
      semester = '',
      division = '';
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
      collegeName = prefs.getString('college_full_name') ?? widget.collegeName;
      college = prefs.getString('college_name') ?? widget.college;
    });
  }

  Future<void> _loadAdminDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      collegeName = prefs.getString('college_full_name') ?? widget.collegeName;
      college = prefs.getString('college_name') ?? widget.college;
      name = prefs.getString('name') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      number = prefs.getString('number') ?? 'N/A';
      prn = prefs.getString('prn') ?? 'N/A';
      department = prefs.getString('department') ?? 'N/A';
      year = prefs.getString('year') ?? 'N/A';
      semester = prefs.getString('semester') ?? 'N/A';
      division = prefs.getString('division') ?? 'N/A';
    });
  }

  Widget _buildProfileInfo(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ACADIFY',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Text('$name Profile',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 20),
              // Profile Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text(
                      name,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(email,
                        style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 0, 0, 0))),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildProfileInfo('Phone Number', number, Icons.phone),
                    _buildProfileInfo('Department', department, Icons.school),
                    _buildProfileInfo('Year', year, Icons.event),
                    _buildProfileInfo(
                        'Semester', semester, Icons.calendar_today),
                    _buildProfileInfo('Division', division, Icons.group),
                  ],
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

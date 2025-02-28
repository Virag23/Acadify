import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentTimetableScreen extends StatefulWidget {
  final String collegeName;
  final String college;

  StudentTimetableScreen({required this.collegeName, required this.college});

  @override
  _StudentTimetableScreenState createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  String? collegeName;
  String? college;
  List<dynamic> timetable = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollegeName();
    fetchTimetable();
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

  void showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> fetchTimetable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? college = prefs.getString('college_name');
    String? department = prefs.getString('department');
    String? year = prefs.getString('year');
    String? division = prefs.getString('division');

    if (college == null ||
        department == null ||
        year == null ||
        division == null) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse(
          "http://192.168.123.47:5000/api/get_timetable?college=$college&department=$department&year=$year&division=$division"),
    );

    if (response.statusCode == 200) {
      setState(() {
        timetable = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Center(
                  child: Text('Timetable',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : timetable.isEmpty
                      ? Center(child: Text("No Timetable Available"))
                      : ListView.builder(
                          itemCount: timetable.length,
                          itemBuilder: (context, index) {
                            final item = timetable[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(
                                    "${item['day']} - ${item['start_time']} to ${item['end_time']}"),
                                subtitle: Text(item['subject'] ?? "Break"),
                                onTap: item['subject'] != null
                                    ? () => showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(item['subject']),
                                            content: Text(
                                                "Faculty: ${item['faculty_name'] ?? 'Not Assigned'}"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("OK"),
                                              ),
                                            ],
                                          ),
                                        )
                                    : null,
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

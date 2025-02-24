import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/timetable_entry_widget.dart';

class AdminTimetableScreen extends StatefulWidget {
  final String collegeName;

  AdminTimetableScreen({required this.collegeName});

  @override
  _AdminTimetableScreenState createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
  String? collegeName;
  String selectedDepartment = "";
  String selectedYear = "";
  String selectedDivision = "";
  List<String> facultyList = [];
  bool isLoading = true; // Added loading state
  bool isSaturdayHoliday = false;

  Map<String, List<Map<String, dynamic>>> timetable = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": [],
  };

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    try {
      final adminData = await ApiService.getAdminDetails();

      if (adminData.isNotEmpty) {
        setState(() {
          collegeName = adminData['college_name'] ?? "Unknown College";
          selectedDepartment = adminData['department'] ?? "Unknown Department";
          selectedYear = adminData['year'] ?? "Unknown Year";
          selectedDivision = adminData['division'] ?? "Unknown Division";
        });

        await fetchFacultyList(); // Ensure faculty is fetched AFTER admin details
      } else {
        print("⚠️ Admin data is empty or null!");
      }
    } catch (e) {
      print("❌ Error fetching admin details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFacultyList() async {
    if (selectedDepartment.isNotEmpty) {
      try {
        final facultyData =
            await ApiService.getFacultyByDepartment(selectedDepartment);
        setState(() {
          facultyList = facultyData;
        });
      } catch (e) {
        print("❌ Error fetching faculty list: $e");
      }
    }
  }

  void addLecture(String day) {
    setState(() {
      timetable[day]!.add({
        "start_time": "",
        "end_time": "",
        "subject": "",
        "faculty": "",
        "isBreak": false,
      });
    });
  }

  void removeLecture(String day, int index) {
    setState(() {
      timetable[day]!.removeAt(index);
    });
  }

  void updateLecture(String day, int index, String key, dynamic value) {
    setState(() {
      timetable[day]![index][key] = value;
      if (key == "isBreak" && value == true) {
        timetable[day]![index]["subject"] = "";
        timetable[day]![index]["faculty"] = "";
      }
    });
  }

  void submitTimetable() async {
    if (collegeName == null || collegeName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("College Name is missing! Please log in again.")),
      );
      return;
    }

    for (String day in timetable.keys) {
      if (day == "Saturday" && isSaturdayHoliday) continue;
      for (var lecture in timetable[day]!) {
        await ApiService.addTimetableEntry(
          collegeName!,
          selectedDepartment,
          selectedYear,
          selectedDivision,
          day,
          lecture["start_time"]!,
          lecture["end_time"]!,
          lecture["subject"]!,
          lecture["faculty"]!,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Timetable Submitted Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ACADIFY',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      collegeName ?? 'Loading...',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Department: $selectedDepartment"),
                  Text("Year: $selectedYear"),
                  Text("Division: $selectedDivision"),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Admin Timetable Scheduler',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SwitchListTile(
                    title: Text("Saturday: Holiday"),
                    value: isSaturdayHoliday,
                    onChanged: (value) {
                      setState(() {
                        isSaturdayHoliday = value;
                      });
                    },
                  ),
                  Column(
                    children: timetable.keys.map((day) {
                      if (day == "Saturday" && isSaturdayHoliday)
                        return SizedBox();
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(day,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              trailing: IconButton(
                                icon: Icon(Icons.add, color: Colors.blue),
                                onPressed: () => addLecture(day),
                              ),
                            ),
                            ...List.generate(timetable[day]!.length, (index) {
                              return Column(
                                children: [
                                  TimetableEntryWidget(
                                    day: day,
                                    index: index,
                                    lecture: timetable[day]![index].map(
                                        (key, value) =>
                                            MapEntry(key, value.toString())),
                                    onUpdate: updateLecture,
                                    facultyList: facultyList,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => removeLecture(day, index),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: submitTimetable,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: Text("Submit Timetable"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

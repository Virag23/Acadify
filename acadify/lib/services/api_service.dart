import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.108.47:5000';

  // ✅ Fetch Admin Details
  static Future<Map<String, dynamic>> getAdminDetails() async {
    final response =
        await http.get(Uri.parse('$baseUrl/get_admin_details?admin_id=1'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch admin details');
    }
  }

  // ✅ Fetch Faculty List by Department
  static Future<List<String>> getFacultyByDepartment(String department) async {
    final response = await http.get(
        Uri.parse('$baseUrl/get_faculty_by_department?department=$department'));

    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch faculty list');
    }
  }

  // ✅ Add Timetable Entry
  static Future<void> addTimetableEntry(
      String collegeName,
      String department,
      String year,
      String division,
      String day,
      String startTime,
      String endTime,
      String subject,
      String faculty) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_timetable_entry'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "college_name": collegeName,
        "department": department,
        "year": year,
        "division": division,
        "day": day,
        "start_time": startTime,
        "end_time": endTime,
        "subject": subject,
        "faculty": faculty,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add timetable entry');
    }
  }
}

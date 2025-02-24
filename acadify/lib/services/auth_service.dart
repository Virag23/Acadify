import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> saveLoginData(String email, String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  static Future<Map<String, String?>> getLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? role = prefs.getString('role');
    return {"email": email, "role": role};
  }

  static Future<void> clearLoginData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('role');
  }

  static getAdminDetails() {}
}

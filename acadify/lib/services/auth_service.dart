import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Save Login Data with Role & Email
  static Future<void> saveLoginData(String email, String role) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('role', role);
    } catch (e) {
      throw Exception('❌ Error saving login data: $e');
    }
  }

  // ✅ Retrieve Login Data
  static Future<Map<String, String?>> getLoginData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? role = prefs.getString('role');
      return {"email": email ?? "", "role": role ?? ""};
    } catch (e) {
      throw Exception('❌ Error retrieving login data: $e');
    }
  }

  // ✅ Clear Login Data
  static Future<void> clearLoginData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('role');
    } catch (e) {
      throw Exception('❌ Error clearing login data: $e');
    }
  }
}

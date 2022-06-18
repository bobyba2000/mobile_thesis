import 'package:shared_preferences/shared_preferences.dart';

class UserPrefrence {
  static Future<String?> get id async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  static Future<bool?> get isServer async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isServer');
  }

  static Future<String?> get location async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('location');
  }

  static Future<void> setIsServer(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isServer', value);
  }

  static Future<void> setLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('location', location);
  }

  static Future<void> setUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('url', url);
  }

  static Future<void> setPhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('phoneNumber', phoneNumber);
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

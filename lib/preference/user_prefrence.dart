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
}

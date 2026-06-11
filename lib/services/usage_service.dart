import 'package:shared_preferences/shared_preferences.dart';

class UsageService {
  static const String _key = "guest_usage_count";
  static const int maxScans = 3;

  static Future<int> getUsage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<bool> canScan() async {
    final used = await getUsage();
    return used < maxScans;
  }

  static Future<int> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_key) ?? 0;

    current++;
    await prefs.setInt(_key, current);

    return current;
  }

  static Future<void> resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 0);
  }
}
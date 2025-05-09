import 'package:shared_preferences/shared_preferences.dart';

class UsageManager {
  static String _keyForTool(String toolId) => 'usage_count_$toolId';

  static Future<int> getUsageCount(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyForTool(toolId)) ?? 0;
  }

  static Future<void> incrementUsage(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyForTool(toolId)) ?? 0;
    await prefs.setInt(_keyForTool(toolId), current + 1);
  }

  static Future<void> resetUsage(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyForTool(toolId), 0);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCleaner {
  // مسح كل البيانات من SharedPreferences
  static Future<void> clearAllData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // مسح جميع البيانات من SharedPreferences
    await prefs.clear();

    // إظهار رسالة توضح أن البيانات تم مسحها
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been cleared!'))
    );
  }

  // مسح الـ "local_chats" و "chatId" فقط
  static Future<void> clearSpecificData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // مسح المحادثات المحلية فقط
    await prefs.remove('local_chats');

    // مسح الـ chatId
    await prefs.remove('chatId');

    // إظهار رسالة توضح أن البيانات تم مسحها
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local chats and chatId cleared!'))
    );
  }
}

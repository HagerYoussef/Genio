import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/user_signup_model.dart';

class AuthRepository {
  Future<Map<String, dynamic>> registerUser(UserSignupModel user) async {
    const String url = "https://genio-rust.vercel.app/api/signup";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "message": "Account created successfully!"};
      } else {
        return {"success": false, "message": responseData["message"] ?? "Something went wrong!"};
      }
    } catch (error) {
      return {"success": false, "message": "Failed to connect to the server!"};
    }
  }
}

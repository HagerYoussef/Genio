import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_signup_model.dart';

class AuthRepository {
  Future<Map<String, dynamic>> registerUser(UserSignupModel user) async {
    const String url = "https://back-end-api.genio.ae/api/signup";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "message": "Account created successfully!"};
      } else if (response.statusCode == 400 && responseData['message'] != null) {
        return {"success": false, "message": 'Email is already exists!'};
      } else {
        return {"success": false, "message": "Unexpected error occurred!"};
      }
    } catch (error) {
      return {"success": false, "message": "Something went wrong!"};
    }
  }
}

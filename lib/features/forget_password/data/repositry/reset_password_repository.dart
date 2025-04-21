import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordRepository {
  Future<String> sendResetRequest(String email) async {
    final url = Uri.parse("https://genio-rust.vercel.app/api/resetRequest");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return "Password reset email sent successfully";
      } else if (response.statusCode == 404) {
        return "No user found with this email";
      } else {
        return "Something went wrong. Please try again.";
      }
    } catch (e) {
      return "Network error. Please check your internet connection.";
    }
  }
}

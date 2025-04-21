import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetCodeRepository {
  final String baseUrl = "https://genio-rust.vercel.app/api/resetCode";

  Future<String> verifyResetCode(String userId, String resetCode) async {
    final url = Uri.parse("$baseUrl/$userId");

    print("🔹 Sending API request...");
    print("🔹 URL: $url");
    print("🔹 Reset Code: $resetCode");


    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ResetCode": resetCode}),
    );

    print("🔹 Response Code: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");


    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return "success"; // Reset code is valid
    } else {
      return responseBody["message"] ?? "Invalid or expired reset code";
    }
  }
}

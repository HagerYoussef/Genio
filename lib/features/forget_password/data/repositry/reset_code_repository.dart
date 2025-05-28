import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetCodeRepository {
  final String baseUrl = "https://back-end-api.genio.ae/api/resetCode";

  Future<String> verifyResetCode(String userId, String resetCode) async {
    final url = Uri.parse("$baseUrl/$userId");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ResetCode": resetCode}),
    );

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return "success";
    } else {
      return responseBody["message"] ?? "Invalid or expired reset code";
    }
  }
}

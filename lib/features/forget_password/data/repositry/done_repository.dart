import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/done_model.dart';

class DoneRepository {
  Future<ResetPasswordResponse> resetPassword({
    required String userId,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse("https://genio-rust.vercel.app/api/reset/$userId");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "password": password,
        "confirmpassword": confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return ResetPasswordResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'https://back-end-api.genio.ae/api/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data.containsKey("token")) {
          final token = data["token"];
          print(" Received Token: $token");

          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          print(" Decoded Token: $decodedToken");

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', token);
          print("Token saved in SharedPreferences");

          if (decodedToken.containsKey("userId")) {
            final userId = decodedToken["userId"];
            await prefs.setString('userId', userId);
            print(" userId saved: $userId");
            return {'success': true, 'userId': userId};
          }
        }
      }
      return {'success': false, 'message': 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Login Failed'};
    }
  }
}

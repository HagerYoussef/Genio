import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepository {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'https://genio-rust.vercel.app/api/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data.containsKey("token")) {
          final token = data["token"];
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          if (decodedToken.containsKey("userId")) {
            final userId = decodedToken["userId"];
            return {'success': true, 'userId': userId}; // ✅ Return userId
          }
        }
      }
      return {'success': false, 'message': 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

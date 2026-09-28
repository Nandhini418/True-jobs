import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class OtpApi {
  /// Verify OTP with the backend server
  static Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
    required String token,
  }) async {
    final String url = ApiConfig.baseUrl;

    // Body params loaded from SharedPreferences cache
    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1101';
    body['mobile'] = mobile;
    body['otp'] = otp;
    body['token'] = token;

    debugPrint('--> POST $url (verify OTP)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'error': true,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('OtpApi Error: $e');
      return {'error': true, 'message': 'Network error: $e'};
    }
  }
}

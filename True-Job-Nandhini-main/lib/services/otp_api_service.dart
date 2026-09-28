import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpApiService {
  static Future<Map<String, dynamic>?> verifyOtp({
    required String mobile,
    required String otp,
    required String token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final body = {
        'type': '1131',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'mobile': mobile,
        'otp': otp,
        'token': token,
      };

      debugPrint('--- OTP API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- OTP API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('OTP API Error: $e');
    }
    return null;
  }
}

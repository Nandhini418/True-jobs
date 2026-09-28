import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LoginApi {
  /// Send login request to retrieve OTP
  static Future<Map<String, dynamic>> loginWithPhone({
    required String mobile,
    required String appSignature,
    required double latitude,
    required double longitude,
    required String deviceId,
    String? referrerCode,
  }) async {
    final String url = ApiConfig.baseUrl;

    // Body params as key-value pairs (x-www-form-urlencoded)
    final Map<String, String> body = {
      'cid': '21472147',
      'ln': longitude.toString(),
      'lt': latitude.toString(),
      'device_id': deviceId,
      'type': '1100',
      'mobile': mobile,
      'app_signature': appSignature,
    };

    if (referrerCode != null && referrerCode.isNotEmpty) {
      body['referrer_code'] = referrerCode;
    }

    debugPrint('--> POST $url');
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
          'error_msg': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('LoginApi Error: $e');
      return {'error': true, 'error_msg': 'Network error: $e'};
    }
  }

  /// Check if the mobile number is already registered
  static Future<Map<String, dynamic>> checkRegistration({
    required String mobile,
    required double latitude,
    required double longitude,
    required String deviceId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = {
      'cid': '21472147',
      'ln': longitude.toString(),
      'lt': latitude.toString(),
      'device_id': deviceId,
      'type': '1168',
      'mobile_no': mobile,
    };

    debugPrint('--> POST $url (Check Registration)');
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
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Check Registration Error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
}

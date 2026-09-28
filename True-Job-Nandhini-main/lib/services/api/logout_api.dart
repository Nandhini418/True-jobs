import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LogoutApi {
  /// Send logout request to backend
  static Future<Map<String, dynamic>> logout({
    required String token,
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
      'type': '1104',
      'token': token,
    };

    debugPrint('--> POST $url (logout)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': 'error',
          'error': true,
          'message': 'Server returned status code: ${response.statusCode}',
          'error_msg': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('LogoutApi Error: $e');
      return {
        'status': 'error',
        'error': true,
        'message': 'Network error: $e',
        'error_msg': 'Network error: $e',
      };
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class VersionApi {
  /// Check app version status (type 1126)
  static Future<Map<String, dynamic>> checkVersion({
    required String version,
  }) async {
    final String url = ApiConfig.baseUrl;

    final String deviceId = await ApiConfig.getDeviceId();
    final Map<String, double> coords = await ApiConfig.getCoordinates();

    final Map<String, String> body = {
      'type': '1126',
      'ln': coords['longitude']?.toString() ?? '11.0',
      'lt': coords['latitude']?.toString() ?? '11.0',
      'device_id': deviceId.isNotEmpty ? deviceId : 'unknown',
      'version': version,
    };

    debugPrint('--> POST $url (checkVersion)');
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
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('VersionApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

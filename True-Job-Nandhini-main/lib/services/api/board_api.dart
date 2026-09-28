import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BoardApi {
  static Map<String, dynamic>? _cachedData;

  /// Fetch dynamic list of boards
  static Future<Map<String, dynamic>> fetchBoards() async {
    if (_cachedData != null) {
      return _cachedData!;
    }
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1110';

    debugPrint('--> POST $url (fetchBoards)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success' || data['error'] == false) {
          _cachedData = data;
        }
        return data;
      } else {
        return {
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('BoardApi Error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
}

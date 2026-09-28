import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class JobSearchApi {
  /// Search jobs/skills/companies (type 1148)
  static Future<Map<String, dynamic>> searchJobs({
    required String query,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1148';
    body['search'] = query;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';
      if (token.isNotEmpty) {
        body['token'] = token;
      }
    } catch (_) {}

    debugPrint('--> POST $url (searchJobs)');
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
      debugPrint('JobSearchApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

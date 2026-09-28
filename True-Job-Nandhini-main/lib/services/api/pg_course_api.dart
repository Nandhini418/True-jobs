import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PgCourseApi {
  /// Fetch dynamic list of PG courses
  static Future<Map<String, dynamic>> fetchCourses() async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1113';

    debugPrint('--> POST $url (fetchPgCourses)');
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
      debugPrint('PgCourseApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

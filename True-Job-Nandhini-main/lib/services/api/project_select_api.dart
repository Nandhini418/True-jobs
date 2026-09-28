import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ProjectSelectApi {
  /// Fetch user projects (type 1133)
  static Future<Map<String, dynamic>> fetchProjects({
    required String name,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1133';
    body['name'] = name;

    debugPrint('--> POST $url (fetchProjects)');
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
      debugPrint('ProjectSelectApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ProjectDeleteApi {
  /// Delete user project (type 1136)
  static Future<Map<String, dynamic>> deleteProject({
    required String name,
    required String id,
    String? token,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1136';
    body['name'] = name;
    body['uid'] = name;
    body['id'] = id;

    if (token != null && token.isNotEmpty) {
      body['token'] = token;
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String savedToken = prefs.getString('token') ?? '';
        if (savedToken.isNotEmpty) {
          body['token'] = savedToken;
        }
      } catch (_) {}
    }

    debugPrint('--> POST $url (deleteProject)');
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
      debugPrint('ProjectDeleteApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

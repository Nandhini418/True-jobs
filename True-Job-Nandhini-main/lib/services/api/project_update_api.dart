import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ProjectUpdateApi {
  /// Save/update user project (type 1132)
  static Future<Map<String, dynamic>> updateProject({
    required String name,
    String? id,
    required String projectName,
    required String startDate,
    required String endDate,
    required String projectDetails,
    required String keySkills,
    required String projectUrl,
    String? token,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = (id != null && id.isNotEmpty) ? '1145' : '1132';
    body['name'] = name;
    body['uid'] = name;
    if (id != null && id.isNotEmpty) {
      body['id'] = id;
      body['project_id'] = id;
      body['Project_id'] = id;
      body['projectId'] = id;
      body['ProjectId'] = id;
    }
    body['project_name'] = projectName;
    body['start_date'] = startDate;
    body['end_date'] = endDate;
    body['project_details'] = projectDetails;
    body['key_skills'] = keySkills;
    body['Project_url'] = projectUrl;

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

    debugPrint('--> POST $url (updateProject)');
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
      debugPrint('ProjectUpdateApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

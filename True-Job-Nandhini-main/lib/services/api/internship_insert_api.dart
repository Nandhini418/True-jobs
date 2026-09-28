import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class InternshipInsertApi {
  /// Insert or update internship details (type 1140)
  static Future<Map<String, dynamic>> insertInternship({
    required String name, // user_id
    String? id, // ID of record to update (optional)
    required String companyName,
    required String projectName,
    required String startDate,
    required String endDate,
    required String projectDetails,
    required String keySkills,
    required String projectUrl,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = (id != null && id.isNotEmpty) ? '1146' : '1140';
    body['name'] = name;
    body['uid'] = name;
    if (id != null && id.isNotEmpty) {
      body['id'] = id;
      body['project_id'] = id;
      body['Project_id'] = id;
      body['projectId'] = id;
      body['ProjectId'] = id;
      body['internship_id'] = id;
      body['Internship_id'] = id;
      body['internshipId'] = id;
      body['InternshipId'] = id;
      body['iid'] = id;
      body['int_id'] = id;
    }
    body['company_name'] = companyName;
    body['project_name'] = projectName;
    body['start_date'] = startDate;
    body['end_date'] = endDate;
    body['project_details'] = projectDetails;
    body['key_skills'] = keySkills;
    body['Project_url'] = projectUrl;

    // Retrieve token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      body['token'] = token;
    }

    debugPrint('--> POST $url (insertInternship)');
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
      debugPrint('InternshipInsertApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

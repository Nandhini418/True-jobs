import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class JobPreferenceApi {
  /// Insert/Update user job preferences (type 1138)
  static Future<Map<String, dynamic>> updateJobPreferences({
    required String name, // user_id
    required List<int> jobRoleIds,
    required List<int> shiftIds,
    required List<int> workModeIds,
    required List<int> jobTypeIds,
    required String expectSalary,
    required List<int> locationIds,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1138';
    body['name'] = name;
    body['job_role'] = jsonEncode(jobRoleIds);
    body['shift'] = jsonEncode(shiftIds);
    body['work_mode'] = jsonEncode(workModeIds);
    body['job_type'] = jsonEncode(jobTypeIds);
    body['expect_salary'] = expectSalary;
    body['location'] = jsonEncode(locationIds);

    // Retrieve token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      body['token'] = token;
    }

    debugPrint('--> POST $url (updateJobPreferences)');
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
      debugPrint('JobPreferenceApi updateError: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Fetch user job preferences (type 1139)
  static Future<Map<String, dynamic>> selectJobPreferences({
    required String name, // user_id
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1139';
    body['name'] = name;

    // Retrieve token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    if (token.isNotEmpty) {
      body['token'] = token;
    }

    debugPrint('--> POST $url (selectJobPreferences)');
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
      debugPrint('JobPreferenceApi selectError: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

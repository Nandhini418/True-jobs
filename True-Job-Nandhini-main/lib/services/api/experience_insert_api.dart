import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ExperienceInsertApi {
  /// Insert or update experience details (type 1119)
  static Future<Map<String, dynamic>> insertExperienceDetails({
    required String name,
    required String age,
    required String youHaveExperience,
    required String totYearXperience,
    required String jobTitle,
    required String companyName,
    required String currentWork,
    String? currentSalary,
    String? id,
    String? mid,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = (id != null && id.isNotEmpty) ? '1147' : '1119';
    body['name'] = name;
    body['uid'] = name;
    body['age'] = age;
    body['you_have_experience'] = youHaveExperience;
    body['tot_year_xperience'] = totYearXperience;
    body['job_title'] = jobTitle;
    body['company_name'] = companyName;
    body['current_work'] = currentWork;
    if (currentSalary != null) {
      body['current_salary'] = currentSalary;
    }
    if (mid != null) {
      body['mid'] = mid;
      body['member_id'] = mid;
    }
    if (id != null) {
      body['id'] = id;
      body['experience_id'] = id;
      body['Experience_id'] = id;
      body['exp_id'] = id;
      body['eid'] = id;
      body['you_have_experience_id'] = id;
      body['experienceId'] = id;
      body['ExperienceId'] = id;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';
      if (token.isNotEmpty) {
        body['token'] = token;
      }
    } catch (_) {}

    debugPrint('--> POST $url (insertExperienceDetails)');
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
      debugPrint('ExperienceInsertApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

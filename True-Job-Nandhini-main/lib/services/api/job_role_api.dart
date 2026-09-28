import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class JobRoleApi {
  /// Fetch dynamic list of job roles (type 1121, form sm_main_form_3175)
  static Future<Map<String, dynamic>> fetchJobRoles({String? userId}) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1121';
    body['form'] = 'sm_main_form_3175';

    String? currentUserId = userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final int? idInt = prefs.getInt('user_id');
      if (idInt != null) {
        currentUserId = idInt.toString();
      } else {
        currentUserId = prefs.getString('user_id');
      }
    }

    if (currentUserId != null && currentUserId.isNotEmpty) {
      body['user_id'] = currentUserId;
    }

    debugPrint('--> POST $url (fetchJobRoles)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body preview: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'error': true,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('JobRoleApi Error: $e');
      return {
        'error': true,
        'message': 'Network error: $e',
      };
    }
  }
}

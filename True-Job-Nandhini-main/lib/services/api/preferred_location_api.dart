import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class PreferredLocationApi {
  /// Fetch dynamic list of preferred locations (type 1123, form sm_main_form_11, list_id 118)
  static Future<Map<String, dynamic>> fetchPreferredLocations({String? userId}) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1123';
    body['form'] = 'sm_main_form_11';
    body['list_id'] = '118';

    // Ensure user_id is set in body if available
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

    debugPrint('--> POST $url (fetchPreferredLocations)');
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
          'error': true,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('PreferredLocationApi Error: $e');
      return {
        'error': true,
        'message': 'Network error: $e',
      };
    }
  }
}

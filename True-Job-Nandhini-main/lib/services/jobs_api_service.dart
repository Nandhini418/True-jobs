import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobsApiService {
  static Future<List<dynamic>?> fetchJobs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1121',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'form': 'sm_main_form_3135',
        'where': 'recuriter_name=$userId',
      };

      debugPrint('--- Fetch Jobs API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Fetch Jobs API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['error'] == false && decoded['data'] is List) {
          return decoded['data'];
        } else {
          // If the API returns error: true (e.g., 'No data found'), return empty list
          // so it doesn't trigger the local storage fallback.
          return [];
        }
      }
    } catch (e) {
      debugPrint('Jobs API Error: $e');
    }
    return null;
  }
}

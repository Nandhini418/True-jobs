import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverallCandidatesApiService {
  static Future<List<dynamic>?> fetchAllCandidates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1160',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '43',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '2',
        'recuriter_name': prefs.getInt('user_id')?.toString() ?? '',
      };

      debugPrint('--- Fetch All Candidates API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Fetch All Candidates API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] is List) {
          return decoded['data'];
        } else {
          return []; // Return empty list if error or no data found
        }
      }
    } catch (e) {
      debugPrint('Fetch All Candidates API Error: $e');
    }
    return null;
  }
}

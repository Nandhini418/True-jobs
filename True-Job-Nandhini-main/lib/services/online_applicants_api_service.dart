import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnlineApplicantsApiService {
  static Future<List<dynamic>?> fetchApplicants(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1159',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'job_id': jobId,
        'token': 'asdf', // as per user instruction
      };

      debugPrint('--- Fetch Online Applicants API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Fetch Online Applicants API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] is List) {
          return decoded['data'];
        }
      }
    } catch (e) {
      debugPrint('Online Applicants API Error: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> fetchWalkinApplicants(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1161',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'job_id': jobId,
        'token': 'asdf',
      };

      debugPrint('--- Fetch Walkin Applicants API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Fetch Walkin Applicants API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] is List) {
          return decoded['data'];
        }
      }
    } catch (e) {
      debugPrint('Walkin Applicants API Error: $e');
    }
    return null;
  }
}

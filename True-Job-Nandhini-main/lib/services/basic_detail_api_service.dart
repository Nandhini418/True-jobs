import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicDetailApiService {
  static Future<Map<String, dynamic>?> fetchBasicDetails({
    required String userId,
    required String token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1107',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'user_id': userId,
        'token': token,
      };

      debugPrint('--- Fetch Basic Details API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Fetch Basic Details API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['status'] == 'success') {
          final data = decoded['data'];
          if (data != null) {
            final String companyName = data['company_name'] ?? data['company'] ?? '';
            final String contactPerson = data['contact_person'] ?? data['name'] ?? '';
            if (companyName.isNotEmpty) {
              await prefs.setString('company_name', companyName);
            }
            if (contactPerson.isNotEmpty) {
              await prefs.setString('contact_person', contactPerson);
            }
          }
        }
        return decoded;
      }
    } catch (e) {
      debugPrint('Fetch Basic Details API Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateBasicDetails({
    required String userId,
    required String contactPerson,
    required String contactPersonEmail,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1105',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'user_id': userId,
        'contact_person': contactPerson,
        'contact_person_email': contactPersonEmail,
      };

      debugPrint('--- Update Basic Details API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Update Basic Details API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Update Basic Details API Error: $e');
    }
    return null;
  }
}

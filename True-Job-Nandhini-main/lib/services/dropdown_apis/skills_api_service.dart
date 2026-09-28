import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkillsApiService {
  static Future<List<dynamic>> fetchSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1121',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '234',
        'ln': prefs.getString('ln') ?? '445',
        'lt': prefs.getString('lt') ?? '345',
        'form': 'sm_main_form_3150',
      };

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('Skills API Response: ${response.body}');
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['data'] != null) {
          return decoded['data'] as List<dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Skills API Error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> insertSkill(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1122',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '234',
        'ln': prefs.getString('ln') ?? '445',
        'lt': prefs.getString('lt') ?? '345',
        'form': 'sm_main_form_3150',
        'name': name,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('Insert Skill API Response: ${response.body}');
        final decoded = jsonDecode(response.body);
        return decoded;
      }
    } catch (e) {
      debugPrint('Insert Skill API Error: $e');
    }
    return null;
  }
}

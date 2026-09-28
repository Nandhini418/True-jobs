import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmploymentTypeApiService {
  static Future<List<dynamic>> fetchEmploymentTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1123',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '234',
        'ln': prefs.getString('ln') ?? '445',
        'lt': prefs.getString('lt') ?? '345',
        'form': 'sm_main_form_11',
        'list_id': '117',
      };

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('Employment Type API Response: ${response.body}');
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['dropdown'] != null) {
          return decoded['dropdown'] as List<dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Employment Type API Error: $e');
    }
    return [];
  }
}

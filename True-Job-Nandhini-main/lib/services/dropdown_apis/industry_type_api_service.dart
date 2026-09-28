import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndustryTypeApiService {
  static Future<List<dynamic>> fetchIndustryTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1121',
        'cid': '21472147',
        'device_id': prefs.getString('device_id') ?? '234',
        'ln': prefs.getString('ln') ?? '445',
        'lt': prefs.getString('lt') ?? '345',
        'form': 'sm_main_form_3140',
      };

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('Industry Type API Response: ${response.body}');
        final decoded = jsonDecode(response.body);
        if (decoded != null) {
          if (decoded['dropdown'] != null) {
            return decoded['dropdown'] as List<dynamic>;
          } else if (decoded['data'] != null) {
            return decoded['data'] as List<dynamic>;
          }
        }
      }
    } catch (e) {
      debugPrint('Industry Type API Error: $e');
    }
    return [];
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentApiService {
  static Future<List<dynamic>> fetchDepartments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1121',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '234',
        'ln': prefs.getString('ln') ?? '445',
        'lt': prefs.getString('lt') ?? '345',
        'form': 'sm_main_form_3215',
      };

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('Department API Response: ${response.body}');
        final decoded = jsonDecode(response.body);
        if (decoded != null) {
          if (decoded['data'] != null) {
            final List<dynamic> data = decoded['data'];
            return data.map((e) => {
              'value': e['id']?.toString() ?? e['value']?.toString() ?? '',
              'label': e['name']?.toString() ?? e['label']?.toString() ?? '',
            }).toList();
          } else if (decoded['dropdown'] != null) {
            return decoded['dropdown'] as List<dynamic>;
          }
        }
      }
    } catch (e) {
      debugPrint('Department API Error: $e');
    }
    return [];
  }
}

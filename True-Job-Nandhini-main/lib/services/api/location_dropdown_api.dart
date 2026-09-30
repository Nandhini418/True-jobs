import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LocationDropdownApi {
  /// Fetch location dropdown list (type 1123)
  static Future<Map<String, dynamic>> fetchLocations() async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1123';
    body['form'] = 'sm_main_form_11';
    body['list_id'] = '118';

    debugPrint('--> POST $url (fetchLocations)');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('LocationDropdownApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

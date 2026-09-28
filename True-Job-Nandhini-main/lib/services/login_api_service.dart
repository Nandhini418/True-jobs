import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApiService {
  static Future<Map<String, dynamic>?> login({
    required String mobile,
    String? referrerCode,
    String? appSignature,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1129',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'mobile': mobile,
        'app_signature': appSignature ?? 'itufuifyfufu',
      };

      if (referrerCode != null && referrerCode.isNotEmpty) {
        body['referrer_code'] = referrerCode;
      }

      debugPrint('--- Login API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Login API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Login API Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final body = {
        'type': '1104',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'token': prefs.getString('token') ?? '',
      };

      debugPrint('--- Logout API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Logout API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Clear session data locally
        await prefs.remove('user_id');
        await prefs.remove('token');
        await prefs.remove('mobile');
        
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Logout API Error: $e');
    }
    return null;
  }
}

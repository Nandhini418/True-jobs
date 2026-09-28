import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class WalletApi {
  /// Fetch user wallet details by user ID
  static Future<Map<String, dynamic>> fetchWallet({
    required int userId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1121';
    body['form'] = 'sm_main_form_3200';
    body['user_id'] = userId.toString();

    debugPrint('--> POST $url (fetchWallet)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {
          'error': true,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('WalletApi Error: $e');
      return {
        'error': true,
        'message': 'Network error: $e',
      };
    }
  }
}

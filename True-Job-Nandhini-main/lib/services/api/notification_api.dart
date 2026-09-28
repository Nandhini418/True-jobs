import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class NotificationApi {
  /// Send FCM token update request to the backend
  static Future<Map<String, dynamic>> updateFcmToken({
    required String fcmToken,
    required int userId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1128';
    body['user_id'] = userId.toString();
    body['fcm_token'] = fcmToken;

    debugPrint('--> POST $url (updateFcmToken)');
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
          'status': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('NotificationApi Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }
}

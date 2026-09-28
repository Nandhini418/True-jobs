import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/services/api/api_config.dart';

class JobApi {
  static Future<Map<String, dynamic>> toggleSaveJob({
    required String jobId,
    required String userId,
    required String token,
    required double lat,
    required double lng,
    required String deviceId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = {
      'cid': '21472147',
      'type': '1167',
      'job_id': jobId,
      'user_id': userId,
      'token': token,
      'ln': lng.toString(),
      'lt': lat.toString(),
      'device_id': deviceId,
    };

    debugPrint('--> POST $url (Save Job)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      debugPrint('<-- ${response.statusCode} $url (Save Job)');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      return {'error': true, 'message': 'Server Error: ${response.statusCode}'};
    } catch (e) {
      debugPrint('Save Job API Error: $e');
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchSavedJobs({
    required int userId,
    required String token,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1169';
    body['user_id'] = userId.toString();
    body['token'] = token;

    debugPrint('--> POST $url (Fetch Saved Jobs)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      debugPrint('<-- ${response.statusCode} $url (Fetch Saved Jobs)');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      return {'error': true, 'message': 'Server Error: ${response.statusCode}'};
    } catch (e) {
      debugPrint('Fetch Saved Jobs API Error: $e');
      return {'error': true, 'message': 'Network error: $e'};
    }
  }
}

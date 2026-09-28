import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Handles recruiter-view tracking via API type=1153.
///
/// API response formats (both use status: true):
///   Not yet viewed : {"status": true, "message": "View unlocked",    "data": {"recruiter_email": null,  "recruiter_mobile": null}}
///   Already viewed : {"status": true, "message": "Already unlocked", "data": {"recruiter_email": "...", "recruiter_mobile": "..."}}
class RecruiterViewApi {
  // ── In-memory session cache ────────────────────────────────────────────────
  // Persists for the lifetime of the current app session.
  // Avoids redundant API calls when the user navigates away and returns.
  static final Set<String> _sessionUnlocked = {};

  static String _key(String jobId, String userId) => '${userId}_$jobId';

  /// True if this user+job was confirmed "Already unlocked" in the current session.
  static bool isUnlockedInSession(String jobId, String userId) =>
      _sessionUnlocked.contains(_key(jobId, userId));

  static void _addToSession(String jobId, String userId) =>
      _sessionUnlocked.add(_key(jobId, userId));

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Check whether the current user has already unlocked recruiter details for
  /// this job by calling type=1153.
  ///
  /// Returns the JSON data if message == "Already unlocked"
  /// Returns null if not yet unlocked.
  static Future<Map<String, dynamic>?> checkRecruiterUnlockStatus({
    required String jobId,
    required String userId,
  }) async {
    if (jobId.isEmpty || userId.isEmpty) return null;

    final String url = ApiConfig.baseUrl;
    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type']    = '1153';
    body['job_id']  = jobId;
    body['user_id'] = userId;

    debugPrint('--> POST $url (checkRecruiterUnlockStatus)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      debugPrint('<-- ${response.statusCode} checkRecruiterUnlockStatus');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String message =
            (data['message'] ?? '').toString().toLowerCase().trim();

        debugPrint('checkRecruiterUnlockStatus → message="$message"');

        // "Already unlocked" → user has previously clicked "Show details"
        if (message == 'already unlocked' || message.contains('already')) {
          _addToSession(jobId, userId);
          return data;
        }

        return null;
      }
    } catch (e) {
      debugPrint('RecruiterViewApi.checkRecruiterUnlockStatus Error: $e');
    }
    return null;
  }

  /// Record that the user has explicitly chosen to view recruiter details.
  /// Calls type=1153 for server-side tracking and caches the result in-session.
  static Future<Map<String, dynamic>> markRecruiterViewed({
    required String jobId,
    required String userId,
  }) async {
    final String url = ApiConfig.baseUrl;
    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type']    = '1153';
    body['job_id']  = jobId;
    body['user_id'] = userId;

    debugPrint('--> POST $url (markRecruiterViewed)');
    debugPrint('Body: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      debugPrint('<-- ${response.statusCode} $url');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final bool isSuccess = data['status'] == true ||
            data['status']?.toString().toLowerCase() == 'true';
        if (isSuccess) {
          _addToSession(jobId, userId);
        }
        return data;
      } else {
        return {
          'status': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('RecruiterViewApi.markRecruiterViewed Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }
}

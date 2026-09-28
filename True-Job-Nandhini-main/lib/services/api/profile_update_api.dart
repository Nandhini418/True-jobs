import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ProfileUpdateApi {
  /// Submit profile updates to the backend
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String mobile,
    required String email,
    required String dob,
    required String gender,
    required String physicalChallenge,
    required String condType,
    required String affectArea,
    String? resume,
    String? linkedin,
    String? portfolio,
    File? profileImage,
    String? profileImageName,
    File? resumeFile,
  }) async {
    final String url = ApiConfig.baseUrl;
    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1105';
    body['user_id'] = userId.toString();
    body['name'] = name;
    body['mobile'] = mobile;
    body['email'] = email;
    body['dob'] = dob;
    body['gender'] = _normalizeGender(gender);
    body['physical_challenge'] = _normalizePhysicalChallenge(physicalChallenge);
    body['cond_type'] = condType;
    body['affect_area'] = affectArea;
    if (resume != null && resumeFile == null) body['resume'] = resume;
    if (linkedin != null) body['linkedin'] = linkedin;
    if (portfolio != null) body['portfolio'] = portfolio;
    if (profileImage == null && profileImageName != null) {
      body['profile_image'] = profileImageName;
      body['photo'] = profileImageName;
    }

    if ((profileImage != null && await profileImage.exists()) ||
        (resumeFile != null && await resumeFile.exists())) {
      // Manual WebKit Multipart Request to bypass WAF 406
      try {
        final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
        final Uri uri = Uri.parse(url);
        final List<int> bodyBytes = [];

        // Add fields
        body.forEach((key, val) {
          bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
          bodyBytes.addAll(utf8.encode('Content-Disposition: form-data; name="$key"\r\n\r\n'));
          bodyBytes.addAll(utf8.encode('$val\r\n'));
        });

        // Add profile image
        if (profileImage != null && await profileImage.exists()) {
          final String filename = profileImage.path.split('/').last;
          final String contentType = _getMimeType(filename);
          bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
          bodyBytes.addAll(utf8.encode('Content-Disposition: form-data; name="profile_image"; filename="$filename"\r\n'));
          bodyBytes.addAll(utf8.encode('Content-Type: $contentType\r\n\r\n'));
          bodyBytes.addAll(await profileImage.readAsBytes());
          bodyBytes.addAll(utf8.encode('\r\n'));
        }

        // Add resume file
        if (resumeFile != null) {
          debugPrint('CHECKING RESUME FILE: ${resumeFile.path}');
          if (await resumeFile.exists()) {
            final int size = await resumeFile.length();
            debugPrint('RESUME FILE EXISTS! Size: $size bytes');
            final String filename = resumeFile.path.split('/').last;
            final String contentType = _getMimeType(filename);
            bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
            bodyBytes.addAll(utf8.encode('Content-Disposition: form-data; name="resume_file"; filename="$filename"\r\n'));
            bodyBytes.addAll(utf8.encode('Content-Type: $contentType\r\n\r\n'));
            bodyBytes.addAll(await resumeFile.readAsBytes());
            bodyBytes.addAll(utf8.encode('\r\n'));
            debugPrint('ADDED RESUME FILE TO MULTIPART: $filename');
          } else {
            debugPrint('RESUME FILE DOES NOT EXIST AT PATH: ${resumeFile.path}');
          }
        }

        bodyBytes.addAll(utf8.encode('--$boundary--\r\n'));

        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'multipart/form-data; boundary=$boundary',
            'Accept': 'application/json, text/plain, */*',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
          body: bodyBytes,
        ).timeout(const Duration(seconds: 15));

        debugPrint('<-- MANUAL MULTIPART RESPONSE FROM $url');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (profileImageName != null && data['data'] != null && data['data'] is Map) {
            final Map dataMap = data['data'];
            if (dataMap['profile_image'] == null || dataMap['profile_image'].toString().isEmpty) {
              dataMap['profile_image'] = profileImageName;
            }
          }
          return data;
        } else {
          return {
            'status': 'error',
            'message': 'Server returned status code: ${response.statusCode}',
          };
        }
      } catch (e) {
        debugPrint('Manual Multipart error: $e');
        return {
          'status': 'error',
          'message': 'Multipart upload error: $e',
        };
      }
    } else {
      // Fallback to standard application/x-www-form-urlencoded POST
      debugPrint('--> POST REQUEST TO $url');
      debugPrint('Body: $body');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json, text/plain, */*',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
          body: body,
        ).timeout(const Duration(seconds: 15));

        debugPrint('<-- POST RESPONSE FROM $url');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (profileImageName != null && data['data'] != null && data['data'] is Map) {
            final Map dataMap = data['data'];
            if (dataMap['profile_image'] == null || dataMap['profile_image'].toString().isEmpty) {
              dataMap['profile_image'] = profileImageName;
            }
          }
          return data;
        } else {
          return {
            'status': 'error',
            'message': 'Server returned status code: ${response.statusCode}',
          };
        }
      } catch (e) {
        debugPrint('ProfileUpdateApi Error: $e');
        return {
          'status': 'error',
          'message': 'Network error: $e',
        };
      }
    }
  }

  static String _normalizeGender(String value) {
    final clean = value.trim().toLowerCase();
    if (clean == 'male' || clean == '1') return '1';
    if (clean == 'female' || clean == '2') return '2';
    if (clean == 'others' || clean == 'other' || clean == '3') return '3';
    return '1';
  }

  static String _normalizePhysicalChallenge(String value) {
    final clean = value.trim().toLowerCase();
    if (clean == 'yes' || clean == '1') return '1';
    if (clean == 'no' || clean == '2') return '2';
    return '2';
  }

  static String _getMimeType(String filename) {
    final String ext = filename.split('.').last.toLowerCase();
    if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
    if (ext == 'png') return 'image/png';
    if (ext == 'gif') return 'image/gif';
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'doc') return 'application/msword';
    if (ext == 'docx') return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    return 'application/octet-stream';
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApplyJobApi {
  static final Set<String> appliedJobIds = {};
  static final Set<String> registeredWalkinIds = {};
  static List<Map<String, dynamic>>? preloadedAppliedJobs;
  static List<Map<String, dynamic>>? preloadedRegisteredWalkins;

  static void setAppliedJobIds(Iterable<String> ids) {
    appliedJobIds.clear();
    for (final id in ids) {
      if (id.isNotEmpty) appliedJobIds.add(id);
    }
  }

  static void setRegisteredWalkinIds(Iterable<String> ids) {
    registeredWalkinIds.clear();
    for (final id in ids) {
      if (id.isNotEmpty) registeredWalkinIds.add(id);
    }
  }

  static void addAppliedJobId(String id) {
    if (id.isNotEmpty) appliedJobIds.add(id);
  }

  static void addRegisteredWalkinId(String id) {
    if (id.isNotEmpty) registeredWalkinIds.add(id);
  }

  static bool isApplied(String id) {
    return id.isNotEmpty && appliedJobIds.contains(id);
  }

  static bool isRegistered(String id) {
    return id.isNotEmpty && registeredWalkinIds.contains(id);
  }

  /// Submit job application (type 1122)
  static Future<Map<String, dynamic>> applyJob({
    required String jobId,
    required String applyBy,
    required String name,
    required String email,
    required String mobileNo,
    required String location,
    required String highQualify,
    required String skills,
    required String experience,
    required String currentCompany,
    required String currentSalary,
    required String expectedSalary,
    required String noticePeriod,
    String? resume,
    String? portfolio,
    String? gender,
    String? photo,
    String? language,
    String? education,
    String? relocate,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1122';
    body['form'] = 'sm_main_form_3145';
    body['job_id'] = jobId;
    body['apply_by'] = applyBy;
    body['name'] = name;
    body['email'] = email;
    body['mobile_no'] = mobileNo;
    body['location'] = location;
    body['high_qualify'] = highQualify;
    body['skills'] = skills;
    body['experience'] = experience;
    body['current_company'] = currentCompany;
    body['current_salary'] = currentSalary;
    body['expected_salary'] = expectedSalary;
    body['notice_period'] = noticePeriod;
    
    if (resume != null && resume.isNotEmpty) body['resume'] = resume;
    if (portfolio != null && portfolio.isNotEmpty) body['portfolio'] = portfolio;
    if (gender != null && gender.isNotEmpty) body['gender'] = gender;
    if (photo != null && photo.isNotEmpty) body['photo'] = photo;
    if (language != null && language.isNotEmpty) body['language'] = language;
    if (education != null && education.isNotEmpty) body['education'] = education;
    if (relocate != null && relocate.isNotEmpty) body['relocate'] = relocate;


    debugPrint('--> POST $url (applyJob)');
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
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('ApplyJobApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Register for Walk-In job (type 1122 with form sm_main_form_3170)
  static Future<Map<String, dynamic>> registerWalkInJob({
    required String jobId,
    required String registerBy,
    String? token,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1122';
    body['form'] = 'sm_main_form_3170';
    body['job_id'] = jobId;
    body['register_by'] = registerBy;

    debugPrint('--> POST $url (registerWalkInJob)');
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
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('ApplyJobApi.registerWalkInJob Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Fetch applied jobs (type 1121)
  static Future<Map<String, dynamic>> fetchAppliedJobs({
    required int userId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1121';
    body['form'] = 'sm_main_form_3145';
    body['where'] = 'apply_by=$userId';

    debugPrint('--> POST $url (fetchAppliedJobs)');
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
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('ApplyJobApi.fetchAppliedJobs Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Fetch registered walkin jobs (type 1121 with form sm_main_form_3170)
  static Future<Map<String, dynamic>> fetchRegisteredWalkins({
    required int userId,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1121';
    body['form'] = 'sm_main_form_3170';
    body['where'] = 'register_by=$userId';

    debugPrint('--> POST $url (fetchRegisteredWalkins)');
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
          'status': 'error',
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('ApplyJobApi.fetchRegisteredWalkins Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

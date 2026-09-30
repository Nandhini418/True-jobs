import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateJobApiService {
  static Future<Map<String, dynamic>?> createJob({
    String? jobId,
    required String userId,
    required String jobTitle,
    required String department,
    required String jobType,
    required String workLocType,
    required String location,
    required String salaryType,
    required String salaryRange,
    required String perksBenefits,
    required String experience,
    required String skills,
    required String qualification,
    required String interviewMethod,
    String? walkStart,
    String? walkEnd,
    String? walkTiming,
    String? otherInstruct,
    String? walkTimeEnd,
    String? interviewDate,
    String? walkAddress,
    required String jobDescription,
    required String responsibilities,
    required String hrName,
    required String recruiterName,
    required String vacancy,
    required String recruiterEmail,
    required String recruiterMobile,
    required String recruiterJob,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final body = {
        'type': jobId != null ? '1124' : '1122',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'form': 'sm_main_form_3135',
        'job_title': jobTitle,
        'department': department,
        'job_type': jobType,
        'work_loc_type': workLocType,
        'location': location,
        'salary_type': salaryType,
        'salary_range': salaryRange,
        'perks_benefits': perksBenefits,
        'experience': experience,
        'skills': skills,
        'qualification': qualification,
        'interview_method': interviewMethod,
        'job_description': jobDescription,
        'responsibilities': responsibilities,
        'hr_name': hrName,
        'recuriter_name': recruiterName,
        'vaccancy': vacancy,
        'recuriter_email': recruiterEmail,
        'recuriter_mobile': recruiterMobile,
        'recuriter_job': recruiterJob,
      };

      if (jobId != null) {
        body['id'] = jobId;
      }

      if (interviewMethod == '1') {
        if (walkStart != null && walkStart.isNotEmpty) body['walk_start'] = walkStart;
        if (walkEnd != null && walkEnd.isNotEmpty) body['walk_end'] = walkEnd;
        if (walkTiming != null && walkTiming.isNotEmpty) body['walk_timing'] = walkTiming;
        if (otherInstruct != null && otherInstruct.isNotEmpty) body['other_instruct'] = otherInstruct;
        if (walkTimeEnd != null && walkTimeEnd.isNotEmpty) body['walk_time_end'] = walkTimeEnd;
        if (interviewDate != null && interviewDate.isNotEmpty) body['interview_date'] = interviewDate;
        if (walkAddress != null && walkAddress.isNotEmpty) body['walk_address'] = walkAddress;
      }

      debugPrint('--- Create Job API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        body: body,
      );

      debugPrint('--- Create Job API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Create Job API Error: $e');
    }
    return null;
  }
}

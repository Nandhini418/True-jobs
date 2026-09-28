import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'skills_select_api.dart';

class JobsApi {
  static List<Map<String, dynamic>>? preloadedJobs;
  static Map<String, String>? _skillsCache;

  /// Ensure master skills list is loaded into memory cache
  static Future<void> _ensureSkillsLoaded() async {
    if (_skillsCache != null) return;
    try {
      final res = await SkillsSelectApi.fetchSkills();
      if (res['status'] == 'success' || res['error'] == false) {
        final List<dynamic>? skillsList = res['data'] as List<dynamic>?;
        if (skillsList != null) {
          final Map<String, String> cache = {};
          for (var item in skillsList) {
            if (item is Map) {
              final String? id = (item['value'] ?? item['id'])?.toString();
              final String? name = item['name']?.toString();
              if (id != null && name != null) {
                cache[id] = name;
              }
            }
          }
          _skillsCache = cache;
        }
      }
    } catch (e) {
      debugPrint('Error preloading skills in JobsApi: $e');
    }
  }

  /// Parse raw API job data into standardized map objects for UI
  static List<Map<String, dynamic>> parseJobList(dynamic responseData) {
    List<dynamic> rawList = [];
    if (responseData is List) {
      rawList = responseData;
    } else if (responseData is Map) {
      if (responseData['data'] is List) {
        rawList = responseData['data'] as List;
      } else if (responseData['data'] is Map) {
        rawList = [responseData['data']];
      } else if (responseData['id'] != null || responseData['job_title'] != null) {
        rawList = [responseData];
      }
    }

    final List<Map<String, dynamic>> mappedJobs = [];
    for (var jobData in rawList) {
      if (jobData is Map) {
        final String rawLoc = (jobData['location'] ?? '').toString().trim();
        final String rawCity = (jobData['job_city'] ?? jobData['city'] ?? '').toString().trim();
        final String rawArea = (jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? '').toString().trim();
        
        String locationStr = '';
        if (rawLoc.isNotEmpty) {
          locationStr = rawLoc;
        } else if (rawArea.isNotEmpty && rawCity.isNotEmpty) {
          locationStr = '$rawArea, $rawCity';
        } else if (rawCity.isNotEmpty) {
          locationStr = rawCity;
        } else if (rawArea.isNotEmpty) {
          locationStr = rawArea;
        } else {
          locationStr = 'Coimbatore';
        }

        final rawFrom = jobData['salary_from'];
        final rawTo = jobData['salary_to'];
        final rawPayType = (jobData['pay_type'] ?? '').toString().trim();
        final rawSalaryType = jobData['salary_type'];
        
        String payTypeStr = 'Monthly';

        final rawSalary = jobData['salary'];
        final rawSalaryRange = jobData['salary_range'];

        String salaryStr = '';
        if (rawFrom != null && rawFrom.toString().trim().isNotEmpty) {
          final fromStr = rawFrom.toString().trim();
          final toStr = (rawTo != null && rawTo.toString().trim().isNotEmpty) ? rawTo.toString().trim() : '';
          salaryStr = toStr.isNotEmpty ? '₹ $fromStr - ₹ $toStr $payTypeStr' : '₹ $fromStr $payTypeStr';
        } else if (rawSalaryRange != null && rawSalaryRange.toString().trim().isNotEmpty) {
          String rangeStr = rawSalaryRange.toString().trim();
          if (rangeStr.contains('-')) {
             final parts = rangeStr.split('-');
             salaryStr = '₹ ${parts[0].trim()} - ₹ ${parts[1].trim()} $payTypeStr';
          } else {
             salaryStr = '₹ $rangeStr $payTypeStr';
          }
        } else if (rawSalary != null && rawSalary.toString().trim().isNotEmpty) {
          salaryStr = rawSalary.toString().trim();
          final lower = salaryStr.toLowerCase();
          if (!lower.contains('monthly') && !lower.contains('yearly') && !lower.contains('annual') && !lower.contains('per month')) {
            salaryStr = '$salaryStr $payTypeStr';
          }
        } else {
          salaryStr = 'Not disclosed';
        }

        final String rawSkills = (jobData['skills'] ?? '').toString().trim();
        String processedSkills = rawSkills;
        if (rawSkills.isNotEmpty && _skillsCache != null) {
          final List<String> resolvedList = [];
          final parts = rawSkills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
          for (var part in parts) {
            if (_skillsCache!.containsKey(part)) {
              resolvedList.add(_skillsCache![part]!);
            } else {
              resolvedList.add(part);
            }
          }
          if (resolvedList.isNotEmpty) {
            processedSkills = resolvedList.join(',');
          }
        }

        final mapped = {
          ...Map<String, dynamic>.from(jobData),
          'id': jobData['id'],
          'title': jobData['job_title'] ?? jobData['title'] ?? '',
          'company': jobData['company_name'] ?? jobData['company'] ?? '',
          'location': locationStr,
          'exp': jobData['experience'] ?? jobData['exp'] ?? '',
          'salary': salaryStr,
          'desc': jobData['job_description'] ?? jobData['job_desc'] ?? jobData['desc'] ?? '',
          'job_description': jobData['job_description'] ?? jobData['job_desc'] ?? '',
          'time': jobData['dtime'] ?? '',
          'skills': processedSkills,
          'logoText': (jobData['company_name'] ?? jobData['company'] ?? 'J').toString().trim().isNotEmpty
              ? (jobData['company_name'] ?? jobData['company']).toString().trim().substring(0, 1).toUpperCase()
              : 'J',
          'logoBg': Colors.blue.shade50,
          'logoColor': Colors.blue.shade700,
          'walkInDate': jobData['walk_start'] ?? jobData['walkInDate'],
          'walkInTime': jobData['walk_time_end'] ?? jobData['walk_time'] ?? jobData['walkInTime'] ?? '',
          'walk_address': jobData['walk_address'] ?? jobData['office_address'] ?? '',
        };
        mappedJobs.add(mapped);
      }
    }
    return mappedJobs;
  }

  /// Fetch all jobs or specific job details by ID (type 1125)
  static Future<Map<String, dynamic>> fetchJobDetails({
    int? jobId,
  }) async {
    await _ensureSkillsLoaded();

    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1125';
    if (jobId != null) {
      body['id'] = jobId.toString();
    }

    debugPrint('--> POST $url (fetchJobDetails)');
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
      debugPrint('JobsApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Alias to fetch all jobs
  static Future<Map<String, dynamic>> fetchJobs() => fetchJobDetails();
}

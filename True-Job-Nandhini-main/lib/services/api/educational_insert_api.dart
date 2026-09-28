import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class EducationalInsertApi {
  /// Insert educational details (type 1117)
  static Future<Map<String, dynamic>> insertEducationalDetails({
    required String name,
    required String highQualify,
    required Map<String, Map<String, String>> savedDetails,
  }) async {
    final String url = ApiConfig.baseUrl;

    final Map<String, String> body = await ApiConfig.getCommonParams();
    body['type'] = '1117';
    body['name'] = name;
    body['high_qualify'] = highQualify;

    String valOrZero(String? value) {
      if (value == null || value.trim().isEmpty) {
        return '0';
      }
      return value.trim();
    }

    // Tenth details (value: '1')
    body['10th_board'] = valOrZero(savedDetails['1']?['board']);
    body['10th_schl_name'] = savedDetails['1']?['school'] ?? '';
    body['10th_year_complete'] = valOrZero(savedDetails['1']?['year']);
    body['10th_percent_cgpa'] = valOrZero(savedDetails['1']?['percentage']);

    // Twelfth details (value: '2')
    body['12th_board'] = valOrZero(savedDetails['2']?['board']);
    body['12th_stream'] = valOrZero(savedDetails['2']?['stream']);
    body['12th_schl_name'] = savedDetails['2']?['school'] ?? '';
    body['12th_year_complete'] = valOrZero(savedDetails['2']?['year']);
    body['12th_percent_cgpa'] = valOrZero(savedDetails['2']?['percentage']);

    // UG details (value: '3')
    body['ug_course'] = valOrZero(savedDetails['3']?['course']);
    body['ug_specialization'] = savedDetails['3']?['specialization'] ?? '';
    body['ug_college'] = savedDetails['3']?['institute'] ?? '';
    body['ug_university'] = savedDetails['3']?['university'] ?? '';
    body['ug_duration'] = savedDetails['3']?['duration'] ?? '';
    body['ug_year_complete'] = valOrZero(savedDetails['3']?['year']);
    body['ug_percent_cgpa'] = valOrZero(savedDetails['3']?['percentage']);

    // PG details (value: '4')
    body['pg_course'] = valOrZero(savedDetails['4']?['course']);
    body['pg_specialization'] = savedDetails['4']?['specialization'] ?? '';
    body['pg_college'] = savedDetails['4']?['institute'] ?? '';
    body['pg_university'] = savedDetails['4']?['university'] ?? '';
    body['pg_duration'] = savedDetails['4']?['duration'] ?? '';
    body['pg_year_complete'] = valOrZero(savedDetails['4']?['year']);
    body['pg_percent_cgpa'] = valOrZero(savedDetails['4']?['percentage']);

    // Diploma details (value: '5')
    body['diploma'] = valOrZero(savedDetails['5']?['diploma']);
    body['dip_institute'] = savedDetails['5']?['institute'] ?? '';
    body['dip_board_university'] = savedDetails['5']?['board'] ?? '';
    body['dip_duration'] = savedDetails['5']?['duration'] ?? '';
    body['dip_year_complete'] = valOrZero(savedDetails['5']?['year']);
    body['dip_percent'] = valOrZero(savedDetails['5']?['percentage']);

    // ITI details (value: '6')
    body['iti_trade'] = valOrZero(savedDetails['6']?['trade']);
    body['iti_specialization'] = savedDetails['6']?['specialization'] ?? '';
    body['iti_institute'] = savedDetails['6']?['institute'] ?? '';
    
    final String rawBoard = savedDetails['6']?['boardType'] ?? '';
    body['iti_board'] = rawBoard == 'NCVT' ? '1' : (rawBoard == 'SCVT' ? '2' : '0');

    body['iti_duration'] = savedDetails['6']?['duration'] ?? '';
    body['iti_year_complete'] = valOrZero(savedDetails['6']?['year']);
    body['iti_percent'] = valOrZero(savedDetails['6']?['percentage']);

    debugPrint('--> POST $url (insertEducationalDetails)');
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
      debugPrint('EducationalInsertApi Error: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

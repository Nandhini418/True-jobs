import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:truejobs/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDetailsApiService {
  static Future<Map<String, dynamic>?> updateDetails({
    required String userId,
    required String companyName,
    required String pincode,
    required String address,
    required String industryType,
    required String token,
    String? companySize,
    String? foundedYear,
    String? companyMobile,
    String? companyWebsite,
    String? companyEmail,
    String? companyDescription,
    String? city,
    String? state,
    String? country,
    String? linkedinUrl,
    String? aboutCompany,
    String? companyLogoFile,
    List<String>? ourCulture,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final fields = <String, String>{
        'type': '1164',
        'cid': ApiConstants.cid,
        'device_id': prefs.getString('device_id') ?? '13',
        'ln': prefs.getString('ln') ?? '11',
        'lt': prefs.getString('lt') ?? '11',
        'user_id': userId,
        'company_name': companyName,
        'industry_type': industryType,
        'pincode': pincode,
        'address': address,
        'token': token,
      };

      if (companySize != null) fields['company_size'] = companySize;
      if (foundedYear != null) fields['founded_year'] = foundedYear;
      if (companyMobile != null) fields['company_mobile'] = companyMobile;
      if (companyWebsite != null) fields['company_website'] = companyWebsite;
      if (companyEmail != null) fields['company_email'] = companyEmail;
      if (companyDescription != null) fields['company_description'] = companyDescription;
      if (city != null) fields['city'] = city;
      if (state != null) fields['state'] = state;
      if (country != null) fields['country'] = country;
      if (linkedinUrl != null) fields['linkedin_url'] = linkedinUrl;
      if (aboutCompany != null) fields['about_company'] = aboutCompany;

      // Remove empty fields to avoid triggering WAF rules with empty multipart bodies
      fields.removeWhere((key, value) => value.trim().isEmpty);

      bool hasFiles = (companyLogoFile != null && companyLogoFile.isNotEmpty && !companyLogoFile.startsWith('http')) ||
          (ourCulture != null && ourCulture.any((path) => !path.startsWith('http')));

      debugPrint('--- Company Details API Request ---');
      debugPrint('URL: ${ApiConstants.baseUrl}');
      debugPrint('Fields: $fields');

      http.Response response;

      final Map<String, String> headers = {
        'Accept': 'application/json, text/plain, */*',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
        'Origin': 'https://truejobs.in',
        'Referer': 'https://truejobs.in/',
        'Connection': 'keep-alive',
      };

      if (hasFiles) {
        var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.baseUrl));
        request.headers.addAll(headers);
        request.fields.addAll(fields);

        if (companyLogoFile != null && companyLogoFile.isNotEmpty && !companyLogoFile.startsWith('http')) {
          request.files.add(await http.MultipartFile.fromPath('company_logo_file', companyLogoFile));
        }

        if (ourCulture != null && ourCulture.isNotEmpty) {
          for (int i = 0; i < ourCulture.length; i++) {
            if (!ourCulture[i].startsWith('http')) {
              request.files.add(await http.MultipartFile.fromPath('our_culture[]', ourCulture[i]));
            }
          }
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.post(
          Uri.parse(ApiConstants.baseUrl),
          headers: headers,
          body: fields,
        );
      }

      debugPrint('--- Company Details API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Company Details API Error: $e');
    }
    return null;
  }
}

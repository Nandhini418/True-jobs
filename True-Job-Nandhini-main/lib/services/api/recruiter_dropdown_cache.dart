import 'package:flutter/foundation.dart';
import 'package:truejobs/services/dropdown_apis/location_type_api_service.dart';
import 'package:truejobs/services/dropdown_apis/salary_api_service.dart';
import 'package:truejobs/services/dropdown_apis/perks_api_service.dart';
import 'package:truejobs/services/dropdown_apis/employment_type_api_service.dart';
import 'package:truejobs/services/dropdown_apis/department_api_service.dart';
import 'package:truejobs/services/dropdown_apis/skills_api_service.dart';
import 'package:truejobs/services/api/location_dropdown_api.dart';

class RecruiterDropdownCache {
  static List<dynamic> locationTypes = [];
  static List<dynamic> salaryTypes = [];
  static List<dynamic> employmentTypes = [];
  static List<dynamic> departments = [];
  static List<dynamic> rawPerks = [];
  static List<dynamic> rawSkills = [];
  static List<dynamic> rawLocations = [];
  
  static bool isLoaded = false;
  static Future<void>? _loadingFuture;

  static Future<void> preloadDropdowns() async {
    if (isLoaded) return;
    if (_loadingFuture != null) return _loadingFuture;

    _loadingFuture = _doPreload();
    await _loadingFuture;
  }

  static Future<void> _doPreload() async {
    try {
      final locTypesRes = await LocationTypeApiService.fetchLocationTypes();
      final salTypesRes = await SalaryApiService.fetchSalaryTypes();
      final perksRes = await PerksApiService.fetchPerks();
      final empTypesRes = await EmploymentTypeApiService.fetchEmploymentTypes();
      final deptTypesRes = await DepartmentApiService.fetchDepartments();
      final skillsRes = await SkillsApiService.fetchSkills();
      
      final locationsMap = await LocationDropdownApi.fetchLocations();
      List<dynamic> locationsRes = [];
      if (locationsMap['status'] == 'success' || locationsMap['error'] == false) {
        if (locationsMap['data'] is List) {
          locationsRes = locationsMap['data'];
        } else if (locationsMap['dropdown'] is List) {
          locationsRes = locationsMap['dropdown'];
        }
      }

      locationTypes = locTypesRes;
      salaryTypes = salTypesRes;
      rawPerks = perksRes;
      employmentTypes = empTypesRes;
      departments = deptTypesRes;
      rawSkills = skillsRes;
      rawLocations = locationsRes;

      isLoaded = true;
    } catch (e) {
      debugPrint('Error preloading recruiter dropdowns: $e');
    } finally {
      _loadingFuture = null;
    }
  }
}

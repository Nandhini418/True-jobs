import 'package:flutter/foundation.dart';
import 'package:truejobs/services/api/job_type_api.dart';
import 'package:truejobs/services/api/work_mode_api.dart';
import 'package:truejobs/services/dropdown_apis/perks_api_service.dart';

class DropdownCache {
  static Map<String, String> jobTypeMap = {};
  static Map<String, String> workModeMap = {};
  static Map<String, String> perksMap = {};
  
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
      final jobTypeRes = await JobTypeApi.fetchJobTypes();
      if (jobTypeRes['status'] == 'success' || jobTypeRes['error'] != true) {
        final list = jobTypeRes['dropdown'] ?? jobTypeRes['data'];
        if (list != null && list is List) {
          for (var item in list) {
            final key = (item['value'] ?? item['id'])?.toString();
            final name = (item['name'] ?? item['label'])?.toString() ?? '';
            if (key != null) jobTypeMap[key] = name;
          }
        }
      }

      final workModeRes = await WorkModeApi.fetchWorkModes();
      if (workModeRes['status'] == 'success' || workModeRes['error'] != true) {
        final list = workModeRes['dropdown'] ?? workModeRes['data'];
        if (list != null && list is List) {
          for (var item in list) {
            final key = (item['value'] ?? item['id'])?.toString();
            final name = (item['name'] ?? item['label'])?.toString() ?? '';
            if (key != null) workModeMap[key] = name;
          }
        }
      }

      final perksRes = await PerksApiService.fetchPerks();
      for (var item in perksRes) {
        final key = (item['value'] ?? item['id'])?.toString();
        final name = (item['name'] ?? item['label'])?.toString() ?? '';
        if (key != null) perksMap[key] = name;
      }

      isLoaded = true;
    } catch (e) {
      debugPrint('Error preloading dropdowns: $e');
    } finally {
      _loadingFuture = null;
    }
  }
}

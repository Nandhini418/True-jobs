import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'https://truejobs.in/ai/api/m_api/';

  /// Retrieve device unique identifier
  static Future<String> getDeviceId() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String id = '';
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id; // Usually a solid unique build/hardware ID
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }

      final prefs = await SharedPreferences.getInstance();
      if (id.isNotEmpty) {
        await prefs.setString('device_id', id);
        return id;
      }

      // Fallback to cache if dynamic query failed
      if (prefs.containsKey('device_id')) {
        return prefs.getString('device_id') ?? '';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
    }
    return ''; // Default fallback
  }

  /// Retrieve common API body parameters loaded from SharedPreferences cache
  static Future<Map<String, String>> getCommonParams() async {
    final prefs = await SharedPreferences.getInstance();
    double lat = prefs.getDouble('latitude') ?? 0.0;
    double lng = prefs.getDouble('longitude') ?? 0.0;
    if (lat == 0.0) lat = 11.0;
    if (lng == 0.0) lng = 11.0;
    final String deviceId = await getDeviceId();
    return {
      'cid': '21472147',
      'lt': lat.toString(),
      'ln': lng.toString(),
      'device_id': deviceId,
    };
  }

  /// Retrieve current location coordinates or fall back to cached/default values
  static Future<Map<String, double>> getCoordinates() async {
    double lat = 0.0;
    double lng = 0.0;

    try {
      // First try to check cached location from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('latitude') && prefs.containsKey('longitude')) {
        lat = prefs.getDouble('latitude') ?? lat;
        lng = prefs.getDouble('longitude') ?? lng;
      }

      // Try fetching current fresh location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          Position? position;
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );
          } catch (e) {
            debugPrint('Fresh GPS fix failed, trying last known: $e');
            position = await Geolocator.getLastKnownPosition();
          }

          if (position != null) {
            lat = position.latitude;
            lng = position.longitude;

            // Update cached values
            await prefs.setDouble('latitude', lat);
            await prefs.setDouble('longitude', lng);
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }

    if (lat == 0.0) lat = 11.0;
    if (lng == 0.0) lng = 11.0;

    return {'latitude': lat, 'longitude': lng};
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfoService {
  static Future<void> initializePermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('Location services are disabled.');
        }
      }
      
      // Fetch and save the actual data to SharedPreferences so APIs don't have to wait
      await _fetchAndSaveDataToPrefs();
    } catch (e) {
      debugPrint('Failed to request location permission on startup: $e');
    }
  }

  static Future<void> _fetchAndSaveDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Get Device ID
    String deviceId = '13';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '13';
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
    }
    await prefs.setString('device_id', deviceId);

    // 2. Get Location
    String ln = '11';
    String lt = '11';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition();
          ln = position.longitude.toString();
          lt = position.latitude.toString();
        }
      }
    } catch (e) {
      debugPrint('Failed to get location info: $e');
    }
    
    await prefs.setString('ln', ln);
    await prefs.setString('lt', lt);
    debugPrint('Saved to SharedPreferences: device_id=$deviceId, ln=$ln, lt=$lt');
  }

  // Fallback if needed, but APIs should ideally read directly from SharedPreferences
  static Future<Map<String, String>> getDynamicData() async {
    String deviceId = '13'; // Default fallback
    String ln = '11';      // Default fallback
    String lt = '11';      // Default fallback

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '13';
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          debugPrint('Location permissions are denied');
        } else {
          final position = await Geolocator.getCurrentPosition();
          ln = position.longitude.toString();
          lt = position.latitude.toString();
        }
      }
    } catch (e) {
      debugPrint('Failed to get location info: $e');
    }

    return {
      'device_id': deviceId,
      'ln': ln,
      'lt': lt,
    };
  }
}

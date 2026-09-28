import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_colors.dart';

class LocationHelper {
  /// Session flag ensuring location is only prompted ONCE per app launch.
  static bool hasPromptedThisSession = false;

  /// Checks location service status and prompts the user to enable real-time location on screen entry.
  /// Only prompts for location services enablement if permission has already been granted.
  static Future<void> checkAndPromptLocation(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      // If permission is not granted, we do not ask again or show warnings.
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // If permission is granted, check location services
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          try {
            // Calling getCurrentPosition triggers the system-level Google Play Services location request dialog
            await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
          } catch (_) {
            // User declined native prompt, do not show any secondary warning/error dialogs
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
    }
  }

  /// Displays the dialog box informing the user that location access is not enabled and can be enabled later.
  static Future<void> showLocationDisabledDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final double sw = MediaQuery.of(dialogContext).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Location Access',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Location access is not denied, you can turn on later.',
            style: TextStyle(
              fontSize: sw * 0.038,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Interactive check and prompt for location services/permission in real-time.
  /// Returns [true] always to ensure user navigation/actions are never blocked,
  /// but attempts to trigger the system-level location dialog if permission is granted.
  static Future<bool> requestEnableLocation(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      // If permission is denied or deniedForever, we do not want to prompt
      // or show settings dialogs here. Just proceed smoothly.
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return true;
      }

      // If permission is granted but location services are disabled, show native prompt.
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Attempt standard native location prompt. If user declines or it fails,
          // catch the error and proceed without blocking.
          try {
            await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
            );
          } catch (_) {
            // User declined/failed, do not show secondary blocking dialogs
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error enabling location: $e');
      return true;
    }
  }

  /// Prompt user to open settings to turn on location services
  static Future<void> showLocationSettingsPrompt(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final double sw = MediaQuery.of(dialogContext).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Location Services Disabled',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'True Jobs requires device location services enabled to proceed. Please turn on location services.',
            style: TextStyle(
              fontSize: sw * 0.038,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text(
                'Turn On',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Prompt user to open settings to grant location permission
  static Future<void> showPermissionDeniedForeverDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final double sw = MediaQuery.of(dialogContext).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Location Permission Denied',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Location permission is permanently denied. Please enable it from app settings to proceed.',
            style: TextStyle(
              fontSize: sw * 0.038,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openAppSettings();
              },
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

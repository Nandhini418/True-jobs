import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/common_screens/unified_login_screen.dart';

class GuestPopup extends StatelessWidget {
  const GuestPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sw * 0.05),
      ),
      child: Stack(
        children: [
          // Close button at top right
          Positioned(
            right: sw * 0.02,
            top: sw * 0.02,
            child: IconButton(
              icon: Icon(Icons.close, color: textColor, size: sw * 0.06),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              vertical: sw * 0.08,
              horizontal: sw * 0.06,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: sw * 0.02),
                // App Logo / Header Image
                Image.asset(
                  'assets/header.png',
                  height: sw * 0.12,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    'TRUE JOBS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: sw * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.04),

                // Title
                Text(
                  'Login To Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sw * 0.05,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: sw * 0.02),

                // Subtitle
                Text(
                  'Verify Your Mobile Number To Continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sw * 0.035, color: subtitleColor),
                ),
                SizedBox(height: sw * 0.06),

                // Login/Signup Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const UnifiedLoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, sw * 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login / Sign Up',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.03),

                // Continue As Guest Button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    minimumSize: Size(double.infinity, sw * 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                  ),
                  child: Text(
                    'Continue As Guest',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.05),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: sw * 0.04,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      'Your Data Is Safe With Us',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show guest dialog if in guest mode.
/// Returns true if guest dialog was shown (blocking access), false if allowed.
Future<bool> checkAndShowGuestPopup(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final bool isGuest = prefs.getBool('is_guest') ?? false;
  if (isGuest) {
    if (context.mounted) {
      showDialog(context: context, builder: (context) => const GuestPopup());
    }
    return true;
  }
  return false;
}

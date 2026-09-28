import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../job_seeker_module/home_screen.dart';
import '../constants/app_colors.dart';

class SuccessPopup extends StatelessWidget {
  const SuccessPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.08,
          horizontal: screenWidth * 0.06,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success GIF
            Image.asset(
              'assets/success.gif',
              width: screenWidth * 0.55,
              height: screenWidth * 0.45,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenWidth * 0.06),

            // "Profile Created successfully" text
            Text(
              'Profile Created successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w500,
                color: const Color(
                  0xFF1B824B,
                ), // AppColors.iconGreen or standard green
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // "Welcome to <LOGO>" row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to ',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Flexible(
                  child: Image.asset(
                    'assets/header.png',
                    height: screenWidth * 0.08,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the popup
void showSuccessPopup(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const SuccessPopup(),
  );

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_profile_completed', true);
    await prefs.setInt('profile_creation_step', 5);
  } catch (e) {
    debugPrint('DEBUG Success Popup Error saving to SharedPreferences: $e');
  }

  Future.delayed(const Duration(seconds: 2), () {
    if (context.mounted) {
      Navigator.of(context).pop(); // close dialog
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  });
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import 'package:truejobs/common_screens/unified_login_screen.dart';
import 'package:truejobs/services/login_api_service.dart';

class LogoutPopup extends StatelessWidget {
  final bool isRecruiter;
  const LogoutPopup({super.key, this.isRecruiter = false});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;

    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(sw * 0.06),
        decoration: BoxDecoration(
          color: cardBg,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE9F7),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: AppColors.red, size: sw * 0.08),
            ),
            SizedBox(height: sw * 0.05),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: sw * 0.05,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: sw * 0.03),
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.038,
                color: subtitleColor,
              ),
            ),
            SizedBox(height: sw * 0.06),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: subtitleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: sw * 0.038,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isRecruiter) {
                        await LoginApiService.logout();
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        int? userId;
                        try {
                          userId = prefs.getInt('user_id');
                        } catch (_) {
                          final String? userIdStr = prefs.getString('user_id');
                          if (userIdStr != null) {
                            userId = int.tryParse(userIdStr);
                          }
                        }
                        if (userId == null) {
                          final String? cidStr = prefs.getString('cid');
                          if (cidStr != null) {
                            userId = int.tryParse(cidStr);
                          }
                        }
                        if (userId != null) {
                          await prefs.remove('user_${userId}_skills');
                          await prefs.remove('user_${userId}_you_have_experience');
                          await prefs.remove('user_${userId}_job_title');
                          await prefs.remove('user_${userId}_company_name');
                          await prefs.remove('user_${userId}_experience_salary');
                          await prefs.remove('user_${userId}_tot_year_xperience');
                          await prefs.remove('user_${userId}_current_work');
                          await prefs.remove('user_${userId}_selected_shifts');
                          await prefs.remove('user_${userId}_selected_work_modes');
                          await prefs.remove('user_${userId}_selected_job_types');
                          await prefs.remove('user_${userId}_selected_job_roles');
                        }
                        await prefs.remove('token');
                        await prefs.remove('user_id');
                        await prefs.remove('user_role');
                        await prefs.remove('is_profile_completed');
                        await prefs.remove('profile_creation_step');
                        await prefs.remove('mobile');
                        await prefs.remove('name');
                        await prefs.remove('email');
                        await prefs.remove('gender');
                        await prefs.remove('dob');
                        await prefs.remove('physical_challenge');
                        await prefs.remove('cond_type');
                        await prefs.remove('affect_area');
                        await prefs.remove('profile_pic_path');
                        await prefs.remove('profile_image_url');
                        await prefs.remove('resume');
                        await prefs.remove('linkedin');
                        await prefs.remove('portfolio');
                        await prefs.remove('job_title');
                        await prefs.remove('company_name');
                        await prefs.remove('experience_salary');
                        await prefs.remove('you_have_experience');
                        await prefs.remove('is_guest');
                        await prefs.remove('user_skills');
                        await prefs.remove('profile_photo_deleted');
                      }

                      if (context.mounted) {
                        // Navigate to Login Screen and clear the backstack
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UnifiedLoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                      elevation: 0,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sw * 0.038,
                      ),
                    ),
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

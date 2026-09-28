import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/notification_screen.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/about_us_screen.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/privacy_policy_screen.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/terms_and_conditions_screen.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/help_and_support_screen.dart';
import 'package:truejobs/widgets/logout_popup.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Header "< Settings"
                  Row(
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dynamicText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  _buildSettingItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification',
                    subtitle: 'Manage notification preference',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.public,
                    title: 'Privacy Policy',
                    subtitle: 'Change app language',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.phone_outlined,
                    title: 'Terms & Condition',
                    subtitle: 'Get in touch with our support team',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()));
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Find answers to your question',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpAndSupportScreen()));
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'App version and other details',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'sign out from your account',
                    isLogout: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const LogoutPopup(isRecruiter: true),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final Color itemColor = isLogout ? const Color(0xFFC12600) : Colors.black;
    final Color iconBgColor = isLogout ? const Color(0xFFFCEAEA) : const Color(0xFFF0F7FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 11.h),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFDFD),
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: itemColor, size: 18.w),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: itemColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? itemColor : Colors.black,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}

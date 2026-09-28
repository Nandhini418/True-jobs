import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'jobs_screen.dart';
import '../Profile Sections/profile_screen.dart';
import '../../utils/smooth_page_route.dart';

class AppliedSuccessfullyScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const AppliedSuccessfullyScreen({super.key, required this.job});

  @override
  State<AppliedSuccessfullyScreen> createState() => _AppliedSuccessfullyScreenState();
}

class _AppliedSuccessfullyScreenState extends State<AppliedSuccessfullyScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      _goToHome();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToHome() {
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/success.gif',
                        width: sw * 0.4,
                        height: sw * 0.4,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: sw * 0.05),
                      Text(
                        'Applied Successfully',
                        style: TextStyle(
                          fontSize: sw * 0.05,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: sw * 0.025),
                      Text(
                        'Your resume has been uploaded successfully and is ready to be viewed by recruiters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: subtitleColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom actions
            Padding(
              padding: EdgeInsets.only(
                left: sw * 0.05,
                right: sw * 0.05,
                bottom: sw * 0.1,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: sh * 0.06,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pushAndRemoveUntil(
                          SmoothPageRoute(child: const ProfileScreen()),
                          (route) => route.isFirst,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to Profile',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: sw * 0.015),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: sw * 0.035,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: sw * 0.03),
                  SizedBox(
                    width: double.infinity,
                    height: sh * 0.06,
                    child: OutlinedButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pushAndRemoveUntil(
                          SmoothPageRoute(child: const JobsScreen()),
                          (route) => route.isFirst,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Browse Jobs',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: sw * 0.02),
                          Icon(
                            Icons.business_center_outlined,
                            size: sw * 0.045,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: sw * 0.04),

                  // Tip box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw * 0.035),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(sw * 0.015),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.primary,
                            size: sw * 0.045,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: Text(
                            'Tip: Recruiters can now discover your profile based on your skills and experience.',
                            style: TextStyle(
                              fontSize: sw * 0.032,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28.h),
                Text(
                  'Hire the Best Talent Faster',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Post jobs, screen candidates, schedule interviews, and build winning teams.',
                  style: TextStyle(
                    color: Color(0xFFDBDBDB),
                    fontSize: 13.sp,
                    height: 1.8,
                  ),
                ),
                SizedBox(height: 30.h),
                const _FeatureItem(
                  title: 'Smart Candidate Matching',
                  subtitle: 'AI powered recommendations',
                  image: 'assets/gif/walkthrough 1.gif',
                ),
                SizedBox(height: 19.h),
                const _FeatureItem(
                  title: 'Advanced Analytics',
                  subtitle: 'Data driven hiring insights',
                  image: 'assets/gif/walkthrough 2.gif',
                ),
                SizedBox(height: 19.h),
                const _FeatureItem(
                  title: 'Secure & Reliable',
                  subtitle: 'Enterprise grade security',
                  image: 'assets/gif/walkthrough 3.gif',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.gradientEnd,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: const Color(0xFF055BF2),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Image.asset(image, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFFB5B5B5),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


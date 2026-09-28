import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 28.h),
                  // Header Row "< About Us"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                          SizedBox(width: 7.w),
                          Text(
                            'About App',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dynamicText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  Text(
                    'Our mission',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 11.h),
                  Text(
                    'Empowering Employers to Hire Smarter',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.dynamicText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 11.h),
                  Text(
                    'Build a faster, simpler, and more efficient hiring experience by connecting employers with the right talent. Our mission is to streamline recruitment, reduce hiring time, and help businesses grow with confidence.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: AppColors.secondary_color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),
                  
                  // Simple divider mimicking the glow/shadow in the design
                  Image.asset('assets/images/ellipse.png', width: 180.w,),
                  
                  SizedBox(height: 32.h),

                  Text(
                    'About Us',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.dynamicText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 11.h),
                  Text(
                    'Our Employer App is designed to simplify the recruitment process for businesses of all sizes. From posting jobs and managing applications to scheduling interviews and communicating with candidates, everything is available in one easy-to- use platform. We help employers hire faster, stay organized, and make better hiring decisions.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: AppColors.secondary_color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

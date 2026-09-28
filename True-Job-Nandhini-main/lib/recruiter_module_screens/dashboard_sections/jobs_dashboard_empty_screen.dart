import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class JobsDashboardEmptyScreen extends StatelessWidget {
  final bool isCompanyProfileComplete;
  final VoidCallback onCompleteProfilePressed;
  final VoidCallback onCreateJobPressed;

  const JobsDashboardEmptyScreen({
    super.key,
    required this.isCompanyProfileComplete,
    required this.onCompleteProfilePressed,
    required this.onCreateJobPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(),

          // Dashboard Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration representation in pure Flutter widgets
                  SizedBox(
                    width: 252.w,
                    height: 180.w,
                    child: Image.asset(
                      'assets/images/dashboard.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 34.h),
                  Text(
                    'Oops! You have no jobs right now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 43.w),
                    child: Text(
                      'Once you start posting jobs, you can track them all here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        color:  const Color(0x66292929),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Primary Action button
                  SizedBox(
                    height: 35.h,
                    child: ElevatedButton.icon(
                      onPressed: isCompanyProfileComplete ? onCreateJobPressed : onCompleteProfilePressed,
                      icon: Icon(
                        isCompanyProfileComplete ? Icons.add : Icons.edit_document, 
                        size: 16.w, 
                        color: Colors.white
                      ),
                      label: Text(
                        isCompanyProfileComplete ? 'Create New Job' : 'Complete Company Profile',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

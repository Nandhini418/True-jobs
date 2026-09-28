import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class HowToCreateJobPostingScreen extends StatelessWidget {
  const HowToCreateJobPostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String fontFamily = 'Poppins';

    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          const CustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 28.h),
                  // Header Row "< How to create a job posting"
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'How to create a job posting',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'Steps to create a job posting',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildStep(
                    fontFamily,
                    stepNumber: '1',
                    title: 'Go to Jobs → Add new jobs',
                    description: "Click on 'Add new Job' from your jobs dashboard.",
                  ),
                  _buildStep(
                    fontFamily,
                    stepNumber: '2',
                    title: 'Enter Job Details',
                    description: "Add the job title, salary range, skills and other preferences.",
                  ),
                  _buildStep(
                    fontFamily,
                    stepNumber: '3',
                    title: 'Set Job Preferences',
                    description: "Choose job type, salary range, skills and other preference.",
                  ),
                  _buildStep(
                    fontFamily,
                    stepNumber: '4',
                    title: 'Review & preview',
                    description: "Review all details and preview how your job will appear.",
                  ),
                  _buildStep(
                    fontFamily,
                    stepNumber: '5',
                    title: 'Publish Job',
                    description: "Click on 'Publish' to make your job live.",
                    isLast: true,
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'Was the article helpful ?',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      _buildHelpfulButton(
                        fontFamily,
                        text: 'Yes, it helped',
                        icon: Icons.thumb_up_rounded,
                        color: const Color(0xFF36C768),
                        borderColor: const Color(0xFFB7EDBD)
                      ),
                      SizedBox(width: 11.w),
                      _buildHelpfulButton(
                        fontFamily,
                        text: 'No, not really',
                        icon: Icons.thumb_down_rounded,
                        color: const Color(0xFFD84343),
                        borderColor: AppColors.secondary_color
                      ),
                    ],
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

  Widget _buildStep(
      String fontFamily, {
        required String stepNumber,
        required String title,
        required String description,
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 18.w,
      ),
      child: Stack(
        children: [
          // Divider across the full width
          if (!isLast)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const Divider(
                height: 1,
                thickness: 0.3,
                color: Color(0xFFD3D3D3),
              ),
            ),

          // Step content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF055BF2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dynamicText,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 14.h),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulButton(String fontFamily, {required String text, required IconData icon, required Color color, required Color borderColor,}) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color, size: 16.sp),
      label: Text(
        text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 0.59),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      ),
    );
  }
}

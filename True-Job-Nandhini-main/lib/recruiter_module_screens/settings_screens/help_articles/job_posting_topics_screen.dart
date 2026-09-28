import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/help_articles/how_to_create_job_posting_screen.dart';

class JobPostingTopicsScreen extends StatelessWidget {
  const JobPostingTopicsScreen({super.key});

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
                  // Header Row "< Job Posting"
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'Job Posting',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  _buildTopicItem(
                    context,
                    title: 'How to create a job posting',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HowToCreateJobPostingScreen()));
                    },
                  ),
                  _buildTopicItem(
                    context,
                    title: 'Edit an existing job',
                  ),
                  _buildTopicItem(
                    context,
                    title: 'Pause or close a job',
                  ),
                  _buildTopicItem(
                    context,
                    title: 'Boost your job visibility',
                  ),
                  _buildTopicItem(
                    context,
                    title: 'Why is my job not getting applicants',
                  ),
                  _buildTopicItem(
                    context,
                    title: 'Delete a job posting',
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

  Widget _buildTopicItem(BuildContext context, {required String title, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.w),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.w,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: const Color(0xFFF2F2F2)),
          borderRadius: BorderRadius.circular(11.r),
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
              padding: EdgeInsets.all(7.w),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.article_outlined, color: const Color(0xFF64748B), size: 16.sp),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dynamicText,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFF64748B), size: 20.sp),
          ],
        ),
      ),
    );
  }
}

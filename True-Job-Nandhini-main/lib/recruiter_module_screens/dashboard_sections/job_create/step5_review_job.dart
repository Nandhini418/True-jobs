import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'job_create_widgets.dart';

class Step5ReviewJob extends StatelessWidget {
  final String title;
  final String location;
  final String employmentType;
  final String experience;
  final String salaryRange;
  final String openings;

  const Step5ReviewJob({
    super.key,
    required this.title,
    required this.location,
    required this.employmentType,
    required this.experience,
    required this.salaryRange,
    required this.openings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Review Job', subtitle: 'Review the details before publishing'),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFD7D7D7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Job Title', title),
              SizedBox(height: 16.h),
              
              _buildReviewRow('Location', location),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(child: _buildReviewRow('Employment Type', employmentType.isEmpty ? 'Not Specified' : employmentType)),
                  Expanded(child: _buildReviewRow('Experience', experience.isEmpty ? 'Not Specified' : experience)),
                ],
              ),
              SizedBox(height: 16.h),
              
              _buildReviewRow('Salary', salaryRange.isEmpty ? 'Not Specified' : '₹ $salaryRange'),
              SizedBox(height: 16.h),
              
              _buildReviewRow('Openings', openings.isEmpty ? '1' : openings),
            ],
          ),
        ),
        
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: kJobFontFamily,
            fontSize: 11.sp,
            color: AppColors.dynamicSubtitle,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: kJobFontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.dynamicText,
          ),
        ),
      ],
    );
  }
}

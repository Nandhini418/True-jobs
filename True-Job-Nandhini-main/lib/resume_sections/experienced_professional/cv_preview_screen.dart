import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/models/resume_data.dart';
import 'package:truejobs/resume_sections/templates/template_one.dart';
import 'package:truejobs/resume_sections/templates/template_two.dart';
import 'package:truejobs/resume_sections/templates/template_three.dart';
import 'package:truejobs/resume_sections/templates/template_four.dart';
import 'package:truejobs/resume_sections/experienced_professional/customize_cv_screen.dart';
import 'package:truejobs/utils/smooth_page_route.dart';

class CvPreviewScreen extends StatelessWidget {
  final int templateId;
  const CvPreviewScreen({super.key, this.templateId = 1});

  Widget _buildTemplateWidget() {
    switch (templateId) {
      case 2:
        return TemplateTwo(data: ResumeData.globalData);
      case 3:
        return TemplateThree(data: ResumeData.globalData);
      case 4:
        return TemplateFour(data: ResumeData.globalData);
      case 1:
      default:
        return TemplateOne(data: ResumeData.globalData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 16.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Header
                    Image.asset(
                      'assets/resume_images/experience/additional_information.gif',
                      height: 50.h,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.insert_drive_file,
                        size: 40.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Cv Preview",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "This is how your CV will look",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // The CV Preview Box
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: 400,
                                      height: 400 * 1.414,
                                      child: _buildTemplateWidget(),
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom blue decorative line seen in mockup
                              Container(
                                height: 24.h,
                                width: double.infinity,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Customize button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          SmoothPageRoute(
                            child: const CustomizeCvScreen(),
                            durationMs: 0,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 16.sp, color: Colors.black87),
                          SizedBox(width: 8.w),
                          Text(
                            "Customize Your CV",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            
            // Bottom Buttons
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: const BorderSide(color: Colors.black87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Next action, save resume, go to final screen, etc.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/models/resume_data.dart';
import 'package:truejobs/resume_sections/templates/template_one.dart';
import 'package:truejobs/resume_sections/templates/template_two.dart';
import 'package:truejobs/resume_sections/templates/template_three.dart';
import 'package:truejobs/resume_sections/templates/template_four.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/resume_sections/experienced_professional/cv_preview_screen.dart';

class TemplatePreviewDialog extends StatelessWidget {
  final int templateId;
  final ResumeData resumeData;

  const TemplatePreviewDialog({
    super.key,
    required this.templateId,
    required this.resumeData,
  });

  Widget _buildTemplateWidget() {
    switch (templateId) {
      case 2:
        return TemplateTwo(data: resumeData);
      case 3:
        return TemplateThree(data: resumeData);
      case 4:
        return TemplateFour(data: resumeData);
      case 1:
      default:
        return TemplateOne(data: resumeData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit barrier color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Template Preview
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
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
            ),
            
            // "Use template" button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: CvPreviewScreen(templateId: templateId),
                        durationMs: 0,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5B824), // Yellow gold color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Use template',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Close button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 24.sp,
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

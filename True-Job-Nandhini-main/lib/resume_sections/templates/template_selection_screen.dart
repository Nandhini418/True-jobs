import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/models/resume_data.dart';
import 'package:truejobs/resume_sections/templates/template_one.dart';
import 'package:truejobs/resume_sections/templates/template_two.dart';
import 'package:truejobs/resume_sections/templates/template_three.dart';
import 'package:truejobs/resume_sections/templates/template_four.dart';
import 'package:truejobs/resume_sections/templates/template_preview_dialog.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  // We'll show multiple instances of the template for the grid.
  // In a real app, this would be a list of different template widgets.
  final List<Map<String, dynamic>> _templates = [
    {"id": 1, "isRecommended": true},
    {"id": 2, "isRecommended": true},
    {"id": 3, "isRecommended": true},
    {"id": 4, "isRecommended": false},
  ];

  void _openTemplatePreview(int templateId) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return TemplatePreviewDialog(
          templateId: templateId,
          resumeData: ResumeData.globalData,
        );
      },
    );
  }

  Widget _buildTemplateWidget(int templateId) {
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "Best templates for\nExperienced",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "You can always change your\ntemplate later.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.filter_list, size: 16.sp),
                    label: Text("Filter", style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: GridView.builder(
                  itemCount: _templates.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 1 / 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final tpl = _templates[index];
                    return GestureDetector(
                      onTap: () => _openTemplatePreview(tpl['id']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Stack(
                            children: [
                              // Scaled down real widget for thumbnail
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      // Provide a fixed logical size for the template to render before scaling down
                                      width: 400,
                                      height: 400 * 1.414,
                                      child: _buildTemplateWidget(tpl['id']),
                                    ),
                                  ),
                                ),
                              ),
                              // Recommended Badge
                              if (tpl['isRecommended'])
                                Positioned(
                                  bottom: 12.h,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4DB6AC), // Teal/Cyan
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        "RECOMMENDED",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

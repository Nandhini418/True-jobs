import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/resume_sections/experienced_professional/certification_screen.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/resume_sections/experienced_professional/select_skills_screen.dart';
import 'package:truejobs/models/resume_data.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  List<String> _selectedSkills = [];

  final List<String> _availableSkills = [
    "UI Design", "UX Design", "User Research", "Wireframing",
    "Prototyping", "Figma", "Design Systems", "Responsive Design",
    "Interaction Design", "Visual Design", "Usability Testing",
    "User Flows", "Information Architecture", "Typography",
    "Color Theory", "Mobile App Design", "Web Design", "UX Writing"
  ];

  void _openSkillSelection() async {
    final result = await Navigator.push(
      context,
      SmoothPageRoute(
        child: SelectSkillsScreen(
          availableSkills: _availableSkills,
          initialSelected: _selectedSkills,
        ),
        durationMs: 0,
      ),
    );

    if (result != null && result is List<String>) {
      setState(() {
        _selectedSkills = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  top: 1.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    // Top Image
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/skills.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.lightbulb_outline, size: 48.sp, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "What are your skills ?",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add relevant skills",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF353535),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    
                    // Skills Input Area
                    _buildSkillsInputArea(),
                    
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "You can choose maximum 10 skills",
                        style: TextStyle(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsInputArea() {
    return GestureDetector(
      onTap: _openSkillSelection,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _selectedSkills.isEmpty ? null : 'Skills',
          labelStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
        ),
        child: _selectedSkills.isEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Skills",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 24.sp),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _selectedSkills.map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0EBFF),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSkills.remove(skill);
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 14.sp,
                                color: Color(0xFFAA1E1E),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Type to search skill",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: const Color(0xFF272727),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ResumeData.globalData = ResumeData.globalData.copyWith(
                  skills: _selectedSkills,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const CertificationScreen(),
                    durationMs: 0,
                  ),
                );
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
                'Submit',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


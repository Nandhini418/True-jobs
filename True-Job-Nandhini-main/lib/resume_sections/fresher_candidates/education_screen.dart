import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/models/resume_data.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/resume_sections/fresher_candidates/skills_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final List<EducationEntry> _educationEntries = [EducationEntry()];

  @override
  void dispose() {
    for (var entry in _educationEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEducation() {
    setState(() {
      _educationEntries.add(EducationEntry());
    });
  }

  void _removeEducation(int index) {
    setState(() {
      _educationEntries[index].dispose();
      _educationEntries.removeAt(index);
    });
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Image
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/education.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.school_outlined, size: 48.sp, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Add Education",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add your Educational Details",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF353535),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    
                    ...List.generate(_educationEntries.length, (index) {
                      return _buildEducationCard(index);
                    }),

                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: _addEducation,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: const Color(0xFF255EC7), // Dark blue border
                          strokeWidth: 1.w,
                          dashPattern: const <double>[2, 2],
                          radius: Radius.circular(24.r),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                color: const Color(0xFF0F99DE),
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Add Another Education",
                                style: TextStyle(
                                  color: const Color(0xFF0F99DE),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
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

  Widget _buildEducationCard(int index) {
    final entry = _educationEntries[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF153885)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11.r),
                topRight: Radius.circular(11.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Education ${index + 1}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_educationEntries.length > 1)
                  GestureDetector(
                    onTap: () => _removeEducation(index),
                    child: Icon(Icons.delete, color: Colors.white, size: 20.sp),
                  ),
              ],
            ),
          ),
          
          // Form Fields
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Course / Degree", "", controller: entry.courseCtrl),
                _buildTextField("School / University", "", controller: entry.schoolCtrl),
                _buildTextField("Grade / Score", "", controller: entry.gradeCtrl),
                _buildTextField("Year of passing", "", controller: entry.yearCtrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 40.h,
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.black87, fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13.sp),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: const Color(0xFFE0E0E0), width: 1.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.w),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
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
                List<Education> eduList = [];
                for (var entry in _educationEntries) {
                  if (entry.courseCtrl.text.isNotEmpty || entry.schoolCtrl.text.isNotEmpty) {
                    eduList.add(Education(
                      degree: entry.courseCtrl.text,
                      institution: entry.schoolCtrl.text,
                      year: entry.yearCtrl.text,
                    ));
                  }
                }
                
                ResumeData.globalData = ResumeData.globalData.copyWith(
                  education: eduList.isNotEmpty ? eduList : null,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const SkillsScreen(),
                    durationMs: 0,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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

class EducationEntry {
  final TextEditingController courseCtrl = TextEditingController();
  final TextEditingController schoolCtrl = TextEditingController();
  final TextEditingController gradeCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController();

  void dispose() {
    courseCtrl.dispose();
    schoolCtrl.dispose();
    gradeCtrl.dispose();
    yearCtrl.dispose();
  }
}

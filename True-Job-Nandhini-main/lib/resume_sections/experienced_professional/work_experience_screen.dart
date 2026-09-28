import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/resume_sections/experienced_professional/education_info.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/models/resume_data.dart' as model;

class WorkExperienceScreen extends StatefulWidget {
  const WorkExperienceScreen({super.key});

  @override
  State<WorkExperienceScreen> createState() => _WorkExperienceScreenState();
}

class WorkExperienceModel {
  final TextEditingController companyNameCtrl = TextEditingController();
  final TextEditingController jobTitleCtrl = TextEditingController();
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();
  final TextEditingController detailsCtrl = TextEditingController();

  void dispose() {
    companyNameCtrl.dispose();
    jobTitleCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    detailsCtrl.dispose();
  }
}

class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
  List<WorkExperienceModel> _experiences = [WorkExperienceModel()];

  void _addExperience() {
    setState(() {
      _experiences.add(WorkExperienceModel());
    });
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences[index].dispose();
      _experiences.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var exp in _experiences) {
      exp.dispose();
    }
    super.dispose();
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
                        'assets/resume_images/experience/experience.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.work_outline, size: 48.sp, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Work Experience",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add your work experience",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF353535),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    
                    // List of experiences
                    ...List.generate(_experiences.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _buildExperienceCard(index),
                      );
                    }),
                    
                    // Add Button
                    Center(
                      child: GestureDetector(
                        onTap: _addExperience,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF153885)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 18.sp),
                              SizedBox(width: 4.w),
                              Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    
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

  Widget _buildExperienceCard(int index) {
    return Container(
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
                  "Experience ${index + 1}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeExperience(index),
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
                _buildTextField("Company name", "Enter Company Name", _experiences[index].companyNameCtrl),
                _buildTextField("Job Title", "Enter Job Title", _experiences[index].jobTitleCtrl),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Start Date", "DD/MM/YYYY", _experiences[index].startDateCtrl)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTextField("End Date", "DD/MM/YYYY", _experiences[index].endDateCtrl)),
                  ],
                ),
                _buildDetailsField("Details", "Write about your experience", _experiences[index].detailsCtrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
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

  Widget _buildDetailsField(String label, String hint, TextEditingController controller) {
    return Column(
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
        TextField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(color: Colors.black87, fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13.sp),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
      ],
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
                final exps = _experiences.map((e) {
                  final start = e.startDateCtrl.text;
                  final end = e.endDateCtrl.text;
                  final duration = [start, end].where((s) => s.isNotEmpty).join(' - ');
                  return model.Experience(
                    jobTitle: e.jobTitleCtrl.text,
                    company: e.companyNameCtrl.text,
                    duration: duration,
                    description: e.detailsCtrl.text,
                  );
                }).toList();

                model.ResumeData.globalData = model.ResumeData.globalData.copyWith(
                  experience: exps,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const EducationInfo(),
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

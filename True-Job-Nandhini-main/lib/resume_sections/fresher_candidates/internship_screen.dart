import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:truejobs/resume_sections/fresher_candidates/add_internship_screen.dart';
import 'package:truejobs/resume_sections/fresher_candidates/projects_screen.dart';
import 'package:truejobs/models/resume_data.dart' as model;

class InternshipScreen extends StatefulWidget {
  const InternshipScreen({super.key});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  final List<InternshipModel> _internships = [];

  void _openAddInternshipScreen([int? indexToEdit]) async {
    final result = await Navigator.push(
      context,
      SmoothPageRoute(
        child: AddInternshipScreen(
          initialData: indexToEdit != null ? _internships[indexToEdit] : null,
        ),
        durationMs: 0,
      ),
    );

    if (result != null && result is InternshipModel) {
      setState(() {
        if (indexToEdit != null) {
          _internships[indexToEdit] = result;
        } else {
          _internships.add(result);
        }
      });
    }
  }

  void _removeInternship(int index) {
    setState(() {
      _internships.removeAt(index);
    });
  }

  void _navigateToNext() {
    // Map internships to Experience model
    final exps = _internships.map((i) {
      return model.Experience(
        jobTitle: i.role,
        company: i.company,
        duration: "${i.startDate} - ${i.endDate}",
        description: i.responsibilities,
      );
    }).toList();

    model.ResumeData.globalData = model.ResumeData.globalData.copyWith(
      experience: exps,
    );

    Navigator.push(
      context,
      SmoothPageRoute(
        child: const ProjectsScreen(),
        durationMs: 0,
      ),
    );
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
                    // Header Image & Title
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/internship.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.business_center,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Internship/ Training",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add your Internship or training details.\n( Optional )",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // List of internships
                    ...List.generate(_internships.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _buildInternshipCard(index),
                      );
                    }),

                    if (_internships.length < 5) ...[
                      GestureDetector(
                        onTap: () => _openAddInternshipScreen(),
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: const Color(0xFF0F99DE),
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
                                  _internships.isEmpty ? "Add Internship" : "Add Another Internship", // Match design typo initially
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
                      SizedBox(height: 12.h),
                      if (_internships.isEmpty)
                        GestureDetector(
                          onTap: _navigateToNext,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Text(
                              "Skip for now",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
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

  Widget _buildInternshipCard(int index) {
    final internship = _internships[index];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB7B7B7), width: 1.w),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      internship.role,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      internship.company,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAddInternshipScreen(index),
                    child: Icon(
                      Icons.edit,
                      color: const Color(0xFF0288D1),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => _removeInternship(index),
                    child: Icon(
                      Icons.delete,
                      color: const Color(0xFFD32F2F),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14.sp, color: Colors.black54),
              SizedBox(width: 4.w),
              Text(
                "${internship.startDate}     ${internship.endDate}",
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.black54),
              SizedBox(width: 4.w),
              Text(
                internship.location,
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            internship.responsibilities,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF616161),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
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
              onPressed: _navigateToNext,
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
                _internships.isEmpty ? 'Submit' : 'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

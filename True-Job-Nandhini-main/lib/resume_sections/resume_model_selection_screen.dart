import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/resume_sections/experienced_professional/personal_info_screen.dart';
import 'package:truejobs/resume_sections/fresher_candidates/fresher_candidate_info_screen.dart';
import 'package:truejobs/utils/smooth_page_route.dart';

class ResumeModelSelectionScreen extends StatefulWidget {
  const ResumeModelSelectionScreen({super.key});

  @override
  State<ResumeModelSelectionScreen> createState() =>
      _ResumeModelSelectionScreenState();
}

class _ResumeModelSelectionScreenState
    extends State<ResumeModelSelectionScreen> {
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Experienced Professional',
      'subtitle': '2+ Years Experience',
      'image': 'assets/resume_images/experience_professional.png',
    },
    {
      'title': 'Fresher',
      'subtitle': '0-1 Years Experience',
      'image': 'assets/resume_images/fresher.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                  top: 12.h,
                  bottom: 12.h + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What type of CV do\nyou need?',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "We'll customize your CV experience\nfor you.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF353535),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ...List.generate(
                      _options.length,
                      (index) => _buildOptionCard(index),
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

  Widget _buildOptionCard(int index) {
    final bool isSelected = _selectedIndex == index;
    final option = _options[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 22.r),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Color(0xFF353535) : Color(0xFFEEEEEE),
            width: isSelected ? 0.8.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: const BoxDecoration(
                color: Color(0xFFECEDFB),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Image.asset(option['image'], fit: BoxFit.contain),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF353535),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    option['subtitle'],
                    style: TextStyle(fontSize: 12.sp, color: Color(0xFF6E6E6E)),
                  ),
                ],
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
                side: BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF272727),
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
                if (_selectedIndex != -1) {
                  final option = _options[_selectedIndex];
                  if (option['title'] == 'Experienced Professional') {
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: const PersonalInfoScreen(),
                        durationMs: 0,
                      ),
                    );
                  } else if (option['title'] == 'Fresher') {
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: const FresherCandidateInfoScreen(),
                        durationMs: 0,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a CV type')),
                  );
                }
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

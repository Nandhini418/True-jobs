import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/resume_sections/experienced_professional/select_languages_screen.dart';
import 'package:truejobs/resume_sections/experienced_professional/additional_information.dart';
import 'package:truejobs/models/resume_data.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  List<String> _selectedLanguages = [];

  void _openSelectLanguagesScreen() async {
    final result = await Navigator.push(
      context,
      SmoothPageRoute(
        child: SelectLanguagesScreen(
          initialSelected: _selectedLanguages,
        ),
        durationMs: 0,
      ),
    );

    if (result != null && result is List<String>) {
      setState(() {
        _selectedLanguages = result;
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Image & Title
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/language.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.language,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "languages you Know",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add languages you know",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Dropdown Container
                    GestureDetector(
                      onTap: _openSelectLanguagesScreen,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _selectedLanguages.isEmpty ? null : 'Languages',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedLanguages.isEmpty
                                    ? "Select"
                                    : _selectedLanguages.join(', '),
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
              onPressed: () {
                ResumeData.globalData = ResumeData.globalData.copyWith(
                  languages: _selectedLanguages.map((lang) => {"name": lang, "level": "Proficient"}).toList(),
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const AdditionalInformationScreen(),
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
                _selectedLanguages.isEmpty ? 'Submit' : 'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class InterviewDetailsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const InterviewDetailsScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),
                  // Back header link
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(5.r),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'Interview details',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Candidate Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000), // #0000000F
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x0A000000), // #0000000A
                          offset: Offset(0, 0),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28.r,
                                backgroundColor: const Color(0xFFE8F1FF),
                                child: Icon(Icons.person, color: const Color(0xFF0D6EFD), size: 28.sp),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rahul Kumar',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.dynamicText,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'UI/UX Designer',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13.sp,
                                        color: const Color(0xFF414141),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      'Applied 5 Days Ago',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11.sp,
                                        color: const Color(0xFF797979),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCACACA), thickness: 0.3,),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(Icons.assignment_outlined, 'Resume'),
                              _buildActionButton(Icons.business_center_outlined, 'Portfolio'),
                              _buildActionButton(Icons.call_outlined, 'Call'),
                              _buildActionButton(Icons.mail_outline, 'Mail'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Interview Information Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000), // #0000000F
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x0A000000), // #0000000A
                          offset: Offset(0, 0),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interview Information',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoRow(Icons.calendar_today_outlined, '15 Jul 2026 ( Wednesday )'),
                        SizedBox(height: 16.h),
                        _buildInfoRow(Icons.access_time, '10:30 AM - 11:00 AM'),
                        SizedBox(height: 16.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.people_outline, size: 18.sp, color: const Color(0x66000000)),
                            SizedBox(width: 11.w),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Interviewer',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.sp,
                                      color: AppColors.dynamicText,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Harish G',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14.sp,
                                          color: AppColors.dynamicText,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppColors.dynamicText),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.videocam_outlined, size: 18.sp, color: const Color(0x66000000)),
                            SizedBox(width: 11.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Google Meet',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.sp,
                                      color: AppColors.dynamicText,
                                    ),
                                  ),
                                  Text(
                                    'Https://Meet.Google.Com/Abc-Defg-Hij',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp,
                                      color: const Color(0xFFA4A4A4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.copy_outlined, size: 18.sp, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Interview Information (Notes)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000), // #0000000F
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x0A000000), // #0000000A
                          offset: Offset(0, 0),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interview Information',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Candidate has 2 years of experience in UI/UX Design. Strong in Figma and prototyping.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            color: AppColors.secondary_color,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  
                  // Bottom Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Reschedule',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: const BorderSide(color: Color(0xFFC12600), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                          ),
                          child: Text(
                            'Cancel Interview',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDA1418),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(9.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18.sp),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11.sp,
            color: AppColors.dynamicText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: const Color(0x66000000)),
        SizedBox(width: 11.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: AppColors.dynamicText,
            ),
          ),
        ),
      ],
    );
  }
}

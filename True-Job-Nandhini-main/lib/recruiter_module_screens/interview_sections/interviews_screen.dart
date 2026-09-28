import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'schedule_interview_screen.dart';

class InterviewsScreen extends StatelessWidget {
  const InterviewsScreen({super.key});

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
                  SizedBox(height: 24.h),
                  // Header Row
                  Text(
                    'Interviews',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Stats Grid (2x2)
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('0', 'Total Interviews', const Color(0xFF055BF2))),
                      SizedBox(width: 11.w),
                      Expanded(child: _buildStatCard('0', "Today's Interviews", const Color(0xFF35CA64))),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('0', 'Upcoming', const Color(0xFFEDB703))),
                      SizedBox(width: 11.w),
                      Expanded(child: _buildStatCard('0', "Completed", const Color(0xFF6600CC))),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Search and Filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by candidate',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              color: Color(0xFFA6A6A6),
                            ),
                            prefixIcon: Icon(Icons.search, color: Color(0xFFA6A6A6)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28.r),
                              borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28.r),
                              borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28.r),
                              borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 11.w),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(color: const Color(0xFFE6E6E6)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28.r),
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_alt_outlined, color: Color(0xFF676767), size: 18.w),
                                SizedBox(width: 4.w),
                                Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF4E4E4E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Interview List Placeholder
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h, bottom: 40.h),
                      child: Text(
                        'No interview scheduled',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          color: AppColors.dynamicSubtitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 7.w),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleInterviewScreen(
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Schedule Interview',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String text, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // #00000014
            offset: Offset(0, 8),
            blurRadius: 16,
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Color(0xFFECECEC),
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                color: Color(0xFFDEDEDE), width: 0.3
              )
            ),
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.dynamicText,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

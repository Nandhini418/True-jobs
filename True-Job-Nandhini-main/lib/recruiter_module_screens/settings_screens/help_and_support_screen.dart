import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/help_articles/job_posting_topics_screen.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String fontFamily = 'Poppins';

    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          const CustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 28.h),
                  // Header Row "< Help & Support"
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  Text(
                    "We're here to help you with hiring, job postings, subscriptions, billing and everything else.",
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFBFD),
                      borderRadius: BorderRadius.circular(7.r),
                      border: Border.all(color: const Color(0xFFE4E4E4)),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for help articles, FAQs or support...',
                        hintStyle: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 13.sp,
                          color: AppColors.secondary_color,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 13.h,
                        ),
                        suffixIcon: Icon(Icons.search, color: const Color(0xFFBDBDBD), size: 18.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Quick Help Title
                  Text(
                    'Quick Help',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Quick Help Grid
                  Wrap(
                    spacing: 11.w,
                    runSpacing: 11.w,
                    children: [
                      _buildQuickHelpCard(
                        'Job Posting', 'assets/settings_icon/job_posting.png',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const JobPostingTopicsScreen()));
                        }
                      ),
                      _buildQuickHelpCard('Candidate Management', 'assets/settings_icon/candidate_management.png'),
                      _buildQuickHelpCard('Subscription & Billing', 'assets/settings_icon/subscription.png'),
                      _buildQuickHelpCard('Employer Account', 'assets/settings_icon/employer_account.png'),
                      _buildQuickHelpCard('Technical Support', 'assets/settings_icon/technical_support.png'),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Contact Us Title
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Email Card
                  _buildContactCard(
                    context: context,
                    icon: Icons.email,
                    iconBgColor: const Color(0xFFEAF2FD),
                    iconColor: const Color(0xFF0962F4),
                    title: 'Email Address',
                    value: 'support@truejobs.com',
                    bottomText: 'Response Time Within 24 Hours',
                  ),

                  // Phone Card
                  _buildContactCard(
                    context: context,
                    icon: Icons.phone,
                    iconBgColor: const Color(0xFFEDFBEF),
                    iconColor: const Color(0xFF41AF5B),
                    title: 'Phone Number',
                    value: '+91 85907 94021',
                    bottomText: 'Working Hours Mon-Sat, 9:00 AM - 6:00 PM IST',
                  ),

                  // Live Chat Card
                  Container(
                    margin: EdgeInsets.only(bottom: 18.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF7F7F7),
                          Color(0xFFFFFFFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(7.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset('assets/settings_icon/comment.png', height: 24.h,),
                            ),
                            SizedBox(width: 11.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Chat',
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.dynamicText,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Chat with our support team for instant assistance.',
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: 13.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  Row(
                                    children: [
                                      Container(
                                        width: 7.w,
                                        height: 7.w,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF30B362),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        'Online',
                                        style: TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: 11.sp,
                                          color: const Color(0xFF30B362),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          height: 42.h,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0859ED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Start Chat',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Still Need Help
                  Container(
                    margin: EdgeInsets.only(bottom: 40.h),
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FD),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFCDDDFE),
                          radius: 22.r,
                          child: Image.asset('assets/settings_icon/help.png', height: 28.h,),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Still Need Help ?',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dynamicText,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'Having trouble accessing your account or posting jobs? Our support team is available to help you resolve critical issues as quickly as possible.',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF055BF2), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                          ),
                          child: Text(
                            'View FAQs',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 11.sp,
                              color: const Color(0xFF055BF2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpCard(
      String title,
      String imagePath,
      {VoidCallback? onTap}
      ) {
    // We aim for 3 cards per row, calculating width based on ScreenUtil
    final double cardWidth = (1.sw - 36.w - 22.w) / 3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardWidth,
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.w,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0xFFC0D7FF),
            ],
            stops: [
              0.1952,
              0.7,
              1.0,
            ],
            begin: Alignment(-0.84, -0.54),
            end: Alignment(0.84, 0.54),
          ),
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.dynamicText,
                height: 1.2,
              ),
            ),

            Image.asset(
              imagePath,
              width: 25.w,
              height: 25.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String value,
    required String bottomText,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7F7F7),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dynamicText,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title copied to clipboard!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(Icons.copy_outlined, color: const Color(0xFF000000), size: 18.sp),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              bottomText,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

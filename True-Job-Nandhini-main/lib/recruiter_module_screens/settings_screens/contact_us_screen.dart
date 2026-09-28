import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/faqs_screen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

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
                  SizedBox(height: 28.h),
                  // Header Row "< Contact Us"
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'Contact Us',
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
                  SizedBox(height: 22.h),

                  Text(
                    'Get in Touch',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 11.h),

                  _buildContactOption(
                    icon: Icons.email_outlined,
                    iconBgColor: const Color(0xFFE5F5E0),
                    title: 'Email Us',
                    subtitle: 'Support@employeshub.com',
                  ),
                  _buildContactOption(
                    icon: Icons.phone_outlined,
                    iconBgColor: const Color(0xFFECEAFC),
                    title: 'Call Us',
                    subtitle: '+91 98765 43210',
                  ),
                  _buildContactOption(
                    icon: Icons.chat_bubble_outline,
                    iconBgColor: const Color(0xFFE9F0FD),
                    title: 'Live chat',
                    subtitle: 'Chat with our support team',
                  ),

                  SizedBox(height: 22.h),

                  Text(
                    'Quick Help',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 11.h),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FE),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3E4FC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.lightbulb_outline, color: const Color(0xFF6600cc), size: 14.sp),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Frequently Asked Question',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.dynamicText,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Find answers to common question',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqsScreen()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2B6D8)),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Text(
                              'View FAQs',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.sp,
                                color: const Color(0xFFE225BF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  Text(
                    'Send Us a Message',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 11.h),

                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFDFE),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E2E2)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(controller: _nameController, label: 'Your Name *', icon: Icons.person_outline, hintText: 'Enter your name'),
                        SizedBox(height: 14.h),
                        _buildTextField(controller: _emailController, label: 'Email Address *', icon: Icons.person_outline, hintText: 'Enter your email'),
                        SizedBox(height: 14.h),
                        _buildTextField(controller: _subjectController, label: 'Subject *', icon: Icons.person_outline, hintText: 'Enter your subject'),
                        SizedBox(height: 14.h),
                        _buildTextField(controller: _messageController, label: 'Your Message *', icon: Icons.person_outline, hintText: 'Type your message here...', maxLines: 2),
                        
                        SizedBox(height: 22.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Handle send message
                            },
                            icon: const Icon(Icons.send_outlined, color: Colors.white),
                            label: Text(
                              'Send Message',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFE),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: AppColors.dynamicText, size: 18.sp),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.dynamicText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.dynamicText, size: 18.sp),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDFE),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 11.h : 0),
            child: Icon(icon, color: const Color(0x55000000), size: 18.sp),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: RichText(
                      text: TextSpan(
                        text: label.replaceAll(' *', ''),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                        children: [
                          if (label.contains('*'))
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(color: Color(0xFFFF383C)),
                            ),
                        ],
                      ),
                    ),
                  ),
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    color: AppColors.dynamicText,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: AppColors.dynamicSubtitle,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 7.h),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String fontFamily = 'Poppins';

    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      appBar: AppBar(
        backgroundColor: AppColors.dynamicBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 16.w, color: AppColors.dynamicText),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.dynamicText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  SizedBox(height: 18.h),
                  
                  // Icon + True Jobs
                  Image.asset('assets/images/header_logo.png', width: 100.w),
                  SizedBox(height: 16.h),
                  

                  Text(
                    'Privacy Policy for True Jobs',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildParagraph(fontFamily,
                      'Welcome to True Jobs. Your privacy is important to us. This Privacy Policy explains how we collect, use, and share your personal information when you use True Jobs app, the opportunities and our services.\n\nBy using True Jobs, you agree to the collection and use of information in accordance with this Privacy Policy.'),

                  _buildSectionTitle(fontFamily, '1. Information We Collect'),
                  _buildParagraph(fontFamily, 'We may collect the following information when you use our platform:'),
                  _buildSubSectionTitle(fontFamily, 'Personal Information'),
                  _buildBulletPoints(fontFamily, [
                    'Full Name',
                    'Mobile Number',
                    'Email Address',
                    'Profile Photo',
                    'Location Data (Optional)',
                    'Gender (Optional)',
                    'Date of Birth',
                    'Educational Qualifications',
                    'Work Experience',
                    'Preferred Job Location',
                    'Resume/CV',
                    'Government ID (for employer verification)',
                  ]),
                  _buildSubSectionTitle(fontFamily, 'Employer Information'),
                  _buildParagraph(fontFamily, 'For employers on True Jobs:'),
                  _buildBulletPoints(fontFamily, [
                    'Company Name',
                    'Company Address',
                    'Contact Person',
                    'Business Email',
                    'Phone Number',
                    'Company Logo',
                    'Job Listings',
                  ]),

                  _buildSectionTitle(fontFamily, '2. How We Use Your Information'),
                  _buildParagraph(fontFamily, 'We use your information to:'),
                  _buildBulletPoints(fontFamily, [
                    'Create and manage your account.',
                    'Build your professional profile.',
                    'Help employers discover suitable candidates.',
                    'Enable you to apply for jobs.',
                    'Notify you about job opportunities.',
                    'Verify employer credentials and accounts.',
                    'Offer communications and support services.',
                    'Provide customer support.',
                    'Prevent fraud and unauthorized activities.',
                    'Comply with legal obligations.',
                  ]),

                  _buildSectionTitle(fontFamily, '3. Resume and Profile Visibility'),
                  _buildParagraph(fontFamily,
                      'Your profile and resume are visible to registered employers on our platform when you apply for jobs or if you choose to make them public.\n\nYou may edit or update your visibility settings within your account at any time.'),

                  _buildSectionTitle(fontFamily, '4. Job Applications'),
                  _buildParagraph(fontFamily,
                      'When you apply for a job through True Jobs, your application details, resume, and relevant profile information will be shared with the respective employer or recruiter.'),

                  _buildSectionTitle(fontFamily, '5. Data Sharing'),
                  _buildParagraph(fontFamily, 'We do not sell your personal information.\nWe may share your data with:'),
                  _buildBulletPoints(fontFamily, [
                    'Potential employers (when you apply)',
                    'Service providers helping us operate our app',
                    'Law enforcement or regulatory authorities when required by law',
                    'Third-party partners providing integrated services',
                  ]),
                  
                  _buildSectionTitle(fontFamily, '6. Data Security'),
                  _buildParagraph(fontFamily, 'We implement reasonable administrative, technical, and physical security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.\nWhile we strive to safeguard your data, no method of electronic transmission or storage is completely secure.'),

                  _buildSectionTitle(fontFamily, '7. Cookies and Analytics'),
                  _buildParagraph(fontFamily, 'Our app may use cookies and similar tracking technologies to:'),
                  _buildBulletPoints(fontFamily, [
                    'Improve user experience',
                    'Remember your preferences',
                    'Analyze app usage',
                    'Monitor performance',
                    'Enhance security',
                  ]),
                  _buildParagraph(fontFamily, 'You may disable cookies through your device settings where applicable.'),

                  _buildSectionTitle(fontFamily, '8. Third-Party Services'),
                  _buildParagraph(fontFamily, 'True Jobs may integrate with various third-party services such as:'),
                  _buildBulletPoints(fontFamily, [
                    'Google Sign-In',
                    'Apple Sign-In (where available)',
                    'SMS/OTP verification providers',
                    'Cloud hosting services',
                    'Payment gateways (if premium services are enabled)',
                    'Analytics and crash reporting tools',
                  ]),
                  _buildParagraph(fontFamily, 'These services have their own privacy policies.'),

                  _buildSectionTitle(fontFamily, '9. User Rights'),
                  _buildParagraph(fontFamily, 'You have the right to:'),
                  _buildBulletPoints(fontFamily, [
                    'Access your personal information',
                    'Update your profile',
                    'Delete your account',
                    'Request correction of inaccurate information',
                    'Withdraw consent where applicable',
                    'Request deletion of your personal data, subject to legal requirements',
                  ]),

                  _buildSectionTitle(fontFamily, '10. Data Retention'),
                  _buildParagraph(fontFamily, 'We retain your personal information for as long as necessary to provide our services, comply with legal obligations, resolve disputes, and enforce our agreements.\nUpon account deletion, your information will be anonymized or permanently deleted.'),

                  _buildSectionTitle(fontFamily, '11. Children\'s Privacy'),
                  _buildParagraph(fontFamily, 'True Jobs is intended for individuals who are at least 18 years of age or the legal working age in their jurisdiction. We do not knowingly collect personal information from children.'),

                  _buildSectionTitle(fontFamily, '12. Changes to This Privacy Policy'),
                  _buildParagraph(fontFamily, 'We may update this Privacy Policy from time to time. Any changes will be posted within the app, and the "Effective Date" will be updated. We encourage you to review this page periodically.'),

                  _buildSectionTitle(fontFamily, '13. Contact Us'),
                  _buildParagraph(fontFamily, 'If you have any questions or concerns regarding this Privacy Policy, please contact our True Jobs Support:\nEmail: support@truejobs.in\nWebsite: www.truejobs.in\n\nThank you for trusting True Jobs as your career partner.'),

                  SizedBox(height: 40.h),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String fontFamily, String title) {
    return Padding(
      padding: EdgeInsets.only(top: 22.h, bottom: 7.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
  
  Widget _buildSubSectionTitle(String fontFamily, String title) {
    return Padding(
      padding: EdgeInsets.only(top: 11.h, bottom: 7.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String fontFamily, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.sp,
          color: const Color(0xFF64748B),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoints(String fontFamily, List<String> points) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h, left: 7.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((point) {
          return Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

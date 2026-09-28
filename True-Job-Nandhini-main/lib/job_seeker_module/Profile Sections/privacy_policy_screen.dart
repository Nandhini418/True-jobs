import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.03),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back_ios, color: textColor, size: sw * 0.05),
                  ),
                  SizedBox(width: sw * 0.03),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: textColor,
                      fontSize: sw * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogoRow(sw),
                    SizedBox(height: sw * 0.05),
                    _title(sw, 'Privacy Policy for True Jobs', textColor),
                    SizedBox(height: sw * 0.03),
                    _paragraph(
                      sw,
                      "Welcome to True Jobs. Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and protect your personal information when you use the True Jobs mobile application and website.",
                      subtitleColor,
                    ),
                    _paragraph(
                      sw,
                      "By using True Jobs, you agree to the practices described in this Privacy Policy.",
                      subtitleColor,
                    ),
                    _section(sw, '1. Information We Collect', textColor),
                    _paragraph(sw, "We may collect the following information when you use our platform:", subtitleColor),
                    _subHeading(sw, 'Personal Information', textColor),
                    ..._bullets(sw, [
                      'Full Name',
                      'Mobile Number',
                      'Email Address',
                      'Profile Photo',
                      'Date of Birth (optional)',
                      'Gender (optional)',
                      'Address/Location',
                      'Educational Qualifications',
                      'Work Experience',
                      'Skills and Certifications',
                      'Resume/CV',
                      'Government ID (only if required for verification)',
                    ], subtitleColor),
                    _section(sw, '2. How We Use Your Information', textColor),
                    _paragraph(sw, "We use your information to:", subtitleColor),
                    ..._bullets(sw, [
                      'Create and manage your account.',
                      'Build your professional profile.',
                      'Help employers discover suitable candidates.',
                      'Enable users to apply for jobs.',
                      'Notify users about job opportunities.',
                      'Verify employer and job seeker accounts.',
                      'Improve our services and user experience.',
                      'Provide customer support.',
                      'Prevent fraud and unauthorized activities.',
                      'Comply with legal obligations.',
                    ], subtitleColor),
                    _section(sw, '3. Resume and Profile Visibility', textColor),
                    _paragraph(
                      sw,
                      "Your profile and resume may be visible to verified employers and recruiters based on your privacy settings.",
                      subtitleColor,
                    ),
                    _paragraph(sw, "You may edit, update, or remove your profile information at any time.", subtitleColor),
                    _section(sw, '4. Job Applications', textColor),
                    _paragraph(
                      sw,
                      "When you apply for a job through True Jobs, your application details, resume, and relevant profile information will be shared with the respective employer or recruiter.",
                      subtitleColor,
                    ),
                    _section(sw, '5. Data Sharing', textColor),
                    _paragraph(sw, "We do not sell your personal information.", subtitleColor),
                    _paragraph(sw, "We may share information with:", subtitleColor),
                    ..._bullets(sw, [
                      'Verified employers and recruiters',
                      'Service providers supporting our platform',
                      'Government or legal authorities when required by law',
                      'Business partners providing integrated services',
                    ], subtitleColor),
                    _section(sw, '6. Data Security', textColor),
                    _paragraph(
                      sw,
                      "We implement reasonable administrative, technical, and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.",
                      subtitleColor,
                    ),
                    _paragraph(
                      sw,
                      "While we strive to safeguard your data, no method of electronic transmission or storage is completely secure.",
                      subtitleColor,
                    ),
                    _section(sw, '7. Cookies and Analytics', textColor),
                    _paragraph(sw, "Our website and application may use cookies and similar technologies to:", subtitleColor),
                    ..._bullets(sw, [
                      'Improve user experience',
                      'Remember user preferences',
                      'Analyze application usage',
                      'Measure performance',
                      'Enhance security',
                    ], subtitleColor),
                    _paragraph(sw, "Users may disable cookies through browser settings where applicable.", subtitleColor),
                    _section(sw, '8. Third-Party Services', textColor),
                    _paragraph(sw, "True Jobs may integrate with trusted third-party services such as:", subtitleColor),
                    ..._bullets(sw, [
                      'Google Sign-In',
                      'Apple Sign-In (where available)',
                      'SMS/OTP verification providers',
                      'Cloud hosting services',
                      'Payment gateways (if premium services are offered)',
                      'Analytics and crash reporting tools',
                    ], subtitleColor),
                    _paragraph(sw, "These services have their own privacy policies.", subtitleColor),
                    _section(sw, '9. User Rights', textColor),
                    _paragraph(sw, "You have the right to:", subtitleColor),
                    ..._bullets(sw, [
                      'Access your personal information.',
                      'Update your profile.',
                      'Delete your account.',
                      'Request correction of inaccurate information.',
                      'Withdraw consent where applicable.',
                      'Request deletion of your personal data, subject to legal requirements.',
                    ], subtitleColor),
                    _section(sw, '10. Data Retention', textColor),
                    _paragraph(
                      sw,
                      "We retain your information only as long as necessary to provide our services, comply with legal obligations, resolve disputes, and enforce our agreements.",
                      subtitleColor,
                    ),
                    _paragraph(sw, "After account deletion, certain information may be retained where required by law.", subtitleColor),
                    _section(sw, '11. Children\'s Privacy', textColor),
                    _paragraph(
                      sw,
                      "True Jobs is intended for individuals who are at least 18 years of age or the legal working age in their jurisdiction. We do not knowingly collect personal information from children.",
                      subtitleColor,
                    ),
                    _section(sw, '12. Changes to This Privacy Policy', textColor),
                    _paragraph(
                      sw,
                      "We may update this Privacy Policy from time to time. Any changes will be posted within the application and on our website. Continued use of True Jobs after updates constitutes acceptance of the revised policy.",
                      subtitleColor,
                    ),
                    _section(sw, '13. Contact Us', textColor),
                    _paragraph(sw, "If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us:", subtitleColor),
                    _paragraph(sw, "True Jobs Support", subtitleColor, bold: true),
                    _paragraph(sw, "Email: sgsapp20@gmail.com", subtitleColor),
                    _paragraph(sw, "Website: http://www.truejobs.in/", subtitleColor),
                    SizedBox(height: sw * 0.03),
                    _paragraph(sw, "Thank you for trusting True Jobs as your career partner.", subtitleColor),
                    SizedBox(height: sw * 0.06),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoRow(double sw) {
    return Image.asset('assets/header.png',
      height: sw * 0.1,
    );
  }

  Widget _title(double sw, String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold, color: textColor),
    );
  }

  Widget _section(double sw, String text, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(top: sw * 0.05, bottom: sw * 0.02),
      child: Text(
        text,
        style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _subHeading(double sw, String text, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(top: sw * 0.02, bottom: sw * 0.01),
      child: Text(
        text,
        style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _paragraph(double sw, String text, Color color, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.02),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: sw * 0.036,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          height: 1.4,
        ),
      ),
    );
  }

  List<Widget> _bullets(double sw, List<String> items, Color color) {
    return items
        .map(
          (item) => Padding(
        padding: EdgeInsets.only(bottom: sw * 0.015, left: sw * 0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ', style: TextStyle(fontSize: sw * 0.036, color: color)),
            Expanded(
              child: Text(
                item,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: sw * 0.036, color: color, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    )
        .toList();
  }
}
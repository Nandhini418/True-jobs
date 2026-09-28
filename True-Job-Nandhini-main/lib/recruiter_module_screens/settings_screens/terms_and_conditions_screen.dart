import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  late Future<Map<String, dynamic>> _termsFuture;

  @override
  void initState() {
    super.initState();
    _termsFuture = fetchTermsAndConditions();
  }

  // Mocking the API call using the provided JSON data
  Future<Map<String, dynamic>> fetchTermsAndConditions() async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "status": "success",
      "data": {
        "Effective Date": "July 2026",
        "metadata": {
          "screen_title": "Terms & Conditions",
          "header_title": "TrueJobs Platform Terms",
          "header_description":
              "Please read these terms carefully before registering or using the Truejobs application and its related services."
        },
        "sections": [
          {
            "order": 1,
            "section_key": "acceptance",
            "title": "1. Acceptance of Terms",
            "content":
                "By downloading, installing, or using the Truejobs app, you agree to comply with and be bound by these Terms and Conditions and our Privacy Policy. If you do not agree to these terms, you should not access or use the app."
          },
          {
            "order": 2,
            "section_key": "eligibility",
            "title": "2. Eligibility and User Accounts",
            "content":
                "You must be at least 18 years of age or the legal working age in your jurisdiction to register and use True Jobs.You are responsible for maintaining the confidentiality of your account credentials.All information provided during registration must be accurate and up to date.You are responsible for all activities conducted through your account."
          },
          {
            "order": 3,
            "section_key": "Responsibilities",
            "title": "3. Job Seeker Responsibilities ",
            "content":
                "As a job seeker, you agree to:Provide accurate profile and resume information.Apply only for genuine employment opportunities.Avoid submitting false, misleading, or fraudulent information.Maintain professional communication with Recuirters."
          },
          {
            "order": 4,
            "section_key": "Responsibilities",
            "title": "4. Recuirter Responsibilities",
            "content":
                " recruiters agree to:Post genuine and lawful job opportunities.Provide accurate job descriptions and company details.Refrain from posting misleading, fraudulent, or discriminatory job listings.Comply with all applicable employment laws."
          },
          {
            "order": 5,
            "section_key": "prohibited_activities",
            "title": "5. Prohibited Activities",
            "content":
                "Users must not:Create fake accounts or impersonate others.Upload harmful, illegal, or offensive content.Misuse another user s information.Attempt unauthorized access to the platform.Distribute spam, malware, or fraudulent job offers.Use True Jobs for unlawful purposes.Violation of these rules may result in account suspension or permanent termination.."
          },
          {
            "order": 6,
            "section_key": "Disclaimer",
            "title": "6. Job Listing Disclaimer",
            "content":
                "True Jobs acts solely as a platform connecting employers and job seekers. We do not guarantee:Employment offers,Candidate selection,Interview invitations,\nSalary negotiations.Employer authenticity beyond available verification processes.Users are encouraged to verify opportunities independently before sharing sensitive information."
          },
          {
            "order": 7,
            "section_key": "Intellectual Property",
            "title": "7. Intellectual Property",
            "content":
                "All content, logos, trademarks, graphics, designs, and software associated with True Jobs are the property of True Jobs or its licensors and may not be copied, reproduced, or distributed without prior written permission."
          },
          {
            "order": 8,
            "section_key": "Account Suspension",
            "title": "8. Account Suspension",
            "content":
                "True Jobs reserves the right to suspend or permanently terminate any account that violates these Terms & Conditions or engages in fraudulent, abusive, or illegal activities."
          },
          {
            "order": 9,
            "section_key": "Liability",
            "title": "9. Limitation of Liability",
            "content":
                "True Jobs shall not be liable for any direct, indirect, incidental, or consequential damages arising from:Job applications or recruitment decisions.\nEmployer or candidate conduct.Loss of employment opportunities.Technical interruptions or service outages.Unauthorized access caused by user negligence."
          },
          {
            "order": 10,
            "section_key": "change to terms",
            "title": "10. Change to Terms",
            "content":
                "We may update these Terms & Conditions from time to time. Continued use of the platform after changes become effective constitutes acceptance of the revised terms."
          },
          {
            "order": 11,
            "section_key": "Law",
            "title": "11. Governing Law",
            "content":
                "These Terms & Conditions shall be governed by and interpreted in accordance with the laws of India. Any disputes shall be subject to the jurisdiction of the competent courts in India."
          },
          {
            "order": 12,
            "section_key": "Contact",
            "title": "12. Contact Us",
            "content":
                "Contact Us For any questions regarding these Terms & Conditions, please contact us:True Jobs SupportEmail: support@truejobs.in , Website: https://truejobs.in/.\nBy using True Jobs, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions."
          }
        ]
      }
    };
  }

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
        title: FutureBuilder<Map<String, dynamic>>(
          future: _termsFuture,
          builder: (context, snapshot) {
            String appBarTitle = 'Terms and conditions';
            if (snapshot.hasData && snapshot.data!['data'] != null) {
              final metadata = snapshot.data!['data']['metadata'];
              if (metadata != null && metadata['screen_title'] != null) {
                appBarTitle = metadata['screen_title'];
              }
            }
            return Text(
              appBarTitle,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.dynamicText,
              ),
            );
          }
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _termsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading terms."));
          } else if (!snapshot.hasData || snapshot.data!['status'] != 'success') {
            return const Center(child: Text("Failed to load terms."));
          }

          final data = snapshot.data!['data'];
          final metadata = data['metadata'] ?? {};
          final effectiveDate = data['Effective Date'];
          final List<dynamic> sections = data['sections'] ?? [];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18.h),
                // Icon + True Jobs
                Image.asset('assets/images/header_logo.png', width: 100.w),
                SizedBox(height: 16.h),

                Text(
                  metadata['header_title'] ?? 'Terms & Conditions',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dynamicText,
                  ),
                ),
                SizedBox(height: 8.h),
                if (effectiveDate != null)
                  _buildParagraph(fontFamily, 'Effective Date: $effectiveDate'),
                if (metadata['header_description'] != null)
                  _buildParagraph(fontFamily, metadata['header_description']),

                ...sections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(fontFamily, section['title'] ?? ''),
                      _buildParagraph(fontFamily, section['content'] ?? ''),
                    ],
                  );
                }).toList(),

                SizedBox(height: 40.h),
              ],
            ),
          );
        },
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
}

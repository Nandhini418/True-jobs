import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                    'About Us',
                    style: TextStyle(color: textColor, fontSize: sw * 0.05, fontWeight: FontWeight.bold),
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
                    _title(sw, 'Welcome to True Jobs', textColor),
                    SizedBox(height: sw * 0.03),
                    _paragraph(
                      sw,
                      "True Jobs is a modern job portal designed to connect talented job seekers with trusted employers across various industries. Our mission is to make the hiring process faster, simpler, and more transparent for everyone.",
                      subtitleColor,
                    ),
                    _paragraph(
                      sw,
                      "Whether you're searching for your first job, planning your next career move, or looking for the right talent to grow your business, True Jobs provides a reliable platform to help you achieve your goals.",
                      subtitleColor,
                    ),
                    _section(sw, 'Our Mission', textColor),
                    _paragraph(
                      sw,
                      "To empower job seekers with meaningful career opportunities while helping employers discover the right talent through a secure, efficient, and user-friendly platform.",
                      subtitleColor,
                    ),
                    _section(sw, 'What We Offer', textColor),
                    ..._bullets(sw, [
                      'Thousands of job opportunities across multiple industries.',
                      'Easy profile creation and resume management.',
                      'Quick and seamless job applications.',
                      'Verified employers and authentic job listings.',
                      'Smart search and filtering options.',
                      'Instant notifications for new job openings.',
                      'Secure communication between employers and candidates.',
                      'A simple and intuitive user experience on both mobile and web.',
                    ], subtitleColor),
                    _section(sw, 'Why Choose True Jobs?', textColor),
                    ..._bullets(sw, [
                      'Trusted and reliable job marketplace.',
                      'User-friendly interface for job seekers and recruiters.',
                      'Fast and secure application process.',
                      'Regularly updated job listings.',
                      'Dedicated customer support.',
                      'Privacy-focused and secure platform.',
                    ], subtitleColor),
                    _section(sw, 'Our Vision', textColor),
                    _paragraph(
                      sw,
                      "To become one of India's most trusted digital employment platforms by connecting millions of job seekers with the right opportunities and enabling businesses to hire the best talent efficiently.",
                      subtitleColor,
                    ),
                    _section(sw, 'Contact Us', textColor),
                    _paragraph(sw, "TRUE JOBS", subtitleColor, bold: true),
                    SizedBox(height: sw * 0.02),
                    _paragraph(sw, "True Jobs Support", subtitleColor, bold: true),
                    _paragraph(sw, "Email: sgsapp20@gmail.com", subtitleColor),
                    _paragraph(sw, "Website: http://www.truejobs.in/", subtitleColor),
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
    return Text(text, style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold, color: textColor));
  }

  Widget _section(double sw, String text, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(top: sw * 0.05, bottom: sw * 0.02),
      child: Text(text, style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.bold, color: textColor)),
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
              child: Text(item, 
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: sw * 0.036, color: color, height: 1.4)),
            ),
          ],
        ),
      ),
    )
        .toList();
  }
}
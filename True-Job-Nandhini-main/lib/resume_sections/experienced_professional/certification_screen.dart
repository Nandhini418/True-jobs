import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:truejobs/resume_sections/experienced_professional/add_certificate_screen.dart';
import 'package:truejobs/resume_sections/experienced_professional/projects_screen.dart';
import 'package:truejobs/models/resume_data.dart' as model;

class CertificationScreen extends StatefulWidget {
  const CertificationScreen({super.key});

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class CertificationModel {
  String name = '';
  String organization = '';
  String year = '';
}

class _CertificationScreenState extends State<CertificationScreen> {
  List<CertificationModel> _certifications = [];

  void _openAddCertificateSheet([int? indexToEdit]) async {
    final result = await Navigator.push(
      context,
      SmoothPageRoute(
        child: AddCertificateScreen(
          initialData: indexToEdit != null
              ? _certifications[indexToEdit]
              : null,
        ),
        durationMs: 0,
      ),
    );

    if (result != null && result is CertificationModel) {
      setState(() {
        if (indexToEdit != null) {
          _certifications[indexToEdit] = result;
        } else {
          _certifications.add(result);
        }
      });
    }
  }

  void _removeCertificate(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
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
                  children: [
                    // Top Image
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/certificate.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.workspace_premium,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Certification",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add Certification",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF353535),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // List of added certifications
                    ...List.generate(_certifications.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _buildCertificateCard(index),
                      );
                    }),

                    if (_certifications.length < 5) ...[
                      GestureDetector(
                        onTap: () => _openAddCertificateSheet(),
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: const Color(0xFF255EC7), // Dark blue border
                            strokeWidth: 1.w,
                            dashPattern: const <double>[2, 2],
                            radius: Radius.circular(24.r),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: const Color(0xFF0F99DE),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _certifications.isEmpty
                                      ? "Add"
                                      : "Add Another Certificate",
                                  style: TextStyle(
                                    color: const Color(0xFF0F99DE),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "You can add a maximum of 5 certifications",
                        style: TextStyle(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
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

  Widget _buildCertificateCard(int index) {
    final cert = _certifications[index];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB7B7B7), width: 1.w),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFFD9D9D9),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openAddCertificateSheet(index),
                        child: Icon(
                          Icons.edit,
                          color: const Color(0xFF0288D1),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => _removeCertificate(index),
                        child: Icon(
                          Icons.delete,
                          color: const Color(0xFFD32F2F),
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                cert.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                cert.organization,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                cert.year,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: -120.w,
          right: 0,
          top: -10.h,
          child: Center(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ClipPath(
                clipper: RibbonClipper(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 35.w,
                    vertical: 3.h,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBEB6F), // Soft yellow ribbon color
                  ),
                  child: Text(
                    "Certificate ${index + 1}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: const Color(0xFF272727),
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
                final certs = _certifications.map((c) {
                  return model.Certification(
                    name: c.name,
                    organization: c.organization,
                    year: c.year,
                  );
                }).toList();

                model.ResumeData.globalData = model.ResumeData.globalData.copyWith(
                  certifications: certs,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const ProjectsScreen(),
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
                _certifications.isEmpty ? 'Submit' : 'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double cutout = 16.0;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - cutout, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(cutout, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

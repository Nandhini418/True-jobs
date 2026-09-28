import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:truejobs/resume_sections/experienced_professional/add_project_screen.dart';
import 'package:truejobs/resume_sections/experienced_professional/languages_screen.dart';
import 'package:truejobs/models/resume_data.dart' as model;

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class ProjectModel {
  String title = '';
  String description = '';
  String technologies = '';
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final List<ProjectModel> _projects = [];

  void _openAddProjectScreen([int? indexToEdit]) async {
    final result = await Navigator.push(
      context,
      SmoothPageRoute(
        child: AddProjectScreen(
          initialData: indexToEdit != null ? _projects[indexToEdit] : null,
        ),
        durationMs: 0,
      ),
    );

    if (result != null && result is ProjectModel) {
      setState(() {
        if (indexToEdit != null) {
          _projects[indexToEdit] = result;
        } else {
          _projects.add(result);
        }
      });
    }
  }

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Image & Title
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/project.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.rocket_launch,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Projects",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add projects you have worked on",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // List of projects
                    ...List.generate(_projects.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: _buildProjectCard(index),
                      );
                    }),

                    if (_projects.length < 5) ...[
                      GestureDetector(
                        onTap: () => _openAddProjectScreen(),
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: const Color(0xFF000000),
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
                                  _projects.isEmpty ? "Add" : "Add Another Project",
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "You can add a maximum of 5 Projects",
                          style: TextStyle(
                            color: const Color(0xFF9E9E9E),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
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

  Widget _buildProjectCard(int index) {
    final proj = _projects[index];
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      proj.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openAddProjectScreen(index),
                        child: Icon(
                          Icons.edit,
                          color: const Color(0xFF0288D1),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => _removeProject(index),
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
              SizedBox(height: 12.h),
              Text(
                proj.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF616161),
                  height: 1.4,
                ),
              ),
              if (proj.technologies.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  proj.technologies,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 40.w,
          top: -10.h,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ClipPath(
              clipper: ProjectRibbonClipper(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 3.h,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFEBEB6F), // Soft yellow ribbon color
                ),
                child: Text(
                  "Project ${index + 1}",
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
      ],
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
                final projs = _projects.map((p) {
                  return model.Project(
                    title: p.title,
                    description: p.description,
                    technologies: p.technologies,
                  );
                }).toList();

                model.ResumeData.globalData = model.ResumeData.globalData.copyWith(
                  projects: projs,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const LanguagesScreen(),
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
                _projects.isEmpty ? 'Submit' : 'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectRibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double cutout = 12.0;

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

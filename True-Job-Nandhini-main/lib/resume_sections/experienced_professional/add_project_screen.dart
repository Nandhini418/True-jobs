import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/resume_sections/experienced_professional/projects_screen.dart';

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? initialData;

  const AddProjectScreen({
    super.key,
    this.initialData,
  });

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _techController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!.title;
      _descController.text = widget.initialData!.description;
      _techController.text = widget.initialData!.technologies;
    }
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
        title: Text(
          "Add projects",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 1.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 65.w,
                              height: 65.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2F6F1), // Light mint color
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset(
                              'assets/resume_images/experience/portfolio.gif',
                              height: 35.h,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.business_center, size: 30.sp, color: Colors.teal),
                            ),
                          ],
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            "Add your most relevant projects to showcase your skills and experience.",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    SizedBox(height: 24.h),
                    
                    // Project Title
                    Text(
                      "Project Title",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(_titleController, "e.g. E-commerce Website"),
                    SizedBox(height: 20.h),
                    
                    // Projects Description
                    Text(
                      "Projects Description",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      _descController, 
                      "Describe your project, Role, and what problem it solved", 
                      maxLines: 4, 
                      maxLength: 300
                    ),
                    SizedBox(height: 20.h),
                    
                    // Technologies Used
                    Text(
                      "Technologies Used",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(_techController, "e.g. React, Node.js, MongoDB"),
                    SizedBox(height: 4.h),
                    Text(
                      "Enter technologies separated by commas",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            
            // Submit Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
                      final project = ProjectModel()
                        ..title = _titleController.text
                        ..description = _descController.text
                        ..technologies = _techController.text;
                      Navigator.pop(context, project);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill the required fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp),
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFBDBDBD), fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        counterText: maxLength != null ? "" : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'job_create_widgets.dart';

class Step4RecruiterDetails extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController designationController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const Step4RecruiterDetails({
    super.key,
    required this.nameController,
    required this.designationController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader("Recruiter Detail's", subtitle: "Add your contact information"),
        
        buildTextField(
          label: 'Recruiter Name',
          hintText: 'Enter full name',
          controller: nameController,
        ),
        
        buildTextField(
          label: 'Recruiter Designation',
          hintText: 'eg. HR MANAGER',
          controller: designationController,
        ),
        
        buildTextField(
          label: 'Work Email',
          hintText: 'eg. recruiter@gmail.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required field';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        
        buildTextField(
          label: 'Contact Number',
          hintText: 'enter contact number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required field';
            if (val.length < 10) return 'Enter a valid 10-digit number';
            return null;
          },
        ),

        SizedBox(height: 24.h),
      ],
    );
  }
}

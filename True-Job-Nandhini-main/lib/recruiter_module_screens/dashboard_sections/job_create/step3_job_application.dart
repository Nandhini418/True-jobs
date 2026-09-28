import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_date_picker.dart';
import 'job_create_widgets.dart';

class Step3JobApplication extends StatefulWidget {
  final TextEditingController descriptionController;
  final TextEditingController responsibilitiesController;
  
  final TextEditingController deadlineController;
  
  final String? walkIn;
  final ValueChanged<String?> onWalkInChanged;
  
  final String? portfolio;
  final ValueChanged<String?> onPortfolioChanged;
  
  final String? resume;
  final ValueChanged<String?> onResumeChanged;

  // Walk-in controllers
  final TextEditingController walkInStartDateController;
  final TextEditingController walkInEndDateController;
  final TextEditingController walkInStartTimeController;
  final TextEditingController walkInEndTimeController;
  final TextEditingController walkInAddressController;
  final TextEditingController walkInInstructionsController;

  const Step3JobApplication({
    super.key,
    required this.descriptionController,
    required this.responsibilitiesController,
    required this.deadlineController,
    required this.walkIn,
    required this.onWalkInChanged,
    required this.portfolio,
    required this.onPortfolioChanged,
    required this.resume,
    required this.onResumeChanged,
    required this.walkInStartDateController,
    required this.walkInEndDateController,
    required this.walkInStartTimeController,
    required this.walkInEndTimeController,
    required this.walkInAddressController,
    required this.walkInInstructionsController,
  });

  @override
  State<Step3JobApplication> createState() => _Step3JobApplicationState();
}

class _Step3JobApplicationState extends State<Step3JobApplication> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Job & Application', subtitle: 'Add job description and application preferences'),
        
        _buildCounterTextField(
          label: 'Job Description',
          hintText: 'Enter job description, roles, responsibilities and more...',
          controller: widget.descriptionController,
          maxLength: 2000,
        ),
        
        _buildCounterTextField(
          label: 'Job Responsibilities',
          hintText: 'Enter job description, roles, responsibilities and more...',
          controller: widget.responsibilitiesController,
          maxLength: 2000,
        ),
        
        SizedBox(height: 10.h),
        buildSectionHeader('Application Settings'),
        

        buildRadioGroup(
          label: 'Is this a walk-in interview?',
          currentValue: widget.walkIn,
          options: const ['Yes', 'No'],
          onChanged: widget.onWalkInChanged,
        ),

        if (widget.walkIn == 'Yes') _buildWalkInFields(),

        buildRadioGroup(
          label: 'Portfolio Required',
          currentValue: widget.portfolio,
          options: const ['Yes', 'No'],
          onChanged: widget.onPortfolioChanged,
        ),

        buildRadioGroup(
          label: 'Resume Required',
          currentValue: widget.resume,
          options: const ['Yes', 'No'],
          onChanged: widget.onResumeChanged,
        ),

        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildCounterTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required int maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel(label),
        SizedBox(height: 7.h),
        Stack(
          children: [
            TextFormField(
              controller: controller,
              maxLines: 6,
              maxLength: maxLength,
              style: TextStyle(fontFamily: kJobFontFamily, fontSize: 13.sp),
              validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontFamily: kJobFontFamily, fontSize: 12.sp, color: Colors.grey),
                counterText: '', // Hide default counter
                contentPadding: EdgeInsets.all(12.w),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFD7D7D7))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.primary)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            Positioned(
              bottom: 12.h,
              right: 12.w,
              child: Text(
                '${controller.text.length}/$maxLength',
                style: TextStyle(fontFamily: kJobFontFamily, fontSize: 11.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
      ],
    );
  }

  Widget _buildWalkInFields() {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDatePicker(label: 'Start Date', controller: widget.walkInStartDateController, hintText: 'Start Date'),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDatePicker(label: 'End Date', controller: widget.walkInEndDateController, hintText: 'End Date'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(child: buildTextField(label: 'Start Time', controller: widget.walkInStartTimeController, hintText: '09:00 AM')),
              SizedBox(width: 12.w),
              Expanded(child: buildTextField(label: 'End Time', controller: widget.walkInEndTimeController, hintText: '05:00 PM')),
            ],
          ),
          buildTextField(label: 'Venue Address', controller: widget.walkInAddressController, hintText: 'Enter complete address', maxLines: 2),
          buildTextField(label: 'Special Instructions', controller: widget.walkInInstructionsController, hintText: 'e.g., Bring 2 copies of resume', isRequired: false),
        ],
      ),
    );
  }
}

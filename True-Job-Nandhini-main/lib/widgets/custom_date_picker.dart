import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class CustomDatePicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const CustomDatePicker({
    Key? key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Ensure firstDate and initialDate match exactly
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.dynamicText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Format as YYYY-MM-DD
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      controller.text = '${picked.year}-$month-$day';
    }
  }

  @override
  Widget build(BuildContext context) {
    const _fontFamily = 'Poppins';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12.sp,
                color: AppColors.dynamicText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        SizedBox(height: 7.h),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 13.sp,
                color: AppColors.dynamicText,
              ),
              validator: validator ?? (val) => val == null || val.isEmpty ? 'Required field' : null,
              decoration: InputDecoration(
                isDense: true,
                hintText: hintText,
                suffixIcon: Icon(Icons.calendar_month_outlined, size: 15.w, color: AppColors.grey),
                hintStyle: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 13.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11.r),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}

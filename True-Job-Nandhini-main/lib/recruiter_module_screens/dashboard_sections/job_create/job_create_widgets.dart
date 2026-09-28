import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

const String kJobFontFamily = 'Poppins';

Widget buildSectionHeader(String title, {String? subtitle}) {
  return Padding(
    padding: EdgeInsets.only(top: 14.h, bottom: 7.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF4FE),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/notes.png',
                height: 15.h,
                width: 15.w,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.notes, color: AppColors.primary, size: 15),
              ),
            ),
            SizedBox(width: 9.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: kJobFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.dynamicText,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          SizedBox(height: 5.h),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: kJobFontFamily,
              fontSize: 12.sp,
              color: AppColors.dynamicSubtitle,
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    ),
  );
}

Widget buildFieldLabel(String label, {bool isRequired = true}) {
  return Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: kJobFontFamily,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.dynamicText,
        ),
      ),
      if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
    ],
  );
}

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required String hintText,
  bool isRequired = true,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
  void Function(String)? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildFieldLabel(label, isRequired: isRequired),
      SizedBox(height: 7.h),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: kJobFontFamily,
          fontSize: 13.sp,
          color: AppColors.dynamicText,
        ),
        validator: validator ??
            (val) {
              if (isRequired && (val == null || val.isEmpty)) {
                return 'Required field';
              }
              return null;
            },
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          suffixIcon: suffixIcon,
          hintStyle: TextStyle(
            fontFamily: kJobFontFamily,
            fontSize: 12.sp,
            color: AppColors.grey,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: maxLines > 1 ? 11.h : 13.h,
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
      SizedBox(height: 14.h),
    ],
  );
}

Widget buildApiDropdownField({
  required String label,
  required String? value,
  required String hintText,
  required List<dynamic> apiOptions,
  required bool isLoading,
  required ValueChanged<String?> onChanged,
  bool isRequired = true,
}) {
  List<DropdownMenuItem<String>> menuItems = [];

  if (isLoading) {
    return buildDropdownField(
      label: label,
      value: value,
      hintText: 'Loading...',
      items: value != null ? [value] : ['Loading...'],
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  if (apiOptions.isEmpty) {
    return buildDropdownField(
      label: label,
      value: value,
      hintText: 'No options found',
      items: value != null ? [value] : ['No options found'],
      onChanged: onChanged,
      isRequired: isRequired,
    );
  }

  for (var e in apiOptions) {
    menuItems.add(
      DropdownMenuItem(
        value: e['value'].toString(),
        child: Text(
          e['label'].toString(),
          style: TextStyle(
            fontFamily: kJobFontFamily,
            fontSize: 13.sp,
            color: AppColors.dynamicText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String? validValue = value;
  if (validValue != null) {
    bool exists = apiOptions.any((e) => e['value'].toString() == validValue);
    if (!exists) validValue = null;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildFieldLabel(label, isRequired: isRequired),
      SizedBox(height: 7.h),
      DropdownButtonFormField<String>(
        isExpanded: true,
        value: validValue,
        dropdownColor: Colors.white,
        style: TextStyle(
          fontFamily: kJobFontFamily,
          fontSize: 13.sp,
          color: AppColors.dynamicText,
          fontWeight: FontWeight.w400,
        ),
        icon: Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Icon(Icons.arrow_drop_down, color: AppColors.dynamicText, size: 20.sp),
        ),
        hint: Text(
          hintText,
          style: TextStyle(
            fontFamily: kJobFontFamily,
            fontSize: 12.sp,
            color: AppColors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
        validator: (val) {
          if (isRequired && val == null) return 'Required field';
          return null;
        },
        items: menuItems,
        onChanged: onChanged,
      ),
      SizedBox(height: 14.h),
    ],
  );
}

Widget buildDropdownField({
  required String label,
  required String? value,
  required String hintText,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  bool isRequired = true,
}) {
  String? validValue = value;
  if (validValue != null && !items.contains(validValue)) {
    validValue = null;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildFieldLabel(label, isRequired: isRequired),
      SizedBox(height: 7.h),
      DropdownButtonFormField<String>(
        isExpanded: true,
        value: validValue,
        style: TextStyle(
          fontFamily: kJobFontFamily,
          fontSize: 13.sp,
          color: AppColors.dynamicText,
          fontWeight: FontWeight.w500,
        ),
        icon: Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Icon(Icons.arrow_drop_down, color: AppColors.dynamicText, size: 20.sp),
        ),
        hint: Text(
          hintText,
          style: TextStyle(
            fontFamily: kJobFontFamily,
            fontSize: 12.sp,
            color: AppColors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        onChanged: onChanged,
        validator: (val) {
          if (isRequired && val == null) return 'Required field';
          return null;
        },
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontFamily: kJobFontFamily,
                fontSize: 13.sp,
                color: AppColors.dynamicText,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
      SizedBox(height: 14.h),
    ],
  );
}

Widget buildRadioGroup({
  required String label,
  required String? currentValue,
  required List<String> options,
  required ValueChanged<String?> onChanged,
  bool isRequired = true,
}) {
  return FormField<String>(
    initialValue: currentValue,
    validator: (val) {
      if (isRequired && val == null) return 'Required field';
      return null;
    },
    builder: (state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFieldLabel(label, isRequired: isRequired),
          Row(
            children: options.map((option) {
              return Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: currentValue,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      onChanged(val);
                      state.didChange(val);
                    },
                  ),
                  Text(
                    option,
                    style: TextStyle(
                      fontFamily: kJobFontFamily,
                      fontSize: 13.sp,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(width: 22.w),
                ],
              );
            }).toList(),
          ),
          if (state.hasError)
            Padding(
              padding: EdgeInsets.only(bottom: 7.h),
              child: Text(
                state.errorText!,
                style: TextStyle(
                  fontFamily: kJobFontFamily,
                  fontSize: 10.sp,
                  color: Colors.red,
                ),
              ),
            ),
          SizedBox(height: 11.h),
        ],
      );
    },
  );
}

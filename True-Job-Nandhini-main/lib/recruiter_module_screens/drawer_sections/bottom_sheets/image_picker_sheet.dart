import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key});
  static const String _fontFamily = 'Poppins';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Logo',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.dynamicText,
            ),
          ),
          SizedBox(height: 16.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.camera_alt_outlined),
            title: Text(
              'Camera',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 14.sp,
                color: AppColors.dynamicText,
              ),
            ),
            onTap: () {
              Navigator.pop(context, 'camera');
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(
              'Gallery',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 14.sp,
                color: AppColors.dynamicText,
              ),
            ),
            onTap: () {
              Navigator.pop(context, 'gallery');
            },
          ),
        ],
      ),
    );
  }
}

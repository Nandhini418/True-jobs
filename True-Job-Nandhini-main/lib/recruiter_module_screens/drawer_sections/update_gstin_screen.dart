import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';

class UpdateGstinScreen extends StatefulWidget {
  const UpdateGstinScreen({super.key});

  @override
  State<UpdateGstinScreen> createState() => _UpdateGstinScreenState();
}

class _UpdateGstinScreenState extends State<UpdateGstinScreen> {
  final TextEditingController _gstinController =
      TextEditingController(text: '33ADWFS2I64G1ZS');
  bool _verified = true;
  static const String _fontFamily = 'Poppins';

  @override
  void dispose() {
    _gstinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          const CustomAppBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Back header
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 14.sp,
                          color: AppColors.dynamicText,
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          'Update GSTIN',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Subtitle
                  Text(
                    'The tax id would appear on your future invoices.',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // GSTIN field label
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ISD-GSTIN / GSTIN number ',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // GSTIN Text field
                  TextField(
                    controller: _gstinController,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14.sp,
                      color: AppColors.dynamicText,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.w,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9.r),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9.r),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9.r),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Company details card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We found following company details',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'COMPANY NAME:',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary_color,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'SMART GLOBAL SOLUTIONS',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'ADDRESS:',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary_color,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '22-B, 9th Street, Sri Vana Bathra Kaliamman Temple, Sri Krishna Nagar, Irugur, Coimbatore, Tamil Nadu, 641103',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12.sp,
                            color: const Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Checkbox
                  GestureDetector(
                    onTap: () => setState(() => _verified = !_verified),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: _verified ? const Color(0xFF2563EB) : Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: _verified ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                          ),
                          child: _verified
                              ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                              : null,
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Text(
                            'I verify my company details and understand that the invoices would be generated using the same information.',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 12.sp,
                              color: const Color(0xFF745569),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 16.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dynamicText,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _verified ? () => Navigator.pop(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

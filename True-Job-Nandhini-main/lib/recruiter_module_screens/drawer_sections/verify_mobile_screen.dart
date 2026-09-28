import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class VerifyMobileScreen extends StatefulWidget {
  final String mobile;

  const VerifyMobileScreen({
    super.key,
    required this.mobile,
  });

  @override
  State<VerifyMobileScreen> createState() => _VerifyMobileScreenState();
}

class _VerifyMobileScreenState extends State<VerifyMobileScreen> {
  static const String _fontFamily = 'Poppins';
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8FD),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(backgroundColor: Color(0xFFF6F8FD)),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, color: AppColors.dynamicText, size: 18.w),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Verify Mobile Number',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dynamicText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  children: [
                    Text(
                      'Enter the 4-digit code sent to',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12.sp,
                        color: AppColors.dynamicSubtitle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '+91 ${widget.mobile}', // Assuming indian format as per design
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dynamicText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 48.w,
                          height: 48.w,
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dynamicText,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(color: Color(0xFFD7D7D7)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            onChanged: (value) => _onOtpChanged(value, index),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code ? ',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11.sp,
                            color: AppColors.dynamicSubtitle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Resend OTP action
                          },
                          child: Text(
                            'Resend OTP ',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '(00:30)',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11.sp,
                            color: AppColors.dynamicSubtitle,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Simulating Verification & Update
                          // Pop until Edit Profile or View Profile depending on user flow
                          Navigator.pop(context); // Pop Verify Mobile
                          Navigator.pop(context); // Pop Change Mobile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Verify & Update',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

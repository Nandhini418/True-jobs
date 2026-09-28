import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class VerifyEmailOtpDialog extends StatefulWidget {
  final String email;
  final VoidCallback onContinue;
  final VoidCallback? onResend;

  const VerifyEmailOtpDialog({
    super.key,
    required this.email,
    required this.onContinue,
    this.onResend,
  });

  @override
  State<VerifyEmailOtpDialog> createState() => _VerifyEmailOtpDialogState();
}

class _VerifyEmailOtpDialogState extends State<VerifyEmailOtpDialog> {
  static const String _fontFamily = 'Poppins';
  static const int _otpLength = 4;

  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());

  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
    for (final node in _focusNodes) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final isComplete = _enteredOtp.length == _otpLength;
    setState(() {
      _isOtpComplete = isComplete;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Dialog(
      backgroundColor: AppColors.dynamicBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verify email ID',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    size: 18.w,
                    color: const Color(0xFF2A2A2A),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  color: const Color(0x66000000),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'We have sent an OTP to your email ID '),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w400,
                      color: Color(0x66000000),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 17.h),
            _buildOtpBoxes(textColor, borderColor),
            SizedBox(height: 14.h),
            _buildResendRow(subtitleColor),
            SizedBox(height: 21.h),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBoxes(
      Color textColor,
      Color borderColor,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(_otpLength, (index) {
        final bool isFilled = _controllers[index].text.isNotEmpty;

        Color boxBorderColor;
        if (_isOtpComplete) {
          boxBorderColor = AppColors.primary;
        } else if (isFilled) {
          boxBorderColor = AppColors.primary;
        } else {
          boxBorderColor = borderColor;
        }

        return Padding(
          padding: EdgeInsets.only(
            right: index == _otpLength - 1 ? 0 : 11.w,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50.w,
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(color: boxBorderColor, width: 1.0),
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _onDigitChanged(index, value);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendRow(Color subtitleColor) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12.sp,
          color: subtitleColor,
        ),
        children: [
          const TextSpan(text: "Didn't receive it? "),
          TextSpan(
            text: 'Resend code',
            style: const TextStyle(
              fontFamily: _fontFamily,
              color: Color(0xFF055BF2),
              fontWeight: FontWeight.w400,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                widget.onResend?.call();
              },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 34.h,
      child: ElevatedButton(
        onPressed: _isOtpComplete ? widget.onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.buttonDisabled,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.buttonDisabledText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29.r),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
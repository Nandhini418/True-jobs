import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/basic_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

import 'package:truejobs/services/otp_api_service.dart';
import 'package:truejobs/services/login_api_service.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/company_details_screen.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/dashboard_holder.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final bool isRegistration;
  final String? token;
  final String? otpFromServer;

  const OtpScreen({
    super.key,
    required this.phone,
    this.isRegistration = false,
    this.token,
    this.otpFromServer,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  static const String _fontFamily = 'Poppins';
  static const int _otpLength = 6;
  static const int _resendSeconds = 29;

  final List<TextEditingController> _otpControllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );
  final List<String> _prevValues = List.generate(_otpLength, (_) => ' ');

  bool _isOtpComplete = false;
  bool _isLoading = false;
  String? _otpFromServer;

  Timer? _timer;
  int _secondsRemaining = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _otpFromServer = widget.otpFromServer;
    _startResendTimer();
    listenForCode();
    for (int i = 0; i < _otpLength; i++) {
      _otpControllers[i].text = ' ';
    }
  }

  @override
  void codeUpdated() {
    if (code != null) {
      String finalOtp = code!;
      if (_otpFromServer != null && _otpFromServer!.length == _otpLength) {
        finalOtp = _otpFromServer!;
      }

      if (finalOtp.length == _otpLength) {
        for (int i = 0; i < _otpLength; i++) {
          _otpControllers[i].text = finalOtp[i];
          _prevValues[i] = finalOtp[i];
        }
        _checkOtpComplete();
      }
    }
  }

  void _startResendTimer() {
    _secondsRemaining = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String get _formattedTimer {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _checkOtpComplete() {
    final isComplete = _otpControllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
    if (isComplete != _isOtpComplete) {
      setState(() {
        _isOtpComplete = isComplete;
      });
    }
  }

  void _onResendPressed() async {
    if (_secondsRemaining != 0) return;

    setState(() {
      _isLoading = true;
    });

    String appSignature = '';
    try {
      appSignature = await SmsAutoFill().getAppSignature;
    } catch (e) {
      debugPrint('Error getting app signature: $e');
      appSignature = 'itufuifyfufu'; // Fallback
    }

    final response = await LoginApiService.login(
      mobile: widget.phone,
      appSignature: appSignature,
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['error'] == false) {
      final String newOtp = response['otp'] ?? '';
      setState(() {
        _otpFromServer = newOtp.isNotEmpty ? newOtp : _otpFromServer;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
      _startResendTimer();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?['error_msg'] ?? 'Failed to resend OTP')),
      );
    }
  }

  void _onVerifyPressed() async {
    if (!_isOtpComplete) return;

    setState(() {
      _isLoading = true;
    });

    final otp = _otpControllers.map((c) => c.text.trim()).join();
    
    final response = await OtpApiService.verifyOtp(
      mobile: widget.phone,
      otp: otp,
      token: widget.token ?? '',
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['error'] == false) {
      final String userIdStr = response['user_id']?.toString() ?? '';
      
      final prefs = await SharedPreferences.getInstance();
      final int? userIdInt = int.tryParse(userIdStr);
      if (userIdInt != null) {
        await prefs.setInt('user_id', userIdInt);
        await prefs.setString('user_role', 'recruiter');
      }
      await prefs.setString('mobile', widget.phone);
      final String token = widget.token ?? '';
      await prefs.setString('token', token);
      
      final profileResponse = await BasicDetailApiService.fetchBasicDetails(
        userId: userIdStr,
        token: token,
      );

      if (!mounted) return;

      bool hasBasicDetails = false;
      bool hasCompanyDetails = false;

      if (profileResponse != null && profileResponse['status'] == 'success') {
        final data = profileResponse['data'];
        if (data != null) {
          final String contactPerson = data['contact_person'] ?? data['name'] ?? '';
          final String contactEmail = data['contact_person_email'] ?? data['email_id'] ?? '';
          if (contactPerson.isNotEmpty && contactEmail.isNotEmpty) {
            hasBasicDetails = true;
          }
           
          final String companyName = data['company_name'] ?? data['company'] ?? '';
          final String pincode = data['pincode'] ?? data['pin_code'] ?? '';
          final String address = data['address'] ?? data['company_address'] ?? '';
          if (companyName.isNotEmpty && pincode.isNotEmpty && address.isNotEmpty) {
            hasCompanyDetails = true;
          }
        }
      }
      
      if (hasBasicDetails && hasCompanyDetails) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardHolder()),
          (route) => false,
        );
      } else if (hasBasicDetails && !hasCompanyDetails) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyDetailsScreen(
              phone: widget.phone,
              userId: userIdStr,
              token: token,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EnteredNumberScreen(
              phone: widget.phone,
              userId: userIdStr,
              token: token,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?['message'] ?? 'Invalid OTP')),
      );
    }
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 34.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18.w,
                  color: textColor,
                ),
              ),
              SizedBox(height: 103.h),
              _buildSentToLine(textColor, subtitleColor),
              SizedBox(height: 21.h),
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 14.h),
              _buildOtpBoxes(textColor, borderColor),
              SizedBox(height: 14.h),
              _buildResendRow(subtitleColor),
              SizedBox(height: 80.h),
              _buildVerifyButton(),
              SizedBox(height: 21.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentToLine(
    Color textColor,
    Color subtitleColor,
  ) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12.sp,
          color: subtitleColor,
        ),
        children: [
          const TextSpan(text: 'A 6-digit code was sent to '),
          TextSpan(
            text: widget.phone,
            style: TextStyle(
              color: textColor, // Different color for mobile number
              fontWeight: FontWeight.w500,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h, bottom: 5.h),
                child: Icon(
                  Icons.edit,
                  size: 14.w,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBoxes(
    Color textColor,
    Color borderColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 43.w,
          height: 43.w,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            enableSuggestions: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
              onChanged: (value) {
                if (value.isEmpty) {
                  if (_prevValues[index] == ' ') {
                    _otpControllers[index].text = ' ';
                    _prevValues[index] = ' ';
                    if (index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                      _otpControllers[index - 1].text = ' ';
                      _prevValues[index - 1] = ' ';
                    }
                  } else {
                    _otpControllers[index].text = ' ';
                    _prevValues[index] = ' ';
                  }
                } else {
                  final digit = value.substring(value.length - 1);
                  _otpControllers[index].text = digit;
                  _prevValues[index] = digit;
                  if (index < _otpLength - 1) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else {
                    _otpFocusNodes[index].unfocus();
                  }
                }
                _checkOtpComplete();
              },
            ),
          );
      }),
    );
  }

  Widget _buildResendRow(Color subtitleColor) {
    return GestureDetector(
      onTap: _onResendPressed,
      child: Text(
        'Resend OTP $_formattedTimer',
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12.sp,
          color: _secondsRemaining == 0 ? AppColors.primary : subtitleColor,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: (_isOtpComplete && !_isLoading) ? _onVerifyPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: Colors.grey[300],
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        elevation: 0,
      ),
      child: _isLoading 
          ? SizedBox(
              height: 18.w, 
              width: 18.w, 
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : Text(
              'Verify',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

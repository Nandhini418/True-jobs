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

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),

              // Enter OTP Title
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                "We've sent an OTP to ${widget.phone}",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  color: Color(0x551B1B1B),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              // Change Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Change',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: 45.w,
                    height: 45.w,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      enableSuggestions: false,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Color(0x66B4B4B4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.primary),
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
              ),

              SizedBox(height: 32.h),

              // Resend OTP
              Column(
                children: [
                  Text(
                    "Didn't receive the OTP?",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: Color(0x551B1B1B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: _secondsRemaining == 0 ? _onResendPressed : null,
                    child: Text(
                      _secondsRemaining > 0
                          ? 'Retry in 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                          : 'Retry Now',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        color: _secondsRemaining > 0
                            ? Colors.grey[400]
                            : AppColors.primary,
                        fontWeight: _secondsRemaining > 0
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Verify Button
              ElevatedButton(
                onPressed: (_isOtpComplete && !_isLoading) ? _onVerifyPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? SizedBox(
                        height: 20.w, 
                        width: 20.w, 
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

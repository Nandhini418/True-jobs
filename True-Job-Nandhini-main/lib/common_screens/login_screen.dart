import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:geolocator/geolocator.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/api/api_config.dart';
import 'package:truejobs/services/api/login_api.dart';
import 'package:truejobs/services/login_api_service.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/utils/uppercase_text_formatter.dart';
import 'package:truejobs/job_seeker_module/Login%20Sections/otp_screen.dart' as js_otp;
import 'package:truejobs/recruiter_module_screens/login_sections/otp_screen.dart' as r_otp;

class LoginScreen extends StatefulWidget {
  final bool isRecruiter;

  const LoginScreen({super.key, required this.isRecruiter});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _fontFamily = 'Poppins';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _referralFocusNode = FocusNode();
  bool _isLoading = false;
  bool? _isRegistered;
  bool _isCheckingRegistration = false;

  Future<void> _checkRegistrationStatus(String mobile) async {
    setState(() {
      _isCheckingRegistration = true;
    });

    try {
      String deviceId = await ApiConfig.getDeviceId();
      double latitude = 11.0;
      double longitude = 11.0;
      
      final response = await LoginApi.checkRegistration(
        mobile: mobile,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
      );

      if (mounted && _phoneController.text == mobile) {
        setState(() {
          _isCheckingRegistration = false;
          if (response['status'] == 'success') {
            _isRegistered = response['registered'] ?? false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingRegistration = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
    _referralFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _referralFocusNode.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() async {
    if (_phoneController.text.length != 10) return;

    setState(() {
      _isLoading = true;
    });

    if (widget.isRecruiter) {
      // Recruiter Login
      String appSignature = '';
      try {
        appSignature = await SmsAutoFill().getAppSignature;
      } catch (e) {
        debugPrint('Error getting app signature: $e');
        appSignature = 'itufuifyfufu'; // Fallback
      }

      final response = await LoginApiService.login(
        mobile: _phoneController.text.trim(),
        referrerCode: _referralController.text.trim(),
        appSignature: appSignature,
      );

      setState(() {
        _isLoading = false;
      });

      if (response != null && response['error'] == false) {
        final String token = response['f_token'] ?? '';
        final String otp = response['otp'] ?? '';
        
        if (mounted) {
          Navigator.push(
            context,
            SmoothPageRoute(
              child: r_otp.OtpScreen(
                phone: _phoneController.text.trim(),
                isRegistration: false, // Defaulting, you may need logic to determine registration
                token: token,
                otpFromServer: otp,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?['error_msg'] ?? 'Login failed')),
          );
        }
      }
    } else {
      // Job Seeker (Employee) Login
      double latitude = 11.0;
      double longitude = 11.0;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            latitude = position.latitude;
            longitude = position.longitude;
          }
        }
      } catch (e) {
        debugPrint('Failed to get location during login: $e');
      }

      String appSignature = '';
      try {
        appSignature = await SmsAutoFill().getAppSignature;
      } catch (e) {
        debugPrint('Error getting app signature: $e');
        appSignature = 'itufuifyfufu'; // Fallback
      }

      var deviceId = await ApiConfig.getDeviceId();

      var response = await LoginApi.loginWithPhone(
        mobile: _phoneController.text.trim(),
        appSignature: appSignature,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        referrerCode: _referralController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response['error'] == false) {
        final String token = response['f_token'] ?? '';
        final String otp = response['otp'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobile', _phoneController.text.trim());
        await prefs.setDouble('latitude', latitude);
        await prefs.setDouble('longitude', longitude);
        await prefs.setString('device_id', deviceId);
        final parsedUserId = int.tryParse(
          response['user_id']?.toString() ?? '',
        );

        if (parsedUserId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Invalid user profile from server. Please try again.',
                ),
              ),
            );
          }
          return;
        }

        if (mounted) {
          Navigator.push(
            context,
            SmoothPageRoute(
              child: js_otp.OtpScreen(
                phoneNumber: _phoneController.text.trim(),
                token: token,
                otpFromServer: otp,
              ),
            ),
          );
        }
      } else {
        final String errorMsg =
            response['error_msg'] ?? 'Failed to request OTP';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhoneComplete = _phoneController.text.length == 10;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15.h),
              Text(
                "Login With OTP",
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
              Text(
                widget.isRecruiter
                    ? "Find the Right Candidates Faster"
                    : "Get your dream jobs with us",
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14.sp,
                  color: Color(0x551B1B1B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              
              // Mobile Number Input
              TextField(
                focusNode: _phoneFocusNode,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  labelText: 'Mobile number',
                  labelStyle: TextStyle(
                    fontFamily: _fontFamily,
                    color: _phoneFocusNode.hasFocus ? AppColors.primary : Color(0x44000000),
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                  if (val.length == 10) {
                    _checkRegistrationStatus(val);
                  } else {
                    _isRegistered = null;
                  }
                },
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "You will receive an OTP on this number",
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12.sp,
                    color: Color(0x551B1B1B),
                  ),
                ),
              ),
              
              if (_isRegistered == false) ...[
                SizedBox(height: 24.h),
                
                // Referral Code Input
                TextField(
                  focusNode: _referralFocusNode,
                  controller: _referralController,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                  maxLength: 5,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    labelText: 'Referral Code',
                    labelStyle: TextStyle(
                      fontFamily: _fontFamily,
                      color: _referralFocusNode.hasFocus ? AppColors.primary : Color(0xFFD0D0D0),
                      fontSize: 14.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: BorderSide(color: AppColors.primary,),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: "Have a referral code? Enter it here or Use  ",
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12.sp,
                        color: Color(0x551B1B1B),
                      ),
                      children: [
                        TextSpan(
                          text: widget.isRecruiter ? "SMART" : "APPLY",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              ElevatedButton(
                onPressed: (!isPhoneComplete || _isLoading || _isCheckingRegistration)
                    ? null
                    : _onSendOtpPressed,
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
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send OTP',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}

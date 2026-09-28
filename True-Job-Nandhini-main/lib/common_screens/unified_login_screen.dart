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
import 'package:truejobs/job_seeker_module/home_screen.dart';
import 'package:truejobs/job_seeker_module/Login%20Sections/otp_screen.dart'
    as js_otp;
import 'package:truejobs/recruiter_module_screens/login_sections/otp_screen.dart'
    as r_otp;

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  static const String _fontFamily = 'Poppins';

  bool _isRecruiter = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;
  bool? _isNewlyRegistered;
  bool _isCheckingNumber = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber(String mobile) async {
    setState(() {
      _isCheckingNumber = true;
      _isNewlyRegistered = null;
    });

    double latitude = 11.0;
    double longitude = 11.0;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }
    } catch (e) {
      debugPrint('Failed to get location during verification: $e');
    }

    var deviceId = await ApiConfig.getDeviceId();

    var response = await LoginApi.checkRegistration(
      mobile: mobile,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
    );

    if (!mounted) return;

    setState(() {
      _isCheckingNumber = false;
      if (response['status'] == 'success') {
        _isNewlyRegistered = response['registered'] == false;
      } else {
        _isNewlyRegistered = false; // Fallback to not showing if error
      }
    });
  }

  void _onGetOtpPressed() async {
    if (_phoneController.text.length != 10) return;

    setState(() {
      _isLoading = true;
    });

    if (_isRecruiter) {
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
            MaterialPageRoute(
              builder: (_) => r_otp.OtpScreen(
                phone: _phoneController.text.trim(),
                isRegistration: false,
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

  void _onGuestModePressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
    await prefs.remove('user_id');
    await prefs.remove('token');
    await prefs.remove('name');
    await prefs.remove('profile_image_url');
    await prefs.remove('profile_pic_path');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        SmoothPageRoute(child: const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    final bool isPhoneComplete = _phoneController.text.length == 10;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),

                // Header (Logo and Language)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/splash_logo.png',
                      height: 55.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(height: 25.h),

                // Welcome Text
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141414),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Login to your account and continue managing\nyour ${_isRecruiter ? 'recruiter' : 'employee'} journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12.sp,
                    color: Color(0x551B1B1B),
                  ),
                ),
                SizedBox(height: 30.h),

                // Animated Toggle
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: _isRecruiter
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            margin: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRecruiter = false;
                                  _referralController.clear();
                                  _isNewlyRegistered = null;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Text(
                                    'Employee',
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: !_isRecruiter
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isRecruiter = true;
                                  _referralController.clear();
                                  _isNewlyRegistered = null;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Text(
                                    'Recruiter',
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: _isRecruiter
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Phone Input Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Let's Start With Your Phone Number",
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8.r),
                    border: _phoneFocusNode.hasFocus
                        ? Border.all(color: AppColors.primary, width: 1.0)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14.sp,
                            color: textColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _phoneFocusNode,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14.sp,
                            color: textColor,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              String digits = newValue.text;
                              int selectionOffset =
                                  newValue.selection.baseOffset;
                              if (digits.length > 10 &&
                                  digits.startsWith('91')) {
                                digits = digits.substring(2);
                                selectionOffset -= 2;
                              }
                              if (digits.length > 10) {
                                digits = digits.substring(0, 10);
                              }
                              if (selectionOffset < 0) selectionOffset = 0;
                              if (selectionOffset > digits.length)
                                selectionOffset = digits.length;
                              return TextEditingValue(
                                text: digits,
                                selection: TextSelection.collapsed(
                                  offset: selectionOffset,
                                ),
                              );
                            }),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                            border: InputBorder.none,
                            hintText: 'Enter your mobile number to get OTP',
                            hintStyle: TextStyle(
                              fontFamily: _fontFamily,
                              color: Colors.grey[400],
                              fontSize: 12.sp,
                            ),
                          ),
                          onChanged: (val) {
                            if (val.length < 10 && _isNewlyRegistered != null) {
                              setState(() {
                                _isNewlyRegistered = null;
                              });
                            } else if (val.length == 10 && _isNewlyRegistered == null) {
                              _verifyPhoneNumber(val);
                            } else {
                              setState(() {}); // Rebuild to update button
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Referral Code Section
                if (_isNewlyRegistered == true)
                  Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FD),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB9CAF2),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/common_images/gift.png',
                              height: 18.h,
                              width: 18.w,
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Have a referral Code?",
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  "Enter referral code to get exiting benfits",
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 12.sp,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Color(0xFFAEAEAE),
                            width: 0.3,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Image.asset(
                                'assets/common_images/refer.png',
                                height: 18.h,
                                width: 18.w,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _referralController,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 12.sp,
                                  color: textColor,
                                ),
                                maxLength: 5,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z]'),
                                  ),
                                  UpperCaseTextFormatter(),
                                ],
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintText: 'Enter referral code',
                                  hintStyle: TextStyle(
                                    fontFamily: _fontFamily,
                                    color: Colors.grey[400],
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Don't have code use this: ${_isRecruiter ? 'SMART' : 'APPLY'}",
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12.sp,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isNewlyRegistered == true) SizedBox(height: 40.h) else SizedBox(height: 16.h),

                // Get OTP Button
                ElevatedButton(
                  onPressed: (!isPhoneComplete || _isLoading)
                      ? null
                      : _onGetOtpPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: (_isLoading || _isCheckingNumber)
                      ? SizedBox(
                          height: 18.w,
                          width: 18.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Get OTP',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                // Guest Mode Button (Only for Employee)
                if (!_isRecruiter) ...[
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: _onGuestModePressed,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

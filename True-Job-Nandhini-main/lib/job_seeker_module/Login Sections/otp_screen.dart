import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/job_seeker_module/build_profile_screen.dart';
import 'package:truejobs/job_seeker_module/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:truejobs/services/api/otp_api.dart';
import 'package:truejobs/services/api/profile_select_api.dart';
import 'package:truejobs/services/api/educational_select_api.dart';
import 'package:truejobs/services/api/login_api.dart';
import 'package:truejobs/services/api/experience_select_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:truejobs/services/notification_service.dart';
import '../../services/api/apply_job_api.dart';
import '../../utils/smooth_page_route.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String token;
  final String? otpFromServer;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.token,
    this.otpFromServer,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<String> _prevValues = List.generate(6, (_) => ' ');
  bool _isOtpComplete = false;
  int _resendTimer = 60;
  Timer? _timer;
  late String _token;
  String? _otpFromServer;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _otpFromServer = widget.otpFromServer;
    _startTimer();
    listenForCode();

    for (int i = 0; i < 6; i++) {
      _controllers[i].text = ' ';
    }
  }

  @override
  void codeUpdated() {
    if (code != null) {
      String finalOtp = code!;
      if (_otpFromServer != null && _otpFromServer!.length == 6) {
        finalOtp = _otpFromServer!;
      }

      if (finalOtp.length == 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = finalOtp[i];
          _prevValues[i] = finalOtp[i];
        }
        _checkOtpComplete();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        if (mounted) setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      double latitude = prefs.getDouble('latitude') ?? 0.0;
      double longitude = prefs.getDouble('longitude') ?? 0.0;
      if (latitude == 0.0) latitude = 11.0;
      if (longitude == 0.0) longitude = 11.0;
      final String deviceId = prefs.getString('device_id') ?? '';

      // Fetch app signature dynamically using sms_autofill
      String appSignature = '';
      try {
        appSignature = await SmsAutoFill().getAppSignature;
      } catch (e) {
        debugPrint('Error getting app signature: $e');
        appSignature = 'itufuifyfufu'; // Fallback
      }

      final response = await LoginApi.loginWithPhone(
        mobile: widget.phoneNumber,
        appSignature: appSignature,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
      );

      if (response['error'] == false) {
        final String newToken = response['f_token'] ?? '';
        final String newOtp = response['otp'] ?? '';
        if (mounted) {
          setState(() {
            _token = newToken.isNotEmpty ? newToken : _token;
            _otpFromServer = newOtp.isNotEmpty ? newOtp : _otpFromServer;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP Resent successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final String errorMsg = response['error_msg'] ?? 'Failed to resend OTP';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkOtpComplete() {
    bool complete = _controllers.every(
          (controller) => controller.text.trim().isNotEmpty,
    );
    if (complete != _isOtpComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isOtpComplete = complete;
          });
        }
      });
    }
    if (complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _verifyOtp();
        }
      });
    }
  }

  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (_isLoading) return;
    final enteredOtp = _controllers.map((c) => c.text.trim()).join();

    if (enteredOtp.length != 6) {
      _showError("Please enter complete 6-digit OTP");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OtpApi.verifyOtp(
        mobile: widget.phoneNumber,
        otp: enteredOtp,
        token: _token,
      );

      if (response['error'] == false) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_guest', false);

        // Clear all previous user profile details to prevent data leakage/cross-user values
        final keysToRemove = [
          'name',
          'email',
          'gender',
          'dob',
          'physical_challenge',
          'cond_type',
          'affect_area',
          'profile_pic_path',
          'profile_image_url',
          'resume',
          'linkedin',
          'portfolio',
          'experience_salary',
          'profile_creation_step',
          'is_profile_completed',
          'comp_name',
          'led_cat',
          'job_title',
          'company_name'
        ];
        for (final key in keysToRemove) {
          await prefs.remove(key);
        }

        if (response['token'] != null) {
          await prefs.setString('token', response['token'].toString());
        }
        final parsedUserId = int.tryParse(response['user_id']?.toString() ?? '');
        if (parsedUserId != null) {
          await prefs.setInt('user_id', parsedUserId);
          await prefs.setString('user_role', 'job_seeker');
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              await NotificationService().uploadFcmToken(fcmToken);
            }
          } catch (e) {
            debugPrint('Error syncing FCM token on OTP verification: $e');
          }
        } else {
          _showError('Invalid user profile from server. Please try again.');
          return;
        }

        bool hasBasicDetails = false;
        bool hasEduDetails = false;
        bool hasExpDetails = false;
        bool hasResume = false;

        try {
          // Fetch profile first to populate local cache
          final profileRes = await ProfileSelectApi.fetchProfile(userId: parsedUserId);
          if (profileRes['status'] == 'success' || profileRes['error'] == false) {
            final data = profileRes['data'];
            if (data != null && data is Map<String, dynamic>) {
              final String nameVal = data['name']?.toString() ?? '';
              if (nameVal.trim().isNotEmpty) {
                hasBasicDetails = true;
                await prefs.setString('name', nameVal.trim());
              }
              if (data['email'] != null && data['email'].toString().isNotEmpty) {
                await prefs.setString('email', data['email'].toString());
              }
              if (data['mobile'] != null && data['mobile'].toString().isNotEmpty) {
                await prefs.setString('mobile', data['mobile'].toString());
              }
              if (data['dob'] != null && data['dob'].toString().isNotEmpty) {
                await prefs.setString('dob', data['dob'].toString());
              }
              if (data['gender'] != null && data['gender'].toString().isNotEmpty) {
                await prefs.setString('gender', data['gender'].toString());
              }
              if (data['physical_challenge'] != null && data['physical_challenge'].toString().isNotEmpty) {
                await prefs.setString('physical_challenge', data['physical_challenge'].toString());
              }
              if (data['cond_type'] != null && data['cond_type'].toString().isNotEmpty) {
                await prefs.setString('cond_type', data['cond_type'].toString());
              }
              if (data['affect_area'] != null && data['affect_area'].toString().isNotEmpty) {
                await prefs.setString('affect_area', data['affect_area'].toString());
              }
              final String fetchedPhoto = (data['photo'] ?? data['profile_image'])?.toString() ?? '';
              if (fetchedPhoto.isNotEmpty) {
                await prefs.setString('profile_image_url', fetchedPhoto);
              }
              if (data['resume'] != null && data['resume'].toString().trim().isNotEmpty) {
                hasResume = true;
                await prefs.setString('resume', data['resume'].toString().trim());
              }
              if (data['linkedin'] != null && data['linkedin'].toString().isNotEmpty) {
                await prefs.setString('linkedin', data['linkedin'].toString());
              }
              if (data['portfolio'] != null && data['portfolio'].toString().isNotEmpty) {
                await prefs.setString('portfolio', data['portfolio'].toString());
              }
            }
          }
        } catch (e) {
          debugPrint('Error loading profile in OTP: $e');
        }

        try {
          final eduRes = await EducationalSelectApi.fetchEducationalDetails(
            name: parsedUserId.toString(),
          );
          if (eduRes['status'] == 'success' || eduRes['error'] == false) {
            final data = eduRes['data'];
            if (data != null &&
                data is Map &&
                data['high_qualify'] != null &&
                data['high_qualify'].toString().trim().isNotEmpty) {
              hasEduDetails = true;
            }
          }
        } catch (e) {
          debugPrint('Error checking server profile completion: $e');
        }

        // Fetch and cache experience details to prevent 'Fresher' showing on new device logins
        try {
          final expRes = await ExperienceSelectApi.fetchExperienceDetails(
            name: parsedUserId.toString(),
          );
          if (expRes['status'] == 'success' || expRes['error'] == false) {
            final expData = expRes['data'];
            if (expData != null && expData is Map<String, dynamic>) {
              final List<dynamic> expList = expData['experiences'] ?? [];
              if (expList.isNotEmpty) {
                hasExpDetails = true;
              }
              Map<String, dynamic>? primaryExp;
              for (var item in expList) {
                if (item is Map<String, dynamic>) {
                  final String youHaveExpStr = item['you_have_experience']?.toString() ?? '0';
                  if (youHaveExpStr == '1') {
                    primaryExp = item;
                    break;
                  }
                }
              }

              final youHaveExp = primaryExp != null;
              final String expId = primaryExp?['id']?.toString() ?? '';
              final String jobTitle = youHaveExp ? (primaryExp['job_title']?.toString() ?? '') : '';
              final String companyName = youHaveExp ? (primaryExp['company_name']?.toString() ?? '') : '';
              final String salaryStr = youHaveExp ? (primaryExp['current_salary']?.toString() ?? '') : '';

              await prefs.setBool('user_${parsedUserId}_you_have_experience', youHaveExp);
              await prefs.setBool('you_have_experience', youHaveExp);
              await prefs.setString('user_${parsedUserId}_experience_id', expId);
              await prefs.setString('experience_id', expId);
              if (youHaveExp) {
                await prefs.setString('user_${parsedUserId}_job_title', jobTitle);
                await prefs.setString('job_title', jobTitle);
                await prefs.setString('user_${parsedUserId}_company_name', companyName);
                await prefs.setString('company_name', companyName);
                if (salaryStr.isNotEmpty) {
                  await prefs.setString('user_${parsedUserId}_experience_salary', salaryStr);
                  await prefs.setString('experience_salary', salaryStr);
                }
              } else {
                await prefs.setString('user_${parsedUserId}_job_title', '');
                await prefs.setString('job_title', '');
                await prefs.setString('user_${parsedUserId}_company_name', '');
                await prefs.setString('company_name', '');
                await prefs.remove('user_${parsedUserId}_experience_salary');
                await prefs.remove('experience_salary');
              }
            }
          }
        } catch (e) {
          debugPrint('Error pre-fetching experience details on OTP verification: $e');
        }

        int step = 1;
        bool isCompleted = false;

        if (hasBasicDetails) {
          step = 2;
          if (hasEduDetails) {
            step = 3;
            if (hasExpDetails) {
              step = 4;
              if (hasResume) {
                step = 5;
                isCompleted = true;
              }
            }
          }
        }

        await prefs.setInt('profile_creation_step', step);
        await prefs.setBool('is_profile_completed', isCompleted);

        try {
          final String suffix = '_$parsedUserId';
          final response = await ApplyJobApi.fetchAppliedJobs(userId: parsedUserId);
          if (response['status'] == 'success' || response['error'] == false) {
            final List<dynamic> appliedList = response['data'] ?? [];
            final List<String> newAppliedIds = [];
            for (final app in appliedList) {
              final String jobIdStr = (app['job_id'] ?? app['job id'] ?? app['job'] ?? app['id'] ?? '').toString();
              if (jobIdStr.isNotEmpty) {
                newAppliedIds.add(jobIdStr);
              }
            }
            await prefs.setStringList('applied_job_ids$suffix', newAppliedIds);
            await prefs.setBool('applied_job_ids_synced$suffix', true);
            ApplyJobApi.setAppliedJobIds(newAppliedIds);
          }

          final walkinResponse = await ApplyJobApi.fetchRegisteredWalkins(userId: parsedUserId);
          if (walkinResponse['status'] == 'success' || walkinResponse['error'] == false) {
            final List<dynamic> walkinList = walkinResponse['data'] ?? [];
            final List<String> newWalkinIds = [];
            for (final item in walkinList) {
              final String jobIdStr = (item['job_id'] ?? item['job id'] ?? item['job'] ?? item['id'] ?? '').toString();
              if (jobIdStr.isNotEmpty) {
                newWalkinIds.add(jobIdStr);
              }
            }
            await prefs.setStringList('registered_walkin_ids$suffix', newWalkinIds);
            await prefs.setBool('registered_walkin_ids_synced$suffix', true);
            ApplyJobApi.setRegisteredWalkinIds(newWalkinIds);
          }
        } catch (e) {
          debugPrint('Error pre-fetching applied/walkin jobs on OTP verification: $e');
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            SmoothPageRoute(
              child: isCompleted ? const HomeScreen() : const BuildProfileScreen(),
            ),
                (route) => false,
          );
        }
      } else {
        final String errorMsg =
            response['message'] ?? 'OTP verification failed';
        _showError(errorMsg);
      }
    } catch (e) {
      _showError('Verification error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: screenWidth * 0.05,
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
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.08),

              Row(
                children: [
                  Text(
                    'A 6-digit code was sent to ',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    widget.phoneNumber,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Icon(
                        Icons.edit,
                        color: AppColors.primary,
                        size: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Enter OTP Title
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      enableSuggestions: false,
                      style: TextStyle(color: textColor),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          if (_prevValues[index] == ' ') {
                            _controllers[index].text = ' ';
                            _prevValues[index] = ' ';
                            if (index > 0) {
                              _focusNodes[index - 1].requestFocus();
                              _controllers[index - 1].text = ' ';
                              _prevValues[index - 1] = ' ';
                            }
                          } else {
                            _controllers[index].text = ' ';
                            _prevValues[index] = ' ';
                          }
                        } else {
                          final digit = value.substring(value.length - 1);
                          _controllers[index].text = digit;
                          _prevValues[index] = digit;
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                          }
                        }
                        _checkOtpComplete();
                      },
                    ),
                  );
                }),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Resend OTP
              GestureDetector(
                onTap: _resendTimer == 0 ? _resendOtp : null,
                child: Text(
                  _resendTimer > 0
                      ? 'Resend OTP 00:${_resendTimer.toString().padLeft(2, '0')}'
                      : 'Resend OTP',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: _resendTimer > 0
                        ? subtitleColor
                        : AppColors.primary,
                    fontWeight: _resendTimer > 0
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Verify Button
              ElevatedButton(
                onPressed: _isOtpComplete ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                   disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  minimumSize: Size(double.infinity, screenHeight * 0.065),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.08),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
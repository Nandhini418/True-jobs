import 'package:flutter/material.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'package:truejobs/job_seeker_module/home_screen.dart';
import 'package:truejobs/job_seeker_module/build_profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/services/api/api_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:truejobs/services/api/version_api.dart';
import '../../constants/app_colors.dart';
import '../../services/api/banner_api.dart';
import '../../services/api/jobs_api.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/dashboard_holder.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/basic_detail_screen.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/company_details_screen.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<int> _text1TypingAnimation;
  late Animation<int> _text2TypingAnimation;
  late Animation<int> _text3TypingAnimation;
  late Animation<double> _buttonAnimation;
  bool _needsUpdate = false;
  String _downloadUrl = '';
  Widget? _nextScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack)),
    );
    
    _text1TypingAnimation = IntTween(begin: 0, end: 'Welcome to'.length).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.25, 0.45, curve: Curves.linear)),
    );
    
    _text2TypingAnimation = IntTween(begin: 0, end: 'True Jobs'.length).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.55, 0.75, curve: Curves.linear)),
    );
    
    _text3TypingAnimation = IntTween(begin: 0, end: 'Connecting Talent With Opportunity'.length).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.80, 0.95, curve: Curves.linear)),
    );
    
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.95, 1.0, curve: Curves.easeIn)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _animationController.forward();
      });
    });

    _initApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUpdateUrl() async {
    if (_downloadUrl.isNotEmpty) {
      final Uri url = Uri.parse(_downloadUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $_downloadUrl');
      }
    }
  }

  Future<void> _initApp() async {
    // Clear local session SharedPreferences data on restart
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('saved_job_ids') ||
            key.startsWith('saved_jobs_data') ||
            key.startsWith('applied_job_ids') ||
            key.startsWith('applied_jobs_data') ||
            key.startsWith('registered_walkin_ids') ||
            key.startsWith('registered_walkin_jobs_data') ||
            key.startsWith('shortlisted_job_ids') ||
            key.startsWith('interview_job_ids') ||
            key.startsWith('rejected_job_ids')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing local session SharedPreferences: $e');
    }

    // ── Device ID — runs on its own, independent of location ──────────
    // This does NOT depend on permission or GPS in any way, so it must
    // always run and must never be skipped because of a location issue.
    try {
      await ApiConfig.getDeviceId();
    } catch (e) {
      debugPrint('Error obtaining device id during splash: $e');
    }

    // ── Location — best effort only ────────────────────────────────────
    // Whether permission is granted, denied, or location services are
    // off, none of this should ever block the app from continuing.
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('Location services are disabled.');
        }

        if (serviceEnabled) {
          Position? position;
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );
          } catch (e) {
            debugPrint('Fresh GPS fix failed, trying last known: $e');
            position = await Geolocator.getLastKnownPosition();
          }

          if (position != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('latitude', position.latitude);
            await prefs.setDouble('longitude', position.longitude);
            await prefs.setString('lt', position.latitude.toString());
            await prefs.setString('ln', position.longitude.toString());
          }
        }
      }
    } catch (e) {
      debugPrint('Error obtaining location during splash: $e');
    }

    // Fetch banners from API & precache their images
    try {
      final bannerRes = await BannerApi.fetchBanners();
      if (bannerRes['error'] == false) {
        BannerApi.preloadedBanners = bannerRes['data'] ?? [];
        final List<dynamic> banners = BannerApi.preloadedBanners!;
        for (final item in banners) {
          final String? url = item['banner']?.toString();
          if (url != null && url.isNotEmpty && mounted) {
            try {
              await precacheImage(NetworkImage(url), context);
            } catch (e) {
              debugPrint('Error precaching banner image $url: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error pre-fetching banners on splash: $e');
    }

    // Pre-fetch Jobs Screen Data
    try {
      final jobsRes = await JobsApi.fetchJobs();
      JobsApi.preloadedJobs = JobsApi.parseJobList(jobsRes);
    } catch (e) {
      debugPrint('Error pre-fetching jobs on splash: $e');
    }

    // Precache essential static assets
    if (mounted) {
      final staticAssets = [
        'assets/header_logo.png',
        'assets/top_company_banner.png',
        'assets/mail.gif',
        'assets/whatsapp_icon.gif',
      ];
      for (final assetPath in staticAssets) {
        try {
          await precacheImage(AssetImage(assetPath), context);
        } catch (_) {}
      }
    }

    // Delay navigation so the splash screen displays for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Version check
    bool needsUpdate = false;
    String downloadUrl = '';

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String appVersion = packageInfo.buildNumber.isNotEmpty 
          ? packageInfo.buildNumber 
          : packageInfo.version;

      final res = await VersionApi.checkVersion(version: appVersion);
      if (res['error'] == false) {
        downloadUrl = (res['download_url'] ?? '').toString();
        
        // Use the API's update_required flag if available
        if (res.containsKey('update_required')) {
          needsUpdate = res['update_required'] == true || res['update_required'] == 'true';
        } else {
          // Fallback to checking the status or version string
          final String status = (res['status'] ?? '').toString();
          if (status.isNotEmpty && status != 'latest') {
            needsUpdate = true;
          } else {
            final String latestVersion = (res['latest_version'] ?? '').toString();
            if (latestVersion.isNotEmpty && latestVersion != appVersion && !latestVersion.contains(appVersion)) {
              needsUpdate = true;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
    }

    if (needsUpdate) {
      if (mounted) {
        setState(() {
          _needsUpdate = true;
          _downloadUrl = downloadUrl;
        });
      }
      return; // Do NOT navigate to the next screen!
    }

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      final bool isSessionValid = true;

      final bool isProfileCompleted = isSessionValid && (prefs.getBool('is_profile_completed') ?? false);
      final String? userRole = prefs.getString('user_role');

      Widget nextScreen;
      if (userId != null && isSessionValid) {
        if (userRole == 'recruiter') {
          // Fetch recruiter profile details
          final String token = prefs.getString('token') ?? '';
          final String mobile = prefs.getString('mobile') ?? '';
          final profileResponse = await BasicDetailApiService.fetchBasicDetails(
            userId: userId.toString(),
            token: token,
          );

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
            nextScreen = const DashboardHolder();
          } else if (hasBasicDetails && !hasCompanyDetails) {
            nextScreen = CompanyDetailsScreen(
              phone: mobile,
              userId: userId.toString(),
              token: token,
            );
          } else {
            nextScreen = EnteredNumberScreen(
              phone: mobile,
              userId: userId.toString(),
              token: token,
            );
          }
        } else {
          // Job Seeker
          nextScreen = isProfileCompleted ? const HomeScreen() : const BuildProfileScreen();
        }
      } else {
        nextScreen = const RoleSelectionScreen();
      }

      if (mounted) {
        setState(() {
          _nextScreen = nextScreen;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _needsUpdate 
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'A new version of the app is available!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _launchUpdateUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(screenWidth * 0.8, screenWidth * 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.2),
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: FadeTransition(
                      opacity: _logoAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/splash_logo.png',
                          width: screenWidth * 0.22,
                          height: screenWidth * 0.22,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                             return Image.asset('assets/header_logo.png', fit: BoxFit.contain);
                          }
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  AnimatedBuilder(
                    animation: _text1TypingAnimation,
                    builder: (context, child) {
                      String visibleText = 'Welcome to'.substring(0, _text1TypingAnimation.value);
                      return Text(
                        visibleText.isEmpty ? '\u200B' : visibleText,
                        style: TextStyle(
                          fontSize: screenWidth * 0.12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _text2TypingAnimation,
                    builder: (context, child) {
                      String visibleText = 'True Jobs'.substring(0, _text2TypingAnimation.value);
                      return Text(
                        visibleText.isEmpty ? '\u200B' : visibleText,
                        style: TextStyle(
                          fontSize: screenWidth * 0.12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  AnimatedBuilder(
                    animation: _text3TypingAnimation,
                    builder: (context, child) {
                      String visibleText = 'Connecting Talent With Opportunity'.substring(0, _text3TypingAnimation.value);
                      return Text(
                        visibleText.isEmpty ? '\u200B' : visibleText,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Color(0x551B1B1B),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _buttonAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          if (_nextScreen != null) {
                             Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => _nextScreen!,
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                                reverseTransitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                            'Let\'s Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
      ),
    );
  }
}

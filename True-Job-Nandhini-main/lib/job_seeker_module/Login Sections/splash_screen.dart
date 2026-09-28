import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:truejobs/common_screens/unified_login_screen.dart';
import 'package:truejobs/job_seeker_module/home_screen.dart';
import 'package:truejobs/job_seeker_module/build_profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/services/api/api_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:truejobs/services/api/version_api.dart';
import 'package:truejobs/services/api/profile_select_api.dart';
import '../../constants/app_colors.dart';
import '../../services/api/apply_job_api.dart';
import '../../services/api/banner_api.dart';
import '../../services/api/jobs_api.dart';
import '../../services/api/job_api.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/dashboard_holder.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/basic_detail_screen.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/company_details_screen.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _needsUpdate = false;
  String _downloadUrl = '';
  Widget? _nextScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initApp();
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

      if (userId != null) {
        try {
          final String suffix = '_$userId';

          // 1. Pre-fetch applied jobs & details
          final response = await ApplyJobApi.fetchAppliedJobs(userId: userId);
          if (response['status'] == 'success' || response['error'] == false) {
            final List<dynamic> appliedList = response['data'] ?? [];
            final List<String> newAppliedIds = [];
            final List<Map<String, dynamic>> mappedAppliedJobs = [];
            final List<String> newAppliedData = [];

            for (final app in appliedList) {
              final String jobIdStr = (app['job_id'] ?? app['job id'] ?? app['job'] ?? app['id'] ?? '').toString();
              if (jobIdStr.isNotEmpty) {
                newAppliedIds.add(jobIdStr);
              }
              Map<String, dynamic>? jobData;
              final int? jobId = int.tryParse(jobIdStr);
              if (jobId != null && JobsApi.preloadedJobs != null) {
                final match = JobsApi.preloadedJobs!.firstWhere(
                  (j) => j['id']?.toString() == jobIdStr,
                  orElse: () => {},
                );
                if (match.isNotEmpty) {
                  jobData = Map<String, dynamic>.from(match);
                }
              }
              if (jobData == null && jobId != null) {
                try {
                  final detailRes = await JobsApi.fetchJobDetails(jobId: jobId);
                  final parsed = JobsApi.parseJobList(detailRes);
                  if (parsed.isNotEmpty) {
                    jobData = parsed.first;
                  }
                } catch (_) {}
              }
              if (jobData == null && app is Map) {
                jobData = Map<String, dynamic>.from(app);
              }

              if (jobData != null) {
                final mapped = {
                  'id': jobData['id'] ?? jobIdStr,
                  'title': jobData['job_title'] ?? jobData['title'] ?? '',
                  'company': jobData['company_name'] ?? jobData['company'] ?? '',
                  'location': (jobData['location'] != null && jobData['location'].toString().trim().isNotEmpty)
                      ? jobData['location'].toString().trim()
                      : ((jobData['job_city'] ?? jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? 'Coimbatore').toString().trim().isNotEmpty
                          ? (jobData['job_city'] ?? jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? 'Coimbatore').toString().trim()
                          : 'Coimbatore'),
                  'exp': jobData['experience'] ?? jobData['exp'] ?? '',
                  'salary': (jobData['salary_from'] != null && jobData['salary_from'].toString().isNotEmpty)
                      ? '₹ ${jobData['salary_from']} - ₹ ${jobData['salary_to'] ?? ''} ${jobData['pay_type'] ?? ''}'
                      : (jobData['salary'] ?? ''),
                  'desc': jobData['job_description'] ?? jobData['job_desc'] ?? jobData['desc'] ?? '',
                  'time': jobData['dtime'] ?? '',
                  'logoText': (jobData['company_name'] ?? jobData['company'] ?? 'J').toString().trim().isNotEmpty
                      ? (jobData['company_name'] ?? jobData['company']).toString().trim().substring(0, 1).toUpperCase()
                      : 'J',
                  'logoBg': Colors.blue.shade50,
                  'logoColor': Colors.blue.shade700,
                  'walkInDate': jobData['walk_start'] ?? jobData['walkInDate'],
                  'walkInTime': jobData['walk_time_end'] ?? jobData['walk_time'] ?? jobData['walkInTime'] ?? '',
                  'walk_address': jobData['walk_address'] ?? jobData['office_address'] ?? '',
                  ...jobData,
                };
                mappedAppliedJobs.add(mapped);

                final cleanJob = Map<String, dynamic>.from(mapped);
                if (cleanJob['logoBg'] is Color) {
                  cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
                }
                if (cleanJob['logoColor'] is Color) {
                  cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
                }
                newAppliedData.add(json.encode(cleanJob));
              }
            }

            await prefs.setStringList('applied_job_ids$suffix', newAppliedIds);
            await prefs.setStringList('applied_jobs_data$suffix', newAppliedData);
            await prefs.setBool('applied_job_ids_synced$suffix', true);
            ApplyJobApi.setAppliedJobIds(newAppliedIds);
            ApplyJobApi.preloadedAppliedJobs = mappedAppliedJobs;
          }

          // 2. Pre-fetch registered walkins & details
          final walkinResponse = await ApplyJobApi.fetchRegisteredWalkins(userId: userId);
          if (walkinResponse['status'] == 'success' || walkinResponse['error'] == false) {
            final List<dynamic> walkinList = walkinResponse['data'] ?? [];
            final List<String> newWalkinIds = [];
            final List<Map<String, dynamic>> mappedWalkinJobs = [];
            final List<String> newWalkinData = [];

            for (final item in walkinList) {
              final String jobIdStr = (item['job_id'] ?? item['job id'] ?? item['job'] ?? item['id'] ?? '').toString();
              if (jobIdStr.isNotEmpty) {
                newWalkinIds.add(jobIdStr);
              }
              Map<String, dynamic>? jobData;
              final int? jobId = int.tryParse(jobIdStr);
              if (jobId != null && JobsApi.preloadedJobs != null) {
                final match = JobsApi.preloadedJobs!.firstWhere(
                  (j) => j['id']?.toString() == jobIdStr,
                  orElse: () => {},
                );
                if (match.isNotEmpty) {
                  jobData = Map<String, dynamic>.from(match);
                }
              }
              if (jobData == null && jobId != null) {
                try {
                  final detailRes = await JobsApi.fetchJobDetails(jobId: jobId);
                  final parsed = JobsApi.parseJobList(detailRes);
                  if (parsed.isNotEmpty) {
                    jobData = parsed.first;
                  }
                } catch (_) {}
              }
              if (jobData == null && item is Map) {
                jobData = Map<String, dynamic>.from(item);
              }

              if (jobData != null) {
                final mapped = {
                  'id': jobData['id'] ?? jobIdStr,
                  'title': jobData['job_title'] ?? jobData['title'] ?? '',
                  'company': jobData['company_name'] ?? jobData['company'] ?? '',
                  'location': (jobData['location'] != null && jobData['location'].toString().trim().isNotEmpty)
                      ? jobData['location'].toString().trim()
                      : ((jobData['job_city'] ?? jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? 'Coimbatore').toString().trim().isNotEmpty
                          ? (jobData['job_city'] ?? jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? 'Coimbatore').toString().trim()
                          : 'Coimbatore'),
                  'exp': jobData['experience'] ?? jobData['exp'] ?? '',
                  'salary': (jobData['salary_from'] != null && jobData['salary_from'].toString().isNotEmpty)
                      ? '₹ ${jobData['salary_from']} - ₹ ${jobData['salary_to'] ?? ''} ${jobData['pay_type'] ?? ''}'
                      : (jobData['salary'] ?? ''),
                  'desc': jobData['job_description'] ?? jobData['job_desc'] ?? jobData['desc'] ?? '',
                  'time': jobData['dtime'] ?? '',
                  'logoText': (jobData['company_name'] ?? jobData['company'] ?? 'J').toString().trim().isNotEmpty
                      ? (jobData['company_name'] ?? jobData['company']).toString().trim().substring(0, 1).toUpperCase()
                      : 'J',
                  'logoBg': Colors.blue.shade50,
                  'logoColor': Colors.blue.shade700,
                  'walkInDate': jobData['walk_start'] ?? jobData['walkInDate'],
                  'walkInTime': jobData['walk_time_end'] ?? jobData['walk_time'] ?? jobData['walkInTime'] ?? '',
                  'walk_address': jobData['walk_address'] ?? jobData['office_address'] ?? '',
                  ...jobData,
                };
                mappedWalkinJobs.add(mapped);

                final cleanJob = Map<String, dynamic>.from(mapped);
                if (cleanJob['logoBg'] is Color) {
                  cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
                }
                if (cleanJob['logoColor'] is Color) {
                  cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
                }
                newWalkinData.add(json.encode(cleanJob));
              }
            }

            await prefs.setStringList('registered_walkin_ids$suffix', newWalkinIds);
            await prefs.setStringList('registered_walkin_jobs_data$suffix', newWalkinData);
            await prefs.setBool('registered_walkin_ids_synced$suffix', true);
            ApplyJobApi.setRegisteredWalkinIds(newWalkinIds);
            ApplyJobApi.preloadedRegisteredWalkins = mappedWalkinJobs;
          }

          // 3. Pre-fetch saved jobs & details
          final String token = prefs.getString('token') ?? '';
          if (token.isNotEmpty) {
            final savedResponse = await JobApi.fetchSavedJobs(userId: userId, token: token);
            if (savedResponse['error'] == false) {
              final List<dynamic> savedList = savedResponse['data'] ?? [];
              final List<String> newSavedIds = [];
              final List<String> newSavedData = [];

              for (final item in savedList) {
                final String jobIdStr = (item['job_id'] ?? item['job id'] ?? item['job'] ?? item['id'] ?? '').toString();
                if (jobIdStr.isNotEmpty) {
                  newSavedIds.add(jobIdStr);
                }
                Map<String, dynamic>? jobData;
                final int? jobId = int.tryParse(jobIdStr);
                
                // First check preloaded jobs
                if (jobId != null && JobsApi.preloadedJobs != null) {
                  final match = JobsApi.preloadedJobs!.firstWhere(
                    (j) => j['id']?.toString() == jobIdStr,
                    orElse: () => {},
                  );
                  if (match.isNotEmpty) {
                    jobData = Map<String, dynamic>.from(match);
                  }
                }
                
                // Next check the item's job_details payload
                if (jobData == null && item['job_details'] is Map) {
                   jobData = Map<String, dynamic>.from(item['job_details']);
                   // Format it similarly to the other endpoints
                   jobData['id'] = jobIdStr;
                   jobData['company'] = jobData['company_name'] ?? '';
                   jobData['title'] = jobData['job_title'] ?? '';
                   jobData['exp'] = jobData['experience'] ?? '';
                   if (jobData['salary_range'] != null) {
                     jobData['salary'] = '₹ ${jobData['salary_range']} Monthly';
                   }
                }
                
                // Fallback to fetch Job details via API
                if (jobData == null && jobId != null) {
                  try {
                    final detailRes = await JobsApi.fetchJobDetails(jobId: jobId);
                    final parsed = JobsApi.parseJobList(detailRes);
                    if (parsed.isNotEmpty) {
                      jobData = parsed.first;
                    }
                  } catch (_) {}
                }

                if (jobData != null) {
                  final mapped = {
                    'id': jobData['id'] ?? jobIdStr,
                    'title': jobData['job_title'] ?? jobData['title'] ?? '',
                    'company': jobData['company_name'] ?? jobData['company'] ?? '',
                    'location': (jobData['location'] != null && jobData['location'].toString().trim().isNotEmpty)
                        ? jobData['location'].toString().trim()
                        : ((jobData['job_city'] ?? jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? 'Coimbatore').toString().trim().isNotEmpty
                            ? (jobData['job_city'] ?? jobData['job_area'] ?? jobData['walk_address'] ?? jobData['office_address'] ?? 'Coimbatore').toString().trim()
                            : 'Coimbatore'),
                    'exp': jobData['experience'] ?? jobData['exp'] ?? '',
                    'salary': (jobData['salary_from'] != null && jobData['salary_from'].toString().isNotEmpty)
                        ? '₹ ${jobData['salary_from']} - ₹ ${jobData['salary_to'] ?? ''} ${jobData['pay_type'] ?? ''}'
                        : (jobData['salary'] ?? ''),
                    'desc': jobData['job_description'] ?? jobData['job_desc'] ?? jobData['desc'] ?? '',
                    'time': jobData['dtime'] ?? '',
                    'logoText': (jobData['company_name'] ?? jobData['company'] ?? 'J').toString().trim().isNotEmpty
                        ? (jobData['company_name'] ?? jobData['company']).toString().trim().substring(0, 1).toUpperCase()
                        : 'J',
                    'logoBg': Colors.blue.shade50,
                    'logoColor': Colors.blue.shade700,
                    'walkInDate': jobData['walk_start'] ?? jobData['walkInDate'],
                    'walkInTime': jobData['walk_time_end'] ?? jobData['walk_time'] ?? jobData['walkInTime'] ?? '',
                    'walk_address': jobData['walk_address'] ?? jobData['office_address'] ?? '',
                    ...jobData,
                  };

                  final cleanJob = Map<String, dynamic>.from(mapped);
                  if (cleanJob['logoBg'] is Color) {
                    cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
                  }
                  if (cleanJob['logoColor'] is Color) {
                    cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
                  }
                  newSavedData.add(json.encode(cleanJob));
                }
              }

              await prefs.setStringList('saved_job_ids$suffix', newSavedIds);
              await prefs.setStringList('saved_jobs_data$suffix', newSavedData);
            }
          }
        } catch (e) {
          debugPrint('Error pre-fetching applied/walkin jobs on splash: $e');
        }
      }

      bool isSessionValid = true;
      if (userId != null) {
        try {
          final profileRes = await ProfileSelectApi.fetchProfile(userId: userId);
          if (profileRes['status'] == 'error' || profileRes['error'] == true) {
            final String msg = (profileRes['message'] ?? '').toString().toLowerCase();
            // Exclude genuine network/downtime errors to allow offline functionality
            if (!msg.contains('network error') && !msg.contains('server returned status code')) {
              isSessionValid = false;
            }
          }
        } catch (e) {
          debugPrint('Error validating session on splash: $e');
        }
      }

      if (!isSessionValid && userId != null) {
        // Clear SharedPreferences session data
        await prefs.remove('user_id');
        await prefs.remove('user_role');
        await prefs.remove('token');
        await prefs.remove('name');
        await prefs.remove('mobile');
        await prefs.remove('email');
        await prefs.remove('profile_image_url');
        await prefs.remove('profile_pic_path');
        await prefs.remove('resume');
        await prefs.remove('linkedin');
        await prefs.remove('portfolio');
        await prefs.remove('is_profile_completed');
        await prefs.remove('profile_creation_step');
        await prefs.remove('you_have_experience');
        await prefs.remove('job_title');
        await prefs.remove('company_name');
        await prefs.remove('user_${userId}_you_have_experience');
        await prefs.remove('user_${userId}_job_title');
        await prefs.remove('user_${userId}_company_name');
        await prefs.remove('user_${userId}_experience_id');
        await prefs.remove('experience_id');
      }

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
        nextScreen = const UnifiedLoginScreen();
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
                  SizedBox(height: screenHeight * 0.15),
                  Container(
                    width: screenWidth * 0.22,
                    height: screenWidth * 0.22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/splash_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                             return Image.asset('assets/header_logo.png', fit: BoxFit.contain);
                          }
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: screenWidth * 0.11,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'True Jobs',
                    style: TextStyle(
                      fontSize: screenWidth * 0.11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connecting Talent With Opportunity',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
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
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
      ),
    );
  }
}

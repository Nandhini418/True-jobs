import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../Jobs Sections/jobs_screen.dart';
import '../Profile Sections/profile_screen.dart';
import '../Jobs Sections/job_detail_screen.dart';
import '../../widgets/rupee_text.dart';
import '../../services/api/apply_job_api.dart';
import '../../services/api/jobs_api.dart';
import '../../services/api/job_api.dart';
import '../../constants/date_formatter.dart';
import '../../widgets/company_logo_widget.dart';

class MyJobsScreen extends StatefulWidget {
  final int initialTab;
  const MyJobsScreen({super.key, this.initialTab = 0});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  int _selectedTab = 0;
  int _bottomNavIndex = 2;
  bool _isLoading = ApplyJobApi.preloadedAppliedJobs == null;

  List<Map<String, dynamic>> _appliedJobsList =
      ApplyJobApi.preloadedAppliedJobs ?? [];
  List<Map<String, dynamic>> _savedJobsList = [];
  List<Map<String, dynamic>> _registeredWalkinsList =
      ApplyJobApi.preloadedRegisteredWalkins ?? [];
  List<Map<String, dynamic>> _shortlistedJobsList = [];
  List<Map<String, dynamic>> _interviewJobsList = [];
  List<Map<String, dynamic>> _rejectedJobsList = [];
  List<String> _savedJobIds = [];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _initSeedingAndLoad();
  }

  Future<String> _getUserSuffix() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId == null) {
      final String? userIdStr = prefs.getString('user_id');
      if (userIdStr != null) {
        userId = int.tryParse(userIdStr);
      }
    }
    if (userId == null) {
      final String? cidStr = prefs.getString('cid');
      if (cidStr != null) {
        userId = int.tryParse(cidStr);
      }
    }
    return userId != null ? '_$userId' : '_guest';
  }

  Future<int?> _getValidUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId == null) {
      final String? userIdStr = prefs.getString('user_id');
      if (userIdStr != null) {
        userId = int.tryParse(userIdStr);
      }
    }
    if (userId == null) {
      final String? cidStr = prefs.getString('cid');
      if (cidStr != null) {
        userId = int.tryParse(cidStr);
      }
    }
    return userId;
  }

  Future<void> _fetchAppliedJobsFromApi() async {
    if (_appliedJobsList.isEmpty && mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();
      final suffix = await _getUserSuffix();

      final response = await ApplyJobApi.fetchAppliedJobs(userId: userId);
      if (response['status'] == 'success' || response['error'] == false) {
        final List<dynamic> appliedList = response['data'] ?? [];
        final List<Map<String, dynamic>> mappedJobs = [];

        // Load existing cache
        final List<String> cachedData =
            prefs.getStringList('applied_jobs_data$suffix') ?? [];
        final Map<String, Map<String, dynamic>> cachedJobs = {};
        for (final item in cachedData) {
          try {
            final jobMap = Map<String, dynamic>.from(json.decode(item) as Map);
            if (jobMap['logoBg'] is int) {
              jobMap['logoBg'] = Color(jobMap['logoBg'] as int);
            }
            if (jobMap['logoColor'] is int) {
              jobMap['logoColor'] = Color(jobMap['logoColor'] as int);
            }
            final String id = jobMap['id'].toString();
            cachedJobs[id] = jobMap;
          } catch (e) {
            debugPrint('Error parsing cached job: $e');
          }
        }

        final List<String> newAppliedIds = [];
        final List<String> newAppliedData = [];

        for (final app in appliedList) {
          final String jobIdStr =
              (app['job_id'] ?? app['job id'] ?? app['job'] ?? app['id'] ?? '')
                  .toString();
          if (jobIdStr.isEmpty && app is! Map) continue;
          if (jobIdStr.isNotEmpty) {
            newAppliedIds.add(jobIdStr);
          }

          if (jobIdStr.isNotEmpty && cachedJobs.containsKey(jobIdStr)) {
            mappedJobs.add(cachedJobs[jobIdStr]!);
            final cleanJob = Map<String, dynamic>.from(cachedJobs[jobIdStr]!);
            if (cleanJob['logoBg'] is Color) {
              cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
            }
            if (cleanJob['logoColor'] is Color) {
              cleanJob['logoColor'] = (cleanJob['logoColor'] as Color)
                  .toARGB32();
            }
            newAppliedData.add(json.encode(cleanJob));
          } else {
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
                  final match = parsed.firstWhere(
                    (j) => j['id']?.toString() == jobIdStr,
                    orElse: () => {},
                  );
                  if (match.isNotEmpty) {
                    jobData = match;
                  }
                }
              } catch (e) {
                debugPrint('Error fetching details for job $jobId: $e');
              }
            }

            if (jobData == null && app is Map) {
              jobData = Map<String, dynamic>.from(app);
            }

            if (jobData != null) {
              final bool isDeleted =
                  (jobData['job_title'] ?? jobData['title'] ?? '')
                      .toString()
                      .trim()
                      .isEmpty &&
                  (jobData['company_name'] ?? jobData['company'] ?? '')
                      .toString()
                      .trim()
                      .isEmpty;
              final mapped = {
                'id': jobIdStr,
                'title': jobData['job_title'] ?? jobData['title'] ?? '',
                'company': jobData['company_name'] ?? jobData['company'] ?? '',
                'is_deleted': isDeleted,
                'location':
                    (jobData['location'] != null &&
                        jobData['location'].toString().trim().isNotEmpty)
                    ? jobData['location'].toString().trim()
                    : ((jobData['job_city'] ??
                                  jobData['job_area'] ??
                                  jobData['walk_address'] ??
                                  jobData['office_address'] ??
                                  'Coimbatore')
                              .toString()
                              .trim()
                              .isNotEmpty
                          ? (jobData['job_city'] ??
                                    jobData['job_area'] ??
                                    jobData['walk_address'] ??
                                    jobData['office_address'] ??
                                    'Coimbatore')
                                .toString()
                                .trim()
                          : 'Coimbatore'),
                'exp': jobData['experience'] ?? jobData['exp'] ?? '',
                'salary': _parseSalary(jobData),
                'desc':
                    jobData['job_description'] ??
                    jobData['job_desc'] ??
                    jobData['desc'] ??
                    '',
                'time': jobData['dtime'] ?? '',
                'logoText':
                    (jobData['company_name'] ?? jobData['company'] ?? 'J')
                        .toString()
                        .trim()
                        .isNotEmpty
                    ? (jobData['company_name'] ?? jobData['company'])
                          .toString()
                          .trim()
                          .substring(0, 1)
                          .toUpperCase()
                    : 'J',
                'logoBg': Colors.blue.shade50,
                'logoColor': Colors.blue.shade700,
                'walkInDate': jobData['walk_start'] ?? jobData['walkInDate'],
                'walkInTime':
                    jobData['walk_time_end'] ??
                    jobData['walk_time'] ??
                    jobData['walkInTime'] ??
                    '',
                'walk_address':
                    jobData['walk_address'] ?? jobData['office_address'] ?? '',
                ...jobData,
              };
              mappedJobs.add(mapped);

              final cleanJob = Map<String, dynamic>.from(mapped);
              if (cleanJob['logoBg'] is Color) {
                cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
              }
              if (cleanJob['logoColor'] is Color) {
                cleanJob['logoColor'] = (cleanJob['logoColor'] as Color)
                    .toARGB32();
              }
              newAppliedData.add(json.encode(cleanJob));
            }
          }
        }

        await prefs.setStringList('applied_job_ids$suffix', newAppliedIds);
        await prefs.setStringList('applied_jobs_data$suffix', newAppliedData);
        ApplyJobApi.setAppliedJobIds(newAppliedIds);
        ApplyJobApi.preloadedAppliedJobs = mappedJobs;

        if (mounted) {
          setState(() {
            _appliedJobsList = mappedJobs;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching applied jobs from API: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRegisteredWalkinsFromApi() async {
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();
      final suffix = await _getUserSuffix();

      final response = await ApplyJobApi.fetchRegisteredWalkins(userId: userId);
      if (response['status'] == 'success' || response['error'] == false) {
        final List<dynamic> walkinList = response['data'] ?? [];
        final List<Map<String, dynamic>> mappedJobs = [];

        final List<String> cachedData =
            prefs.getStringList('registered_walkin_jobs_data$suffix') ?? [];
        final Map<String, Map<String, dynamic>> cachedJobs = {};
        for (final item in cachedData) {
          try {
            final jobMap = Map<String, dynamic>.from(json.decode(item) as Map);
            if (jobMap['logoBg'] is int) {
              jobMap['logoBg'] = Color(jobMap['logoBg'] as int);
            }
            if (jobMap['logoColor'] is int) {
              jobMap['logoColor'] = Color(jobMap['logoColor'] as int);
            }
            final String id = jobMap['id'].toString();
            cachedJobs[id] = jobMap;
          } catch (e) {
            debugPrint('Error parsing cached walkin job: $e');
          }
        }

        final List<String> newWalkinIds = [];
        final List<String> newWalkinData = [];

        for (final item in walkinList) {
          final String jobIdStr =
              (item['job_id'] ??
                      item['job id'] ??
                      item['job'] ??
                      item['id'] ??
                      '')
                  .toString();
          if (jobIdStr.isEmpty && item is! Map) continue;
          if (jobIdStr.isNotEmpty) {
            newWalkinIds.add(jobIdStr);
          }

          if (jobIdStr.isNotEmpty && cachedJobs.containsKey(jobIdStr)) {
            mappedJobs.add(cachedJobs[jobIdStr]!);
            final cleanJob = Map<String, dynamic>.from(cachedJobs[jobIdStr]!);
            if (cleanJob['logoBg'] is Color) {
              cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
            }
            if (cleanJob['logoColor'] is Color) {
              cleanJob['logoColor'] = (cleanJob['logoColor'] as Color)
                  .toARGB32();
            }
            newWalkinData.add(json.encode(cleanJob));
          } else {
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
                  final match = parsed.firstWhere(
                    (j) => j['id']?.toString() == jobIdStr,
                    orElse: () => {},
                  );
                  if (match.isNotEmpty) {
                    jobData = match;
                  }
                }
              } catch (e) {
                debugPrint('Error fetching details for walkin job $jobId: $e');
              }
            }

            if (jobData == null && item is Map) {
              jobData = Map<String, dynamic>.from(item);
            }

            if (jobData != null) {
              final bool isDeleted =
                  (jobData['job_title'] ?? jobData['title'] ?? '')
                      .toString()
                      .trim()
                      .isEmpty &&
                  (jobData['company_name'] ?? jobData['company'] ?? '')
                      .toString()
                      .trim()
                      .isEmpty;
              final mapped = {
                'id': jobIdStr,
                'title': jobData['job_title'] ?? jobData['title'] ?? '',
                'company': jobData['company_name'] ?? jobData['company'] ?? '',
                'is_deleted': isDeleted,
                'location':
                    (jobData['location'] != null &&
                        jobData['location'].toString().trim().isNotEmpty)
                    ? jobData['location'].toString().trim()
                    : ((jobData['job_city'] ??
                                  jobData['job_area'] ??
                                  jobData['walk_address'] ??
                                  jobData['office_address'] ??
                                  'Coimbatore')
                              .toString()
                              .trim()
                              .isNotEmpty
                          ? (jobData['job_city'] ??
                                    jobData['job_area'] ??
                                    jobData['walk_address'] ??
                                    jobData['office_address'] ??
                                    'Coimbatore')
                                .toString()
                                .trim()
                          : 'Coimbatore'),
                'exp': jobData['experience'] ?? jobData['exp'] ?? '',
                'salary': _parseSalary(jobData),
                'desc':
                    jobData['job_description'] ??
                    jobData['job_desc'] ??
                    jobData['desc'] ??
                    '',
                'time': jobData['dtime'] ?? '',
                'logoText':
                    (jobData['company_name'] ?? jobData['company'] ?? 'J')
                        .toString()
                        .trim()
                        .isNotEmpty
                    ? (jobData['company_name'] ?? jobData['company'])
                          .toString()
                          .trim()
                          .substring(0, 1)
                          .toUpperCase()
                    : 'J',
                'logoBg': Colors.blue.shade50,
                'logoColor': Colors.blue.shade700,
                'walkInDate': jobData['walk_start'] ?? jobData['walkInDate'],
                'walkInTime':
                    jobData['walk_time_end'] ??
                    jobData['walk_time'] ??
                    jobData['walkInTime'] ??
                    '',
                'walk_address':
                    jobData['walk_address'] ?? jobData['office_address'] ?? '',
                ...jobData,
              };
              mappedJobs.add(mapped);

              final cleanJob = Map<String, dynamic>.from(mapped);
              if (cleanJob['logoBg'] is Color) {
                cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
              }
              if (cleanJob['logoColor'] is Color) {
                cleanJob['logoColor'] = (cleanJob['logoColor'] as Color)
                    .toARGB32();
              }
              newWalkinData.add(json.encode(cleanJob));
            }
          }
        }

        await prefs.setStringList('registered_walkin_ids$suffix', newWalkinIds);
        await prefs.setStringList(
          'registered_walkin_jobs_data$suffix',
          newWalkinData,
        );
        ApplyJobApi.setRegisteredWalkinIds(newWalkinIds);
        ApplyJobApi.preloadedRegisteredWalkins = mappedJobs;

        if (mounted) {
          setState(() {
            _registeredWalkinsList = mappedJobs;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching registered walkins from API: $e');
    }
  }

  Future<void> _initSeedingAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    // Do not seed any mock data, keep all lists empty by default
    if (prefs.getStringList('applied_job_ids$suffix') == null) {
      await prefs.setStringList('applied_job_ids$suffix', []);
      await prefs.setStringList('applied_jobs_data$suffix', []);
    }
    if (prefs.getStringList('saved_job_ids$suffix') == null) {
      await prefs.setStringList('saved_job_ids$suffix', []);
      await prefs.setStringList('saved_jobs_data$suffix', []);
    }
    if (prefs.getStringList('registered_walkin_ids$suffix') == null) {
      await prefs.setStringList('registered_walkin_ids$suffix', []);
      await prefs.setStringList('registered_walkin_jobs_data$suffix', []);
    }
    await prefs.setStringList('shortlisted_job_ids$suffix', []);
    await prefs.setStringList('interview_job_ids$suffix', []);
    await prefs.setStringList('rejected_job_ids$suffix', []);

    await _loadAllLists();
    _fetchAppliedJobsFromApi();
    _fetchRegisteredWalkinsFromApi();
  }

  Future<void> _loadAllLists() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> savedIds =
        prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> shortlistedIds =
        prefs.getStringList('shortlisted_job_ids$suffix') ?? [];
    final List<String> interviewIds =
        prefs.getStringList('interview_job_ids$suffix') ?? [];
    final List<String> rejectedIds =
        prefs.getStringList('rejected_job_ids$suffix') ?? [];

    final List<String> appliedData =
        prefs.getStringList('applied_jobs_data$suffix') ?? [];
    final List<String> savedData =
        prefs.getStringList('saved_jobs_data$suffix') ?? [];
    final List<String> registeredData =
        prefs.getStringList('registered_walkin_jobs_data$suffix') ?? [];

    List<Map<String, dynamic>> appliedList =
        ApplyJobApi.preloadedAppliedJobs ?? _parseJobsFromData(appliedData);
    List<Map<String, dynamic>> registeredList =
        ApplyJobApi.preloadedRegisteredWalkins ??
        _parseJobsFromData(registeredData);

    if (mounted) {
      setState(() {
        _savedJobIds = savedIds;
        _appliedJobsList = appliedList;
        _savedJobsList = _parseJobsFromData(savedData);
        _registeredWalkinsList = registeredList;
        _shortlistedJobsList = _filterJobs(shortlistedIds);
        _interviewJobsList = _filterJobs(interviewIds);
        _rejectedJobsList = _filterJobs(rejectedIds);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseJobsFromData(List<String> data) {
    return data.map((item) {
      final map = Map<String, dynamic>.from(json.decode(item) as Map);
      if (map['logoBg'] is int) {
        map['logoBg'] = Color(map['logoBg'] as int);
      }
      if (map['logoColor'] is int) {
        map['logoColor'] = Color(map['logoColor'] as int);
      }
      return map;
    }).toList();
  }

  List<Map<String, dynamic>> _filterJobs(List<String> ids) {
    return [];
  }

  String _parseSalary(Map<String, dynamic> jobData) {
    final rawFrom = jobData['salary_from'];
    final rawTo = jobData['salary_to'];
    final rawSalaryRange = jobData['salary_range'];
    final rawSalary = jobData['salary'];

    if (rawFrom != null && rawFrom.toString().trim().isNotEmpty) {
      final fromStr = rawFrom.toString().trim();
      final toStr = (rawTo != null && rawTo.toString().trim().isNotEmpty) ? rawTo.toString().trim() : '';
      return toStr.isNotEmpty ? '₹ $fromStr - ₹ $toStr Monthly' : '₹ $fromStr Monthly';
    } else if (rawSalaryRange != null && rawSalaryRange.toString().trim().isNotEmpty) {
      String rangeStr = rawSalaryRange.toString().trim();
      if (rangeStr.contains('-')) {
        final parts = rangeStr.split('-');
        return '₹ ${parts[0].trim()} - ₹ ${parts[1].trim()} Monthly';
      }
      return '₹ $rangeStr Monthly';
    } else if (rawSalary != null && rawSalary.toString().trim().isNotEmpty) {
      String salaryStr = rawSalary.toString().trim();
      final lower = salaryStr.toLowerCase();
      if (!lower.contains('monthly') && !lower.contains('yearly') && !lower.contains('annual') && !lower.contains('per month')) {
        return '$salaryStr Monthly';
      }
      return salaryStr;
    }
    return 'Not disclosed';
  }

  Future<void> _toggleSave(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> saved =
        prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> savedData =
        prefs.getStringList('saved_jobs_data$suffix') ?? [];
    final String idStr = jobId.toString();
    if (saved.contains(idStr)) {
      saved.remove(idStr);
      savedData.removeWhere((item) {
        final map = json.decode(item) as Map<String, dynamic>;
        return map['id'].toString() == idStr;
      });
    } else {
      Map<String, dynamic>? jobToSave;
      for (final j in _appliedJobsList + _registeredWalkinsList) {
        if (j['id'].toString() == idStr) {
          jobToSave = j;
          break;
        }
      }
      if (jobToSave != null) {
        final cleanJob = Map<String, dynamic>.from(jobToSave);
        if (cleanJob['logoBg'] is Color) {
          cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
        }
        if (cleanJob['logoColor'] is Color) {
          cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
        }
        saved.add(idStr);
        savedData.add(json.encode(cleanJob));
      }
    }
    await prefs.setStringList('saved_job_ids$suffix', saved);
    await prefs.setStringList('saved_jobs_data$suffix', savedData);
    _loadAllLists();

    final String userId = (prefs.getInt('user_id') ?? prefs.getString('user_id'))?.toString() ?? '';
    if (userId.isNotEmpty) {
      final String token = prefs.getString('token') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final double lat = prefs.getDouble('latitude') ?? 11.0;
      final double lng = prefs.getDouble('longitude') ?? 11.0;
      
      await JobApi.toggleSaveJob(
        jobId: idStr,
        userId: userId,
        token: token,
        lat: lat,
        lng: lng,
        deviceId: deviceId,
      );
    }
  }

  Future<T?> _pushFade<T>(Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 0),
        reverseTransitionDuration: const Duration(milliseconds: 0),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const JobsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 0),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        ),
      );
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 0),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        ),
      );
    } else {
      setState(() {
        _bottomNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sw * 0.02,
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                      size: sw * 0.05,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'My Jobs',
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sw * 0.02),

            // Tab Pill Selectors
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: Row(
                children: [
                  _buildTabPill('Applied', _appliedJobsList.length, 0, sw),
                  SizedBox(width: sw * 0.03),
                  _buildTabPill('Saved', _savedJobsList.length, 1, sw),
                  SizedBox(width: sw * 0.03),
                  _buildTabPill(
                    'Walkin Registered',
                    _registeredWalkinsList.length,
                    2,
                    sw,
                  ),
                  SizedBox(width: sw * 0.03),
                  _buildTabPill(
                    'Shortlisted',
                    _shortlistedJobsList.length,
                    3,
                    sw,
                  ),
                  SizedBox(width: sw * 0.03),
                  _buildTabPill('Interview', _interviewJobsList.length, 4, sw),
                  SizedBox(width: sw * 0.03),
                  _buildTabPill('Rejected', _rejectedJobsList.length, 5, sw),
                ],
              ),
            ),
            SizedBox(height: sw * 0.04),
            Divider(height: 1, color: Color(0xFFE4E4E4)),
            SizedBox(height: sw * 0.02),
            // Main Jobs List based on Active Tab
            Expanded(child: _buildJobsList(sw)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildTabPill(String label, int count, int index, double sw) {
    final isSelected = _selectedTab == index;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color bgColor = AppColors.dynamicBg;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.035,
          vertical: sw * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardBg,
          borderRadius: BorderRadius.circular(sw * 0.05),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : textColor,
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: sw * 0.02),
            Container(
              padding: EdgeInsets.all(sw * 0.01),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : textColor,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: sw * 0.05,
                minHeight: sw * 0.05,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    color: isSelected ? AppColors.primary : bgColor,
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(double sw) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;

    List<Map<String, dynamic>> list;
    String emptyMessage;

    switch (_selectedTab) {
      case 0:
        list = _appliedJobsList;
        emptyMessage = 'No applied jobs found.';
        break;
      case 1:
        list = _savedJobsList;
        emptyMessage = 'No saved jobs found.';
        break;
      case 2:
        list = _registeredWalkinsList;
        emptyMessage = 'No registered walk-ins found.';
        break;
      case 3:
        list = _shortlistedJobsList;
        emptyMessage = 'No shortlisted jobs found.';
        break;
      case 4:
        list = _interviewJobsList;
        emptyMessage = 'No interview scheduled jobs found.';
        break;
      case 5:
        list = _rejectedJobsList;
        emptyMessage = 'No rejected jobs found.';
        break;
      default:
        list = [];
        emptyMessage = 'No jobs found.';
    }

    if (_isLoading && list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: GoogleFonts.poppins(
            color: subtitleColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.04),
      itemCount: list.length,
      separatorBuilder: (context, index) => SizedBox(height: sw * 0.05),
      itemBuilder: (context, index) {
        final job = list[index];
        final String jobIdStr = job['id'].toString();
        final bool isSaved = _savedJobIds.contains(jobIdStr);
        final hasWalkIn =
            job['walkInDate'] != null &&
            (job['interview_method'] == 1 ||
                job['interview_method']?.toString() == '1');

        final bool isDeleted =
            job['is_deleted'] == true ||
            job['title'] == 'This job is no longer available';

        return GestureDetector(
          onTap: isDeleted
              ? null
              : () async {
                  await _pushFade(JobDetailScreen(job: job));
                  _loadAllLists();
                },
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(sw * 0.03),
              border: Border.all(color: Color(0xFFEFEFEF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000), // #00000014
                  offset: Offset(0, 10.85),
                  blurRadius: 21.71,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x0A000000), // #0000000A
                  offset: Offset(0, 0),
                  blurRadius: 5.43,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(sw * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CompanyLogoWidget(
                            companyId: job['recuriter_name']?.toString() ?? '',
                            fallbackText: job['logoText']?.toString() ?? 'T',
                            fallbackBgColor: job['logoBg'] is Color ? job['logoBg'] : Colors.blue.shade50,
                            fallbackTextColor: job['logoColor'] is Color ? job['logoColor'] : Colors.blue.shade700,
                            radius: 20.0,
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: sw * 0.04,
                                    color: textColor,
                                  ),
                                ),
                                if (job['company'] != null &&
                                    job['company'].toString().isNotEmpty)
                                  Text(
                                    job['company'] ?? '',
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: sw * 0.035,
                                    ),
                                  ),
                                if (job['is_deleted'] == true)
                                  Text(
                                    'This job is no longer available',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: sw * 0.034,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (job['is_deleted'] != true)
                            GestureDetector(
                              onTap: () => _toggleSave(job['id']),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.02,
                                  vertical: sw * 0.01,
                                ),
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: isSaved
                                          ? AppColors.primary
                                          : subtitleColor,
                                      size: sw * 0.045,
                                    ),
                                    SizedBox(width: sw * 0.01),
                                    Text(
                                      isSaved ? 'Saved' : 'Save',
                                      style: TextStyle(
                                        color: isSaved
                                            ? AppColors.primary
                                            : subtitleColor,
                                        fontSize: sw * 0.034,
                                        fontWeight: isSaved
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (job['is_deleted'] != true) ...[
                        SizedBox(height: sw * 0.03),
                        Row(
                          children: [
                            Image.asset(
                              'assets/location.png',
                              height: sw * 0.047,
                              color: subtitleColor,
                            ),
                            SizedBox(width: sw * 0.02),
                            Text(
                              job['location'] ?? '',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: sw * 0.038,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sw * 0.015),
                        Row(
                          children: [
                            Icon(
                              Icons.business_center,
                              size: sw * 0.045,
                              color: subtitleColor,
                            ),
                            SizedBox(width: sw * 0.02),
                            RupeeText(
                              text: '${job['exp']}  •  ${job['salary']}',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: sw * 0.035,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sw * 0.02),
                        Text(
                          job['job_description'] ?? job['desc'] ?? '',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: sw * 0.034,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasWalkIn && job['is_deleted'] != true) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                      vertical: sw * 0.02,
                    ),
                    color: AppColors.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                              size: sw * 0.045,
                            ),
                            SizedBox(width: sw * 0.01),
                            Text(
                              'Walk -In Interview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sw * 0.032,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          job['walkInDate'] ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * 0.032,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (job['is_deleted'] != true)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      sw * 0.04,
                      0,
                      sw * 0.04,
                      sw * 0.04,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: sw * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              convertToRelativeTime(job['time'] ?? '11h ago'),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: sw * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

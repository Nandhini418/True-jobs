import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../widgets/guest_popup.dart';
import 'view_company_screen.dart';
import 'resume_selection_screen.dart';
import '../../widgets/rupee_text.dart';
import 'sticky_tab_bar_delegate.dart';
import '../../widgets/company_logo_widget.dart';
import '../../services/api/apply_job_api.dart';
import '../../services/api/job_api.dart';
import '../../services/api/dropdown_cache.dart';
import '../../services/api/recruiter_view_api.dart';
import '../../constants/date_formatter.dart';
import '../Subscription Sections/pro_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  int _activeTabIndex = 0;
  bool _isDescriptionExpanded = false;

  List<String> get _tabs {
    final hasWalkIn =
        (_jobDetails['interview_method'] == 1 ||
            _jobDetails['interview_method']?.toString() == '1' ||
            widget.job['interview_method'] == 1 ||
            widget.job['interview_method']?.toString() == '1');

    if (hasWalkIn) {
      return const [
        'Job Details',
        'Walkin Details',
        'Key Skills',
        'Qualification',
      ];
    } else {
      return const [
        'Job Details',
        'Key Skills',
        'Qualification',
        'Recruiter Details',
      ];
    }
  }

  Map<String, dynamic> _jobDetails = {};
  bool _isLoading = false;
  bool _isSaved = false;
  bool _isRegistered = false;
  bool _isApplied = false;
  bool _showRecruiterDetails = false;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  bool _isProgrammaticScroll = false;

  final GlobalKey _jobDetailsKey = GlobalKey();
  final GlobalKey _walkinDetailsKey = GlobalKey();
  final GlobalKey _keySkillsKey = GlobalKey();
  final GlobalKey _qualificationKey = GlobalKey();
  final GlobalKey _recruiterDetailsKey = GlobalKey();

  Map<String, String> _jobTypeMap = {};
  Map<String, String> _workModeMap = {};
  Map<String, String> _perksMap = {};
  bool _isDropdownsLoading = true;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isProgrammaticScroll || !_scrollController.hasClients) return;

    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double tabHeight = MediaQuery.of(context).size.width * 0.14;
    const double extraMargin = 24.0;
    final double targetY = appBarHeight + statusBarHeight + tabHeight + extraMargin;

    final List<MapEntry<GlobalKey, int>> keyIndexPairs = [];
    for (int i = 0; i < _tabs.length; i++) {
      final String tabTitle = _tabs[i];
      if (tabTitle == 'Job Details') {
        keyIndexPairs.add(MapEntry(_jobDetailsKey, i));
      } else if (tabTitle == 'Walkin Details' || tabTitle == 'Walk-in Details') {
        keyIndexPairs.add(MapEntry(_walkinDetailsKey, i));
      } else if (tabTitle == 'Key Skills') {
        keyIndexPairs.add(MapEntry(_keySkillsKey, i));
      } else if (tabTitle == 'Qualification') {
        keyIndexPairs.add(MapEntry(_qualificationKey, i));
      } else if (tabTitle == 'Recruiter Details') {
        keyIndexPairs.add(MapEntry(_recruiterDetailsKey, i));
      }
    }

    int detectedIndex = 0;
    for (final pair in keyIndexPairs) {
      final key = pair.key;
      final idx = pair.value;
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final position = box.localToGlobal(Offset.zero);
          if (position.dy <= targetY + 30) {
            detectedIndex = idx;
          }
        }
      }
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      detectedIndex = _tabs.length - 1;
    }

    if (detectedIndex != _activeTabIndex && mounted) {
      setState(() {
        _activeTabIndex = detectedIndex;
      });
      _scrollToActiveTab(detectedIndex);
    }
  }

  void _scrollToActiveTab(int index) {
    if (!_tabScrollController.hasClients) return;
    final double tabWidth = MediaQuery.of(context).size.width * 0.28;
    final double targetOffset =
        (index * tabWidth) - (MediaQuery.of(context).size.width * 0.3);
    final double clampedOffset = targetOffset.clamp(
      0.0,
      _tabScrollController.position.maxScrollExtent,
    );
    _tabScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToSection(GlobalKey key) {
    _isProgrammaticScroll = true;
    final context = key.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero);
        final scrollPosition = _scrollController.position.pixels;

        final double appBarHeight = AppBar().preferredSize.height;
        final double statusBarHeight = MediaQuery.of(this.context).padding.top;
        final double tabHeight = MediaQuery.of(this.context).size.width * 0.14;
        const double extraMargin = 16.0;
        final double targetY =
            appBarHeight + statusBarHeight + tabHeight + extraMargin;

        final double offset = scrollPosition + position.dy - targetY;

        _scrollController
            .animateTo(
              offset.clamp(0.0, _scrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            )
            .then((_) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _isProgrammaticScroll = false;
              });
            });
      } else {
        _isProgrammaticScroll = false;
      }
    } else {
      _isProgrammaticScroll = false;
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      if (!DropdownCache.isLoaded) {
        await DropdownCache.preloadDropdowns();
      }

      if (mounted) {
        setState(() {
          _jobTypeMap = DropdownCache.jobTypeMap;
          _workModeMap = DropdownCache.workModeMap;
          _perksMap = DropdownCache.perksMap;
          _isDropdownsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dropdown data: $e');
      if (mounted) {
        setState(() {
          _isDropdownsLoading = false;
        });
      }
    }
  }

  String _getNamesFromIds(String commaSeparatedIds, Map<String, String> map) {
    if (commaSeparatedIds.isEmpty) return '';
    return commaSeparatedIds
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .map((id) => map[id] ?? id)
        .join(', ');
  }

  @override
  void initState() {
    super.initState();
    _jobDetails = Map<String, dynamic>.from(widget.job);
    final String jobIdStr = (_jobDetails['id'] ?? widget.job['id'] ?? '').toString();
    _isApplied = widget.job['isApplied'] == true ||
        widget.job['is_applied'] == true ||
        widget.job['applied'] == true ||
        ApplyJobApi.isApplied(jobIdStr);
    _isRegistered = widget.job['isRegistered'] == true ||
        widget.job['is_registered'] == true ||
        widget.job['registered'] == true ||
        ApplyJobApi.isRegistered(jobIdStr);
    _loadSaveState();
    _loadDropdownData();
    _scrollController.addListener(_onScroll);
    GoogleFonts.pendingFonts([GoogleFonts.poppins()]).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
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

  Future<void> _loadSaveState() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();

    // Load instantly from cache first
    final List<String> list = prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> registered =
        prefs.getStringList('registered_walkin_ids$suffix') ?? [];
    final List<String> applied =
        prefs.getStringList('applied_job_ids$suffix') ?? [];
    final String jobIdStr = _jobDetails['id'].toString();

    ApplyJobApi.setAppliedJobIds(applied);
    ApplyJobApi.setRegisteredWalkinIds(registered);

    if (mounted) {
      setState(() {
        _isSaved = list.contains(jobIdStr);
        _isRegistered = registered.contains(jobIdStr);
        _isApplied = applied.contains(jobIdStr);
        // Recruiter visibility is resolved from the API below
      });
    }

    // Check via SharedPreferences & local session memory whether this user has already unlocked recruiter details
    final int? userId = await _getValidUserId();
    if (userId != null && jobIdStr.isNotEmpty) {
      final List<String> unlockedJobs =
          prefs.getStringList('unlocked_recruiter_jobs$suffix') ?? [];
          
      final bool backendSaysUnlocked = 
          _jobDetails['is_unlocked'] == true || _jobDetails['is_unlocked']?.toString() == '1' || _jobDetails['is_unlocked']?.toString() == 'true' ||
          widget.job['is_unlocked'] == true || widget.job['is_unlocked']?.toString() == '1' || widget.job['is_unlocked']?.toString() == 'true' ||
          _jobDetails['unlocked'] == true || _jobDetails['unlocked']?.toString() == '1' || _jobDetails['unlocked']?.toString() == 'true' ||
          widget.job['unlocked'] == true || widget.job['unlocked']?.toString() == '1' || widget.job['unlocked']?.toString() == 'true';

      bool isUnlocked = backendSaysUnlocked || unlockedJobs.contains(jobIdStr) ||
          RecruiterViewApi.isUnlockedInSession(jobIdStr, userId.toString());

      if (mounted) {
        setState(() {
          _showRecruiterDetails = isUnlocked;
        });
      }
    }

    final bool isAppliedSynced =
        prefs.getBool('applied_job_ids_synced$suffix') ?? false;
    final bool isWalkinSynced =
        prefs.getBool('registered_walkin_ids_synced$suffix') ?? false;

    if (!isAppliedSynced || !isWalkinSynced) {
      final int? userId = await _getValidUserId();
      if (userId != null) {
        try {
          if (!isAppliedSynced) {
            final response = await ApplyJobApi.fetchAppliedJobs(userId: userId);
            if (response['status'] == 'success' || response['error'] == false) {
              final List<dynamic> appliedList = response['data'] ?? [];
              final List<String> newAppliedIds = [];

              for (final app in appliedList) {
                final String idStr = (app['job_id'] ?? app['job id'] ?? app['job'] ?? app['id'] ?? '').toString();
                if (idStr.isNotEmpty) {
                  newAppliedIds.add(idStr);
                }
              }

              await prefs.setStringList('applied_job_ids$suffix', newAppliedIds);
              await prefs.setBool('applied_job_ids_synced$suffix', true);
              ApplyJobApi.setAppliedJobIds(newAppliedIds);

              if (mounted) {
                setState(() {
                  _isApplied = newAppliedIds.contains(jobIdStr);
                });
              }
            }
          }

          if (!isWalkinSynced) {
            final walkinResponse = await ApplyJobApi.fetchRegisteredWalkins(userId: userId);
            if (walkinResponse['status'] == 'success' || walkinResponse['error'] == false) {
              final List<dynamic> walkinList = walkinResponse['data'] ?? [];
              final List<String> newWalkinIds = [];

              for (final item in walkinList) {
                final String idStr = (item['job_id'] ?? item['job id'] ?? item['job'] ?? item['id'] ?? '').toString();
                if (idStr.isNotEmpty) {
                  newWalkinIds.add(idStr);
                }
              }

              await prefs.setStringList('registered_walkin_ids$suffix', newWalkinIds);
              await prefs.setBool('registered_walkin_ids_synced$suffix', true);
              ApplyJobApi.setRegisteredWalkinIds(newWalkinIds);

              if (mounted) {
                setState(() {
                  _isRegistered = newWalkinIds.contains(jobIdStr);
                });
              }
            }
          }
        } catch (e) {
          debugPrint('Error syncing applied/walkin jobs in JobDetailScreen: $e');
        }
      }
    }
  }

  Future<void> _toggleSaveState() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> list = prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> savedData =
        prefs.getStringList('saved_jobs_data$suffix') ?? [];
    final String jobIdStr = _jobDetails['id'].toString();
    if (list.contains(jobIdStr)) {
      list.remove(jobIdStr);
      savedData.removeWhere((item) {
        final map = json.decode(item) as Map<String, dynamic>;
        return map['id'].toString() == jobIdStr;
      });
    } else {
      list.add(jobIdStr);
      final cleanJob = Map<String, dynamic>.from(_jobDetails);
      if (cleanJob['logoBg'] is Color) {
        cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
      }
      if (cleanJob['logoColor'] is Color) {
        cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
      }
      savedData.add(json.encode(cleanJob));
    }
    await prefs.setStringList('saved_job_ids$suffix', list);
    await prefs.setStringList('saved_jobs_data$suffix', savedData);
    _loadSaveState();

    final String userId = (prefs.getInt('user_id') ?? prefs.getString('user_id'))?.toString() ?? '';
    if (userId.isNotEmpty) {
      final String token = prefs.getString('token') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final double lat = prefs.getDouble('latitude') ?? 11.0;
      final double lng = prefs.getDouble('longitude') ?? 11.0;
      
      await JobApi.toggleSaveJob(
        jobId: jobIdStr,
        userId: userId,
        token: token,
        lat: lat,
        lng: lng,
        deviceId: deviceId,
      );
    }
  }

  Future<bool> _registerWalkIn() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> registered =
        prefs.getStringList('registered_walkin_ids$suffix') ?? [];
    final List<String> registeredData =
        prefs.getStringList('registered_walkin_jobs_data$suffix') ?? [];
    final String jobIdStr = _jobDetails['id'].toString();

    final int? userId = await _getValidUserId();
    bool isSuccess = false;

    if (userId != null) {
      try {
        final response = await ApplyJobApi.registerWalkInJob(
          jobId: jobIdStr,
          registerBy: userId.toString(),
        );
        
        if (response['status'] == 'success' || response['error'] == false || response['status'] == true) {
          isSuccess = true;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']?.toString() ?? 'Failed to register for walk-in'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      } catch (e) {
        debugPrint('Error registering walk-in job via API: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to register for walk-in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    if (isSuccess) {
      final cleanJob = Map<String, dynamic>.from(_jobDetails);
      if (cleanJob['logoBg'] is Color) {
        cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
      }
      if (cleanJob['logoColor'] is Color) {
        cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
      }

      if (!registered.contains(jobIdStr)) {
        registered.add(jobIdStr);
        registeredData.add(json.encode(cleanJob));
        await prefs.setStringList('registered_walkin_ids$suffix', registered);
        await prefs.setStringList(
          'registered_walkin_jobs_data$suffix',
          registeredData,
        );
      }
      ApplyJobApi.addRegisteredWalkinId(jobIdStr);
      _loadSaveState();
      return true;
    }
  }

  void _showSubscribeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/splash_logo.png', width: 40, height: 40),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Subscribe Plan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Please subscribe to a plan to unlock recruiter details.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.dynamicText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.dynamicSubtitle),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Subscribe Plan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callHR(String recruiterMobile) async {
    final String jobIdStr = _jobDetails['id'].toString();
    final int? userId = await _getValidUserId();
    if (userId != null && jobIdStr.isNotEmpty) {
      try {
        final responseData = await RecruiterViewApi.markRecruiterViewed(
          jobId: jobIdStr,
          userId: userId.toString(),
        );

        final bool isSuccess = responseData['status'] == true ||
            responseData['status']?.toString().toLowerCase() == 'true';

        if (!isSuccess) {
          final String msg = responseData['message']?.toString() ??
              'Please activate your plan to unlock recruiter details.';
          if (mounted) {
            _showSubscribeDialog(context, msg);
          }
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final suffix = await _getUserSuffix();
        final List<String> unlockedJobs =
            prefs.getStringList('unlocked_recruiter_jobs$suffix') ?? [];
        if (!unlockedJobs.contains(jobIdStr)) {
          unlockedJobs.add(jobIdStr);
          await prefs.setStringList('unlocked_recruiter_jobs$suffix', unlockedJobs);
        }

        if (responseData['data'] != null && responseData['data'] is Map) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          final String? mobile = dataMap['recruiter_mobile']?.toString();
          if (mobile != null && mobile.isNotEmpty && mobile != 'null') {
            recruiterMobile = mobile;
            _jobDetails['recruiter_mobile'] = mobile;
            _jobDetails['recuriter_mobile'] = mobile;
          }
          final String? email = dataMap['recruiter_email']?.toString();
          if (email != null && email.isNotEmpty && email != 'null') {
            _jobDetails['recruiter_email'] = email;
            _jobDetails['recuriter_email'] = email;
          }
        }
        if (mounted) {
          setState(() {
            _showRecruiterDetails = true;
          });
        }
      } catch (e) {
        debugPrint('Error checking recruiter view limit during call HR: $e');
      }
    }

    final String cleanNumber = recruiterMobile.replaceAll(RegExp(r'[\s\-]+'), '');
    if (cleanNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recruiter phone number not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch phone dialer for $recruiterMobile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching tel uri: $e');
    }
  }

  void _showRegistrationBottomSheet(BuildContext context, String recruiterMobile) {
    final walkInDate =
        _jobDetails['walk_start']?.toString() ??
        widget.job['walkInDate']?.toString() ??
        widget.job['walk_start']?.toString() ??
        '';
    final walkInTime =
        _jobDetails['walk_timing']?.toString() ??
        widget.job['walkInTime']?.toString() ??
        widget.job['walk_timing']?.toString() ??
        '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double sw = screenSize.width;
        final double sh = screenSize.height;
        final Color textColor = AppColors.dynamicText;
        final Color subtitleColor = AppColors.dynamicSubtitle;
        final Color cardBg = AppColors.dynamicCardBg;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.only(bottom: sw * 0.04),
                width: sw * 0.12,
                height: sw * 0.12,
                decoration: BoxDecoration(
                  color: cardBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: textColor,
                  size: sw * 0.06,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                sw * 0.06,
                sw * 0.08,
                sw * 0.06,
                sw * 0.08,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: sw * 0.07,
                            height: sw * 0.07,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: sw * 0.045,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: sh * 0.08,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(width: sw * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered for walk-in',
                              style: GoogleFonts.poppins(
                                fontSize: sw * 0.045,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: sw * 0.015),
                            Text(
                              'Date: $walkInDate',
                              style: GoogleFonts.poppins(
                                fontSize: sw * 0.035,
                                color: subtitleColor,
                              ),
                            ),
                            SizedBox(height: sw * 0.005),
                            Text(
                              'Time: $walkInTime',
                              style: GoogleFonts.poppins(
                                fontSize: sw * 0.035,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: sw * 0.07,
                        height: sw * 0.07,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.04),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: sw * 0.005),
                          child: Text(
                            'Call the HR now to discuss the next steps for this job',
                            style: GoogleFonts.poppins(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.08),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: sh * 0.06,
                          height: sh * 0.06,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(sw * 0.025),
                            child: Image.asset(
                              'assets/whatsapp_icon.gif',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.04),
                      Expanded(
                        child: SizedBox(
                          height: sh * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _callHR(recruiterMobile);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                            ),
                            child: Text(
                              'Call HR',
                              style: GoogleFonts.poppins(
                                fontSize: sw * 0.042,
                                fontWeight: FontWeight.bold,
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
          ],
        );
      },
    );
  }

  Widget _buildCompanyLogo(double sw, String companyName) {
    final firstLetter =
        companyName.trim().isNotEmpty ? companyName.trim()[0].toUpperCase() : 'T';
    final String recruiterId = (_jobDetails['recuriter_name'] ?? widget.job['recuriter_name'])?.toString() ?? '';

    return CompanyLogoWidget(
      companyId: recruiterId,
      fallbackText: firstLetter,
      fallbackBgColor: const Color(0xFFE8F1FF),
      fallbackTextColor: const Color(0xFF0052CC),
      radius: sw * 0.07,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;

    // Use real API job data passed from API or widget
    final title = (_jobDetails['job_title'] ??
            _jobDetails['title'] ??
            widget.job['job_title'] ??
            widget.job['title'] ??
            '')
        .toString()
        .trim();

    final jobTitleCat = (_jobDetails['job_title_cat'] ??
            _jobDetails['add_cat_job'] ??
            widget.job['job_title_cat'] ??
            widget.job['add_cat_job'] ??
            '')
        .toString()
        .trim();

    final company = (_jobDetails['company_name'] ??
            _jobDetails['company'] ??
            widget.job['company_name'] ??
            widget.job['company'] ??
            '')
        .toString()
        .trim();

    String locVal = (_jobDetails['location']?.toString() ?? '').trim();
    if (locVal.isEmpty) {
      locVal = (_jobDetails['job_city']?.toString() ?? '').trim();
    }
    if (locVal.isEmpty) {
      locVal = (widget.job['location']?.toString() ?? widget.job['job_city']?.toString() ?? '').trim();
    }
    final officeAddr = (_jobDetails['job_area']?.toString() ?? widget.job['job_area']?.toString() ?? '').trim();
    final locationText = [officeAddr, locVal].where((s) => s.isNotEmpty).join(', ');
    final location = locationText.isNotEmpty ? locationText : locVal;

    final workLocType = (_jobDetails['work_loc_type']?.toString() ?? widget.job['work_loc_type']?.toString() ?? '').trim();
    final badgeWorkLoc = workLocType.isNotEmpty ? (_isDropdownsLoading ? 'Loading...' : _getNamesFromIds(workLocType, _workModeMap)) : '';

    final jobType = (_jobDetails['job_type']?.toString() ?? widget.job['job_type']?.toString() ?? '').trim();
    final badgeJobType = jobType.isNotEmpty ? (_isDropdownsLoading ? 'Loading...' : _getNamesFromIds(jobType, _jobTypeMap)) : '';

    final String jobIdStrTemp = (_jobDetails['id'] ?? widget.job['id'] ?? '0')
        .toString();
    final int jobIdInt = int.tryParse(jobIdStrTemp) ?? 0;
    final int baseApplicants = jobIdInt > 0 ? (jobIdInt * 3 + 17) % 89 + 12 : 0;
    final int actualApplicants = _isApplied
        ? baseApplicants + 1
        : baseApplicants;
    final String applicantsCount =
        (_jobDetails['applicants_count'] ??
                _jobDetails['applied_count'] ??
                _jobDetails['applicants'] ??
                widget.job['applicants_count'] ??
                widget.job['applied_count'] ??
                (actualApplicants > 0 ? actualApplicants.toString() : '0'))
            .toString();

    final exp = (_jobDetails['experience'] ??
            _jobDetails['exp'] ??
            widget.job['experience'] ??
            widget.job['exp'] ??
            '')
        .toString()
        .trim();

    final rawFrom = _jobDetails['salary_from'] ?? widget.job['salary_from'];
    final rawTo = _jobDetails['salary_to'] ?? widget.job['salary_to'];
    final rawPayType = (_jobDetails['pay_type'] ?? widget.job['pay_type'] ?? '').toString().trim();
    final payTypeStr = rawPayType.isNotEmpty ? rawPayType : '';
    final rawSalary = _jobDetails['salary'] ?? widget.job['salary'];

    String salary = '';
    if (rawFrom != null && rawFrom.toString().trim().isNotEmpty) {
      final fromStr = rawFrom.toString().trim();
      final toStr = (rawTo != null && rawTo.toString().trim().isNotEmpty)
          ? rawTo.toString().trim()
          : '';
      salary = toStr.isNotEmpty ? '₹ $fromStr - ₹ $toStr $payTypeStr' : '₹ $fromStr $payTypeStr';
    } else if (rawSalary != null && rawSalary.toString().trim().isNotEmpty) {
      salary = rawSalary.toString().trim();
      if (!salary.contains('₹') && !salary.contains('Rs') && !salary.contains('INR')) {
        salary = '₹ $salary';
      }
    } else {
      salary = 'Salary Not Disclosed';
    }

    final String relativeTime = _jobDetails['dtime'] != null
        ? convertToRelativeTime(_jobDetails['dtime'])
        : (widget.job['posted'] ?? widget.job['time'] ?? widget.job['dtime'] ?? '');
    final posted = relativeTime.isNotEmpty
        ? (relativeTime.startsWith('Posted') ? relativeTime : 'Posted $relativeTime')
        : '';

    String recruiterEmail = (_jobDetails['recuriter_email'] ??
            _jobDetails['recruiter_email'] ??
            widget.job['recuriter_email'] ??
            widget.job['recruiter_email'] ??
            '')
        .toString()
        .trim();

    String recruiterMobile = (_jobDetails['recuriter_mobile'] ??
            _jobDetails['recruiter_mobile'] ??
            widget.job['recuriter_mobile'] ??
            widget.job['recruiter_mobile'] ??
            '')
        .toString()
        .trim();

    final hasWalkIn =
        (_jobDetails['walk_address'] != null ||
            _jobDetails['walk_start'] != null ||
            widget.job['walk_address'] != null ||
            widget.job['walk_start'] != null ||
            widget.job['walkInDate'] != null) &&
        (_jobDetails['interview_method'] == 1 ||
            _jobDetails['interview_method']?.toString() == '1' ||
            widget.job['interview_method'] == 1 ||
            widget.job['interview_method']?.toString() == '1');

    final walkInDateRange =
        (_jobDetails['walk_start'] != null && _jobDetails['walk_end'] != null)
        ? '${_jobDetails['walk_start']} - ${_jobDetails['walk_end']}'
        : (_jobDetails['walk_start'] ?? widget.job['walkInDateRange'] ?? widget.job['walk_start'] ?? '').toString();

    final walkInTime =
        (_jobDetails['walk_timing'] != null &&
            _jobDetails['walk_time_end'] != null)
        ? '${_jobDetails['walk_timing']} - ${_jobDetails['walk_time_end']}'
        : (_jobDetails['walk_timing'] ?? widget.job['walkInTime'] ?? widget.job['walk_timing'] ?? '').toString();

    final String rawDesc = (_jobDetails['job_description'] ??
            _jobDetails['job_desc'] ??
            _jobDetails['desc'] ??
            widget.job['job_description'] ??
            widget.job['job_desc'] ??
            widget.job['desc'] ??
            '')
        .toString()
        .trim();
    final String descriptionText = rawDesc.isNotEmpty ? rawDesc : 'No description provided.';

    final String rawSkills = (_jobDetails['skills'] ?? widget.job['skills'] ?? '').toString().trim();

    final String rawResponsibilities = (_jobDetails['responsibilities'] ??
            _jobDetails['job_responsibilities'] ??
            widget.job['responsibilities'] ??
            '')
        .toString()
        .trim();

    final String rawQual = (_jobDetails['qualification'] ??
            _jobDetails['qualification_cat'] ??
            _jobDetails['ug_course'] ??
            widget.job['qualification'] ??
            widget.job['qualification_cat'] ??
            '')
        .toString()
        .trim();

    final String rawPerks = (_jobDetails['perks'] ??
            _jobDetails['benefits'] ??
            _jobDetails['perks_benefits'] ??
            widget.job['perks'] ??
            widget.job['perks_benefits'] ??
            '')
        .toString()
        .trim();

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isSaved ? AppColors.primary : textColor,
              size: sw * 0.055,
            ),
            onPressed: () => _toggleSaveState(),
          ),
          IconButton(
            icon: Icon(Icons.share, color: textColor, size: sw * 0.055),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(
                color: AppColors.primary,
                minHeight: 2,
              ),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.05,
                        vertical: sw * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Header Row: Logo + (Title & Company) + Posted time
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCompanyLogo(sw, company),
                              SizedBox(width: sw * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: sw * 0.038,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    if (jobTitleCat.isNotEmpty) ...[
                                      SizedBox(height: sw * 0.005),
                                      Text(
                                        jobTitleCat,
                                        style: TextStyle(
                                          fontSize: sw * 0.034,
                                          fontWeight: FontWeight.w600,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: sw * 0.008),
                                    Text(
                                      company,
                                      style: TextStyle(
                                        fontSize: sw * 0.034,
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: sw * 0.02),
                              Text(
                                posted,
                                style: TextStyle(
                                  fontSize: sw * 0.03,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.03),

                          // Location Row
                          Row(
                            children: [
                              Image.asset(
                                'assets/location.png',
                                height: sw * 0.045,
                                color: AppColors.grey,
                              ),
                              SizedBox(width: sw * 0.02),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: sw * 0.035,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.015),

                          // Salary Row
                          Row(
                            children: [
                              RupeeText(
                                text: salary,
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.03),

                          // Work Type Badge Row
                          Row(
                            children: [
                              _buildWorkTypeBadge(
                                'assets/image/building.png',
                                badgeWorkLoc,
                                sw,
                              ),
                              SizedBox(width: sw * 0.03),
                              _buildWorkTypeBadge(
                                'assets/image/f.png',
                                badgeJobType,
                                sw,
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.05),

                          // Openings / Applicants / Years Card
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x05000000), // ~2% opacity
                                  offset: Offset(0, 0),
                                  blurRadius: 6,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildMetricItem(
                                    icon: Icons.work_outline,
                                    iconColor: const Color(0xFF34A269),
                                    value:
                                        _jobDetails['vaccancy']
                                                ?.toString()
                                                .isNotEmpty ==
                                            true
                                        ? _jobDetails['vaccancy'].toString()
                                        : '3',
                                    label: 'Openings',
                                    sw: sw,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: sw * 0.15,
                                  color: borderColor,
                                ),
                                Expanded(
                                  child: _buildMetricItem(
                                    icon: Icons.groups_outlined,
                                    iconColor: const Color(0xFF7F68D6),
                                    value: applicantsCount,
                                    label: 'Applicants',
                                    sw: sw,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: sw * 0.15,
                                  color: borderColor,
                                ),
                                Expanded(
                                  child: _buildMetricItem(
                                    icon: Icons.description_outlined,
                                    iconColor: const Color(0xFFDF8F3F),
                                    value: exp.split(' ').first,
                                    label: 'Years',
                                    sw: sw,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      height: sw * 0.14,
                      child: Container(
                        color: bgColor,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: borderColor,
                                  width: 0.8,
                                ),
                              ),
                            ),
                            child: SingleChildScrollView(
                              controller: _tabScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: List.generate(_tabs.length, (index) {
                                  final isSelected = _activeTabIndex == index;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index == _tabs.length - 1
                                          ? 0
                                          : sw * 0.05,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _activeTabIndex = index;
                                        });
                                        _scrollToActiveTab(index);
                                        final String tabTitle = _tabs[index];
                                        if (tabTitle == 'Job Details') {
                                          _scrollToSection(_jobDetailsKey);
                                        } else if (tabTitle ==
                                                'Walkin Details' ||
                                            tabTitle == 'Walk-in Details') {
                                          _scrollToSection(_walkinDetailsKey);
                                        } else if (tabTitle == 'Key Skills') {
                                          _scrollToSection(_keySkillsKey);
                                        } else if (tabTitle ==
                                            'Qualification') {
                                          _scrollToSection(_qualificationKey);
                                        } else if (tabTitle ==
                                            'Recruiter Details') {
                                          _scrollToSection(
                                            _recruiterDetailsKey,
                                          );
                                        }
                                      },
                                      child: IntrinsicWidth(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0,
                                              ),
                                              child: Text(
                                                _tabs[index],
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.visible,
                                                style: GoogleFonts.poppins(
                                                  fontSize: sw * 0.038,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? textColor
                                                      : subtitleColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: sw * 0.02),
                                            Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        3,
                                                      ),
                                                      topRight: Radius.circular(
                                                        3,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.05,
                      vertical: sw * 0.02,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: sw * 0.04),
                          // Job Description Section
                          Text(
                            key: _jobDetailsKey,
                            'JOB DESCRIPITON',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: sw * 0.02),
                          Text(
                            _isDescriptionExpanded
                                ? (descriptionText.length > 200 && !_isDescriptionExpanded
                                    ? '${descriptionText.substring(0, 200)}...'
                                    : descriptionText)
                                : (descriptionText.length > 200
                                    ? '${descriptionText.substring(0, 200)}...'
                                    : descriptionText),
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              color: subtitleColor,
                              height: 1.5,
                            ),
                          ),
                          if (descriptionText.length > 200) ...[
                            SizedBox(height: sw * 0.02),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded =
                                      !_isDescriptionExpanded;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _isDescriptionExpanded
                                        ? 'Show Less'
                                        : 'Show More',
                                    style: TextStyle(
                                      fontSize: sw * 0.035,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    _isDescriptionExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.primary,
                                    size: sw * 0.05,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (hasWalkIn) ...[
                            SizedBox(height: sw * 0.04),
                            Container(
                              key: _walkinDetailsKey,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor),
                              ),
                              padding: EdgeInsets.all(sw * 0.045),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Walk-in Details',
                                    style: TextStyle(
                                      fontSize: sw * 0.042,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: sw * 0.015),
                                  Text(
                                    'Apply for the job and call HR to confirm interview',
                                    style: TextStyle(
                                      fontSize: sw * 0.034,
                                      color: subtitleColor,
                                    ),
                                  ),
                                  if (walkInDateRange.isNotEmpty) ...[
                                    SizedBox(height: sw * 0.04),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.calendar_month_outlined,
                                          size: sw * 0.05,
                                          color: textColor,
                                        ),
                                        SizedBox(width: sw * 0.03),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date',
                                              style: TextStyle(
                                                fontSize: sw * 0.032,
                                                color: subtitleColor,
                                              ),
                                            ),
                                            SizedBox(height: sw * 0.004),
                                            Text(
                                              walkInDateRange,
                                              style: TextStyle(
                                                fontSize: sw * 0.037,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (walkInTime.isNotEmpty) ...[
                                    SizedBox(height: sw * 0.035),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: sw * 0.05,
                                          color: textColor,
                                        ),
                                        SizedBox(width: sw * 0.03),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Time',
                                              style: TextStyle(
                                                fontSize: sw * 0.032,
                                                color: subtitleColor,
                                              ),
                                            ),
                                            SizedBox(height: sw * 0.004),
                                            Text(
                                              walkInTime,
                                              style: TextStyle(
                                                fontSize: sw * 0.037,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: sw * 0.045),
                          Divider(color: borderColor),
                          SizedBox(height: sw * 0.04),

                          // Key Skills Section
                          Text(
                            key: _keySkillsKey,
                            'Key Skills',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: sw * 0.03),
                          Wrap(
                            spacing: sw * 0.02,
                            runSpacing: sw * 0.02,
                            children: (rawSkills.isNotEmpty
                                    ? rawSkills
                                        .split(',')
                                        .map((s) => s.trim())
                                        .where((s) => s.isNotEmpty)
                                        .toList()
                                    : ['As per job requirement'])
                                .map((skill) => _buildSkillBadge(skill, sw))
                                .toList(),
                          ),
                          SizedBox(height: sw * 0.06),

                          Divider(color: borderColor),
                          SizedBox(height: sw * 0.04),

                          // Responsibilities Section (Render if provided in API)
                          if (rawResponsibilities.isNotEmpty) ...[
                            Text(
                              'Responsibilities',
                              style: TextStyle(
                                fontSize: sw * 0.045,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: sw * 0.03),
                            ..._buildBulletPoints(
                              rawResponsibilities
                                  .split('.')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .map((s) => s.endsWith('.') ? s : '$s.')
                                  .toList(),
                              sw,
                              bulletColor: Colors.blue.shade700,
                            ),
                            SizedBox(height: sw * 0.05),
                          ],

                          // Qualifications Card
                          Container(
                            key: _qualificationKey,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            padding: EdgeInsets.all(sw * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Qualifications
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(sw * 0.02),
                                      decoration: BoxDecoration(
                                        color: AppColors.iconGreen.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.school,
                                        color: AppColors.iconGreen,
                                        size: sw * 0.05,
                                      ),
                                    ),
                                    SizedBox(width: sw * 0.03),
                                    Text(
                                      'Qualifications',
                                      style: TextStyle(
                                        fontSize: sw * 0.036,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: sw * 0.03),
                                ..._buildBulletPoints(
                                  rawQual.isNotEmpty
                                      ? rawQual
                                          .split('.')
                                          .map((s) => s.trim())
                                          .where((s) => s.isNotEmpty)
                                          .map((s) => s.endsWith('.') ? s : '$s.')
                                          .toList()
                                      : ['As per job requirement.'],
                                  sw,
                                  bulletColor: Colors.blue.shade700,
                                ),
                                if (rawPerks.isNotEmpty) ...[
                                  SizedBox(height: sw * 0.04),
                                  const Divider(),
                                  SizedBox(height: sw * 0.04),
                                  // Perks & Benefits
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(sw * 0.02),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.card_giftcard,
                                          color: Colors.orange.shade700,
                                          size: sw * 0.05,
                                        ),
                                      ),
                                      SizedBox(width: sw * 0.03),
                                      Text(
                                        'Perks & Benefits',
                                        style: TextStyle(
                                          fontSize: sw * 0.036,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: sw * 0.03),
                                  ..._buildBulletPoints(
                                    rawPerks
                                        .split(',')
                                        .map((s) => s.trim())
                                        .where((s) => s.isNotEmpty)
                                        .map((id) => _perksMap[id] ?? (_isDropdownsLoading ? 'Loading...' : id))
                                        .map((s) => s.endsWith('.') ? s : '$s.')
                                        .toList(),
                                    sw,
                                    bulletColor: Colors.orange.shade700,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: sw * 0.05),
                          Row(
                            children: [
                              Image.asset(
                                'assets/location.png',
                                height: sw * 0.045,
                                color: subtitleColor,
                              ),
                              SizedBox(width: sw * 0.015),
                              Text(
                                location,
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.015),
                          RupeeText(
                            text: salary,
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: sw * 0.04),

                          // Recruiter Card
                          Container(
                            key: _recruiterDetailsKey,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            padding: EdgeInsets.all(sw * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: sw * 0.06,
                                      backgroundColor: const Color(0xFFC8E6C9),
                                      child: Text(
                                        'HR',
                                        style: TextStyle(
                                          color: AppColors.iconGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: sw * 0.045,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: sw * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Recruiter',
                                            style: TextStyle(
                                              fontSize: sw * 0.035,
                                              color: subtitleColor,
                                            ),
                                          ),
                                          SizedBox(height: sw * 0.015),
                                          Text(
                                            'HR Team - $company',
                                            style: TextStyle(
                                              fontSize: sw * 0.036,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: sw * 0.04),

                                // Contact Info
                                if (!_showRecruiterDetails) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final String jobIdStr = _jobDetails['id'].toString();
                                        final int? userId = await _getValidUserId();
                                        // Call API to record the recruiter view (type 1153)
                                        if (userId != null && jobIdStr.isNotEmpty) {
                                          try {
                                            final responseData = await RecruiterViewApi.markRecruiterViewed(
                                              jobId: jobIdStr,
                                              userId: userId.toString(),
                                            );

                                            final bool isSuccess = responseData['status'] == true ||
                                                responseData['status']?.toString().toLowerCase() == 'true';

                                            if (!isSuccess) {
                                              final String msg = responseData['message']?.toString() ??
                                                  'Please activate your plan to unlock recruiter details.';
                                              if (mounted) {
                                                _showSubscribeDialog(context, msg);
                                              }
                                              return;
                                            }

                                            final prefs = await SharedPreferences.getInstance();
                                            final suffix = await _getUserSuffix();
                                            final List<String> unlockedJobs =
                                                prefs.getStringList('unlocked_recruiter_jobs$suffix') ?? [];
                                            if (!unlockedJobs.contains(jobIdStr)) {
                                              unlockedJobs.add(jobIdStr);
                                              await prefs.setStringList('unlocked_recruiter_jobs$suffix', unlockedJobs);
                                            }

                                            if (responseData['data'] != null && responseData['data'] is Map) {
                                              final dataMap = responseData['data'] as Map<String, dynamic>;
                                              final String? email = dataMap['recruiter_email']?.toString();
                                              final String? mobile = dataMap['recruiter_mobile']?.toString();
                                              if (email != null && email.isNotEmpty && email != 'null') {
                                                _jobDetails['recruiter_email'] = email;
                                                _jobDetails['recuriter_email'] = email;
                                              }
                                              if (mobile != null && mobile.isNotEmpty && mobile != 'null') {
                                                _jobDetails['recruiter_mobile'] = mobile;
                                                _jobDetails['recuriter_mobile'] = mobile;
                                              }
                                            }

                                            if (mounted) {
                                              setState(() {
                                                _showRecruiterDetails = true;
                                              });
                                            }
                                          } catch (e) {
                                            debugPrint('Error marking recruiter viewed: $e');
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.visibility_outlined,
                                          size: sw * 0.045,
                                          color: AppColors.iconGreen),
                                      label: Text(
                                        'Show details of recruiter',
                                        style: TextStyle(
                                          color: AppColors.iconGreen,
                                          fontSize: sw * 0.035,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.iconGreen,
                                            width: 1.0),
                                        padding: EdgeInsets.symmetric(
                                            vertical: sw * 0.03),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // Contact Info
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: sw * 0.045,
                                        color: subtitleColor,
                                      ),
                                      SizedBox(width: sw * 0.02),
                                      Text(
                                        recruiterEmail,
                                        style: TextStyle(
                                          fontSize: sw * 0.035,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: sw * 0.02),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: sw * 0.045,
                                        color: subtitleColor,
                                      ),
                                      SizedBox(width: sw * 0.02),
                                      Text(
                                        recruiterMobile,
                                        style: TextStyle(
                                          fontSize: sw * 0.035,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: sw * 0.05),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      if (await checkAndShowGuestPopup(context))
                                        return;
                                      if (context.mounted) {
                                        final String companyId = (_jobDetails['recuriter_name'] ?? _jobDetails['recruiter_name'] ?? widget.job['recuriter_name'] ?? widget.job['recruiter_name'] ?? '').toString();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ViewCompanyScreen(
                                              company: {
                                                'id': companyId,
                                                'name': company,
                                                'tagline':
                                                    'Transform Your Business with AI & Machine Learning',
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.iconGreen,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: sw * 0.03,
                                      ),
                                    ),
                                    child: Text(
                                      'View Company',
                                      style: TextStyle(
                                        color: AppColors.iconGreen,
                                        fontSize: sw * 0.038,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sw * 0.08),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Sticky Action Buttons
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sw * 0.04,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: sh * 0.05,
                      child: OutlinedButton(
                        onPressed: (hasWalkIn ? _isRegistered : _isApplied)
                            ? null
                            : () async {
                                if (await checkAndShowGuestPopup(context))
                                  return;
                                if (hasWalkIn) {
                                  final bool success = await _registerWalkIn();
                                  if (success && context.mounted) {
                                    _showRegistrationBottomSheet(context, recruiterMobile);
                                  }
                                } else {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ResumeSelectionScreen(
                                          job: widget.job,
                                        ),
                                      ),
                                    ).then((_) {
                                      _loadSaveState();
                                    });
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: (hasWalkIn ? _isRegistered : _isApplied)
                                ? Color(0x66055BF2)
                                : AppColors.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.08),
                          ),
                        ),
                        child: Text(
                          hasWalkIn
                              ? (_isRegistered ? 'Registered' : 'Register')
                              : (_isApplied ? 'Applied' : 'Apply'),
                          style: TextStyle(
                            color: (hasWalkIn ? _isRegistered : _isApplied)
                                ? Color(0x66055BF2)
                                : AppColors.primary,
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.04),
                  Expanded(
                    child: SizedBox(
                      height: sh * 0.05,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (await checkAndShowGuestPopup(context)) return;
                          _callHR(recruiterMobile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.08),
                          ),
                        ),
                        child: Text(
                          'Call HR',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkTypeBadge(String imagePath, String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sw * 0.015,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(sw * 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: sw * 0.038,
            height: sw * 0.038,
            fit: BoxFit.contain,
          ),
          SizedBox(width: sw * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.033,
              color: AppColors.dynamicSubtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required double sw,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: sw * 0.06),
        SizedBox(height: sw * 0.015),
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.04,
            fontWeight: FontWeight.bold,
            color: AppColors.dynamicText,
          ),
        ),
        SizedBox(height: sw * 0.005),
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.035,
            color: AppColors.dynamicSubtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillBadge(String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.015,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EFFF),
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: AppColors.primary, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: sw * 0.032,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildBulletPoints(
    List<String> points,
    double sw, {
    required Color bulletColor,
  }) {
    return points.map((point) {
      return Padding(
        padding: EdgeInsets.only(bottom: sw * 0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: sw * 0.012),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: bulletColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                point,
                style: TextStyle(
                  fontSize: sw * 0.035,
                  color: AppColors.dynamicText,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

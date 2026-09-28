import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:truejobs/job_seeker_module/Walkin%20Sections/jobs_applied_screen.dart';
import 'package:truejobs/job_seeker_module/Walkin%20Sections/nearby_walkin_screen.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/job_seeker_module/Drawer%20Sections/drawers-screen.dart';
import 'package:truejobs/job_seeker_module/add_skills_screen.dart';
import 'package:truejobs/widgets/rupee_text.dart';
import '../widgets/company_logo_widget.dart';
import 'notification_screen.dart';
import 'jobs_picked_screen.dart';
import 'package:truejobs/job_seeker_module/Jobs%20Sections/jobs_screen.dart';
import 'package:truejobs/job_seeker_module/Profile%20Sections/profile_screen.dart';
import 'package:truejobs/job_seeker_module/Subscription%20Sections/pro_screen.dart';
import 'package:truejobs/job_seeker_module/Jobs%20Sections/job_detail_screen.dart';
import 'package:truejobs/widgets/bottom_nav_bar.dart';
import 'package:truejobs/widgets/guest_popup.dart';
import 'package:truejobs/resume_sections/create_cv_screen.dart';
import 'jobs_search_screen.dart';
import 'Profile Sections/add_project_screen.dart';
import 'package:truejobs/services/api/banner_api.dart';
import 'package:truejobs/services/api/jobs_api.dart';
import 'package:truejobs/services/api/job_api.dart';
import 'package:truejobs/constants/date_formatter.dart';
import 'package:truejobs/services/api/dropdown_cache.dart';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showMailPrompt = true;
  String _userName = 'Nandhu';
  bool _hasSkills = false;
  bool _hasProjects = false;
  int _currentBannerIndex = 0;
  int _jobsScrollIndex = 0;

  List<dynamic> _bannerList = [];
  bool _isLoadingBanners = true;

  List<Map<String, dynamic>> _onlineJobs = [];
  List<Map<String, dynamic>> _walkInJobs = [];
  List<String> _savedJobIds = [];
  bool _isLoadingJobs = true;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSkillsStatus();
    _loadSavedJobIds();
    _fetchJobs();
    _fetchBanners();
    DropdownCache.preloadDropdowns();
  }

  Future<String> _getUserSuffix() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId;
    try {
      userId = prefs.getInt('user_id');
    } catch (_) {
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

  Future<void> _loadSavedJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    if (mounted) {
      setState(() {
        _savedJobIds = prefs.getStringList('saved_job_ids$suffix') ?? [];
      });
    }
  }

  Future<void> _toggleSaveJob(Map<String, dynamic> job) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> list = prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> savedData =
        prefs.getStringList('saved_jobs_data$suffix') ?? [];
    final String idStr = job['id'].toString();
    
    // Determine action for API later
    bool isSaving = !list.contains(idStr);

    if (list.contains(idStr)) {
      list.remove(idStr);
      savedData.removeWhere((item) {
        final map = json.decode(item) as Map<String, dynamic>;
        return map['id'].toString() == idStr;
      });
    } else {
      list.add(idStr);
      final cleanJob = Map<String, dynamic>.from(job);
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
    _loadSavedJobIds();

    // Call API
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

  Future<void> _fetchJobs() async {
    if (JobsApi.preloadedJobs != null && JobsApi.preloadedJobs!.isNotEmpty) {
      _filterJobs(JobsApi.preloadedJobs!);
    }
    try {
      final response = await JobsApi.fetchJobDetails();
      final mappedJobs = JobsApi.parseJobList(response);
      if (mappedJobs.isNotEmpty) {
        JobsApi.preloadedJobs = mappedJobs;
        _filterJobs(mappedJobs);
      }
    } catch (e) {
      debugPrint('Error fetching jobs on home: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingJobs = false;
        });
      }
    }
  }

  void _filterJobs(List<Map<String, dynamic>> allJobs) {
    final online = <Map<String, dynamic>>[];
    final walkin = <Map<String, dynamic>>[];
    for (final job in allJobs) {
      final method = job['interview_method']?.toString();
      if (method == '2') {
        online.add(job);
      } else if (method == '1') {
        walkin.add(job);
      }
    }
    if (mounted) {
      setState(() {
        _onlineJobs = online;
        _walkInJobs = walkin;
        _isLoadingJobs = false;
      });
    }
  }

  Future<void> _fetchBanners() async {
    if (BannerApi.preloadedBanners != null) {
      setState(() {
        _bannerList = BannerApi.preloadedBanners!;
        _isLoadingBanners = false;
      });
    } else {
      try {
        final res = await BannerApi.fetchBanners();
        if (res['error'] == false) {
          setState(() {
            _bannerList = res['data'] ?? [];
            _currentBannerIndex = 0;
            _isLoadingBanners = false;
          });
        } else {
          setState(() {
            _isLoadingBanners = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching banners on home: $e');
        setState(() {
          _isLoadingBanners = false;
        });
      }
    }
  }

  Future<String> _getPrefsKey() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId;
    try {
      userId = prefs.getInt('user_id');
    } catch (_) {
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
    if (userId != null) {
      return 'user_${userId}_skills';
    }
    return 'user_skills';
  }

  Future<void> _loadSkillsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isGuest = prefs.getBool('is_guest') ?? false;

    final key = await _getPrefsKey();
    final skills = prefs.getStringList(key) ?? [];
    final name = isGuest ? 'Guest' : (prefs.getString('name') ?? 'User');

    int? userId;
    try {
      userId = prefs.getInt('user_id');
    } catch (_) {
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
    final projKey = userId != null
        ? 'user_${userId}_projects'
        : 'user_projects';
    final projects = prefs.getStringList(projKey) ?? [];

    setState(() {
      _hasSkills = skills.isNotEmpty;
      _hasProjects = projects.isNotEmpty;
      _userName = name;
    });
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

  void _onItemTapped(int index) async {
    if (index == 2 || index == 3) {
      if (await checkAndShowGuestPopup(context)) return;
    }
    if (index == 1) {
      if (mounted) {
        _pushFade(const JobsScreen());
      }
    } else if (index == 2) {
      if (mounted) {
        _pushFade(const MyJobsScreen());
      }
    } else if (index == 3) {
      if (mounted) {
        _pushFade(const ProfileScreen()).then((_) {
          _loadSkillsStatus();
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = AppColors.dynamicBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(sw),
      drawer: DrawersScreen(
        onProfileUpdated: () {
          _loadSkillsStatus();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(sw),
            _buildWelcomeMessage(sw),
            _buildMailPromptCard(sw),
            SizedBox(height: 0.02.sw),
            _buildMainBanner(sw),
            SizedBox(height: 0.02.sw),
            if (!_hasSkills) _buildBoostSkillsSection(sw),
            _buildSectionHeader(
              sw,
              'Jobs Picked for You',
              showViewAll: true,
              onViewAllPressed: () {
                _pushFade(const JobsPickedScreen()).then((_) => _loadSavedJobIds());
              },
            ),
            _buildJobsPickedForYou(sw),
            _buildBecomeAProBanner(sw),
            _buildResumeBuilderPromo(sw),
            _buildSectionHeader(
              sw,
              'Walk-in Interviews',
              showViewAll: true,
              onViewAllPressed: () {
                _pushFade(const NearbyWalkInScreen()).then((_) => _loadSavedJobIds());
              },
            ),
            _buildWalkInInterviews(sw),
            _buildSectionHeader(sw, 'Jobs Through reels', showViewAll: true),
            _buildJobsThroughReels(sw),
            _buildSectionHeader(sw, 'Top Companies', showViewAll: true),
            _buildTopCompanies(sw),
            _buildReferFriendsPromo(sw),
            _buildFooter(sw),
            SizedBox(height: 0.05.sw),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(double sw) {
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,

      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: textColor, size: 0.07.sw),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),

      title: Image.asset('assets/header.png', height: 0.08.sw),
      titleSpacing: 0,

      actions: [
        Padding(
          padding: EdgeInsets.only(right: 0.04.sw),
          child: GestureDetector(
            onTap: () async {
              if (await checkAndShowGuestPopup(context)) return;
              if (context.mounted) {
                _pushFade(const NotificationScreen());
              }
            },
            child: Container(
              width: 0.09.sw,
              height: 0.09.sw,
              decoration: BoxDecoration(
                color: cardBg, // #FFFFFF
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x14000000), // #00000014
                    offset: const Offset(0, 4),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: const Color(0x0A000000), // #0000000A
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                  size: 0.05.sw,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(double sw) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Padding(
      padding: EdgeInsets.all(0.04.sw),
      child: GestureDetector(
        onTap: () {
          _pushFade(const JobSearchScreen());
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(0.08.sw),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: subtitleColor, size: 0.06.sw),
              SizedBox(width: 0.02.sw),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  readOnly: true, // ← prevents keyboard on home
                  onTap: () {
                    _pushFade(const JobSearchScreen());
                  },
                  decoration: InputDecoration(
                    hintText: _isListening ? 'Listening...' : 'Search Jobs',
                    hintStyle: TextStyle(
                      color: _isListening ? AppColors.primary : subtitleColor,
                      fontSize: 0.04.sw,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _listenToSpeech,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.primary : subtitleColor,
                  size: 0.06.sw,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _listenToSpeech() async {
    if (!_isListening) {
      _searchController.clear();
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' && _isListening) {
            setState(() => _isListening = false);
            if (_searchController.text.isNotEmpty) {
              final query = _searchController.text;
              _searchController.clear();
              _pushFade(JobsScreen(searchQuery: query, location: ''));
            }
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text;
        _searchController.clear();
        _pushFade(JobsScreen(searchQuery: query, location: ''));
      }
    }
  }

  Widget _buildWelcomeMessage(double sw) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi $_userName',
            style: TextStyle(color: subtitleColor, fontSize: 0.035.sw),
          ),
          SizedBox(height: 0.01.sw),
          Text(
            'Your profile is incomplete...',
            style: TextStyle(
              color: textColor,
              fontSize: 0.04.sw,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.03.sw),
        ],
      ),
    );
  }

  Widget _buildMailPromptCard(double sw) {
    if (!_showMailPrompt || _hasProjects) return const SizedBox.shrink();
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.04.sw, vertical: 0.02.sw),
      child: Container(
        padding: EdgeInsets.all(0.04.sw),
        decoration: BoxDecoration(
          color: cardBg,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000), // #00000014
              offset: Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000), // #0000000A
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(0.02.sw),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/mail.gif',
                  width: 0.15.sw,
                  height: 0.15.sw,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 0.04.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HR is looking for your projects',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 0.035.sw,
                        ),
                      ),
                      SizedBox(height: 0.02.sw),
                      ElevatedButton(
                        onPressed: () async {
                          if (await checkAndShowGuestPopup(context)) return;
                          if (context.mounted) {
                            final result = await _pushFade<ProjectEntry>(
                              const AddProjectScreen(),
                            );
                            if (result != null) {
                              final prefs = await SharedPreferences.getInstance();
                              int? userId;
                              try {
                                userId = prefs.getInt('user_id');
                              } catch (_) {
                                final String? userIdStr = prefs.getString(
                                  'user_id',
                                );
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
                              if (userId != null) {
                                final String key = 'user_${userId}_projects';
                                final List<String> cachedProj =
                                    prefs.getStringList(key) ?? [];
                                cachedProj.add(
                                  jsonEncode({
                                    'id': result.id,
                                    'projectName': result.projectName,
                                    'startDate': result.startDate,
                                    'endDate': result.endDate,
                                    'details': result.details,
                                    'keySkills': result.keySkills,
                                    'projectUrl': result.projectUrl,
                                  }),
                                );
                                await prefs.setStringList(key, cachedProj);
                                _loadSkillsStatus();
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.05.sw),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.06.sw,
                            vertical: 0.025.sw,
                          ),
                          minimumSize: Size(0, 0.08.sw),
                        ),
                        child: Text(
                          'Add Project',
                          style: TextStyle(fontSize: 0.035.sw),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: -0.025.sw,
              right: -0.025.sw,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: (){
                  setState(() {
                    _showMailPrompt = false;
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.black87,
                  size: 0.06.sw,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainBanner(double sw) {
    if (_isLoadingBanners) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: (sw - 32) * 122 / 328,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0.r)),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (_bannerList.isEmpty) {
      return const SizedBox.shrink();
    }

    final double bannerWidth = sw - 32;
    // We add 4px horizontal margin inside the CarouselSlider items to make them separate cards
    final double itemWidth = bannerWidth - 8;
    final double itemHeight = itemWidth * 122 / 328;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(
            height: itemHeight,
            width: double.infinity,
            child: CarouselSlider(
              items: _bannerList.map((bannerItem) {
                final String bannerUrl = bannerItem['banner'] ?? '';
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0.r),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0.r),
                          child: Image.network(
                            bannerUrl,
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.dynamicCardBg,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.dynamicCardBg,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0.r),
                            border: Border.all(
                              color: const Color(0xFFEFEFEF),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: itemHeight,
                viewportFraction: 1.0,
                autoPlay: true,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
              ),
            ),
          ),
          if (_bannerList.length > 1) ...[
            SizedBox(height: 0.03.sw),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerList.length, (index) {
                final bool isCurrent = _currentBannerIndex == index;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.005.sw),
                  width: isCurrent ? 0.08.sw : 0.02.sw,
                  height: 0.015.sw,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: isCurrent
                        ? BorderRadius.circular(0.01.sw)
                        : null,
                    shape: isCurrent ? BoxShape.rectangle : BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoostSkillsSection(double sw) {
    return Padding(
      padding: EdgeInsets.only(
        left: 0.04.sw,
        top: 0.04.sw,
        right: 0.04.sw,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: AppColors.primary,
                      size: 0.04.sw,
                    ),
                    SizedBox(width: 0.01.sw),
                    Text(
                      'Boost 5%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 0.04.sw,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.01.sw),
                Text(
                  'Lets recruiters know your skills',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 0.038.sw,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              if (await checkAndShowGuestPopup(context)) return;
              await _pushFade(const AddSkillsScreen());
              _loadSkillsStatus();
            },
            icon: Icon(Icons.add, color: AppColors.primary, size: 0.04.sw),
            label: Text(
              'Add Skills',
              style: TextStyle(color: AppColors.primary, fontSize: 0.035.sw),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.05.sw),
              ),
              padding: EdgeInsets.symmetric(horizontal: 0.03.sw),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    double sw,
    String title, {
    bool showViewAll = false,
    VoidCallback? onViewAllPressed,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.04.sw, 0.06.sw, 0.04.sw, 0.03.sw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 0.05.sw,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: onViewAllPressed,
              child: Text(
                'View all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 0.035.sw,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobsPickedForYou(double sw) {
    final double cardWidth = sw * (256 / 360);
    final double cardHeight = sw * (116 / 360);
    final double outerHeight = cardHeight + (0.04.sw);

    if (_isLoadingJobs && _onlineJobs.isEmpty) {
      return Container(
        height: outerHeight,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_onlineJobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0.04.sw,
          vertical: 0.02.sw,
        ),
        child: Text(
          'No online jobs available right now.',
          style: TextStyle(
            color: AppColors.dynamicSubtitle,
            fontSize: 0.035.sw,
          ),
        ),
      );
    }

    final displayJobs = _onlineJobs.take(2).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
          child: SizedBox(
            height: outerHeight,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.maxScrollExtent > 0) {
                  final double progress =
                      notification.metrics.pixels /
                      notification.metrics.maxScrollExtent;
                  final int newIndex = progress > 0.5 ? 1 : 0;
                  if (newIndex != _jobsScrollIndex) {
                    setState(() {
                      _jobsScrollIndex = newIndex;
                    });
                  }
                }
                return false;
              },
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: displayJobs.length,
                separatorBuilder: (context, index) => SizedBox(width: 0.04.sw),
                itemBuilder: (context, index) {
                  final job = displayJobs[index];
                  final String title =
                      (job['title'] ?? job['job_title'] ?? 'Job Title')
                          .toString();
                  final String company =
                      (job['company'] ?? job['company_name'] ?? 'Company')
                          .toString();
                  final String logoText =
                      job['logoText'] ??
                      (company.isNotEmpty ? company[0].toUpperCase() : 'J');
                  final Color logoBg = job['logoBg'] is Color
                      ? job['logoBg']
                      : Colors.blue.shade50;
                  final Color logoColor = job['logoColor'] is Color
                      ? job['logoColor']
                      : Colors.blue.shade700;
                  final String timeStr = (job['time'] ?? job['dtime'] ?? '')
                      .toString();
                  final String relativeTime = timeStr.isNotEmpty
                      ? convertToRelativeTime(timeStr)
                      : 'Recently';

                  return GestureDetector(
                    onTap: () async {
                      if (await checkAndShowGuestPopup(context)) return;
                      if (context.mounted) {
                        await _pushFade(JobDetailScreen(job: job)).then((_) => _loadSavedJobIds());
                        _loadSavedJobIds();
                      }
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        padding: EdgeInsets.fromLTRB(
                          0.035.sw,
                          0.04.sw,
                          0.03.sw,
                          0.04.sw,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(sw * (8 / 360)),
                          border: Border.all(
                            color: const Color(0xFFEFEFEF),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000), // #00000014
                              offset: Offset(0, 0),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color(0x0A000000), // #0000000A
                              offset: Offset(0, 0),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CompanyLogoWidget(
                                  companyId: job['recuriter_name']?.toString() ?? '',
                                  fallbackText: logoText,
                                  fallbackBgColor: logoBg,
                                  fallbackTextColor: logoColor,
                                  radius: 0.05.sw,
                                ),
                                SizedBox(width: 0.03.sw),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          color: AppColors.dynamicText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 0.036.sw,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.01.sw,),
                                      Text(
                                        company,
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 0.034.sw,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 0.045.sw,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.business_center,
                                  size: 0.032.sw,
                                  color: AppColors.dynamicSubtitle,
                                ),
                                SizedBox(width: 0.01.sw),
                                Expanded(
                                  child: RupeeText(
                                    text: '${job['exp']} •${job['salary']}',
                                    style: TextStyle(
                                      color: Color(0x99000000),
                                      fontSize: 0.029.sw,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              relativeTime,
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 0.032.sw,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (displayJobs.length > 1) ...[
          SizedBox(height: 0.02.sw),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 0.25.sw,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: _jobsScrollIndex == 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        width: 0.12.sw,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBecomeAProBanner(double sw) {
    return Padding(
      padding: EdgeInsets.all(0.04.sw),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 0.04.sw,
              vertical: 0.03.sw,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.03.sw),
              gradient: LinearGradient(
                colors: [Color(0xFFE88515), Color(0xFF772B88)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/crown.png', height: 43),
                SizedBox(width: 0.03.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Become a Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 0.04.sw,
                        ),
                      ),
                      Text(
                        'AI-Based Job Recommendations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 0.025.sw,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (await checkAndShowGuestPopup(context)) return;
                    if (context.mounted) {
                      _pushFade(const ProScreen());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(0.91), // Border thickness
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFFFFB93), Color(0xFF999758)],
                      ),
                      borderRadius: BorderRadius.circular(0.05.sw),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.03.sw,
                        vertical: 0.015.sw,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFFCE96), Color(0xFFC7710E)],
                        ),
                        borderRadius: BorderRadius.circular(0.05.sw),
                      ),
                      child: Text(
                        'Get Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 0.03.sw,
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
    );
  }

  Widget _buildResumeBuilderPromo(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
      child: Container(
        padding: EdgeInsets.all(0.04.sw),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: AppColors.dynamicBorder, width: 0.3),
          borderRadius: BorderRadius.circular(0.03.sw),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000), // #00000014 (8% opacity)
              offset: const Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0x0A000000), // #0000000A (4% opacity)
              offset: const Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/resume.png', height: 0.1.sw),
                SizedBox(width: 0.03.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a professional, ATS-friendly',
                        style: TextStyle(
                          color: AppColors.dynamicText,
                          fontSize: 0.035.sw,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.01.sw),
                      Text(
                        'resume in minutes with smart templates and expert suggestions.',
                        style: TextStyle(
                          color: AppColors.dynamicSubtitle,
                          fontSize: 0.032.sw,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.03.sw),
            ElevatedButton(
              onPressed: () async {
                if (await checkAndShowGuestPopup(context)) return;
                if (context.mounted) {
                  _pushFade(const CreateCvScreen());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.05.sw),
                ),
              ),
              child: const Text('Create Your CV'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkInInterviews(double sw) {
    if (_isLoadingJobs && _walkInJobs.isEmpty) {
      return Container(
        height: 0.3.sw,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_walkInJobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0.04.sw,
          vertical: 0.02.sw,
        ),
        child: Text(
          'No walk-in interviews available right now.',
          style: TextStyle(
            color: AppColors.dynamicSubtitle,
            fontSize: 0.035.sw,
          ),
        ),
      );
    }

    final displayWalkIns = _walkInJobs.take(2).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
      itemCount: displayWalkIns.length,
      separatorBuilder: (context, index) => SizedBox(height: 0.04.sw),
      itemBuilder: (context, index) {
        final job = displayWalkIns[index];
        final String jobIdStr = (job['id'] ?? '').toString();
        final bool isSaved = _savedJobIds.contains(jobIdStr);

        final String title = (job['title'] ?? job['job_title'] ?? 'Walk-in Job')
            .toString();
        final String company =
            (job['company'] ?? job['company_name'] ?? 'Company').toString();
        final String location =
            (job['location'] != null &&
                job['location'].toString().trim().isNotEmpty)
            ? job['location'].toString().trim()
            : ((job['job_city'] ??
                      job['job_area'] ??
                      job['walk_address'] ??
                      'Coimbatore')
                  .toString());

        final String walkDate =
            (job['walk_start'] ?? job['walkInDate'] ?? 'Walk-in Date')
                .toString();
        final String walkTiming =
            (job['walk_timing'] != null && job['walk_time_end'] != null)
            ? '${job['walk_timing']} - ${job['walk_time_end']}'
            : (job['walkInTime'] ?? '10:00 AM - 05:00 PM').toString();

        final String skillsRaw = (job['skills'] ?? '').toString();
        final List<String> skillList = skillsRaw
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .take(3)
            .toList();

        return GestureDetector(
          onTap: () async {
            if (await checkAndShowGuestPopup(context)) return;
            if (context.mounted) {
              await _pushFade(JobDetailScreen(job: job)).then((_) => _loadSavedJobIds());
              _loadSavedJobIds();
            }
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.dynamicCardBg,
              borderRadius: BorderRadius.circular(0.03.sw),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000), // #00000014 (8% opacity)
                  offset: Offset(0, 8),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x0A000000), // #0000000A (4% opacity)
                  offset: Offset(0, 0),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(0.04.sw),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Text(
                              company.isNotEmpty
                                  ? company[0].toUpperCase()
                                  : 'W',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 0.03.sw),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: AppColors.dynamicText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 0.04.sw,
                                  ),
                                ),
                                SizedBox(height: 0.015.sw),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/location.png',
                                      height: 0.04.sw,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 0.01.sw),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: TextStyle(
                                          color: AppColors.dynamicSubtitle,
                                          fontSize: 0.03.sw,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.01.sw),
                      const Divider(color: Color(0x55D2D2D2)),
                      SizedBox(height: 0.01.sw),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 0.04.sw,
                            color: AppColors.dynamicSubtitle,
                          ),
                          SizedBox(width: 0.02.sw),
                          Text(
                            'Walk-in : $walkDate',
                            style: TextStyle(
                              color: AppColors.dynamicText,
                              fontSize: 0.03.sw,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (walkTiming.isNotEmpty) ...[
                        SizedBox(height: 0.01.sw),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 0.04.sw,
                              color: AppColors.dynamicSubtitle,
                            ),
                            SizedBox(width: 0.02.sw),
                            Text(
                              walkTiming,
                              style: TextStyle(
                                color: AppColors.dynamicText,
                                fontSize: 0.03.sw,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (skillList.isNotEmpty) ...[
                        SizedBox(height: 0.01.sw),
                        const Divider(color: Color(0x55D2D2D2)),
                        SizedBox(height: 0.01.sw),
                        Wrap(
                          spacing: 0.02.sw,
                          runSpacing: 0.02.sw,
                          children: List.generate(skillList.length, (i) {
                            return _buildSkillChip(
                              sw,
                              skillList[i],
                              i % 2 == 0
                                  ? const Color(0xFF2E62A3)
                                  : const Color(0xFF6C57A3),
                            );
                          }),
                        ),
                      ],
                      SizedBox(height: 0.01.sw),
                      const Divider(color: Color(0x55D2D2D2)),
                      SizedBox(height: 0.01.sw),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 0.035.sw,
                            color: AppColors.dynamicSubtitle,
                          ),
                          SizedBox(width: 0.01.sw),
                          Text(
                            'Near You • ',
                            style: TextStyle(
                              color: AppColors.dynamicSubtitle,
                              fontSize: 0.03.sw,
                            ),
                          ),
                          Text(
                            'Walk-in Register',
                            style: TextStyle(
                              color: AppColors.dynamicSubtitle,
                              fontSize: 0.03.sw,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _toggleSaveJob(job),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isSaved
                                      ? AppColors.primary
                                      : AppColors.dynamicSubtitle,
                                  size: 0.04.sw,
                                ),
                                SizedBox(width: 0.01.sw),
                                Text(
                                  isSaved ? 'Saved' : 'Save Job',
                                  style: TextStyle(
                                    color: isSaved
                                        ? AppColors.primary
                                        : AppColors.dynamicSubtitle,
                                    fontSize: 0.03.sw,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.05.sw,
                      vertical: 0.025.sw,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.iconGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0.06.sw),
                        topLeft: Radius.circular(0.06.sw),
                      ),
                    ),
                    child: Text(
                      'Walk-in',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 0.032.sw,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillChip(double sw, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.03.sw, vertical: 0.01.sw),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0.03.sw),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 0.025.sw),
      ),
    );
  }

  Widget _buildJobsThroughReels(double sw) {
    final List<Map<String, String>> reels = [
      {
        'title': 'We are hiring Software Engineers!',
        'videoUrl': 'https://github.com/intel-iot-devkit/sample-videos/raw/master/classroom.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=500&auto=format&fit=crop&q=60',
      },
      {
        'title': 'Creative UI/UX Designers needed!',
        'videoUrl': 'https://github.com/intel-iot-devkit/sample-videos/raw/master/face-demographics-walking.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?w=500&auto=format&fit=crop&q=60',
      },
      {
        'title': 'Join our Sales & Marketing team!',
        'videoUrl': 'https://github.com/intel-iot-devkit/sample-videos/raw/master/worker-zone-detection.mp4',
        'thumbnail': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500&auto=format&fit=crop&q=60',
      },
    ];

    return Container(
      color: const Color(0xFFE7EFFF),
      padding: EdgeInsets.symmetric(vertical: 0.06.sw),
      child: SizedBox(
        height: 0.6.sw,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
          scrollDirection: Axis.horizontal,
          itemCount: reels.length,
          separatorBuilder: (context, index) => SizedBox(width: 0.03.sw),
          itemBuilder: (context, index) {
            final reel = reels[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReelPlayerScreen(
                      videoUrl: reel['videoUrl']!,
                      title: reel['title']!,
                    ),
                  ),
                );
              },
              child: Container(
                width: 0.35.sw,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(0.03.sw),
                  image: DecorationImage(
                    image: NetworkImage(reel['thumbnail']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 0.1.sw,
                      ),
                    ),
                    Positioned(
                      bottom: 0.02.sw,
                      left: 0.02.sw,
                      right: 0.02.sw,
                      child: Text(
                        reel['title']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 0.025.sw,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopCompanies(double sw) {
    List<Map<String, dynamic>> companies = [
      {
        'rating': '3.7',
        'reviews': '73k',
        'image': 'assets/image/accenture.png',
        'height': 0.1.sw,
      },
      {
        'rating': '3.7',
        'reviews': '73k',
        'image': 'assets/image/wipro.png',
        'height': 0.12.sw,
      },
      {
        'rating': '3.7',
        'reviews': '73k',
        'image': 'assets/image/cognizant.png',
        'height': 0.1.sw,
      },
      {
        'rating': '3.7',
        'reviews': '73k',
        'image': 'assets/image/infosys.png',
        'height': 0.1.sw,
      },
      {
        'rating': '3.7',
        'reviews': '73k',
        'image': 'assets/image/hcltech.png',
        'height': 0.1.sw,
      },
      {
        'rating': '3.7',
        'reviews': '73k',
        'image': 'assets/image/reliance.png',
        'height': 0.1.sw,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.04.sw),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0.03.sw,
          mainAxisSpacing: 0.03.sw,
          childAspectRatio: 0.8,
        ),
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final comp = companies[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0.02.sw),
              border: Border.all(color: Color(0xFFEBEBEB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000), // #00000014
                  offset: Offset(0, 8),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x0A000000), // #0000000A
                  offset: Offset(0, 0),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  comp['image'],
                  height: comp['height'],
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 0.02.sw),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.secondary,
                      size: 0.03.sw,
                    ),
                    Text(
                      '${comp['rating']}',
                      style: TextStyle(
                        color: AppColors.dynamicSubtitle,
                        fontSize: 0.025.sw,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${comp['reviews']} Reviews',
                  style: TextStyle(
                    color: AppColors.dynamicSubtitle,
                    fontSize: 0.025.sw,
                  ),
                ),
                SizedBox(height: 0.01.sw),
                Text(
                  'View Jobs',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 0.025.sw,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReferFriendsPromo(double sw) {
    return Container(
      margin: EdgeInsets.only(top: 0.06.sw),
      width: double.infinity,
      height: 0.36.sw,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFC2FFD9), // Vibrant Mint/Cyan
            Color(0xFF668FF6), // Vibrant Light Blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Left Side Text and Badge
          Positioned(
            left: 0.05.sw,
            top: 0,
            bottom: 0,
            right:
                0.35.sw, // Leaves space for the pointing person image on the right
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.04.sw,
                    vertical: 0.02.sw,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0.05.sw),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/whatsapp_icon.gif',
                          width: 0.05.sw,
                          height: 0.05.sw,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 0.02.sw),
                        Text(
                          'Refer friends',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 0.035.sw,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 0.03.sw),
                Text(
                  'Help your friends to get jobs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 0.045.sw,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Right Side Person Image
          Positioned(
            right: -0.05.sw,
            bottom: 0,
            child: Image.asset(
              'assets/refer_person.png',
              height: 0.36.sw,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(double sw) {
    return Container(
      color: Colors.grey.shade900,
      padding: EdgeInsets.all(0.06.sw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '100% Apply\nthrough True jobs...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 0.06.sw,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.04.sw),
          _buildFooterBullet(sw, 'Get Instant Job alert'),
          SizedBox(height: 0.02.sw),
          _buildFooterBullet(sw, 'Ats Cv Creating'),
          SizedBox(height: 0.02.sw),
          _buildFooterBullet(sw, 'Nearby Walk-in\'s'),
        ],
      ),
    );
  }

  Widget _buildFooterBullet(double sw, String text) {
    return Row(
      children: [
        Image.asset('assets/blue_tick.png', height: 20),
        SizedBox(width: 0.02.sw),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 0.035.sw),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return CustomBottomNavBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}

class ReelPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const ReelPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<ReelPlayerScreen> createState() => _ReelPlayerScreenState();
}

class _ReelPlayerScreenState extends State<ReelPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Referer': 'https://mixkit.co/',
        'Origin': 'https://mixkit.co',
      },
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
          _controller.setLooping(true);
        }
      }).catchError((error) {
        debugPrint('Video Player error: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Fullscreen Video Player or Status message
          Positioned.fill(
            child: _hasError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.white, size: 0.12.sw),
                        SizedBox(height: 0.03.sw),
                        Text(
                          'Failed to load video',
                          style: TextStyle(color: Colors.white, fontSize: 0.04.sw),
                        ),
                      ],
                    ),
                  )
                : _isInitialized
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      ),
          ),

          // Play/Pause Overlay indicator
          if (_isInitialized && !_controller.value.isPlaying)
            Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white.withValues(alpha: 0.7),
                size: 0.2.sw,
              ),
            ),

          // Top Header (Back Button & "Reel" Title)
          Positioned(
            top: MediaQuery.of(context).padding.top + 0.02.sw,
            left: 0.02.sw,
            right: 0.04.sw,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 0.02.sw),
                const Text(
                  'Job Reel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Details (Reel Title and Progress Bar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(0.05.sw, 0.1.sw, 0.05.sw, 0.05.sw),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 0.045.sw,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Color(0xCC000000),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.04.sw),
                  if (_isInitialized)
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.blue,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

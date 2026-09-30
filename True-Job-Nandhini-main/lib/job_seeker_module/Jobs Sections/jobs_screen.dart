import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:truejobs/job_seeker_module/Jobs%20Sections/filter_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/jobs_api.dart';
import '../../services/api/job_api.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/guest_popup.dart';
import '../Walkin Sections/jobs_applied_screen.dart';
import '../Profile Sections/profile_screen.dart';
import 'job_detail_screen.dart';
import '../../widgets/rupee_text.dart';
import '../../constants/date_formatter.dart';
import '../jobs_search_screen.dart';
import '../../utils/smooth_page_route.dart';
import '../../widgets/company_logo_widget.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class JobsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? location;
  const JobsScreen({super.key, this.searchQuery, this.location});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  int _selectedIndex = 1; // Default is the Jobs tab (index 1)
  List<String> _savedJobIds = [];
  bool _isLoading = JobsApi.preloadedJobs == null;
  List<Map<String, dynamic>> _apiJobList = JobsApi.preloadedJobs ?? [];
  late final TextEditingController _jobsSearchController;
  Map<String, List<Map<String, dynamic>>>? _appliedFilters;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    String initialText = '';
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      initialText += widget.searchQuery!;
    }
    if (widget.location != null && widget.location!.isNotEmpty) {
      if (initialText.isNotEmpty) initialText += ' in ';
      initialText += widget.location!;
    }
    _jobsSearchController = TextEditingController(text: initialText);
    _loadSavedJobIds();
    _fetchApiJob();
  }

  @override
  void dispose() {
    _jobsSearchController.dispose();
    super.dispose();
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

  Future<void> _loadSavedJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    if (mounted) {
      setState(() {
        _savedJobIds = prefs.getStringList('saved_job_ids$suffix') ?? [];
      });
    }
  }

  Future<void> _fetchApiJob() async {
    if (JobsApi.preloadedJobs != null && JobsApi.preloadedJobs!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _apiJobList = JobsApi.preloadedJobs!;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    try {
      final response = await JobsApi.fetchJobDetails();
      final mappedJobs = JobsApi.parseJobList(response);
      if (mappedJobs.isNotEmpty) {
        JobsApi.preloadedJobs = mappedJobs;
        if (mounted) {
          setState(() {
            _apiJobList = mappedJobs;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSaveJob(Map<String, dynamic> job) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> list = prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> savedData =
        prefs.getStringList('saved_jobs_data$suffix') ?? [];
    final String idStr = job['id'].toString();
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

  void _onItemTapped(int index) async {
    if (index == 2 || index == 3) {
      if (await checkAndShowGuestPopup(context)) return;
    }
    if (index == 0) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else if (index == 2) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MyJobsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 0),
            reverseTransitionDuration: const Duration(milliseconds: 0),
          ),
        );
      }
    } else if (index == 3) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 0),
            reverseTransitionDuration: const Duration(milliseconds: 0),
          ),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _listenToSpeech() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _jobsSearchController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    final String filterText = _jobsSearchController.text.trim().toLowerCase();
    final List<Map<String, dynamic>> jobList = _apiJobList.where((job) {
      bool textMatched = true;
      if (filterText.isNotEmpty) {
        if (filterText.contains(' in ')) {
          final parts = filterText.split(' in ');
          final q = parts[0].trim();
          final loc = parts.sublist(1).join(' in ').trim();

          bool matchesQuery = true;
          if (q.isNotEmpty) {
            final title = (job['title'] ?? '').toString().toLowerCase();
            final company = (job['company'] ?? '').toString().toLowerCase();
            final skills = (job['skills'] ?? '').toString().toLowerCase();
            final desc = (job['desc'] ?? '').toString().toLowerCase();
            matchesQuery = title.contains(q) || company.contains(q) || skills.contains(q) || desc.contains(q);
          }

          bool matchesLocation = true;
          if (loc.isNotEmpty) {
            final jobLoc = (job['location'] ?? '').toString().toLowerCase();
            matchesLocation = jobLoc.contains(loc);
          }
          textMatched = matchesQuery && matchesLocation;
        } else {
          final title = (job['title'] ?? '').toString().toLowerCase();
          final company = (job['company'] ?? '').toString().toLowerCase();
          final skills = (job['skills'] ?? '').toString().toLowerCase();
          final desc = (job['desc'] ?? '').toString().toLowerCase();
          final jobLoc = (job['location'] ?? '').toString().toLowerCase();
          textMatched = title.contains(filterText) ||
              company.contains(filterText) ||
              skills.contains(filterText) ||
              desc.contains(filterText) ||
              jobLoc.contains(filterText);
        }
      }
      
      if (!textMatched) return false;

      if (_appliedFilters != null) {
        // Walk-in filter
        final walkInOptions = _appliedFilters!['Walk-in']?.where((e) => e['checked']).toList() ?? [];
        if (walkInOptions.isNotEmpty) {
           final isWalkin = job['interview_method'] == 1 || job['interview_method']?.toString() == '1';
           bool pass = false;
           for(var opt in walkInOptions) {
             if(opt['label'] == 'Yes' && isWalkin) pass = true;
             if(opt['label'] == 'No' && !isWalkin) pass = true;
           }
           if (!pass) return false;
        }
        
        // Location filter
        final locOptions = _appliedFilters!['Location']?.where((e) => e['checked']).toList() ?? [];
        if (locOptions.isNotEmpty) {
           final locStr = (job['location'] ?? '').toString().toLowerCase();
           bool pass = false;
           for(var opt in locOptions) {
             if(locStr.contains(opt['label'].toString().toLowerCase())) {
               pass = true;
               break;
             }
           }
           if (!pass) return false;
        }
        
        // Job Type
        final jobTypeOptions = _appliedFilters!['Job Type']?.where((e) => e['checked']).toList() ?? [];
        if (jobTypeOptions.isNotEmpty) {
            final jobType = (job['employment_type'] ?? job['job_type'] ?? '').toString().toLowerCase();
            bool pass = false;
            for(var opt in jobTypeOptions) {
                if(jobType.contains(opt['label'].toString().toLowerCase())) {
                   pass = true;
                   break;
                }
            }
            if(!pass) return false;
        }
        
        // Work mode
        final workModeOptions = _appliedFilters!['Work mode']?.where((e) => e['checked']).toList() ?? [];
        if (workModeOptions.isNotEmpty) {
            final wMode = (job['work_mode'] ?? job['job_mode'] ?? '').toString().toLowerCase();
            bool pass = false;
            for(var opt in workModeOptions) {
                if(wMode.contains(opt['label'].toString().toLowerCase())) {
                   pass = true;
                   break;
                }
            }
            if(!pass) return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Top Bar with Back Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sw * 0.02,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: textColor,
                  size: sw * 0.05,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.08),
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
                    Icon(Icons.search, color: subtitleColor, size: sw * 0.06),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: TextField(
                        controller: _jobsSearchController,
                        readOnly: true,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            SmoothPageRoute(
                              child: const JobSearchScreen(returnResults: true),
                            ),
                          );
                          if (result is Map) {
                            final q = result['searchQuery']?.toString() ?? '';
                            final loc = result['location']?.toString() ?? '';
                            String newText = '';
                            if (q.isNotEmpty) newText += q;
                            if (loc.isNotEmpty) {
                              if (newText.isNotEmpty) newText += ' in ';
                              newText += loc;
                            }
                            setState(() {
                              _jobsSearchController.text = newText;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: _isListening ? 'Listening...' : 'Search Jobs',
                          hintStyle: TextStyle(
                            color: _isListening ? AppColors.primary : subtitleColor,
                            fontSize: sw * 0.04,
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
                        size: sw * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sw * 0.06),

            // Filters Scroll Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: SizedBox(
                height: sw * 0.1,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FilterBottomSheet(initialFilters: _appliedFilters),
                        );
                        if (result != null && result is Map<String, List<Map<String, dynamic>>>) {
                          setState(() {
                            _appliedFilters = result;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: sw * 0.02),
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.filter_alt,
                          size: sw * 0.07,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    _buildFilterChip('Freshness', sw),
                    SizedBox(width: sw * 0.02),
                    _buildFilterChip('Nearby jobs', sw),
                    SizedBox(width: sw * 0.02),
                    _buildFilterChip('Work mode', sw),
                    SizedBox(width: sw * 0.02),
                    _buildFilterChip('Location', sw),
                  ],
                ),
              ),
            ),
            SizedBox(height: sw * 0.04),

            // Results count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Text(
                '${jobList.length} ${jobList.length == 1 ? 'result' : 'results'}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: sw * 0.036,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: sw * 0.02),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : jobList.isEmpty
                  ? Center(
                      child: Text(
                        'No jobs found.',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sw * 0.06,
                      ),
                      itemCount: jobList.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: sw * 0.04),
                      itemBuilder: (context, index) {
                        return _buildJobCard(jobList[index], sw);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFilterChip(String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sw * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.05),
        border: Border.all(color: Color(0xFFB5B5B5), width: 0.8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: sw * 0.036,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, double sw) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    final hasWalkIn = (job['interview_method'] == 1 ||
        job['interview_method']?.toString() == '1');

    final isSaved = _savedJobIds.contains(job['id'].toString());

    return GestureDetector(
      onTap: () async {
        if (await checkAndShowGuestPopup(context)) return;
        if (context.mounted) {
          await _pushFade(JobDetailScreen(job: job));
          _loadSavedJobIds();
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: sw * (328 / 360),
          constraints: BoxConstraints(
            minHeight: hasWalkIn ? sw * (219 / 360) : sw * (193 / 360),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(sw * (10.85 / 360)),
            border: Border.all(
              color: const Color(0xFFEFEFEF),
              width: sw * (1.36 / 360),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000), // #00000014
                offset: Offset(0, sw * (10.85 / 360)),
                blurRadius: sw * (21.71 / 360),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0x0A000000), // #0000000A
                offset: Offset(0, 0),
                blurRadius: sw * (5.43 / 360),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                sw * 0.04,
                sw * 0.045,
                sw * 0.04,
                hasWalkIn ? sw * 0.045 : sw * 0.04,
              ),
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
                              job['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: sw * 0.04,
                                color: textColor,
                              ),
                            ),
                            Text(
                              job['company'],
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: sw * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleSaveJob(job),
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
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.035),
                  Row(
                    children: [
                      Image.asset(
                        'assets/location.png',
                        height: sw * 0.047,
                        color: Color(0xFFB2B2B2),
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        () {
                          if (job['location'] != null &&
                              job['location'].toString().trim().isNotEmpty) {
                            return job['location'].toString().trim();
                          }
                          final String area =
                              (job['job_area'] ?? '').toString().trim();
                          final String city =
                              (job['job_city'] ?? '').toString().trim();
                          if (area.isNotEmpty && city.isNotEmpty) {
                            return '$area, $city';
                          } else if (city.isNotEmpty) {
                            return city;
                          } else if (area.isNotEmpty) {
                            return area;
                          }
                          return (job['walk_address'] ?? 'Coimbatore')
                              .toString()
                              .trim();
                        }(),
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: sw * 0.038,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.02),
                  Row(
                    children: [
                      Icon(
                        Icons.business_center,
                        size: sw * 0.045,
                        color: Color(0xFFB2B2B2),
                      ),
                      SizedBox(width: sw * 0.02),
                      Expanded(
                        child: RupeeText(
                          text: '${job['exp']}  •  ${job['salary']}',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: sw * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.04),
                  Text(
                    job['job_description'],
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: sw * 0.034,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasWalkIn) ...[
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
                      (job['walk_start'] ?? job['walkInDate'] ?? '').toString(),
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
            Padding(
              padding: EdgeInsets.fromLTRB(
                sw * 0.04,
                hasWalkIn ? sw * 0.02 : 0,
                sw * 0.04,
                sw * 0.04,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        convertToRelativeTime(job['time']),
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
    ),
    );
  }
}

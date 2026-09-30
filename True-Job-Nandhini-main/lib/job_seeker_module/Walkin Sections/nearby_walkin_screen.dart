import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../widgets/guest_popup.dart';
import '../Jobs Sections/job_detail_screen.dart';
import '../../services/api/jobs_api.dart';
import '../../services/api/job_api.dart';
import '../../utils/smooth_page_route.dart';
import '../../widgets/company_logo_widget.dart';

class NearbyWalkInScreen extends StatefulWidget {
  const NearbyWalkInScreen({super.key});

  @override
  State<NearbyWalkInScreen> createState() => _NearbyWalkInScreenState();
}

class _NearbyWalkInScreenState extends State<NearbyWalkInScreen> {
  List<Map<String, dynamic>> _walkInJobs = [];
  List<String> _savedJobIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
    _fetchJobs();
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

  Future<void> _loadSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    if (mounted) {
      setState(() {
        _savedJobIds = prefs.getStringList('saved_job_ids$suffix') ?? [];
      });
    }
  }

  Future<void> _toggleSave(Map<String, dynamic> job) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getUserSuffix();
    final List<String> list = prefs.getStringList('saved_job_ids$suffix') ?? [];
    final List<String> savedData =
        prefs.getStringList('saved_jobs_data$suffix') ?? [];
    final String jobIdStr = job['id'].toString();

    if (list.contains(jobIdStr)) {
      list.remove(jobIdStr);
      savedData.removeWhere((item) {
        final map = json.decode(item) as Map<String, dynamic>;
        return map['id'].toString() == jobIdStr;
      });
    } else {
      list.add(jobIdStr);
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
    _loadSavedJobs();

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

  Future<void> _fetchJobs() async {
    if (JobsApi.preloadedJobs != null && JobsApi.preloadedJobs!.isNotEmpty) {
      _filterWalkInJobs(JobsApi.preloadedJobs!);
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await JobsApi.fetchJobDetails();
      final mappedJobs = JobsApi.parseJobList(response);
      if (mappedJobs.isNotEmpty) {
        JobsApi.preloadedJobs = mappedJobs;
        _filterWalkInJobs(mappedJobs);
      }
    } catch (e) {
      debugPrint('Error fetching jobs on NearbyWalkInScreen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterWalkInJobs(List<Map<String, dynamic>> allJobs) {
    final filtered = <Map<String, dynamic>>[];
    for (final job in allJobs) {
      final method = job['interview_method']?.toString();
      if (method == '1') {
        filtered.add(job);
      }
    }
    if (mounted) {
      setState(() {
        _walkInJobs = filtered;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.04,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nearby Walk-in',
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _walkInJobs.isEmpty
            ? Center(
                child: Text(
                  'No walk-in jobs found.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04,
                  vertical: sw * 0.02,
                ),
                itemCount:
                    _walkInJobs.length + (_walkInJobs.length >= 2 ? 1 : 0),
                separatorBuilder: (context, index) =>
                    SizedBox(height: sw * 0.04),
                itemBuilder: (context, index) {
                  if (_walkInJobs.length >= 2 && index == 2) {
                    return _buildTopCompaniesBanner(sw);
                  }
                  final int jobIndex = (_walkInJobs.length >= 2 && index > 2)
                      ? index - 1
                      : index;
                  final job = _walkInJobs[jobIndex];
                  return _buildWalkInCard(job: job, sw: sw);
                },
              ),
      ),
    );
  }

  Widget _buildWalkInCard({
    required Map<String, dynamic> job,
    required double sw,
  }) {
    final String jobIdStr = job['id'].toString();
    final bool isSaved = _savedJobIds.contains(jobIdStr);

    final String title = (job['title'] ?? job['job_title'] ?? 'Walk-in Job')
        .toString();
    final String company = (job['company'] ?? job['company_name'] ?? 'Company')
        .toString();
    final String location =
        (job['location'] != null &&
            job['location'].toString().trim().isNotEmpty)
        ? job['location'].toString().trim()
        : ((job['job_city'] ??
                  job['job_area'] ??
                  job['walk_address'] ??
                  'Coimbatore')
              .toString());

    final String date =
        (job['walk_start'] ?? job['walkInDate'] ?? 'Walk-in Date').toString();
    final String time =
        (job['walk_timing'] != null && job['walk_time_end'] != null)
        ? '${job['walk_timing']} - ${job['walk_time_end']}'
        : (job['walkInTime'] ?? '10:00 AM - 05:00 PM').toString();

    final String skillsRaw = (job['skills'] ?? '').toString();
    final List<String> skills = skillsRaw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return GestureDetector(
      onTap: () async {
        if (await checkAndShowGuestPopup(context)) return;
        if (mounted) {
          Navigator.of(context)
              .push(SmoothPageRoute(child: JobDetailScreen(job: job)))
              .then((_) => _loadSavedJobs());
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
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
                        fallbackText: job['logoText']?.toString() ?? (company.isNotEmpty ? company[0].toUpperCase() : 'W'),
                        fallbackBgColor: job['logoBg'] is Color ? job['logoBg'] : Colors.blue.shade50,
                        fallbackTextColor: job['logoColor'] is Color ? job['logoColor'] : Colors.blue.shade700,
                        radius: sw * 0.06,
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: sw * 0.04,
                                  color: textColor,
                                ),
                              ),
                            ),
                            SizedBox(height: sw * 0.015),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/location.png',
                                  height: sw * 0.04,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: sw * 0.01),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: subtitleColor,
                                        fontSize: sw * 0.035,
                                      ),
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
                  SizedBox(height: sw * 0.01),
                  Divider(color: borderColor),
                  SizedBox(height: sw * 0.01),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: sw * 0.04,
                        color: subtitleColor,
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Walk-in : $date',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: sw * 0.03,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (time.isNotEmpty) ...[
                    SizedBox(height: sw * 0.01),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: sw * 0.04,
                          color: subtitleColor,
                        ),
                        SizedBox(width: sw * 0.02),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: sw * 0.03,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (skills.isNotEmpty) ...[
                    SizedBox(height: sw * 0.01),
                    Divider(color: borderColor),
                    SizedBox(height: sw * 0.01),
                    Wrap(
                      spacing: sw * 0.02,
                      runSpacing: sw * 0.02,
                      children: List.generate(skills.length, (i) {
                        final skill = skills[i];
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.03,
                            vertical: sw * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E62A3),
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: sw * 0.025,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  SizedBox(height: sw * 0.01),
                  Divider(color: borderColor),
                  SizedBox(height: sw * 0.01),
                  Row(
                    children: [
                      Image.asset(
                        'assets/location.png',
                        height: sw * 0.04,
                        color: subtitleColor,
                      ),
                      SizedBox(width: sw * 0.01),
                      Text(
                        'Near You • ',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: subtitleColor,
                            fontSize: sw * 0.03,
                          ),
                        ),
                      ),
                      Text(
                        'Walk-in Register',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: subtitleColor,
                            fontSize: sw * 0.03,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _toggleSave(job),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved
                                  ? AppColors.primary
                                  : subtitleColor,
                              size: sw * 0.04,
                            ),
                            SizedBox(width: sw * 0.01),
                            Text(
                              isSaved ? 'Saved' : 'Save Job',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: isSaved
                                      ? AppColors.primary
                                      : subtitleColor,
                                  fontSize: sw * 0.03,
                                  fontWeight: FontWeight.w500,
                                ),
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
                  horizontal: sw * 0.05,
                  vertical: sw * 0.025,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF448661),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(sw * 0.06),
                    topLeft: Radius.circular(sw * 0.06),
                  ),
                ),
                child: Text(
                  'Walk-in',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.035,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCompaniesBanner(double sw) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(sw * 0.06),
      child: SizedBox(
        width: double.infinity,
        height: sw * 0.4,
        child: Image.asset('assets/top_company_banner.png', fit: BoxFit.cover),
      ),
    );
  }
}

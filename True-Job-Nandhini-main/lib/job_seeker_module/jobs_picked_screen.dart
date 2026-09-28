import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/job_seeker_module/Jobs%20Sections/job_detail_screen.dart';
import 'package:truejobs/services/api/jobs_api.dart';
import 'package:truejobs/services/api/job_api.dart';
import 'package:truejobs/constants/date_formatter.dart';
import '../utils/smooth_page_route.dart';
import 'package:truejobs/widgets/guest_popup.dart';
import '../widgets/rupee_text.dart';
import '../widgets/company_logo_widget.dart';

class JobsPickedScreen extends StatefulWidget {
  const JobsPickedScreen({super.key});

  @override
  State<JobsPickedScreen> createState() => _JobsPickedScreenState();
}

class _JobsPickedScreenState extends State<JobsPickedScreen> {
  List<Map<String, dynamic>> _onlineJobs = [];
  List<String> _savedJobIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedJobIds();
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

  Future<void> _fetchJobs() async {
    if (JobsApi.preloadedJobs != null && JobsApi.preloadedJobs!.isNotEmpty) {
      _filterOnlineJobs(JobsApi.preloadedJobs!);
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
        _filterOnlineJobs(mappedJobs);
      }
    } catch (e) {
      debugPrint('Error fetching jobs on JobsPickedScreen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterOnlineJobs(List<Map<String, dynamic>> allJobs) {
    final filtered = <Map<String, dynamic>>[];
    for (final job in allJobs) {
      final method = job['interview_method']?.toString();
      if (method == '2') {
        filtered.add(job);
      }
    }
    if (mounted) {
      setState(() {
        _onlineJobs = filtered;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 0.05.sw),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Jobs Picked for you',
          style: TextStyle(
            color: textColor,
            fontSize: 0.055.sw,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _onlineJobs.isEmpty
              ? Center(
                  child: Text(
                    'No online jobs found.',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 0.04.sw,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.04.sw,
                    vertical: 0.02.sw,
                  ),
                  itemCount: _onlineJobs.length,
                  separatorBuilder: (context, index) => SizedBox(height: 0.04.sw),
                  itemBuilder: (context, index) {
                    final job = _onlineJobs[index];
                    return _buildJobCard(context, job, sw);
                  },
                ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, double sw) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    final String jobIdStr = job['id'].toString();
    final bool isSaved = _savedJobIds.contains(jobIdStr);

    final String title = (job['title'] ?? job['job_title'] ?? '').toString();
    final String company = (job['company'] ?? job['company_name'] ?? '').toString();
    final String exp = (job['exp'] ?? job['experience'] ?? '').toString();
    final String salary = (job['salary'] ?? '').toString();
    final String desc = (job['desc'] ?? job['job_description'] ?? '').toString();
    final String rawTime = (job['time'] ?? job['dtime'] ?? '').toString();
    final String relativeTime = rawTime.isNotEmpty ? convertToRelativeTime(rawTime) : '';

    final String logoText = job['logoText'] ?? (company.isNotEmpty ? company[0].toUpperCase() : 'J');
    final Color logoBg = job['logoBg'] is Color ? job['logoBg'] : Colors.blue.shade50;
    final Color logoColor = job['logoColor'] is Color ? job['logoColor'] : Colors.blue.shade700;

    return GestureDetector(
      onTap: () async {
        if (await checkAndShowGuestPopup(context)) return;
        if (context.mounted) {
          await Navigator.of(context).push(
            SmoothPageRoute(child: JobDetailScreen(job: job)),
          );
          _loadSavedJobIds();
        }
      },
      child: Container(
        padding: EdgeInsets.all(0.04.sw),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(0.03.sw),
          border: Border.all(color: Color(0xFFEFEFEF)),
          boxShadow: [
  BoxShadow(
    color: const Color(0x14000000), // #00000014
    offset: const Offset(0, 8),
    blurRadius: 16,
    spreadRadius: 0,
  ),
  BoxShadow(
    color: const Color(0x0A000000), // #0000000A
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyLogoWidget(
                  companyId: job['recuriter_name']?.toString() ?? '',
                  fallbackText: logoText,
                  fallbackBgColor: logoBg,
                  fallbackTextColor: logoColor,
                  radius: 20.0,
                ),
                SizedBox(width: 0.03.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 0.045.sw,
                          color: textColor,
                        ),
                      ),
                      Text(
                        company,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 0.035.sw,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 0.06.sw,
                ),
              ],
            ),
            SizedBox(height: 0.025.sw),
            Row(
              children: [
                Icon(Icons.business_center, size: 0.04.sw, color: subtitleColor),
                SizedBox(width: 0.02.sw),
                Expanded(
                  child: RupeeText(
                    text: '$exp  •  $salary',
                    style: TextStyle(color: subtitleColor, fontSize: 0.035.sw),
                  ),
                ),
              ],
            ),
            if (desc.isNotEmpty) ...[
              SizedBox(height: 0.015.sw),
              Text(
                desc,
                style: TextStyle(color: subtitleColor, fontSize: 0.032.sw),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 0.03.sw),
            Divider(color: borderColor, height: 1),
            SizedBox(height: 0.03.sw),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  relativeTime,
                  style: TextStyle(color: subtitleColor, fontSize: 0.032.sw),
                ),
                GestureDetector(
                  onTap: () => _toggleSaveJob(job),
                  child: Row(
                    children: [
                      Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? AppColors.primary : subtitleColor,
                        size: 0.045.sw,
                      ),
                      SizedBox(width: 0.01.sw),
                      Text(
                        isSaved ? 'Saved' : 'Save Job',
                        style: TextStyle(
                          color: isSaved ? AppColors.primary : subtitleColor,
                          fontSize: 0.032.sw,
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
    );
  }
}

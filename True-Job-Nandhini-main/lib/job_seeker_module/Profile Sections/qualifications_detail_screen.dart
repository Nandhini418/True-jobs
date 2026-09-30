import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/job_seeker_module/Profile%20Sections/add_education_screen.dart';
import '../../constants/app_colors.dart';
import 'package:truejobs/job_seeker_module/qualification_screen.dart';
import 'package:truejobs/job_seeker_module/experience_screen.dart';
import 'package:truejobs/job_seeker_module/add_skills_screen.dart';
import 'package:truejobs/services/api/educational_select_api.dart';
import 'package:truejobs/services/api/skills_select_api.dart';
import 'package:truejobs/services/api/board_api.dart';
import 'package:truejobs/services/api/stream_api.dart';
import 'package:truejobs/services/api/ug_course_api.dart';
import 'package:truejobs/services/api/pg_course_api.dart';
import 'package:truejobs/services/api/diploma_api.dart';
import 'package:truejobs/services/api/iti_trade_api.dart';
import 'package:truejobs/services/api/experience_select_api.dart';
import 'package:truejobs/services/api/experience_insert_api.dart';
import 'package:truejobs/services/api/experience_delete_api.dart';
import 'package:truejobs/services/api/profile_select_api.dart';
import 'package:truejobs/job_seeker_module/Profile%20Sections/add_project_screen.dart';
import 'package:truejobs/job_seeker_module/Profile%20Sections/add_internship_screen.dart';
import 'package:truejobs/services/api/project_select_api.dart';
import 'package:truejobs/services/api/project_update_api.dart';
import 'package:truejobs/services/api/project_delete_api.dart';
import 'package:truejobs/services/api/internship_select_api.dart';
import 'package:truejobs/services/api/internship_insert_api.dart';
import 'package:truejobs/services/api/internship_delete_api.dart';
import '../../utils/smooth_page_route.dart';

class PreviousExperienceEntry {
  final String? id;
  final String companyName;
  final String jobTitle;
  final String duration;

  PreviousExperienceEntry({
    this.id,
    required this.companyName,
    required this.jobTitle,
    required this.duration,
  });
}

class QualificationsDetailScreen extends StatefulWidget {
  const QualificationsDetailScreen({super.key});

  @override
  State<QualificationsDetailScreen> createState() =>
      _QualificationsDetailScreenState();
}

class _QualificationsDetailScreenState
    extends State<QualificationsDetailScreen> {
  String _highestQualification = 'UG';
  String _courseName = 'B.E. Artificial Intelligence Engineering';
  bool _isLoading = false;
  bool _hasExperience = false;
  String? _primaryExperienceId;

  List<String> _skills = [];

  String _totalExperience = '';
  String _prevJobTitle = '';
  String _prevJobCompany = '';
  String _prevJobSalary = '';
  String _prevJobDuration = '';
  String? _memberId;
  int _userAge = 23;

  /// List of manually added education entries (via Add Education button)
  final List<EducationEntry> _educationEntries = [];

  /// List of previous experiences parsed from backend
  final List<PreviousExperienceEntry> _previousExperiences = [];

  /// List of manually added project entries (via Add Project button)
  final List<ProjectEntry> _projectEntries = [];

  /// List of manually added internship entries (via Add Internship button)
  final List<InternshipEntry> _internshipEntries = [];

  @override
  void initState() {
    super.initState();
    _loadQualificationDetails();
  }

  Future<int?> _getValidUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          SmoothPageRoute(child: const RoleSelectionScreen()),
          (route) => false,
        );
      }
      return null;
    }
    return userId;
  }

  Future<void> _loadQualificationDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;

      // Fetch profile to calculate age
      try {
        final profileRes = await ProfileSelectApi.fetchProfile(userId: userId);
        if (profileRes['status'] == 'success' || profileRes['error'] == false) {
          final pData = profileRes['data'];
          if (pData != null && pData is Map<String, dynamic>) {
            final String dobVal = pData['dob']?.toString() ?? '';
            _userAge = _calculateAge(dobVal);
          }
        }
      } catch (e) {
        debugPrint('Error loading profile age: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> loadedSkills =
          prefs.getStringList('user_${userId}_skills') ?? [];

      final List<String> cachedProj =
          prefs.getStringList('user_${userId}_projects') ?? [];
      final List<ProjectEntry> loadedProj = cachedProj
          .map((str) {
            try {
              final map = jsonDecode(str) as Map<String, dynamic>;
              return ProjectEntry(
                id: map['id']?.toString(),
                projectName: map['projectName'] ?? '',
                startDate: map['startDate'] ?? '',
                endDate: map['endDate'] ?? '',
                details: map['details'] ?? '',
                keySkills: map['keySkills'] ?? '',
                projectUrl: map['projectUrl'] ?? '',
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<ProjectEntry>()
          .toList();

      final List<String> cachedIntern =
          prefs.getStringList('user_${userId}_internships') ?? [];
      final List<InternshipEntry> loadedIntern = cachedIntern
          .map((str) {
            try {
              final map = jsonDecode(str) as Map<String, dynamic>;
              return InternshipEntry(
                id: map['id']?.toString(),
                companyName: map['companyName'] ?? '',
                startDate: map['startDate'] ?? '',
                endDate: map['endDate'] ?? '',
                projectName: map['projectName'] ?? '',
                description: map['description'] ?? '',
                keySkills: map['keySkills'] ?? '',
                projectUrl: map['projectUrl'] ?? '',
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<InternshipEntry>()
          .toList();

      setState(() {
        _skills.clear();
        _skills.addAll(loadedSkills);
        _projectEntries.clear();
        _projectEntries.addAll(loadedProj);
        _internshipEntries.clear();
        _internshipEntries.addAll(loadedIntern);
      });

      final res = await EducationalSelectApi.fetchEducationalDetails(
        name: userId.toString(),
      );
      if (res['error'] == false || res['status'] == 'success') {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          // Fetch user skills from SkillsSelectApi (type 1134)
          try {
            final userSkillsRes = await SkillsSelectApi.fetchUserSkills(
              name: userId.toString(),
            );
            if (userSkillsRes['status'] == 'success' ||
                userSkillsRes['error'] == false) {
              List<dynamic> masterSkills = [];
              try {
                final skillsRes = await SkillsSelectApi.fetchSkills();
                if (skillsRes['error'] == false ||
                    skillsRes['status'] == 'success') {
                  masterSkills = skillsRes['data'] ?? [];
                }
              } catch (_) {}

              final rawData = userSkillsRes['data'];
              List<dynamic> skillItems = [];
              if (rawData is List) {
                skillItems = rawData;
              } else if (rawData is Map && rawData['skills'] != null) {
                if (rawData['skills'] is List) {
                  skillItems = rawData['skills'];
                }
              }

              if (skillItems.isNotEmpty) {
                final List<String> serverSkillNames = [];
                for (var item in skillItems) {
                  if (item is Map) {
                    final name =
                        item['name']?.toString() ??
                        item['skill_name']?.toString() ??
                        '';
                    if (name.isNotEmpty && !serverSkillNames.contains(name)) {
                      serverSkillNames.add(name);
                    }
                  } else if (item != null) {
                    final idStr = item.toString();
                    final matched = masterSkills.firstWhere(
                      (mSkill) =>
                          mSkill['value']?.toString() == idStr ||
                          mSkill['id']?.toString() == idStr,
                      orElse: () => null,
                    );
                    if (matched != null) {
                      final String name = matched['name']?.toString() ?? '';
                      if (name.isNotEmpty && !serverSkillNames.contains(name)) {
                        serverSkillNames.add(name);
                      }
                    } else if (int.tryParse(idStr) == null &&
                        idStr.isNotEmpty) {
                      if (!serverSkillNames.contains(idStr))
                        serverSkillNames.add(idStr);
                    }
                  }
                }

                if (serverSkillNames.isNotEmpty) {
                  await prefs.setStringList(
                    'user_${userId}_skills',
                    serverSkillNames,
                  );
                  if (mounted) {
                    setState(() {
                      _skills.clear();
                      _skills.addAll(serverSkillNames);
                    });
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('Error fetching user skills from server: $e');
          }

          // Fetch lookups first
          List<dynamic> boards = [];
          List<dynamic> streams = [];
          List<dynamic> ugCourses = [];
          List<dynamic> pgCourses = [];
          List<dynamic> diplomas = [];
          List<dynamic> trades = [];

          try {
            final boardsRes = await BoardApi.fetchBoards();
            if (boardsRes['error'] == false ||
                boardsRes['status'] == 'success') {
              boards = boardsRes['data'] ?? [];
            }
          } catch (_) {}

          try {
            final streamsRes = await StreamApi.fetchStreams();
            if (streamsRes['error'] == false ||
                streamsRes['status'] == 'success') {
              streams = streamsRes['data'] ?? [];
            }
          } catch (_) {}

          try {
            final ugRes = await UgCourseApi.fetchCourses();
            if (ugRes['error'] == false || ugRes['status'] == 'success') {
              ugCourses = ugRes['data'] ?? [];
            }
          } catch (_) {}

          try {
            final pgRes = await PgCourseApi.fetchCourses();
            if (pgRes['error'] == false || pgRes['status'] == 'success') {
              pgCourses = pgRes['data'] ?? [];
            }
          } catch (_) {}

          try {
            final dipRes = await DiplomaApi.fetchCourses();
            if (dipRes['error'] == false || dipRes['status'] == 'success') {
              diplomas = dipRes['data'] ?? [];
            }
          } catch (_) {}

          try {
            final tradesRes = await ItiTradeApi.fetchTrades();
            if (tradesRes['error'] == false ||
                tradesRes['status'] == 'success') {
              trades = tradesRes['data'] ?? [];
            }
          } catch (_) {}

          String getBoardName(String id) {
            final match = boards.firstWhere(
              (item) =>
                  item['value']?.toString() == id ||
                  item['id']?.toString() == id,
              orElse: () => null,
            );
            return match != null ? (match['name']?.toString() ?? '') : id;
          }

          String getStreamName(String id) {
            final match = streams.firstWhere(
              (item) =>
                  item['value']?.toString() == id ||
                  item['id']?.toString() == id,
              orElse: () => null,
            );
            return match != null ? (match['name']?.toString() ?? '') : id;
          }

          String getUgCourseName(String id) {
            final match = ugCourses.firstWhere(
              (item) =>
                  item['value']?.toString() == id ||
                  item['id']?.toString() == id,
              orElse: () => null,
            );
            return match != null ? (match['name']?.toString() ?? '') : id;
          }

          String getPgCourseName(String id) {
            final match = pgCourses.firstWhere(
              (item) =>
                  item['value']?.toString() == id ||
                  item['id']?.toString() == id,
              orElse: () => null,
            );
            return match != null ? (match['name']?.toString() ?? '') : id;
          }

          String getDiplomaName(String id) {
            final match = diplomas.firstWhere(
              (item) =>
                  item['value']?.toString() == id ||
                  item['id']?.toString() == id,
              orElse: () => null,
            );
            return match != null ? (match['name']?.toString() ?? '') : id;
          }

          String getTradeName(String id) {
            final match = trades.firstWhere(
              (item) =>
                  item['value']?.toString() == id ||
                  item['id']?.toString() == id,
              orElse: () => null,
            );
            return match != null ? (match['name']?.toString() ?? '') : id;
          }

          final String highQualifyVal = data['high_qualify']?.toString() ?? '';

          String categoryName = '';
          String detailText = '';

          if (highQualifyVal == '1') {
            categoryName = '10th';
            final String boardId = data['10th_board']?.toString() ?? '';
            final String school = data['10th_schl_name']?.toString() ?? '';
            final String boardText = getBoardName(boardId);
            detailText = [
              boardText,
              school,
            ].where((s) => s.isNotEmpty).join(' - ');
          } else if (highQualifyVal == '2') {
            categoryName = '12th';
            final String boardId = data['12th_board']?.toString() ?? '';
            final String streamId = data['12th_stream']?.toString() ?? '';
            final String school = data['12th_schl_name']?.toString() ?? '';
            final String boardText = getBoardName(boardId);
            final String streamText = getStreamName(streamId);
            final String boardStream = [
              boardText,
              streamText,
            ].where((s) => s.isNotEmpty).join(' / ');
            detailText = [
              boardStream,
              school,
            ].where((s) => s.isNotEmpty).join(' - ');
          } else if (highQualifyVal == '3') {
            categoryName = 'UG';
            final String courseId = data['ug_course']?.toString() ?? '';
            final String spec = data['ug_specialization']?.toString() ?? '';
            final String college = data['ug_college']?.toString() ?? '';
            final String courseText = getUgCourseName(courseId);
            final String courseSpec = spec.isNotEmpty
                ? '$courseText. $spec'
                : courseText;
            detailText = [
              courseSpec,
              college,
            ].where((s) => s.isNotEmpty).join(' - ');
          } else if (highQualifyVal == '4') {
            categoryName = 'PG';
            final String courseId = data['pg_course']?.toString() ?? '';
            final String spec = data['pg_specialization']?.toString() ?? '';
            final String college = data['pg_college']?.toString() ?? '';
            final String courseText = getPgCourseName(courseId);
            final String courseSpec = spec.isNotEmpty
                ? '$courseText $spec'
                : courseText;
            detailText = [
              courseSpec,
              college,
            ].where((s) => s.isNotEmpty).join(' - ');
          } else if (highQualifyVal == '5') {
            categoryName = 'Diploma';
            final String courseId = data['diploma']?.toString() ?? '';
            final String inst = data['dip_institute']?.toString() ?? '';
            final String courseText = getDiplomaName(courseId);
            detailText = [
              courseText,
              inst,
            ].where((s) => s.isNotEmpty).join(' - ');
          } else if (highQualifyVal == '6') {
            categoryName = 'ITI';
            final String tradeId = data['iti_trade']?.toString() ?? '';
            final String spec = data['iti_specialization']?.toString() ?? '';
            final String boardId = data['iti_board']?.toString() ?? '';
            final String boardText = boardId == '2'
                ? 'SCVT'
                : (boardId == '1' ? 'NCVT' : '');
            final String inst = data['iti_institute']?.toString() ?? '';
            final String tradeText = getTradeName(tradeId);
            final String tradeSpec = [tradeText, spec]
                .where((s) => s.isNotEmpty)
                .join(' (${spec.isNotEmpty ? spec : ''})');
            final String tradeBoard = [
              tradeSpec,
              boardText,
            ].where((s) => s.isNotEmpty).join(' / ');
            detailText = [
              tradeBoard,
              inst,
            ].where((s) => s.isNotEmpty).join(' - ');
          }

          final List<EducationEntry> fetchedEntries = [];

          // 1. Tenth
          final String tBoard = data['10th_board']?.toString() ?? '';
          if (tBoard.isNotEmpty && tBoard != '0') {
            fetchedEntries.add(
              EducationEntry(
                type: '10th',
                details: {
                  'board': getBoardName(tBoard),
                  'schoolName': data['10th_schl_name']?.toString() ?? '',
                  'passingYear': data['10th_year_complete']?.toString() ?? '',
                  'marks': data['10th_percent_cgpa']?.toString() ?? '',
                },
              ),
            );
          }

          // 2. Twelfth
          final String twBoard = data['12th_board']?.toString() ?? '';
          if (twBoard.isNotEmpty && twBoard != '0') {
            fetchedEntries.add(
              EducationEntry(
                type: '12th',
                details: {
                  'board': getBoardName(twBoard),
                  'stream': getStreamName(
                    data['12th_stream']?.toString() ?? '',
                  ),
                  'schoolName': data['12th_schl_name']?.toString() ?? '',
                  'passingYear': data['12th_year_complete']?.toString() ?? '',
                  'marks': data['12th_percent_cgpa']?.toString() ?? '',
                },
              ),
            );
          }

          // 3. UG
          final String ugCourse = data['ug_course']?.toString() ?? '';
          if (ugCourse.isNotEmpty && ugCourse != '0') {
            fetchedEntries.add(
              EducationEntry(
                type: 'UG',
                details: {
                  'courseName': getUgCourseName(ugCourse),
                  'specialization': data['ug_specialization']?.toString() ?? '',
                  'collegeName': data['ug_college']?.toString() ?? '',
                  'university': data['ug_university']?.toString() ?? '',
                  'marks': data['ug_percent_cgpa']?.toString() ?? '',
                  'passingYear': data['ug_year_complete']?.toString() ?? '',
                  'duration': data['ug_duration']?.toString() ?? '',
                },
              ),
            );
          }

          // 4. PG
          final String pgCourse = data['pg_course']?.toString() ?? '';
          if (pgCourse.isNotEmpty && pgCourse != '0') {
            fetchedEntries.add(
              EducationEntry(
                type: 'PG',
                details: {
                  'courseName': getPgCourseName(pgCourse),
                  'specialization': data['pg_specialization']?.toString() ?? '',
                  'collegeName': data['pg_college']?.toString() ?? '',
                  'university': data['pg_university']?.toString() ?? '',
                  'marks': data['pg_percent_cgpa']?.toString() ?? '',
                  'passingYear': data['pg_year_complete']?.toString() ?? '',
                  'duration': data['pg_duration']?.toString() ?? '',
                },
              ),
            );
          }

          // 5. Diploma
          final String dip = data['diploma']?.toString() ?? '';
          if (dip.isNotEmpty && dip != '0') {
            fetchedEntries.add(
              EducationEntry(
                type: 'Diploma',
                details: {
                  'courseName': getDiplomaName(dip),
                  'instituteName': data['dip_institute']?.toString() ?? '',
                  'board': data['dip_board_university']?.toString() ?? '',
                  'marks': data['dip_percent']?.toString() ?? '',
                  'passingYear': data['dip_year_complete']?.toString() ?? '',
                  'duration': data['dip_duration']?.toString() ?? '',
                },
              ),
            );
          }

          // 6. ITI
          final String iti = data['iti_trade']?.toString() ?? '';
          if (iti.isNotEmpty && iti != '0') {
            fetchedEntries.add(
              EducationEntry(
                type: 'ITI',
                details: {
                  'tradeName': getTradeName(iti),
                  'specialization':
                      data['iti_specialization']?.toString() ?? '',
                  'board': data['iti_board']?.toString() == '1'
                      ? 'NCVT'
                      : (data['iti_board']?.toString() == '2' ? 'SCVT' : ''),
                  'instituteName': data['iti_institute']?.toString() ?? '',
                  'passingYear': data['iti_year_complete']?.toString() ?? '',
                  'duration': data['iti_duration']?.toString() ?? '',
                  'marks': data['iti_percent']?.toString() ?? '',
                },
              ),
            );
          }

          if (mounted) {
            setState(() {
              _highestQualification = categoryName.isNotEmpty
                  ? categoryName
                  : 'Not Set';
              _courseName = detailText;
              _educationEntries.clear();
              _educationEntries.addAll(fetchedEntries);
            });
          }
        }
      }

      // Fetch Experience Details
      try {
        final expRes = await ExperienceSelectApi.fetchExperienceDetails(
          name: userId.toString(),
        );
        if (expRes['status'] == 'success' || expRes['error'] == false) {
          final expData = expRes['data'];
          if (expData != null && expData is Map<String, dynamic>) {
            _memberId = expData['id']?.toString();
            final List<dynamic> expList = expData['experiences'] ?? [];
            final List<PreviousExperienceEntry> parsedPrev = [];

            bool youHaveExp = false;
            String mainTotExp = '';
            String mainJobTitle = '';
            String mainCompany = '';
            String mainSalary = '';
            String? primaryId;

            if (expList.isNotEmpty) {
              final primaryItem = expList.first;
              if (primaryItem is Map) {
                primaryId = primaryItem['id']?.toString();
                final String youHaveExpStr = primaryItem['you_have_experience']?.toString() ?? '0';
                youHaveExp = youHaveExpStr == '1';
                if (youHaveExp) {
                  mainTotExp = primaryItem['tot_year_xperience']?.toString() ?? '0';
                  mainJobTitle = primaryItem['job_title']?.toString() ?? '';
                  mainCompany = primaryItem['company_name']?.toString() ?? '';
                  
                  final String apiSalary = primaryItem['current_salary']?.toString() ?? '';
                  mainSalary = apiSalary.isNotEmpty
                      ? apiSalary
                      : (prefs.getString('user_${userId}_experience_salary') ??
                            prefs.getString('experience_salary') ??
                            '');
                }
              }

              // The rest of the experiences (index >= 1) are previous experiences
              for (int i = 1; i < expList.length; i++) {
                final item = expList[i];
                if (item is Map) {
                  final String youHaveExpStr = item['you_have_experience']?.toString() ?? '0';
                  if (youHaveExpStr == '1') {
                    parsedPrev.add(
                      PreviousExperienceEntry(
                        id: item['id']?.toString(),
                        companyName: item['company_name']?.toString() ?? '',
                        jobTitle: item['job_title']?.toString() ?? '',
                        duration: item['tot_year_xperience']?.toString() ?? '0',
                      ),
                    );
                  }
                }
              }
            }

            double sumYears = 0.0;
            for (var exp in parsedPrev) {
              final clean = exp.duration.replaceAll(RegExp(r'[^0-9.]'), '');
              final val = double.tryParse(clean) ?? 0.0;
              sumYears += val;
            }

            String displayTotal = '';
            if (sumYears > 0) {
              if (sumYears == sumYears.toInt()) {
                displayTotal = '${sumYears.toInt()} Years';
              } else {
                displayTotal = '$sumYears Years';
              }
            } else {
              displayTotal = mainTotExp.isNotEmpty
                ? '$mainTotExp Years'
                  : '0 Years';
            }

            setState(() {
              _primaryExperienceId = primaryId;
              _hasExperience = youHaveExp;
              _totalExperience = youHaveExp ? displayTotal : 'Fresher';
              _prevJobTitle = mainJobTitle;
              _prevJobCompany = mainCompany;
              _prevJobSalary = mainSalary.isNotEmpty ? 'Rs. $mainSalary' : '';
              _prevJobDuration = mainTotExp;
              _previousExperiences.clear();
              _previousExperiences.addAll(parsedPrev);
            });

            // Cache experience in SharedPreferences
            await prefs.setBool('user_${userId}_you_have_experience', youHaveExp);
            await prefs.setBool('you_have_experience', youHaveExp);
            final String expId = primaryId ?? '';
            await prefs.setString('user_${userId}_experience_id', expId);
            await prefs.setString('experience_id', expId);
            if (youHaveExp) {
              await prefs.setString('user_${userId}_job_title', mainJobTitle);
              await prefs.setString('job_title', mainJobTitle);
              await prefs.setString('user_${userId}_company_name', mainCompany);
              await prefs.setString('company_name', mainCompany);
              if (mainSalary.isNotEmpty) {
                await prefs.setString('user_${userId}_experience_salary', mainSalary);
                await prefs.setString('experience_salary', mainSalary);
              }
            } else {
              await prefs.setString('user_${userId}_job_title', '');
              await prefs.setString('job_title', '');
              await prefs.setString('user_${userId}_company_name', '');
              await prefs.setString('company_name', '');
              await prefs.remove('user_${userId}_experience_salary');
              await prefs.remove('experience_salary');
            }
          } else {
            setState(() {
              _primaryExperienceId = null;
              _hasExperience = false;
              _totalExperience = 'Fresher';
              _prevJobTitle = '';
              _prevJobCompany = '';
              _prevJobSalary = '';
              _prevJobDuration = '';
              _previousExperiences.clear();
            });
            await prefs.setBool('user_${userId}_you_have_experience', false);
            await prefs.setBool('you_have_experience', false);
            await prefs.setString('user_${userId}_experience_id', '');
            await prefs.setString('experience_id', '');
            await prefs.setString('user_${userId}_job_title', '');
            await prefs.setString('job_title', '');
            await prefs.setString('user_${userId}_company_name', '');
            await prefs.setString('company_name', '');
            await prefs.remove('user_${userId}_experience_salary');
            await prefs.remove('experience_salary');
          }
        } else {
          setState(() {
            _hasExperience = false;
            _totalExperience = 'Fresher';
            _prevJobTitle = '';
            _prevJobCompany = '';
            _prevJobSalary = '';
            _prevJobDuration = '';
            _previousExperiences.clear();
          });
          await prefs.setBool('user_${userId}_you_have_experience', false);
          await prefs.setBool('you_have_experience', false);
          await prefs.setString('user_${userId}_experience_id', '');
          await prefs.setString('experience_id', '');
          await prefs.setString('user_${userId}_job_title', '');
          await prefs.setString('job_title', '');
          await prefs.setString('user_${userId}_company_name', '');
          await prefs.setString('company_name', '');
          await prefs.remove('user_${userId}_experience_salary');
          await prefs.remove('experience_salary');
        }
      } catch (e) {
        debugPrint('Error loading experience details: $e');
        setState(() {
          _hasExperience = false;
          _totalExperience = 'Fresher';
          _prevJobTitle = '';
          _prevJobCompany = '';
          _prevJobSalary = '';
          _prevJobDuration = '';
          _previousExperiences.clear();
        });
      }

      // Fetch Project Details from API
      try {
        final projRes = await ProjectSelectApi.fetchProjects(
          name: userId.toString(),
        );
        if (projRes['status'] == 'success' || projRes['error'] == false) {
          final dynamic rawData = projRes['data'];
          List<dynamic> fetchedProjs = [];
          if (rawData is List) {
            fetchedProjs = rawData;
          } else if (rawData is Map && rawData['projects'] != null) {
            if (rawData['projects'] is List) {
              fetchedProjs = rawData['projects'];
            }
          }

          final List<ProjectEntry> serverProj = [];
          for (var item in fetchedProjs) {
            if (item is Map) {
              serverProj.add(
                ProjectEntry(
                  id: item['id']?.toString(),
                  projectName: item['project_name']?.toString() ?? '',
                  startDate: item['start_date']?.toString() ?? '',
                  endDate: item['end_date']?.toString() ?? '',
                  details: item['project_details']?.toString() ?? '',
                  keySkills: item['key_skills']?.toString() ?? '',
                  projectUrl:
                      (item['Project_url'] ?? item['project_url'])
                          ?.toString() ??
                      '',
                ),
              );
            }
          }

          if (serverProj.isNotEmpty) {
            final List<String> jsonList = serverProj
                .map(
                  (e) => jsonEncode({
                    'id': e.id,
                    'projectName': e.projectName,
                    'startDate': e.startDate,
                    'endDate': e.endDate,
                    'details': e.details,
                    'keySkills': e.keySkills,
                    'projectUrl': e.projectUrl,
                  }),
                )
                .toList();
            await prefs.setStringList('user_${userId}_projects', jsonList);

            setState(() {
              _projectEntries.clear();
              _projectEntries.addAll(serverProj);
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching project details from API: $e');
      }

      // Fetch Internship Details from API
      try {
        final internRes = await InternshipSelectApi.fetchInternships(
          name: userId.toString(),
        );
        if (internRes['status'] == 'success' || internRes['error'] == false) {
          final dynamic rawData = internRes['data'];
          List<dynamic> fetchedInterns = [];
          if (rawData is List) {
            fetchedInterns = rawData;
          } else if (rawData is Map) {
            if (rawData['internships'] is List) {
              fetchedInterns = rawData['internships'];
            } else if (rawData['projects'] is List) {
              fetchedInterns = rawData['projects'];
            } else if (rawData['internship'] is List) {
              fetchedInterns = rawData['internship'];
            }
          }

          final List<InternshipEntry> serverIntern = [];
          for (var item in fetchedInterns) {
            if (item is Map) {
              serverIntern.add(
                InternshipEntry(
                  id: item['id']?.toString(),
                  companyName: item['company_name']?.toString() ?? '',
                  startDate: item['start_date']?.toString() ?? '',
                  endDate: item['end_date']?.toString() ?? '',
                  projectName: item['project_name']?.toString() ?? '',
                  description: item['project_details']?.toString() ?? '',
                  keySkills: item['key_skills']?.toString() ?? '',
                  projectUrl:
                      (item['Project_url'] ?? item['project_url'])
                          ?.toString() ??
                      '',
                ),
              );
            }
          }

          final List<String> jsonList = serverIntern
              .map(
                (e) => jsonEncode({
                  'id': e.id,
                  'companyName': e.companyName,
                  'startDate': e.startDate,
                  'endDate': e.endDate,
                  'projectName': e.projectName,
                  'description': e.description,
                  'keySkills': e.keySkills,
                  'projectUrl': e.projectUrl,
                }),
              )
              .toList();
          await prefs.setStringList('user_${userId}_internships', jsonList);

          setState(() {
            _internshipEntries.clear();
            _internshipEntries.addAll(serverIntern);
          });
        }
      } catch (e) {
        debugPrint('Error fetching internship details from API: $e');
      }
    } catch (e) {
      debugPrint('Error loading qualification details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _calculateAge(String dobStr) {
    if (dobStr.isEmpty) return 23;
    try {
      if (dobStr.contains('/')) {
        final parts = dobStr.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final dob = DateTime(year, month, day);
          final today = DateTime.now();
          int age = today.year - dob.year;
          if (today.month < dob.month ||
              (today.month == dob.month && today.day < dob.day)) {
            age--;
          }
          return age;
        }
      } else if (dobStr.contains('-')) {
        final parts = dobStr.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final dob = DateTime(year, month, day);
          final today = DateTime.now();
          int age = today.year - dob.year;
          if (today.month < dob.month ||
              (today.month == dob.month && today.day < dob.day)) {
            age--;
          }
          return age;
        }
      }
    } catch (_) {}
    return 23;
  }

  // â”€â”€ Navigate to AddEducationScreen and handle result â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _openAddEducation({
    EducationEntry? existing,
    int? editIndex,
  }) async {
    final result = await Navigator.push<EducationEntry>(
      context,
      SmoothPageRoute(child: AddEducationScreen(existingEntry: existing)),
    );
    if (result != null) {
      setState(() {
        if (editIndex != null) {
          _educationEntries[editIndex] = result;
        } else {
          _educationEntries.add(result);
        }
      });
    }
  }

  Future<void> _saveProjectsToPrefs() async {
    final int? userId = await _getValidUserId();
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = _projectEntries
        .map(
          (e) => jsonEncode({
            'id': e.id,
            'projectName': e.projectName,
            'startDate': e.startDate,
            'endDate': e.endDate,
            'details': e.details,
            'keySkills': e.keySkills,
            'projectUrl': e.projectUrl,
          }),
        )
        .toList();
    await prefs.setStringList('user_${userId}_projects', jsonList);
  }

  Future<void> _saveInternshipsToPrefs() async {
    final int? userId = await _getValidUserId();
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = _internshipEntries
        .map(
          (e) => jsonEncode({
            'id': e.id,
            'companyName': e.companyName,
            'startDate': e.startDate,
            'endDate': e.endDate,
            'projectName': e.projectName,
            'description': e.description,
            'keySkills': e.keySkills,
            'projectUrl': e.projectUrl,
          }),
        )
        .toList();
    await prefs.setStringList('user_${userId}_internships', jsonList);
  }

  Future<void> _openAddProject({ProjectEntry? existing, int? editIndex}) async {
    final result = await Navigator.push<dynamic>(
      context,
      SmoothPageRoute(child: AddProjectScreen(existingEntry: existing)),
    );
    if (result != null) {
      final int? userId = await _getValidUserId();
      if (userId == null) return;

      if (result == 'delete' && editIndex != null && existing != null) {
        if (existing.id != null && existing.id!.isNotEmpty) {
          setState(() {
            _isLoading = true;
          });
          try {
            final delRes = await ProjectDeleteApi.deleteProject(
              name: userId.toString(),
              id: existing.id!,
            );
            if (delRes['status'] == 'success' || delRes['error'] == false) {
              setState(() {
                _projectEntries.removeAt(editIndex);
              });
              await _saveProjectsToPrefs();
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      delRes['message'] ?? 'Failed to delete project',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Error deleting project: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          setState(() {
            _projectEntries.removeAt(editIndex);
          });
          await _saveProjectsToPrefs();
        }
        _loadQualificationDetails();
      } else if (result is ProjectEntry) {
        setState(() {
          _isLoading = true;
        });
        try {
          final bool isNew = (existing == null);
          final String? sanitizedId = isNew ? null : existing.id;

          final upRes = await ProjectUpdateApi.updateProject(
            name: userId.toString(),
            id: sanitizedId,
            projectName: result.projectName,
            startDate: result.startDate,
            endDate: result.endDate,
            projectDetails: result.details,
            keySkills: result.keySkills,
            projectUrl: result.projectUrl,
          );

          if (upRes['status'] == 'success' ||
              upRes['status'] == 'added' ||
              upRes['status'] == 'updated' ||
              upRes['error'] == false) {
            _loadQualificationDetails();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(upRes['message'] ?? 'Failed to save project'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Error saving project: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  Future<void> _openAddInternship({
    InternshipEntry? existing,
    int? editIndex,
  }) async {
    final result = await Navigator.push<dynamic>(
      context,
      SmoothPageRoute(child: AddInternshipScreen(existingEntry: existing)),
    );
    if (result != null) {
      final int? userId = await _getValidUserId();
      if (userId == null) return;

      if (result == 'delete' && editIndex != null && existing != null) {
        if (existing.id != null && existing.id!.isNotEmpty) {
          setState(() {
            _isLoading = true;
          });
          try {
            final delRes = await InternshipDeleteApi.deleteInternship(
              name: userId.toString(),
              id: existing.id!,
            );
            if (delRes['status'] == 'success' || delRes['error'] == false) {
              setState(() {
                _internshipEntries.removeAt(editIndex);
              });
              await _saveInternshipsToPrefs();
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      delRes['message'] ?? 'Failed to delete internship',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Error deleting internship: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          setState(() {
            _internshipEntries.removeAt(editIndex);
          });
          await _saveInternshipsToPrefs();
        }
        _loadQualificationDetails();
      } else if (result is InternshipEntry) {
        setState(() {
          _isLoading = true;
        });
        try {
          final bool isNew = (existing == null);
          final String? sanitizedId = isNew ? null : existing.id;

          final upRes = await InternshipInsertApi.insertInternship(
            name: userId.toString(),
            id: sanitizedId,
            companyName: result.companyName,
            projectName: result.projectName,
            startDate: result.startDate,
            endDate: result.endDate,
            projectDetails: result.description,
            keySkills: result.keySkills,
            projectUrl: result.projectUrl,
          );

          if (upRes['status'] == 'success' ||
              upRes['status'] == 'added' ||
              upRes['status'] == 'updated' ||
              upRes['error'] == false) {
            _loadQualificationDetails();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    upRes['message'] ?? 'Failed to save internship',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Error saving internship: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double sw = size.width;

    // Responsive sizing helpers using media query
    final double paddingHorizontal = sw * 0.05;
    final double headingFontSize = sw * 0.045;
    final double subHeadingFontSize = sw * 0.038;
    final double bodyFontSize = sw * 0.035;
    final double chipFontSize = sw * 0.032;
    final double iconSize = sw * 0.055;
    final double sectionSpacing = sw * 0.06;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: sw * 0.15,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.045,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Qualifications',
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: sw * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Education Section
                    Container(
                      margin: EdgeInsets.only(bottom: sectionSpacing),
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                color: subtitleColor,
                                size: iconSize,
                              ),
                              SizedBox(width: sw * 0.03),
                              Text(
                                'Education',
                                style: TextStyle(
                                  fontSize: headingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.04),

                          // CONTENT
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Highest Qualification Container
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(sw * 0.04),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Highest Qualification: $_highestQualification',
                                                style: TextStyle(
                                                  fontSize: subHeadingFontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              _buildEditButton(sw, () async {
                                                await Navigator.push(
                                                  context,
                                                  SmoothPageRoute(
                                                    child:
                                                        const QualificationScreen(
                                                          isEditing: true,
                                                        ),
                                                  ),
                                                );
                                                _loadQualificationDetails();
                                              }),
                                            ],
                                          ),
                                          if (_courseName.isNotEmpty) ...[
                                            SizedBox(height: sw * 0.025),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: sw * 0.04,
                                                vertical: sw * 0.02,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE7EFFF),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _courseName,
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: chipFontSize,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sw * 0.05),

                              // Educational Details Heading
                              Text(
                                'Educational Details',
                                style: TextStyle(
                                  fontSize: subHeadingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              SizedBox(height: sw * 0.015),

                              Text(
                                'Add your educational qualifications here.',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: subtitleColor,
                                ),
                              ),

                              // â”€â”€ Saved education entry cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                              if (_educationEntries.isNotEmpty) ...[
                                SizedBox(height: sw * 0.04),
                                ..._educationEntries.asMap().entries.map(
                                  (entry) => _buildEducationEntryCard(
                                    entry.value,
                                    entry.key,
                                    sw,
                                    subHeadingFontSize,
                                    bodyFontSize,
                                    chipFontSize,
                                  ),
                                ),
                              ],

                              SizedBox(height: sw * 0.04),

                              // Add Education Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _openAddEducation(),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: EdgeInsets.symmetric(
                                      vertical: sw * 0.035,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Add Education',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 2. Skills Section
                    Container(
                      margin: EdgeInsets.only(bottom: sectionSpacing),
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: subtitleColor,
                                size: iconSize,
                              ),
                              SizedBox(width: sw * 0.03),
                              Text(
                                'Skills',
                                style: TextStyle(
                                  fontSize: headingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              _buildEditButton(sw, () async {
                                await Navigator.push(
                                  context,
                                  SmoothPageRoute(
                                    child: const AddSkillsScreen(),
                                  ),
                                );
                                _loadQualificationDetails();
                              }),
                            ],
                          ),

                          SizedBox(height: sw * 0.04),

                          // SKILLS CONTENT
                          if (_skills.isEmpty)
                            Text(
                              'Add your skills',
                              style: TextStyle(
                                fontSize: bodyFontSize,
                                color: subtitleColor,
                              ),
                            )
                          else
                            Wrap(
                              spacing: sw * 0.03,
                              runSpacing: sw * 0.025,
                              children: _skills
                                  .map((skill) => _buildSkillChip(skill, sw))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),

                    // 3. Experience Section
                    Container(
                      margin: EdgeInsets.only(bottom: sectionSpacing),
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Row(
                            children: [
                              Icon(
                                Icons.business_center_rounded,
                                color: subtitleColor,
                                size: iconSize,
                              ),
                              SizedBox(width: sw * 0.03),
                              Text(
                                'Experience',
                                style: TextStyle(
                                  fontSize: headingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              _buildEditButton(sw, () async {
                                await Navigator.of(context).push(
                                  SmoothPageRoute(
                                    child: const ExperienceScreen(
                                      isEditing: true,
                                    ),
                                  ),
                                );
                                _loadQualificationDetails();
                              }),
                            ],
                          ),

                          SizedBox(height: sw * 0.04),

                          Text(
                            'Total years of experience: $_totalExperience',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: textColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          if (_hasExperience) ...[
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: sw * 0.03),
                              padding: EdgeInsets.all(sw * 0.04),
                              decoration: BoxDecoration(
                                color: cardBg,
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_prevJobCompany.isNotEmpty)
                                    Text(
                                      _prevJobCompany,
                                      style: TextStyle(
                                        fontSize: subHeadingFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  if (_prevJobTitle.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: sw * 0.01),
                                      child: Text(
                                        _prevJobTitle,
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ),
                                  if (_prevJobDuration.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: sw * 0.01),
                                      child: Text(
                                        'Experience: $_prevJobDuration Years',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ),
                                  if (_prevJobSalary.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: sw * 0.01),
                                      child: Text(
                                        'Salary: $_prevJobSalary',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: sw * 0.05),
                            Text(
                              'Previous Experience',
                              style: TextStyle(
                                fontSize: subHeadingFontSize,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: sw * 0.03),

                            // Listed Previous Experiences
                            if (_previousExperiences.isNotEmpty) ...[
                              ..._previousExperiences.asMap().entries.map(
                                (entry) => _buildPreviousExperienceCard(
                                  entry.value,
                                  entry.key,
                                  sw,
                                  subHeadingFontSize,
                                  bodyFontSize,
                                  chipFontSize,
                                ),
                              ),
                              SizedBox(height: sw * 0.03),
                            ],

                            // Add Previous Experience button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showAddEditExperienceDialog(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(
                                    vertical: sw * 0.035,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Add Experience',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (!_hasExperience) ...[
                            SizedBox(height: sw * 0.04),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    SmoothPageRoute(
                                      child: const ExperienceScreen(
                                        isEditing: true,
                                      ),
                                    ),
                                  );
                                  _loadQualificationDetails();
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(
                                    vertical: sw * 0.035,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Add Experience',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: sectionSpacing),
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_copy_rounded,
                                color: subtitleColor,
                                size: iconSize,
                              ),
                              SizedBox(width: sw * 0.03),

                              Text(
                                "Projects",
                                style: TextStyle(
                                  fontSize: headingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: sw * 0.04),

                          Text(
                            "Showcase your academic or personal projects.",
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: subtitleColor,
                            ),
                          ),
                          if (_projectEntries.isNotEmpty) ...[
                            SizedBox(height: sw * 0.04),
                            ..._projectEntries.asMap().entries.map(
                              (entry) => _buildProjectEntryCard(
                                entry.value,
                                entry.key,
                                sw,
                                subHeadingFontSize,
                                bodyFontSize,
                                chipFontSize,
                              ),
                            ),
                          ],

                          SizedBox(height: sw * 0.04),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openAddProject(),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  vertical: sw * 0.035,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                'Add Project',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: sectionSpacing),
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_center_rounded,
                                color: subtitleColor,
                                size: iconSize,
                              ),
                              SizedBox(width: sw * 0.03),

                              Text(
                                "Internships",
                                style: TextStyle(
                                  fontSize: headingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: sw * 0.04),

                          Text(
                            "Highlight your internship experience.",
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: subtitleColor,
                            ),
                          ),
                          if (_internshipEntries.isNotEmpty) ...[
                            SizedBox(height: sw * 0.04),
                            ..._internshipEntries.asMap().entries.map(
                              (entry) => _buildInternshipEntryCard(
                                entry.value,
                                entry.key,
                                sw,
                                subHeadingFontSize,
                                bodyFontSize,
                                chipFontSize,
                              ),
                            ),
                          ],

                          SizedBox(height: sw * 0.04),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openAddInternship(),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  vertical: sw * 0.035,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                'Add Internship',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // â”€â”€ Education Entry Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildEducationEntryCard(
    EducationEntry entry,
    int index,
    double sw,
    double subHeadingFontSize,
    double bodyFontSize,
    double chipFontSize,
  ) {
    final details = entry.details;

    // Build detail rows based on entry type
    List<Widget> detailRows = [];

    switch (entry.type) {
      case '10th':
        if (details['board']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Board', details['board']!),
          );
        if (details['passingYear']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Passing Year',
              details['passingYear']!,
            ),
          );
        if (details['gradingSystem']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Grading System',
              details['gradingSystem']!,
            ),
          );
        if (details['marks']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Marks / CGPA', details['marks']!),
          );
        break;

      case '12th':
        if (details['board']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Board', details['board']!),
          );
        if (details['stream']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Stream', details['stream']!),
          );
        if (details['passingYear']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Passing Year',
              details['passingYear']!,
            ),
          );
        if (details['gradingSystem']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Grading System',
              details['gradingSystem']!,
            ),
          );
        if (details['marks']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Marks / CGPA', details['marks']!),
          );
        break;

      case 'UG':
      case 'PG':
        if (details['specialization']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Specialization',
              details['specialization']!,
            ),
          );
        if (details['university']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'University', details['university']!),
          );
        if (details['marks']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Marks / CGPA', details['marks']!),
          );
        if (details['passingYear']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Passing Year',
              details['passingYear']!,
            ),
          );
        if (details['duration']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Duration',
              details['duration']! +
                  (int.tryParse(details['duration']!) != null ? ' Years' : ''),
            ),
          );
        break;

      case 'Diploma':
        if (details['board']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Board', details['board']!),
          );
        if (details['marks']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Marks / CGPA', details['marks']!),
          );
        if (details['passingYear']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Passing Year',
              details['passingYear']!,
            ),
          );
        if (details['duration']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Duration',
              details['duration']! +
                  (int.tryParse(details['duration']!) != null ? ' Years' : ''),
            ),
          );
        break;

      case 'ITI':
        if (details['specialization']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Specialization',
              details['specialization']!,
            ),
          );
        if (details['board']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Board', details['board']!),
          );
        if (details['duration']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Duration',
              details['duration']! +
                  (int.tryParse(details['duration']!) != null ? ' Years' : ''),
            ),
          );
        if (details['passingYear']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(
              sw,
              bodyFontSize,
              'Passing Year',
              details['passingYear']!,
            ),
          );
        if (details['marks']?.isNotEmpty == true)
          detailRows.add(
            _detailRow(sw, bodyFontSize, 'Marks / CGPA', details['marks']!),
          );
        break;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: sw * 0.03),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.dynamicCardBg,
        border: Border.all(color: AppColors.dynamicBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header: type badge + title + edit button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main title (school/college/course name)
                    Text(
                      entry.displayTitle,
                      style: TextStyle(
                        fontSize: subHeadingFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dynamicText,
                      ),
                    ),
                    if (entry.displaySubtitle.isNotEmpty) ...[
                      SizedBox(height: sw * 0.01),
                      Text(
                        entry.displaySubtitle,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: AppColors.dynamicSubtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: sw * 0.02),
              _buildEditButton(
                sw,
                () => _openAddEducation(existing: entry, editIndex: index),
              ),
            ],
          ),

          // Detail rows
          if (detailRows.isNotEmpty) ...[
            SizedBox(height: sw * 0.02),
            Divider(color: AppColors.dynamicBorder, thickness: 1),
            SizedBox(height: sw * 0.02),
            ...detailRows,
          ],
        ],
      ),
    );
  }

  Widget _detailRow(double sw, double fontSize, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.018),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: sw * 0.28,
            child: Text(
              label,
              style: TextStyle(fontSize: fontSize, color: AppColors.primary),
            ),
          ),
          Text(
            ':   ',
            style: TextStyle(fontSize: fontSize, color: AppColors.dynamicText),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.dynamicText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Edit Button Widget
  Widget _buildEditButton(double sw, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sw * 0.07,
        height: sw * 0.07,
        decoration: const BoxDecoration(
          color: Color(0xFFE7EFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.edit_rounded,
          color: AppColors.primary,
          size: sw * 0.03,
        ),
      ),
    );
  }

  // Reusable Skill Chip Widget
  Widget _buildSkillChip(String skill, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: sw * 0.035,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildPreviousExperienceCard(
    PreviousExperienceEntry entry,
    int index,
    double sw,
    double subHeadingFontSize,
    double bodyFontSize,
    double chipFontSize,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: sw * 0.03),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.dynamicCardBg,
        border: Border.all(color: AppColors.dynamicBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.companyName,
                      style: TextStyle(
                        fontSize: subHeadingFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dynamicText,
                      ),
                    ),
                    SizedBox(height: sw * 0.01),
                    Text(
                      entry.jobTitle,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        color: AppColors.dynamicSubtitle,
                      ),
                    ),
                    SizedBox(height: sw * 0.01),
                    Text(
                      'Experience: ${entry.duration} Years',
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        color: AppColors.dynamicSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.02),
              _buildEditButton(
                sw,
                () =>
                    _showAddEditExperienceDialog(existing: entry, index: index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteExperience(PreviousExperienceEntry entry) async {
    if (entry.id == null || entry.id!.isEmpty || entry.id == 'null') return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Experience'),
        content: const Text('Are you sure you want to delete this experience?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        final int? userId = await _getValidUserId();
        if (userId != null) {
          final res = await ExperienceDeleteApi.deleteExperience(
            name: userId.toString(),
            id: entry.id!,
          );
          if (res['status'] == 'success' || res['error'] == false) {
            if (entry.id == _primaryExperienceId) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('you_have_experience', false);
              await prefs.setBool('user_${userId}_you_have_experience', false);
              await prefs.setString('job_title', '');
              await prefs.setString('company_name', '');
              await prefs.setString('user_${userId}_job_title', '');
              await prefs.setString('user_${userId}_company_name', '');
            }
            _loadQualificationDetails();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    res['message'] ?? 'Failed to delete experience',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error deleting experience: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showAddEditExperienceDialog({
    PreviousExperienceEntry? existing,
    int? index,
  }) {
    final companyController = TextEditingController(
      text: existing?.companyName ?? '',
    );
    final jobTitleController = TextEditingController(
      text: existing?.jobTitle ?? '',
    );
    final durationController = TextEditingController(
      text: existing?.duration ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.dynamicCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing != null
                    ? 'Edit Previous Experience'
                    : 'Add Previous Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dynamicText,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: companyController,
                style: TextStyle(color: AppColors.dynamicText),
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  labelStyle: TextStyle(color: AppColors.dynamicSubtitle),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.dynamicBorder),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: jobTitleController,
                style: TextStyle(color: AppColors.dynamicText),
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  labelStyle: TextStyle(color: AppColors.dynamicSubtitle),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.dynamicBorder),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.dynamicText),
                decoration: InputDecoration(
                  labelText: 'Years of Experience',
                  labelStyle: TextStyle(color: AppColors.dynamicSubtitle),
                  hintText: 'e.g. 2',
                  hintStyle: TextStyle(color: AppColors.dynamicSubtitle),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.dynamicBorder),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (existing != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteExperience(existing);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final comp = companyController.text.trim();
                      final job = jobTitleController.text.trim();
                      final dur = durationController.text.trim();
                      if (comp.isEmpty || job.isEmpty || dur.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      await _savePreviousExperience(
                        id: existing?.id,
                        companyName: comp,
                        jobTitle: job,
                        duration: dur,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePreviousExperience({
    String? id,
    required String companyName,
    required String jobTitle,
    required String duration,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;

      final String? sanitizedId = (id != null && id.isNotEmpty && id != "null")
          ? id
          : null;

      final insertRes = await ExperienceInsertApi.insertExperienceDetails(
        name: userId.toString(),
        age: _userAge.toString(),
        youHaveExperience: '1',
        totYearXperience: duration,
        jobTitle: jobTitle,
        companyName: companyName,
        currentWork: '0',
        id: sanitizedId,
        mid: _memberId,
      );

      if (insertRes['status'] == 'success' ||
          insertRes['status'] == 'updated' ||
          insertRes['status'] == 'added' ||
          insertRes['error'] == false) {
        _loadQualificationDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                insertRes['message'] ?? 'Failed to save experience',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving previous experience: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProjectEntryCard(
    ProjectEntry entry,
    int index,
    double sw,
    double subHeadingFontSize,
    double bodyFontSize,
    double chipFontSize,
  ) {
    List<Widget> detailRows = [];
    if (entry.startDate.isNotEmpty || entry.endDate.isNotEmpty) {
      final formattedStart = entry.startDate.replaceAll('-', '/');
      final formattedEnd = entry.endDate.replaceAll('-', '/');
      detailRows.add(
        _detailRow(
          sw,
          bodyFontSize,
          'Duration',
          [formattedStart, formattedEnd].where((s) => s.isNotEmpty).join('  â€“  '),
        ),
      );
    }
    if (entry.keySkills.isNotEmpty)
      detailRows.add(
        _detailRow(sw, bodyFontSize, 'Key Skills', entry.keySkills),
      );
    if (entry.projectUrl.isNotEmpty)
      detailRows.add(
        _detailRow(sw, bodyFontSize, 'Project URL', entry.projectUrl),
      );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: sw * 0.03),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.dynamicCardBg,
        border: Border.all(color: AppColors.dynamicBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.projectName,
                  style: TextStyle(
                    fontSize: subHeadingFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dynamicText,
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              _buildEditButton(
                sw,
                () => _openAddProject(existing: entry, editIndex: index),
              ),
            ],
          ),
          if (detailRows.isNotEmpty) ...[
            SizedBox(height: sw * 0.02),
            Divider(color: AppColors.dynamicBorder, thickness: 1),
            SizedBox(height: sw * 0.02),
            ...detailRows,
          ],
        ],
      ),
    );
  }

  Widget _buildInternshipEntryCard(
    InternshipEntry entry,
    int index,
    double sw,
    double subHeadingFontSize,
    double bodyFontSize,
    double chipFontSize,
  ) {
    List<Widget> detailRows = [];

    if (entry.startDate.isNotEmpty || entry.endDate.isNotEmpty) {
      final formattedStart = entry.startDate.replaceAll('-', '/');
      final formattedEnd = entry.endDate.replaceAll('-', '/');
      detailRows.add(
        _detailRow(
          sw,
          bodyFontSize,
          'Duration',
          [formattedStart, formattedEnd].where((s) => s.isNotEmpty).join('  â€“  '),
        ),
      );
    }
    if (entry.projectName.isNotEmpty)
      detailRows.add(
        _detailRow(sw, bodyFontSize, 'Project Name', entry.projectName),
      );
    if (entry.description.isNotEmpty)
      detailRows.add(
        _detailRow(sw, bodyFontSize, 'Description', entry.description),
      );
    if (entry.keySkills.isNotEmpty)
      detailRows.add(
        _detailRow(sw, bodyFontSize, 'Key Skills', entry.keySkills),
      );
    if (entry.projectUrl.isNotEmpty)
      detailRows.add(
        _detailRow(sw, bodyFontSize, 'Project URL', entry.projectUrl),
      );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: sw * 0.03),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.dynamicCardBg,
        border: Border.all(color: AppColors.dynamicBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.companyName,
                  style: TextStyle(
                    fontSize: subHeadingFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dynamicText,
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              _buildEditButton(
                sw,
                () => _openAddInternship(existing: entry, editIndex: index),
              ),
            ],
          ),
          if (detailRows.isNotEmpty) ...[
            SizedBox(height: sw * 0.02),
            Divider(color: AppColors.dynamicBorder, thickness: 1),
            SizedBox(height: sw * 0.02),
            ...detailRows,
          ],
        ],
      ),
    );
  }
}


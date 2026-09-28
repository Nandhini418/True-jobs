import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/jobs_api_service.dart';
import 'package:truejobs/services/delete_job_api_service.dart';
import 'models.dart';
import 'jobs_dashboard_empty_screen.dart';
import 'create_job_screen.dart';
import 'jobs_overview_screen.dart';
import 'job_details_screen.dart';
import '../candidate_sections/candidates_screen.dart';
import '../interview_sections/interviews_screen.dart';
import 'settings_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import '../drawer_sections/company_profile_screen.dart';
import 'package:truejobs/services/api/recruiter_dropdown_cache.dart';

class DashboardHolder extends StatefulWidget {
  const DashboardHolder({super.key});

  @override
  State<DashboardHolder> createState() => _DashboardHolderState();
}

class _DashboardHolderState extends State<DashboardHolder> {
  int _currentIndex = 0; // 0: Jobs, 1: Candidate, 2: Interviews, 3: Settings

  // Jobs state management
  List<JobModel> _jobs = [];
  JobModel? _selectedJob;
  String _jobsSubState = 'loading'; // 'loading', 'empty', 'list', 'create', 'edit', 'details'
  bool _isCompanyProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    RecruiterDropdownCache.preloadDropdowns();
  }

  Future<void> _loadJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userIdInt = prefs.getInt('user_id');
    final String? userId = userIdInt?.toString();
    final String token = prefs.getString('token') ?? '';

    if (userId != null && userId.isNotEmpty) {
      final apiJobsData = await JobsApiService.fetchJobs(userId);
      if (apiJobsData != null && apiJobsData.isNotEmpty) {
        _jobs = apiJobsData.map((j) => JobModel.fromApiJson(j)).toList();
      } else if (apiJobsData != null && apiJobsData.isEmpty) {
        _jobs = [];
      } else {
        // Fallback to local storage if API fails
        final String? jobsJson = prefs.getString('saved_jobs_$userId');
        if (jobsJson != null && jobsJson.isNotEmpty) {
          try {
            final List<dynamic> decodedList = json.decode(jobsJson);
            _jobs = decodedList.map((j) => JobModel.fromJson(j)).toList();
          } catch (e) {
            debugPrint('Error loading jobs locally: $e');
          }
        }
      }
    }
    
    await _checkCompanyProfileComplete(userId, token);

    setState(() {
      _jobsSubState = _jobs.isEmpty ? 'empty' : 'list';
    });
  }

  Future<void> _checkCompanyProfileComplete(String? userId, String token) async {
    if (userId == null || userId.isEmpty) return;
    
    final response = await BasicDetailApiService.fetchBasicDetails(userId: userId, token: token);
    bool isComplete = false;
    
    if (response != null && response['status'] == 'success') {
      final data = response['data'];
      if (data != null) {
        final requiredFieldsMap = {
          'company_name': data['company_name'] ?? data['company'],
          'pincode': data['pincode'] ?? data['pin_code'],
          'address': data['address'] ?? data['company_address'],
          'industry_type': data['industry_type'] ?? data['industry'],
          'about_company': data['about_company'],
          'company_size': data['company_size']?.toString(),
          'founded_year': data['founded_year']?.toString(),
          'company_logo': data['company_logo']
        };
        
        isComplete = true;
        List<String> missingFields = [];
        requiredFieldsMap.forEach((key, value) {
          final str = value?.toString().trim().toLowerCase() ?? '';
          if (str.isEmpty || str == 'null') {
            isComplete = false;
            missingFields.add(key);
          }
        });

        if (!isComplete && mounted) {
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _isCompanyProfileComplete = isComplete;
      });
    }
  }

  Future<void> _saveJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userIdInt = prefs.getInt('user_id');
    final String? userId = userIdInt?.toString();
    if (userId != null) {
      final String encodedList = json.encode(_jobs.map((j) => j.toJson()).toList());
      await prefs.setString('saved_jobs_$userId', encodedList);
    }
  }

  // Candidates state management
  final List<CandidateModel> _candidates = List.from(mockCandidatesList);

  void _onCandidateStatusChanged(CandidateModel candidate, String newStatus) {
    setState(() {
      final idx = _candidates.indexWhere((c) => c.name == candidate.name);
      if (idx != -1) {
        _candidates[idx] = CandidateModel(
          name: candidate.name,
          role: candidate.role,
          experience: candidate.experience,
          phone: candidate.phone,
          location: candidate.location,
          status: newStatus,
          appliedDate: candidate.appliedDate,
          expectedSalary: candidate.expectedSalary,
          education: candidate.education,
          languages: candidate.languages,
          skills: candidate.skills,
          matchScore: candidate.matchScore,
        );
      }
    });
  }

  Widget _buildJobsTabContent() {
    switch (_jobsSubState) {
      case 'loading':
        return const Center(child: CircularProgressIndicator());
      case 'empty':
        return JobsDashboardEmptyScreen(
          isCompanyProfileComplete: _isCompanyProfileComplete,
          onCompleteProfilePressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompanyProfileScreen()),
            );
            if (result == true) {
              setState(() {
                _jobsSubState = 'loading';
              });
              await _loadJobs();
            }
          },
          onCreateJobPressed: () {
            setState(() {
              _selectedJob = null;
              _jobsSubState = 'create';
            });
          },
        );
      case 'create':
        return CreateJobScreen(
          jobToEdit: null,
          onBack: () {
            setState(() {
              _jobsSubState = _jobs.isEmpty ? 'empty' : 'list';
            });
          },
          onPublish: (newJob) {
            setState(() {
              _jobs.add(newJob);
              _jobsSubState = 'list';
            });
            _saveJobs();
          },
        );
      case 'edit':
        return CreateJobScreen(
          jobToEdit: _selectedJob,
          onBack: () {
            setState(() {
              _jobsSubState = 'list';
            });
          },
          onPublish: (updatedJob) {
            setState(() {
              final index = _jobs.indexWhere((j) => j.id == updatedJob.id);
              if (index != -1) {
                _jobs[index] = updatedJob;
              }
              _jobsSubState = 'list';
            });
            _saveJobs();
          },
        );
      case 'details':
        if (_selectedJob == null) {
          return const Center(child: Text('No job selected'));
        }
        // Grab updated job state from the list in case it changed
        final job = _jobs.firstWhere((j) => j.id == _selectedJob!.id, orElse: () => _selectedJob!);
        return JobDetailsScreen(
          job: job,
          candidates: _candidates,
          onCandidateStatusChanged: _onCandidateStatusChanged,
          onBack: () {
            setState(() {
              _jobsSubState = 'list';
            });
          },
        );
      case 'list':
      default:
        if (_jobs.isEmpty) {
          // Fallback check
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _jobsSubState = 'empty';
            });
          });
          return const Center(child: CircularProgressIndicator());
        }
        return JobsOverviewScreen(
          jobs: _jobs,
          onJobSelected: (job) {
            setState(() {
              _selectedJob = job;
              _jobsSubState = 'details';
            });
          },
          onEditJob: (job) {
            setState(() {
              _selectedJob = job;
              _jobsSubState = 'edit';
            });
          },
          onDuplicateJob: (job) {
            setState(() {
              final duplicate = job.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: '${job.title} (Duplicate)',
              );
              _jobs.add(duplicate);
            });
            _saveJobs();
          },
          onDeleteJob: (job) async {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
            
            final result = await DeleteJobApiService.deleteJob(job.id);
            
            if (mounted) Navigator.pop(context);
            
            if (result != null && result['error'] == false) {
              setState(() {
                _jobs.removeWhere((j) => j.id == job.id);
                if (_jobs.isEmpty) {
                  _jobsSubState = 'empty';
                }
              });
              _saveJobs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job deleted successfully!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete job')),
              );
            }
          },
          onCreateJobPressed: () {
            setState(() {
              _selectedJob = null;
              _jobsSubState = 'create';
            });
          },
        );
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildJobsTabContent();
      case 1:
        return const CandidatesScreen();
      case 2:
        return const InterviewsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showBottomNav = !(_currentIndex == 0 &&
        (_jobsSubState == 'empty' ||
            _jobsSubState == 'loading' ||
            _jobsSubState == 'create' ||
            _jobsSubState == 'edit' ||
            _jobsSubState == 'details'));

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        if (_jobsSubState == 'details' || _jobsSubState == 'create' || _jobsSubState == 'edit') {
          setState(() {
            _jobsSubState = _jobs.isEmpty ? 'empty' : 'list';
          });
          return false;
        }
        return true; // Let the app close
      },
      child: Scaffold(
        backgroundColor: AppColors.dynamicBg,
        body: _buildBody(),
        bottomNavigationBar: showBottomNav
            ? CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              )
            : null,
      ),
    );
  }
}

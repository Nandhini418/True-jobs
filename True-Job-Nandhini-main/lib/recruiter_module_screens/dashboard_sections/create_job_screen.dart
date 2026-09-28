import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/create_job_api_service.dart';
import 'package:truejobs/services/api/recruiter_dropdown_cache.dart';
import 'package:truejobs/services/dropdown_apis/perks_api_service.dart';
import 'package:truejobs/services/dropdown_apis/skills_api_service.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';

import 'models.dart';
import 'job_create/step1_job_details.dart';
import 'job_create/step2_candidate_reqs.dart';
import 'job_create/step3_job_application.dart';
import 'job_create/step4_recruiter_details.dart';
import 'job_create/step5_review_job.dart';

class CreateJobScreen extends StatefulWidget {
  final JobModel? jobToEdit;
  final Function(JobModel) onPublish;
  final VoidCallback onBack;

  const CreateJobScreen({
    super.key,
    this.jobToEdit,
    required this.onPublish,
    required this.onBack,
  });

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;

  // Controllers
  late TextEditingController _titleController;
  final TextEditingController _locationController = TextEditingController();
  late TextEditingController _openingsController;
  late TextEditingController _salaryRangeController;
  late TextEditingController _experienceController;
  late TextEditingController _qualificationController;
  late TextEditingController _descriptionController;
  late TextEditingController _responsibilitiesController;
  late TextEditingController _recruiterNameController;
  late TextEditingController _recruiterTitleController;
  late TextEditingController _recruiterEmailController;
  late TextEditingController _recruiterPhoneController;
  late TextEditingController _deadlineController;
  late TextEditingController _skillInputController;

  // Walk-in controllers
  late TextEditingController _walkInStartDateController;
  late TextEditingController _walkInEndDateController;
  late TextEditingController _walkInStartTimeController;
  late TextEditingController _walkInEndTimeController;
  late TextEditingController _walkInAddressController;
  late TextEditingController _walkInInstructionsController;

  // Dropdown / Selection Values (nullable so nothing is pre-selected)
  String? _employmentType;
  String? _experienceLevel;
  String? _locationType;
  String? _salaryType;
  String? _minEducation;
  String? _englishLevel;
  String? _departmentType;

  // Lists and Radios
  List<String> _selectedPerks = [];
  List<String> _selectedSkills = [];

  String? _walkIn;
  String? _portfolio;
  String? _resume;

  List<String> _skillOptions = [];
  List<dynamic> _rawSkills = [];
  bool _isLoadingSkills = false;

  List<dynamic> _locationTypeOptions = [];
  bool _isLoadingLocationTypes = false;

  List<dynamic> _departmentOptions = [];
  bool _isLoadingDepartments = false;

  List<dynamic> _salaryTypeOptions = [];
  bool _isLoadingSalaryTypes = false;

  List<dynamic> _employmentTypeOptions = [];
  bool _isLoadingEmploymentTypes = false;

  List<String> _perkOptions = [];
  List<dynamic> _rawPerks = [];
  bool _isLoadingPerks = false;

  final List<String> _educationOptions = [
    'Education Not Required',
    'High School (10th Pass)',
    'Higher Secondary (12th Pass)',
    'Diploma',
    "Bachelor's Degree",
    "Master's Degree",
    'PhD',
  ];

  final List<String> _englishLevelOptions = [
    'No English Required',
    'Basic',
    'Intermediate',
    'Fluent',
  ];

  static const String _fontFamily = 'Poppins';

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions();
    final job = widget.jobToEdit;

    _titleController = TextEditingController(text: job?.title ?? '');
    _locationController.text = job?.location ?? '';
    _openingsController = TextEditingController(
      text: job != null ? job.openings.toString() : '',
    );
    _salaryRangeController = TextEditingController(
      text: job?.salaryRange ?? '',
    );
    _experienceController = TextEditingController(text: job?.experience ?? '');
    _qualificationController = TextEditingController(
      text: job?.qualification ?? '',
    );
    _descriptionController = TextEditingController(
      text: job?.description ?? '',
    );
    _responsibilitiesController = TextEditingController(
      text: job?.responsibilities ?? '',
    );
    _recruiterNameController = TextEditingController(
      text: job?.recruiterName ?? '',
    );
    _recruiterTitleController = TextEditingController(
      text: job?.recruiterTitle ?? '',
    );
    _recruiterEmailController = TextEditingController(
      text: job?.recruiterEmail ?? '',
    );
    _recruiterPhoneController = TextEditingController(
      text: job?.recruiterPhone ?? '',
    );
    _deadlineController = TextEditingController(text: job?.deadline ?? '');
    _skillInputController = TextEditingController();

    _walkInStartDateController = TextEditingController(
      text: job?.walkInStartDate ?? '',
    );
    _walkInEndDateController = TextEditingController(
      text: job?.walkInEndDate ?? '',
    );
    _walkInStartTimeController = TextEditingController(
      text: job?.walkInStartTime ?? '',
    );
    _walkInEndTimeController = TextEditingController(
      text: job?.walkInEndTime ?? '',
    );
    _walkInAddressController = TextEditingController(
      text: job?.walkInAddress ?? '',
    );
    _walkInInstructionsController = TextEditingController(
      text: job?.walkInInstructions ?? '',
    );

    if (job != null) {
      _employmentType = job.employmentType;
      _experienceLevel = job.experienceLevel;
      _locationType = job.locationType;
      _salaryType = job.salaryType;
      _minEducation = job.education;
      _englishLevel = job.englishLevel;
      _departmentType = job.department;
      _selectedPerks = List.from(job.perks);
      _selectedSkills = List.from(job.skills);
      _walkIn = job.walkIn;
      _portfolio = job.portfolio;
      _resume = job.resume;
    }
  }

  Future<void> _fetchDropdownOptions() async {
    setState(() {
      _isLoadingLocationTypes = true;
      _isLoadingSalaryTypes = true;
      _isLoadingPerks = true;
      _isLoadingEmploymentTypes = true;
      _isLoadingDepartments = true;
      _isLoadingSkills = true;
    });

    if (!RecruiterDropdownCache.isLoaded) {
      await RecruiterDropdownCache.preloadDropdowns();
    }

    final locTypes = RecruiterDropdownCache.locationTypes;
    final salTypes = RecruiterDropdownCache.salaryTypes;
    final perks = RecruiterDropdownCache.rawPerks;
    final empTypes = RecruiterDropdownCache.employmentTypes;
    final deptTypes = RecruiterDropdownCache.departments;
    final skills = RecruiterDropdownCache.rawSkills;

    if (mounted) {
      setState(() {
        _locationTypeOptions = locTypes;
        _isLoadingLocationTypes = false;
        _salaryTypeOptions = salTypes;
        _isLoadingSalaryTypes = false;
        _employmentTypeOptions = empTypes;
        _isLoadingEmploymentTypes = false;
        _rawPerks = perks;
        _perkOptions = perks.map((e) => e['name'].toString()).toSet().toList();
        _isLoadingPerks = false;
        _rawSkills = skills;
        _skillOptions = skills
            .map((e) => e['name'].toString())
            .toSet()
            .toList();
        _isLoadingSkills = false;
        _departmentOptions = deptTypes;
        _isLoadingDepartments = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _openingsController.dispose();
    _salaryRangeController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _recruiterNameController.dispose();
    _recruiterTitleController.dispose();
    _recruiterEmailController.dispose();
    _recruiterPhoneController.dispose();
    _deadlineController.dispose();
    _skillInputController.dispose();

    _walkInStartDateController.dispose();
    _walkInEndDateController.dispose();
    _walkInStartTimeController.dispose();
    _walkInEndTimeController.dispose();
    _walkInAddressController.dispose();
    _walkInInstructionsController.dispose();
    super.dispose();
  }

  String _mapPerksToIds(List<String> selected) {
    if (selected.isEmpty) return '';
    List<String> ids = [];
    for (String perk in selected) {
      try {
        final item = _rawPerks.firstWhere((element) => element['name'] == perk);
        ids.add(item['id'].toString());
      } catch (e) {}
    }
    return ids.join(',');
  }

  String _mapSkillsToIds(List<String> selected) {
    if (selected.isEmpty) return '';
    List<String> ids = [];
    for (String skill in selected) {
      try {
        final item = _rawSkills.firstWhere(
          (element) => element['name'] == skill,
        );
        ids.add(item['id'].toString());
      } catch (e) {}
    }
    return ids.join(',');
  }

  void _onPublishPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id')?.toString() ?? '';

      final result = await CreateJobApiService.createJob(
        jobId: widget.jobToEdit?.id,
        userId: userId,
        jobTitle: _titleController.text.trim(),
        department: _departmentType ?? '3',
        jobType: _employmentType ?? '',
        workLocType: _locationType ?? '',
        location: _locationController.text.trim(),
        salaryType: _salaryType ?? '',
        salaryRange: _salaryRangeController.text.trim(),
        perksBenefits: _mapPerksToIds(_selectedPerks),
        experience: _experienceController.text.trim(),
        skills: _mapSkillsToIds(_selectedSkills),
        qualification: _minEducation ?? '',
        interviewMethod: _walkIn == 'Yes' ? '1' : '2',
        walkStart: _walkIn == 'Yes'
            ? _walkInStartDateController.text.trim()
            : null,
        walkEnd: _walkIn == 'Yes' ? _walkInEndDateController.text.trim() : null,
        walkTiming: _walkIn == 'Yes'
            ? _walkInStartTimeController.text.trim()
            : null,
        otherInstruct: _walkIn == 'Yes'
            ? _walkInInstructionsController.text.trim()
            : null,
        walkTimeEnd: _walkIn == 'Yes'
            ? _walkInEndTimeController.text.trim()
            : null,
        interviewDate: _walkIn == 'Yes'
            ? _deadlineController.text.trim()
            : null,
        walkAddress: _walkIn == 'Yes'
            ? _walkInAddressController.text.trim()
            : null,
        jobDescription: _descriptionController.text.trim(),
        responsibilities: _responsibilitiesController.text.trim(),
        hrName: _recruiterNameController.text.trim(),
        recruiterName: userId,
        vacancy: _openingsController.text.trim(),
        recruiterEmail: _recruiterEmailController.text.trim(),
        recruiterMobile: _recruiterPhoneController.text.trim(),
        recruiterJob: _recruiterTitleController.text.trim(),
      );

      if (mounted) Navigator.pop(context);

      if (result != null && result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job created successfully!')),
        );
      } else {
        final errorDetails = result != null
            ? (result['message'] ?? result.toString())
            : 'Failed to create job';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorDetails'),
            duration: const Duration(seconds: 8),
          ),
        );
        return; // Prevent saving the job locally if creation fails
      }

      final job = JobModel(
        id:
            widget.jobToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        employmentType: _employmentType ?? '',
        experienceLevel: _experienceController.text.trim(),
        locationType: _locationType ?? '',
        location: _locationController.text.trim(),
        openings: int.tryParse(_openingsController.text) ?? 1,
        deadline: _deadlineController.text.trim(),
        salaryType: _salaryType ?? '',
        salaryRange: _salaryRangeController.text.trim(),
        perks: _selectedPerks,
        education: _minEducation ?? '',
        experience: _experienceController.text.trim(),
        englishLevel: _englishLevel ?? '',
        skills: _selectedSkills,
        qualification: _minEducation ?? '',
        description: _descriptionController.text.trim(),
        department: _departmentType,
        responsibilities: _responsibilitiesController.text.trim(),
        walkIn: _walkIn ?? '',
        walkInStartDate: _walkIn == 'Yes'
            ? _walkInStartDateController.text.trim()
            : null,
        walkInEndDate: _walkIn == 'Yes'
            ? _walkInEndDateController.text.trim()
            : null,
        walkInStartTime: _walkIn == 'Yes'
            ? _walkInStartTimeController.text.trim()
            : null,
        walkInEndTime: _walkIn == 'Yes'
            ? _walkInEndTimeController.text.trim()
            : null,
        walkInAddress: _walkIn == 'Yes'
            ? _walkInAddressController.text.trim()
            : null,
        walkInInstructions: _walkIn == 'Yes'
            ? _walkInInstructionsController.text.trim()
            : null,
        portfolio: _portfolio ?? '',
        resume: _resume ?? '',
        recruiterName: _recruiterNameController.text.trim(),
        recruiterTitle: _recruiterTitleController.text.trim(),
        recruiterEmail: _recruiterEmailController.text.trim(),
        recruiterPhone: _recruiterPhoneController.text.trim(),
        status: widget.jobToEdit?.status ?? 'Active',
        datePosted: widget.jobToEdit?.datePosted ?? DateTime.now().toString(),
      );
      widget.onPublish(job);
    }
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep < 5) {
        setState(() => _currentStep++);
      } else {
        _onPublishPressed();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      widget.onBack();
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          Row(
            children: [
              GestureDetector(
                onTap: _prevStep,
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.dynamicText,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Steps $_currentStep of 5',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    color: AppColors.dynamicSubtitle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(5, (index) {
              final isActive = index < _currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 4.w),
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : const Color(0xFFD7D7D7),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return Step1JobDetails(
          titleController: _titleController,
          departmentType: _departmentType,
          onDepartmentChanged: (v) => setState(() => _departmentType = v),
          departmentOptions: _departmentOptions,
          isLoadingDepartments: _isLoadingDepartments,
          employmentType: _employmentType,
          onEmploymentTypeChanged: (v) => setState(() => _employmentType = v),
          employmentTypeOptions: _employmentTypeOptions,
          isLoadingEmploymentTypes: _isLoadingEmploymentTypes,
          workLocType: _locationType,
          onWorkLocTypeChanged: (v) => setState(() => _locationType = v),
          locationTypeOptions: _locationTypeOptions,
          isLoadingLocationTypes: _isLoadingLocationTypes,
          locationController: _locationController,
          openingsController: _openingsController,
          salaryType: _salaryType,
          onSalaryTypeChanged: (v) => setState(() => _salaryType = v),
          salaryTypeOptions: _salaryTypeOptions,
          isLoadingSalaryTypes: _isLoadingSalaryTypes,
          salaryRangeController: _salaryRangeController,
          selectedPerks: _selectedPerks,
          perkOptions: _perkOptions,
          isLoadingPerks: _isLoadingPerks,
          onAddPerk: (p) {
            if (!_selectedPerks.contains(p))
              setState(() => _selectedPerks.add(p));
          },
          onRemovePerk: (p) => setState(() => _selectedPerks.remove(p)),
          onAddNewPerkToDB: (p, ctrl) async {
            final perk = p.trim();
            if (perk.isEmpty || _selectedPerks.contains(perk)) return;
            setState(() => _selectedPerks.add(perk));
            ctrl.clear();
            if (!_perkOptions.contains(perk)) {
              await PerksApiService.insertPerk(perk);
            }
          },
        );
      case 2:
        return Step2CandidateReqs(
          minEducation: _minEducation,
          onMinEducationChanged: (v) => setState(() => _minEducation = v),
          educationOptions: _educationOptions,
          experienceController: _experienceController,
          englishLevel: _englishLevel,
          onEnglishLevelChanged: (v) => setState(() => _englishLevel = v),
          englishLevelOptions: _englishLevelOptions,
          selectedSkills: _selectedSkills,
          skillOptions: _skillOptions,
          isLoadingSkills: _isLoadingSkills,
          onAddSkill: (s) {
            if (!_selectedSkills.contains(s))
              setState(() => _selectedSkills.add(s));
          },
          onRemoveSkill: (s) => setState(() => _selectedSkills.remove(s)),
          onAddNewSkillToDB: (s, ctrl) async {
            final skill = s.trim();
            if (skill.isEmpty || _selectedSkills.contains(skill)) return;
            setState(() => _selectedSkills.add(skill));
            ctrl.clear();
            if (!_skillOptions.contains(skill)) {
              await SkillsApiService.insertSkill(skill);
            }
          },
        );
      case 3:
        return Step3JobApplication(
          descriptionController: _descriptionController,
          responsibilitiesController: _responsibilitiesController,
          deadlineController: _deadlineController,
          walkIn: _walkIn,
          onWalkInChanged: (v) => setState(() => _walkIn = v),
          portfolio: _portfolio,
          onPortfolioChanged: (v) => setState(() => _portfolio = v),
          resume: _resume,
          onResumeChanged: (v) => setState(() => _resume = v),
          walkInStartDateController: _walkInStartDateController,
          walkInEndDateController: _walkInEndDateController,
          walkInStartTimeController: _walkInStartTimeController,
          walkInEndTimeController: _walkInEndTimeController,
          walkInAddressController: _walkInAddressController,
          walkInInstructionsController: _walkInInstructionsController,
        );
      case 4:
        return Step4RecruiterDetails(
          nameController: _recruiterNameController,
          designationController: _recruiterTitleController,
          emailController: _recruiterEmailController,
          phoneController: _recruiterPhoneController,
        );
      case 5:
        return Step5ReviewJob(
          title: _titleController.text,
          location: _locationController.text,
          employmentType: _employmentTypeOptions
              .firstWhere(
                (e) => e['value'].toString() == _employmentType,
                orElse: () => {'label': ''},
              )['label']
              .toString(),
          experience: _experienceController.text,
          salaryRange: _salaryRangeController.text,
          openings: _openingsController.text,
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const CustomAppBar(backgroundColor: Colors.white),
            _buildStepIndicator(),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  //physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    children: [
                      _getCurrentStepWidget(),
                      SizedBox(height: 20.h),
                      // Bottom Action Bar now inside the scroll view
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // boxShadow removed since it's now part of the scrolling content
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _prevStep,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                child: Text(
                                  _currentStep == 1 ? 'Cancel' : 'Back',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 15.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                child: Text(
                                  _currentStep == 5 ? 'Publish Job' : 'Save',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 15.sp,
                                    color: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }
}

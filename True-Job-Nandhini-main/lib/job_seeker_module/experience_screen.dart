import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_next_button.dart';
import 'package:truejobs/job_seeker_module/resume_screen.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/smooth_page_route.dart';
import 'package:flutter/services.dart';
import 'package:truejobs/services/api/profile_select_api.dart';
import 'package:truejobs/services/api/experience_insert_api.dart';
import 'package:truejobs/services/api/experience_select_api.dart';

class ExperienceScreen extends StatefulWidget {
  final bool isEditing;
  const ExperienceScreen({super.key, this.isEditing = false});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  String? _experienceId;
  bool _hasExperience = true;
  bool _currentlyWorking = false;
  bool _isLoading = false;
  int _userAge = 23;

  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExperienceDetails();
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

  Future<void> _loadExperienceDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();

      // 1. Fetch profile to calculate age
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

      // 2. Load monthly salary and experience ID from local SharedPreferences
      final String cachedSalary = prefs.getString('user_${userId}_experience_salary') ?? prefs.getString('experience_salary') ?? '';
      final String cachedExpId = prefs.getString('user_${userId}_experience_id') ?? prefs.getString('experience_id') ?? '';
      if (cachedExpId.isNotEmpty) {
        setState(() {
          _experienceId = cachedExpId;
        });
      }

      // 3. Fetch experience details (type 1120)
      final res = await ExperienceSelectApi.fetchExperienceDetails(
        name: userId.toString(),
      );

      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          final List<dynamic> expList = data['experiences'] ?? [];
          Map<String, dynamic>? primaryExp;
          if (expList.isNotEmpty) {
            primaryExp = expList.first as Map<String, dynamic>?;
          }

          final bool hasExp = primaryExp != null && (primaryExp['you_have_experience']?.toString() == '1');
          final String expId = primaryExp?['id']?.toString() ?? '';
          final String totYearStr = primaryExp?['tot_year_xperience']?.toString() ?? '';
          final String jobTitleStr = primaryExp?['job_title']?.toString() ?? '';
          final String companyNameStr = primaryExp?['company_name']?.toString() ?? '';
          final String currentWorkStr = primaryExp?['current_work']?.toString() ?? '';
          final String currentSalaryStr = primaryExp?['current_salary']?.toString() ?? '';

          setState(() {
            _experienceId = expId.isNotEmpty ? expId : null;
            _hasExperience = hasExp;
            if (hasExp) {
              _experienceController.text = totYearStr.split(' / ').first.trim();
              _jobTitleController.text = jobTitleStr.split(' / ').first.trim();
              _companyController.text = companyNameStr.split(' / ').first.trim();
              final String cwFirst = currentWorkStr.split(' / ').first.trim();
              _currentlyWorking = cwFirst == '1' || cwFirst == 'true';

              final String apiSalary = currentSalaryStr.split(' / ').first.trim();
              if (apiSalary.isNotEmpty) {
                _salaryController.text = apiSalary;
              } else {
                _salaryController.text = cachedSalary.split(' / ').first.trim();
              }
            } else {
              _experienceController.clear();
              _jobTitleController.clear();
              _companyController.clear();
              _currentlyWorking = false;
              _salaryController.clear();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading experience details: $e');
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

  Future<void> _goToNextScreen() async {
    if (_hasExperience) {
      if (_experienceController.text.trim().isEmpty ||
          _jobTitleController.text.trim().isEmpty ||
          _companyController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all experience details')),
        );
        return;
      }
      if (_currentlyWorking && _salaryController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter current monthly salary')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();

      final String youHaveExperience = _hasExperience ? '1' : '2';
      final String totYearXperience = _hasExperience ? _experienceController.text.trim() : '0';
      final String jobTitle = _hasExperience ? _jobTitleController.text.trim() : '';
      final String companyName = _hasExperience ? _companyController.text.trim() : '';
      final String currentWork = _hasExperience ? (_currentlyWorking ? '1' : '0') : '0';
      final String salaryStr = _hasExperience ? (_currentlyWorking ? _salaryController.text.trim() : '') : '';

      final res = await ExperienceInsertApi.insertExperienceDetails(
        name: userId.toString(),
        age: _userAge.toString(),
        youHaveExperience: youHaveExperience,
        totYearXperience: totYearXperience,
        jobTitle: jobTitle,
        companyName: companyName,
        currentWork: currentWork,
        currentSalary: salaryStr,
        id: _experienceId,
      );

      if (res['status'] == 'success' ||
          res['status'] == 'updated' ||
          res['status'] == 'added' ||
          res['error'] == false) {
        await prefs.setBool('you_have_experience', _hasExperience);
        await prefs.setBool('user_${userId}_you_have_experience', _hasExperience);
        String savedId = _experienceId ?? '';
        if (res['id'] != null) {
          savedId = res['id'].toString();
        } else if (res['data'] != null) {
          if (res['data'] is List && (res['data'] as List).isNotEmpty) {
            savedId = res['data'][0]['id']?.toString() ?? savedId;
          } else if (res['data'] is Map) {
            savedId = res['data']['id']?.toString() ?? savedId;
          }
        }
        if (savedId.isNotEmpty) {
          await prefs.setString('user_${userId}_experience_id', savedId);
          await prefs.setString('experience_id', savedId);
        }
        if (_hasExperience) {
          await prefs.setString('job_title', jobTitle);
          await prefs.setString('company_name', companyName);
          await prefs.setString('user_${userId}_job_title', jobTitle);
          await prefs.setString('user_${userId}_company_name', companyName);
          if (salaryStr.isNotEmpty) {
            await prefs.setString('user_${userId}_experience_salary', salaryStr);
            await prefs.setString('experience_salary', salaryStr);
          } else {
            await prefs.remove('user_${userId}_experience_salary');
            await prefs.remove('experience_salary');
          }
        } else {
          await prefs.setString('job_title', '');
          await prefs.setString('company_name', '');
          await prefs.setString('user_${userId}_job_title', '');
          await prefs.setString('user_${userId}_company_name', '');
          await prefs.remove('user_${userId}_experience_salary');
          await prefs.remove('experience_salary');
        }

        await prefs.setInt('profile_creation_step', 4);

        if (mounted) {
          if (widget.isEditing) {
            Navigator.pop(context);
          } else {
            Navigator.push(
              context,
              SmoothPageRoute(child: const ResumeScreen()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res['message'] ?? 'Failed to save experience details',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving experience details: $e');
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

  Widget _buildRadioButton(
      String label,
      bool isSelected,
      VoidCallback onTap,
      double screenWidth,
      Color textColor,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 0.05.sw,
            height: 0.05.sw,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: 0.03.sw,
                height: 0.03.sw,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
                : null,
          ),
          SizedBox(width: 0.02.sw),
          Text(
            label,
            style: TextStyle(
              fontSize: 0.035.sw,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller,
      double screenWidth,
      Color textColor,
      Color subtitleColor,
      Color borderColor, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.04.sw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 0.035.sw,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          SizedBox(height: 0.02.sw),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontSize: 0.038.sw,
              color: textColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 0.04.sw,
                vertical: 0.035.sw,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.02.sw),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.02.sw),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.02.sw),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: subtitleColor,
                fontSize: 0.035.sw,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top App Bar
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 0.02.sw,
                      top: 0.02.sw,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textColor,
                        size: 0.06.sw,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.05.sw,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Bar Section
                        Container(
                          height: 0.01.sh,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(
                              0.01.sw,
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  0.01.sw,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 0.008.sh),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Creation',
                              style: TextStyle(
                                fontSize: 0.03.sw,
                                color: subtitleColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '40%',
                              style: TextStyle(
                                fontSize: 0.03.sw,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 0.035.sh),

                        // Title
                        Text(
                          'Do you have any work experience',
                          style: TextStyle(
                            fontSize: 0.048.sw,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 0.005.sh),
                        Text(
                          'get personalized job recommendations based on your\nexperience',
                          style: TextStyle(
                            fontSize: 0.032.sw,
                            color: subtitleColor,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: 0.025.sh),

                        // Radio Buttons
                        Row(
                          children: [
                            _buildRadioButton('Yes', _hasExperience, () {
                              setState(() => _hasExperience = true);
                            }, screenWidth, textColor),
                            SizedBox(width: 0.08.sw),
                            _buildRadioButton('No', !_hasExperience, () {
                              setState(() => _hasExperience = false);
                            }, screenWidth, textColor),
                          ],
                        ),

                        SizedBox(height: 0.035.sh),

                        // Experience Form
                        if (_hasExperience) ...[
                          _buildTextField(
                            'Total years of experience ?',
                            'Eg : 2',
                            _experienceController,
                            screenWidth,
                            textColor,
                            subtitleColor,
                            borderColor,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: 0.01.sh),
                          Text(
                            'Latest job Details',
                            style: TextStyle(
                              fontSize: 0.04.sw,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 0.015.sh),
                          _buildTextField(
                            'Job title',
                            'Eg : Accountant',
                            _jobTitleController,
                            screenWidth,
                            textColor,
                            subtitleColor,
                            borderColor,
                          ),
                          _buildTextField(
                            'Company name',
                            'Eg : Work india',
                            _companyController,
                            screenWidth,
                            textColor,
                            subtitleColor,
                            borderColor,
                          ),
                          SizedBox(height: 0.01.sh),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentlyWorking = !_currentlyWorking;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 0.045.sw,
                                      height: 0.045.sw,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _currentlyWorking
                                          ? Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 0.035.sw,
                                          color: AppColors.primary,
                                        ),
                                      )
                                          : null,
                                    ),
                                    SizedBox(width: 0.03.sw),
                                    Text(
                                      'Currently working here',
                                      style: TextStyle(
                                        fontSize: 0.035.sw,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (_currentlyWorking) ...[
                                SizedBox(height: 0.03.sh),

                                _buildTextField(
                                  'Current monthly salary',
                                  'Enter salary eg: 12000',
                                  _salaryController,
                                  screenWidth,
                                  textColor,
                                  subtitleColor,
                                  borderColor,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(0.05.sw),
          child: CustomNextButton(onPressed: _goToNextScreen),
        ),
      ),
    );
  }
}

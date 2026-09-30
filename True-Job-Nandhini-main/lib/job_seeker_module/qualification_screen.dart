import 'package:flutter/material.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_next_button.dart';
import 'package:truejobs/widgets/qualification_sheets.dart';
import 'package:truejobs/job_seeker_module/experience_screen.dart';
import 'package:truejobs/services/api/qualification_cat_api.dart';
import 'package:truejobs/services/api/educational_insert_api.dart';
import 'package:truejobs/services/api/educational_select_api.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/smooth_page_route.dart';

class QualificationScreen extends StatefulWidget {
  final bool isEditing;
  const QualificationScreen({super.key, this.isEditing = false});

  @override
  State<QualificationScreen> createState() => _QualificationScreenState();
}

class _QualificationScreenState extends State<QualificationScreen> {
  Map<String, dynamic>? _selectedOption;
  final Map<String, Map<String, String>> _savedDetails = {};
  List<Map<String, dynamic>> _qualifications = [
    {'value': '1', 'name': '10th'},
    {'value': '2', 'name': '12th'},
    {'value': '3', 'name': 'UG'},
    {'value': '4', 'name': 'PG'},
    {'value': '5', 'name': 'Diploma'},
    {'value': '6', 'name': 'ITI'},
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQualifications();
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

  Future<void> _loadSavedDetails() async {
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final res = await EducationalSelectApi.fetchEducationalDetails(
        name: userId.toString(),
      );
      if (res['error'] == false || res['status'] == 'success') {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          final String highQualify = data['high_qualify']?.toString() ?? '';
          if (highQualify.isNotEmpty) {
            setState(() {
              _selectedOption = _qualifications.firstWhere(
                    (opt) => opt['value']?.toString() == highQualify,
                orElse: () => <String, dynamic>{},
              );
              if (_selectedOption?.isEmpty ?? true) {
                _selectedOption = null;
              }

              if (highQualify == '1') {
                _savedDetails['1'] = {
                  'board': data['10th_board']?.toString() ?? '',
                  'school': data['10th_schl_name']?.toString() ?? '',
                  'year': data['10th_year_complete']?.toString() ?? '',
                  'percentage': data['10th_percent_cgpa']?.toString() ?? '',
                };
              } else if (highQualify == '2') {
                _savedDetails['2'] = {
                  'board': data['12th_board']?.toString() ?? '',
                  'stream': data['12th_stream']?.toString() ?? '',
                  'school': data['12th_schl_name']?.toString() ?? '',
                  'year': data['12th_year_complete']?.toString() ?? '',
                  'percentage': data['12th_percent_cgpa']?.toString() ?? '',
                };
              } else if (highQualify == '3' || highQualify == '4') {
                final String prefix = highQualify == '3' ? 'ug' : 'pg';
                _savedDetails[highQualify] = {
                  'course': data['${prefix}_course']?.toString() ?? '',
                  'specialization':
                  data['${prefix}_specialization']?.toString() ?? '',
                  'institute': data['${prefix}_college']?.toString() ?? '',
                  'university': data['${prefix}_university']?.toString() ?? '',
                  'duration': data['${prefix}_duration']?.toString() ?? '',
                  'year': data['${prefix}_year_complete']?.toString() ?? '',
                  'percentage':
                  data['${prefix}_percent_cgpa']?.toString() ?? '',
                };
              } else if (highQualify == '5') {
                _savedDetails['5'] = {
                  'diploma': data['diploma']?.toString() ?? '',
                  'institute': data['dip_institute']?.toString() ?? '',
                  'board': data['dip_board_university']?.toString() ?? '',
                  'duration': data['dip_duration']?.toString() ?? '',
                  'year': data['dip_year_complete']?.toString() ?? '',
                  'percentage': data['dip_percent']?.toString() ?? '',
                };
              } else if (highQualify == '6') {
                _savedDetails['6'] = {
                  'trade': data['iti_trade']?.toString() ?? '',
                  'specialization':
                  data['iti_specialization']?.toString() ?? '',
                  'institute': data['iti_institute']?.toString() ?? '',
                  'boardType': data['iti_board']?.toString() == '2'
                      ? 'SCVT'
                      : 'NCVT',
                  'duration': data['iti_duration']?.toString() ?? '',
                  'year': data['iti_year_complete']?.toString() ?? '',
                  'percentage': data['iti_percent']?.toString() ?? '',
                };
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading saved details: $e');
    }
  }

  Future<void> _fetchQualifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await QualificationCatApi.fetchCategories();
      if (res['error'] == false || res['status'] == 'success') {
        final List<dynamic>? list = res['data'];
        if (list != null && list.isNotEmpty) {
          final List<Map<String, dynamic>> fetched = [];
          for (var item in list) {
            if (item is Map) {
              fetched.add({
                'value': item['value']?.toString() ?? '',
                'name': item['name']?.toString() ?? '',
              });
            }
          }
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _qualifications = fetched;
            });
          }
        }
      }
      await _loadSavedDetails();
    } catch (e) {
      debugPrint('Error fetching qualifications: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cleanupUnrelatedDetails(String highQualify) {
    if (mounted) {
      setState(() {
        _savedDetails.removeWhere((k, v) => k != highQualify);
      });
    }
  }

  Future<void> _submitQualifications() async {
    if (_selectedOption == null) return;
    final String val = _selectedOption!['value']?.toString() ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();

      final res = await EducationalInsertApi.insertEducationalDetails(
        name: userId.toString(),
        highQualify: val,
        savedDetails: _savedDetails,
      );

      if (res['error'] == false || res['status'] == 'success') {
        await prefs.setInt('profile_creation_step', 3);
        if (mounted) {
          if (widget.isEditing) {
            Navigator.pop(context);
          } else {
            Navigator.push(
              context,
              SmoothPageRoute(child: const ExperienceScreen()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res['message'] ?? 'Failed to save educational details',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error inserting educational details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDetailsSheet(Map<String, dynamic> option) {
    final String val = option['value']?.toString() ?? '';
    final String name = option['name']?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (val == '1') {
          return TenthDetailsSheet(
            title: name,
            value: val,
            initialData: _savedDetails[val],
            onSave: (data) {
              setState(() {
                _savedDetails[val] = data;
              });
              print(
                'DEBUG Qualification Screen: Saved $val ($name) details -> $data',
              );
              Future.microtask(() => _submitQualifications());
            },
          );
        } else if (val == '2') {
          return TwelfthDetailsSheet(
            title: name,
            value: val,
            initialData: _savedDetails[val],
            onSave: (data) {
              setState(() {
                _savedDetails[val] = data;
              });
              print(
                'DEBUG Qualification Screen: Saved $val ($name) details -> $data',
              );
              Future.microtask(() => _submitQualifications());
            },
          );
        } else if (val == '5') {
          return DiplomaDetailsSheet(
            title: name,
            value: val,
            initialData: _savedDetails[val],
            onSave: (data) {
              setState(() {
                _savedDetails[val] = data;
              });
              print(
                'DEBUG Qualification Screen: Saved $val ($name) details -> $data',
              );
              Future.microtask(() => _submitQualifications());
            },
          );
        } else if (val == '6') {
          return ItiDetailsSheet(
            title: name,
            value: val,
            initialData: _savedDetails[val],
            onSave: (data) {
              setState(() {
                _savedDetails[val] = data;
              });
              print(
                'DEBUG Qualification Screen: Saved $val ($name) details -> $data',
              );
              Future.microtask(() => _submitQualifications());
            },
          );
        } else if (val == '3' || val == '4') {
          return UgPgDetailsSheet(
            title: name,
            value: val,
            initialData: _savedDetails[val],
            onSave: (data) {
              setState(() {
                _savedDetails[val] = data;
              });
              print(
                'DEBUG Qualification Screen: Saved $val ($name) details -> $data',
              );
              Future.microtask(() => _submitQualifications());
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _buildPill(Map<String, dynamic> option, double screenWidth, Color cardBg, Color textColor, Color borderColor) {
    final String name = option['name']?.toString() ?? '';
    final String val = option['value']?.toString() ?? '';
    final bool isSelected = _selectedOption?['value'] == val;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
        _cleanupUnrelatedDetails(val);
        _showDetailsSheet(option);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardBg,
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                top: screenWidth * 0.02,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textColor,
                  size: screenWidth * 0.06,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Progress Bar Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: screenHeight * 0.01,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.20, // 20% Progress
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.01,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Creation',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: subtitleColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '20%',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.035),

            // Title "Your Highest Qualification"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Text(
                'Your Highest Qualification',
                style: TextStyle(
                  fontSize: screenWidth * 0.048,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Responsive Wrap for Qualifications
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: _isLoading && _qualifications.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
                  : Wrap(
                spacing: screenWidth * 0.03,
                runSpacing: screenWidth * 0.03,
                children: _qualifications
                    .map((option) => _buildPill(option, screenWidth, cardBg, textColor, borderColor))
                    .toList(),
              ),
            ),

            const Spacer(),

            // Next Button at bottom
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: CustomNextButton(
                text: widget.isEditing ? 'Save' : 'Next',
                onPressed:
                (_selectedOption != null &&
                    _savedDetails.containsKey(
                      _selectedOption!['value']?.toString(),
                    ))
                    ? () {
                  _submitQualifications();
                }
                    : null, // Disabled if not selected or the details for it are not filled
              ),
            ),
          ],
        ),
      ),
    );
  }
}

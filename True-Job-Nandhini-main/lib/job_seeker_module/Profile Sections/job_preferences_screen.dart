import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../services/api/shift_api.dart';
import '../../services/api/work_mode_api.dart';
import '../../services/api/job_type_api.dart';
import '../../services/api/preferred_location_api.dart';
import '../../services/api/job_role_api.dart';
import '../../services/api/job_preference_api.dart';
import '../../widgets/add_job_role_popup.dart';
import '../../widgets/preferred_location_sheet.dart';


class JobPreferencesScreen extends StatefulWidget {
  const JobPreferencesScreen({super.key});

  @override
  State<JobPreferencesScreen> createState() => _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends State<JobPreferencesScreen> {
  // Selection states for chips
  List<String> _selectedShifts = [];
  List<String> _selectedWorkModes = [];
  List<String> _selectedJobTypes = [];
  List<String> _selectedJobRoles = [];
  List<String> _selectedLocations = [];

  // API dynamic shift list state
  List<Map<String, dynamic>> _shiftList = [];
  bool _isLoadingShifts = true;
  String? _shiftError;

  // API dynamic work mode list state
  List<Map<String, dynamic>> _workModeList = [];
  bool _isLoadingWorkModes = true;
  String? _workModeError;

  // API dynamic job type list state
  List<Map<String, dynamic>> _jobTypeList = [];
  bool _isLoadingJobTypes = true;
  String? _jobTypeError;

  // Predefined Expected Salary options
  final List<String> _salaryOptions = [
    '5,000',
    '10,000',
    '15,000',
    '20,000',
    '25,000',
    '30,000',
    '35,000',
    '40,000',
    '45,000',
    '50,000',
    '60,000',
    '70,000',
    '80,000',
    '90,000',
    '1,00,000+',
  ];

  String _expectSalary = '';
  bool _isSaving = false;
  bool _isLoadingPreferences = false;

  // Master lists for mapping labels to IDs when saving
  List<Map<String, dynamic>> _locationList = [];
  List<Map<String, dynamic>> _jobRolesList = [];

  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserIdAndSavedPreferences();
    await Future.wait([
      _fetchShifts(),
      _fetchWorkModes(),
      _fetchJobTypes(),
      _fetchLocationList(),
      _fetchJobRolesList(),
    ]);
    await _fetchUserPreferencesFromServer();
  }

  Future<void> _loadUserIdAndSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idInt = prefs.getInt('user_id');
    final String? idStr = idInt?.toString() ?? prefs.getString('user_id');

    if (idStr != null && idStr.isNotEmpty) {
      _userId = idStr;
      final List<String>? savedShifts = prefs.getStringList('user_${idStr}_selected_shifts');
      final List<String>? savedWorkModes = prefs.getStringList('user_${idStr}_selected_work_modes');
      final List<String>? savedJobTypes = prefs.getStringList('user_${idStr}_selected_job_types');
      final List<String>? savedJobRoles = prefs.getStringList('user_${idStr}_selected_job_roles');
      final List<String>? savedLocations = prefs.getStringList('user_${idStr}_selected_locations');
      final String? savedExpectSalary = prefs.getString('user_${idStr}_expected_salary');
      if (mounted) {
        setState(() {
          if (savedShifts != null) _selectedShifts = savedShifts;
          if (savedWorkModes != null) _selectedWorkModes = savedWorkModes;
          if (savedJobTypes != null) _selectedJobTypes = savedJobTypes;
          if (savedJobRoles != null) _selectedJobRoles = savedJobRoles;
          if (savedLocations != null) _selectedLocations = savedLocations;
          if (savedExpectSalary != null) _expectSalary = savedExpectSalary;
        });
      }
    } else {
      final List<String>? savedShifts = prefs.getStringList('selected_shifts');
      final List<String>? savedWorkModes = prefs.getStringList('selected_work_modes');
      final List<String>? savedJobTypes = prefs.getStringList('selected_job_types');
      final List<String>? savedJobRoles = prefs.getStringList('selected_job_roles');
      final List<String>? savedLocations = prefs.getStringList('selected_locations');
      final String? savedExpectSalary = prefs.getString('expected_salary');
      if (mounted) {
        setState(() {
          if (savedShifts != null) _selectedShifts = savedShifts;
          if (savedWorkModes != null) _selectedWorkModes = savedWorkModes;
          if (savedJobTypes != null) _selectedJobTypes = savedJobTypes;
          if (savedJobRoles != null) _selectedJobRoles = savedJobRoles;
          if (savedLocations != null) _selectedLocations = savedLocations;
          if (savedExpectSalary != null) _expectSalary = savedExpectSalary;
        });
      }
    }
  }

  Future<void> _saveSelectedShifts(List<String> shifts) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null && _userId!.isNotEmpty) {
      await prefs.setStringList('user_${_userId}_selected_shifts', shifts);
    }
    await prefs.setStringList('selected_shifts', shifts);
  }

  Future<void> _saveSelectedWorkModes(List<String> workModes) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null && _userId!.isNotEmpty) {
      await prefs.setStringList('user_${_userId}_selected_work_modes', workModes);
    }
    await prefs.setStringList('selected_work_modes', workModes);
  }

  Future<void> _saveSelectedJobTypes(List<String> jobTypes) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null && _userId!.isNotEmpty) {
      await prefs.setStringList('user_${_userId}_selected_job_types', jobTypes);
    }
    await prefs.setStringList('selected_job_types', jobTypes);
  }

  Future<void> _saveSelectedJobRoles(List<String> jobRoles) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null && _userId!.isNotEmpty) {
      await prefs.setStringList('user_${_userId}_selected_job_roles', jobRoles);
    }
    await prefs.setStringList('selected_job_roles', jobRoles);
  }

  Future<void> _saveSelectedLocations(List<String> locations) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null && _userId!.isNotEmpty) {
      await prefs.setStringList('user_${_userId}_selected_locations', locations);
    }
    await prefs.setStringList('selected_locations', locations);
  }

  Future<void> _saveExpectedSalary(String salary) async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null && _userId!.isNotEmpty) {
      await prefs.setString('user_${_userId}_expected_salary', salary);
    }
    await prefs.setString('expected_salary', salary);
  }

  Future<void> _fetchLocationList() async {
    try {
      final res = await PreferredLocationApi.fetchPreferredLocations(userId: _userId);
      if (res['error'] == false && res['dropdown'] != null) {
        final List rawList = res['dropdown'];
        if (mounted) {
          setState(() {
            _locationList = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching locations master list: $e');
    }
  }

  Future<void> _fetchJobRolesList() async {
    try {
      final res = await JobRoleApi.fetchJobRoles(userId: _userId);
      if (res['error'] == false && res['data'] is List) {
        final List rawList = res['data'];
        if (mounted) {
          setState(() {
            _jobRolesList = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching job roles master list: $e');
    }
  }

  Future<void> _fetchUserPreferencesFromServer() async {
    if (_userId == null || _userId!.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isLoadingPreferences = true;
    });

    try {
      final res = await JobPreferenceApi.selectJobPreferences(name: _userId!);
      if (res['status'] == 'success' && res['data'] != null) {
        final data = res['data'];

        List<String> serverShifts = [];
        if (data['shift'] is List) {
          serverShifts = List<String>.from(data['shift'].map((e) => e.toString()));
        }

        List<String> serverWorkModes = [];
        if (data['work_mode'] is List) {
          serverWorkModes = List<String>.from(data['work_mode'].map((e) => e.toString()));
        }

        List<String> serverJobTypes = [];
        if (data['job_type'] is List) {
          serverJobTypes = List<String>.from(data['job_type'].map((e) => e.toString()));
        }

        List<String> serverLocations = [];
        if (data['location'] is List) {
          serverLocations = List<String>.from(data['location'].map((e) => e.toString()));
        }

        List<String> serverJobRoles = [];
        if (data['job_role'] is List) {
          serverJobRoles = List<String>.from(data['job_role'].map((e) => e.toString().trim()));
        } else if (data['job_role'] != null) {
          final String roleStr = data['job_role'].toString().trim();
          if (roleStr.isNotEmpty) {
            if (roleStr.startsWith('[') && roleStr.endsWith(']')) {
              try {
                final decoded = jsonDecode(roleStr);
                if (decoded is List) {
                  serverJobRoles = List<String>.from(decoded.map((e) => e.toString().trim()));
                }
              } catch (_) {
                serverJobRoles.add(roleStr);
              }
            } else if (roleStr.contains(',')) {
              serverJobRoles = roleStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            } else {
              serverJobRoles.add(roleStr);
            }
          }
        }

        final String serverExpectSalary = data['expect_salary']?.toString() ?? '';

        if (mounted) {
          setState(() {
            if (serverShifts.isNotEmpty) _selectedShifts = serverShifts;
            if (serverWorkModes.isNotEmpty) _selectedWorkModes = serverWorkModes;
            if (serverJobTypes.isNotEmpty) _selectedJobTypes = serverJobTypes;
            if (serverLocations.isNotEmpty) _selectedLocations = serverLocations;
            if (serverJobRoles.isNotEmpty) _selectedJobRoles = serverJobRoles;
            if (serverExpectSalary.isNotEmpty) _expectSalary = serverExpectSalary;
          });
        }

        // Cache loaded data into SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String id = _userId!;
        await prefs.setStringList('user_${id}_selected_shifts', _selectedShifts);
        await prefs.setStringList('user_${id}_selected_work_modes', _selectedWorkModes);
        await prefs.setStringList('user_${id}_selected_job_types', _selectedJobTypes);
        await prefs.setStringList('user_${id}_selected_locations', _selectedLocations);
        await prefs.setStringList('user_${id}_selected_job_roles', _selectedJobRoles);
        await prefs.setString('user_${id}_expected_salary', _expectSalary);
      }
    } catch (e) {
      debugPrint('Error loading preferences from server: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPreferences = false;
        });
      }
    }
  }

  String _getFormattedSalary(String salary) {
    if (salary.isEmpty) return '';
    final double? val = double.tryParse(salary);
    if (val != null) {
      if (val >= 100000) {
        return '1,00,000+';
      }
      final int intVal = val.toInt();
      if (intVal == 5000) return '5,000';
      if (intVal == 10000) return '10,000';
      if (intVal == 15000) return '15,000';
      if (intVal == 20000) return '20,000';
      if (intVal == 25000) return '25,000';
      if (intVal == 30000) return '30,000';
      if (intVal == 35000) return '35,000';
      if (intVal == 40000) return '40,000';
      if (intVal == 45000) return '45,000';
      if (intVal == 50000) return '50,000';
      if (intVal == 60000) return '60,000';
      if (intVal == 70000) return '70,000';
      if (intVal == 80000) return '80,000';
      if (intVal == 90000) return '90,000';
      return intVal.toString();
    }
    return salary;
  }

  void _showExpectedSalarySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final Color bgColor = AppColors.dynamicBg;
        final Color textColor = AppColors.dynamicText;
        final Color borderColor = AppColors.dynamicBorder;
        final double sw = MediaQuery.of(context).size.width;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: sw * 0.03),
              Container(
                width: sw * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(sw * 0.04),
                child: Text(
                  'Select Expected Salary (Monthly)',
                  style: TextStyle(
                    fontSize: sw * 0.045,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _salaryOptions.length,
                  itemBuilder: (context, index) {
                    final optionLabel = _salaryOptions[index];
                    final cleanVal = optionLabel.replaceAll(',', '').replaceAll('+', '');
                    final isSelected = _expectSalary == cleanVal;

                    return ListTile(
                      title: Text(
                        '₹ $optionLabel',
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _expectSalary = cleanVal;
                        });
                        _saveExpectedSalary(cleanVal);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePreferencesToServer() async {
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save preferences.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Resolve job role IDs
      final List<int> jobRoleIds = [];
      for (var role in _selectedJobRoles) {
        final matched = _jobRolesList.firstWhere(
          (item) => item['role']?.toString().toLowerCase() == role.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (matched.isNotEmpty) {
          final val = int.tryParse(matched['id']?.toString() ?? '');
          if (val != null) jobRoleIds.add(val);
        }
      }

      // 2. Resolve shifts IDs
      final List<int> shiftIds = [];
      for (var label in _selectedShifts) {
        final matched = _shiftList.firstWhere(
          (item) => item['label']?.toString().toLowerCase() == label.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (matched.isNotEmpty) {
          final val = int.tryParse(matched['value']?.toString() ?? '');
          if (val != null) shiftIds.add(val);
        }
      }

      // 3. Resolve work modes IDs
      final List<int> workModeIds = [];
      for (var label in _selectedWorkModes) {
        final matched = _workModeList.firstWhere(
          (item) => item['label']?.toString().toLowerCase() == label.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (matched.isNotEmpty) {
          final val = int.tryParse(matched['value']?.toString() ?? '');
          if (val != null) workModeIds.add(val);
        }
      }

      // 4. Resolve job types IDs
      final List<int> jobTypeIds = [];
      for (var label in _selectedJobTypes) {
        final matched = _jobTypeList.firstWhere(
          (item) => item['label']?.toString().toLowerCase() == label.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (matched.isNotEmpty) {
          final val = int.tryParse(matched['value']?.toString() ?? '');
          if (val != null) jobTypeIds.add(val);
        }
      }

      // 5. Resolve locations IDs
      final List<int> locationIds = [];
      for (var label in _selectedLocations) {
        final matched = _locationList.firstWhere(
          (item) => item['label']?.toString().toLowerCase() == label.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (matched.isNotEmpty) {
          final val = int.tryParse(matched['value']?.toString() ?? '');
          if (val != null) locationIds.add(val);
        }
      }

      final res = await JobPreferenceApi.updateJobPreferences(
        name: _userId!,
        jobRoleIds: jobRoleIds,
        shiftIds: shiftIds,
        workModeIds: workModeIds,
        jobTypeIds: jobTypeIds,
        expectSalary: _expectSalary,
        locationIds: locationIds,
      );

      if (res['status'] == 'success' || res['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to save preferences'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _fetchShifts() async {
    if (!mounted) return;
    setState(() {
      _isLoadingShifts = true;
      _shiftError = null;
    });

    final res = await ShiftApi.fetchShifts(userId: _userId);

    if (!mounted) return;

    if (res['error'] == false && res['dropdown'] != null) {
      final List rawList = res['dropdown'];
      setState(() {
        _shiftList = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingShifts = false;
      });
    } else {
      setState(() {
        _shiftError = res['message'] ?? 'Failed to load shifts';
        _isLoadingShifts = false;
      });
    }
  }

  Future<void> _fetchWorkModes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWorkModes = true;
      _workModeError = null;
    });

    final res = await WorkModeApi.fetchWorkModes(userId: _userId);

    if (!mounted) return;

    if (res['error'] == false && res['dropdown'] != null) {
      final List rawList = res['dropdown'];
      setState(() {
        _workModeList = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingWorkModes = false;
      });
    } else {
      setState(() {
        _workModeError = res['message'] ?? 'Failed to load work modes';
        _isLoadingWorkModes = false;
      });
    }
  }

  Future<void> _fetchJobTypes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingJobTypes = true;
      _jobTypeError = null;
    });

    final res = await JobTypeApi.fetchJobTypes(userId: _userId);

    if (!mounted) return;

    if (res['error'] == false && res['dropdown'] != null) {
      final List rawList = res['dropdown'];
      setState(() {
        _jobTypeList = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoadingJobTypes = false;
      });
    } else {
      setState(() {
        _jobTypeError = res['message'] ?? 'Failed to load job types';
        _isLoadingJobTypes = false;
      });
    }
  }

  void _toggleShiftSelection(String label) {
    setState(() {
      if (_selectedShifts.contains(label)) {
        _selectedShifts.remove(label);
      } else {
        _selectedShifts.add(label);
      }
    });
    _saveSelectedShifts(_selectedShifts);
  }

  void _toggleWorkModeSelection(String label) {
    setState(() {
      if (_selectedWorkModes.contains(label)) {
        _selectedWorkModes.remove(label);
      } else {
        _selectedWorkModes.add(label);
      }
    });
    _saveSelectedWorkModes(_selectedWorkModes);
  }

  void _toggleJobTypeSelection(String label) {
    setState(() {
      if (_selectedJobTypes.contains(label)) {
        _selectedJobTypes.remove(label);
      } else {
        _selectedJobTypes.add(label);
      }
    });
    _saveSelectedJobTypes(_selectedJobTypes);
  }

  void _showAddJobRolePopup(BuildContext context) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => AddJobRolePopup(initialRoles: _selectedJobRoles),
    );
    if (result != null) {
      setState(() {
        final List<String> updatedRoles = [];
        for (var role in result) {
          final cleanRole = role.trim();
          if (cleanRole.isNotEmpty && !updatedRoles.contains(cleanRole)) {
            updatedRoles.add(cleanRole);
          }
        }
        _selectedJobRoles = updatedRoles;
      });
      _saveSelectedJobRoles(_selectedJobRoles);
    }
  }

  void _showPreferredLocationSheet(BuildContext context) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreferredLocationSheet(initialLocations: _selectedLocations),
    );
    if (result != null) {
      setState(() {
        _selectedLocations = result;
      });
      _saveSelectedLocations(_selectedLocations);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double sw = size.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color borderColor = AppColors.dynamicBorder;

    // Responsive sizing helpers using media query
    final double paddingHorizontal = sw * 0.05;
    final double headingFontSize = sw * 0.045;
    final double chipFontSize = sw * 0.035;
    final double iconSize = sw * 0.055;
    final double sectionSpacing = sw * 0.06;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: sw * 0.15,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Preference',
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.052,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoadingPreferences
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: sw * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Add Job Role
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showAddJobRolePopup(context),
                      child: Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            color: subtitleColor,
                            size: iconSize,
                          ),
                          SizedBox(width: sw * 0.03),
                          Text(
                            'Add  Job Role',
                            style: TextStyle(
                              fontSize: headingFontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.add, color: subtitleColor, size: sw * 0.065),
                            onPressed: () => _showAddJobRolePopup(context),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedJobRoles.isNotEmpty) ...[
                      SizedBox(height: sw * 0.025),
                      Wrap(
                        spacing: sw * 0.02,
                        runSpacing: sw * 0.02,
                        children: _selectedJobRoles.map((role) {
                          return InputChip(
                            label: Text(role),
                            backgroundColor: const Color(0xFFE7EFFF),
                            labelStyle: TextStyle(
                              color: AppColors.primary,
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFFE7EFFF)),
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedJobRoles.remove(role);
                              });
                              _saveSelectedJobRoles(_selectedJobRoles);
                            },
                            deleteIcon: Icon(
                              Icons.cancel,
                              color: AppColors.primary,
                              size: sw * 0.045,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    Divider(color: borderColor, thickness: 1),
                    SizedBox(height: sectionSpacing * 0.5),

                    // 2. Select Shift
                    Row(
                      children: [
                        Icon(
                          Icons.north_rounded,
                          color: subtitleColor,
                          size: iconSize,
                        ),
                        SizedBox(width: sw * 0.03),
                        Text(
                          'Select Shift',
                          style: TextStyle(
                            fontSize: headingFontSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.04),
                    if (_isLoadingShifts)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else if (_shiftError != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shiftError!,
                              style: TextStyle(color: Colors.red, fontSize: chipFontSize),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _fetchShifts,
                          ),
                        ],
                      )
                    else if (_shiftList.isEmpty)
                      Text(
                        'No shifts available',
                        style: TextStyle(color: subtitleColor, fontSize: chipFontSize),
                      )
                    else
                      Wrap(
                        spacing: sw * 0.03,
                        runSpacing: sw * 0.02,
                        children: _shiftList.map((shiftItem) {
                          final String label = shiftItem['label']?.toString() ?? '';
                          final bool isSelected = _selectedShifts.contains(label);
                          return _buildMultiSelectChip(
                            label,
                            isSelected,
                            () => _toggleShiftSelection(label),
                            sw,
                            chipFontSize,
                            cardBg,
                            borderColor,
                            subtitleColor,
                          );
                        }).toList(),
                      ),
                    SizedBox(height: sw * 0.04),
                    Divider(color: borderColor, thickness: 1),
                    SizedBox(height: sectionSpacing * 0.5),

                    // 3. Select Work Mode
                    Row(
                      children: [
                        Icon(
                          Icons.home_work_rounded,
                          color: subtitleColor,
                          size: iconSize,
                        ),
                        SizedBox(width: sw * 0.03),
                        Text(
                          'Select Work Mode',
                          style: TextStyle(
                            fontSize: headingFontSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.04),
                    if (_isLoadingWorkModes)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else if (_workModeError != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _workModeError!,
                              style: TextStyle(color: Colors.red, fontSize: chipFontSize),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _fetchWorkModes,
                          ),
                        ],
                      )
                    else if (_workModeList.isEmpty)
                      Text(
                        'No work modes available',
                        style: TextStyle(color: subtitleColor, fontSize: chipFontSize),
                      )
                    else
                      Wrap(
                        spacing: sw * 0.03,
                        runSpacing: sw * 0.02,
                        children: _workModeList.map((modeItem) {
                          final String label = modeItem['label']?.toString() ?? '';
                          final bool isSelected = _selectedWorkModes.contains(label);
                          return _buildMultiSelectChip(
                            label,
                            isSelected,
                            () => _toggleWorkModeSelection(label),
                            sw,
                            chipFontSize,
                            cardBg,
                            borderColor,
                            subtitleColor,
                          );
                        }).toList(),
                      ),
                    SizedBox(height: sw * 0.04),
                    Divider(color: borderColor, thickness: 1),
                    SizedBox(height: sectionSpacing * 0.5),

                    // 4. Select Job Type
                    Row(
                      children: [
                        Icon(
                          Icons.business_center_rounded,
                          color: subtitleColor,
                          size: iconSize,
                        ),
                        SizedBox(width: sw * 0.03),
                        Text(
                          'Select Job Type',
                          style: TextStyle(
                            fontSize: headingFontSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.04),
                    if (_isLoadingJobTypes)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else if (_jobTypeError != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _jobTypeError!,
                              style: TextStyle(color: Colors.red, fontSize: chipFontSize),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _fetchJobTypes,
                          ),
                        ],
                      )
                    else if (_jobTypeList.isEmpty)
                      Text(
                        'No job types available',
                        style: TextStyle(color: subtitleColor, fontSize: chipFontSize),
                      )
                    else
                      Wrap(
                        spacing: sw * 0.03,
                        runSpacing: sw * 0.02,
                        children: _jobTypeList.map((typeItem) {
                          final String label = typeItem['label']?.toString() ?? '';
                          final bool isSelected = _selectedJobTypes.contains(label);
                          return _buildMultiSelectChip(
                            label,
                            isSelected,
                            () => _toggleJobTypeSelection(label),
                            sw,
                            chipFontSize,
                            cardBg,
                            borderColor,
                            subtitleColor,
                          );
                        }).toList(),
                      ),
                    SizedBox(height: sw * 0.04),
                    Divider(color: borderColor, thickness: 1),
                    SizedBox(height: sectionSpacing * 0.5),

                    // 5. Expected Salary
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showExpectedSalarySheet(context),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: subtitleColor,
                            size: iconSize,
                          ),
                          SizedBox(width: sw * 0.03),
                          Text(
                            'Expected salary',
                            style: TextStyle(
                              fontSize: headingFontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.add, color: subtitleColor, size: sw * 0.065),
                            onPressed: () => _showExpectedSalarySheet(context),
                          ),
                        ],
                      ),
                    ),
                    if (_expectSalary.isNotEmpty) ...[
                      SizedBox(height: sw * 0.025),
                      InputChip(
                        label: Text('₹ ${_getFormattedSalary(_expectSalary)}'),
                        backgroundColor: const Color(0xFFE7EFFF),
                        labelStyle: TextStyle(
                          color: AppColors.primary,
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE7EFFF)),
                        ),
                        onDeleted: () {
                          setState(() {
                            _expectSalary = '';
                          });
                          _saveExpectedSalary('');
                        },
                        deleteIcon: Icon(
                          Icons.cancel,
                          color: AppColors.primary,
                          size: sw * 0.045,
                        ),
                      ),
                    ],
                    Divider(color: borderColor, thickness: 1),
                    SizedBox(height: sectionSpacing * 0.5),

                    // 6. Preferred Location
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showPreferredLocationSheet(context),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: subtitleColor,
                            size: iconSize,
                          ),
                          SizedBox(width: sw * 0.03),
                          Text(
                            'Preferred Location',
                            style: TextStyle(
                              fontSize: headingFontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.add, color: subtitleColor, size: sw * 0.065),
                            onPressed: () => _showPreferredLocationSheet(context),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedLocations.isNotEmpty) ...[
                      SizedBox(height: sw * 0.025),
                      Wrap(
                        spacing: sw * 0.02,
                        runSpacing: sw * 0.02,
                        children: _selectedLocations.map((location) {
                          return InputChip(
                            label: Text(location),
                            backgroundColor: const Color(0xFFE7EFFF),
                            labelStyle: TextStyle(
                              color: AppColors.primary,
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFFE7EFFF)),
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedLocations.remove(location);
                              });
                              _saveSelectedLocations(_selectedLocations);
                            },
                            deleteIcon: Icon(
                              Icons.cancel,
                              color: AppColors.primary,
                              size: sw * 0.045,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    Divider(color: borderColor, thickness: 1),
                    SizedBox(height: sectionSpacing),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.03),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: sw * 0.12,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _savePreferencesToServer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw * 0.06),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Reusable Multi-Selectable Chip Widget
  Widget _buildMultiSelectChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    double sw,
    double chipFontSize,
    Color cardBg,
    Color borderColor,
    Color subtitleColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.045,
          vertical: sw * 0.022,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE7EFFF) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : subtitleColor,
            fontSize: chipFontSize,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

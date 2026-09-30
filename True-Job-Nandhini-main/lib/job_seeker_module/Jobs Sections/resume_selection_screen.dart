import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../services/api/profile_select_api.dart';
import '../../services/api/profile_update_api.dart';
import '../../services/api/apply_job_api.dart';
import '../../services/api/educational_select_api.dart';
import '../../services/api/skills_select_api.dart';
import 'applied_successfully_screen.dart';
import '../resume_preview_page.dart';
import '../../utils/smooth_page_route.dart';
import '../../widgets/company_logo_widget.dart';

class ResumeSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const ResumeSelectionScreen({super.key, required this.job});

  @override
  State<ResumeSelectionScreen> createState() => _ResumeSelectionScreenState();
}

class _ResumeSelectionScreenState extends State<ResumeSelectionScreen> {
  int _selectedResumeIndex = 0;
  bool _isLoading = false;
  bool _isUploading = false;
  String _resumeName = '';
  final List<Map<String, String>> _resumes = [];

  // Cached profile details to preserve on update
  String _profileName = '';
  String _profileMobile = '';
  String _profileEmail = '';
  String _profileDob = '';
  String _profileGender = '';
  String _profilePC = '';
  String _profileCondType = '';
  String _profileAffectArea = '';
  String _linkedin = '';
  String _portfolio = '';
  String _profileHighQualify = '';
  String _profileCompany = '';
  String _profilePhoto = '';
  String _profileLanguage = '';
  String _profileEducation = '';

  // ---- Application Details form state (Figma: Expected Salary -> Portfolio) ----
  final TextEditingController _expectedSalaryController =
      TextEditingController();
  final TextEditingController _currentSalaryController =
      TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();

  String _expectedSalaryPeriod = 'Per Annum';
  String _currentSalaryPeriod = 'Per Annum';
  String? _noticePeriod;
  String? _totalExperience;
  String? _willingToRelocate;
  final List<String> _skills = [];

  final List<String> _salaryPeriodOptions = ['Per Annum', 'Per Month'];
  final List<String> _noticePeriodOptions = [
    'Immediate',
    '15 Days',
    '30 Days',
    '45 Days',
    '60 Days',
    '90 Days',
  ];
  final List<String> _experienceOptions = [
    'Fresher',
    '1 Year',
    '2 Years',
    '3 Years',
    '4 Years',
    '5 Years',
    '6 Years',
    '7 Years',
    '8+ Years',
  ];
  final List<String> _relocateOptions = ['Yes', 'No', 'Depands on Location'];

  final GlobalKey _expectedSalaryPeriodKey = GlobalKey();
  final GlobalKey _currentSalaryPeriodKey = GlobalKey();
  final GlobalKey _noticePeriodKey = GlobalKey();
  final GlobalKey _totalExperienceKey = GlobalKey();

  List<String> _availableSkills = [];
  final Map<String, String> _skillNameToId = {};

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
    _loadAvailableSkills();
  }

  Future<void> _loadAvailableSkills() async {
    try {
      final res = await SkillsSelectApi.fetchSkills();
      if (res['status'] == 'success' || res['error'] == false) {
        final List<dynamic>? skillsList = res['data'] as List<dynamic>?;
        if (skillsList != null) {
          final List<String> loaded = [];
          for (var item in skillsList) {
            if (item is Map && item['name'] != null) {
              final String name = item['name'].toString();
              loaded.add(name);
              _skillNameToId[name] = (item['id'] ?? item['value'] ?? '').toString();
            }
          }
          loaded.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          if (mounted) {
            setState(() {
              _availableSkills = loaded;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading available skills: $e');
    }
  }

  @override
  void dispose() {
    _expectedSalaryController.dispose();
    _currentSalaryController.dispose();
    _portfolioController.dispose();
    _skillInputController.dispose();
    super.dispose();
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

  Future<void> _loadProfileDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();

      // First try to load from SharedPreferences for instant display
      final String cachedResume = prefs.getString('resume') ?? '';
      _profileName = prefs.getString('name') ?? '';
      _profileMobile = prefs.getString('mobile') ?? '';
      _profileEmail = prefs.getString('email') ?? '';
      _profileDob = prefs.getString('dob') ?? '';
      _profileGender = prefs.getString('gender') ?? '';
      _profilePC = prefs.getString('physical_challenge') ?? '';
      _profileCondType = prefs.getString('cond_type') ?? '';
      _profileAffectArea = prefs.getString('affect_area') ?? '';
      _linkedin = (prefs.getString('linkedin') ?? '').trim();
      _portfolio = (prefs.getString('portfolio') ?? '').trim();
      _profileCompany = prefs.getString('user_${userId}_company_name') ?? prefs.getString('company_name') ?? '';
      _profilePhoto = prefs.getString('profile_image_url') ?? '';
      _profileLanguage = prefs.getString('language') ?? '';
      _profileEducation = prefs.getString('education') ?? '';

      final List<String> loadedSkills = prefs.getStringList('user_${userId}_skills') ?? [];
      _skills.clear();
      _skills.addAll(loadedSkills);

      if (cachedResume.isNotEmpty) {
        _resumeName = cachedResume;
        await _addResumeToList(cachedResume);
      }

      // Fetch from API for accuracy
      final res = await ProfileSelectApi.fetchProfile(userId: userId);
      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          _profileName = data['name']?.toString() ?? _profileName;
          _profileMobile = data['mobile']?.toString() ?? _profileMobile;
          _profileEmail = data['email']?.toString() ?? _profileEmail;
          _profileDob = data['dob']?.toString() ?? _profileDob;
          _profileGender = data['gender']?.toString() ?? _profileGender;
          _profilePC = data['physical_challenge']?.toString() ?? _profilePC;
          _profileCondType = data['cond_type']?.toString() ?? _profileCondType;
          _profileAffectArea =
              data['affect_area']?.toString() ?? _profileAffectArea;
          _linkedin = (data['linkedin']?.toString() ?? '').trim();
          _portfolio = (data['portfolio']?.toString() ?? '').trim();
          _profilePhoto = (data['photo'] ?? data['profile_image'])?.toString() ?? _profilePhoto;
          _profileLanguage = data['language']?.toString() ?? _profileLanguage;
          _profileEducation = data['education']?.toString() ?? _profileEducation;

          final String resumeName = data['resume']?.toString() ?? '';
          if (resumeName.isNotEmpty && resumeName != _resumeName) {
            _resumeName = resumeName;
            await _addResumeToList(resumeName);
            // Save to shared prefs
            await prefs.setString('resume', resumeName);
          }
        }
      }

      // Fetch educational details for high_qualify
      try {
        final eduRes = await EducationalSelectApi.fetchEducationalDetails(
          name: userId.toString(),
        );
        if (eduRes['status'] == 'success' || eduRes['error'] == false) {
          final data = eduRes['data'];
          if (data != null && data is Map<String, dynamic>) {
            final String highQualifyVal =
                data['high_qualify']?.toString() ?? '';
            if (highQualifyVal == '1') {
              _profileHighQualify = '10th';
            } else if (highQualifyVal == '2') {
              _profileHighQualify = '12th';
            } else if (highQualifyVal == '3') {
              _profileHighQualify = 'UG';
            } else if (highQualifyVal == '4') {
              _profileHighQualify = 'PG';
            } else if (highQualifyVal == '5') {
              _profileHighQualify = 'Diploma';
            } else if (highQualifyVal == '6') {
              _profileHighQualify = 'ITI';
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching educational details in ResumeSelection: $e');
      }

    } catch (e) {
      debugPrint('Error loading profile details: $e');
    } finally {
      _portfolioController.text = _portfolio;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addResumeToList(String filename) async {
    String sizeStr = 'Size: N/A';
    String modifiedStr = 'Uploaded';

    try {
      final String cleanFilename = filename.split('/').last;
      final appDocDir = await getApplicationDocumentsDirectory();
      final localFile = File('${appDocDir.path}/$cleanFilename');
      if (await localFile.exists()) {
        final sizeBytes = await localFile.length();
        final stat = await localFile.stat();
        sizeStr = '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
        modifiedStr =
            'Modified ${stat.modified.day}/${stat.modified.month}/${stat.modified.year}';
      }
    } catch (e) {
      debugPrint('Error getting local file details: $e');
    }

    if (mounted) {
      setState(() {
        _resumes.clear();
        _resumes.add({
          'name': filename,
          'modified': modifiedStr,
          'size': sizeStr,
        });
        _selectedResumeIndex = 0;
      });
    }
  }

  void _viewResume(String filename) async {
    final String cleanFilename = filename.split('/').last;
    final appDocDir = await getApplicationDocumentsDirectory();
    final localFile = File('${appDocDir.path}/$cleanFilename');

    if (await localFile.exists()) {
      if (!mounted) return;
      Navigator.push(
        context,
        SmoothPageRoute(
          child: ResumePreviewPage(file: localFile, title: cleanFilename),
        ),
      );
    } else {
      String downloadUrl = filename;
      if (!downloadUrl.startsWith('http')) {
        if (downloadUrl.startsWith('/')) {
          downloadUrl = 'http://truejobs.in$downloadUrl';
        } else if (downloadUrl.startsWith('ai/uploads/')) {
          downloadUrl = 'http://truejobs.in/$downloadUrl';
        } else {
          downloadUrl = 'http://truejobs.in/ai/uploads/$downloadUrl';
        }
      }
      final encodedUrl = Uri.encodeFull(downloadUrl);

      if (!mounted) return;
      Navigator.push(
        context,
        SmoothPageRoute(
          child: ResumePreviewPage(url: encodedUrl, title: cleanFilename),
        ),
      );
    }
  }

  String _normalizeGender(String value) {
    final clean = value.trim().toLowerCase();
    if (clean == 'male' || clean == '1') return '1';
    if (clean == 'female' || clean == '2') return '2';
    if (clean == 'others' || clean == 'other' || clean == '3') return '3';
    return '1';
  }

  String _normalizePhysicalChallenge(String value) {
    final clean = value.trim().toLowerCase();
    if (clean == 'yes' || clean == '1') return '1';
    if (clean == 'no' || clean == '2') return '2';
    return '2';
  }

  String _normalizeRelocate(String? value) {
    if (value == null) return '2';
    final clean = value.trim().toLowerCase();
    if (clean == 'yes' || clean == '1') return '1';
    return '2';
  }

  Future<void> _pickAndUploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = result.files.single;

        setState(() {
          _isUploading = true;
        });

        // Copy file to persistent App Documents Directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final String localPath = '${appDocDir.path}/${pickedFile.name}';
        final File localFile = File(pickedFile.path!);
        await localFile.copy(localPath);

        final int? userId = await _getValidUserId();
        if (userId == null) return;
        final prefs = await SharedPreferences.getInstance();

        final String resumeUrl = pickedFile.name;

        final updateRes = await ProfileUpdateApi.updateProfile(
          userId: userId,
          name: _profileName,
          mobile: _profileMobile,
          email: _profileEmail,
          dob: _profileDob,
          gender: _normalizeGender(_profileGender),
          physicalChallenge: _normalizePhysicalChallenge(_profilePC),
          condType: _profileCondType,
          affectArea: _profileAffectArea,
          resume: resumeUrl,
          linkedin: _linkedin.trim().isEmpty ? ' ' : _linkedin.trim(),
          portfolio: _portfolio.trim().isEmpty ? ' ' : _portfolio.trim(),
          resumeFile: File(pickedFile.path!),
        );

        if (updateRes['status'] == 'success' || updateRes['error'] == false) {
          String finalResumeValue = resumeUrl;
          if (updateRes['data'] != null && updateRes['data'] is Map && updateRes['data']['resume'] != null) {
            final returnedResume = updateRes['data']['resume'].toString();
            if (returnedResume.isNotEmpty) {
              finalResumeValue = returnedResume;
            }
          }
          await prefs.setString('resume', finalResumeValue);
          _resumeName = finalResumeValue;
          await _addResumeToList(finalResumeValue);
          if (mounted) {}
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updateRes['message'] ?? 'Failed to upload resume',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking or uploading resume: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ---- New helpers for the Application Details fields (Figma) ----

  String _getCleanResumeName(String path) {
    if (path.isEmpty) return '';
    String filename = path.split('/').last;
    final regex = RegExp(r'^\d+_(.*)$');
    final match = regex.firstMatch(filename);
    if (match != null) {
      return match.group(1) ?? filename;
    }
    return filename;
  }

  Future<void> _showOptionsMenu({
    required GlobalKey anchorKey,
    required List<String> options,
    required void Function(String) onSelected,
  }) async {
    final RenderBox? renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final String? selected = await showMenu<String>(
      context: context,
      color: AppColors.dynamicBg,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: options
          .map((opt) => PopupMenuItem<String>(
                value: opt,
                child: Text(
                  opt,
                  style: TextStyle(color: AppColors.dynamicText),
                ),
              ))
          .toList(),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }



  Widget _buildFieldLabel(double sw, String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w600,
            color: AppColors.dynamicText,
          ),
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(color: Colors.red, fontSize: sw * 0.038),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSalaryField({
    required double sw,
    required String label,
    required bool required,
    required TextEditingController controller,
    required String period,
    required GlobalKey dropdownKey,
    required void Function(String) onPeriodSelected,
  }) {
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(sw, label, required: required),
        SizedBox(height: sw * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/rupee.png',
                height: sw * 0.06,
                width: sw * 0.06,
              ),
              SizedBox(width: sw * 0.025),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [IndianCurrencyInputFormatter()],
                  style: TextStyle(fontSize: sw * 0.038, color: textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: subtitleColor, fontSize: sw * 0.035),
                  ),
                ),
              ),
              GestureDetector(
                key: dropdownKey,
                onTap: () => _showOptionsMenu(
                  anchorKey: dropdownKey,
                  options: _salaryPeriodOptions,
                  onSelected: onPeriodSelected,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                  child: Row(
                    children: [
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: sw * 0.036,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: sw * 0.01),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: sw * 0.05,
                        color: textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSelectField({
    required double sw,
    required String label,
    required IconData icon,
    required String? value,
    required String placeholder,
    required GlobalKey dropdownKey,
    required List<String> options,
    required void Function(String) onSelected,
  }) {
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(sw, label, required: true),
        SizedBox(height: sw * 0.02),
        GestureDetector(
          key: dropdownKey,
          onTap: () => _showOptionsMenu(
            anchorKey: dropdownKey,
            options: options,
            onSelected: onSelected,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.035,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: sw * 0.045, color: textColor),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      color: value == null ? subtitleColor : textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: sw * 0.05,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsField(double sw) {
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    TextEditingController? autoCompleteController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(sw, 'Skills', required: true),
        SizedBox(height: sw * 0.008),
        Text(
          'Add relevent skills for this role',
          style: TextStyle(fontSize: sw * 0.032, color: subtitleColor),
        ),
        SizedBox(height: sw * 0.03),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(sw * 0.01),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.trim().isEmpty) {
                return const Iterable<String>.empty();
              }
              final String lowerQuery = textEditingValue.text.toLowerCase();
              return _availableSkills.where((skill) {
                return !_skills.contains(skill) && skill.toLowerCase().startsWith(lowerQuery);
              });
            },
            onSelected: (String selection) {
              if (!_skills.contains(selection)) {
                setState(() {
                  _skills.add(selection);
                });
              }
              autoCompleteController?.clear();
            },
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
              autoCompleteController = textEditingController;
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                style: TextStyle(fontSize: sw * 0.038, color: textColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.add, color: textColor, size: sw * 0.05),
                  hintText: 'Type to add skills',
                  hintStyle: TextStyle(color: subtitleColor, fontSize: sw * 0.035),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: sw * 0.03),
                ),
                onSubmitted: (String value) {
                  final val = value.trim();
                  if (val.isNotEmpty && !_skills.contains(val)) {
                    setState(() {
                      _skills.add(val);
                    });
                  }
                  textEditingController.clear();
                },
              );
            },
            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.dynamicBg,
                  child: Container(
                    width: sw * 0.8,
                    constraints: BoxConstraints(maxHeight: sw * 0.5),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(sw * 0.035),
                            child: Text(
                              option,
                              style: TextStyle(color: textColor, fontSize: sw * 0.035),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_skills.isNotEmpty) ...[
          SizedBox(height: sw * 0.03),
          Wrap(
            spacing: sw * 0.025,
            runSpacing: sw * 0.025,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _skills.map((skill) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical: sw * 0.018,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: sw * 0.015),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _skills.remove(skill);
                        });
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: sw * 0.038,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRelocateField(double sw) {
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(sw, 'Are you willing to relocate ?', required: true),
        SizedBox(height: sw * 0.02),
        ..._relocateOptions.map((option) {
          final bool isSelected = _willingToRelocate == option;
          return InkWell(
            onTap: () {
              setState(() {
                _willingToRelocate = option;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sw * 0.015),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? AppColors.primary
                        : borderColor,
                    size: sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.03),
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;

    final title = widget.job['title'] ?? 'UI/UX Designer';
    final company = widget.job['company'] ?? 'Techasoft Pvt Ltd';
    final location = widget.job['location'] ?? 'Chennai, Tamilnadu';

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;
    final Color cardBg = AppColors.dynamicCardBg;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: sw * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Application Details',
          style: TextStyle(
            color: textColor,
            fontSize: sw * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: sw * 0.05,
                  right: sw * 0.05,
                  top: sw * 0.03,
                  bottom: MediaQuery.of(context).viewInsets.bottom + sh * 0.1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Applying For Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.035),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(
                          color: borderColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CompanyLogoWidget(
                            companyId: widget.job['recuriter_name']?.toString() ?? '',
                            fallbackText: widget.job['logoText']?.toString() ?? (company.isNotEmpty ? company[0].toUpperCase() : 'W'),
                            fallbackBgColor: widget.job['logoBg'] is Color ? widget.job['logoBg'] : Colors.blue.shade50,
                            fallbackTextColor: widget.job['logoColor'] is Color ? widget.job['logoColor'] : Colors.blue.shade700,
                            radius: sw * 0.06,
                          ),
                          SizedBox(width: sw * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Applying for',
                                  style: TextStyle(
                                    fontSize: sw * 0.034,
                                    color: subtitleColor,
                                  ),
                                ),
                                SizedBox(height: sw * 0.008),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: sw * 0.034,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: sw * 0.008),
                                Text(
                                  '$company  â€¢  $location',
                                  style: TextStyle(
                                    fontSize: sw * 0.034,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Select Your Resume
                    Text(
                      'Select Your resume',
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: sw * 0.05),

                    // Resume option (single card: tap to view, edit icon to replace)
                    if (_resumes.isEmpty)
                      GestureDetector(
                        onTap: _pickAndUploadResume,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: sw * 0.05),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(sw * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.upload_file_rounded,
                                  color: Colors.orange.shade800,
                                  size: sw * 0.05,
                                ),
                                SizedBox(width: sw * 0.03),
                                Expanded(
                                  child: Text(
                                    'No resume uploaded yet. Tap here to upload your resume.',
                                    style: TextStyle(
                                      fontSize: sw * 0.035,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_resumes.length, (index) {
                        final resume = _resumes[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: sw * 0.04),
                          child: Container(
                            padding: EdgeInsets.all(sw * 0.04),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7EFFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (resume['name'] != null) {
                                        _viewResume(resume['name']!);
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: sw * 0.1,
                                          height: sw * 0.1,
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/file.png',
                                            height: sw * 0.06,
                                          ),
                                        ),
                                        SizedBox(width: sw * 0.035),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getCleanResumeName(resume['name'] ?? ''),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: sw * 0.038,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              SizedBox(height: sw * 0.01),
                                              Text(
                                                '${resume['modified']}  â€¢  ${resume['size']}',
                                                style: TextStyle(
                                                  fontSize: sw * 0.032,
                                                  color: subtitleColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: sw * 0.02),
                                GestureDetector(
                                  onTap: _pickAndUploadResume,
                                  child: Container(
                                    padding: EdgeInsets.all(sw * 0.022),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x1A000000),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.primary,
                                      size: sw * 0.045,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    SizedBox(height: sw * 0.02),

                    // Expected Salary
                    _buildSalaryField(
                      sw: sw,
                      label: 'Expected Salary',
                      required: true,
                      controller: _expectedSalaryController,
                      period: _expectedSalaryPeriod,
                      dropdownKey: _expectedSalaryPeriodKey,
                      onPeriodSelected: (value) {
                        setState(() {
                          _expectedSalaryPeriod = value;
                        });
                      },
                    ),
                    SizedBox(height: sw * 0.055),

                    // Notice Period
                    _buildDropdownSelectField(
                      sw: sw,
                      label: 'Notice Period',
                      icon: Icons.calendar_month_outlined,
                      value: _noticePeriod,
                      placeholder: 'Select Notice Period',
                      dropdownKey: _noticePeriodKey,
                      options: _noticePeriodOptions,
                      onSelected: (value) {
                        setState(() {
                          _noticePeriod = value;
                        });
                      },
                    ),
                    SizedBox(height: sw * 0.055),

                    // Current Salary (CTC) - Optional, no asterisk
                    _buildSalaryField(
                      sw: sw,
                      label: 'Current Salary ( CTC )',
                      required: false,
                      controller: _currentSalaryController,
                      period: _currentSalaryPeriod,
                      dropdownKey: _currentSalaryPeriodKey,
                      onPeriodSelected: (value) {
                        setState(() {
                          _currentSalaryPeriod = value;
                        });
                      },
                    ),
                    SizedBox(height: sw * 0.055),

                    // Total Experience
                    _buildDropdownSelectField(
                      sw: sw,
                      label: 'Total Experience',
                      icon: Icons.business_center_outlined,
                      value: _totalExperience,
                      placeholder: 'Select Experience',
                      dropdownKey: _totalExperienceKey,
                      options: _experienceOptions,
                      onSelected: (value) {
                        setState(() {
                          _totalExperience = value;
                        });
                      },
                    ),
                    SizedBox(height: sw * 0.055),

                    // Skills
                    _buildSkillsField(sw),
                    SizedBox(height: sw * 0.055),

                    // Are you willing to relocate?
                    _buildRelocateField(sw),
                    SizedBox(height: sw * 0.08),
                  ],
                ),
              ),
            ),

            // Sticky Submit Application Button (positioned static at bottom of Stack)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: bgColor,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sw * 0.05,
                ),
                child: SizedBox(
                  height: sh * 0.06,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_resumes.isEmpty ||
                          _selectedResumeIndex >= _resumes.length) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please upload a resume first.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (_expectedSalaryController.text.trim().isEmpty ||
                          _noticePeriod == null ||
                          _totalExperience == null ||
                          _skills.isEmpty ||
                          _willingToRelocate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill in all required fields.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final int? userId = await _getValidUserId();
                        if (userId == null) return;

                        final List<String> skillIds = [];
                        for (final s in _skills) {
                          if (_skillNameToId.containsKey(s) && _skillNameToId[s]!.isNotEmpty) {
                            skillIds.add(_skillNameToId[s]!);
                          } else {
                            skillIds.add(s); // custom skills without ID
                          }
                        }

                        final response = await ApplyJobApi.applyJob(
                          jobId: (widget.job['id'] ?? '').toString(),
                          applyBy: userId.toString(),
                          name: _profileName,
                          email: _profileEmail,
                          mobileNo: _profileMobile,
                          location: (widget.job['location'] ?? '')
                              .toString()
                              .toUpperCase(),
                          highQualify: _profileHighQualify,
                          skills: skillIds.join(','),
                          experience: _totalExperience ?? '',
                          currentCompany: _profileCompany,
                          currentSalary:
                              _currentSalaryController.text.trim().replaceAll(
                                    ',',
                                    '',
                                  ),
                          expectedSalary: _expectedSalaryController.text
                              .trim()
                              .replaceAll(',', ''),
                          noticePeriod: _noticePeriod ?? '',
                          resume: _resumeName,
                          portfolio: _portfolioController.text.trim(),
                          gender: _profileGender,
                          photo: _profilePhoto,
                          language: _profileLanguage,
                          education: _profileEducation,
                          relocate: _normalizeRelocate(_willingToRelocate),
                        );

                        if (response['status'] == 'success' ||
                            response['error'] == false) {
                          final prefs = await SharedPreferences.getInstance();
                          final int? currUserId = await _getValidUserId();
                          final String suffix = currUserId != null ? '_$currUserId' : '_guest';
                          final List<String> applied = prefs.getStringList('applied_job_ids$suffix') ?? [];
                          final List<String> appliedData = prefs.getStringList('applied_jobs_data$suffix') ?? [];
                          final String jobIdStr = (widget.job['id'] ?? '').toString();
                          if (!applied.contains(jobIdStr)) {
                            applied.add(jobIdStr);
                            
                            final cleanJob = Map<String, dynamic>.from(widget.job);
                            if (cleanJob['logoBg'] is Color) {
                              cleanJob['logoBg'] = (cleanJob['logoBg'] as Color).toARGB32();
                            }
                            if (cleanJob['logoColor'] is Color) {
                              cleanJob['logoColor'] = (cleanJob['logoColor'] as Color).toARGB32();
                            }
                            appliedData.add(json.encode(cleanJob));
                            
                            await prefs.setStringList('applied_job_ids$suffix', applied);
                            await prefs.setStringList('applied_jobs_data$suffix', appliedData);
                          }
                          ApplyJobApi.addAppliedJobId(jobIdStr);

                          if (mounted) {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                child: AppliedSuccessfullyScreen(job: widget.job),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response['message'] ??
                                      'Failed to submit application',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error submitting application: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Submit Application',
                      style: TextStyle(
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading || _isUploading)
              Container(
                color: Colors.black.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class IndianCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (cleanDigits.length > 10) {
      cleanDigits = cleanDigits.substring(0, 10);
    }

    final formattedText = _formatIndianCurrency(cleanDigits);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatIndianCurrency(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    final remaining = digits.substring(0, digits.length - 3);

    final StringBuffer buffer = StringBuffer();
    int count = 0;
    for (int i = remaining.length - 1; i >= 0; i--) {
      if (count > 0 && count % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
      count++;
    }

    final reversedRemaining = buffer.toString().split('').reversed.join('');
    return '$reversedRemaining,$lastThree';
  }
}


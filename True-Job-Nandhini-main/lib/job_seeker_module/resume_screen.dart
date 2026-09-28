import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truejobs/common_screens/unified_login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_save_button.dart';
import 'package:truejobs/widgets/success_popup.dart';
import 'package:truejobs/services/api/profile_select_api.dart';
import 'package:truejobs/services/api/profile_update_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'resume_preview_page.dart';
import '../utils/smooth_page_route.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  bool _isUploading = false;
  bool _hasUploaded = false;
  bool _isLoading = false;
  PlatformFile? _uploadedFile;
  String _serverResumeName = '';

  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();

  // Cached profile details to preserve on update
  String _profileName = '';
  String _profileMobile = '';
  String _profileEmail = '';
  String _profileDob = '';
  String _profileGender = '';
  String _profilePC = '';
  String _profileCondType = '';
  String _profileAffectArea = '';

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  @override
  void dispose() {
    _linkedinController.dispose();
    _portfolioController.dispose();
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
          SmoothPageRoute(child: const UnifiedLoginScreen()),
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

      final res = await ProfileSelectApi.fetchProfile(userId: userId);
      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          setState(() {
            _profileName = data['name']?.toString() ?? '';
            _profileMobile = data['mobile']?.toString() ?? '';
            _profileEmail = data['email']?.toString() ?? '';
            _profileDob = data['dob']?.toString() ?? '';
            _profileGender = data['gender']?.toString() ?? '';
            _profilePC = data['physical_challenge']?.toString() ?? '';
            _profileCondType = data['cond_type']?.toString() ?? '';
            _profileAffectArea = data['affect_area']?.toString() ?? '';

            _linkedinController.text = (data['linkedin']?.toString() ?? '')
                .trim();
            _portfolioController.text = (data['portfolio']?.toString() ?? '')
                .trim();

            final String resumeName = data['resume']?.toString() ?? '';
            _serverResumeName = resumeName;
            if (resumeName.isNotEmpty) {
              _hasUploaded = true;
              _loadLocalResumeFile(resumeName);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadLocalResumeFile(String filename) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final String cleanFilename = filename.split('/').last;
      final localFile = File('${appDocDir.path}/$cleanFilename');
      if (await localFile.exists()) {
        final size = await localFile.length();
        setState(() {
          _uploadedFile = PlatformFile(
            name: cleanFilename,
            size: size,
            path: localFile.path,
          );
        });
      } else {
        setState(() {
          _uploadedFile = PlatformFile(name: cleanFilename, size: 0, path: null);
        });
      }
    } catch (e) {
      debugPrint('Error locating local resume file: $e');
    }
  }

  Future<void> _handleUpload() async {
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

        // Simulate a short processing delay
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          setState(() {
            _uploadedFile = PlatformFile(
              name: pickedFile.name,
              size: pickedFile.size,
              path: localPath,
              bytes: pickedFile.bytes,
            );
            _isUploading = false;
            _hasUploaded = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _handleView() {
    if (_uploadedFile == null) return;

    if (_uploadedFile!.path != null) {
      Navigator.push(
        context,
        SmoothPageRoute(
          child: ResumePreviewPage(
            file: File(_uploadedFile!.path!),
            title: _uploadedFile!.name.split('/').last,
          ),
        ),
      );
    } else if (_serverResumeName.isNotEmpty) {
      String downloadUrl = _serverResumeName;
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

      Navigator.push(
        context,
        SmoothPageRoute(
          child: ResumePreviewPage(
            url: encodedUrl,
            title: _serverResumeName.split('/').last,
          ),
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

  Future<void> _saveResumeAndProfile() async {
    String? resumeNameToSend;
    if (_uploadedFile != null) {
      resumeNameToSend = _uploadedFile!.name;
    } else if (_serverResumeName.isNotEmpty) {
      resumeNameToSend = _serverResumeName;
    }

    if (resumeNameToSend == null || resumeNameToSend.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume is mandatory. Please upload your resume.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();

      // 1. Fetch latest profile details to avoid overwriting them
      String name = _profileName;
      String mobile = _profileMobile;
      String email = _profileEmail;
      String dob = _profileDob;
      String gender = _profileGender;
      String physicalChallenge = _profilePC;
      String condType = _profileCondType;
      String affectArea = _profileAffectArea;

      try {
        final profileRes = await ProfileSelectApi.fetchProfile(userId: userId);
        if (profileRes['status'] == 'success' || profileRes['error'] == false) {
          final data = profileRes['data'];
          if (data != null && data is Map<String, dynamic>) {
            name = data['name']?.toString() ?? name;
            mobile = data['mobile']?.toString() ?? mobile;
            email = data['email']?.toString() ?? email;
            dob = data['dob']?.toString() ?? dob;
            gender = data['gender']?.toString() ?? gender;
            physicalChallenge =
                data['physical_challenge']?.toString() ?? physicalChallenge;
            condType = data['cond_type']?.toString() ?? condType;
            affectArea = data['affect_area']?.toString() ?? affectArea;
          }
        }
      } catch (_) {}

      // 3. Submit profile updates with filename
      final updateRes = await ProfileUpdateApi.updateProfile(
        userId: userId,
        name: name,
        mobile: mobile,
        email: email,
        dob: dob,
        gender: _normalizeGender(gender),
        physicalChallenge: _normalizePhysicalChallenge(physicalChallenge),
        condType: condType,
        affectArea: affectArea,
        resume: resumeNameToSend,
        linkedin: _linkedinController.text.trim().isEmpty
            ? ' '
            : _linkedinController.text.trim(),
        portfolio: _portfolioController.text.trim().isEmpty
            ? ' '
            : _portfolioController.text.trim(),
        resumeFile: _uploadedFile != null && _uploadedFile!.path != null
            ? File(_uploadedFile!.path!)
            : null,
      );

      if (updateRes['status'] == 'success' || updateRes['error'] == false) {
        String finalResumeValue = resumeNameToSend;
        if (updateRes['data'] != null && updateRes['data'] is Map && updateRes['data']['resume'] != null) {
          final returnedResume = updateRes['data']['resume'].toString();
          if (returnedResume.isNotEmpty) {
            finalResumeValue = returnedResume;
          }
        }
        if (finalResumeValue.isNotEmpty) {
          await prefs.setString('resume', finalResumeValue);
          _serverResumeName = finalResumeValue;
        }
        await prefs.setString('linkedin', _linkedinController.text.trim());
        await prefs.setString('portfolio', _portfolioController.text.trim());
        if (mounted) {
          showSuccessPopup(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updateRes['message'] ?? 'Failed to save profile details',
              ),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving resume profile details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
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

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller,
      double screenWidth,
      Color textColor,
      Color subtitleColor,
      Color borderColor, {
        Widget? subLabel,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (subLabel != null) ...[
            SizedBox(height: screenWidth * 0.005),
            subLabel,
          ],
          SizedBox(height: screenWidth * 0.02),
          TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              color: textColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.035,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: subtitleColor,
                fontSize: screenWidth * 0.035,
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
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
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
                      left: screenWidth * 0.02,
                      top: screenWidth * 0.02,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textColor,
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Bar Section
                        Container(
                          height: screenHeight * 0.01,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.01,
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.92, // 92% Progress
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
                              '92%',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Resume Upload Row
                        Row(
                          children: [
                            // Custom Document Icon
                            Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.015,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.005,
                                    vertical: screenWidth * 0.002,
                                  ),
                                  color: Colors.orange,
                                  child: Text(
                                    'Resume',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.018,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),

                            Expanded(
                              child: Text(
                                _hasUploaded && _uploadedFile != null
                                    ? 'Uploaded: ${_getCleanResumeName(_uploadedFile!.name)}'
                                    : 'If you have a resume , upload it\nhere',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),

                            SizedBox(width: screenWidth * 0.02),

                            // Upload / View Button
                            SizedBox(
                              height: screenHeight * 0.045,
                              child: OutlinedButton(
                                onPressed: _isUploading
                                    ? null
                                    : (_hasUploaded
                                    ? _handleView
                                    : _handleUpload),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.06,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                  ),
                                ),
                                child: _isUploading
                                    ? SizedBox(
                                  width: screenWidth * 0.04,
                                  height: screenWidth * 0.04,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                                    : Text(
                                  _hasUploaded ? 'View' : 'Upload',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // Section Title
                        Text(
                          'Social Links & Resume',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Form Fields
                        _buildTextField(
                          'LinkedIn (optional)',
                          'Enter Link Address',
                          _linkedinController,
                          screenWidth,
                          textColor,
                          subtitleColor,
                          borderColor,
                        ),

                        _buildTextField(
                          'Portfolio (Optional)',
                          'Enter Portfolio Link Address',
                          _portfolioController,
                          screenWidth,
                          textColor,
                          subtitleColor,
                          borderColor,
                          subLabel: Text(
                            '(For Tech/Design Roles)',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: CustomSaveButton(onPressed: _saveResumeAndProfile),
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
    );
  }
}
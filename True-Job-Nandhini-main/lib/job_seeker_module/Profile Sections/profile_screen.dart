import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/api/profile_select_api.dart';
import '../../services/api/profile_update_api.dart';
import '../../services/api/profile_image_remove_api.dart';
import '../../services/api/experience_select_api.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import '../Jobs Sections/jobs_screen.dart';
import '../Walkin Sections/jobs_applied_screen.dart';
import 'personal_details_screen.dart';
import 'settings_screen.dart';
import 'qualifications_detail_screen.dart';
import 'job_preferences_screen.dart';
import '../resume_preview_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _bottomNavIndex =
  3; // Active tab in custom bottom bar is "Profile" (index 3)
  String _name = '';
  String _headline = '';
  String _company = '';
  String _profileImageUrl = '';
  String _profilePicPath = '';
  String _resumeName = '';
  String _resumeSubtitle = 'Update your resume';
  String _linkedin = '';
  String _portfolio = '';
  String _mobile = '';
  String _email = '';
  bool _isActive = true;

  // NEW: inline-editing state for social links
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  bool _isEditingLinkedin = false;
  bool _isEditingPortfolio = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _linkedinController.dispose(); // NEW
    _portfolioController.dispose(); // NEW
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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const RoleSelectionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 0),
            reverseTransitionDuration: const Duration(milliseconds: 0),
          ),
          (route) => false,
        );
      }
      return null;
    }
    return userId;
  }

  Future<void> _loadProfileData() async {
    final int? userId = await _getValidUserId();

    // 1. Load from SharedPreferences first for instant display
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final bool isDeleted = prefs.getBool('profile_photo_deleted') ?? false;
      final bool youHaveExp = (userId != null ? prefs.getBool('user_${userId}_you_have_experience') : null) ?? prefs.getBool('you_have_experience') ?? false;
      final String cachedJobTitle = (userId != null ? prefs.getString('user_${userId}_job_title') : null) ?? prefs.getString('job_title') ?? '';
      final String cachedCompany = (userId != null ? prefs.getString('user_${userId}_company_name') : null) ?? prefs.getString('company_name') ?? '';

      setState(() {
        _name = prefs.getString('name') ?? '';
        _mobile = prefs.getString('mobile') ?? '';
        _email = prefs.getString('email') ?? '';
        _profileImageUrl = isDeleted
            ? ''
            : (prefs.getString('profile_image_url') ?? '');
        _profilePicPath = isDeleted
            ? ''
            : (prefs.getString('profile_pic_path') ?? '');
        _resumeName = prefs.getString('resume') ?? '';
        _linkedin = prefs.getString('linkedin') ?? '';
        _portfolio = prefs.getString('portfolio') ?? '';

        if (youHaveExp) {
          _headline = cachedJobTitle.isNotEmpty
              ? cachedJobTitle
              : 'Experienced Professional';
          _company = cachedCompany;
        } else {
          _headline = 'Fresher';
          _company = '';
        }
      });
      _updateResumeSubtitle();
    }

    if (userId == null) return;

    // 2. Fetch profile from select API
    try {
      final res = await ProfileSelectApi.fetchProfile(userId: userId);
      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          final fetchedName = data['name']?.toString() ?? '';
          final fetchedPhoto =
              (data['photo'] ?? data['profile_image'])?.toString() ?? '';
          final fetchedResume = data['resume']?.toString() ?? '';
          final fetchedLinkedin = data['linkedin']?.toString() ?? '';
          final fetchedPortfolio = data['portfolio']?.toString() ?? '';
          final fetchedMobile = data['mobile']?.toString() ?? '';
          final fetchedEmail = data['email']?.toString() ?? '';

          final String cachedImageUrl =
              prefs.getString('profile_image_url') ?? '';
          final bool serverHasPhoto = _isValidImageUrl(fetchedPhoto);

          if (mounted) {
            setState(() {
              if (fetchedName.isNotEmpty) _name = fetchedName;
              _profileImageUrl = serverHasPhoto ? fetchedPhoto : '';
              if (!serverHasPhoto) {
                _profilePicPath = '';
              } else if (fetchedPhoto != cachedImageUrl) {
                _profilePicPath = '';
              }
              _resumeName = fetchedResume;
              _linkedin = fetchedLinkedin;
              _portfolio = fetchedPortfolio;
              _mobile = fetchedMobile;
              _email = fetchedEmail;
            });
            _updateResumeSubtitle();
          }

          // Cache in SharedPreferences
          if (fetchedName.isNotEmpty) {
            await prefs.setString('name', fetchedName);
          }
          await prefs.setBool('profile_photo_deleted', !serverHasPhoto);
          if (serverHasPhoto) {
            await prefs.setString('profile_image_url', fetchedPhoto);
            if (fetchedPhoto != cachedImageUrl) {
              await prefs.setString('profile_pic_path', '');
            }
          } else {
            await prefs.setString('profile_image_url', '');
            await prefs.setString('profile_pic_path', '');
          }
          await prefs.setString('resume', fetchedResume);
          await prefs.setString('linkedin', fetchedLinkedin);
          await prefs.setString('portfolio', fetchedPortfolio);
          await prefs.setString('mobile', fetchedMobile);
          await prefs.setString('email', fetchedEmail);
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile in ProfileScreen: $e');
    }

    // 3. Fetch experience details
    try {
      final res = await ExperienceSelectApi.fetchExperienceDetails(
        name: userId.toString(),
      );
      if (res['status'] == 'success' || res['error'] == false) {
        final data = res['data'];
        if (data != null && data is Map<String, dynamic>) {
          final List<dynamic> expList = data['experiences'] ?? [];
          Map<String, dynamic>? primaryExp;
          for (var item in expList) {
            if (item is Map<String, dynamic>) {
              final String youHaveExpStr = item['you_have_experience']?.toString() ?? '0';
              if (youHaveExpStr == '1') {
                primaryExp = item;
                break;
              }
            }
          }

          final youHaveExp = primaryExp != null;
          final jobTitle = youHaveExp
              ? (primaryExp['job_title']?.toString() ?? '')
              : '';
          final companyName = youHaveExp
              ? (primaryExp['company_name']?.toString() ?? '')
              : '';

          if (mounted) {
            setState(() {
              if (youHaveExp) {
                _headline = jobTitle.isNotEmpty
                    ? jobTitle
                    : 'Experienced Professional';
                _company = companyName;
              } else {
                _headline = 'Fresher';
                _company = '';
              }
            });
          }

          await prefs.setBool('user_${userId}_you_have_experience', youHaveExp);
          await prefs.setBool('you_have_experience', youHaveExp);
          final String expId = primaryExp?['id']?.toString() ?? '';
          await prefs.setString('user_${userId}_experience_id', expId);
          await prefs.setString('experience_id', expId);
          if (youHaveExp) {
            await prefs.setString('user_${userId}_job_title', jobTitle);
            await prefs.setString('job_title', jobTitle);
            await prefs.setString('user_${userId}_company_name', companyName);
            await prefs.setString('company_name', companyName);
          } else {
            await prefs.setString('user_${userId}_job_title', '');
            await prefs.setString('job_title', '');
            await prefs.setString('user_${userId}_company_name', '');
            await prefs.setString('company_name', '');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching experience in ProfileScreen: $e');
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

  Future<void> _updateResumeSubtitle() async {
    if (_resumeName.isNotEmpty) {
      try {
        final String cleanFilename = _resumeName.split('/').last;
        final appDocDir = await getApplicationDocumentsDirectory();
        final localFile = File('${appDocDir.path}/$cleanFilename');
        if (await localFile.exists()) {
          final sizeBytes = await localFile.length();
          final stat = await localFile.stat();
          final sizeKb = (sizeBytes / 1024).toStringAsFixed(1);
          final modifiedDate =
              '${stat.modified.day}/${stat.modified.month}/${stat.modified.year}';
          if (mounted) {
            setState(() {
              _resumeSubtitle = 'Size: $sizeKb KB â€¢ Uploaded on $modifiedDate';
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _resumeSubtitle = 'Uploaded on server';
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _resumeSubtitle = 'Uploaded';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _resumeSubtitle = 'Update your resume';
        });
      }
    }
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty ||
        url.trim() == '0' ||
        url.trim() == 'null' ||
        url.trim().isEmpty) {
      return false;
    }
    final cleanUrl = url.toLowerCase();
    return cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg') ||
        cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.gif') ||
        cleanUrl.endsWith('.webp');
  }

  Future<void> _viewResume() async {
    if (_resumeName.isEmpty) return;

    final String cleanFilename = _resumeName.split('/').last;
    final appDocDir = await getApplicationDocumentsDirectory();
    final localFile = File('${appDocDir.path}/$cleanFilename');

    if (await localFile.exists()) {
      if (!mounted) return;
      _pushFade(ResumePreviewPage(file: localFile, title: cleanFilename));
    } else {
      String downloadUrl = _resumeName;
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
      _pushFade(ResumePreviewPage(url: encodedUrl, title: cleanFilename));
    }
  }

  Future<void> _updateResume() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = result.files.single;

        setState(() {
          _resumeSubtitle = 'Saving...';
        });

        // Sanitize filename to prevent backend multipart parser issues with spaces/special characters
        final String safeFilename = pickedFile.name.replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9_.]'), '');

        // Copy file to persistent App Documents Directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final String localPath = '${appDocDir.path}/$safeFilename';
        final File localFile = File(pickedFile.path!);
        await localFile.copy(localPath);

        // Fetch latest profile first to avoid overwriting other values
        final prefs = await SharedPreferences.getInstance();
        final int? userId = await _getValidUserId();
        if (userId == null) return;

        String name = _name;
        String mobile = prefs.getString('mobile') ?? '';
        String email = prefs.getString('email') ?? '';
        String dob = prefs.getString('dob') ?? '';
        String gender = prefs.getString('gender') ?? '';
        String physicalChallenge = prefs.getString('physical_challenge') ?? '';
        String condType = prefs.getString('cond_type') ?? '';
        String affectArea = prefs.getString('affect_area') ?? '';

        try {
          final profileRes = await ProfileSelectApi.fetchProfile(
            userId: userId,
          );
          if (profileRes['status'] == 'success' ||
              profileRes['error'] == false) {
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

        final String resumeUrl = safeFilename;

        final updateRes = await ProfileUpdateApi.updateProfile(
          userId: userId,
          name: name,
          mobile: mobile,
          email: email,
          dob: dob,
          gender: gender,
          physicalChallenge: physicalChallenge,
          condType: condType,
          affectArea: affectArea,
          resume: resumeUrl,
          linkedin: _linkedin,
          portfolio: _portfolio,
          resumeFile: File(localPath), // Pass the safely copied local file
        );

        if (updateRes['status'] == 'success' || updateRes['error'] == false) {
          String finalResumeValue = resumeUrl;
          if (updateRes['data'] != null &&
              updateRes['data'] is Map &&
              updateRes['data']['resume'] != null) {
            final returnedResume = updateRes['data']['resume'].toString();
            if (returnedResume.isNotEmpty) {
              finalResumeValue = returnedResume;
            }
          }
          
          // Rename the locally copied file if the server modified the file name
          if (finalResumeValue != safeFilename) {
            try {
              final String cleanFilename = finalResumeValue.split('/').last;
              final String finalPath = '${appDocDir.path}/$cleanFilename';
              final File savedLocalFile = File(localPath);
              if (await savedLocalFile.exists()) {
                await savedLocalFile.rename(finalPath);
              }
            } catch (e) {
              debugPrint('Error renaming resume locally: $e');
            }
          }

          await prefs.setString('resume', finalResumeValue);
          setState(() {
            _resumeName = finalResumeValue;
          });
          await _updateResumeSubtitle();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$safeFilename saved successfully!'),
                backgroundColor: AppColors.iconGreen,
              ),
            );
          }
        } else {
          setState(() {
            _resumeSubtitle = 'Upload failed';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updateRes['message'] ?? 'Failed to update resume',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking or uploading resume: $e');
      setState(() {
        _resumeSubtitle = 'Upload failed';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NEW: enters inline-edit mode for the given social link, prefilling the controller
  void _startEditingSocialLink(String type) {
    setState(() {
      if (type == 'linkedin') {
        _linkedinController.text = _linkedin;
        _isEditingLinkedin = true;
      } else {
        _portfolioController.text = _portfolio;
        _isEditingPortfolio = true;
      }
    });
  }

  // NEW: saves the inline-edited social link (replaces old dialog-based _editSocialLink)
  Future<void> _saveSocialLink(String type) async {
    final String newValue =
    (type == 'linkedin' ? _linkedinController.text : _portfolioController.text)
        .trim();

    setState(() {
      if (type == 'linkedin') {
        _linkedin = newValue;
        _isEditingLinkedin = false;
      } else {
        _portfolio = newValue;
        _isEditingPortfolio = false;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(type, newValue);

    // Submit update to the server
    final int? userId = await _getValidUserId();
    if (userId == null) return;
    String name = _name;
    String mobile = prefs.getString('mobile') ?? '';
    String email = prefs.getString('email') ?? '';
    String dob = prefs.getString('dob') ?? '';
    String gender = prefs.getString('gender') ?? '';
    String physicalChallenge = prefs.getString('physical_challenge') ?? '';
    String condType = prefs.getString('cond_type') ?? '';
    String affectArea = prefs.getString('affect_area') ?? '';

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

    try {
      await ProfileUpdateApi.updateProfile(
        userId: userId,
        name: name,
        mobile: mobile,
        email: email,
        dob: dob,
        gender: gender,
        physicalChallenge: physicalChallenge,
        condType: condType,
        affectArea: affectArea,
        resume: _resumeName,
        linkedin: (type == 'linkedin' ? newValue : _linkedin).trim().isEmpty
            ? ' '
            : (type == 'linkedin' ? newValue : _linkedin).trim(),
        portfolio:
        (type == 'portfolio' ? newValue : _portfolio).trim().isEmpty
            ? ' '
            : (type == 'portfolio' ? newValue : _portfolio).trim(),
      );
    } catch (e) {
      debugPrint('Error updating social link: $e');
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_profileImageUrl.isNotEmpty || _profilePicPath.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteProfileImage() async {
    try {
      final int? userId = await _getValidUserId();
      if (userId == null) return;
      final prefs = await SharedPreferences.getInstance();

      final response = await ProfileImageRemoveApi.removeProfileImage(
        userId: userId,
      );

      if (response['status'] == 'success' || response['error'] == false) {
        setState(() {
          _profilePicPath = '';
          _profileImageUrl = '';
        });

        await prefs.setString('profile_pic_path', '');
        await prefs.setString('profile_image_url', '');
        await prefs.setBool('profile_photo_deleted', true);

        // Delete the local file if exists
        final appDocDir = await getApplicationDocumentsDirectory();
        final String localPath = '${appDocDir.path}/profile_image_$userId.jpg';
        final File localFile = File(localPath);
        if (await localFile.exists()) {
          try {
            await FileImage(localFile).evict();
          } catch (_) {}
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo deleted successfully!'),
              backgroundColor: AppColors.iconGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoViewOptions() {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final bool hasImage =
        (_profilePicPath.isNotEmpty && File(_profilePicPath).existsSync()) ||
            (_profileImageUrl.isNotEmpty && _isValidImageUrl(_profileImageUrl));

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 0),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Stack(
            children: [
              // Dismiss trigger on tapping background
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular image in the center
                      Container(
                        width: sw * 0.65,
                        height: sw * 0.65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: sw * 0.32,
                          backgroundColor: Colors.grey.shade900,
                          backgroundImage:
                          (_profilePicPath.isNotEmpty &&
                              File(_profilePicPath).existsSync())
                              ? FileImage(File(_profilePicPath))
                          as ImageProvider
                              : (_profileImageUrl.isNotEmpty &&
                              _isValidImageUrl(_profileImageUrl)
                              ? NetworkImage(
                            _profileImageUrl.startsWith('http')
                                ? _profileImageUrl
                                : (_profileImageUrl.startsWith(
                              '/',
                            )
                                ? 'https://truejobs.in$_profileImageUrl'
                                : 'https://truejobs.in/$_profileImageUrl'),
                          )
                          as ImageProvider
                              : null),
                          child:
                          ((_profilePicPath.isEmpty ||
                              !File(_profilePicPath).existsSync()) &&
                              (_profileImageUrl.isEmpty ||
                                  !_isValidImageUrl(_profileImageUrl)))
                              ? Icon(
                            Icons.person,
                            size: sw * 0.35,
                            color: Colors.grey.shade600,
                          )
                              : null,
                        ),
                      ),
                      SizedBox(height: sw * 0.12),
                      // Actions Row below the image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Upload button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _pickAndUploadImage();
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: sw * 0.15,
                                  height: sw * 0.15,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Upload Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasImage) ...[
                            SizedBox(width: sw * 0.15),
                            // Delete button
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _deleteProfileImage();
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: sw * 0.15,
                                    height: sw * 0.15,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Delete Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: sw * 0.1),
                      // Tap hint
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap background to close',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        // Add a small delay to avoid onActivityResult race conditions on Android
        await Future.delayed(const Duration(milliseconds: 500));
        
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Profile Image',
                toolbarColor: AppColors.primary,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: false,
                cropStyle: CropStyle.circle,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]),
            IOSUiSettings(
              title: 'Crop Profile Image',
              cropStyle: CropStyle.circle,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
            ),
          ],
        );
        if (croppedFile == null) return;
        final String finalImagePath = croppedFile.path;

        final prefs = await SharedPreferences.getInstance();
        final int? userId = await _getValidUserId();
        if (userId == null) return;

        // Fetch latest profile details to preserve all other fields on update
        String name = _name;
        String mobile = prefs.getString('mobile') ?? '';
        String email = prefs.getString('email') ?? '';
        String dob = prefs.getString('dob') ?? '';
        String gender = prefs.getString('gender') ?? '';
        String physicalChallenge = prefs.getString('physical_challenge') ?? '';
        String condType = prefs.getString('cond_type') ?? '';
        String affectArea = prefs.getString('affect_area') ?? '';
        String resume = _resumeName;
        String linkedin = _linkedin;
        String portfolio = _portfolio;

        try {
          final profileRes = await ProfileSelectApi.fetchProfile(
            userId: userId,
          );
          if (profileRes['status'] == 'success' ||
              profileRes['error'] == false) {
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
              resume = data['resume']?.toString() ?? resume;
              linkedin = data['linkedin']?.toString() ?? linkedin;
              portfolio = data['portfolio']?.toString() ?? portfolio;
            }
          }
        } catch (_) {}

        final response = await ProfileUpdateApi.updateProfile(
          userId: userId,
          name: name,
          mobile: mobile,
          email: email,
          dob: dob,
          gender: gender,
          physicalChallenge: physicalChallenge,
          condType: condType,
          affectArea: affectArea,
          resume: resume,
          linkedin: linkedin,
          portfolio: portfolio,
          profileImage: File(finalImagePath),
        );

        if (response['status'] == 'success' || response['error'] == false) {
          final appDocDir = await getApplicationDocumentsDirectory();
          final String localPath =
              '${appDocDir.path}/profile_image_$userId.jpg';

          try {
            await FileImage(File(finalImagePath)).evict();
            await FileImage(File(localPath)).evict();
          } catch (_) {}

          final File savedFile = await File(finalImagePath).copy(localPath);

          try {
            await FileImage(savedFile).evict();
          } catch (_) {}

          await prefs.setString('profile_pic_path', savedFile.path);
          await prefs.setBool('profile_photo_deleted', false);

          final data = response['data'];
          String imageUrl = '';
          if (data != null && data is Map) {
            imageUrl =
                (data['photo'] ?? data['profile_image'])?.toString() ?? '';
            if (imageUrl.isNotEmpty) {
              await prefs.setString('profile_image_url', imageUrl);
              await prefs.setBool('profile_photo_deleted', false);
            }
          }

          setState(() {
            _profilePicPath = savedFile.path;
            if (imageUrl.isNotEmpty) {
              _profileImageUrl = imageUrl;
            }
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile photo updated successfully!'),
                backgroundColor: AppColors.iconGreen,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Failed to upload photo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking or uploading profile photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<T?> _pushFade<T>(Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 0),
        reverseTransitionDuration: const Duration(milliseconds: 0),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      // Pop back to home
      Navigator.of(context).pop();
    } else if (index == 1) {
      // Navigate to JobsScreen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const JobsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 0),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        ),
      );
    } else if (index == 2) {
      // Navigate to Applied/My Jobs Screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MyJobsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 0),
          reverseTransitionDuration: const Duration(milliseconds: 0),
        ),
      );
    } else {
      setState(() {
        _bottomNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfileData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top AppBar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sw * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: textColor,
                              size: sw * 0.05,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: sw * 0.01),
                          Text(
                            'My Profile',
                            style: TextStyle(
                              color: textColor,
                              fontSize: sw * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _pushFade(const SettingsScreen());
                        },
                        child: Image.asset('assets/image/settings.png', height: sw * 0.07,)
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.04),

                // Centered Profile Avatar Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _showPhotoViewOptions,
                            child: Container(
                              width: sw * 0.24,
                              height: sw * 0.24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.iconGreen,
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: sw * 0.12,
                                backgroundColor: cardBg,
                                backgroundImage:
                                (_profilePicPath.isNotEmpty &&
                                    File(_profilePicPath).existsSync())
                                    ? FileImage(File(_profilePicPath))
                                as ImageProvider
                                    : (_profileImageUrl.isNotEmpty &&
                                    _isValidImageUrl(_profileImageUrl)
                                    ? NetworkImage(
                                  _profileImageUrl.startsWith(
                                    'http',
                                  )
                                      ? _profileImageUrl
                                      : (_profileImageUrl
                                      .startsWith('/')
                                      ? 'https://truejobs.in$_profileImageUrl'
                                      : 'https://truejobs.in/$_profileImageUrl'),
                                )
                                as ImageProvider
                                    : null),
                                child:
                                ((_profilePicPath.isEmpty ||
                                    !File(
                                      _profilePicPath,
                                    ).existsSync()) &&
                                    (_profileImageUrl.isEmpty ||
                                        !_isValidImageUrl(
                                          _profileImageUrl,
                                        )))
                                    ? Icon(
                                  Icons.person,
                                  size: sw * 0.16,
                                  color: AppColors.grey,
                                )
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: CircleAvatar(
                                radius: sw * 0.035,
                                backgroundColor: AppColors.iconGreen,
                                child: Icon(
                                  Icons.add,
                                  size: sw * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.03),
                      GestureDetector(
                        onTap: () async {
                          final result = await _pushFade(
                            PersonalDetailsScreen(
                              initialName: _name,
                              initialHeadline: _headline,
                              initialPhone: _mobile,
                              initialEmail: _email,
                            ),
                          );
                          if (result != null && result is Map<String, String>) {
                            final String newName = result['name'] ?? _name;
                            final String newHeadline =
                                result['headline'] ?? _headline;
                            final String newPhone = result['phone'] ?? _mobile;
                            final String newEmail = result['email'] ?? _email;
                            setState(() {
                              _name = newName;
                              _headline = newHeadline;
                              _mobile = newPhone;
                              _email = newEmail;
                            });
                            // Save locally and update server
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('name', newName);
                            await prefs.setString('job_title', newHeadline);
                            await prefs.setString('mobile', newPhone);
                            await prefs.setString('email', newEmail);

                            final int? userId = await _getValidUserId();
                            if (userId == null) return;
                            try {
                              // Fetch latest profile first to keep other properties intact
                              final profileRes =
                              await ProfileSelectApi.fetchProfile(
                                userId: userId,
                              );
                              if (profileRes['status'] == 'success' ||
                                  profileRes['error'] == false) {
                                final data = profileRes['data'];
                                if (data != null &&
                                    data is Map<String, dynamic>) {
                                  final dob = data['dob']?.toString() ?? '';
                                  final gender =
                                      data['gender']?.toString() ?? '';
                                  final physicalChallenge =
                                      data['physical_challenge']?.toString() ??
                                          '';
                                  final condType =
                                      data['cond_type']?.toString() ?? '';
                                  final affectArea =
                                      data['affect_area']?.toString() ?? '';
                                  final resume =
                                      data['resume']?.toString() ?? '';
                                  final linkedin =
                                      data['linkedin']?.toString() ?? '';
                                  final portfolio =
                                      data['portfolio']?.toString() ?? '';

                                  await ProfileUpdateApi.updateProfile(
                                    userId: userId,
                                    name: newName,
                                    mobile: newPhone,
                                    email: newEmail,
                                    dob: dob,
                                    gender: gender,
                                    physicalChallenge: physicalChallenge,
                                    condType: condType,
                                    affectArea: affectArea,
                                    resume: resume,
                                    linkedin: linkedin,
                                    portfolio: portfolio,
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                'Error updating profile from PersonalDetails: $e',
                              );
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _name,
                              style: TextStyle(
                                fontSize: sw * 0.052,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(width: sw * 0.01),
                            Icon(
                              Icons.edit,
                              color: subtitleColor,
                              size: sw * 0.045,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sw * 0.01),
                      Text(
                        _headline,
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: subtitleColor,
                        ),
                      ),

                      if (_company.isNotEmpty)
                        Text(
                          _company,
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            color: subtitleColor,
                          ),
                        ),
                      SizedBox(height: sw * 0.04),
                      // Actively job hunting badge
                      GestureDetector(
                        onTap: () => _showStatusBottomSheet(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.05,
                            vertical: sw * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(sw * 0.05),
                          ),
                          child: Text(
                            _isActive ? 'â€¢ Active' : 'â€¢ Inactive',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.06),

                // Qualifications & Job Preferences Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pushFade(const QualificationsDetailScreen());
                          _loadProfileData();
                        },
                        child: _buildSelectionCard(
                          'Qualifications',
                          'Your Skills & Achievements',
                          sw,
                        ),
                      ),
                      SizedBox(height: sw * 0.03),
                      GestureDetector(
                        onTap: () {
                          _pushFade(const JobPreferencesScreen());
                        },
                        child: _buildSelectionCard(
                          'Job preferences',
                          'Tailor your job search',
                          sw,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.06),

                // Resume Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: GestureDetector(
                    onTap: _viewResume,
                    child: Container(
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF5FF),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Resume',
                                style: TextStyle(
                                  fontSize: sw * 0.042,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: _updateResume,
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: sw * 0.038,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.04),
                          Row(
                            children: [
                              Image.asset(
                                'assets/file.png',
                                width: sw * 0.12,
                                height: sw * 0.12,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      padding: EdgeInsets.all(sw * 0.02),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade400,
                                        borderRadius: BorderRadius.circular(
                                          sw * 0.02,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.insert_drive_file,
                                        color: Colors.white,
                                        size: sw * 0.08,
                                      ),
                                    ),
                              ),
                              SizedBox(width: sw * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _resumeName.isNotEmpty
                                          ? _getCleanResumeName(_resumeName)
                                          : 'No resume uploaded',
                                      style: TextStyle(
                                        fontSize: sw * 0.038,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: sw * 0.005),
                                    Text(
                                      _resumeSubtitle,
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
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.06),

                // Social Links Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Text(
                    'Social links',
                    style: TextStyle(
                      fontSize: sw * 0.048,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Column(
                    children: [
                      // NEW: inline-editable LinkedIn field (no more AlertDialog)
                      _buildSocialLinkInput(
                        'LinkedIn (optional)',
                        _linkedin.trim().isNotEmpty
                            ? _linkedin.trim()
                            : 'Not Provided',
                        sw,
                        isEditing: _isEditingLinkedin,
                        controller: _linkedinController,
                        onEditTap: () => _startEditingSocialLink('linkedin'),
                        onSave: () => _saveSocialLink('linkedin'),
                      ),
                      SizedBox(height: sw * 0.03),
                      // NEW: inline-editable Portfolio field (no more AlertDialog)
                      _buildSocialLinkInput(
                        'Portfolio (optional)\n(For Tech/Design Roles)',
                        _portfolio.trim().isNotEmpty
                            ? _portfolio.trim()
                            : 'Not Provided',
                        sw,
                        isEditing: _isEditingPortfolio,
                        controller: _portfolioController,
                        onEditTap: () => _startEditingSocialLink('portfolio'),
                        onSave: () => _saveSocialLink('portfolio'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.08),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
        profileImageUrl: _profileImageUrl,
        profilePicPath: _profilePicPath,
      ),
    );
  }

  Widget _buildSelectionCard(String title, String subtitle, double sw) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sw * 0.045,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: sw * 0.005),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: sw * 0.045,
            color: subtitleColor,
          ),
        ],
      ),
    );
  }

  // UPDATED: now supports inline editing instead of opening a dialog.
  // When isEditing is true, the placeholder Text is swapped for a live TextField,
  // and the edit icon becomes a check icon that saves the value.
  Widget _buildSocialLinkInput(
      String title,
      String placeholder,
      double sw, {
        required bool isEditing,
        required TextEditingController controller,
        required VoidCallback onEditTap,
        required VoidCallback onSave,
      }) {
    final Color cardBg = AppColors.dynamicCardBg;
    final Color subtitleColor = AppColors.dynamicSubtitle;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.03),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: isEditing ? AppColors.primary : AppColors.dynamicBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: sw * 0.005),
                isEditing
                    ? TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Enter URL',
                  ),
                  onSubmitted: (_) => onSave(),
                )
                    : Text(
                  placeholder,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isEditing ? onSave : onEditTap,
            child: Icon(
              isEditing ? Icons.check : Icons.edit_square,
              color: isEditing ? AppColors.primary : subtitleColor,
              size: sw * 0.055,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    bool tempIsActive = _isActive;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;
    final Color cardBg = AppColors.dynamicCardBg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                sw * 0.05,
                sw * 0.05,
                sw * 0.05,
                MediaQuery.of(context).viewInsets.bottom + sw * 0.06,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile settings',
                          style: TextStyle(
                            color: textColor,
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                            color: textColor,
                            size: sw * 0.06,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.05),

                    // Active Option Card
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          tempIsActive = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sw * 0.04),
                        padding: EdgeInsets.all(sw * 0.04),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(sw * 0.03),
                          border: Border.all(
                            color: tempIsActive
                                ? AppColors.primary
                                : borderColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      size: sw * 0.055,
                                      color: textColor,
                                    ),
                                    SizedBox(width: sw * 0.025),
                                    Text(
                                      'When Status is Active',
                                      style: TextStyle(
                                        fontSize: sw * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Radio<bool>(
                                  value: true,
                                  groupValue: tempIsActive,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempIsActive = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: sw * 0.02),
                            Text(
                              'Your profile will be visible to employers. They can view your profile and contact you for relevant job opportunities.',
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                color: subtitleColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Inactive Option Card
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          tempIsActive = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sw * 0.06),
                        padding: EdgeInsets.all(sw * 0.04),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(sw * 0.03),
                          border: Border.all(
                            color: !tempIsActive
                                ? AppColors.primary
                                : borderColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_off_outlined,
                                      size: sw * 0.055,
                                      color: textColor,
                                    ),
                                    SizedBox(width: sw * 0.025),
                                    Text(
                                      'When Status is Inactive',
                                      style: TextStyle(
                                        fontSize: sw * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Radio<bool>(
                                  value: false,
                                  groupValue: tempIsActive,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setModalState(() {
                                      tempIsActive = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: sw * 0.02),
                            Text(
                              "Your profile will be hidden from employers. They won't be able to view your profile or contact you until you activate it again.",
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                color: subtitleColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Save button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isActive = tempIsActive;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        height: sw * 0.13,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:truejobs/common_screens/unified_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truejobs/job_seeker_module/Profile%20Sections/about_us_screen.dart';
import 'package:truejobs/job_seeker_module/Profile%20Sections/settings_screen.dart';
import 'package:truejobs/job_seeker_module/jobs_search_screen.dart';
import 'package:truejobs/resume_sections/create_cv_screen.dart';
import '../../constants/app_colors.dart';
import '../../widgets/logout_popup.dart';
import '../../widgets/guest_popup.dart';
import '../../services/api/profile_select_api.dart';
import '../../services/api/profile_update_api.dart';
import '../../services/api/profile_image_remove_api.dart';
import '../Walkin Sections/jobs_applied_screen.dart';
import '../../widgets/language.dart';
import '../jobs_picked_screen.dart';
import '../Profile Sections/profile_screen.dart';
import 'my_coins_screen.dart';
import 'refer_and_earn_screen.dart';

class DrawersScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;
  const DrawersScreen({super.key, this.onProfileUpdated});

  @override
  State<DrawersScreen> createState() => _DrawersScreenState();
}

class _DrawersScreenState extends State<DrawersScreen> {
  bool _isGuest = false;
  String _userName = '';
  String _profileImageUrl = '';
  String _profilePicPath = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<int?> _getValidUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId;
    try {
      userId = prefs.getInt('user_id');
    } catch (_) {
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
          MaterialPageRoute(builder: (_) => const UnifiedLoginScreen()),
          (route) => false,
        );
      }
      return null;
    }
    return userId;
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final bool isDeleted = prefs.getBool('profile_photo_deleted') ?? false;
      setState(() {
        _isGuest = prefs.getBool('is_guest') ?? false;
        _userName = prefs.getString('name') ?? '';
        _profileImageUrl = isDeleted
            ? ''
            : (prefs.getString('profile_image_url') ?? '');
        _profilePicPath = isDeleted
            ? ''
            : (prefs.getString('profile_pic_path') ?? '');
      });
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

  void _showPhotoViewOptions() async {
    if (await checkAndShowGuestPopup(context)) return;
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
      transitionDuration: const Duration(milliseconds: 200),
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

        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 30,
      );
      if (pickedFile != null) {
        final int? userId = await _getValidUserId();
        if (userId == null) return;
        final prefs = await SharedPreferences.getInstance();

        // Fetch latest profile details to preserve all other fields on update
        String name = _userName;
        String mobile = prefs.getString('mobile') ?? '';
        String email = prefs.getString('email') ?? '';
        String dob = prefs.getString('dob') ?? '';
        String gender = prefs.getString('gender') ?? '';
        String physicalChallenge = prefs.getString('physical_challenge') ?? '';
        String condType = prefs.getString('cond_type') ?? '';
        String affectArea = prefs.getString('affect_area') ?? '';
        String resume = prefs.getString('resume') ?? '';
        String linkedin = (prefs.getString('linkedin') ?? '').trim();
        String portfolio = (prefs.getString('portfolio') ?? '').trim();

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
              linkedin = (data['linkedin']?.toString() ?? '').trim();
              portfolio = (data['portfolio']?.toString() ?? '').trim();
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
          linkedin: linkedin.isEmpty ? ' ' : linkedin,
          portfolio: portfolio.isEmpty ? ' ' : portfolio,
          profileImage: File(pickedFile.path),
        );

        if (response['status'] == 'success' || response['error'] == false) {
          final appDocDir = await getApplicationDocumentsDirectory();
          final String localPath =
              '${appDocDir.path}/profile_image_$userId.jpg';

          try {
            await FileImage(File(pickedFile.path)).evict();
            await FileImage(File(localPath)).evict();
          } catch (_) {}

          final File savedFile = await File(pickedFile.path).copy(localPath);

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

          if (widget.onProfileUpdated != null) {
            widget.onProfileUpdated!();
          }
          if (mounted) {}
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color cardBg = AppColors.dynamicCardBg;

    return Drawer(
      backgroundColor: bgColor,
      width: sw * 0.8,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Drawer Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    sw * 0.05,
                    sw * 0.12,
                    sw * 0.05,
                    sw * 0.04,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(sw * 0.008),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _showPhotoViewOptions,
                              child: CircleAvatar(
                                radius: sw * 0.08,
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
                                        size: sw * 0.15,
                                        color: AppColors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  if (await checkAndShowGuestPopup(context))
                                    return;
                                  _pickAndUploadImage();
                                },
                                child: CircleAvatar(
                                  radius: sw * 0.023,
                                  backgroundColor: AppColors.secondary,
                                  child: Icon(
                                    Icons.add,
                                    size: sw * 0.03,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: sw * 0.04),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (await checkAndShowGuestPopup(context)) return;
                            if (mounted) {
                              Navigator.of(context).pop(); // Close drawer
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                              _loadProfileData();
                              if (widget.onProfileUpdated != null) {
                                widget.onProfileUpdated!();
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName.isNotEmpty ? _userName : 'User',
                                      style: TextStyle(
                                        fontSize: sw * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: sw * 0.01,),
                                    Text(
                                      'Update Your profile',
                                      style: TextStyle(
                                        fontSize: sw * 0.035,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: sw * 0.01,),
                                    if (!_isGuest) ...[
                                      Text(
                                        '90% Completed',
                                        style: TextStyle(
                                          fontSize: sw * 0.03,
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: sw * 0.04,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Color(0x44000000), thickness: 0.4),

                // Group 1
                _buildMenuItem(context, Icons.search, 'Search jobs', sw),
                _buildMenuItem(
                  context,
                  Icons.business_center_outlined,
                  'Suggested jobs for you',
                  sw,
                ),
                _buildMenuItem(context, Icons.bookmark_border, 'Saved jobs', sw),
                _buildMenuItem(
                  context,
                  Icons.send_outlined,
                  'My Applications',
                  sw,
                ),

                Divider(color: Color(0x44000000), thickness: 0.4),

                // Group 2
                _buildMenuItem(
                  context,
                  Icons.chat_outlined,
                  'My Coins',
                  sw,
                ),
                _buildMenuItem(context, Icons.language, 'Language', sw),
                _buildMenuItem(
                  context,
                  Icons.description_outlined,
                  'Resume Builder',
                  sw,
                ),
                _buildMenuItem(
                  context,
                  Icons.monetization_on_outlined,
                  'Refer & Earn',
                  sw,
                ),
                _buildMenuItem(context, Icons.info_outline, 'About us', sw),
                _buildMenuItem(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  sw,
                ),
                _isGuest
                    ? _buildMenuItem(
                        context,
                        Icons.login,
                        'Login',
                        sw,
                        isLogin: true,
                      )
                    : _buildMenuItem(
                        context,
                        Icons.logout,
                        'Logout',
                        sw,
                        isLogout: true,
                      ),
                SizedBox(height: sw * 0.03),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: sw * 0.035,
                    horizontal: sw * 0.08,
                  ),
                  color: const Color(0xFFFFECC9),
                  child: Row(
                    children: [
                      Image.asset('assets/crown-5.png', height: sw * 0.04,),
                      SizedBox(width: sw * 0.02),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFFF9D00), // #FF9D00
                            Color(0xFF995E00),
                            Color(0xFFFF9D00),// #995E00
                            Color(0xFF995E00),
                          ],
                        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: Text(
                          'True Jobs Pro',
                          style: TextStyle(
                            color: Colors.white, // Required for ShaderMask
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Banner at bottom
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    double sw, {
    bool isLogout = false,
    bool isLogin = false,
  }) {
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = Color(0xFF7C7C7C);

    final color = isLogout
        ? Colors.red.shade400
        : (isLogin ? AppColors.primary : textColor);
    final iconColor = isLogout
        ? Colors.red.shade400
        : (isLogin ? AppColors.primary : subtitleColor);

    return ListTile(
      leading: Icon(icon, color: iconColor, size: sw * 0.06),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: sw * 0.04,
          fontWeight: (isLogout || isLogin)
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 0),
      dense: true,
      onTap: () {
        if (isLogout) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const LogoutPopup();
            },
          );
        } else if (isLogin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UnifiedLoginScreen()),
            (route) => false,
          );
        } else if (title == 'My Applications') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const MyJobsScreen()));
        } else if (title == 'Saved jobs') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const MyJobsScreen(initialTab: 1)));
        } else if (title == 'Search jobs') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const JobSearchScreen()),
          );
        } else if (title == 'Suggested jobs for you') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const JobsPickedScreen()),
          );
        } else if (title == 'Refer & Earn') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ReferAndEarnScreen()),
          );
        } else if (title == 'My Coins') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MyCoinsScreen()),
          );
        } else if (title == 'About us') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AboutUsScreen()),
          );
        } else if (title == 'Settings') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        } else if (title == 'Resume Builder') {
          Navigator.of(context).pop(); // Close drawer
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateCvScreen()),
          );
        } else if (title == 'Language') {
          Navigator.of(context).pop(); // Close drawer
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => LanguageSelectionBottomSheet(
              currentLanguage: 'English',
              onLanguageSelected: (lang) {
                // Language selection handling
              },
            ),
          );
        }
      },
    );
  }
}

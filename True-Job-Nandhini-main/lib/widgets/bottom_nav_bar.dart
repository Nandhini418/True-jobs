import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../constants/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? profileImageUrl;
  final String? profilePicPath;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.profilePicPath,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String _profileImageUrl = '';
  String _profilePicPath = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    if (widget.profileImageUrl != null || widget.profilePicPath != null) {
      if (mounted) {
        setState(() {
          _profileImageUrl = widget.profileImageUrl ?? '';
          _profilePicPath = widget.profilePicPath ?? '';
        });
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final bool isDeleted = prefs.getBool('profile_photo_deleted') ?? false;
      setState(() {
        _profileImageUrl = isDeleted ? '' : (prefs.getString('profile_image_url') ?? '');
        _profilePicPath = isDeleted ? '' : (prefs.getString('profile_pic_path') ?? '');
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadProfilePic();
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty || url.trim() == '0' || url.trim() == 'null' || url.trim().isEmpty) {
      return false;
    }
    final cleanUrl = url.toLowerCase();
    return cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg') ||
        cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.gif') ||
        cleanUrl.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = AppColors.dynamicBg;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: sw * 0.02),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              imagePath: 'assets/home.png',
              label: 'Home',
              sw: sw,
            ),
            _buildNavItem(
              index: 1,
              imagePath: 'assets/jobs.png',
              label: 'Jobs',
              sw: sw,
            ),
            _buildNavItem(
              index: 2,
              imagePath: 'assets/apply.png',
              label: 'Apply',
              sw: sw,
            ),
            _buildProfileNavItem(index: 3, label: 'Profile', sw: sw),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isSelected, double sw, Color color) {
    return Container(
      width: sw * 0.2,
      height: 3,
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String imagePath,
    required String label,
    required double sw,
  }) {
    final isSelected = widget.currentIndex == index;
    final color = AppColors.primary;

    return InkWell(
      onTap: () => widget.onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: sw * 0.055,
            height: sw * 0.055,
            color: isSelected ? color : const Color(0xFFC2C1C1),
          ),
          SizedBox(height: sw * 0.01),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Color(0xFF979797),
              fontSize: sw * 0.033,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: sw * 0.015),
          _buildIndicator(isSelected, sw, color),
        ],
      ),
    );
  }

  Widget _buildProfileNavItem({
    required int index,
    required String label,
    required double sw,
  }) {
    final isSelected = widget.currentIndex == index;
    return InkWell(
      onTap: () => widget.onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Color(0xFFC2C1C1),
                width: 1.3,
              ),
            ),
            padding: const EdgeInsets.all(1.0),
            child: CircleAvatar(
              radius: sw * 0.03,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  (_profilePicPath.isNotEmpty &&
                      File(_profilePicPath).existsSync())
                  ? FileImage(File(_profilePicPath)) as ImageProvider
                  : (_profileImageUrl.isNotEmpty && _isValidImageUrl(_profileImageUrl)
                        ? NetworkImage(
                                _profileImageUrl.startsWith('http')
                                    ? _profileImageUrl
                                    : (_profileImageUrl.startsWith('/')
                                          ? 'https://truejobs.in$_profileImageUrl'
                                          : 'https://truejobs.in/$_profileImageUrl'),
                              )
                              as ImageProvider
                        : null),
              child:
                  ((_profilePicPath.isEmpty ||
                          !File(_profilePicPath).existsSync()) &&
                      (_profileImageUrl.isEmpty || !_isValidImageUrl(_profileImageUrl)))
                  ? Icon(Icons.person, size: sw * 0.04, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(height: sw * 0.01),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Color(0xFF979797),
              fontSize: sw * 0.033,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: sw * 0.015),
          _buildIndicator(isSelected, sw, AppColors.primary),
        ],
      ),
    );
  }
}

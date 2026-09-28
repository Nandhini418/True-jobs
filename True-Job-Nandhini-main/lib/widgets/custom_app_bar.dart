import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/right_side_drawer.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget {
  final bool showBackButton;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key, 
    this.showBackButton = false,
    this.backgroundColor,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _profileLetter = 'S';

  @override
  void initState() {
    super.initState();
    _loadProfileLetter();
  }

  Future<void> _loadProfileLetter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyName = prefs.getString('company_name') ?? '';
      final contactPerson = prefs.getString('contact_person') ?? prefs.getString('name') ?? '';
      
      String letter = 'S';
      if (companyName.trim().isNotEmpty) {
        letter = companyName.trim()[0].toUpperCase();
      } else if (contactPerson.trim().isNotEmpty) {
        letter = contactPerson.trim()[0].toUpperCase();
      }
      
      if (mounted) {
        setState(() {
          _profileLetter = letter;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile letter: $e');
    }
  }

  void _openDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 280.w,
            height: double.infinity,
            child: const Material(child: RightSideDrawer()),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55.h,
      margin: EdgeInsets.only(top: 32.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.dynamicBg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.showBackButton) ...[
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18.w,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 14.w),
              ],
              Image.asset(
                'assets/images/header_logo.png',
                height: 28.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Row(
            children: [
              Image.asset(
                'assets/images/appbar.png',
                height: 28.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 14.w),
              GestureDetector(
                onTap: () => _openDrawer(context),
                child: CircleAvatar(
                  radius: 16.r,
                  backgroundColor: const Color(0xFF005C62),
                  child: Text(
                    _profileLetter,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

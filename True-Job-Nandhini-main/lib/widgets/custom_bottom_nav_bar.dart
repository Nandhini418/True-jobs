import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildIcon(IconData iconData, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData,
          size: 20.w,
          color: isActive ? AppColors.primary : const Color(0xFF979797),
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF979797), width: 0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.dynamicBg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF979797),
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.work_outline),
              activeIcon: _buildIcon(Icons.work, isActive: true),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.people_outline),
              activeIcon: _buildIcon(Icons.people, isActive: true),
              label: 'Candidate',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.calendar_month_outlined),
              activeIcon: _buildIcon(Icons.calendar_today, isActive: true),
              label: 'Interviews',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.settings_outlined),
              activeIcon: _buildIcon(Icons.settings, isActive: true),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

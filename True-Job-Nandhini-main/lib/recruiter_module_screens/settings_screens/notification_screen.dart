import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool jobApplicationAlert = true;
  bool interviewReminders = true;
  bool emailNotification = true;
  bool pushNotifications = true;
  bool quietHours = false;

  String fromTime = '10:00 PM';
  String toTime = '07:00 PM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 28.h),
                  // Header Row "< Notification"
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'Notification',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFEFE),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: const Color(0xFFC4C4C4), width: 0.3),
                    ),
                    child: Column(
                      children: [
                        _buildToggleItem(
                          icon: Icons.notifications_none_outlined,
                          title: 'Job Application Alert',
                          subtitle: 'Get alerts for new applications',
                          value: jobApplicationAlert,
                          onChanged: (val) => setState(() => jobApplicationAlert = val),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.notifications_none_outlined,
                          title: 'Interview Reminders',
                          subtitle: 'Receive interview reminders',
                          value: interviewReminders,
                          onChanged: (val) => setState(() => interviewReminders = val),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.notifications_none_outlined,
                          title: 'Email Notification',
                          subtitle: 'Receive Notification via email',
                          value: emailNotification,
                          onChanged: (val) => setState(() => emailNotification = val),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.notifications_none_outlined,
                          title: 'Push Notifications',
                          subtitle: 'Receive Push Notification on device',
                          value: pushNotifications,
                          onChanged: (val) => setState(() => pushNotifications = val),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFEFE),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: const Color(0xFFC4C4C4), width: 0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(14.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quiet Hours',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Do not disturb during selected time',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: quietHours,
                                  onChanged: (val) => setState(() => quietHours = val),
                                  // ON State
                                  activeTrackColor: const Color(0xFF3183FF), // Track
                                  activeColor: Colors.white,                 // Thumb
                                  activeThumbColor: Colors.white,            // Thumb
                                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                                        (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return const Color(0xFF92B0FF); // ON Border
                                      }
                                      return const Color(0xFFC1C1C1); // OFF Border
                                    },
                                  ),
                                  trackOutlineWidth: WidgetStateProperty.all(0.52),

                                  // OFF State
                                  inactiveTrackColor: const Color(0xFF757171), // Track
                                  inactiveThumbColor: Colors.white,            // Thumb
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildDivider(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                          child: Row(
                            children: [
                              Text(
                                'From',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(width: 11.w),
                              _buildTimeDropdown(fromTime, (val) => setState(() => fromTime = val!)),
                              SizedBox(width: 11.w),
                              Container(
                                height: 25.h,
                                width: 1,
                                color: const Color(0xFFC0C0C0),
                              ),
                              SizedBox(width: 11.w),
                              Text(
                                'To',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(width: 11.w),
                              _buildTimeDropdown(toTime, (val) => setState(() => toTime = val!)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDropdown(String currentValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E4E4)),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 14.sp),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            color: AppColors.dynamicText,
          ),
          onChanged: onChanged,
          items: <String>['10:00 PM', '11:00 PM', '12:00 AM', '07:00 PM', '08:00 AM', '09:00 AM']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFC0C0C0),
      thickness: 0.3,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: AppColors.dynamicText, size: 18.sp),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.dynamicText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,

              // ON State
              activeTrackColor: const Color(0xFF3183FF), // Track
              activeColor: Colors.white,                 // Thumb
              activeThumbColor: Colors.white,            // Thumb
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF92B0FF); // ON Border
                  }
                  return const Color(0xFFC1C1C1); // OFF Border
                },
              ),
              trackOutlineWidth: WidgetStateProperty.all(0.52),

              // OFF State
              inactiveTrackColor: const Color(0xFF757171), // Track
              inactiveThumbColor: Colors.white,            // Thumb
            ),
          ),
        ],
      ),
    );
  }
}

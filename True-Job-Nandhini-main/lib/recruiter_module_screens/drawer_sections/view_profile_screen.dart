import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'edit_profile_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  static const String _fontFamily = 'Poppins';
  bool _isLoading = true;
  String _fullName = '';
  String _email = '';
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id')?.toString() ?? '';
    // A token may be stored or passed, for now we will use an empty string or fetch if available
    final token = prefs.getString('token') ?? '';
    final mobile = prefs.getString('mobile') ?? '';

    setState(() {
      _mobile = mobile;
    });

    final response = await BasicDetailApiService.fetchBasicDetails(
      userId: userId,
      token: token,
    );

    if (response != null && response['status'] == 'success') {
      final data = response['data'];
      if (data != null) {
        setState(() {
          _fullName = data['contact_person'] ?? data['name'] ?? '';
          _email = data['contact_person_email'] ?? data['email_id'] ?? '';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8FD),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(
              backgroundColor: Color(0xFFF6F8FD),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.dynamicText,
                          size: 18.w,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'View Profile',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dynamicText,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            fullName: _fullName,
                            email: _email,
                            mobile: _mobile,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 14.w,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Text(
                'View your registered information below',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  color: AppColors.dynamicSubtitle,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Details',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dynamicText,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  Icons.person_outline,
                                  'Full Name',
                                  _fullName,
                                ),
                                Divider(
                                  color: const Color(0xFFF2F2F2),
                                  height: 32.h,
                                ),
                                _buildInfoRow(
                                  Icons.email_outlined,
                                  'Official Mail ID',
                                  _email,
                                ),
                                Divider(
                                  color: const Color(0xFFF2F2F2),
                                  height: 32.h,
                                ),
                                _buildInfoRow(
                                  Icons.phone_outlined,
                                  'Mobile Number',
                                  _mobile,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.dynamicSubtitle,
                                size: 16.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Your information is safe and secure with us',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 12.sp,
                                  color: AppColors.dynamicSubtitle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: const BoxDecoration(
            color: Color(0xFFEAEFFC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF1462FD), size: 18.w),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 11.sp,
                  color: AppColors.dynamicSubtitle,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dynamicText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

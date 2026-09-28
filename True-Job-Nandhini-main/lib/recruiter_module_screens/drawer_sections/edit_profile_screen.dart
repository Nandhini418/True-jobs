import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'change_email_screen.dart';
import 'change_mobile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String mobile;

  const EditProfileScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.mobile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const String _fontFamily = 'Poppins';
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: widget.email);
    _mobileController = TextEditingController(text: widget.mobile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
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
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, color: AppColors.dynamicText, size: 18.w),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dynamicText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
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
              child: SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Full Name'),
                          SizedBox(height: 8.h),
                          _buildTextField(_nameController),
                          SizedBox(height: 20.h),
                          
                          _buildLabel('Official Mail ID'),
                          SizedBox(height: 8.h),
                          _buildTextFieldWithChange(
                            _emailController, 
                            onChangeTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChangeEmailScreen()),
                              );
                            },
                          ),
                          SizedBox(height: 20.h),

                          _buildLabel('Mobile Number'),
                          SizedBox(height: 8.h),
                          _buildTextFieldWithChange(
                            _mobileController, 
                            onChangeTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChangeMobileScreen()),
                              );
                            },
                          ),
                          SizedBox(height: 32.h),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // For now, just pop back as per requirements (UI only)
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, color: AppColors.dynamicSubtitle, size: 16.w),
                        SizedBox(width: 8.w),
                        Text(
                          'Your information is safe and secure with us',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11.sp,
                            color: AppColors.dynamicSubtitle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.dynamicSubtitle,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13.sp,
        color: AppColors.dynamicText,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithChange(TextEditingController controller, {required VoidCallback onChangeTap}) {
    return TextFormField(
      controller: controller,
      readOnly: true, // Making this readOnly since change happens on another screen
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13.sp,
        color: AppColors.dynamicText,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: GestureDetector(
          onTap: onChangeTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Change',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

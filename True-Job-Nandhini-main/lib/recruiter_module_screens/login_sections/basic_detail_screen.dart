import 'package:truejobs/recruiter_module_screens/login_sections/company_details_screen.dart';
//import 'package:truejobs/recruiter_module_screens/login_sections/email_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';

class EnteredNumberScreen extends StatefulWidget {
  final String phone;
  final String userId;
  final String token;

  const EnteredNumberScreen({
    super.key,
    required this.phone,
    required this.userId,
    required this.token,
  });

  @override
  State<EnteredNumberScreen> createState() => _EnteredNumberScreenState();
}

class _EnteredNumberScreenState extends State<EnteredNumberScreen> {
  static const String _fontFamily = 'Poppins';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isFormComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final response = await BasicDetailApiService.fetchBasicDetails(
      userId: widget.userId,
      token: widget.token,
    );

    if (response != null && response['status'] == 'success') {
      final data = response['data'];
      if (data != null) {
        _nameController.text = data['contact_person'] ?? data['name'] ?? '';
        _emailController.text =
            data['contact_person_email'] ?? data['email_id'] ?? '';
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onFormChanged() {
    final emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(emailPattern);
    final isComplete =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        regExp.hasMatch(_emailController.text.trim());
    if (isComplete != _isFormComplete) {
      setState(() {
        _isFormComplete = isComplete;
      });
    }
  }

  Future<void> _onVerifyPressed() async {
    if (!_isFormComplete) return;

    setState(() {
      _isLoading = true;
    });

    final response = await BasicDetailApiService.updateBasicDetails(
      userId: widget.userId,
      contactPerson: _nameController.text.trim(),
      contactPersonEmail: _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['status'] == 'success') {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyDetailsScreen(
            phone: widget.phone,
            userId: widget.userId,
            token: widget.token,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?['message'] ?? 'Failed to update details'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _emailController.removeListener(_onFormChanged);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear(); // Clear persistent login
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 18.w, 18.w, 17.h),
          child: _isLoading
              ? SizedBox(
                  height: 552.h,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14.h),
                    _buildTabs(textColor, subtitleColor),
                    SizedBox(height: 20.h),
                    _buildHeaderIconAndTitle(textColor),
                    SizedBox(height: 18.h),
                    _buildBasicDetailsCard(
                      textColor,
                      subtitleColor,
                      borderColor,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTabs(Color textColor, Color subtitleColor) {
    return Row(
      children: [
        // Basic Details - Active
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(width: 5.w),

            Text(
              'Basic details',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),

        // Line
        Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            color: const Color(0xFFE3E3E3),
          ),
        ),

        // Company Details - Inactive
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
            ),

            SizedBox(width: 5.w),

            Text(
              'Company Details',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0x66000000),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicDetailsCard(
    Color textColor,
    Color subtitleColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.52),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // #0000000A
            offset: Offset(0, 0),
            blurRadius: 2.07,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile number
          _buildMobileDisplay(textColor, subtitleColor, borderColor),

          SizedBox(height: 17.h),

          // Full Name
          _buildLabeledField(
            label: 'Full name',
            controller: _nameController,
            icon: Icons.person_outline,
            hintText: 'Enter your full name',
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),

          SizedBox(height: 14.h),

          // Official Email
          _buildLabeledField(
            label: 'Official email ID',
            controller: _emailController,
            icon: Icons.mail_outline,
            hintText: 'Enter your mail id',
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: 25.h),

          // Verify Button
          _buildVerifyButton(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildHeaderIconAndTitle(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset('assets/images/file.png', height: 54.w),
        SizedBox(width: 9.w),
        Text(
          'Set up your employer account',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDisplay(
    Color textColor,
    Color subtitleColor,
    Color borderColor,
  ) {
    return Row(
      children: [
        Text(
          'Mobile: ',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12.sp,
            color: const Color(0x55000000),
          ),
        ),
        Text(
          '+91 ${widget.phone}',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: label),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFFF0404)),
              ),
            ],
          ),
        ),
        SizedBox(height: 7.h),
        Container(
          height: 43.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: const Color(0xFFA9A9A9), width: 0.3),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFF888888)),
              SizedBox(width: 9.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 12.sp,
                      color: const Color(0xFFC3C3C3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 38.h,
      child: ElevatedButton(
        onPressed: _isFormComplete ? _onVerifyPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: const Color(0xFFEFF0F3),
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.buttonDisabledText,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(103.r),
          ),
        ),
        child: Text(
          'Verify OTP',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


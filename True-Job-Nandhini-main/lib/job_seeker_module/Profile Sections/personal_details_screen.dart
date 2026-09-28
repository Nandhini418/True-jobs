import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String initialName;
  final String initialHeadline;
  final String initialPhone;
  final String initialEmail;

  const PersonalDetailsScreen({
    super.key,
    required this.initialName,
    required this.initialHeadline,
    required this.initialPhone,
    required this.initialEmail,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _headlineController = TextEditingController(text: widget.initialHeadline);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Personal Details',
                        style: TextStyle(
                          color: textColor,
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.settings_outlined,
                    color: textColor,
                    size: sw * 0.065,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(sw * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please fill out the form below.* required',
                      style: TextStyle(
                        fontSize: sw * 0.034,
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Full Name Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Full Name*',
                          style: TextStyle(
                            fontSize: sw * 0.038,
                            color: subtitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '250/250',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Profile Headline Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Headline*',
                          style: TextStyle(
                            fontSize: sw * 0.038,
                            color: subtitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '250/250',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _headlineController,
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.015),
                    Text(
                      'Briefly introduce yourself to potential employers.',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        color: subtitleColor,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Phone Input
                    Text(
                      'Phone *',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        color: subtitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sw * 0.02),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.015),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const Text(
                                '🇮🇳',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+91',
                                style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: sw * 0.045,
                                color: subtitleColor,
                              ),
                            ],
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: borderColor,
                            margin: EdgeInsets.symmetric(horizontal: sw * 0.03),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontSize: sw * 0.042,
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(color: subtitleColor),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // Email Input
                    Text(
                      'Email *',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        color: subtitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: sw * 0.042,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        suffixIconConstraints: const BoxConstraints(),
                        suffixIcon: Text(
                          'Edit',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: borderColor),

            // Bottom Actions Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                sw * 0.05,
                sw * 0.04,
                sw * 0.05,
                sw * 0.06,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.08),
                        ),
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.04),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'name': _nameController.text,
                          'headline': _headlineController.text,
                          'phone': _phoneController.text,
                          'email': _emailController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.08),
                        ),
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

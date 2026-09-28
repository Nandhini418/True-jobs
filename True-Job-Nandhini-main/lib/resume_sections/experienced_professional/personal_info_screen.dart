import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/resume_sections/experienced_professional/summary_screen.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/models/resume_data.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // State for additional fields
  bool _showLinkedIn = false;
  bool _showBehance = false;
  bool _showWebsite = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _surNameCtrl = TextEditingController();
  final TextEditingController _professionCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _districtCtrl = TextEditingController();
  final TextEditingController _pinCodeCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _linkedinCtrl = TextEditingController();
  final TextEditingController _behanceCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _surNameCtrl.dispose();
    _professionCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _pinCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _linkedinCtrl.dispose();
    _behanceCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 16.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  top: 1.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's the best way for employers to contact you?",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "We suggest including an email and phone number.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF353535),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "*indicates a required field",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF255EC7),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Upload Photo Section
                    Center(
                      child: GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Column(
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(12.r),
                                image: _selectedImage != null
                                    ? DecorationImage(
                                        image: FileImage(_selectedImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _selectedImage == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 32.sp,
                                          color: Colors.black87,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "( Optional )",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Upload Photo",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF255EC7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h),

                    _buildTextField("First name *", "Enter Your First Name", controller: _firstNameCtrl),
                    _buildTextField("Sur name", "Enter Your Sur Name", controller: _surNameCtrl),
                    _buildTextField("Profession *", "Enter Your Profession", controller: _professionCtrl),

                    _buildTextField("City *", "Enter City", controller: _cityCtrl),
                    Row(
                      children: [
                        Expanded(child: _buildTextField("District *", "Enter District", controller: _districtCtrl)),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField("Pin Code *", "Enter Pin Code", controller: _pinCodeCtrl, maxLength: 6, keyboardType: TextInputType.number),
                        ),
                      ],
                    ),

                    _buildTextField("Phone *", "Enter Phone Number", controller: _phoneCtrl, maxLength: 10, keyboardType: TextInputType.phone),
                    _buildTextField("Email *", "Enter Your Email", controller: _emailCtrl, keyboardType: TextInputType.emailAddress),

                    SizedBox(height: 15.h),

                    // Additional info section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, const Color(0xFFD9D9D9)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: const Color(0xFFE29300),
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Add additional information to your resume (optional)",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: [
                        if (!_showLinkedIn)
                          _buildAddChip(
                            "LinkedIn",
                            () => setState(() => _showLinkedIn = true),
                          ),
                        if (!_showBehance)
                          _buildAddChip(
                            "Behance",
                            () => setState(() => _showBehance = true),
                          ),
                        if (!_showWebsite)
                          _buildAddChip(
                            "Website",
                            () => setState(() => _showWebsite = true),
                          ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    if (_showLinkedIn)
                      _buildTextField(
                        "LinkedIn",
                        "Enter Your linkedin",
                        controller: _linkedinCtrl,
                        showClose: true,
                        onClose: () => setState(() => _showLinkedIn = false),
                      ),
                    if (_showBehance)
                      _buildTextField(
                        "Behance",
                        "Enter Your behance",
                        controller: _behanceCtrl,
                        showClose: true,
                        onClose: () => setState(() => _showBehance = false),
                      ),
                    if (_showWebsite)
                      _buildTextField(
                        "Website",
                        "Enter Your website",
                        controller: _websiteCtrl,
                        showClose: true,
                        onClose: () => setState(() => _showWebsite = false),
                      ),

                    SizedBox(height: 15.h),

                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool showClose = false,
    VoidCallback? onClose,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: label.replaceAll(' *', ''),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  children: [
                    if (label.contains('*'))
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              if (showClose)
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
            style: TextStyle(color: Colors.black87, fontSize: 12.sp),
            decoration: InputDecoration(
              counterText: "",
              hintText: hint,
              hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0),
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF255EC7), width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF255EC7),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.add, color: const Color(0xFF255EC7), size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: const Color(0xFF272727),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_firstNameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('First name is required')));
                  return;
                }
                if (_professionCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profession is required')));
                  return;
                }
                if (_cityCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('City is required')));
                  return;
                }
                if (_districtCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('District is required')));
                  return;
                }
                if (_pinCodeCtrl.text.trim().isEmpty || _pinCodeCtrl.text.trim().length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid 6-digit Pin Code is required')));
                  return;
                }
                if (_phoneCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid 10-digit phone number is required')));
                  return;
                }
                final email = _emailCtrl.text.trim();
                if (email.isEmpty || !email.endsWith('@gmail.com')) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid @gmail.com email is required')));
                  return;
                }

                final fullName = "${_firstNameCtrl.text} ${_surNameCtrl.text}".trim();
                final address = [
                  if (_cityCtrl.text.isNotEmpty) _cityCtrl.text,
                  if (_districtCtrl.text.isNotEmpty) _districtCtrl.text,
                  if (_pinCodeCtrl.text.isNotEmpty) _pinCodeCtrl.text,
                ].join(', ');

                ResumeData.globalData = ResumeData.globalData.copyWith(
                  fullName: fullName.isNotEmpty ? fullName : null,
                  role: _professionCtrl.text.isNotEmpty ? _professionCtrl.text : null,
                  phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
                  email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
                  address: address.isNotEmpty ? address : null,
                  hasPhoto: _selectedImage != null ? true : null,
                  profileImagePath: _selectedImage?.path,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const SummaryScreen(),
                    durationMs: 0,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

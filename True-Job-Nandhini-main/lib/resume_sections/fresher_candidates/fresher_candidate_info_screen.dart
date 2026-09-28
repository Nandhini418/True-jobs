import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/resume_sections/fresher_candidates/career_objective_screen.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/models/resume_data.dart';

class FresherCandidateInfoScreen extends StatefulWidget {
  const FresherCandidateInfoScreen({super.key});

  @override
  State<FresherCandidateInfoScreen> createState() => _FresherCandidateInfoScreenState();
}

class _FresherCandidateInfoScreenState extends State<FresherCandidateInfoScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _linkedinCtrl = TextEditingController();
  final TextEditingController _portfolioCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _locationCtrl.dispose();
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
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
                      "Personal Details",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Lets start with your basic information.",
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

                    _buildTextField("Full Name", "Enter your full name", controller: _fullNameCtrl),
                    _buildTextField("Mobile Number", "Enter mobile number", controller: _mobileCtrl),
                    _buildTextField("Email Address", "Enter your email", controller: _emailCtrl),
                    _buildTextField("Current Location", "Coimbatore", controller: _locationCtrl),
                    _buildTextField("LinkedIn Profile (Optional)", "https://", controller: _linkedinCtrl),
                    _buildTextField("Portfolio / GitHub (Optional)", "https://", controller: _portfolioCtrl),

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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            style: TextStyle(color: Colors.black87, fontSize: 12.sp),
            decoration: InputDecoration(
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
                final fullName = _fullNameCtrl.text.trim();
                ResumeData.globalData = ResumeData.globalData.copyWith(
                  fullName: fullName.isNotEmpty ? fullName : null,
                  phone: _mobileCtrl.text.isNotEmpty ? _mobileCtrl.text : null,
                  email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
                  address: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : null,
                  hasPhoto: _selectedImage != null ? true : null,
                  profileImagePath: _selectedImage?.path,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const CareerObjectiveScreen(),
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
                'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

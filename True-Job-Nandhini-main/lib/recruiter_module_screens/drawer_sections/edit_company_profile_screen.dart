import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'package:truejobs/services/company_details_api_service.dart';
import 'package:truejobs/services/dropdown_apis/industry_type_api_service.dart';
import 'package:image_picker/image_picker.dart';

import 'bottom_sheets/image_picker_sheet.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  State<EditCompanyProfileScreen> createState() => _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  static const String _fontFamily = 'Poppins';

  bool _isLoading = true;
  bool _isSaving = false;
  int _currentStep = 1;

  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _aboutCtrl = TextEditingController();
  final TextEditingController _sizeCtrl = TextEditingController();
  final TextEditingController _foundedYearCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();
  final TextEditingController _linkedinCtrl = TextEditingController();

  String _industryTypeId = '';
  String? _companyLogoPath;
  List<String> _ourCulturePaths = [];

  String _userId = '';
  String _token = '';

  List<dynamic> _industryOptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    _aboutCtrl.dispose();
    _sizeCtrl.dispose();
    _foundedYearCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id')?.toString() ?? '';
    _token = prefs.getString('token') ?? '';

    _industryOptions = await IndustryTypeApiService.fetchIndustryTypes();

    final response = await BasicDetailApiService.fetchBasicDetails(
      userId: _userId,
      token: _token,
    );

    if (response != null && response['status'] == 'success') {
      final data = response['data'];
      if (data != null) {
        _companyNameCtrl.text = data['company_name'] ?? data['company'] ?? '';
        _pincodeCtrl.text = data['pincode'] ?? data['pin_code'] ?? '';
        _addressCtrl.text = data['address'] ?? data['company_address'] ?? '';
        _aboutCtrl.text = data['company_description'] ?? data['about_company'] ?? '';
        _sizeCtrl.text = data['company_size']?.toString() ?? '';
        _foundedYearCtrl.text = data['founded_year']?.toString() ?? '';
        _mobileCtrl.text = data['company_mobile'] ?? '';
        _emailCtrl.text = data['company_email'] ?? '';
        _websiteCtrl.text = data['company_website'] ?? '';
        _linkedinCtrl.text = data['linkedin_url'] ?? '';

        final indType = data['industry_type'] ?? data['industry'];
        if (indType != null && indType.toString().isNotEmpty) {
          String fetchedIndType = indType.toString();
          bool found = false;
          for (var e in _industryOptions) {
            if ((e['value'] ?? e['id'])?.toString() == fetchedIndType) {
              _industryTypeId = fetchedIndType;
              found = true;
              break;
            }
          }
          if (!found) {
            for (var e in _industryOptions) {
              if ((e['label'] ?? e['name'])?.toString() == fetchedIndType) {
                _industryTypeId = (e['value'] ?? e['id'])?.toString() ?? '';
                found = true;
                break;
              }
            }
          }
          if (!found) {
            _industryTypeId = '';
          }
        }
        final logo = data['company_logo'];
        if (logo != null && logo.toString().isNotEmpty) {
          _companyLogoPath = logo.toString();
        }
      }
    }
    setState(() => _isLoading = false);
  }

  void _handleNextStep() {
    final companyName = _companyNameCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final about = _aboutCtrl.text.trim();
    final size = _sizeCtrl.text.trim();
    final foundedYear = _foundedYearCtrl.text.trim();

    if (companyName.isEmpty ||
        pincode.isEmpty ||
        address.isEmpty ||
        _industryTypeId.isEmpty ||
        about.isEmpty ||
        size.isEmpty ||
        foundedYear.isEmpty ||
        _companyLogoPath == null ||
        _companyLogoPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the mandatory fields')),
      );
      return;
    }
    
    setState(() {
      _currentStep = 2;
    });
  }

  Future<void> _handleSave() async {
    final companyName = _companyNameCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final about = _aboutCtrl.text.trim();
    final size = _sizeCtrl.text.trim();
    final foundedYear = _foundedYearCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final website = _websiteCtrl.text.trim();
    final linkedin = _linkedinCtrl.text.trim();

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    final response = await CompanyDetailsApiService.updateDetails(
      userId: _userId,
      companyName: companyName,
      pincode: pincode,
      address: address,
      industryType: _industryTypeId,
      token: _token,
      aboutCompany: about,
      companySize: size,
      foundedYear: foundedYear,
      companyMobile: mobile,
      companyEmail: email,
      companyWebsite: website,
      linkedinUrl: linkedin,
      companyLogoFile: _companyLogoPath,
      ourCulture: _ourCulturePaths,
    );

    setState(() {
      _isSaving = false;
    });

    if (response != null && response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company profile updated successfully')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?['message'] ?? 'Failed to update details')),
      );
    }
  }

  void _pickImages() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (context) => const ImagePickerSheet(),
    ).then((val) async {
      if (val != null && val is String) {
        final ImagePicker picker = ImagePicker();
        if (val == 'camera') {
          XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
          if (pickedFile != null) setState(() => _ourCulturePaths.add(pickedFile.path));
        } else if (val == 'gallery') {
          final List<XFile> pickedFiles = await picker.pickMultiImage();
          if (pickedFiles.isNotEmpty) {
            setState(() {
              for (var file in pickedFiles) {
                _ourCulturePaths.add(file.path);
              }
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(backgroundColor: Color(0xFFF6F8FD)),
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
                  Text('Edit Company Profile', style: TextStyle(fontFamily: _fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.dynamicText)),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Text('Update your registered information below', style: TextStyle(fontFamily: _fontFamily, fontSize: 12.sp, color: AppColors.dynamicSubtitle)),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
                          ),
                        ),
                        _buildBottomBar(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: _buildLogoRow(),
        ),
        
        SizedBox(height: 16.h),
        Text('Basic Details (Mandatory)', style: _sectionTitleStyle()),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Company Name'),
              SizedBox(height: 8.h),
              _buildTextField(_companyNameCtrl),
              SizedBox(height: 16.h),
              
              _buildLabel('Industry'),
              SizedBox(height: 8.h),
              _buildDropdownField(),
              SizedBox(height: 16.h),
              
              _buildLabel('Company Address'),
              SizedBox(height: 8.h),
              _buildTextField(_addressCtrl, maxLines: 2),
              SizedBox(height: 16.h),
              
              _buildLabel('Pin code'),
              SizedBox(height: 8.h),
              _buildTextField(_pincodeCtrl, isNumber: true),
              SizedBox(height: 16.h),
              
              _buildLabel('About'),
              SizedBox(height: 8.h),
              _buildTextField(_aboutCtrl, maxLines: 3),
            ],
          ),
        ),
        
        SizedBox(height: 24.h),
        Text('Additional Information (Mandatory)', style: _sectionTitleStyle()),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Company Size'),
              SizedBox(height: 8.h),
              _buildTextField(_sizeCtrl, isNumber: true),
              SizedBox(height: 16.h),
              
              _buildLabel('Founded Year'),
              SizedBox(height: 8.h),
              _buildTextField(_foundedYearCtrl, isNumber: true),
            ],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Information (Optional)', style: _sectionTitleStyle()),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Company Mobile'),
              SizedBox(height: 8.h),
              _buildTextField(_mobileCtrl, isNumber: true),
              SizedBox(height: 16.h),
              
              _buildLabel('Company Email'),
              SizedBox(height: 8.h),
              _buildTextField(_emailCtrl),
              SizedBox(height: 16.h),
              
              _buildLabel('Company Website'),
              SizedBox(height: 8.h),
              _buildTextField(_websiteCtrl),
              SizedBox(height: 16.h),
              
              _buildLabel('LinkedIn URL'),
              SizedBox(height: 8.h),
              _buildTextField(_linkedinCtrl),
            ],
          ),
        ),
        
        SizedBox(height: 24.h),
        Text('Company Gallery (Optional)', style: _sectionTitleStyle()),
        SizedBox(height: 4.h),
        Text('Showcase your workplace, team, and culture', style: TextStyle(fontFamily: _fontFamily, fontSize: 11.sp, color: AppColors.dynamicSubtitle)),
        SizedBox(height: 16.h),
        _buildGalleryUpload(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE8E8E8))),
      ),
      child: Row(
        children: [
          if (_currentStep == 2) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                ),
                child: Text('Back', style: TextStyle(fontFamily: _fontFamily, fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.primary)),
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 1 ? _handleNextStep : (_isSaving ? null : _handleSave),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _currentStep == 1 ? 'Next' : 'Save Changes',
                      style: TextStyle(fontFamily: _fontFamily, fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  
  TextStyle _sectionTitleStyle() {
    return TextStyle(fontFamily: _fontFamily, fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.dynamicText);
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

  Widget _buildTextField(TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
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

  Widget _buildDropdownField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _industryTypeId.isNotEmpty ? _industryTypeId : null,
          hint: Text('Select Industry', style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, color: AppColors.dynamicSubtitle)),
          items: () {
            final seenValues = <String>{};
            return _industryOptions.where((e) {
              final val = (e['value'] ?? e['id'])?.toString() ?? '';
              if (val.isEmpty || seenValues.contains(val)) return false;
              seenValues.add(val);
              return true;
            }).map((e) {
              final val = (e['value'] ?? e['id'])?.toString() ?? '';
              final label = (e['label'] ?? e['name'])?.toString() ?? '';
              return DropdownMenuItem<String>(
                value: val, 
                child: Text(label, style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp))
              );
            }).toList();
          }(),
          onChanged: (val) {
            setState(() {
              _industryTypeId = val ?? '';
            });
          },
        ),
      ),
    );
  }

  Widget _buildLogoRow() {
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEAEFFC),
            shape: BoxShape.circle,
            image: _companyLogoPath != null && _companyLogoPath!.isNotEmpty
                ? DecorationImage(
                    image: _companyLogoPath!.startsWith('http')
                        ? NetworkImage(_companyLogoPath!) as ImageProvider
                        : FileImage(File(_companyLogoPath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _companyLogoPath == null ? Icon(Icons.business, color: const Color(0xFF1462FD), size: 24.w) : null,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company Logo', style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.dynamicText)),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
                    builder: (context) => const ImagePickerSheet(),
                  ).then((val) async {
                    if (val != null && val is String) {
                      final ImagePicker picker = ImagePicker();
                      XFile? pickedFile;
                      if (val == 'camera') pickedFile = await picker.pickImage(source: ImageSource.camera);
                      else if (val == 'gallery') pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) setState(() => _companyLogoPath = pickedFile!.path);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1462FD)), borderRadius: BorderRadius.circular(4.r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: const Color(0xFF1462FD), size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(_companyLogoPath == null || _companyLogoPath!.isEmpty ? 'Add logo' : 'Change logo', style: TextStyle(fontFamily: _fontFamily, fontSize: 12.sp, color: const Color(0xFF1462FD))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildGalleryUpload() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD3D8E2), style: BorderStyle.solid),
      ),
      child: GestureDetector(
        onTap: _pickImages,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: const Color(0xFF1462FD), size: 32.w),
            SizedBox(height: 8.h),
            Text('Upload Images', style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.dynamicText)),
            SizedBox(height: 4.h),
            RichText(
              text: TextSpan(
                text: 'Drag and drop images or click to ',
                style: TextStyle(fontFamily: _fontFamily, fontSize: 11.sp, color: AppColors.dynamicSubtitle),
                children: const [
                  TextSpan(text: 'browse', style: TextStyle(color: Color(0xFF1462FD), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (_ourCulturePaths.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _ourCulturePaths.map((path) {
                  return Stack(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: DecorationImage(
                            image: path.startsWith('http') ? NetworkImage(path) as ImageProvider : FileImage(File(path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: GestureDetector(
                          onTap: () => setState(() => _ourCulturePaths.remove(path)),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.cancel, size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

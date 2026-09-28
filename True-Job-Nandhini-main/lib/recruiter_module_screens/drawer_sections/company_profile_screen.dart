import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'package:truejobs/services/dropdown_apis/industry_type_api_service.dart';
import 'edit_company_profile_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  static const String _fontFamily = 'Poppins';

  bool _isLoading = true;

  String _companyName = '';
  String _pincode = '';
  String _address = '';
  String _about = '';
  String _size = '';
  String _foundedYear = '';
  String _mobile = '';
  String _email = '';
  String _website = '';
  String _linkedin = '';

  String _industryTypeId = '';
  String _industryTypeName = '';
  String? _companyLogoPath;
  List<String> _ourCulturePaths = []; // Assuming we also fetch these if available in the basic API?

  String _userId = '';
  String _token = '';

  List<dynamic> _industryOptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
        _companyName = data['company_name'] ?? data['company'] ?? '';
        _pincode = data['pincode'] ?? data['pin_code'] ?? '';
        _address = data['address'] ?? data['company_address'] ?? '';
        _about = data['company_description'] ?? data['about_company'] ?? '';
        _size = data['company_size']?.toString() ?? '';
        _foundedYear = data['founded_year']?.toString() ?? '';
        _mobile = data['company_mobile'] ?? '';
        _email = data['company_email'] ?? '';
        _website = data['company_website'] ?? '';
        _linkedin = data['linkedin_url'] ?? '';

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
            _industryTypeName = fetchedIndType;
          } else {
            _updateIndustryName();
          }
        }
        final logo = data['company_logo'];
        if (logo != null && logo.toString().isNotEmpty) {
          _companyLogoPath = logo.toString();
        }
        
        final cultureList = data['our_culture'] ?? data['company_gallery'];
        if (cultureList is List) {
          _ourCulturePaths = cultureList.map((e) => e.toString()).toList();
        } else if (cultureList is String && cultureList.isNotEmpty) {
          _ourCulturePaths = [cultureList];
        } else {
          _ourCulturePaths = [];
        }
      }
    }
    setState(() => _isLoading = false);
  }

  void _updateIndustryName() {
    _industryTypeName = '';
    for (var e in _industryOptions) {
      if ((e['value'] ?? e['id'])?.toString() == _industryTypeId) {
        _industryTypeName = (e['label'] ?? e['name'])?.toString() ?? '';
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Icon(Icons.arrow_back_ios, color: AppColors.dynamicText, size: 18.w),
                      ),
                      SizedBox(width: 8.w),
                      Text('Company Profile', style: TextStyle(fontFamily: _fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.dynamicText)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditCompanyProfileScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadData();
                      }
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
              child: Text('View your registered information below', style: TextStyle(fontFamily: _fontFamily, fontSize: 12.sp, color: AppColors.dynamicSubtitle)),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCard(_buildLogoRow()),
                          
                          SizedBox(height: 16.h),
                          Text('Basic Details', style: _sectionTitleStyle()),
                          SizedBox(height: 16.h),
                          _buildCardColumn([
                            _buildInfoRow('Company Name', _companyName, 'assets/settings_icon/company_name.png'),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildIndustryRow(),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('Company Address', _address, 'assets/settings_icon/address.png', maxLines: 2),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('Pin code', _pincode, 'assets/settings_icon/pincode.png'),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('About', _about, 'assets/settings_icon/about_company.png', maxLines: 3),
                          ]),
                          
                          SizedBox(height: 24.h),
                          Text('Additional Information', style: _sectionTitleStyle()),
                          SizedBox(height: 16.h),
                          _buildCardColumn([
                            _buildInfoRow('Company Size', _size, 'assets/settings_icon/company_name.png'),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('Founded Year', _foundedYear, 'assets/settings_icon/company_name.png'),
                          ]),
                          
                          SizedBox(height: 24.h),
                          Text('Contact Information', style: _sectionTitleStyle()),
                          SizedBox(height: 16.h),
                          _buildCardColumn([
                            _buildInfoRow('Company Mobile', _mobile, 'assets/settings_icon/company_name.png'),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('Company Email', _email, 'assets/settings_icon/company_name.png'),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('Company Website', _website, 'assets/settings_icon/company_name.png'),
                            const Divider(color: Color(0xFFE3E3E3), height: 1),
                            _buildInfoRow('LinkedIn URL', _linkedin, 'assets/settings_icon/company_name.png'),
                          ]),
                          
                          if (_ourCulturePaths.isNotEmpty) ...[
                            SizedBox(height: 24.h),
                            Text('Company Gallery', style: _sectionTitleStyle()),
                            SizedBox(height: 16.h),
                            _buildGalleryUpload(),
                          ],
                          
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      )
    );
  }
  
  TextStyle _sectionTitleStyle() {
    return TextStyle(fontFamily: _fontFamily, fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.dynamicText);
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: child,
    );
  }
  
  Widget _buildCardColumn(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      child: Column(children: children),
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
              SizedBox(height: 4.h),
              Text(_companyLogoPath == null || _companyLogoPath!.isEmpty ? 'No logo added' : 'Logo uploaded', style: TextStyle(fontFamily: _fontFamily, fontSize: 11.sp, color: AppColors.dynamicSubtitle)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildIndustryRow() {
    final bool isEmpty = _industryTypeId.isEmpty;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: const Color(0xFFEAEFFC), borderRadius: BorderRadius.circular(10.r)),
            child: Image.asset('assets/settings_icon/industry.png', height: 20.h, width: 20.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Industry', style: TextStyle(fontFamily: _fontFamily, fontSize: 11.sp, color: AppColors.dynamicSubtitle)),
                SizedBox(height: 4.h),
                Text(
                  isEmpty ? 'Not Available' : _industryTypeName,
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500, color: isEmpty ? AppColors.dynamicSubtitle : AppColors.dynamicText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, String iconPath, {int maxLines = 1}) {
    final bool isEmpty = value.trim().isEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: const Color(0xFFEAEFFC), borderRadius: BorderRadius.circular(10.r)),
            child: Image.asset(iconPath, height: 20.h, width: 20.w, errorBuilder: (c, e, s) => Icon(Icons.info_outline, color: const Color(0xFF1462FD), size: 20.w)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: _fontFamily, fontSize: 11.sp, color: AppColors.dynamicSubtitle)),
                SizedBox(height: 4.h),
                Text(
                  isEmpty ? 'Not Available' : value,
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500, color: isEmpty ? AppColors.dynamicSubtitle : AppColors.dynamicText),
                  maxLines: maxLines,
                  overflow: maxLines == 1 ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
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
      child: Column(
        children: [
          if (_ourCulturePaths.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _ourCulturePaths.map((path) {
                return Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: path.startsWith('http') ? NetworkImage(path) as ImageProvider : FileImage(File(path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Icon(Icons.image_not_supported_outlined, color: const Color(0xFF1462FD), size: 32.w),
            SizedBox(height: 8.h),
            Text('No images added', style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.dynamicText)),
          ],
        ],
      ),
    );
  }
}

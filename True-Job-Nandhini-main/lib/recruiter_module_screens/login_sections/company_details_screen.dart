import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/dashboard_holder.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'package:truejobs/services/company_details_api_service.dart';
import 'package:truejobs/services/dropdown_apis/industry_type_api_service.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final String phone;
  final String userId;
  final String token;

  const CompanyDetailsScreen({
    super.key,
    required this.phone,
    required this.userId,
    required this.token,
  });

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  static const String _fontFamily = 'Poppins';

  final TextEditingController _companyController = TextEditingController();
  String? _selectedIndustry;
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isFormComplete = false;
  bool _isLoading = false;

  List<dynamic> _industryOptions = [];
  bool _isLoadingIndustry = false;

  @override
  void initState() {
    super.initState();
    _fetchIndustryOptions();
    _loadData();
    _companyController.addListener(_onFormChanged);
    _pinCodeController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
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
        _companyController.text = data['company_name'] ?? data['company'] ?? '';
        _pinCodeController.text = data['pincode'] ?? data['pin_code'] ?? '';
        _addressController.text = data['address'] ?? data['company_address'] ?? '';
        
        final indType = data['industry_type'] ?? data['industry'];
        if (indType != null && indType.toString().isNotEmpty) {
           _selectedIndustry = indType.toString();
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchIndustryOptions() async {
    setState(() {
      _isLoadingIndustry = true;
    });
    final options = await IndustryTypeApiService.fetchIndustryTypes();
    if (mounted) {
      setState(() {
        _industryOptions = options;
        _isLoadingIndustry = false;
      });
    }
  }

  void _onFormChanged() {
    final isComplete =
        _companyController.text.trim().isNotEmpty &&
        _selectedIndustry != null &&
        _pinCodeController.text.trim().length == 6 &&
        _addressController.text.trim().isNotEmpty;
    if (isComplete != _isFormComplete) {
      setState(() {
        _isFormComplete = isComplete;
      });
    }
  }

  void _onVerifyPressed() async {
    if (!_isFormComplete) return;

    setState(() {
      _isLoading = true;
    });

    final response = await CompanyDetailsApiService.updateDetails(
      userId: widget.userId,
      companyName: _companyController.text.trim(),
      pincode: _pinCodeController.text.trim(),
      address: _addressController.text.trim(),
      industryType: _selectedIndustry ?? '',
      token: widget.token,
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['status'] == 'success') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardHolder()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?['message'] ?? 'Failed to update details'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _companyController.removeListener(_onFormChanged);
    _pinCodeController.removeListener(_onFormChanged);
    _addressController.removeListener(_onFormChanged);
    _companyController.dispose();
    _pinCodeController.dispose();
    _addressController.dispose();
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
          onPressed: () => Navigator.pop(context),
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
                    _buildTabs(textColor),
                    SizedBox(height: 25.h),
                    _buildHeaderIconAndTitle(textColor, subtitleColor),
                    SizedBox(height: 20.h),
                    _buildFormCard(textColor, subtitleColor, borderColor),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTabs(Color textColor) {
    return Row(
      children: [
        // Basic Details - Active
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 11.w,
              height: 11.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
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

  Widget _buildHeaderIconAndTitle(Color textColor, Color subtitleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/file.png', height: 54.w),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell Us About Your Company',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Provide your company details so we can personalize your hiring experience and generate accurate invoices.',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(
    Color textColor,
    Color subtitleColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
          Row(
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
          ),
          SizedBox(height: 17.h),
          _buildLabeledField(
            label: 'Company',
            controller: _companyController,
            hintText: 'Enter company name',
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
          SizedBox(height: 14.h),
          _buildIndustryDropdown(textColor: textColor),
          SizedBox(height: 14.h),
          _buildLabeledField(
            label: 'Pin code',
            controller: _pinCodeController,
            hintText: 'Enter 6 digit pin code',
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          SizedBox(height: 14.h),
          _buildLabeledField(
            label: 'Company address',
            controller: _addressController,
            hintText: 'Tell us about your company',
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
            maxLines: 4,
          ),
          SizedBox(height: 20.h),
          _buildVerifyButton(),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: maxLines > 1 ? 2.h : 0,
          ),
          height: maxLines > 1 ? null : 35.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: const Color(0xFFA9A9A9), width: 0.3),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
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

  Widget _buildIndustryDropdown({required Color textColor}) {
    List<DropdownMenuItem<String>> menuItems = [];

    if (_isLoadingIndustry) {
      // Don't show dummy value in items if not matching value.
      // We can just rely on the hint to show 'Loading...'
    } else if (_industryOptions.isEmpty) {
      // Similarly, rely on hint 'No options found'
    } else {
      for (var e in _industryOptions) {
        final val = (e['value'] ?? e['id'])?.toString() ?? '';
        final label = (e['label'] ?? e['name'])?.toString() ?? '';

        if (val.isNotEmpty && label.isNotEmpty) {
          menuItems.add(DropdownMenuItem(
            value: val,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 13.sp,
                color: textColor,
                fontWeight: FontWeight.w400
              ),
            ),
          ));
        }
      }
    }

    // Ensure _selectedIndustry is valid or null
    if (_selectedIndustry != null &&
        _industryOptions.isNotEmpty &&
        !_industryOptions.any((e) => (e['value'] ?? e['id'])?.toString() == _selectedIndustry)) {
      _selectedIndustry = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Industry',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          height: 35.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: const Color(0xFFA9A9A9), width: 0.3),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedIndustry,
              hint: Text(
                _isLoadingIndustry
                    ? 'Loading...'
                    : _industryOptions.isEmpty
                        ? 'No options found'
                        : 'Select your industry',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFC3C3C3),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: textColor, size: 20.sp),
              items: menuItems.isEmpty ? null : menuItems,
              onChanged: (val) {
                setState(() {
                  _selectedIndustry = val;
                });
                _onFormChanged();
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 35.h,
      child: ElevatedButton(
        onPressed: (_isFormComplete && !_isLoading) ? _onVerifyPressed : null,
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
        child: _isLoading
            ? SizedBox(
                height: 18.w,
                width: 18.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Verify',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/resume_sections/experienced_professional/certification_screen.dart';

class AddCertificateScreen extends StatefulWidget {
  final CertificationModel? initialData;

  const AddCertificateScreen({
    super.key,
    this.initialData,
  });

  @override
  State<AddCertificateScreen> createState() => _AddCertificateScreenState();
}

class _AddCertificateScreenState extends State<AddCertificateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  String _selectedYear = '';

  final List<String> _years = List.generate(30, (index) => (DateTime.now().year - index).toString());

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!.name;
      _orgController.text = widget.initialData!.organization;
      _selectedYear = widget.initialData!.year;
    }
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
        title: Text(
          "Add Certificates",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 1.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 65.w,
                            height: 65.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2F6F1), // Light mint color
                              shape: BoxShape.circle,
                            ),
                          ),
                          Image.asset(
                            'assets/resume_images/experience/stamp.gif',
                            height: 35.h,
                          ),
                        ],
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          "Add your most relevant certification\nto strengthen your CV.",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    SizedBox(height: 24.h),
                    
                    // Certificate Name
                    Text(
                      "Certificate Name",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(_nameController, "e.g. Google UX Design Certificate"),
                    SizedBox(height: 20.h),
                    
                    // Issuing Organization
                    Text(
                      "Issuing Organization",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTextField(_orgController, "e.g. Google , Microsoft, AWS"),
                    SizedBox(height: 20.h),
                    
                    // Issue Year
                    Text(
                      "Issue Year",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            "Select year",
                            style: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 14.sp),
                          ),
                          value: _selectedYear.isEmpty ? null : _selectedYear,
                          items: _years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year, style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedYear = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Info Box
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEFC),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: const Color(0xFF1976D2), size: 20.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "You can add a maximum of 5 certifications",
                            style: TextStyle(
                              color: const Color(0xFF757575),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            
            // Submit Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _orgController.text.isNotEmpty && _selectedYear.isNotEmpty) {
                      final cert = CertificationModel()
                        ..name = _nameController.text
                        ..organization = _orgController.text
                        ..year = _selectedYear;
                      Navigator.pop(context, cert);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFBDBDBD), fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

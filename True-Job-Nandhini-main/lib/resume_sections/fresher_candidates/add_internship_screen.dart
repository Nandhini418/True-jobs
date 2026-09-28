import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class InternshipModel {
  String company = '';
  String role = '';
  String startDate = '';
  String endDate = '';
  String location = '';
  String responsibilities = '';
}

class AddInternshipScreen extends StatefulWidget {
  final InternshipModel? initialData;

  const AddInternshipScreen({super.key, this.initialData});

  @override
  State<AddInternshipScreen> createState() => _AddInternshipScreenState();
}

class _AddInternshipScreenState extends State<AddInternshipScreen> {
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _roleCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _respCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _companyCtrl.text = widget.initialData!.company;
      _roleCtrl.text = widget.initialData!.role;
      _startDateCtrl.text = widget.initialData!.startDate;
      _endDateCtrl.text = widget.initialData!.endDate;
      _locationCtrl.text = widget.initialData!.location;
      _respCtrl.text = widget.initialData!.responsibilities;
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _locationCtrl.dispose();
    _respCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    Center(
                      child: Text(
                        "Internship/ Training",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        "Add your Internship or training details.\n( Optional )",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF353535),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    _buildTextField("Company/ Organization", "Enter company name", _companyCtrl),
                    _buildTextField("Role / Title", "e.g. Google, Microsoft, AWS", _roleCtrl),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Start Date",
                            "dd/mm/yy",
                            _startDateCtrl,
                            isDate: true,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            "End Date",
                            "dd/mm/yy",
                            _endDateCtrl,
                            isDate: true,
                          ),
                        ),
                      ],
                    ),
                    
                    _buildTextField("Location", "Enter location", _locationCtrl),
                    _buildTextField("Responsibilities / What you learned", "Enter responsibilities", _respCtrl, maxLines: 4),
                    
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final model = InternshipModel()
                      ..company = _companyCtrl.text
                      ..role = _roleCtrl.text
                      ..startDate = _startDateCtrl.text
                      ..endDate = _endDateCtrl.text
                      ..location = _locationCtrl.text
                      ..responsibilities = _respCtrl.text;
                    
                    Navigator.pop(context, model);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    bool isDate = false,
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
          GestureDetector(
            onTap: isDate ? () => _selectDate(context, controller) : null,
            child: AbsorbPointer(
              absorbing: isDate,
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13.sp),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: isDate
                      ? Icon(Icons.calendar_today_outlined, size: 20.sp, color: Colors.grey)
                      : null,
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
            ),
          ),
        ],
      ),
    );
  }
}

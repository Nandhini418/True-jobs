import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class ScheduleInterviewScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ScheduleInterviewScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<ScheduleInterviewScreen> createState() => _ScheduleInterviewScreenState();
}

class _ScheduleInterviewScreenState extends State<ScheduleInterviewScreen> {
  String? _interviewType;
  bool _sendReminder = true;
  String? _selectedInterviewer;
  String? _selectedVideoPlatform;

  final TextEditingController _meetingLinkController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _walkInFromController = TextEditingController();
  final TextEditingController _walkInToController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _candidateNameController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.dynamicText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      _dateController.text = '${picked.year}-$month-$day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),
                  // Back header link
                  InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(5.r),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'Schedule Interview',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildLabel('Candidate Name'),
                  _buildTextField('Enter candidate name', controller: _candidateNameController),
                  SizedBox(height: 16.h),

                  _buildLabel('Interviewer Name'),
                  _buildDropdown(
                    'Choose Interviewer',
                    ['Harish G', 'John Doe'],
                        (value) {
                      setState(() {
                        _selectedInterviewer = value;
                      });
                    },
                    value: _selectedInterviewer,
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel('Interviewer Type'),
                  _buildDropdown(
                    'Choose Interview Type',
                    ['In-Person', 'Video Interview', 'Walk-in'],
                        (value) {
                      setState(() {
                        _interviewType = value;
                      });
                    },
                    value: _interviewType,
                  ),
                  SizedBox(height: 16.h),

                  if (_interviewType == 'Video Interview') ...[
                    _buildLabel('Video platform'),
                    _buildDropdown(
                      'Choose Video Platform',
                      ['Google Meet', 'Zoom'],
                          (value) {
                        setState(() {
                          _selectedVideoPlatform = value;
                        });
                      },
                      value: _selectedVideoPlatform,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Meeting Link'),
                    _buildTextField(
                      'Paste the meeting URL',
                      controller: _meetingLinkController,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date'),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    'DD/MM/YY',
                                    controller: _dateController,
                                    suffixIcon: Icons.calendar_month_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Interview Time'),
                              _buildTextField(
                                '--:-- --',
                                controller: _timeController,
                                suffixIcon: Icons.access_time,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (_interviewType == 'Walk-in') ...[
                    _buildLabel('Walk-in timings'),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(
                          '10:00 AM',
                          controller: _walkInFromController,
                          suffixIcon: Icons.access_time,
                        )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: Text('-', style: TextStyle(fontSize: 14.sp, color: AppColors.dynamicSubtitle)),
                        ),
                        Expanded(child: _buildTextField(
                          '02:30 PM',
                          controller: _walkInToController,
                          suffixIcon: Icons.access_time,
                        ),),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Date'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          'DD/MM/YY',
                          controller: _dateController,
                          suffixIcon: Icons.calendar_month_outlined,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Interview Venue'),
                    _buildTextField(
                      'Enter Office address',
                      controller: _venueController,
                    ),
                  ] else ...[ // In-Person
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date'),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    'DD/MM/YY',
                                    controller: _dateController,
                                    suffixIcon: Icons.calendar_month_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Interview Time'),
                              _buildTextField('--:-- --', suffixIcon: Icons.access_time),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 16.h),
                  _buildLabel('Additional Notes'),
                  Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.r),
                      border: Border.all(color: const Color(0xFFDFDFDF)),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Add interview instruction or special notes....',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          color: const Color(0xFFB0B0B0),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.w),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Send Automatic Reminder',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dynamicText,
                            ),
                          ),
                          Text(
                            'Email + Push 30 min before',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.sp,
                              color: const Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _sendReminder,
                        onChanged: (value) {
                          setState(() {
                            _sendReminder = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onBack();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            side: BorderSide(color: AppColors.primary, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onBack();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Send',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, {
        bool readOnly = false,
        IconData? suffixIcon,
        TextEditingController? controller,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFDFDFDF)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 13.h,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(
            suffixIcon,
            color: const Color(0xFF6C757D),
            size: 18.sp,
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String hint,
      List<String> items,
      ValueChanged<String?> onChanged, {
        String? value,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFDFDFDF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              height: 20 / 14,
              color: const Color(0xFF6C757D),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.dynamicText,
            size: 22.sp,
          ),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            height: 20 / 14,
            color: const Color(0xFF0F172A),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  height: 20 / 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

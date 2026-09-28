import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/models.dart';

class CandidateCardWidget extends StatefulWidget {
  final CandidateModel candidate;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onReject;
  final VoidCallback onShortlist;

  const CandidateCardWidget({
    super.key,
    required this.candidate,
    required this.onTap,
    required this.onCall,
    required this.onWhatsApp,
    required this.onReject,
    required this.onShortlist,
  });

  @override
  State<CandidateCardWidget> createState() => _CandidateCardWidgetState();
}

class _CandidateCardWidgetState extends State<CandidateCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Name + Arrow
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          widget.candidate.name[0],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        widget.candidate.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dynamicText,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.chevron_right, color: AppColors.primary, size: 20.w),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  
                  // Second Row: Experience + Location
                  Row(
                    children: [
                      Icon(Icons.person, size: 16.w, color: const Color(0xFF5E6C84)),
                      SizedBox(width: 4.w),
                      Text(
                        widget.candidate.experience,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: const Color(0xFF5E6C84),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.business_center, size: 16.w, color: const Color(0xFF5E6C84)),
                      SizedBox(width: 4.w),
                      Text(
                        'Fresher', // Placeholder if not in model
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: const Color(0xFF5E6C84),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.location_on, size: 16.w, color: const Color(0xFF5E6C84)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          widget.candidate.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            color: const Color(0xFF5E6C84),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Expandable Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16.h,
                  horizontal: 12.w,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1FF),
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/top_match.png',
                                height: 16.h,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF055BF2),
                                      Color(0xFF03358C),
                                    ],
                                  ).createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      bounds.width,
                                      bounds.height,
                                    ),
                                  );
                                },
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  'See whats matches',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 20.w,
                          ),
                        ],
                      ),
                    ),

                    // Expanded content INSIDE the decoration
                    if (_isExpanded) ...[
                      SizedBox(
                        height: 12.h,
                      ),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: widget.candidate.skills.isNotEmpty
                            ? widget.candidate.skills
                                .map((skill) => _buildMatchChip(skill))
                                .toList()
                            : [
                                Text(
                                  'No skills specified',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.sp,
                                    color: AppColors.dynamicSubtitle,
                                  ),
                                ),
                              ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          SizedBox(height: 24.h),
          
          // Education Section (Constant)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_rounded, size: 16.w, color: const Color(0xFF5E6C84)),
                    SizedBox(width: 8.w),
                    Text(
                      'Education',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5E6C84),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.only(left: 24.w),
                  child: Text(
                    widget.candidate.education,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: const Color(0xFF172B4D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFD4D4D4), thickness: 0.3,),
            SizedBox(height: 12.h),
          
          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _buildIconButton(
                  icon: Icons.call,
                  color: Colors.white,
                  bgColor: const Color(0xFF2563EB),
                  borderColor: const Color(0xFF2563EB),
                  onTap: widget.onCall,
                  width: 48.w,
                ),
                SizedBox(width: 8.w),
                _buildIconButton(
                  imagePath: 'assets/images/whatsapp.png', // Placeholder for whatsapp
                  color: const Color(0xFF25D366),
                  bgColor: Colors.white,
                  borderColor: const Color(0xFF0CBD44),
                  onTap: widget.onWhatsApp,
                  width: 48.w,
                ),
                const Spacer(),
                
                if (widget.candidate.status == 'Shortlisted') ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Shortlisted',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ] else ...[
                  _buildActionButton(
                    text: '',
                    icon: Icons.close,
                    color: const Color(0xFFC12600),
                    onTap: widget.onReject,
                    isText: false,
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    text: 'Shortlist',
                    icon: Icons.check,
                    color: const Color(0xFF2A9852),
                    onTap: widget.onShortlist,
                    isText: true,
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Bottom Status Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              '${widget.candidate.appliedDate} | Active a month ago',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                color: const Color(0xFFA7A7A7),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ));
  }

  Widget _buildIconButton({
    IconData? icon,
    String? imagePath,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Center(
          child: imagePath != null
              ? Image.asset(
            imagePath,
            width: width * 0.6,
            height: width * 0.6,
            fit: BoxFit.contain,
          )
              : Icon(
            icon,
            color: color,
            size: width * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18.w),
            if (isText) ...[
              SizedBox(width: 6.w),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMatchChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3E7BFA),
            Color(0xFF6600CC),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}

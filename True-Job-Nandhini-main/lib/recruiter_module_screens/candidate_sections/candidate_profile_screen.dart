import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/models.dart';
import 'package:truejobs/recruiter_module_screens/candidate_sections/resume_preview_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidateProfileScreen extends StatefulWidget {
  final CandidateModel candidate;

  const CandidateProfileScreen({super.key, required this.candidate});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  static const String _fontFamily = 'Poppins';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 22.h),
                  _buildCandidateHeaderCard(),
                  SizedBox(height: 22.h),
                  _buildCoreCompetencies(),
                  SizedBox(height: 10.h),
                  Divider(color: Color(0x55C5C6D0),),
                  SizedBox(height: 10.h),
                  _buildProfessionalExperience(),
                  SizedBox(height: 10.h),
                  Divider(color: Color(0x55C5C6D0),),
                  SizedBox(height: 10.h),
                  _buildPersonalData(),
                  if (widget.candidate.portfolio.isNotEmpty || widget.candidate.linkedin.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Divider(color: Color(0x55C5C6D0),),
                    SizedBox(height: 10.h),
                    _buildSocialLinks(),
                  ],
                  SizedBox(height: 10.h),
                  Divider(color: Color(0x55C5C6D0),),
                  SizedBox(height: 10.h),
                  _buildEducation(),
                  SizedBox(height: 10.h),
                  Divider(color: Color(0x55C5C6D0),),
                  SizedBox(height: 10.h),
                  _buildResumeSection(),
                  SizedBox(height: 22.h), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return const CustomAppBar(showBackButton: true);
  }

  Widget _buildCandidateHeaderCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          widget.candidate.photo.isNotEmpty
              ? CircleAvatar(
                  radius: 29.r,
                  backgroundImage: NetworkImage(widget.candidate.photo),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                )
              : CircleAvatar(
                  radius: 29.r,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    widget.candidate.name.isNotEmpty
                        ? widget.candidate.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
          SizedBox(height: 11.h),
          // Name and Role
          Text(
            widget.candidate.name,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.dynamicText,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            widget.candidate.role,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 13.sp,
              color: const Color(0xFF45464F),
            ),
          ),
          SizedBox(height: 15.h),
          // Chips
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: [
              _buildInfoChip(Icons.work_outline, widget.candidate.experience),
              _buildInfoChip(
                Icons.location_on_outlined,
                widget.candidate.location,
              ),
              _buildInfoChip(
                Icons.account_balance_wallet_outlined,
                widget.candidate.expectedSalary,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          // Match Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Match Score',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dynamicText,
                ),
              ),
              Text(
                '${(widget.candidate.matchScore * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0051D5),
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(7.r),
            child: LinearProgressIndicator(
              value: widget.candidate.matchScore,
              backgroundColor: const Color(0xFFE3E3E3),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0051D5)),
              minHeight: 7.h,
            ),
          ),
          SizedBox(height: 18.h),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.phone_outlined,
                'Call',
                onTap: () async {
                  final Uri url = Uri.parse('tel:${widget.candidate.phone}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open dialer')),
                      );
                    }
                  }
                },
              ),
              _buildActionButton(
                Icons.message_outlined,
                'WhatsApp',
                onTap: () async {
                  // Format phone number to ensure it works well with WhatsApp (e.g., removing spaces/pluses is sometimes needed, but wa.me handles standard international format).
                  final Uri url = Uri.parse(
                    'https://wa.me/${widget.candidate.phone.replaceAll(RegExp(r"[^\d+]"), "")}',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open WhatsApp'),
                        ),
                      );
                    }
                  }
                },
              ),
              _buildActionButton(
                Icons.email_outlined,
                'Email',
                onTap: () async {
                  // Email placeholder or future use if they want
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF0),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: const Color(0xFF4B5563)),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 11.sp,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFECEEF0),
            ),
            child: Icon(icon, color: const Color(0xFF4B5563), size: 18.sp),
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12.sp,
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.primary, size: 18.sp),
          SizedBox(width: 7.w),
        ],
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: const Color(0xFF45464F),
          ),
        ),
      ],
    );
  }

  Widget _buildCoreCompetencies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Core Competencies'),
        SizedBox(height: 11.h),
        Wrap(
          spacing: 7.w,
          runSpacing: 7.h,
          children: widget.candidate.skills.map((skill) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                border: Border.all(color: Color(0x33C5C6D0)),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  color: const Color(0xFF374151),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfessionalExperience() {
    // If experience is missing or says Fresher without current company, we can adapt
    final isFresher = widget.candidate.experience.toLowerCase().contains(
      'fresher',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Professional Experience'),
        SizedBox(height: 11.h),
        if (isFresher && widget.candidate.currentCompany.isEmpty)
          Text(
            'Fresher',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14.sp,
              color: AppColors.dynamicText,
            ),
          )
        else
          _buildExperienceItem(
            role: widget.candidate.role.isNotEmpty
                ? widget.candidate.role
                : 'Professional',
            company: widget.candidate.currentCompany.isNotEmpty
                ? widget.candidate.currentCompany
                : 'Previous Experience',
            duration: widget.candidate.experience,
            description: '',
            isCurrent: true,
          ),
      ],
    );
  }

  Widget _buildExperienceItem({
    required String role,
    required String company,
    required String duration,
    required String description,
    required bool isCurrent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent ? AppColors.primary : const Color(0xFFD1D5DB),
              ),
            ),
            Container(
              width: 2.w,
              height: 72.h, // Arbitrary line height
              color: const Color(0xFFE5E7EB),
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Text(
                        'CURRENT',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF137333),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                company,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                duration,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 11.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: 7.h),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
              SizedBox(height: 22.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Data'),
        SizedBox(height: 20.h),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          children: [
            _buildDataBox(
              Icons.work_outline,
              'TOTAL EXP',
              widget.candidate.experience.isNotEmpty
                  ? widget.candidate.experience
                  : 'Fresher',
            ),
            _buildDataBox(
              Icons.account_balance_wallet_outlined,
              'CURRENT SALARY',
              widget.candidate.currentSalary.isNotEmpty
                  ? widget.candidate.currentSalary
                  : 'N/A',
            ),
            _buildDataBox(
              Icons.schedule_outlined,
              'NOTICE PERIOD',
              widget.candidate.noticePeriod.isNotEmpty
                  ? widget.candidate.noticePeriod
                  : 'N/A',
            ),
            _buildDataBox(
              Icons.account_balance_wallet,
              'EXPECTED SALARY',
              widget.candidate.expectedSalary.isNotEmpty
                  ? widget.candidate.expectedSalary
                  : 'N/A',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataBox(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dynamicText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Social Links'),
        SizedBox(height: 11.h),
        if (widget.candidate.portfolio.isNotEmpty) ...[
          _buildSocialLinkItem(Icons.link, widget.candidate.portfolio),
          SizedBox(height: 11.h),
        ],
        if (widget.candidate.linkedin.isNotEmpty) ...[
          _buildSocialLinkItem(
            Icons.business_center_outlined,
            widget.candidate.linkedin,
          ),
        ],

      ],
    );
  }

  Widget _buildSocialLinkItem(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.sp, color: AppColors.primary),
        ),
        SizedBox(width: 11.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Education'),
        SizedBox(height: 11.h),
        Text(
          widget.candidate.education.isNotEmpty
              ? widget.candidate.education
              : 'No education details provided',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.dynamicText,
          ),
        ),
      ],
    );
  }

  Widget _buildResumeSection() {
    final hasResume = widget.candidate.resume.isNotEmpty;
    final resumeFileName = hasResume
        ? widget.candidate.resume.split('/').last
        : 'No resume uploaded';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resume'),
        SizedBox(height: 11.h),
        GestureDetector(
          onTap: () {
            if (hasResume) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResumePreviewPage(
                    url: widget.candidate.resume,
                    title: resumeFileName,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No resume uploaded by candidate'),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasResume ? Icons.description : Icons.description_outlined,
                    size: 36.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 7.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      resumeFileName,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (hasResume) {
                    final Uri url = Uri.parse(widget.candidate.resume);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open resume'),
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No resume available')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
                icon: Icon(Icons.download, size: 16.sp),
                label: Text(
                  'DOWNLOAD',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4B5563),
                  side: BorderSide(color: const Color(0xFFD1D5DB)),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
                icon: Icon(Icons.share_outlined, size: 16.sp),
                label: Text(
                  'SHARE',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildLanguages() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionTitle('Languages'),
  //       SizedBox(height: 11.h),
  //       Wrap(
  //         spacing: 7.w,
  //         runSpacing: 7.h,
  //         children: widget.candidate.languages.map((lang) {
  //           return Container(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: 11.w,
  //               vertical: 7.h,
  //             ),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               border: Border.all(color: const Color(0xFFE5E7EB)),
  //               borderRadius: BorderRadius.circular(14.r),
  //             ),
  //             child: Text(
  //               lang,
  //               style: TextStyle(
  //                 fontFamily: _fontFamily,
  //                 fontSize: 12.sp,
  //                 color: AppColors.dynamicText,
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildRecruiterNotes() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildSectionTitle(
  //             'Recruiter Notes',
  //             icon: Icons.chat_bubble_outline,
  //           ),
  //           Container(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: 7.w,
  //               vertical: 4.h,
  //             ),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFFF3F4F6),
  //               borderRadius: BorderRadius.circular(7.r),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.lock_outline,
  //                   size: 11.sp,
  //                   color: const Color(0xFF6B7280),
  //                 ),
  //                 SizedBox(width: 4.w),
  //                 Text(
  //                   'Private Notes',
  //                   style: TextStyle(
  //                     fontFamily: _fontFamily,
  //                     fontSize: 9.sp,
  //                     color: const Color(0xFF6B7280),
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 14.h),
  //       Container(
  //         padding: EdgeInsets.all(14.w),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(14.r),
  //           border: Border.all(color: const Color(0xFFE5E7EB)),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Write a private note about the candidate...',
  //               style: TextStyle(
  //                 fontFamily: _fontFamily,
  //                 fontSize: 13.sp,
  //                 color: const Color(0xFF9CA3AF),
  //               ),
  //             ),
  //             SizedBox(height: 14.h),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.emoji_emotions_outlined,
  //                       color: const Color(0xFF6B7280),
  //                       size: 18.sp,
  //                     ),
  //                     SizedBox(width: 14.w),
  //                     Icon(
  //                       Icons.attach_file,
  //                       color: const Color(0xFF6B7280),
  //                       size: 18.sp,
  //                     ),
  //                   ],
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {},
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color(0xFF0F172A),
  //                     foregroundColor: Colors.white,
  //                     elevation: 0,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(7.r),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'ADD NOTE',
  //                     style: TextStyle(
  //                       fontFamily: _fontFamily,
  //                       fontSize: 11.sp,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 14.h),
  //       // Existing note
  //       Container(
  //         padding: EdgeInsets.all(14.w),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFF9FAFB),
  //           borderRadius: BorderRadius.circular(14.r),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 CircleAvatar(
  //                   radius: 14.r,
  //                   backgroundColor: const Color(0xFFE0E7FF),
  //                   child: Text(
  //                     'SK',
  //                     style: TextStyle(
  //                       color: const Color(0xFF4F46E5),
  //                       fontSize: 11.sp,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 11.w),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Suresh Kapoor',
  //                       style: TextStyle(
  //                         fontFamily: _fontFamily,
  //                         fontSize: 12.sp,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     Text(
  //                       '2 days ago',
  //                       style: TextStyle(
  //                         fontFamily: _fontFamily,
  //                         fontSize: 10.sp,
  //                         color: const Color(0xFF6B7280),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 11.h),
  //             Text(
  //               'Candidate has good experience with modern design systems. Needs to validate their HTML and CSS skills.',
  //               style: TextStyle(
  //                 fontFamily: _fontFamily,
  //                 fontSize: 12.sp,
  //                 color: const Color(0xFF4B5563),
  //                 height: 1.5,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/candidate_sections/candidate_card_widget.dart';
import 'package:truejobs/recruiter_module_screens/candidate_sections/candidate_profile_screen.dart';
import 'models.dart';
import 'package:truejobs/services/online_applicants_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;
  final VoidCallback onBack;
  final List<CandidateModel> candidates;
  final Function(CandidateModel, String) onCandidateStatusChanged;

  const JobDetailsScreen({
    super.key,
    required this.job,
    required this.onBack,
    required this.candidates,
    required this.onCandidateStatusChanged,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  String _selectedTab = 'Applied'; // 'Applied', 'Shortlisted', 'Contacted'
  static const String _fontFamily = 'Poppins';
  
  List<CandidateModel> _apiCandidates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    setState(() {
      _isLoading = true;
    });

    final onlineData = await OnlineApplicantsApiService.fetchApplicants(widget.job.id);
    final walkinData = await OnlineApplicantsApiService.fetchWalkinApplicants(widget.job.id);

    List<CandidateModel> combined = [];

    if (onlineData != null) {
      combined.addAll(onlineData.map((e) => CandidateModel.fromApiJson(e, widget.job.title)));
    }
    if (walkinData != null) {
      combined.addAll(walkinData.map((e) => CandidateModel.fromApiJson(e, widget.job.title)));
    }

    if (mounted) {
      setState(() {
        _apiCandidates = combined;
        _isLoading = false;
      });
    }
  }

  List<CandidateModel> get _filteredCandidates {
    final sourceList = _apiCandidates;
    
    // Return candidates matching the tab
    return sourceList.where((candidate) {
      if (_selectedTab == 'Applied') return true;
      if (_selectedTab == 'Shortlisted') return candidate.status == 'Shortlisted';
      if (_selectedTab == 'Contacted') return candidate.status == 'Shortlisted' || candidate.status == 'On Hold';
      return true;
    }).toList();
  }

  int _getCount(String tab) {
    final sourceList = _apiCandidates;
    return sourceList.where((candidate) {
      if (tab == 'Applied') return true;
      if (tab == 'Shortlisted') return candidate.status == 'Shortlisted';
      if (tab == 'Contacted') return candidate.status == 'Shortlisted' || candidate.status == 'On Hold';
      return true;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredCandidates;

    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          // App Bar
          const CustomAppBar(),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              //physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(height: 32.h),
                // Back to Jobs header link
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(5.r),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 14.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          'Back To Jobs',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Job Title & Status Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 7.w,
                          runSpacing: 4.h,
                          children: [
                            Text(
                              widget.job.title,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dynamicText,
                              ),
                            ),
                            Icon(Icons.circle, color: const Color(0xFF5ABE3B), size: 10.sp),
                            Text(
                              widget.job.status,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                color: widget.job.status == 'Active' ? const Color(0xFF4E4E4E) : const Color(0xFFC5221F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Icon(Icons.more_vert, color: AppColors.dynamicText, size: 22.sp),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Location Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 7.w),
                      Text(
                        'See Database Matches (20,081)', // Mock location matching screenshot
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 13.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 14.sp, color: AppColors.primary),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    //physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['Applied', 'Shortlisted', 'Contacted'].map((tab) {
                        final isSelected = _selectedTab == tab;
                        final count = _getCount(tab);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 22.w),
                            padding: EdgeInsets.only(bottom: 5.h),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: Text(
                              '$tab ($count)',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppColors.dynamicText : AppColors.dynamicSubtitle,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // All Candidates Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Text(
                    'All Candidates',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.dynamicText,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Candidates List
                filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.h, bottom: 40.h),
                          child: Text(
                            'No candidates in this stage yet.',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 13.sp,
                              color: AppColors.dynamicSubtitle,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          _buildMatchGroup(
                            context: context,
                            candidates: filteredList.where((c) => c.matchScore >= 0.8).toList(),
                            title: 'Top Match',
                            subtitle: 'Candidates matching all your key requirements. Connect with them before someone else does!',
                            bgColor: const Color(0xFFE4EEFF),
                            titleBgColor: Colors.white,
                            titleColor: AppColors.primary,
                            titleGradientColors: const [
                              Color(0xFF055BF2),
                              Color(0xFF03358C),
                            ],
                            titleImagePath: 'assets/images/top_match.png'
                          ),
                          _buildMatchGroup(
                            context: context,
                            candidates: filteredList.where((c) => c.matchScore >= 0.5 && c.matchScore < 0.8).toList(),
                            title: 'Medium Match',
                            subtitle: 'Candidates matching most of your key requirements. Connect with them before someone else does!',
                            bgColor: const Color(0xFFFFF9DB), // Light yellow background
                            titleBgColor: Colors.white,
                            titleColor: const Color(0xFFFD7E14), // Orange text
                            titleGradientColors: const [
                              Color(0xFFF39E00),
                              Color(0xFF4279D9),
                            ],
                            titleImagePath: 'assets/images/medium_match.png'
                          ),
                        ],
                      ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchGroup({
    required BuildContext context,
    required List<CandidateModel> candidates,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color titleBgColor,
    required Color titleColor,
    required List<Color> titleGradientColors,
    required String titleImagePath,
  }) {
    if (candidates.isEmpty) return const SizedBox();

    return Container(
      margin: EdgeInsets.only(bottom: 22.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(0.66),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF055BF2),
                      Color(0xFFC082FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 13.33),
                      blurRadius: 26.67,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x0A000000),
                      offset: Offset(0, 0),
                      blurRadius: 6.67,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: titleBgColor,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        titleImagePath,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 5.w),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: titleGradientColors,
                          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height,));
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: AppColors.secondary_color,
              height: 1.6
            ),
          ),
          SizedBox(height: 11.h),
          Column(
            children: candidates.map((candidate) {
              return CandidateCardWidget(
                candidate: candidate,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CandidateProfileScreen(candidate: candidate),
                    ),
                  );
                },
                onCall: () async {
                  final Uri url = Uri.parse('tel:${candidate.phone}');
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
                onWhatsApp: () async {
                  final Uri url = Uri.parse('https://wa.me/${candidate.phone.replaceAll(RegExp(r"[^\d+]"), "")}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open WhatsApp')),
                      );
                    }
                  }
                },
                onReject: () {
                  widget.onCandidateStatusChanged(candidate, 'Rejected');
                },
                onShortlist: () {
                  final nextStatus = candidate.status == 'Shortlisted' ? 'Under Review' : 'Shortlisted';
                  widget.onCandidateStatusChanged(candidate, nextStatus);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

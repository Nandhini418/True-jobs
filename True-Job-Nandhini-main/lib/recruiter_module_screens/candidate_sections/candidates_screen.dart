import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/models.dart';
import 'package:truejobs/recruiter_module_screens/candidate_sections/candidate_profile_screen.dart';
import 'package:truejobs/services/overall_candidates_api_service.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CandidateModel> _candidates = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    setState(() => _isLoading = true);
    final data = await OverallCandidatesApiService.fetchAllCandidates();
    if (data != null) {
      setState(() {
        _candidates = data
            .map<CandidateModel>(
                (json) => CandidateModel.fromApiJson(json as Map<String, dynamic>, ''))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<CandidateModel> get _filteredCandidates {
    final query = _searchController.text.toLowerCase().trim();
    return _candidates.where((candidate) {
      final matchesQuery =
          candidate.name.toLowerCase().contains(query) ||
          candidate.role.toLowerCase().contains(query) ||
          candidate.location.toLowerCase().contains(query) ||
          candidate.skills.any((s) => s.toLowerCase().contains(query));

      if (_selectedFilter == 'All') return matchesQuery;
      return matchesQuery && candidate.status == _selectedFilter;
    }).toList();
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Shortlisted':
        return const Color(0xFFE6F4EA);
      case 'On Hold':
        return const Color(0xFFF3E8FF);
      case 'Under Review':
        return const Color(0xFFFEF3C7);
      case 'Rejected':
        return const Color(0xFFFCE8E6);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Shortlisted':
        return const Color(0xFF137333);
      case 'On Hold':
        return const Color(0xFF6B21A8);
      case 'Under Review':
        return const Color(0xFFD97706);
      case 'Rejected':
        return const Color(0xFFC5221F);
      default:
        return const Color(0xFF475569);
    }
  }


  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredCandidates;

    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: RefreshIndicator(
        onRefresh: _fetchCandidates,
        child: Column(
          children: [
            // App Bar
            const CustomAppBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SizedBox(height: 24.h),
                  // Header
                  Text(
                    'Candidates',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dynamicText,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    'Manage job applications, review candidate profiles, and track their hiring progress.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: AppColors.dynamicSubtitle,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 17.h),

                  // Search Bar
                  Container(
                    height: 43.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: Color(0xFFE6E6E6)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 11.w),
                        Icon(
                          Icons.search,
                          color: Color(0xFFA6A6A6),
                          size: 18.w,
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              color: AppColors.dynamicText,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Search by name, email, phone or skill...',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.sp,
                                color: Color(0xFFA6A6A6),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: AppColors.primary,
                            size: 18.w,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Filters (Horizontal tabs)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            'All',
                            'Under Review',
                            'Shortlisted',
                            'Rejected',
                          ].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: 7.w,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                  18.r,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.dynamicCardBg,
                                    borderRadius: BorderRadius.circular(
                                      18.r,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.dynamicBorder.withOpacity(
                                              0.3,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    filter == 'All'
                                        ? '${_candidates.length} Applications'
                                        : filter,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.dynamicText,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Candidates List
                  _isLoading
                      ? Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : filteredList.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40.h, bottom: 40.h),
                                child: Text(
                                  'No candidates found',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.sp,
                                    color: AppColors.dynamicSubtitle,
                                  ),
                                ),
                              ),
                            )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                          ),
                          itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final candidate = filteredList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CandidateProfileScreen(candidate: candidate),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: 18.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFEFEFE,
                                    ), // Background: #FEFEFE
                                    borderRadius: BorderRadius.circular(
                                      11.r,
                                    ),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFEDEDED,
                                      ), // Border: #EDEDED
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0F000000), // #0000000F
                                        offset: Offset(0, 4),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Color(0x0A000000), // #0000000A
                                        offset: Offset(0, 0),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 12.h,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Avatar Placeholder
                                                CircleAvatar(
                                                  radius: 24.r,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withOpacity(0.1),
                                                  child: Text(
                                                    candidate.name[0],
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          14.sp,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 11.w,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        candidate.name,
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize:
                                                              13.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors
                                                              .dynamicText,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            2.h,
                                                      ),
                                                      Text(
                                                        candidate.role,
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize:
                                                              12.sp,
                                                          color: Color(
                                                            0xFF4A4A4A,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            2.h,
                                                      ),
                                                      Text(
                                                        candidate.experience,
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize:
                                                              11.sp,
                                                          color: Color(
                                                            0xFF818181,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  padding: EdgeInsets.zero,
                                                  color: Colors.white,
                                                  constraints: BoxConstraints(
                                                    minWidth: 120.w,
                                                  ),
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color: const Color(
                                                      0xFF6C757D,
                                                    ),
                                                    size: 18.w,
                                                  ),
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                  onSelected: (String action) {
                                                    final originalIndex = _candidates.indexOf(candidate);
                                                    if (originalIndex != -1) {
                                                      setState(() {
                                                        _candidates[originalIndex] = CandidateModel(
                                                          name: candidate.name,
                                                          role: candidate.role,
                                                          experience: candidate.experience,
                                                          phone: candidate.phone,
                                                          location: candidate.location,
                                                          status: action,
                                                          appliedDate: candidate.appliedDate,
                                                          expectedSalary: candidate.expectedSalary,
                                                          education: candidate.education,
                                                          languages: candidate.languages,
                                                          skills: candidate.skills,
                                                          matchScore: candidate.matchScore,
                                                        );
                                                      });
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (
                                                        BuildContext context,
                                                      ) => <PopupMenuEntry<String>>[
                                                        const PopupMenuItem(
                                                          value: 'Shortlisted',
                                                          child: Text('Shortlist', style: TextStyle(fontFamily: 'Poppins')),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'Rejected',
                                                          child: Text(
                                                            'Reject',
                                                            style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: Color(0xFFB1B1B1),
                                        thickness: 0.3,
                                        height: 1,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 12.h,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 11.w,
                                                      color: Color(0xFF787878),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          5.w,
                                                    ),
                                                    Text(
                                                      candidate.phone,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize:
                                                            11.sp,
                                                        color: Color(
                                                          0xFF676767,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 4.h,
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 11.w,
                                                      color: Color(0xFF787878),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          5.w,
                                                    ),
                                                    Text(
                                                      candidate.location,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize:
                                                            11.sp,
                                                        color: Color(
                                                          0xFF676767,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // Status Badge
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 11.w,
                                                vertical: 5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusBgColor(
                                                  candidate.status,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      14.r,
                                                    ),
                                              ),
                                              child: Text(
                                                candidate.status,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getStatusTextColor(
                                                    candidate.status,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
      ),
    );
  }
}

import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/delete_job_api_service.dart';
import 'models.dart';

class JobsOverviewScreen extends StatefulWidget {
  final List<JobModel> jobs;
  final Function(JobModel) onJobSelected;
  final Function(JobModel) onEditJob;
  final Function(JobModel) onDuplicateJob;
  final Function(JobModel) onDeleteJob;
  final VoidCallback onCreateJobPressed;

  const JobsOverviewScreen({
    super.key,
    required this.jobs,
    required this.onJobSelected,
    required this.onEditJob,
    required this.onDuplicateJob,
    required this.onDeleteJob,
    required this.onCreateJobPressed,
  });

  @override
  State<JobsOverviewScreen> createState() => _JobsOverviewScreenState();
}

class _JobsOverviewScreenState extends State<JobsOverviewScreen> {
  String _selectedTab = 'All'; // 'All', 'Active', 'Expired', 'Closed'
  String _sortBy = 'Newest First';

  static const String _fontFamily = 'Poppins';

  List<JobModel> get _filteredJobs {
    var filtered = widget.jobs.where((job) {
      if (_selectedTab == 'All') return true;
      return job.status == _selectedTab;
    }).toList();

    if (_sortBy == 'Newest First') {
      // Sort newest first by parsing id or index
      filtered.sort((a, b) => b.id.compareTo(a.id));
    } else if (_sortBy == 'Oldest First') {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    } else {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    }
    return filtered;
  }

  int _getTabCount(String tab) {
    if (tab == 'All') return widget.jobs.length;
    return widget.jobs.where((job) => job.status == tab).length;
  }

  Future<void> _confirmDeleteJob(BuildContext context, JobModel job) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Job'),
          content: const Text('Are you sure you want to delete this job?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext loadingContext) =>
            const Center(child: CircularProgressIndicator()),
      );

      final result = await DeleteJobApiService.deleteJob(job.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading

      if (result != null && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job deleted successfully')),
        );
        widget.onDeleteJob(job);
      } else {
        final errorMsg = result?['message'] ?? 'Failed to delete job';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredJobs;

    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Stack(
        children: [
          Column(
            children: [
              // App Bar
              const CustomAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  //physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),

                        // Title Section
                        Text(
                          'Jobs Overview',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicText,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'Manage your job postings, track applications, and update job status.',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 13.sp,
                            color: AppColors.dynamicSubtitle,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // Filter tabs: All, Active, Expired, Closed
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          //physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: ['All', 'Active', 'Expired', 'Closed']
                                .asMap()
                                .entries
                                .map((entry) {
                                  final int index = entry.key;
                                  final String tab = entry.value;
                                  final isSelected = _selectedTab == tab;
                                  final count = _getTabCount(tab);
                                  String tabText = tab == 'All'
                                      ? 'All'
                                      : '$tab Jobs';
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index == 3 ? 0 : 11.w,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedTab = tab;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(18.r),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 18.w,
                                          vertical: 7.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF0D6EFD)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18.r,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF0D6EFD)
                                                : AppColors.dynamicBorder
                                                      .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '$tabText ( $count )',
                                          style: TextStyle(
                                            fontFamily: _fontFamily,
                                            fontSize: 12.sp,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.dynamicSubtitle,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 18.h),

                        // Sort dropdown row
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7.r),
                            border: Border.all(color: Color(0xFFDFDFDF)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.swap_vert,
                                      size: 16.w,
                                      color: const Color(0xFF000000),
                                    ),
                                    SizedBox(width: 7.w),
                                    Text(
                                      'Sort By',
                                      style: TextStyle(
                                        fontFamily: _fontFamily,
                                        fontSize: 13.sp,
                                        color: const Color(0xFF000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 25.h,
                                color: Color(0xFFA7A7A7),
                              ),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _sortBy,
                                    isExpanded: true,
                                    icon: Padding(
                                      padding: EdgeInsets.only(right: 7.w),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 18.w,
                                        color: const Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _sortBy = newValue;
                                        });
                                      }
                                    },
                                    items:
                                        <String>[
                                          'Newest First',
                                          'Oldest First',
                                          'Alphabetical',
                                        ].map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Center(
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontFamily: _fontFamily,
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(
                                                    0xFF000000,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),

                        // Job Listings Header Title
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Jobs Listing ',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dynamicText,
                                ),
                              ),
                              TextSpan(
                                text: '( ${filteredList.length} )',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 14.sp,
                                  color: const Color(0xFF8C8C8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 17.h),

                        // Job List
                        filteredList.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 40.h,
                                    bottom: 40.h,
                                  ),
                                  child: Text(
                                    'No jobs found in this category.',
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 13.sp,
                                      color: AppColors.dynamicSubtitle,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 40.h),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final job = filteredList[index];
                                  return Card(
                                    elevation: 0,
                                    color: Colors.white,
                                    margin: EdgeInsets.only(bottom: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      side: BorderSide(
                                        color: Color(0xFFDFDFDF),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () => widget.onJobSelected(job),
                                      borderRadius: BorderRadius.circular(11.r),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 5.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Row 1: Title, Status Badge, Popup Menu
                                            Row(
                                              children: [
                                                Text(
                                                  job.title,
                                                  style: TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF1E1E1E,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 22.w),
                                                // Status badge
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 14.w,
                                                    vertical: 5.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF0FDF4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14.r,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          job.status == 'Active'
                                                          ? const Color(
                                                              0xFF19893F,
                                                            )
                                                          : const Color(
                                                              0xFFDC3545,
                                                            ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        job.status,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              _fontFamily,
                                                          fontSize: 9.sp,
                                                          color:
                                                              job.status ==
                                                                  'Active'
                                                              ? const Color(
                                                                  0xFF19893F,
                                                                )
                                                              : const Color(
                                                                  0xFFDC3545,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                // Context pop-up menu button with Figma Col 4 options
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
                                                    if (action == 'edit') {
                                                      widget.onEditJob(job);
                                                    } else if (action ==
                                                        'delete') {
                                                      _confirmDeleteJob(
                                                        context,
                                                        job,
                                                      );
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (
                                                        BuildContext context,
                                                      ) => <PopupMenuEntry<String>>[
                                                        PopupMenuItem<String>(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                size: 16.w,
                                                                color: AppColors
                                                                    .dynamicText,
                                                              ),
                                                              SizedBox(
                                                                width: 11.w,
                                                              ),
                                                              Text(
                                                                'Edit Job',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      _fontFamily,
                                                                  fontSize:
                                                                      13.sp,
                                                                  color: AppColors
                                                                      .dynamicText,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const PopupMenuDivider(),
                                                        PopupMenuItem<String>(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                size: 16.w,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              SizedBox(
                                                                width: 11.w,
                                                              ),
                                                              Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      _fontFamily,
                                                                  fontSize:
                                                                      13.sp,
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                ),
                                              ],
                                            ),
                                            // Row 2: Location
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 13.w,
                                                  color: const Color(
                                                    0xFF6C757D,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  job.location.isNotEmpty
                                                      ? job.location
                                                      : 'Location not specified',
                                                  style: TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 12.sp,
                                                    color: const Color(
                                                      0xFF6C757D,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10.h),
                                            // Row 3: Details (Date, Views, Openings)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 13.w,
                                                  color: const Color(
                                                    0xFF6C757D,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  'Posted On : ${job.datePosted.isNotEmpty ? job.datePosted.split(' ').first : 'N/A'}',
                                                  style: TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 11.sp,
                                                    color: const Color(
                                                      0xFF6C757D,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15.w),
                                                Container(
                                                  height: 15.h,
                                                  width: 0.6.w,
                                                  color: const Color(
                                                    0xFF878787,
                                                  ),
                                                ),
                                                SizedBox(width: 15.w),
                                                Icon(
                                                  Icons.visibility_outlined,
                                                  size: 13.w,
                                                  color: const Color(
                                                    0xFF6C757D,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  '351',
                                                  style: TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 11.sp,
                                                    color: const Color(
                                                      0xFF6C757D,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15.w),
                                                Container(
                                                  height: 15.h,
                                                  width: 0.6.w,
                                                  color: const Color(
                                                    0xFF878787,
                                                  ),
                                                ),
                                                SizedBox(width: 15.w),
                                                Image.asset(
                                                  'assets/images/appbar.png',
                                                  width: 15.w,
                                                  height: 15.h,
                                                  color: const Color(
                                                    0xFF6C757D,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  job.openings.toString(),
                                                  style: TextStyle(
                                                    fontFamily: _fontFamily,
                                                    fontSize: 11.sp,
                                                    color: const Color(
                                                      0xFF6C757D,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10.h),
                                          ],
                                        ),
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
          // Fixed floating button at the bottom center
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 35.h,
                child: ElevatedButton.icon(
                  onPressed: widget.onCreateJobPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    elevation: 6,
                  ),
                  icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
                  label: Text(
                    'Post a new job',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

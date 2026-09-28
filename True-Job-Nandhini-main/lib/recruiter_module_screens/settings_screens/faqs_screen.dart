import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I post a job?',
      'answer': 'Go to the Jobs section and tap on "Post a Job". Fill in the job details, add requirements, and click on Publish. Your job will be live and visible to candidates.',
    },
    {
      'question': 'How can I view my posted jobs ?',
      'answer': 'You can view your posted jobs by navigating to the dashboard and selecting "My Jobs".',
    },
    {
      'question': 'How do I manage application ?',
      'answer': 'Navigate to the applications section to see all candidates who applied to your job posts.',
    },
    {
      'question': 'How do I schedule an interview ?',
      'answer': 'Select a candidate\'s application and click on "Schedule Interview" to pick a date and time.',
    },
    {
      'question': 'Can I Edit or close a job post',
      'answer': 'Yes, you can edit or close an active job post from the job details page.',
    },
    {
      'question': 'How can I update my company profile ?',
      'answer': 'Go to Settings > Company Profile to update your details.',
    },
    {
      'question': 'Is there any cost to post a job?',
      'answer': 'Job posting costs depend on your current subscription plan.',
    },
    {
      'question': 'How can i contact support?',
      'answer': 'You can contact support via the Contact Us screen in the app.',
    },
  ];

  int _expandedIndex = 0; // Default first item expanded

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  SizedBox(height: 28.h),
                  // Header Row "< FAQs"
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 14.sp, color: AppColors.dynamicText),
                        SizedBox(width: 7.w),
                        Text(
                          'FAQs',
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
                  SizedBox(height: 22.h),

                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFEFE),
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: const Color(0xFFAAAAAA), size: 18.sp),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              color: AppColors.dynamicText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search for help topics...',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.sp,
                                color: AppColors.secondary_color,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 22.h),
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: AppColors.secondary_color,
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // FAQ List
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqs.length,
                    itemBuilder: (context, index) {
                      final faq = _faqs[index];
                      final isExpanded = _expandedIndex == index;

                      return Container(
                        margin: EdgeInsets.only(bottom: 11.h),
                        decoration: BoxDecoration(
                          color: isExpanded ? const Color(0xFFF8F9FA) : Colors.white,
                          borderRadius: BorderRadius.circular(11.r),
                          border: Border.all(color: const Color(0xFFE3E3E3)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            key: Key(index.toString()),
                            initiallyExpanded: isExpanded,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                if (expanded) {
                                  _expandedIndex = index;
                                } else {
                                  _expandedIndex = -1;
                                }
                              });
                            },
                            title: Text(
                              faq['question']!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.dynamicText,
                              ),
                            ),
                            iconColor: AppColors.secondary_color,
                            collapsedIconColor: AppColors.secondary_color,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 14.w,
                                  right: 14.w,
                                  bottom: 14.h,
                                ),
                                child: Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.sp,
                                    color: AppColors.secondary_color,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 14.h),

                  // Still need help card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FE),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(9.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3E4FC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.headset_mic_outlined, color: const Color(0xFF055BF2), size: 18.sp),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Still need help ?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.dynamicText,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Our support team is here for you',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.sp,
                                  color: AppColors.secondary_color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to contact us
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF3E7BFA)),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Contact Us',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.sp,
                                color: const Color(0xFF3E7BFA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

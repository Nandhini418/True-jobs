import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  String _selectedTab = 'All';
  static const String _fontFamily = 'Poppins';

  final List<Map<String, dynamic>> _transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dynamicBg,
      body: Column(
        children: [
          const CustomAppBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Back header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            size: 14.sp,
                            color: AppColors.dynamicText,
                          ),
                          SizedBox(width: 7.w),
                          Text(
                            'Credits & Usage',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dynamicText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Available Credits Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14319B),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Credits',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              SizedBox(width: 7.w),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Text(
                                  'Credits',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Stats row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11.r),
                        border: Border.all(color: const Color(0xFFE6E6E6)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            icon: Icons.shopping_bag_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            value: '0',
                            label: 'Total Purchased',
                            sub: 'Credits',
                          ),
                          Container(width: 1, height: 56.h, color: const Color(0xFFE5E7EB)),
                          _buildStatItem(
                            icon: Icons.bolt_outlined,
                            iconColor: const Color(0xFFA855F7),
                            value: '0',
                            label: 'Credit used',
                            sub: 'Credits',
                          ),
                          Container(width: 1, height: 56.h, color: const Color(0xFFE5E7EB)),
                          _buildStatItem(
                            icon: Icons.calendar_today_outlined,
                            iconColor: const Color(0xFF64748B),
                            value: 'No expiry',
                            label: 'Credit expiry',
                            sub: '',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Transaction History header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Text(
                      'Transaction History',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dynamicText,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Filter tabs (scrollable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      children: ['All', 'Credits Added', 'Credits Spent'].map((tab) {
                        final isSelected = _selectedTab == tab;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: Container(
                            margin: EdgeInsets.only(right: 7.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.dynamicText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: _transactions.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 14.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          )
                        : Column(
                            children: _transactions.map((tx) => _buildTransactionItem(tx)).toList(),
                          ),
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

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String sub,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 10.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.dynamicText,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 9.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    return Container(
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 13.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'],
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dynamicText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  tx['subtitle'],
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  tx['date'],
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['amount'],
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                tx['time'],
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 10.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';
import 'package:truejobs/recruiter_module_screens/drawer_sections/update_gstin_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String _selectedTab = 'All';
  static const String _fontFamily = 'Poppins';

  final List<Map<String, dynamic>> _transactions = [];

  Color _statusColor(String status) {
    switch (status) {
      case 'Processing':
        return const Color(0xFF004AC6);
      case 'Success':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF97316);
      case 'Failed':
        return const Color(0xFFEF4444);
      case 'Cancelled':
        return const Color(0xFF434655);
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedTab == 'All') return _transactions;
    return _transactions.where((tx) {
      if (_selectedTab == 'Success') return tx['status'] == 'Success';
      if (_selectedTab == 'Pending') return tx['status'] == 'Pending';
      if (_selectedTab == 'Failed') return tx['status'] == 'Failed' || tx['status'] == 'Cancelled';
      return true;
    }).toList();
  }

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
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Back header
                  InkWell(
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
                          'Billing',
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

                  SizedBox(height: 20.h),

                  // Company card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
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
                        Row(
                          children: [
                            Text(
                              'Smart Global solution',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dynamicText,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDAFFE6),
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: const Color(0xFF40AC69), size: 12.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF40AC69),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              'GSTIN: ',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              '33ADWFS2I64G1ZS',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.secondary_color,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(const ClipboardData(text: '33ADWFS2I64G1ZS'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('GSTIN copied'), duration: Duration(seconds: 1)),
                                );
                              },
                              child: Icon(Icons.copy_outlined, size: 14.sp, color: const Color(0xFF464455)),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Address: ',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary_color,
                                ),
                              ),
                              TextSpan(
                                text:
                                '22-B, 9th Street, Sri Vana Bathra Kaliamman Temple, '
                                    'Sri Krishna Nagar, Irugur, Coimbatore, Tamil Nadu, 641103',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondary_color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Update GSTIN button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const UpdateGstinScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 11.h),
                            ),
                            child: Text(
                              'Update ISD-GSTIN / GSTIN',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Billing History header
                  Text(
                    'Billing History',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dynamicText,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Filter tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Success', 'Pending', 'Failed'].map((tab) {
                        final isSelected = _selectedTab == tab;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: Container(
                            margin: EdgeInsets.only(right: 9.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF434655),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0xFFC5C5C5), thickness: 0.6, height: 1,),
                  SizedBox(height: 16.h),

                  // Transactions
                  _filteredTransactions.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Center(
                            child: Text(
                              'No result found',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 14.sp,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            ..._filteredTransactions.map((tx) => _buildTransactionItem(tx)),
                            SizedBox(height: 12.h),
                            // Pagination
                            Center(
                              child: Text(
                                'Showing 1-5 of 37 results',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 11.sp,
                                  color: const Color(0xFF434655),
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildPageButton(Icons.chevron_left, null),
                                _buildPageNumber('1', true),
                                _buildPageNumber('2', false),
                                _buildPageNumber('3', false),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Text('...', style: TextStyle(fontFamily: _fontFamily, fontSize: 13.sp, color: const Color(0xFF64748B))),
                                ),
                                _buildPageNumber('10', false),
                                _buildPageButton(Icons.chevron_right, null),
                              ],
                            ),
                            SizedBox(height: 32.h),
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

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['date'],
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dynamicText,
                        ),
                      ),
                      SizedBox(height: 4.h,),
                      Text(
                        tx['time'],
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 11.sp,
                          color: const Color(0xFF434655),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dynamicText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(tx['status']),
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      child: Text(
                        tx['status'],
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 11.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tx['plan'],
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp,
                  color: const Color(0xFF434655),
                ),
              ),
              Icon(Icons.more_vert, color: const Color(0xFF000000), size: 18.sp),
            ],
          ),
          SizedBox(height: 7.h,),
          const Divider(color: Color(0xFFC5C5C5), thickness: 0.6),
        ],
      ),
    );
  }

  Widget _buildPageButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 14.sp, color: const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildPageNumber(String number, bool isActive) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: isActive ? AppColors.primary : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

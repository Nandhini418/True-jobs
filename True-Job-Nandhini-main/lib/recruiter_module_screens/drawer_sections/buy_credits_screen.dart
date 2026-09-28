import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/widgets/custom_app_bar.dart';

class BuyCreditsScreen extends StatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  State<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends State<BuyCreditsScreen> {
  int _selectedPlanIndex = 1; // Default: Professional (middle plan)
  bool _faq1Open = false;
  bool _faq2Open = false;
  bool _faq3Open = false;
  bool _faq4Open = false;

  static const String _fontFamily = 'Poppins';
  static const Duration _animDuration = Duration(milliseconds: 350);
  static const Curve _animCurve = Curves.easeInOutCubic;

  final List<Map<String, dynamic>> _plans = [
    {
      'tag': 'Basic',
      'label': '1 Month Plan',
      'price': '₹499',
      'credits': '100 Credits',
      'description': 'Great for small businesses hiring occasionally.',
      'features': [
        'Post up to 5 Jobs',
        'Unlock 50 Candidate Profiles',
        'Standard Job Listings',
        'Basic Candidate Matching',
        'Valid for 1 Month',
      ],
    },
    {
      'tag': 'Professional',
      'label': '2 Month Plan',
      'price': '₹1,299',
      'credits': '300 Credits',
      'description': 'Best value for growing businesses hiring regularly.',
      'features': [
        'Post up to 20 Jobs',
        'Unlock 100 Candidate Profiles',
        'Featured Job Listings',
        'Priority Candidate Matching',
        'Valid for 12 Months',
      ],
    },
    {
      'tag': 'Business',
      'label': '3 Month Plan',
      'price': '₹2,799',
      'credits': '100 Credits',
      'description': 'Ideal for large teams with high-volume hiring needs.',
      'features': [
        'Post up to 50 Jobs',
        'Unlock 300 Candidate Profiles',
        'Premium Job Listings',
        'AI-Powered Matching',
        'Employer Badge',
        'Valid for 3 Months',
      ],
    },
  ];

  void _selectPlan(int index) {
    if (index >= 0 && index < _plans.length && index != _selectedPlanIndex) {
      setState(() => _selectedPlanIndex = index);
    }
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
              //physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Back header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
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
                            'Buy Credits',
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

                  // Hero section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [
                                Color(0xFF2765EF), // 0%
                                Color(0xFF00723D), // 32.69%
                                Color(0xFFBFDD16), // 63.94%
                                Color(0xFF0038B7), // 100%
                              ],
                              stops: [0.0, 0.3269, 0.6394, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Supercharge Your Hiring',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // Required for ShaderMask
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Choose the perfect credit package to post jobs, unlock resumes, and connect with top talent faster.',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12.sp,
                            color: const Color(0x88292929),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Plan cards — Stack-based overlapping carousel
                  _buildPlanCarousel(),

                  SizedBox(height: 16.h),

                  // Enterprise section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8F9FF), Color(0xFFEDEFFF)],
                          stops: [0.5, 1.0],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(11.r),
                        border: Border.all(color: const Color(0xFFCFCFCF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 36.w,
                            height: 36.w,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/shine_star.png',
                                width: 18.w,
                                height: 18.w,
                              ),
                              SizedBox(width: 7.w),
                              Text(
                                'Enterprise',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dynamicText,
                                ),
                              ),
                              SizedBox(width: 7.w),
                              Text(
                                '(customising)',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          _buildFeatureRow('Unlimited Credits'),
                          _buildFeatureRow('Unlimited Job Posts'),
                          _buildFeatureRow('Unlimited Candidate Access'),
                          _buildFeatureRow('Dedicated Account Manager'),
                          SizedBox(height: 8.h),
                          Text(
                            'Tailored for large organizations with high-volume hiring and custom recruitment requirements.',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Have More Questions section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000), // #00000014
                            offset: Offset(0, 8),
                            blurRadius: 16,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/contacts.png', width: 54.w, height: 54.w,),
                          SizedBox(height: 8.h),
                          Text(
                            'Have More Questions? We\'re Here to Help',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dynamicText,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Tell us more about your hiring needs so we can help you pick the right solution.',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              height: 1.5
                            ),
                          ),
                          SizedBox(height: 12.h),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF055BF2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  7.r,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 7.h,
                              ),
                            ),
                            child: Text(
                              'Contact Us',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Here's Why Recruiters Trust Us
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: Text(
                      "Here's Why Recruiters Trust Us",
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.dynamicText,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: Text(
                      'Testimonials from valued clients who’ve elevated their hiring with True Jobs',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 11.sp,
                        height: 1.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 160.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                      ),
                      children: [
                        _buildTestimonialCard(
                          'Sarah K.',
                          'HR Manager',
                          'The candidate matching was incredibly accurate — we filled our key positions in record time.',
                        ),
                        _buildTestimonialCard(
                          'James R.',
                          'Tech Lead',
                          'True Jobs simplified our entire hiring process. Highly recommended!',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // FAQs
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAQs',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dynamicText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                  Text(
                    'Our FAQ section offers quick answers to common questions, helping you find information easily.',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 11.sp,
                      height: 1.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                        SizedBox(height: 12.h),
                        _buildFAQ(
                          'Enter Question Here',
                          'This is the answer to the frequently asked question about our credits and plans.',
                          _faq1Open,
                          () => setState(() => _faq1Open = !_faq1Open),
                        ),
                        _buildFAQ(
                          'Enter Question Here',
                          'This is the answer to the frequently asked question about our credits and plans.',
                          _faq2Open,
                          () => setState(() => _faq2Open = !_faq2Open),
                        ),
                        _buildFAQ(
                          'Enter Question Here',
                          'This is the answer to the frequently asked question about our credits and plans.',
                          _faq3Open,
                          () => setState(() => _faq3Open = !_faq3Open),
                        ),
                        _buildFAQ(
                          'Enter Question Here',
                          'This is the answer to the frequently asked question about our credits and plans.',
                          _faq4Open,
                          () => setState(() => _faq4Open = !_faq4Open),
                        ),
                      ],
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

  /// Stack-based overlapping plan carousel
  Widget _buildPlanCarousel() {
    // ── Main card (Figma: 240 × 370 on a 360×780 frame) ──────────────────
    final double mainCardW = 240.w;
    final double mainCardH = 370.h;
    final double mainCardLeft = (1.sw - mainCardW) / 2; // centered

    // ── Side cards (Figma: 186×287) ───────────────────────────────────────
    final double sideW = 186.w;
    final double sideH = 287.h;

    // Vertical: side card top offset relative to main card top
    final double sideTopOffset = 34.h;

    // ── Horizontal positions ──────────────────────────────────────────────
    // Left card: Figma left = -60px
    final double leftCardLeft = -60.w;

    // Right card: Figma left = 233.46px
    final double rightCardLeft = 233.w;

    return ClipRect(
      child: SizedBox(
        height: mainCardH + 16,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -200 &&
                  _selectedPlanIndex < _plans.length - 1) {
                _selectPlan(_selectedPlanIndex + 1);
              } else if (details.primaryVelocity! > 200 &&
                  _selectedPlanIndex > 0) {
                _selectPlan(_selectedPlanIndex - 1);
              }
            }
          },
          child: Stack(
            clipBehavior: Clip.none, // AnimatedPositioned uses negative left
            children:
                List.generate(_plans.length, (index) {
                    final int offset = index - _selectedPlanIndex;
                    final bool isSelected = offset == 0;

                    double left;
                    double top;
                    double width;
                    double height;
                    double opacity;

                    if (isSelected) {
                      // ── Selected card: full size, centered ──────────────────
                      left = mainCardLeft;
                      top = 0;
                      width = mainCardW;
                      height = mainCardH;
                      opacity = 1.0;
                    } else if (offset == -1) {
                      // ── Left adjacent: starts at -60/360·sw, behind main ────
                      left = leftCardLeft;
                      top = sideTopOffset;
                      width = sideW;
                      height = sideH;
                      opacity = 0.70;
                    } else if (offset == 1) {
                      // ── Right adjacent: starts at 233/360·sw, behind main ───
                      left = rightCardLeft;
                      top = sideTopOffset;
                      width = sideW;
                      height = sideH;
                      opacity = 0.70;
                    } else {
                      // ── Fully hidden off-screen ──────────────────────────────
                      left = offset < 0
                          ? leftCardLeft - sideW
                          : rightCardLeft + sideW;
                      top = sideTopOffset;
                      width = sideW;
                      height = sideH;
                      opacity = 0.0;
                    }

                    return AnimatedPositioned(
                      key: ValueKey(index),
                      duration: _animDuration,
                      curve: _animCurve,
                      left: left,
                      top: top,
                      width: width,
                      height: height,
                      child: AnimatedOpacity(
                        duration: _animDuration,
                        curve: _animCurve,
                        opacity: opacity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.r),
                          child: GestureDetector(
                            onTap: () => _selectPlan(index),
                            child: _buildPlanCard(
                              plan: _plans[index],
                              isSelected: isSelected,
                              cardWidth: width,
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  ..sort((a, b) {
                    final aOffset =
                        ((a.key as ValueKey<int>).value - _selectedPlanIndex)
                            .abs();
                    final bOffset =
                        ((b.key as ValueKey<int>).value - _selectedPlanIndex)
                            .abs();
                    return bOffset.compareTo(aOffset);
                  }),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required bool isSelected,
    required double cardWidth,
  }) {
    // Side cards are narrower and shorter — scale fonts & spacing down by 30%
    final double sf = isSelected ? 1.0 : 0.70;

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      padding: EdgeInsets.symmetric(
        horizontal: 17.w,
        vertical: 13.h * sf,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFCFCFCF), width: 0.63),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // #00000014
            offset: Offset(0, 8),
            blurRadius: 16,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          // ── Tag badge ──────────────────────────────────────────────────────
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w * sf,
                vertical: 4.h * sf,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                plan['tag'],
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12.sp * sf,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h * sf),

          // ── Plan name ──────────────────────────────────────────────────────
          Center(
            child: Text(
              plan['label'],
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 17.sp * sf,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h * sf),

          // ── Price ──────────────────────────────────────────────────────────
          Center(
            child: Text(
              plan['price'],
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16.sp * sf,
                fontWeight: FontWeight.w600,
                color: AppColors.dynamicText,
              ),
            ),
          ),
          SizedBox(height: 8.h * sf),
          Image.asset(
            'assets/images/credit_line.png',
            height: 1,
            width: double.infinity,
          ),
          SizedBox(height: 8.h * sf),

          // ── Credits ────────────────────────────────────────────────────────
          Center(
            child: Text(
              plan['credits'],
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 14.sp * sf,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary_color,
              ),
            ),
          ),
          SizedBox(height: 16.h * sf),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List<Widget>.from(
                    (plan['features'] as List<String>).map(
                      (f) => Padding(
                        padding: EdgeInsets.only(
                          bottom: 4.h * sf,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/shine_star.png',
                              height: 20.h * sf,
                              width: 9.w * sf,
                            ),
                            SizedBox(width: 7.w * sf),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 11.sp * sf,
                                  color: AppColors.dynamicText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h * sf),
                  Text(
                    plan['description'],
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 10.sp * sf,
                      color: AppColors.secondary_color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h * sf),

          // ── Buy Now ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical: 7.h * sf,
                ),
              ),
              child: Text(
                'Buy Now',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14.sp * sf,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        children: [
          Image.asset(
            'assets/images/shine_star.png',
            width: 11.w,
            height: 11.w,
          ),
          SizedBox(width: 9.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 13.sp,
              color: AppColors.dynamicText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
    String name,
    String role,
    String quote,
  ) {
    return Container(
      width: 252.w,
      margin: EdgeInsets.only(right: 11.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14.w,
                backgroundColor: const Color(0xFF005C62),
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 11.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    role,
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
          SizedBox(height: 11.h),
          Text(
            '"$quote"',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 11.sp,
              color: const Color(0xFF475569),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(
    String question,
    String answer,
    bool isOpen,
    VoidCallback onToggle,
  ) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: EdgeInsets.only(bottom: 11.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dynamicText,
                    ),
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
            if (isOpen) ...[
              SizedBox(height: 7.h),
              Text(
                answer,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 11.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

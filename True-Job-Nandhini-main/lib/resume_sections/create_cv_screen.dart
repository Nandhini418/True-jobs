import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truejobs/resume_sections/resume_model_selection_screen.dart';
import 'package:truejobs/utils/smooth_page_route.dart';

class CreateCvScreen extends StatefulWidget {
  const CreateCvScreen({super.key});

  @override
  State<CreateCvScreen> createState() => _CreateCvScreenState();
}

class _CreateCvScreenState extends State<CreateCvScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Floating Profile Image Animation
  late AnimationController _floatingAnimController;
  late Animation<double> _floatingAnim;

  // For Auto-scrolling banner
  late PageController _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  final List<String> _bannerTexts = [
    'Enhance your CV with our expert content',
    'Apply for jobs with confidence',
    'Expert tips & guidance',
    'Professionally designed template',
  ];

  // For Hero Section Auto-scrolling text
  late PageController _heroTextPageController;
  Timer? _heroTextTimer;
  int _currentHeroTextIndex = 0;
  final List<String> _heroTexts = ['ATS Checking', 'Template', 'CV builder'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    // Setup floating animation
    _floatingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatingAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingAnimController, curve: Curves.easeInOutSine),
    );

    _bannerPageController = PageController(initialPage: 0, viewportFraction: 0.75);
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentBannerIndex =
          (_currentBannerIndex + 1) % _bannerTexts.length;
      if (_bannerPageController.hasClients) {
        _bannerPageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });

    _heroTextPageController = PageController(initialPage: 0);
    _heroTextTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _currentHeroTextIndex =
          (_currentHeroTextIndex + 1) % _heroTexts.length;
      if (_heroTextPageController.hasClients) {
        _heroTextPageController.animateToPage(
          _currentHeroTextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _floatingAnimController.dispose();
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _heroTextTimer?.cancel();
    _heroTextPageController.dispose();
    super.dispose();
  }

  final List<String> _templates = [
    'assets/cv-temp1.png',
    'assets/cv-temp2.png',
    'assets/cv-temp3.png',
    'assets/cv-temp4.png',
  ];

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeroBanner(sw),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActionButtons(sw),
                    _buildTagline(sw),
                    const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 20,
                        endIndent: 20),
                    _buildEnhanceBanner(sw),
                    _buildPickTemplateHeader(sw),
                    _buildTemplateGrid(sw),
                    _buildViewMoreButton(sw),
                    _buildHowItWorksSection(sw),
                    SizedBox(height: sw * 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HERO BANNER ──────────────────────────────────────────────────────────
  Widget _buildHeroBanner(double sw) {
    final double topPad = MediaQuery.of(context).padding.top;
    final double bannerHeight = sw * 0.85; // Increased to fit the image properly

    return Container(
      width: double.infinity,
      height: bannerHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Back Button ──
          Positioned(
            top: topPad + 8,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── Text content (left side) ──
          Positioned(
            left: sw * 0.05,
            top: topPad + sw * 0.12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Fast. Easy. Effective."
                Text(
                  'Fast. Easy. Effective.',
                  style: TextStyle(
                    color: const Color(0xFF2ECC71),
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: sw * 0.015),

                // "Create ATS Friendly\nCV"
                Text(
                  'Create ATS Friendly\nCV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.065,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: sw * 0.04),

                // Auto-scrolling green dot + text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: sw * 0.022,
                      height: sw * 0.022,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: sw * 0.018),
                    SizedBox(
                      height: sw * 0.06,
                      width: sw * 0.38,
                      child: PageView.builder(
                        controller: _heroTextPageController,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _heroTexts.length,
                        itemBuilder: (context, index) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _heroTexts[index],
                              style: TextStyle(
                                color: const Color(0xFF2ECC71),
                                fontSize: sw * 0.038,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.025),

                // Subtitle paragraph
                SizedBox(
                  width: sw * 0.60,
                  child: Text(
                    'Whether you want to build a new\nCV from scratch or improve an\nexisting one',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.035,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── CV Preview image (right side) ──
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/bg-cv.png',
              width: sw * 0.25,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: sw * 0.38,
                height: sw * 0.46,
                color: Colors.white,
                child: const Icon(Icons.description, color: Colors.grey),
              ),
            ),
          ),

          // ── Profile Image Overlay ──
          Positioned(
            right: sw * 0.20,
            bottom: sw * 0.20,
            child: AnimatedBuilder(
              animation: _floatingAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnim.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2), // For the orange border
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDB022), width: 2.5),
                ),
                child: CircleAvatar(
                  radius: sw * 0.075,
                  backgroundImage: const AssetImage('assets/profile-1.png'),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCvBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create CV',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: const ResumeModelSelectionScreen(),
                        durationMs: 300,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19893F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fetch profile details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    SmoothPageRoute(
                      child: const ResumeModelSelectionScreen(),
                      durationMs: 0,
                    ),
                  );
                },
                child: const Text(
                  'Not now',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── TWO ACTION BUTTONS ───────────────────────────────────────────────────
  Widget _buildActionButtons(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sw * 0.05),
      child: Row(
        children: [
          // "Create cv" — green pill button
          Expanded(
            child: SizedBox(
              height: sw * 0.115,
              child: ElevatedButton(
                onPressed: () {
                  _showCreateCvBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19893F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.06),
                  ),
                ),
                child: Text(
                  'Create cv',
                  style: TextStyle(
                    fontSize: sw * 0.040,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
          // "ATS Checking" — blue/purple pill button
          Expanded(
            child: SizedBox(
              height: sw * 0.115,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF772B88),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.06),
                  ),
                ),
                child: Text(
                  'ATS Checking',
                  style: TextStyle(
                    fontSize: sw * 0.040,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAGLINE ──────────────────────────────────────────────────────────────
  Widget _buildTagline(double sw) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sw * 0.015),
      child: Center(
        child: Text(
          'Help you present your work life, personality,\nand skills on a CV that stands out.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontSize: sw * 0.036,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ─── ENHANCE BANNER (dark card, auto-scrolling) ───────────────────────────
  Widget _buildEnhanceBanner(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          sw * 0.04, sw * 0.035, sw * 0.04, sw * 0.01),
      child: Center(
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.65, 1.0], // Fade out the bottom to create a blur/reflection effect
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            width: 328,
            height: 80, // Extended height to show the next item peeking
            child: PageView.builder(
              controller: _bannerPageController,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bannerTexts.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    // Gap so they don't touch while scrolling
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      width: 328,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Numbered green jagged star badge
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF19893F), // Verified Green
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 0.785398, // 45 degrees in radians
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF19893F),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _bannerTexts[index],
                              style: const TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── PICK A CV TEMPLATE HEADER ────────────────────────────────────────────
  Widget _buildPickTemplateHeader(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          sw * 0.04, sw * 0.045, sw * 0.04, sw * 0.025),
      child: Center(
        child: Text(
          'Pick a CV template',
          style: TextStyle(
            color: Colors.black,
            fontSize: sw * 0.050,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── TEMPLATE GRID ────────────────────────────────────────────────────────
  Widget _buildTemplateGrid(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: sw * 0.03,
          mainAxisSpacing: sw * 0.03,
          // Taller cards — matches screenshot where CV pages fill most of card
          childAspectRatio: 0.62,
        ),
        itemCount: _templates.length,
        itemBuilder: (context, index) => _buildTemplateCard(sw, index),
      ),
    );
  }

  Widget _buildTemplateCard(double sw, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.025),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Template thumbnail — takes most of the card height
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(sw * 0.025)),
              child: Image.asset(
                _templates[index],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(Icons.description,
                      color: Colors.grey, size: sw * 0.12),
                ),
              ),
            ),
          ),

          // "Use Template" blue pill button
          Padding(
            padding: EdgeInsets.all(sw * 0.025),
            child: SizedBox(
              width: double.infinity,
              height: sw * 0.092,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D9CEC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.05),
                  ),
                ),
                child: Text(
                  'Use Template',
                  style: TextStyle(
                    fontSize: sw * 0.034,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── VIEW MORE BUTTON ─────────────────────────────────────────────────────
  Widget _buildViewMoreButton(double sw) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.04),
      child: Center(
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF2ECC71), width: 1.8),
            foregroundColor: const Color(0xFF2ECC71),
            minimumSize: Size(sw * 0.52, sw * 0.118),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sw * 0.06),
            ),
          ),
          child: Text(
            'View more templates',
            style: TextStyle(
              fontSize: sw * 0.038,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ─── HOW IT WORKS ─────────────────────────────────────────────────────────
  // From screenshot: image on left + text right, then text left + image right, alternating
  Widget _buildHowItWorksSection(double sw) {
    final steps = [
      {
        'asset': 'assets/CV3.png',
        'title': 'Pick a CV template.',
        'subtitle': 'Choose a sleek design\nand layout to get started.',
        'imageLeft': true,
      },
      {
        'asset': 'assets/CV2.png',
        'title': 'Fill in the blanks.',
        'subtitle': 'Type in a few words. Let\nthe wizard fill the rest.',
        'imageLeft': false,
      },
      {
        'asset': 'assets/CV1.png',
        'title': 'Customize your document.',
        'subtitle': 'Make it truly yours. Uniqueness\nin a few clicks.',
        'imageLeft': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.map((step) {
        final bool imageLeft = step['imageLeft'] as bool;
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04, vertical: sw * 0.03),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: imageLeft
                ? [
              _buildStepImage(sw, step['asset'] as String),
              SizedBox(width: sw * 0.045),
              _buildStepText(sw, step['title'] as String,
                  step['subtitle'] as String),
            ]
                : [
              _buildStepText(sw, step['title'] as String,
                  step['subtitle'] as String),
              SizedBox(width: sw * 0.045),
              _buildStepImage(sw, step['asset'] as String),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepImage(double sw, String asset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(sw * 0.03),
      child: Image.asset(
        asset,
        width: sw * 0.30,
        height: sw * 0.38,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: sw * 0.30,
          height: sw * 0.38,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(sw * 0.03),
          ),
          child: Icon(Icons.image, color: Colors.grey, size: sw * 0.1),
        ),
      ),
    );
  }

  Widget _buildStepText(double sw, String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: sw * 0.044,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: sw * 0.018),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: sw * 0.034,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
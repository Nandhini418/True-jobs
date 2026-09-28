import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../services/api/profile_select_api.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'total_referred_friends_screen.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key? key}) : super(key: key);

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  bool _isLoading = true;
  String _referCode = '';

  // Dynamic but currently mocked values as discussed
  final int _totalEarnedCoins = 0;
  final int _targetCoins = 200;
  final int _totalReferred = 5;
  final int _userCoins = 85;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId;
      try {
        userId = prefs.getInt('user_id');
      } catch (_) {
        final String? userIdStr = prefs.getString('user_id');
        if (userIdStr != null) {
          userId = int.tryParse(userIdStr);
        }
      }

      if (userId != null) {
        final profileRes = await ProfileSelectApi.fetchProfile(userId: userId);
        if (profileRes['status'] == 'success' || profileRes['error'] == false) {
          final data = profileRes['data'];
          if (data != null && data is Map) {
            setState(() {
              _referCode = data['refer_code']?.toString() ?? 'TRUE12345';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile for refer code: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral code copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/image/coin.png', height: 18, width: 18),
                const SizedBox(width: 6),
                Text(
                  '$_userCoins',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  _buildEarnedCoinsCard(sw),
                  const SizedBox(height: 28),
                  _buildReferralCodeCard(sw),
                  const SizedBox(height: 24),
                  _buildShareButton(sw),
                  const SizedBox(height: 24),
                  _buildTotalReferredCard(sw),
                  const SizedBox(height: 24),
                  _buildHowToEarnSection(sw),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEarnedCoinsCard(double sw) {
    final double progress = _totalEarnedCoins / _targetCoins;
    final int remaining = _targetCoins - _totalEarnedCoins;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x66DDDDDD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xA1BDCEED),
            offset: const Offset(0, 9),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Left side
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Earned Coins',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            'assets/image/coin.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_totalEarnedCoins',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  height: 70,
                  width: 0.8,
                  color: const Color(0x66BFBFBF),
                ),
                // Right side
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$remaining more coins to unlock\nyour reward',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: '$_totalEarnedCoins ',
                                style: const TextStyle(
                                  color: Color(0xFF255EC7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: '/ $_targetCoins Coins'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Color(0x66DDDDDD))),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                  height: 1.8,
                ),
                children: [
                  TextSpan(
                    text: 'Please Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Cashback expires if not withdrawn within 30 days. Minimum withdrawal Coins is 200',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(double sw) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x77EEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEFEAFB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.link, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Referral Code',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  painter: DashedBorderPainter(color: const Color(0xFF255EC7)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Center(
                      child: Text(
                        _referCode.isNotEmpty
                            ? _referCode.split('').join(' ')
                            : 'T R U E',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _copyToClipboard(_referCode),
            icon: const Icon(Icons.copy_rounded, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(double sw) {
    return ElevatedButton.icon(
      onPressed: () {
        Share.share(
          'Hey! Join True Jobs using my referral code: $_referCode\n\nDownload now: https://play.google.com/store/apps/details?id=com.truejobs.app',
        );
      },
      icon: const Icon(Icons.share_outlined, color: Colors.white),
      label: const Text(
        'Share and earn',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF255EC7), // Deep blue
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
    );
  }

  Widget _buildTotalReferredCard(double sw) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TotalReferredFriendsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Total referred',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, color: Colors.black38, size: 18),
              const Spacer(),
              Text(
                '$_totalReferred friends >',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatar('assets/gif/walkthrough 1.gif'),
              _buildTextAvatar('AM', const Color(0xFF2B5CBF)),
              _buildAvatar('assets/gif/walkthrough 2.gif'),
              _buildAvatar('assets/gif/walkthrough 3.gif'),
              _buildAvatar('assets/gif/walkthrough 1.gif'),
              _buildStackedTextAvatar('HG', const Color(0xFF4A80F0)),
            ],
          ),
        ],
      ),
      )
    );
  }

  Widget _buildAvatar(String assetPath) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: AssetImage(assetPath),
      backgroundColor: Colors.grey.shade300,
    );
  }

  Widget _buildTextAvatar(String text, Color color) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStackedTextAvatar(String text, Color color) {
    return SizedBox(
      width: 52,
      height: 44,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.5),
            ),
          ),
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnSection(double sw) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          title: const Text(
            'How to earn:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 24.0,
                top: 8.0,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 35,
                    right: 38,
                    child: CustomPaint(
                      painter: HorizontalDashedLinePainter(
                        color: Colors.grey.shade300,
                      ),
                      size: const Size(double.infinity, 1),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepItem(
                        number: '1',
                        icon: Icons.people,
                        iconColor: const Color(0xFF6B45FF),
                        bgColor: const Color(0xFFF1EFFF),
                        title: 'Invite Friends',
                        desc: 'Share your referral link with friends.',
                      ),
                      _buildStepItem(
                        number: '2',
                        icon: Icons.person_add,
                        iconColor: const Color(0xFF43C05A),
                        bgColor: const Color(0xFFEAF8ED),
                        title: 'Friend Joins',
                        desc: 'Your friend signs up using your link.',
                      ),
                      _buildStepItem(
                        number: '3',
                        imagePath: 'assets/image/coin.png',
                        iconColor: const Color(0xFFFFB300),
                        bgColor: const Color(0xFFFFF7E0),
                        title: 'Earn Coins',
                        desc: 'Get coins when the referral is completed.',
                      ),
                      _buildStepItem(
                        number: '4',
                        imagePath: 'assets/common_images/gift.png',
                        iconColor: const Color(0xFFFF528C),
                        bgColor: const Color(0xFFFFEFF4),
                        title: 'Claim Reward',
                        desc: 'Reach 200 coins and claim your reward.',
                        changeImageColor: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    IconData? icon,
    String? imagePath,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
    bool changeImageColor = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF6B45FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: imagePath != null
              ? Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: changeImageColor ? iconColor : null,
                  colorBlendMode:
                      changeImageColor ? BlendMode.srcIn : null,
                )
              : Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
        ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5.0;
    final double dashSpace = gap;
    final double dashRadius = 4.0; // corner radius

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(dashRadius),
        ),
      );

    Path dashPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HorizontalDashedLinePainter extends CustomPainter {
  final Color color;

  HorizontalDashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 5.0;
    var dashSpace = 5.0;
    double startX = 0;
    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

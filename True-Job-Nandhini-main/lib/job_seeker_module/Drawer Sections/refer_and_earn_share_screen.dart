import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnShareScreen extends StatelessWidget {
  final String referCode;

  const ReferAndEarnShareScreen({Key? key, required this.referCode})
    : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Your referral code:-  ',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      Text(
                        referCode,
                        style: const TextStyle(
                          color: Color(0xFF255EC7),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _copyToClipboard(context, referCode),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // QR Code placeholder
                  const Icon(Icons.qr_code_2_outlined, size: 200, color: Colors.black),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionItem(
                        icon: Icons.download_rounded,
                        label: 'Download\nQR',
                        onTap: () {
                          // Download logic
                        },
                      ),
                      Container(
                        height: 50,
                        width: 0.6,
                        color: Colors.black45,
                      ),
                      _buildActionItem(
                        icon: Icons.link_rounded,
                        label: 'Copy\nLink',
                        onTap: () => _copyToClipboard(
                          context,
                          'https://truejobs.com/invite/$referCode',
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 0.6,
                        color: Colors.black45,
                      ),
                      _buildActionItem(
                        icon: Icons.share_outlined,
                        label: 'Share\nLink',
                        onTap: () {
                          Share.share(
                            'Hey! Join True Jobs using my referral code: $referCode\n\nDownload now: https://play.google.com/store/apps/details?id=com.truejobs.app',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD2F3DD), // Light green background
                border: Border.all(
                  color: const Color(0xFF169F45),
                ), // Green border
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 12, fontFamily: 'Poppins'),
                  children: [
                    TextSpan(text: 'User have '),
                    TextSpan(
                      text: 'Earned ₹ 20 Coins ',
                      style: TextStyle(
                        color: Color(0xFF19893F), // Darker green for text
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(text: 'Through referral'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF255EC7), width: 1.5),
              color: Colors.white,
            ),
            child: Icon(icon, color: const Color(0xFF255EC7), size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

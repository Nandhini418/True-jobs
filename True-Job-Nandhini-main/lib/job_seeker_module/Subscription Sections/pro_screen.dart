import 'package:flutter/material.dart';
import 'pro_payment_screen.dart';
import '../../constants/app_colors.dart';
import '../../utils/smooth_page_route.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  // To track which FAQ is expanded (we can make it interactive!)
  final List<bool> _isOpen = List.generate(6, (_) => false);

  final List<Map<String, String>> _faqs = [
    {
      'num': '01',
      'q': 'What is a Premium Plan?',
      'a':
          'A Premium Plan gives you priority visibility to recruiters, unlimited job applications, and advanced resume building features to stand out.',
    },
    {
      'num': '02',
      'q': 'Can I upgrade or downgrade my plan anytime?',
      'a':
          'Yes, you can easily change your plan or cancel subscription directly through your app store settings or account profile settings.',
    },
    {
      'num': '03',
      'q': 'Is there a free trial available?',
      'a':
          'Yes, we offer a 7-day free trial for new users to test out the premium features.',
    },
    {
      'num': '04',
      'q': 'Will recruiters contact me directly?',
      'a':
          'Yes, with Pro, recruiters get direct access to your verified contact information to contact you faster.',
    },
    {
      'num': '05',
      'q': 'What happens after my plan expires?',
      'a':
          'Your account will revert to the standard free tier plan, but you will retain access to your saved files and applied job history.',
    },
    {
      'num': '06',
      'q': 'Will my profile be highlighted?',
      'a':
          'Yes, your profile gets a highlighted premium badge and is listed at the top of candidate pools when recruiters search for your skills.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color cardBg = AppColors.dynamicCardBg;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Scroll
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF772B88),
                  Color(0xFFE88515), // Fading into orange
                  Color(0xFFA41CC3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sw * 0.05,
                sw * 0.15,
                sw * 0.05,
                sw * 0.25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: sw * 0.06,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(height: sw * 0.04),

                  // Title and badge
                  Row(
                    children: [
                      Text(
                        'True Jobs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.09,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Container(
                        padding: const EdgeInsets.all(0.7), // Border thickness
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFFFB93), Color(0xFF999758)],
                          ),
                          borderRadius: BorderRadius.circular(sw * 0.05),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.03,
                            vertical: sw * 0.015,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFFFCE96), Color(0xFFC7710E)],
                            ),
                            borderRadius: BorderRadius.circular(sw * 0.05),
                          ),
                          child: Text(
                            'Get Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: sw * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.01),

                  // Subtitle
                  Text(
                    'Unlock Better Jobs. Get Hired Faster.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sw * 0.03),

                  // Paragraph
                  Text(
                    'Upgrade to Pro and get exclusive access to premium jobs, priority visibility, and faster interview calls.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: sw * 0.036,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: sw * 0.06),

                  // 25% Off Banner Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: sw * 0.015),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(sw * 0.08),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/crown-2.png', height: 40),
                        SizedBox(width: sw * 0.02),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF772B88),
                              Color(0xFFE88515),
                              Color(0xFFA41CC3),
                            ],
                            stops: [0.0, 0.53, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            '25 % Off on Pro',
                            style: TextStyle(
                              color: Colors.white, // Required for ShaderMask
                              fontSize: sw * 0.048,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sw * 0.06),

                  // Upgrade to Pro Header and Tag
                  Row(
                    children: [
                      Image.asset('assets/crown-3.png', height: 15),
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Upgrade to pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sw * 0.06),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.025,
                          vertical: sw * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF19893F),
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                        child: Text(
                          'What you\'ll get',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.04),

                  // Bullets
                  _buildProFeatureBullet('Apply to unlimited jobs', sw),
                  _buildProFeatureBullet('Create ATS-friendly resume', sw),
                  _buildProFeatureBullet('Guaranteed interview calls', sw),
                  _buildProFeatureBullet('Unlock recruiter contact info', sw),
                  SizedBox(height: sw * 0.08),

                  // FAQ Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(sw * 0.05),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: sw * 0.01,),
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _faqs.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: Colors.black12),
                          itemBuilder: (context, index) {
                            final faq = _faqs[index];
                            final isOpen = _isOpen[index];
                            return Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                key: PageStorageKey(index),
                                initiallyExpanded: isOpen,
                                onExpansionChanged: (val) {
                                  setState(() {
                                    _isOpen[index] = val;
                                  });
                                },
                                tilePadding: EdgeInsets.zero,
                                iconColor: textColor,
                                collapsedIconColor: textColor,
                                leading: Text(
                                  faq['num']!,
                                  style: TextStyle(
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                title: Text(
                                  faq['q']!,
                                  style: TextStyle(
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      sw * 0.05,
                                      0,
                                      sw * 0.02,
                                      sw * 0.03,
                                    ),
                                    child: Text(
                                      faq['a']!,
                                      style: TextStyle(
                                        fontSize: sw * 0.032,
                                        color: subtitleColor,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar
          Align(
  alignment: Alignment.bottomCenter,
  child: Container(
    width: double.infinity,
    color: bgColor,
    padding: EdgeInsets.fromLTRB(
      sw * 0.05,
      sw * 0.03,
      sw * 0.05,
      sw * 0.03,
    ),
    child: Container(
      padding: const EdgeInsets.all(1.08), // border width
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFFB93),
            Color(0xFF999758),
          ],
        ),
        borderRadius: BorderRadius.circular(sw * 0.08),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
    Color(0xFFFFD45C),
    Color(0xFF9B6100),
            ],
          ),
          borderRadius: BorderRadius.circular(sw * 0.08),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              SmoothPageRoute(
                child: const ProPaymentScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              vertical: sw * 0.04,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sw * 0.08),
            ),
          ),
          child: Text(
            'Get True Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.04,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildProFeatureBullet(String label, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.03),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.white, size: sw * 0.045),
          SizedBox(width: sw * 0.03),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.038,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

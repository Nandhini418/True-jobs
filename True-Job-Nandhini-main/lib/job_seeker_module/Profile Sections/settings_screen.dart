import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../widgets/logout_popup.dart';
import '../../widgets/deactivate_account_popups.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_condition_screen.dart';
import 'about_us_screen.dart';
import '../../widgets/language.dart';
import '../../utils/smooth_page_route.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _smsAlerts = true;
  bool _whatsAppAlerts = true;
  bool _isGuest = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettingsState();
  }

  Future<void> _loadSettingsState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuest = prefs.getBool('is_guest') ?? false;
      _smsAlerts = prefs.getBool('sms_alerts') ?? true;
      _whatsAppAlerts = prefs.getBool('whatsapp_alerts') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final Color bgColor = Colors.white;
    final Color textColor = Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sw * 0.03,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Custom Back Button with Settings Title
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: textColor,
                          size: sw * 0.04,
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: textColor,
                            fontSize: sw * 0.048,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Language Dropdown
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => LanguageSelectionBottomSheet(
                          currentLanguage: _selectedLanguage,
                          onLanguageSelected: (newLang) async {
                            setState(() {
                              _selectedLanguage = newLang;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('language', newLang);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03,
                        vertical: sw * 0.015,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedLanguage,
                            style: TextStyle(
                              fontSize: sw * 0.034,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: sw * 0.04,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sw * 0.05),

                    // SMS Preference Switch
                    _buildSwitchRow(
                      title: 'SMS Preference',
                      subtitle: 'Get notified by True jobs',
                      value: _smsAlerts,
                      onChanged: (val) {
                        setState(() {
                          _smsAlerts = val;
                        });
                        _saveSetting('sms_alerts', val);
                      },
                      sw: sw,
                    ),

                    // WhatsApp Preference Switch
                    _buildSwitchRow(
                      title: 'WhatsApp Preference',
                      subtitle: 'Get notified by True jobs',
                      value: _whatsAppAlerts,
                      onChanged: (val) {
                        setState(() {
                          _whatsAppAlerts = val;
                        });
                        _saveSetting('whatsapp_alerts', val);
                      },
                      sw: sw,
                    ),

                    // Privacy Policy Tile
                    _buildNavigationRow(
                      title: 'Privacy policy',
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const PrivacyPolicyScreen()),
                        );
                      },
                      sw: sw,
                    ),

                    // Terms and Conditions Tile
                    _buildNavigationRow(
                      title: 'Terms and Condition',
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const TermsConditionScreen()),
                        );
                      },
                      sw: sw,
                    ),

                    // About Us Tile
                    _buildNavigationRow(
                      title: 'About Us',
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(child: const AboutUsScreen()),
                        );
                      },
                      sw: sw,
                    ),

                    // Need Help Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.05,
                        vertical: sw * 0.12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Help',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: sw * 0.02),
                          Row(
                            children: [
                              Text(
                                'Contact us - Email',
                                style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset('assets/tele.png', height: sw * 0.03,),
                            ],
                          ),
                          SizedBox(height: sw * 0.015),
                          Text(
                            'Our team will get back to you, as soon as possible with the most suitable solution.',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              color: Colors.grey,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer logouts / deactivate
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sw * 0.15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Deactivate account flow
                      showDeactivateFirstPopup(context);
                    },
                    child: Text(
                      'Deactivate Account',
                      style: TextStyle(
                        color: textColor,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isGuest) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          SmoothPageRoute(
                            child: const RoleSelectionScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const LogoutPopup(),
                        );
                      }
                    },
                    child: Text(
                      _isGuest ? 'Log In' : 'Log Out',
                      style: TextStyle(
                        color: const Color(0xFFCE1414),
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
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
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double sw,
  }) {
    final Color textColor = Colors.black;
    final Color subtitleColor = Colors.grey.shade500;
    final Color borderColor = const Color(0x44000000);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        padding: EdgeInsets.symmetric(vertical: sw * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.042,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            // Figma-style pill toggle (iOS switch look)
            Transform.scale(
              scale: 0.85,
              child: CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                trackColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow({
    required String title,
    required VoidCallback onTap,
    required double sw,
  }) {
    final Color textColor = Colors.black;
    final Color borderColor = const Color(0x44000000);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          padding: EdgeInsets.symmetric(vertical: sw * 0.045),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: sw * 0.04,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: sw * 0.04,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


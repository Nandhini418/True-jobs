import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/recruiter_module_screens/settings_screens/contact_us_screen.dart';
import 'package:truejobs/recruiter_module_screens/drawer_sections/buy_credits_screen.dart';
import 'package:truejobs/recruiter_module_screens/drawer_sections/my_subscription_screen.dart';
import 'package:truejobs/recruiter_module_screens/drawer_sections/billing_screen.dart';
import 'package:truejobs/recruiter_module_screens/drawer_sections/view_profile_screen.dart';
import 'package:truejobs/recruiter_module_screens/drawer_sections/company_profile_screen.dart';
import 'package:truejobs/widgets/logout_popup.dart';
import 'package:truejobs/widgets/language.dart';

class RightSideDrawer extends StatefulWidget {
  const RightSideDrawer({super.key});

  @override
  State<RightSideDrawer> createState() => _RightSideDrawerState();
}

class _RightSideDrawerState extends State<RightSideDrawer> {
  String _firstLetter = 'U';

  @override
  void initState() {
    super.initState();
    _loadUserInitial();
  }

  Future<void> _loadUserInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString('name') ?? prefs.getString('company_name') ?? 'User';
    if (name.isNotEmpty) {
      setState(() {
        _firstLetter = name[0].toUpperCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and avatar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 9.h,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 8),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/appbar.png',
                    height: 24.h,
                    fit: BoxFit.contain,
                  ),
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: const Color(0xFF005C62),
                    child: Text(
                      _firstLetter,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 7.h),

            // Menu Items
            _DrawerMenuItem(
              icon: Icons.person_outline,
              label: 'View Profile',
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.business_outlined,
              label: 'Company Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompanyProfileScreen()),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.workspace_premium_outlined,
              label: 'My Subscription',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MySubscriptionScreen()),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.credit_card_outlined,
              label: 'Billings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillingScreen()),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.layers_outlined,
              label: 'Buy Credits',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyCreditsScreen()),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.translate,
              label: 'Language',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => LanguageSelectionBottomSheet(
                    currentLanguage: 'English',
                    onLanguageSelected: (lang) {
                      // Handle language selection if needed
                    },
                  ),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.phone_outlined,
              label: 'Contact Us',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                );
              },
            ),
            _DrawerMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: Colors.red,
              labelColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const LogoutPopup(isRecruiter: true),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedIconColor = iconColor ?? Colors.black87;
    final Color resolvedLabelColor = labelColor ?? Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 22.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: resolvedIconColor),
            SizedBox(width: 18.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: resolvedLabelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

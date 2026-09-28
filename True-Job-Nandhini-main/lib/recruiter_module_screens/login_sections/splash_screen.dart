import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/device_info_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truejobs/services/basic_detail_api_service.dart';
import 'package:truejobs/recruiter_module_screens/dashboard_sections/dashboard_holder.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/company_details_screen.dart';
import 'package:truejobs/recruiter_module_screens/login_sections/basic_detail_screen.dart';
import 'walkthrough_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWalkthrough();
  }

  Future<void> _navigateToWalkthrough() async {
    // Wait for at least 2.5 seconds or for permissions to be handled, whichever takes longer
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      DeviceInfoService.initializePermissions(),
    ]);

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final int? userIdInt = prefs.getInt('user_id');
    final String? userId = userIdInt?.toString();
    final String token = prefs.getString('token') ?? '';
    final String phone = prefs.getString('mobile') ?? '';

    if (userId != null && userId.isNotEmpty) {
      final profileResponse = await BasicDetailApiService.fetchBasicDetails(
        userId: userId,
        token: token,
      );

      bool hasBasicDetails = false;
      bool hasCompanyDetails = false;

      if (profileResponse != null && profileResponse['status'] == 'success') {
        final data = profileResponse['data'];
        if (data != null) {
          final String contactPerson = data['contact_person'] ?? data['name'] ?? '';
          final String contactEmail = data['contact_person_email'] ?? data['email_id'] ?? '';
          if (contactPerson.isNotEmpty && contactEmail.isNotEmpty) {
            hasBasicDetails = true;
          }
           
          final String companyName = data['company_name'] ?? data['company'] ?? '';
          final String pincode = data['pincode'] ?? data['pin_code'] ?? '';
          final String address = data['address'] ?? data['company_address'] ?? '';
          if (companyName.isNotEmpty && pincode.isNotEmpty && address.isNotEmpty) {
            hasCompanyDetails = true;
          }
        }
      }

      if (!mounted) return;

      if (hasBasicDetails && hasCompanyDetails) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardHolder()),
        );
        return;
      } else if (hasBasicDetails && !hasCompanyDetails) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompanyDetailsScreen(
              phone: phone,
              userId: userId,
              token: token,
            ),
          ),
        );
        return;
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EnteredNumberScreen(
              phone: phone,
              userId: userId,
              token: token,
            ),
          ),
        );
        return;
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: Image.asset(
            'assets/images/recruiter_logo.png',
            width: 100.w,
            height: 100.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
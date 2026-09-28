import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/job_seeker_module/Login%20Sections/splash_screen.dart';
import 'constants/app_themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:truejobs/services/notification_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Bypass certificate verification for the API host due to hostname mismatch
        return true;
      };
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'True Jobs',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

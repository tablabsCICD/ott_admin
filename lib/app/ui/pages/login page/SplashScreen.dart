import 'dart:async';
import 'package:admin_ott/app/core/constant/image_constant.dart';
import 'package:admin_ott/app/ui/pages/login%20page/LoginPage.dart';
import 'package:admin_ott/app/ui/NavigationPage.dart';
import 'package:admin_ott/app/ui/pages/network%20handler/NetworkHandler.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import '../../../core/constant/prefrense_constant.dart';
import '../../../core/utils/sharepreferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  final LocalSharePreferences localSharePreferences = LocalSharePreferences();

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    await getData();
    Timer(const Duration(seconds: 2), _navigateToNextScreen);
  }

  Future<void> getData() async {
    final bool? loggedIn =
    await localSharePreferences.getBool(SharedPreferencesConstant.isAdminLoggedIn);
    setState(() {
      isLoggedIn = loggedIn ?? false; // Default to false if null
    });
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkHandler(
          mainPage: isLoggedIn ? NavigationPage() : LoginPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Image.asset(
              ImageConstant.logo,
              width: ResponsiveWidget.isMobile(context) ? 350 : 450,
              fit: BoxFit.contain,
            ),
            SizedBox(
              height: ResponsiveWidget.isMobile(context) ? 150 : 10,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Discover, Watch & Collect the Latest Movies & TV',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveWidget.isMobile(context) ? 18 : 20,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

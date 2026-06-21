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
    final bool? loggedIn = await localSharePreferences
        .getBool(SharedPreferencesConstant.isAdminLoggedIn);
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
      backgroundColor: theme.primaryColor,
      body: SafeArea(
          child: Stack(fit: StackFit.expand, children: [
        ResponsiveWidget.isMobile(context)
            ? Hero(
                tag: 'logo',
                child: Image.asset(
                  ImageConstant.fullScreenLogo,
                  fit: BoxFit.cover,
                ),
              )
            : Hero(
                tag: 'logo',
                child: Image.asset(
                  ImageConstant.webFullScreenLogo,
                  fit: BoxFit.cover,
                ),
              ),
        /* Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Text(
              'Watch First Day First Show',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                shadows: const [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black54,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ), */
      ])),
    );
  }
}

import 'package:admin_ott/app/ui/pages/Live%20Room/LiveRoom.dart';
import 'package:admin_ott/app/ui/pages/access%20control%20page/AccessControlPage.dart';
import 'package:admin_ott/app/ui/pages/admin%20settings%20page/AdminSettingsPage.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/DashboardPage.dart';
import 'package:admin_ott/app/ui/pages/login%20page/LoginPage.dart';
import 'package:admin_ott/app/ui/pages/login%20page/SplashScreen.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/ManageMediaHousePage.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/ManagePromoterPage.dart';
import 'package:admin_ott/app/ui/pages/manage%20user%20page/ManageUserPage.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/ManageContentPage.dart';
import 'package:admin_ott/app/ui/pages/profile%20page/ProfilePage.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return buildRoute(LoginPage(), settings: settings);

      case AppRoutes.entry:
        return buildRoute(SplashScreen(), settings: settings);

      case AppRoutes.register:
        return buildRoute(DashboardPage(), settings: settings);

      case AppRoutes.dashboard:
        return buildRoute(DashboardPage(), settings: settings);

      case AppRoutes.liveRoom:
        return buildRoute(LiveRoomPage(), settings: settings);

      case AppRoutes.profile:
        return buildRoute(ProfilePage(), settings: settings);

      case AppRoutes.accessControl:
        return buildRoute(AccessControlPage(), settings: settings);

      case AppRoutes.adminSettings:
        return buildRoute(AdminSettingsPage(), settings: settings);

      case AppRoutes.manageMediaHouse:
        return buildRoute(ManageMediaHousePage(), settings: settings);

      case AppRoutes.managePromoters:
        return buildRoute(ManagePromoterPage(), settings: settings);

      case AppRoutes.manageUser:
        return buildRoute(ManageUserPage(), settings: settings);

      case AppRoutes.manageVideo:
        return buildRoute(MovieListScreen(), settings: settings);
      default:
        return _errorRoute();
    }
  }

  static MaterialPageRoute buildRoute(Widget child,
      {required RouteSettings settings}) {
    return MaterialPageRoute(
        settings: settings, builder: (BuildContext context) => child);
  }

  static Route _createRoute(Widget root) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => root,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
        ;
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'ERROR!!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 450.0,
                  width: 450.0,
                  //child: Lottie.asset('assets/lottie/error.json'),
                ),
                Text(
                  'Seems the route you\'ve navigated to doesn\'t exist!!',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

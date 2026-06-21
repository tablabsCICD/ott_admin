import 'package:admin_ott/app/config/routes/app_routes.dart';
import 'package:admin_ott/app/config/routes/routes.dart';
import 'package:admin_ott/app/provider/accessControleProvider.dart';
import 'package:admin_ott/app/provider/analyticsProvider.dart';
import 'package:admin_ott/app/provider/admin_settings_provider.dart';
import 'package:admin_ott/app/provider/dashboardProvider.dart';
import 'package:admin_ott/app/provider/fullscreenProvider.dart';
import 'package:admin_ott/app/provider/graphProvider.dart';
import 'package:admin_ott/app/provider/language_provider.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/notification_provider.dart';
import 'package:admin_ott/app/provider/promoterGraphProvider.dart';
import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/promoter_percentage_provider.dart';
import 'package:admin_ott/app/provider/settelementProvider.dart';
import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/provider/transactionProvider.dart';
import 'package:admin_ott/app/provider/userGraphProvider.dart';
import 'package:admin_ott/app/provider/userProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/app/ui/pages/network%20handler/NetworkHandler.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // media_kit replaces the previous video_player/Chewie playback engine.
  MediaKit.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Check theme preference
  final themeBool = prefs.getBool("isDark") ?? true;

  // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(isDark: themeBool),
        ),
        ChangeNotifierProvider(
          create: (_) => FullScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MediaHouseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => VideoProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PromoterProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserGraphProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PromoterGraphProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GraphProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettelementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TicketProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PromoterPercentageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccesscontroleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminSettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShortsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<ThemeProvider>(
        builder: (context, ThemeProvider themeNotifier, child) {
      return MaterialApp(
        title: 'OTT Admin',
        theme: themeNotifier.getTheme,
        navigatorKey: navigatorKey, // Pass the navigatorKey here
        debugShowCheckedModeBanner: false,
        builder: (context, child) => AppLoaderOverlay(
          child: NetworkHandler(
            mainPage: child ?? const SizedBox.shrink(),
          ),
        ),
        initialRoute: AppRoutes.entry,
        // Use initialRoute to specify starting route
        onGenerateRoute:
            RouteGenerator.generateRoute, // Route handling with RouteGenerator
      );
    });
  }
}
// latest code

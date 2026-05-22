import 'package:admin_ott/app/core/constant/image_constant.dart';
import 'package:admin_ott/app/ui/pages/analytics_page/analyticsPage.dart';
import 'package:admin_ott/app/ui/pages/access%20control%20page/AccessControlPage.dart';
import 'package:admin_ott/app/ui/pages/admin%20settings%20page/AdminSettingsPage.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/help2.dart';
import 'package:admin_ott/app/ui/pages/profile%20page/ProfilePage.dart';
import 'package:admin_ott/app/ui/pages/manage%20user%20page/ManageUserPage.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/DashboardPage.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/ManagePromoterPage.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/ManageMediaHousePage.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/ManageContentPage.dart';
import 'package:admin_ott/app/ui/pages/promoter%20perentage/manage_promoter_percentage.dart';
import 'package:admin_ott/app/ui/pages/settlemet_page/SettlementPage.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/ShortsPage.dart';
import 'package:admin_ott/app/ui/pages/transaction%20page/TransactionPage.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<PageData> _pages = [
    PageData(title: 'Dashboard', page: const DashboardPage()),
    PageData(title: 'Manage Media House', page: const ManageMediaHousePage()),
    PageData(title: 'Manage Promoters', page: const ManagePromoterPage()),
    PageData(title: 'Manage Content', page: MovieListScreen()),
    PageData(title: 'Manage Mini Series', page: ShortsPage()),
    PageData(title: 'Manage User', page: ManageUserPage()),
    PageData(title: 'Transaction', page: const TransactionPage()),
    PageData(title: 'Access Control', page: const AccessControlPage()),
    PageData(title: 'Admin Settings', page: const AdminSettingsPage()),
    PageData(
        title: 'Promoter Percentage',
        page: const ManagePromoterPercentagePage()),
    PageData(title: 'Settlement', page: SettlementPage()),
    PageData(title: 'Analytics', page: AnalyticsPage()),
    PageData(title: 'Help & Support', page: HelpDeskPage()),
    PageData(title: 'Profile', page: const ProfilePage()),
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.house,
    Icons.supervisor_account,
    Icons.video_library,
    Icons.smart_display_rounded,
    Icons.people_alt_rounded,
    Icons.currency_rupee_sharp,
    Icons.admin_panel_settings_rounded,
    Icons.settings_suggest_rounded,
    Icons.percent,
    Icons.transform_sharp,
    Icons.bar_chart_sharp,
    Icons.help,
    Icons.account_circle_sharp,
  ];

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveWidget.isDesktop(context)
          ? null
          : AppBar(
              centerTitle: true,
              title: Text(
                _pages[_selectedIndex].title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: selectedThemeData.primaryColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_on_sharp,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = _pages.length - 1;
                    });
                  },
                  icon: Icon(
                    Icons.account_circle_sharp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
      drawer: ResponsiveWidget.isDesktop(context)
          ? null
          : Drawer(
              backgroundColor: selectedThemeData.cardColor,
              child: _buildDrawerContent(context)),
      body: Row(
        children: [
          if (ResponsiveWidget.isDesktop(context))
            Container(
              width: 270,
              color: selectedThemeData.cardColor,
              child: _buildDrawerContent(context),
            ),
          Expanded(child: _pages[_selectedIndex].page),
        ],
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var selectedThemeData = themeProvider.getTheme;
    bool isDark = selectedThemeData.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: ResponsiveWidget.isDesktop(context) ? 160 : 200,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: selectedThemeData.primaryColor,
            ),
            child: Center(
              child: Hero(
                tag: "logo",
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(25),
                  child: Image.asset(
                    ImageConstant.logo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            ResponsiveWidget.isDesktop(context)
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_on_sharp,
                      color: selectedThemeData.canvasColor,
                    ),
                  )
                : Text(''),
            Expanded(
              child: Divider(
                color: selectedThemeData.primaryColor,
                thickness: 1,
              ),
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: selectedThemeData.canvasColor,
              ),
              onPressed: () {
                themeProvider.toggleTheme(); // Toggle the theme
              },
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveWidget.isDesktop(context) ? 30 : 1,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  _icons[index],
                  color: _selectedIndex == index
                      ? selectedThemeData.primaryColor
                      : selectedThemeData.canvasColor,
                ),
                title: Text(
                  _pages[index].title,
                  style: TextStyle(
                    color: _selectedIndex == index
                        ? selectedThemeData.primaryColor
                        : selectedThemeData.canvasColor,
                  ),
                ),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    if (!ResponsiveWidget.isDesktop(context)) {
                      Navigator.pop(context); //Close drawer on mobile/tablet
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class PageData {
  final String title;
  final Widget page;

  const PageData({required this.title, required this.page});
}

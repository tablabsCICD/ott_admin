import 'package:admin_ott/app/ui/pages/login%20page/LoginPage.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import '../../../core/constant/prefrense_constant.dart';
import '../../../core/utils/sharepreferences.dart';
import '../../../provider/userProvider.dart';
import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final localSharePreferences = LocalSharePreferences();
    final user = await localSharePreferences.getUser();
    if (user != null) {
      if (mounted) {
        await Provider.of<UserProvider>(context, listen: false).getUserById(user.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeData = themeProvider.getTheme;
    final isDarkTheme = selectedThemeData.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: ResponsiveWidget.isMobile(context)
          ? _buildMobileLayout(selectedThemeData, isDarkTheme, themeProvider)
          : _buildDesktopLayout(selectedThemeData, isDarkTheme, themeProvider),
    );
  }

  Widget _buildMobileLayout(
      ThemeData selectedThemeData, bool isDarkTheme, ThemeProvider themeProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final user = provider.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            children: [
              _buildProfileHeader(selectedThemeData, user),
              const Divider(height: 40),
              _buildAccountSettings(selectedThemeData, isDarkTheme, themeProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(
      ThemeData selectedThemeData, bool isDarkTheme, ThemeProvider themeProvider) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final user = provider.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    _buildProfileHeader(selectedThemeData, user, isDesktop: true),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 3,
                child: _buildAccountSettings(selectedThemeData, isDarkTheme, themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData themeData, User user, {bool isDesktop = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: isDesktop ? 80 : 60,
          backgroundColor: themeData.cardColor,
          child: Icon(
            Icons.account_circle,
            size: isDesktop ? 100 : 80,
            color: themeData.scaffoldBackgroundColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyle(
            fontSize: isDesktop ? 30 : 24,
            fontWeight: FontWeight.bold,
            color: themeData.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.emailId ?? '',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: themeData.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.mobileNumber ?? '',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: themeData.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Role: "Super Admin"',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: themeData.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(
      ThemeData selectedThemeData, bool isDarkTheme, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ResponsiveWidget.isDesktop(context))
          const SizedBox(height: 100),
        Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: selectedThemeData.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        _buildListTile(
          icon: Icons.edit,
          text: 'Edit Profile',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfilePage(),
              ),
            );
          },
          selectedThemeData: selectedThemeData,
        ),
        _buildListTile(
          icon: Icons.lock,
          text: 'Change Password',
          onTap: () {
            // Implement change password functionality
          },
          selectedThemeData: selectedThemeData,
        ),
        _buildListTile(
          icon: isDarkTheme ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          text: 'Toggle Theme',
          onTap: () {
            themeProvider.toggleTheme();
          },
          selectedThemeData: selectedThemeData,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final localSharePreferences = LocalSharePreferences();
            await localSharePreferences.logOut();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedThemeData.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required ThemeData selectedThemeData,
  }) {
    return ListTile(
      leading: Icon(icon, color: selectedThemeData.primaryColor),
      title: Text(
        text,
        style: TextStyle(
          color: selectedThemeData.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
    );
  }
}

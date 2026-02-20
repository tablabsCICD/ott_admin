import 'package:admin_ott/app/core/constant/image_constant.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/login%20page/LoginPage.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/sharepreferences.dart';
import '../../../provider/userProvider.dart';
import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
    final localUser = await localSharePreferences.getUser();
    if (localUser != null && mounted) {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(localUser.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final isDark = selectedThemeData.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final user = provider.userObj;
          final isDesktop = ResponsiveWidget.isDesktop(context);
          final content = _buildContent(
            context: context,
            user: user,
            selectedThemeData: selectedThemeData,
            isDark: isDark,
            isDesktop: isDesktop,
          );

          return SafeArea(
            child: isDesktop
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: content,
                    ),
                  )
                : content,
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required User user,
    required ThemeData selectedThemeData,
    required bool isDark,
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _profileCard(user, selectedThemeData, isDesktop: true),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: _settingsCard(selectedThemeData, isDark),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _profileCard(user, selectedThemeData),
          const SizedBox(height: 16),
          _settingsCard(selectedThemeData, isDark),
        ],
      ),
    );
  }

  Widget _profileCard(User user, ThemeData theme, {bool isDesktop = false}) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'profile',
              child: _profileImage(
                imageUrl: user.profilePhoto,
                radius: isDesktop ? 72 : 60,
                theme: theme,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty
                  ? 'Admin'
                  : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: isDesktop ? 28 : 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.emailId ?? '-',
              style: TextStyle(color: theme.hintColor, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              user.mobileNumber ?? '-',
              style: TextStyle(color: theme.hintColor, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Super Admin',
                style: TextStyle(
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

  Widget _settingsCard(ThemeData theme, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Account Settings',
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _tile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                _fetchUserData();
              },
              theme: theme,
            ),
            _tile(
              icon: isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              title: 'Toggle Theme',
              onTap: themeProvider.toggleTheme,
              theme: theme,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await LocalSharePreferences().logOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(
        title,
        style: TextStyle(color: theme.canvasColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _profileImage({
    required String? imageUrl,
    required double radius,
    required ThemeData theme,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.primaryColor, width: 2),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  ImageConstant.profile,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                ImageConstant.profile,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

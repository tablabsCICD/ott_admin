import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildSummaryCard extends StatelessWidget {
  IconData icon;
  String title;
  String value;
  final VoidCallback? onTap; // Accept onTap function
  BuildSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return SizedBox(
      width: ResponsiveWidget.isMobile(context) ? 200 : 200,
      child: GestureDetector(
        child: Card(
          color: selectedThemeData.cardColor,
          elevation: 3,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(icon, size: 40),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: selectedThemeData.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

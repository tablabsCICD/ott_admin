import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/settlemet_page/promoter_settlement_download_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromoterSettlementPage extends StatelessWidget {
  const PromoterSettlementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: PromoterSettlementDownloadSection(),
      ),
    );
  }
}

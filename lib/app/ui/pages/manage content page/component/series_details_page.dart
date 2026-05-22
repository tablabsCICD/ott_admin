import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'movie_details_page.dart';

class SeriesDetailsPage extends StatelessWidget {
  final Content content;

  const SeriesDetailsPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Series Details'),
        backgroundColor: theme.cardColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosterHeader(content: content),
            const SizedBox(height: 16),
            ActionPanel(content: content),
            const SizedBox(height: 16),
            DetailsSection(
              content: content,
              heading: 'Series Metadata',
            ),
            const SizedBox(height: 16),
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Episode-level metadata is not available in current API response.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

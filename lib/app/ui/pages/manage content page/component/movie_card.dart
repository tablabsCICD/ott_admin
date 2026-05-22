import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import 'movie_details_page.dart';
import 'series_details_page.dart';

class MovieCard extends StatelessWidget {
  final Content movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final posterUrl =
        (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
            ? movie.posterUrlList!.first
            : '';
    final isSeries = (movie.type ?? '').toUpperCase() == 'SERIES';
    final language = movie.languageList?.isNotEmpty == true
        ? movie.languageList!.first
        : 'Unknown';
    final price = movie.price == null
        ? 'Rs. -'
        : 'Rs. ${movie.price!.toStringAsFixed(movie.price! % 1 == 0 ? 0 : 2)}';
    final revenue = movie.totalRevenue == null
        ? 'Rs. -'
        : 'Rs. ${movie.totalRevenue!.toStringAsFixed(movie.totalRevenue! % 1 == 0 ? 0 : 2)}';
    final releaseDate = _formatDate(movie.releaseDate);
    final mediaHouse = movie.mediaHouseName ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isSeries
                ? SeriesDetailsPage(content: movie)
                : MovieDetailsPage(content: movie),
          ),
        );
      },
      child: Card(
        color: selectedThemeData.cardColor,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholderPoster(),
                        )
                      : _placeholderPoster(),
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selectedThemeData.cardColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        movie.type ?? 'CONTENT',
                        style: TextStyle(
                          color: selectedThemeData.canvasColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selectedThemeData.cardColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        movie.approvalStatus ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: selectedThemeData.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movie.title ?? "Unknown Title",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: selectedThemeData.canvasColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _titleLanguageBadge(
                        theme: selectedThemeData,
                        language: language,
                      ),
                    ],
                  ),
                  //  const SizedBox(height: 8),
                  Row(
                    spacing: 5,
                    children: [
                      _infoChip(
                        theme: selectedThemeData,
                        icon: Icons.currency_rupee,
                        text: price.replaceFirst('Rs. ', ''),
                      ),
                      _infoChip(
                        theme: selectedThemeData,
                        icon: Icons.currency_rupee,
                        text: revenue.replaceFirst('Revenue. ', ''),
                      ),
                      _infoChip(
                        theme: selectedThemeData,
                        icon: Icons.event,
                        text: releaseDate,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      _infoChip(
                        theme: selectedThemeData,
                        icon: Icons.business,
                        text: mediaHouse,
                        wide: true,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderPoster() {
    return Container(
      color: Colors.black12,
      child: const Center(child: Icon(Icons.movie_creation_outlined, size: 36)),
    );
  }

  Widget _infoChip({
    required ThemeData theme,
    required IconData icon,
    required String text,
    bool wide = false,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: wide ? 220 : 128),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: theme.primaryColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.78),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleLanguageBadge({
    required ThemeData theme,
    required String language,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 96),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.28)),
        ),
        child: Text(
          language,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'No date';
    final date =
        rawDate is DateTime ? rawDate : DateTime.tryParse(rawDate.toString());
    if (date == null) return rawDate.toString();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import 'add_video.dart';
import 'movie_details_page.dart';
import 'series_details_page.dart';

class MovieCard extends StatelessWidget {
  final Content movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final posterUrl =
        (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
            ? movie.posterUrlList!.first
            : '';
    final type = (movie.type ?? '').toUpperCase();
    final isSeries = type == 'SERIES' || type == 'MINI_SERIES';
    final language = movie.languageList?.isNotEmpty == true
        ? movie.languageList!.first
        : 'Unknown';
    final price = movie.price == null
        ? '-'
        : '${movie.price! % 1 == 0 ? movie.price!.toInt() : movie.price}';
    final revenue = movie.totalRevenue == null
        ? '-'
        : '${movie.totalRevenue! % 1 == 0 ? movie.totalRevenue!.toInt() : movie.totalRevenue}';
    final purchases = '${movie.totalPurchase ?? 0}';
    final releaseDate = _formatDate(movie.releaseDate);
    final mediaHouse = movie.mediaHouseName ?? 'Unknown';

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: selectedThemeData.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedThemeData.dividerColor.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Poster / Media Header
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      posterUrl.isNotEmpty
                          ? Image.network(
                              posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _placeholderPoster(selectedThemeData),
                            )
                          : _placeholderPoster(selectedThemeData),
                      // Subtle gradient overlay for readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.45),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Top Left: Content Type Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            formatContentTypeLabel(movie.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      // Top Right: Status Badge & Edit Action
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _statusBadge(movie.approvalStatus),
                            const SizedBox(width: 6),
                            Material(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () => _openEdit(context),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 15,
                                    color: selectedThemeData.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 2. Body Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title & Language Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              movie.title ?? "Untitled",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 6),
                      // Row 1: Price, Purchases & Revenue
                      Row(
                        children: [
                          Expanded(
                            child: _infoPill(
                              theme: selectedThemeData,
                              icon: Icons.currency_rupee_rounded,
                              label: "Price",
                              value: price,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _infoPill(
                              theme: selectedThemeData,
                              icon: Icons.shopping_cart_outlined,
                              label: "Sales",
                              value: purchases,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _infoPill(
                              theme: selectedThemeData,
                              icon: Icons.trending_up_rounded,
                              label: "Rev",
                              value: revenue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Row 2: Date & Media House
                      Row(
                        children: [
                          Expanded(
                            child: _infoPill(
                              theme: selectedThemeData,
                              icon: Icons.calendar_today_outlined,
                              label: "Date",
                              value: releaseDate,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _infoPill(
                              theme: selectedThemeData,
                              icon: Icons.business_outlined,
                              label: "Studio",
                              value: mediaHouse,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String? status) {
    final norm = (status ?? 'PENDING').trim().toUpperCase();
    Color bg;
    Color textColor = Colors.white;

    if (norm == 'APPROVED') {
      bg = const Color(0xFF16A34A);
    } else if (norm == 'REJECTED') {
      bg = const Color(0xFFDC2626);
    } else {
      bg = const Color(0xFFEA580C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        norm,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _infoPill({
    required ThemeData theme,
    required IconData icon,
    String? label,
    required String value,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*   Icon(
            icon,
            size: 11.5,
            color: iconColor ?? theme.primaryColor.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4), */
          if (label != null && label.isNotEmpty) ...[
            Text(
              "$label: ",
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: theme.hintColor,
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleLanguageBadge({
    required ThemeData theme,
    required String language,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        language,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.primaryColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _placeholderPoster(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          size: 32,
          color: theme.hintColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    final id = movie.id;
    if (id == null) return;
    final provider = context.read<VideoProvider>();
    Content? fullContent;
    try {
      fullContent = await provider.getContentById(id);
    } catch (_) {}
    if (!context.mounted) return;

    final targetContent = movie.mergeWith(fullContent);

    final updated = await Navigator.push<Content>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDataWidget(editingContent: targetContent),
      ),
    );
    if (updated != null && context.mounted) {
      await provider.fetchMoviesByStatusAndMediaHouseId('ALL', 0);
    }
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

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
              aspectRatio: 16 / 9,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                movie.title ?? "Unknown Title",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selectedThemeData.canvasColor,
                ),
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
}

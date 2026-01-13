import 'dart:developer';

import 'package:admin_ott/app/provider/themeProvider.dart';

import 'package:admin_ott/data/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import 'movie_details_dialog.dart.dart';

class MovieCard extends StatelessWidget {
  final Content movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return GestureDetector(
      onTap: () => showMovieDetailsDialog(context, movie),
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.network(
              (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty)
                  ? movie.posterUrlList!.first // Use the first poster URL if available
                  : 'https://via.placeholder.com/300x400?text=No+Image', // Fallback URL
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 100),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? "Unknown Title",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Director: ${(movie.directorList != null && movie.directorList!.isNotEmpty)
                        ? movie.directorList!.first // Use the first director if available
                        : "-"}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

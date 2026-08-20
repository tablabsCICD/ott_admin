import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';

import 'movie_details_page.dart';
import 'series_details_page.dart';

void showMovieDetailsDialog(BuildContext context, Content content) {
  final type = (content.type ?? '').toUpperCase();
  final isSeries = type == 'SERIES' || type == 'MINI_SERIES' || type == 'MINI SERIES';

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => isSeries
          ? SeriesDetailsPage(content: content)
          : MovieDetailsPage(content: content),
    ),
  );
}

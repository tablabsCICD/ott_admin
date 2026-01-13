class MovieModel {
  final int id;
  final String title;
  final double price;
  final int views;
  final double revenue;
  final String type;
  final String description;
  final String posterUrl;
  final double rating;
  final String runtime;
  final DateTime releaseDate;
  final List<String> languages;
  final List<String> audioFormats;
  final List<String> subtitleLanguages;
  final String ageRating;
  final List<String> genres;
  final List<String> cast;
  final String director;
  final String trailerUrl;
  final bool isDownloadable;
  final bool isFeatured;

  MovieModel({
    required this.id,
    required this.title,
    required this.price,
    required this.views,
    required this.revenue,
    required this.type,
    required this.description,
    required this.posterUrl,
    required this.rating,
    required this.runtime,
    required this.releaseDate,
    required this.languages,
    required this.audioFormats,
    required this.subtitleLanguages,
    required this.ageRating,
    required this.genres,
    required this.cast,
    required this.director,
    required this.trailerUrl,
    required this.isDownloadable,
    required this.isFeatured,
  });
}

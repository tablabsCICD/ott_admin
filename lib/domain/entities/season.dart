import 'dart:convert';

import 'package:admin_ott/domain/entities/episode.dart';

Season seasonUserDTOFromJson(String str) => Season.fromJson(json.decode(str));

String seasonUserDTOToJson(Season data) => json.encode(data.toJson());

class Season {
  int? seasonId;
  int? seasonNumber;
  String? title;
  String? description;
  DateTime? releaseDate;
  bool? isSeasonPurchased;
  double? price;
  List<Episode>? episodes;

  Season({
    this.seasonId,
    this.seasonNumber,
    this.title,
    this.description,
    this.releaseDate,
    this.isSeasonPurchased,
    this.price,
    this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        seasonId: json["seasonId"],
        seasonNumber: json["seasonNumber"],
        title: json["title"],
        description: json["description"],
        releaseDate: json["releaseDate"] == null
            ? null
            : DateTime.parse(json["releaseDate"]),
        isSeasonPurchased: json["isSeasonPurchased"],
        price: json["price"]?.toDouble(),
        episodes: json["episodes"] == null
            ? []
            : List<Episode>.from(
                json["episodes"].map((x) => Episode.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "seasonId": seasonId,
        "seasonNumber": seasonNumber,
        "title": title,
        "description": description,
        "releaseDate": releaseDate?.toIso8601String(),
        "isSeasonPurchased": isSeasonPurchased,
        "price": price,
        "episodes": episodes == null
            ? []
            : List<Episode>.from(
                episodes!.map((x) => x.toJson()),
              ),
      };
}

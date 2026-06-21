import 'dart:convert';

Episode episodeFromJson(String str) => Episode.fromJson(json.decode(str));

String episodeToJson(Episode data) => json.encode(data.toJson());

class Episode {
  int? id;
  int? episodeNumber;
  String? title;
  String? description;
  String? videoUrl;
  String? posterUrl;
  int? runtime;
  DateTime? releaseDate;
  bool? isActive;
  bool? isFree;
  int? seasonId;
  double? amount;
  int? viewCount;
  String? partName;

  Episode({
    this.id,
    this.episodeNumber,
    this.title,
    this.description,
    this.videoUrl,
    this.posterUrl,
    this.runtime,
    this.releaseDate,
    this.isActive,
    this.isFree,
    this.seasonId,
    this.amount,
    this.viewCount,
    this.partName,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json["id"],
        episodeNumber: json["episodeNumber"],
        title: json["title"],
        description: json["description"],
        videoUrl: json["videoUrl"],
        posterUrl: json["posterUrl"],
        runtime: json["runtime"],
        releaseDate: json["releaseDate"] == null
            ? null
            : DateTime.parse(json["releaseDate"]),
        isActive: json["active"] ?? json["isActive"],
        isFree: json["free"] ?? json["isFree"],
        seasonId: json["seasonId"],
        amount: json["amount"]?.toDouble(),
        viewCount: json["viewCount"],
        partName: json["partName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "episodeNumber": episodeNumber,
        "title": title,
        "description": description,
        "videoUrl": videoUrl,
        "posterUrl": posterUrl,
        "runtime": runtime,
        "releaseDate": releaseDate?.toIso8601String(),
        "isActive": isActive,
        "isFree": isFree,
        "seasonId": seasonId,
        "amount": amount,
        "viewCount": viewCount,
        "partName": partName,
      };
}

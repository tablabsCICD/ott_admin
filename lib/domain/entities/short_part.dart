import 'dart:convert';

ShortPartDTO shortPartDTOFromJson(String str) =>
    ShortPartDTO.fromJson(json.decode(str));

String shortPartDTOToJson(ShortPartDTO data) => json.encode(data.toJson());

class ShortPartDTO {
  String? partId;
  int? partNumber;
  String? title;
  int? coins;
  bool? isLocked;
  bool? isPurchased;
  String? videoUrl;
  String? thumbnail;
  int? durationSec;
  int? views;
  int? likes;
  String? nextPartId;
  bool? autoPlayNext;
  bool? isFreePreview;
  bool? isLiked;

  ShortPartDTO({
    this.partId,
    this.partNumber,
    this.title,
    this.coins,
    this.isLocked,
    this.isPurchased,
    this.videoUrl,
    this.thumbnail,
    this.durationSec,
    this.views,
    this.likes,
    this.nextPartId,
    this.autoPlayNext,
    this.isFreePreview,
    this.isLiked,
  });

  factory ShortPartDTO.fromJson(Map<String, dynamic> json) => ShortPartDTO(
        partId: json["partId"],
        partNumber: json["partNumber"],
        title: json["title"],
        coins: json["coins"],
        isLocked: json["isLocked"],
        isPurchased: json["isPurchased"],
        videoUrl: json["videoUrl"],
        thumbnail: json["thumbnail"],
        durationSec: json["durationSec"],
        views: json["views"],
        likes: json["likes"],
        nextPartId: json["nextPartId"],
        autoPlayNext: json["autoPlayNext"],
        isFreePreview: json["isFreePreview"],
        isLiked: json["isLiked"],
      );

  Map<String, dynamic> toJson() => {
        "partId": partId,
        "partNumber": partNumber,
        "title": title,
        "coins": coins,
        "isLocked": isLocked,
        "isPurchased": isPurchased,
        "videoUrl": videoUrl,
        "thumbnail": thumbnail,
        "durationSec": durationSec,
        "views": views,
        "likes": likes,
        "nextPartId": nextPartId,
        "autoPlayNext": autoPlayNext,
        "isFreePreview": isFreePreview,
        "isLiked": isLiked,
      };
}

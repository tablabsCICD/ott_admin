import 'package:admin_ott/domain/entities/content.dart';

class SaveContentRequest {
  String? ageRating;
  String? approvalStatus;
  String? approvedDateTime;
  List<String>? audioFormatList;
  Availability? availability;
  List<String>? castList;
  String? contentUrl;
  String? description;
  List<String>? directorList;
  List<String>? genersList;
  bool? isDownloadable;
  bool? isFeatured;
  List<String>? languageList;
  int? mediaHouseId;
  List<String>? posterUrlList;
  double? price;
  int? ratingCount;
  double? ratings;
  String? reason;
  String? releaseDate;
  String? rentlDuration;
  double? runtime;
  String? sensorCertificate;
  List<String>? subtitleLanguageList;
  String? title;
  double? totalRevenue;
  String? trailerUrl;
  String? type;
  String? uploadDateTime;
  int? views;

  SaveContentRequest({
    this.ageRating,
    this.approvalStatus,
    this.approvedDateTime,
    this.audioFormatList,
    this.availability,
    this.castList,
    this.contentUrl,
    this.description,
    this.directorList,
    this.genersList,
    this.isDownloadable,
    this.isFeatured,
    this.languageList,
    this.mediaHouseId,
    this.posterUrlList,
    this.price,
    this.ratingCount,
    this.ratings,
    this.reason,
    this.releaseDate,
    this.rentlDuration,
    this.runtime,
    this.sensorCertificate,
    this.subtitleLanguageList,
    this.title,
    this.totalRevenue,
    this.trailerUrl,
    this.type,
    this.uploadDateTime,
    this.views,
  });

  factory SaveContentRequest.fromJson(Map<String, dynamic> json) => SaveContentRequest(
    ageRating: json["ageRating"],
    approvalStatus: json["approvalStatus"],
    approvedDateTime: json["approvedDateTime"],
    audioFormatList: json["audioFormatList"] == null ? [] : List<String>.from(json["audioFormatList"]!.map((x) => x)),
    availability: json["availability"] == null ? null : Availability.fromJson(json["availability"]),
    castList: json["castList"] == null ? [] : List<String>.from(json["castList"]!.map((x) => x)),
    contentUrl: json["contentUrl"],
    description: json["description"],
    directorList: json["directorList"] == null ? [] : List<String>.from(json["directorList"]!.map((x) => x)),
    genersList: json["genersList"] == null ? [] : List<String>.from(json["genersList"]!.map((x) => x)),
    isDownloadable: json["isDownloadable"],
    isFeatured: json["isFeatured"],
    languageList: json["languageList"] == null ? [] : List<String>.from(json["languageList"]!.map((x) => x)),
    mediaHouseId: json["mediaHouseId"],
    posterUrlList: json["posterUrlList"] == null ? [] : List<String>.from(json["posterUrlList"]!.map((x) => x)),
    price: json["price"],
    ratingCount: json["ratingCount"],
    ratings: json["ratings"],
    reason: json["reason"],
    releaseDate: json["releaseDate"],
    rentlDuration: json["rentlDuration"],
    runtime: json["runtime"],
    sensorCertificate: json["sensorCertificate"],
    subtitleLanguageList: json["subtitleLanguageList"] == null ? [] : List<String>.from(json["subtitleLanguageList"]!.map((x) => x)),
    title: json["title"],
    totalRevenue: json["totalRevenue"],
    trailerUrl: json["trailerUrl"],
    type: json["type"],
    uploadDateTime: json["uploadDateTime"],
    views: json["views"],
  );

  Map<String, dynamic> toJson() => {
    "ageRating": ageRating,
    "approvalStatus": approvalStatus,
    "approvedDateTime": approvedDateTime,
    "audioFormatList": audioFormatList == null ? [] : List<dynamic>.from(audioFormatList!.map((x) => x)),
    "availability": availability?.toJson(),
    "castList": castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
    "contentUrl": contentUrl,
    "description": description,
    "directorList": directorList == null ? [] : List<dynamic>.from(directorList!.map((x) => x)),
    "genersList": genersList == null ? [] : List<dynamic>.from(genersList!.map((x) => x)),
    "isDownloadable": isDownloadable,
    "isFeatured": isFeatured,
    "languageList": languageList == null ? [] : List<dynamic>.from(languageList!.map((x) => x)),
    "mediaHouseId": mediaHouseId,
    "posterUrlList": posterUrlList == null ? [] : List<dynamic>.from(posterUrlList!.map((x) => x)),
    "price": price,
    "ratingCount": ratingCount,
    "ratings": ratings,
    "reason": reason,
    "releaseDate": releaseDate,
    "rentlDuration": rentlDuration,
    "runtime": runtime,
    "sensorCertificate": sensorCertificate,
    "subtitleLanguageList": subtitleLanguageList == null ? [] : List<dynamic>.from(subtitleLanguageList!.map((x) => x)),
    "title": title,
    "totalRevenue": totalRevenue,
    "trailerUrl": trailerUrl,
    "type": type,
    "uploadDateTime": uploadDateTime,
    "views": views,
  };
}




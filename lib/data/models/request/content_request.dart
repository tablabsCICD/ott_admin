import 'package:admin_ott/domain/entities/content.dart';

class SaveContentRequest {
  int? id;
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
  List<String>? genreList;
  bool? isDownloadable;
  bool? isFeatured;
  List<String>? languageList;
  int? mediaHouseId;
  String? mediaHouseName;
  List<String>? posterUrlList;
  double? price;
  int? ratingCount;
  double? ratings;
  String? reason;
  String? releaseDate;
  String? rentlDuration;
  double? runtime;
  String? sensorCertificate;
  String? agreementUrl;
  List<String>? subtitleLanguageList;
  String? title;
  double? totalRevenue;
  double? adminRevnue;
  double? mediaHouseRevenue;
  int? totalPurchase;
  double? adminIncentivePecentage;
  double? mediaHouseIncentivePecentage;
  String? teaserUrl;
  String? trailerUrl;
  String? type;
  String? uploadDateTime;
  int? views;

  Map<String, String>? languageAudioUrls;
  Map<String, String>? subtitleLanguageUrls;

  SaveContentRequest({
    this.id,
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
    this.genreList,
    this.isDownloadable,
    this.isFeatured,
    this.languageList,
    this.languageAudioUrls,
    this.subtitleLanguageUrls,
    this.mediaHouseId,
    this.mediaHouseName,
    this.posterUrlList,
    this.price,
    this.ratingCount,
    this.ratings,
    this.reason,
    this.releaseDate,
    this.rentlDuration,
    this.runtime,
    this.sensorCertificate,
    this.agreementUrl,
    this.subtitleLanguageList,
    this.title,
    this.totalRevenue,
    this.adminRevnue,
    this.mediaHouseRevenue,
    this.totalPurchase,
    this.adminIncentivePecentage,
    this.mediaHouseIncentivePecentage,
    this.teaserUrl,
    this.trailerUrl,
    this.type,
    this.uploadDateTime,
    this.views,
  });

  factory SaveContentRequest.fromJson(Map<String, dynamic> json) => SaveContentRequest(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
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
    genreList: json["genreList"] == null ? [] : List<String>.from(json["genreList"]!.map((x) => x)),
    isDownloadable: json["isDownloadable"],
    isFeatured: json["isFeatured"],
    languageList: json["languageList"] == null
        ? []
        : List<String>.from(json["languageList"]!.map((x) {
            if (x is Map) {
              return (x["language"] ?? x["name"] ?? x["value"] ?? "").toString();
            }
            return x.toString();
          }).where((e) => e.trim().isNotEmpty)),
    mediaHouseId: json["mediaHouseId"],
    mediaHouseName: json["mediaHouseName"],
    posterUrlList: json["posterUrlList"] == null ? [] : List<String>.from(json["posterUrlList"]!.map((x) => x)),
    price: json["price"]?.toDouble(),
    ratingCount: json["ratingCount"],
    ratings: json["ratings"]?.toDouble(),
    reason: json["reason"],
    releaseDate: json["releaseDate"],
    rentlDuration: json["rentlDuration"],
    runtime: json["runtime"]?.toDouble(),
    sensorCertificate: json["sensorCertificate"],
    agreementUrl: json["agreementUrl"] ?? json["sensorCertificate"],
    subtitleLanguageList: json["subtitleLanguageList"] == null ? [] : List<String>.from(json["subtitleLanguageList"]!.map((x) {
      if (x is Map) {
        return (x["language"] ?? x["name"] ?? x["value"] ?? "").toString();
      }
      return x.toString();
    }).where((e) => e.trim().isNotEmpty)),
    title: json["title"],
    totalRevenue: json["totalRevenue"]?.toDouble(),
    adminRevnue: (json["AdminRevnue"] ?? json["adminRevenue"] ?? json["adminRevnue"])?.toDouble(),
    mediaHouseRevenue: json["mediaHouseRevenue"]?.toDouble(),
    totalPurchase: json["totalPurchase"],
    adminIncentivePecentage: json["adminIncentivePecentage"]?.toDouble(),
    mediaHouseIncentivePecentage: json["mediaHouseIncentivePecentage"]?.toDouble(),
    teaserUrl: json["teaserUrl"] ?? json["TeaserUrl"] ?? json["teaser"] ?? json["Teaser"],
    trailerUrl: json["trailerUrl"] ?? json["TrailerUrl"] ?? json["trailer"] ?? json["Trailer"],
    type: json["type"],
    uploadDateTime: json["uploadDateTime"],
    views: json["views"],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id,
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
    "genreList": genreList == null ? (genersList == null ? [] : List<dynamic>.from(genersList!.map((x) => x))) : List<dynamic>.from(genreList!.map((x) => x)),
    "isDownloadable": isDownloadable,
    "isFeatured": isFeatured,
    "languageList": languageList == null
        ? []
        : List<String>.from(languageList!.map((lang) => lang.trim()).where((lang) => lang.isNotEmpty)),
    "mediaHouseId": mediaHouseId,
    if (mediaHouseName != null && mediaHouseName!.isNotEmpty) "mediaHouseName": mediaHouseName,
    "posterUrlList": posterUrlList == null ? [] : List<dynamic>.from(posterUrlList!.map((x) => x)),
    "price": price,
    "ratingCount": ratingCount,
    "ratings": ratings,
    "reason": reason,
    "releaseDate": releaseDate,
    "rentlDuration": rentlDuration,
    "runtime": runtime,
    "sensorCertificate": sensorCertificate,
    if (agreementUrl != null && agreementUrl!.isNotEmpty) "agreementUrl": agreementUrl,
    "subtitleLanguageList": subtitleLanguageList == null
        ? []
        : List<String>.from(subtitleLanguageList!.map((sub) => sub.trim()).where((sub) => sub.isNotEmpty)),
    "title": title,
    "totalRevenue": totalRevenue,
    "AdminRevnue": adminRevnue,
    "adminRevenue": adminRevnue,
    "mediaHouseRevenue": mediaHouseRevenue,
    "totalPurchase": totalPurchase,
    "adminIncentivePecentage": adminIncentivePecentage,
    "mediaHouseIncentivePecentage": mediaHouseIncentivePecentage,
    if (teaserUrl != null) "teaserUrl": teaserUrl,
    "trailerUrl": trailerUrl,
    "type": type,
    "uploadDateTime": uploadDateTime,
    "views": views,
  };
}

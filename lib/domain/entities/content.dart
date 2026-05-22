class Content {
  int? id;
  String? title;
  String? description;
  int? runtime;
  dynamic releaseDate;
  double? ratings;
  double? price;
  List<String>? languageList;
  List<String>? castList;
  List<String>? genreList;
  List<String>? directorList;
  int? views;
  double? totalRevenue;
  String? ageRating;
  List<String>? posterUrlList;
  String? trailerUrl;
  String? contentUrl;
  String? approvalStatus;
  String? type;
  String? sensorCertificate;
  bool? isFeatured;
  Availability? availability;
  List<String>? audioFormatList;
  List<String>? subtitleLanguageList;
  bool? isDownloadable;
  String? uploadDateTime;
  String? approvedDateTime;
  String? mediaHouseName;
  int? mediaHouseId;
  int? ratingCount;
  String? rentlDuration;
  double? adminIncentivePecentage;
  double? mediaHouseIncentivePecentage;
  String? reason;

  Content(
      {this.id,
      this.title,
      this.description,
      this.runtime,
      this.releaseDate,
      this.ratings,
      this.price,
      this.languageList,
      this.castList,
      this.genreList,
      this.directorList,
      this.views,
      this.totalRevenue,
      this.ageRating,
      this.posterUrlList,
      this.trailerUrl,
      this.contentUrl,
      this.approvalStatus,
      this.type,
      this.sensorCertificate,
      this.isFeatured,
      this.availability,
      this.audioFormatList,
      this.subtitleLanguageList,
      this.isDownloadable,
      this.uploadDateTime,
      this.approvedDateTime,
      this.mediaHouseName,
      this.mediaHouseId,
      this.ratingCount,
      this.rentlDuration,
      this.adminIncentivePecentage,
      this.mediaHouseIncentivePecentage,
      this.reason});

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: _asInt(json["id"]),
        title: _asString(json["title"]),
        description: _asString(json["description"]),
        runtime: _asInt(json["runtime"]),
        releaseDate: json["releaseDate"],
        ratings: _asDouble(json["ratings"]),
        price: _asDouble(json["price"]),
        languageList: _asStringList(json["languageList"]),
        castList: _asStringList(json["castList"]),
        genreList: _asStringList(json["genreList"]),
        directorList: _asStringList(json["directorList"]),
        views: _asInt(json["views"]),
        totalRevenue: _asDouble(json["totalRevenue"]),
        ageRating: _asString(json["ageRating"]),
        posterUrlList: _asStringList(json["posterUrlList"]),
        trailerUrl: _asString(json["trailerUrl"]),
        contentUrl: _asString(json["contentUrl"]),
        approvalStatus: _asString(json["approvalStatus"]),
        type: _asString(json["type"]),
        sensorCertificate: _asString(json["sensorCertificate"]),
        isFeatured: _asBool(json["isFeatured"]),
        availability: json["availability"] == null
            ? null
            : Availability.fromJson(json["availability"]),
        audioFormatList: _asStringList(json["audioFormatList"]),
        subtitleLanguageList: _asStringList(json["subtitleLanguageList"]),
        isDownloadable: _asBool(json["isDownloadable"]),
        uploadDateTime: _asString(json["uploadDateTime"]),
        approvedDateTime: _asString(json["approvedDateTime"]),
        mediaHouseName: _asString(json["mediaHouseName"]),
        mediaHouseId: _asInt(json["mediaHouseId"]),
        ratingCount: _asInt(json["ratingCount"]),
        rentlDuration: _asString(json["rentlDuration"]),
        adminIncentivePecentage: _asDouble(json["adminIncentivePecentage"]),
        mediaHouseIncentivePecentage:
            _asDouble(json["mediaHouseIncentivePecentage"]),
        reason: _asString(json["reason"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "runtime": runtime,
        "releaseDate": releaseDate,
        "ratings": ratings,
        "price": price,
        "languageList": languageList == null
            ? []
            : List<dynamic>.from(languageList!.map((x) => x)),
        "castList":
            castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
        "genreList": genreList == null
            ? []
            : List<dynamic>.from(genreList!.map((x) => x)),
        "directorList": directorList == null
            ? []
            : List<dynamic>.from(directorList!.map((x) => x)),
        "views": views,
        "totalRevenue": totalRevenue,
        "ageRating": ageRating,
        "posterUrlList": posterUrlList == null
            ? []
            : List<dynamic>.from(posterUrlList!.map((x) => x)),
        "trailerUrl": trailerUrl,
        "contentUrl": contentUrl,
        "approvalStatus": approvalStatus,
        "type": type,
        "sensorCertificate": sensorCertificate,
        "isFeatured": isFeatured,
        "availability": availability?.toJson(),
        "audioFormatList": audioFormatList == null
            ? []
            : List<dynamic>.from(audioFormatList!.map((x) => x)),
        "subtitleLanguageList": subtitleLanguageList == null
            ? []
            : List<dynamic>.from(subtitleLanguageList!.map((x) => x)),
        "isDownloadable": isDownloadable,
        "uploadDateTime": uploadDateTime,
        "approvedDateTime": approvedDateTime,
        "mediaHouseName": mediaHouseName,
        "mediaHouseId": mediaHouseId,
        "ratingCount": ratingCount,
        "rentlDuration": rentlDuration,
        "adminIncentivePecentage": adminIncentivePecentage,
        "mediaHouseIncentivePecentage": mediaHouseIncentivePecentage,
        "reason": reason
      };
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == "true" || normalized == "1") return true;
  if (normalized == "false" || normalized == "0") return false;
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            return (item["language"] ?? item["name"] ?? item["value"] ?? "")
                .toString();
          }
          return item.toString();
        })
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  return [];
}

class Availability {
  List<String>? regions;
  List<String>? platforms;

  Availability({
    this.regions,
    this.platforms,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
        regions: json["regions"] == null
            ? []
            : List<String>.from(json["regions"]!.map((x) => x)),
        platforms: json["platforms"] == null
            ? []
            : List<String>.from(json["platforms"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "regions":
            regions == null ? [] : List<dynamic>.from(regions!.map((x) => x)),
        "platforms": platforms == null
            ? []
            : List<dynamic>.from(platforms!.map((x) => x)),
      };
}

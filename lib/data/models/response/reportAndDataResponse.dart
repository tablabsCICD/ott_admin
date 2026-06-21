class ReportAndDataResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  ReportAndDataResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory ReportAndDataResponse.fromJson(Map<String, dynamic> json) {
    return ReportAndDataResponse(
      message: json["message"]?.toString(),
      data: Data.fromDynamic(json["data"]),
      statusCode: _asInt(json["statusCode"]),
      success: json["success"] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "success": success,
      };
}

class Data {
  List<ReportAndDataObject>? mediaHouse;

  Data({
    this.mediaHouse,
  });

  factory Data.fromDynamic(dynamic value) {
    if (value is List) {
      return Data(mediaHouse: _readReportRows(value));
    }
    if (value is Map<String, dynamic>) {
      return Data.fromJson(value);
    }
    return Data(mediaHouse: []);
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    for (final key in [
      "MediaHouse",
      "mediaHouse",
      "reportAndData",
      "reports",
      "contentList",
      "contents",
    ]) {
      final rows = json[key];
      if (rows is List) {
        return Data(mediaHouse: _readReportRows(rows));
      }
    }

    final mediaHouses = json["mediaHouses"];
    if (mediaHouses is List) {
      return Data(
        mediaHouse:
            mediaHouses.whereType<Map<String, dynamic>>().expand((mediaHouse) {
          final contents = mediaHouse["contents"] ??
              mediaHouse["contentList"] ??
              mediaHouse["reports"];
          if (contents is! List) return <ReportAndDataObject>[];

          return contents
              .whereType<Map<String, dynamic>>()
              .map(
                (content) => ReportAndDataObject.fromMediaHouseContent(
                  content,
                  mediaHouseName: (mediaHouse["mediaHouse"] ??
                          mediaHouse["mediaHouseName"] ??
                          mediaHouse["name"])
                      ?.toString(),
                  designation: mediaHouse["designation"]?.toString(),
                ),
              )
              .toList();
        }).toList(),
      );
    }

    return Data(mediaHouse: []);
  }

  Map<String, dynamic> toJson() => {
        "MediaHouse": mediaHouse == null
            ? []
            : List<dynamic>.from(mediaHouse!.map((item) => item.toJson())),
      };
}

class ReportAndDataObject {
  int? contentId;
  String? contentName;
  String? contentStatus;
  dynamic releasedDate;
  int? totalViews;
  dynamic totalRevenue;
  int? currentPecentageIncentive;
  int? earnedIncentive;
  double? price;
  String? contentType;
  String? releaseTime;
  String? mediaHouseName;
  String? designation;
  List<String> languageList;

  ReportAndDataObject({
    this.contentId,
    this.contentName,
    this.contentStatus,
    this.releasedDate,
    this.totalViews,
    this.totalRevenue,
    this.currentPecentageIncentive,
    this.earnedIncentive,
    this.price,
    this.contentType,
    this.releaseTime,
    this.mediaHouseName,
    this.designation,
    this.languageList = const [],
  });

  factory ReportAndDataObject.fromJson(Map<String, dynamic> json) {
    return ReportAndDataObject(
      contentId: _asInt(json["contentId"]),
      contentName: (json["contentName"] ?? json["movieName"] ?? json["name"])
          ?.toString(),
      contentStatus: json["contentStatus"]?.toString(),
      releasedDate: json["releasedDate"] ?? json["releaseDate"],
      totalViews: _asInt(json["totalViews"] ?? json["views"]),
      totalRevenue: json["totalRevenue"] ?? json["revenue"] ?? 0,
      currentPecentageIncentive: _asInt(json["currentPecentageIncentive"]),
      earnedIncentive: _asInt(json["earnedIncentive"]),
      price: _asDouble(json["price"]),
      contentType: json["contentType"]?.toString(),
      releaseTime: json["releaseTime"]?.toString(),
      mediaHouseName:
          (json["mediaHouseName"] ?? json["mediaHouse"])?.toString(),
      designation: json["designation"]?.toString(),
      languageList: _readLanguages(json["language"]),
    );
  }

  factory ReportAndDataObject.fromMediaHouseContent(
    Map<String, dynamic> json, {
    String? mediaHouseName,
    String? designation,
  }) {
    return ReportAndDataObject(
      contentId: _asInt(json["contentId"]),
      contentName:
          (json["movieName"] ?? json["contentName"] ?? "Untitled").toString(),
      contentStatus: json["contentStatus"]?.toString(),
      releasedDate: json["releasedDate"],
      totalViews: _asInt(json["views"] ?? json["totalViews"]) ?? 0,
      totalRevenue: json["revenue"] ?? json["totalRevenue"] ?? 0,
      currentPecentageIncentive: _asInt(json["currentPecentageIncentive"]),
      earnedIncentive: _asInt(json["earnedIncentive"]) ?? 0,
      price: _asDouble(json["price"]),
      contentType: json["contentType"]?.toString(),
      releaseTime: json["releaseTime"]?.toString(),
      mediaHouseName: mediaHouseName,
      designation: designation,
      languageList: _readLanguages(json["language"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "contentId": contentId,
        "contentName": contentName,
        "contentStatus": contentStatus,
        "releasedDate": releasedDate,
        "totalViews": totalViews,
        "totalRevenue": totalRevenue,
        "currentPecentageIncentive": currentPecentageIncentive,
        "earnedIncentive": earnedIncentive,
        "price": price,
        "contentType": contentType,
        "releaseTime": releaseTime,
        "mediaHouseName": mediaHouseName,
        "designation": designation,
        "language": languageList,
      };
}

List<ReportAndDataObject> _readReportRows(List<dynamic> rows) {
  return rows
      .whereType<Map<String, dynamic>>()
      .map(ReportAndDataObject.fromJson)
      .toList();
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<String> _readLanguages(dynamic value) {
  if (value is! List) return [];

  return value
      .map((language) {
        if (language is Map<String, dynamic>) {
          return language["language"]?.toString() ?? "";
        }
        return language.toString();
      })
      .where((language) => language.trim().isNotEmpty)
      .toList();
}

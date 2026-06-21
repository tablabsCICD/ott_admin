import 'package:admin_ott/domain/entities/audio_track.dart';
import 'package:admin_ott/domain/entities/cast_crew.dart';
import 'package:admin_ott/domain/entities/short_part.dart';

class ShortMaster {
  int? id;
  String? title;
  String? description;
  String? poster;
  String? posterUrl;
  int? totalParts;
  int? coinsPerPart;
  String? creatorName;
  int? viewCount;
  int? likeCount;
  bool? isTrending;
  String? category;
  List<String> tags;
  List<AudioTrack> languageList;
  List<ShortPartDTO> parts;
  String? rentlDuration;
  List<Cast> castList;
  List<String> crewList;
  double? mediaHouseRevenue;
  double? adminRevenue;
  double? totalRevenue;
  String? approvalStatus;
  int? mediaHouseId;
  dynamic uploadDateTime;
  dynamic approvedDateTime;
  dynamic createdAt;
  dynamic createdDate;

  ShortMaster({
    this.id,
    this.title,
    this.description,
    this.poster,
    this.posterUrl,
    this.totalParts,
    this.coinsPerPart,
    this.creatorName,
    this.viewCount,
    this.likeCount,
    this.isTrending,
    this.category,
    this.tags = const [],
    this.languageList = const [],
    this.parts = const [],
    this.rentlDuration,
    this.castList = const [],
    this.crewList = const [],
    this.mediaHouseRevenue,
    this.adminRevenue,
    this.totalRevenue,
    this.approvalStatus,
    this.mediaHouseId,
    this.uploadDateTime,
    this.approvedDateTime,
    this.createdAt,
    this.createdDate,
  });

  factory ShortMaster.fromJson(Map<String, dynamic> json) => ShortMaster(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        poster: json["poster"] ?? json["posterUrl"],
        posterUrl: json["posterUrl"] ?? json["poster"],
        totalParts: json["totalParts"],
        coinsPerPart: json["coinsPerPart"],
        creatorName: json["creatorName"],
        viewCount: json["viewCount"],
        likeCount: json["likeCount"],
        isTrending: json["isTrending"],
        category: json["category"],
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"].map((x) => x)),
        languageList: json["languageList"] == null
            ? []
            : List<AudioTrack>.from(
                json["languageList"].map((x) => AudioTrack.fromJson(x)),
              ),
        parts: json["parts"] == null
            ? []
            : List<ShortPartDTO>.from(
                json["parts"].map((x) => ShortPartDTO.fromJson(x)),
              ),
        rentlDuration: json["rentlDuration"],
        castList: json["castList"] == null
            ? []
            : List<Cast>.from(
                json["castList"].map((x) => Cast.fromJson(x)),
              ),
        crewList: json["crewList"] == null
            ? []
            : List<String>.from(json["crewList"].map((x) => x)),
        mediaHouseRevenue: json["mediaHouseRevenue"]?.toDouble(),
        adminRevenue: json["AdminRevnue"]?.toDouble(),
        totalRevenue: json["totalRevenue"]?.toDouble(),
        approvalStatus: json["approvalStatus"],
        mediaHouseId: json["mediaHouseId"],
        uploadDateTime: json["uploadDateTime"],
        approvedDateTime: json["approvedDateTime"],
        createdAt: json["createdAt"],
        createdDate: json["createdDate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "poster": poster,
        "posterUrl": posterUrl,
        "totalParts": totalParts,
        "coinsPerPart": coinsPerPart,
        "creatorName": creatorName,
        "viewCount": viewCount,
        "likeCount": likeCount,
        "isTrending": isTrending,
        "category": category,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "languageList": List<dynamic>.from(
          languageList.map((x) => x.toJson()),
        ),
        "parts": List<dynamic>.from(
          parts.map((x) => x.toJson()),
        ),
        "rentlDuration": rentlDuration,
        "castList": List<dynamic>.from(
          castList.map((x) => x.toJson()),
        ),
        "crewList": List<dynamic>.from(crewList.map((x) => x)),
        "mediaHouseRevenue": mediaHouseRevenue,
        "AdminRevnue": adminRevenue,
        "totalRevenue": totalRevenue,
        "approvalStatus": approvalStatus,
        "mediaHouseId": mediaHouseId,
        "uploadDateTime": uploadDateTime,
        "approvedDateTime": approvedDateTime,
        "createdAt": createdAt,
        "createdDate": createdDate,
      };
}

class ShortMastersResponse {
  String? message;
  List<ShortMaster> data;
  bool? success;

  ShortMastersResponse({
    this.message,
    this.data = const [],
    this.success,
  });

  factory ShortMastersResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    final rawShorts = rawData is Map<String, dynamic>
        ? rawData["miniSeries"] ?? rawData["shorts"] ?? rawData["content"]
        : rawData;

    return ShortMastersResponse(
      message: json["message"]?.toString(),
      data: rawShorts is List
          ? rawShorts
              .map((x) => ShortMaster.fromJson(Map<String, dynamic>.from(x)))
              .toList()
          : const [],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "success": success,
      };
}

class ShortDetailResponse {
  String? message;
  ShortDetailData? data;
  bool? success;

  ShortDetailResponse({
    this.message,
    this.data,
    this.success,
  });

  factory ShortDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    final detail = rawData is Map<String, dynamic>
        ? rawData["miniSeries"] ??
            rawData["short"] ??
            rawData["shortMaster"] ??
            rawData["content"] ??
            rawData
        : null;

    return ShortDetailResponse(
      message: json["message"]?.toString(),
      data: detail is Map<String, dynamic>
          ? ShortDetailData.fromJson(Map<String, dynamic>.from(detail))
          : null,
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "success": success,
      };
}

class ShortDetailData extends ShortMaster {
  ShortDetailData({
    super.id,
    super.title,
    super.description,
    super.poster,
    super.posterUrl,
    super.totalParts,
    super.coinsPerPart,
    super.creatorName,
    super.viewCount,
    super.likeCount,
    super.isTrending,
    super.category,
    super.tags,
    super.languageList,
    super.parts,
    super.rentlDuration,
    super.castList,
    super.crewList,
    super.mediaHouseRevenue,
    super.adminRevenue,
    super.totalRevenue,
    super.approvalStatus,
    super.mediaHouseId,
    super.uploadDateTime,
    super.approvedDateTime,
    super.createdAt,
    super.createdDate,
  });

  factory ShortDetailData.fromJson(Map<String, dynamic> json) {
    final master = ShortMaster.fromJson(json);
    return ShortDetailData(
      id: master.id,
      title: master.title,
      description: master.description,
      poster: master.poster,
      posterUrl: master.posterUrl,
      totalParts: master.totalParts,
      coinsPerPart: master.coinsPerPart,
      creatorName: master.creatorName,
      viewCount: master.viewCount,
      likeCount: master.likeCount,
      isTrending: master.isTrending,
      category: master.category,
      tags: master.tags,
      languageList: master.languageList,
      parts: master.parts,
      rentlDuration: master.rentlDuration,
      castList: master.castList,
      crewList: master.crewList,
      mediaHouseRevenue: master.mediaHouseRevenue,
      adminRevenue: master.adminRevenue,
      totalRevenue: master.totalRevenue,
      approvalStatus: master.approvalStatus,
      mediaHouseId: master.mediaHouseId,
      uploadDateTime: master.uploadDateTime,
      approvedDateTime: master.approvedDateTime,
      createdAt: master.createdAt,
      createdDate: master.createdDate,
    );
  }
}

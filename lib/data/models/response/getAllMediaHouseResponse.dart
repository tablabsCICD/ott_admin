import 'package:admin_ott/domain/entities/mediaHouse.dart';

class GetAllMediaHouseResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  dynamic totalViews;
  dynamic totalLikes;
  dynamic totalRevenue;
  bool? success;

  GetAllMediaHouseResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
    this.success,
  });

  factory GetAllMediaHouseResponse.fromJson(Map<String, dynamic> json) =>
      GetAllMediaHouseResponse(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        statusCode: json["statusCode"],
        total: json["total"],
        totalViews: json["totalViews"],
        totalLikes: json["totalLikes"],
        totalRevenue: json["totalRevenue"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "total": total,
        "totalViews": totalViews,
        "totalLikes": totalLikes,
        "totalRevenue": totalRevenue,
        "success": success,
      };
}

class Data {
  List<MediaHouse>? mediaHouses;

  Data({
    this.mediaHouses,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        mediaHouses: json["mediaHouses"] == null
            ? []
            : List<MediaHouse>.from(
                json["mediaHouses"]!.map((x) => MediaHouse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mediaHouses": mediaHouses == null
            ? []
            : List<dynamic>.from(mediaHouses!.map((x) => x.toJson())),
      };
}

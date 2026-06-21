import 'package:admin_ott/domain/entities/shorts_models.dart';

class ShortsByStatusPageResponse {
  String? message;
  Data? data;
  bool? success;

  ShortsByStatusPageResponse({
    this.message,
    this.data,
    this.success,
  });

  factory ShortsByStatusPageResponse.fromJson(Map<String, dynamic> json) =>
      ShortsByStatusPageResponse(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "success": success,
      };
}

class Data {
  int? totalItems;
  List<ShortMaster>? miniSeries;
  int? totalPages;
  int? pageSize;
  bool? hasPrevious;
  bool? hasNext;
  int? currentPage;

  Data({
    this.totalItems,
    this.miniSeries,
    this.totalPages,
    this.pageSize,
    this.hasPrevious,
    this.hasNext,
    this.currentPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalItems: json["totalItems"],
        miniSeries: json["miniSeries"] == null
            ? []
            : List<ShortMaster>.from(
                json["miniSeries"]!.map((x) => ShortMaster.fromJson(x))),
        totalPages: json["totalPages"],
        pageSize: json["pageSize"],
        hasPrevious: json["hasPrevious"],
        hasNext: json["hasNext"],
        currentPage: json["currentPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalItems": totalItems,
        "miniSeries": miniSeries == null
            ? []
            : List<dynamic>.from(miniSeries!.map((x) => x.toJson())),
        "totalPages": totalPages,
        "pageSize": pageSize,
        "hasPrevious": hasPrevious,
        "hasNext": hasNext,
        "currentPage": currentPage,
      };
}

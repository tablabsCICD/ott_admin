import 'package:admin_ott/domain/entities/content.dart';

class GetAllVideoResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAllVideoResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory GetAllVideoResponse.fromJson(Map<String, dynamic> json) => GetAllVideoResponse(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    statusCode: json["statusCode"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "success": success,
  };
}

class Data {
  List<Content>? contentList;

  Data({
    this.contentList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    contentList: json["ContentList"] == null ? [] : List<Content>.from(json["ContentList"]!.map((x) => Content.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ContentList": contentList == null ? [] : List<dynamic>.from(contentList!.map((x) => x.toJson())),
  };
}
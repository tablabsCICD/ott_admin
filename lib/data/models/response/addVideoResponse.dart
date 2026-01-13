import '../../../domain/entities/content.dart';
import '../../../domain/entities/mediaHouse.dart';

class AddVideoResponse {
  Content? data;
  String? message;
  int? statusCode;
  bool? isSuccess;

  AddVideoResponse({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  factory AddVideoResponse.fromJson(Map<String, dynamic> json) => AddVideoResponse(
    data: json["data"] == null ? null : Content.fromJson(json["data"]),
    message: json["message"],
    statusCode: json["statusCode"],
    isSuccess: json["isSuccess"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "message": message,
    "statusCode": statusCode,
    "isSuccess": isSuccess,
  };
}





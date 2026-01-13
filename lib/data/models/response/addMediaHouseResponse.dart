import '../../../domain/entities/mediaHouse.dart';

class AddMediaHouseResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  AddMediaHouseResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory AddMediaHouseResponse.fromJson(Map<String, dynamic> json) => AddMediaHouseResponse(
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
  MediaHouse? mediaHouse;

  Data({
    this.mediaHouse,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    mediaHouse: json["MediaHouse"] == null ? null : MediaHouse.fromJson(json["MediaHouse"]),
  );

  Map<String, dynamic> toJson() => {
    "MediaHouse": mediaHouse?.toJson(),
  };
}


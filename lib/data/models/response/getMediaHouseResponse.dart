// To parse this JSON data, do
//
//     final getMediaHouseResponse = getMediaHouseResponseFromJson(jsonString);

import 'dart:convert';

import '../../../domain/entities/mediaHouse.dart';

GetMediaHouseResponse getMediaHouseResponseFromJson(String str) => GetMediaHouseResponse.fromJson(json.decode(str));

String getMediaHouseResponseToJson(GetMediaHouseResponse data) => json.encode(data.toJson());

class GetMediaHouseResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  GetMediaHouseResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory GetMediaHouseResponse.fromJson(Map<String, dynamic> json) => GetMediaHouseResponse(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    statusCode: json["statusCode"],
    total: json["total"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "total": total,
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


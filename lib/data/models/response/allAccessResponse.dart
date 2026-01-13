// To parse this JSON data, do
//
//     final allAccessResponse = allAccessResponseFromJson(jsonString);

import 'dart:convert';

AllAccessResponse allAccessResponseFromJson(String str) => AllAccessResponse.fromJson(json.decode(str));

String allAccessResponseToJson(AllAccessResponse data) => json.encode(data.toJson());

class AllAccessResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  AllAccessResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory AllAccessResponse.fromJson(Map<String, dynamic> json) => AllAccessResponse(
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
  List<AccessControl>? accessControl;

  Data({
    this.accessControl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accessControl: json["Access Control"] == null ? [] : List<AccessControl>.from(json["Access Control"]!.map((x) => AccessControl.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Access Control": accessControl == null ? [] : List<dynamic>.from(accessControl!.map((x) => x.toJson())),
  };
}

class AccessControl {
  int? id;
  String? promoterLevel;
  bool? manageUser;
  bool? manageMediaHouse;
  bool? manageContent;
  bool? manageTrasaction;
  bool? helpDesk;

  AccessControl({
    this.id,
    this.promoterLevel,
    this.manageUser,
    this.manageMediaHouse,
    this.manageContent,
    this.manageTrasaction,
    this.helpDesk,
  });

  factory AccessControl.fromJson(Map<String, dynamic> json) => AccessControl(
    id: json["id"],
    promoterLevel: json["promoterLevel"],
    manageUser: json["manageUser"],
    manageMediaHouse: json["manageMediaHouse"],
    manageContent: json["manageContent"],
    manageTrasaction: json["manageTrasaction"],
    helpDesk: json["helpDesk"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "promoterLevel": promoterLevel,
    "manageUser": manageUser,
    "manageMediaHouse": manageMediaHouse,
    "manageContent": manageContent,
    "manageTrasaction": manageTrasaction,
    "helpDesk": helpDesk,
  };
}

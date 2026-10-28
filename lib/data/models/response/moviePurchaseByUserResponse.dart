import 'package:admin_ott/domain/entities/content.dart';

import '../../../domain/entities/user.dart';

class MoviePurchaseByUserResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  MoviePurchaseByUserResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory MoviePurchaseByUserResponse.fromJson(Map<String, dynamic> json) => MoviePurchaseByUserResponse(
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
  List<UserContent>? userContent;

  Data({
    this.userContent,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userContent: json["userContent"] == null ? [] : List<UserContent>.from(json["userContent"]!.map((x) => UserContent.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userContent": userContent == null ? [] : List<dynamic>.from(userContent!.map((x) => x.toJson())),
  };
}

class UserContent {
  int? id;
  int? contentPercentage;
  int? dateFrom;
  int? dateTo;
  String? refferedBy;
  int? price;
  bool? isGifted;
  int? userIdGiftFrom;
  int? userIdGiftTo;
  Content? movie;
  User? user;
  String? status;
  bool? active;

  UserContent({
    this.id,
    this.contentPercentage,
    this.dateFrom,
    this.dateTo,
    this.refferedBy,
    this.price,
    this.isGifted,
    this.userIdGiftFrom,
    this.userIdGiftTo,
    this.movie,
    this.user,
    this.status,
    this.active,
  });

  factory UserContent.fromJson(Map<String, dynamic> json) => UserContent(
    id: json["id"] is int ? json["id"] : (json["id"] is num ? (json["id"] as num).toInt() : int.tryParse(json["id"]?.toString() ?? '')),
    contentPercentage: json["contentPercentage"] is int ? json["contentPercentage"] : (json["contentPercentage"] is num ? (json["contentPercentage"] as num).toInt() : int.tryParse(json["contentPercentage"]?.toString() ?? '')),
    dateFrom: json["dateFrom"] is int ? json["dateFrom"] : (json["dateFrom"] is num ? (json["dateFrom"] as num).toInt() : int.tryParse(json["dateFrom"]?.toString() ?? '')),
    dateTo: json["dateTo"] is int ? json["dateTo"] : (json["dateTo"] is num ? (json["dateTo"] as num).toInt() : int.tryParse(json["dateTo"]?.toString() ?? '')),
    refferedBy: json["refferedBy"]?.toString(),
    price: json["price"] is int ? json["price"] : (json["price"] is num ? (json["price"] as num).toInt() : int.tryParse(json["price"]?.toString() ?? '')),
    isGifted: json["isGifted"] is bool ? json["isGifted"] : (json["isGifted"] != null ? json["isGifted"].toString().toLowerCase() == 'true' : null),
    userIdGiftFrom: json["userIdGiftFrom"] is int ? json["userIdGiftFrom"] : (json["userIdGiftFrom"] is num ? (json["userIdGiftFrom"] as num).toInt() : int.tryParse(json["userIdGiftFrom"]?.toString() ?? '')),
    userIdGiftTo: json["userIdGiftTo"] is int ? json["userIdGiftTo"] : (json["userIdGiftTo"] is num ? (json["userIdGiftTo"] as num).toInt() : int.tryParse(json["userIdGiftTo"]?.toString() ?? '')),
    movie: json["movie"] == null ? null : (json["movie"] is Map<String, dynamic> ? Content.fromJson(json["movie"]) : (json["movie"] is Map ? Content.fromJson(Map<String, dynamic>.from(json["movie"])) : null)),
    user: json["user"] == null ? null : (json["user"] is Map<String, dynamic> ? User.fromJson(json["user"]) : (json["user"] is Map ? User.fromJson(Map<String, dynamic>.from(json["user"])) : null)),
    status: json["status"]?.toString(),
    active: json["active"] is bool ? json["active"] : (json["active"] != null ? json["active"].toString().toLowerCase() == 'true' : null),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "contentPercentage": contentPercentage,
    "dateFrom": dateFrom,
    "dateTo": dateTo,
    "refferedBy": refferedBy,
    "price": price,
    "isGifted": isGifted,
    "userIdGiftFrom": userIdGiftFrom,
    "userIdGiftTo": userIdGiftTo,
    "movie": movie?.toJson(),
    "user": user?.toJson(),
    "status": status,
    "active": active,
  };
}

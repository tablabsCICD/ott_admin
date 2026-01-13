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
    id: json["id"],
    contentPercentage: json["contentPercentage"],
    dateFrom: json["dateFrom"],
    dateTo: json["dateTo"],
    refferedBy: json["refferedBy"],
    price: json["price"],
    isGifted: json["isGifted"],
    userIdGiftFrom: json["userIdGiftFrom"],
    userIdGiftTo: json["userIdGiftTo"],
    movie: json["movie"] == null ? null : Content.fromJson(json["movie"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    status: json["status"],
    active: json["active"],
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

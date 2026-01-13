import 'package:admin_ott/domain/entities/content.dart';

import '../../../domain/entities/user.dart';

class UserTransactionResponse {
  String? message;
  List<UserTransactionData>? data;
  int? statusCode;
  bool? success;

  UserTransactionResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory UserTransactionResponse.fromJson(Map<String, dynamic> json) => UserTransactionResponse(
    message: json["message"],
    data: json["data"] == null ? [] : List<UserTransactionData>.from(json["data"]!.map((x) => UserTransactionData.fromJson(x))),
    statusCode: json["statusCode"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "statusCode": statusCode,
    "success": success,
  };
}

class UserTransactionData {
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

  UserTransactionData({
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

  factory UserTransactionData.fromJson(Map<String, dynamic> json) => UserTransactionData(
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


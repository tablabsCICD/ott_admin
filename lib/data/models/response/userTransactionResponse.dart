import 'dart:convert';
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
  num? price;
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
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
    contentPercentage: json["contentPercentage"] is int ? json["contentPercentage"] : int.tryParse(json["contentPercentage"]?.toString() ?? ''),
    dateFrom: json["dateFrom"] is int ? json["dateFrom"] : int.tryParse(json["dateFrom"]?.toString() ?? ''),
    dateTo: json["dateTo"] is int ? json["dateTo"] : int.tryParse(json["dateTo"]?.toString() ?? ''),
    refferedBy: json["refferedBy"]?.toString(),
    price: json["price"] is num ? json["price"] : num.tryParse(json["price"]?.toString() ?? ''),
    isGifted: json["isGifted"] == true || json["isGifted"]?.toString().toLowerCase() == 'true',
    userIdGiftFrom: json["userIdGiftFrom"] is int ? json["userIdGiftFrom"] : int.tryParse(json["userIdGiftFrom"]?.toString() ?? ''),
    userIdGiftTo: json["userIdGiftTo"] is int ? json["userIdGiftTo"] : int.tryParse(json["userIdGiftTo"]?.toString() ?? ''),
    movie: _parseMovie(json["movie"] ?? json["Movie"] ?? json["content"] ?? json["Content"]),
    user: _parseUser(json["user"] ?? json["User"]),
    status: json["status"]?.toString(),
    active: json["active"] == true || json["active"]?.toString().toLowerCase() == 'true',
  );

  static Content? _parseMovie(dynamic value) {
    if (value == null) return null;
    if (value is Content) return value;
    if (value is Map<String, dynamic>) return Content.fromJson(value);
    if (value is Map) return Content.fromJson(Map<String, dynamic>.from(value));
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map) {
            return Content.fromJson(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      }
      return Content(title: trimmed);
    }
    return null;
  }

  static User? _parseUser(dynamic value) {
    if (value == null) return null;
    if (value is User) return value;
    if (value is Map<String, dynamic>) return User.fromJson(value);
    if (value is Map) return User.fromJson(Map<String, dynamic>.from(value));
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map) {
            return User.fromJson(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      }
      return User(firstName: trimmed);
    }
    return null;
  }

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


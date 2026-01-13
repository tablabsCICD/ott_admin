import 'package:admin_ott/domain/entities/user.dart';

class UsersByReferalCode {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  UsersByReferalCode({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory UsersByReferalCode.fromJson(Map<String, dynamic> json) => UsersByReferalCode(
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
  int? userCount;
  int? totalRevenueOfPromoter;
  int? totalViewRevenueEarned;
  List<User>? users;
  int? totalRevenueEarnedByUsers;

  Data({
    this.userCount,
    this.totalRevenueOfPromoter,
    this.totalViewRevenueEarned,
    this.users,
    this.totalRevenueEarnedByUsers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userCount: json["userCount"],
    totalRevenueOfPromoter: json["TotalRevenueOfPromoter"],
    totalViewRevenueEarned: json["totalViewRevenueEarned"],
    users: json["Users"] == null ? [] : List<User>.from(json["Users"]!.map((x) => User.fromJson(x))),
    totalRevenueEarnedByUsers: json["TotalRevenueEarnedByUsers"],
  );

  Map<String, dynamic> toJson() => {
    "userCount": userCount,
    "TotalRevenueOfPromoter": totalRevenueOfPromoter,
    "totalViewRevenueEarned": totalViewRevenueEarned,
    "Users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
    "TotalRevenueEarnedByUsers": totalRevenueEarnedByUsers,
  };
}

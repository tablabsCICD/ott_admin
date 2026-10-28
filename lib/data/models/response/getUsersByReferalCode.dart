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

  factory UsersByReferalCode.fromJson(Map<String, dynamic> json) {
    Data? parsedData;
    if (json["data"] != null) {
      if (json["data"] is Map<String, dynamic>) {
        parsedData = Data.fromJson(json["data"]);
      } else if (json["data"] is Map) {
        parsedData = Data.fromJson(Map<String, dynamic>.from(json["data"]));
      } else if (json["data"] is List) {
        parsedData = Data(
          userCount: (json["data"] as List).length,
          users: (json["data"] as List)
              .map((x) => User.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
              .toList(),
        );
      }
    }

    return UsersByReferalCode(
      message: json["message"],
      data: parsedData,
      statusCode: json["statusCode"] is int ? json["statusCode"] : int.tryParse(json["statusCode"]?.toString() ?? ''),
      success: json["success"] == true || json["status"]?.toString().toLowerCase() == 'success',
    );
  }

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

  factory Data.fromJson(Map<String, dynamic> json) {
    int? parseCount(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final rawList = json["Users"] ?? json["users"] ?? json["content"] ?? json["list"] ?? json["data"];
    List<User> userList = [];
    if (rawList is List) {
      userList = rawList
          .map((x) => User.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
          .toList();
    }

    return Data(
      userCount: parseCount(json["userCount"] ?? json["totalUsers"] ?? json["totalElements"] ?? json["total"] ?? json["count"]) ?? userList.length,
      totalRevenueOfPromoter: parseCount(json["TotalRevenueOfPromoter"] ?? json["totalRevenueOfPromoter"] ?? json["totalRevenue"] ?? json["revenue"]),
      totalViewRevenueEarned: parseCount(json["totalViewRevenueEarned"] ?? json["commissionEarned"] ?? json["earnedRevenue"]),
      users: userList,
      totalRevenueEarnedByUsers: parseCount(json["TotalRevenueEarnedByUsers"] ?? json["totalRevenueEarnedByUsers"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "userCount": userCount,
    "TotalRevenueOfPromoter": totalRevenueOfPromoter,
    "totalViewRevenueEarned": totalViewRevenueEarned,
    "Users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
    "TotalRevenueEarnedByUsers": totalRevenueEarnedByUsers,
  };
}

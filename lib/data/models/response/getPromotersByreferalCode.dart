import 'package:admin_ott/domain/entities/promoter.dart';

class PrometrsByReferalCode {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  PrometrsByReferalCode({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory PrometrsByReferalCode.fromJson(Map<String, dynamic> json) {
    Data? parsedData;
    if (json["data"] != null) {
      if (json["data"] is Map<String, dynamic>) {
        parsedData = Data.fromJson(json["data"]);
      } else if (json["data"] is Map) {
        parsedData = Data.fromJson(Map<String, dynamic>.from(json["data"]));
      } else if (json["data"] is List) {
        parsedData = Data(
          totalPromoterUnderPromoter: (json["data"] as List).length,
          promoter: (json["data"] as List)
              .map((x) => Promoters.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
              .toList(),
        );
      }
    }

    return PrometrsByReferalCode(
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
  List<Promoters>? promoter;
  int? totalRevenueOfPromoter;
  int? totalViewRevenueEarned;
  int? totalPromoterUnderPromoter;
  int? totalRevenueEarnedByUsers;

  Data({
    this.promoter,
    this.totalRevenueOfPromoter,
    this.totalViewRevenueEarned,
    this.totalPromoterUnderPromoter,
    this.totalRevenueEarnedByUsers,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    int? parseCount(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final rawList = json["Promoter"] ?? json["promoter"] ?? json["promoters"] ?? json["childPromoters"] ?? json["content"] ?? json["list"] ?? json["data"];
    List<Promoters> promoterList = [];
    if (rawList is List) {
      promoterList = rawList
          .map((x) => Promoters.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
          .toList();
    }

    return Data(
      promoter: promoterList,
      totalRevenueOfPromoter: parseCount(json["TotalRevenueOfPromoter"] ?? json["totalRevenueOfPromoter"] ?? json["totalRevenue"] ?? json["revenue"]),
      totalViewRevenueEarned: parseCount(json["totalViewRevenueEarned"] ?? json["commissionEarned"] ?? json["earnedRevenue"]),
      totalPromoterUnderPromoter: parseCount(json["TotalPromoterUnderPromoter"] ?? json["totalPromoterUnderPromoter"] ?? json["totalChildPromoters"] ?? json["totalElements"] ?? json["total"] ?? json["count"]) ?? promoterList.length,
      totalRevenueEarnedByUsers: parseCount(json["TotalRevenueEarnedByUsers"] ?? json["totalRevenueEarnedByUsers"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "Promoter": promoter == null ? [] : List<dynamic>.from(promoter!.map((x) => x.toJson())),
    "TotalRevenueOfPromoter": totalRevenueOfPromoter,
    "totalViewRevenueEarned": totalViewRevenueEarned,
    "TotalPromoterUnderPromoter": totalPromoterUnderPromoter,
    "TotalRevenueEarnedByUsers": totalRevenueEarnedByUsers,
  };
}
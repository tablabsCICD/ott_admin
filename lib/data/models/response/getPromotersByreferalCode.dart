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

  factory PrometrsByReferalCode.fromJson(Map<String, dynamic> json) => PrometrsByReferalCode(
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    promoter: json["Promoter"]  == null ? [] : List<Promoters>.from(json["Promoter"]!.map((x) => Promoters.fromJson(x))),
    totalRevenueOfPromoter: json["TotalRevenueOfPromoter"],
    totalViewRevenueEarned: json["totalViewRevenueEarned"],
    totalPromoterUnderPromoter: json["TotalPromoterUnderPromoter"],
    totalRevenueEarnedByUsers: json["TotalRevenueEarnedByUsers"],
  );

  Map<String, dynamic> toJson() => {
    "Promoter": promoter == null ? [] : List<dynamic>.from(promoter!.map((x) => x.toJson())),
    "TotalRevenueOfPromoter": totalRevenueOfPromoter,
    "totalViewRevenueEarned": totalViewRevenueEarned,
    "TotalPromoterUnderPromoter": totalPromoterUnderPromoter,
    "TotalRevenueEarnedByUsers": totalRevenueEarnedByUsers,
  };
}
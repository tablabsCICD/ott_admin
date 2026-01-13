class PromoterRevenueGraphResponse {
  String? message;
  List<PromoterRevenueList>? data;
  int? statusCode;
  bool? success;

  PromoterRevenueGraphResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory PromoterRevenueGraphResponse.fromJson(Map<String, dynamic> json) => PromoterRevenueGraphResponse(
    message: json["message"],
    data: json["data"] == null ? [] : List<PromoterRevenueList>.from(json["data"]!.map((x) => PromoterRevenueList.fromJson(x))),
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

class PromoterRevenueList {
  String? date;
  double? nationalRevenue;
  double? stateRevenue;
  double? districtRevenue;
  double? talukaRevenue;

  PromoterRevenueList({
    this.date,
    this.nationalRevenue,
    this.stateRevenue,
    this.districtRevenue,
    this.talukaRevenue,
  });

  factory PromoterRevenueList.fromJson(Map<String, dynamic> json) => PromoterRevenueList(
    date: json["date"],
    nationalRevenue: json["National Revenue"],
    stateRevenue: json["State Revenue"],
    districtRevenue: json["District Revenue"],
    talukaRevenue: json["Taluka Revenue"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "National Revenue": nationalRevenue,
    "State Revenue": stateRevenue,
    "District Revenue": districtRevenue,
    "Taluka Revenue": talukaRevenue,
  };
}

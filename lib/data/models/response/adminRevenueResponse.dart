class AdminRevenueChartResponse {
  String? message;
  List<AllAdminRevenue>? data;
  int? statusCode;
  bool? success;
  String? total;

  AdminRevenueChartResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
    this.total
  });

  factory AdminRevenueChartResponse.fromJson(Map<String, dynamic> json) => AdminRevenueChartResponse(
    message: json["message"],
    data: json["data"] == null ? [] : List<AllAdminRevenue>.from(json["data"]!.map((x) => AllAdminRevenue.fromJson(x))),
    statusCode: json["statusCode"],
    success: json["success"],
    total: json["total"]
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "statusCode": statusCode,
    "success": success,
    "total": total
  };
}

class AllAdminRevenue {
  String? date;
  double? adminRevenue;
  double? promoterRevenue;
  double? mediaHouseRevenue;

  AllAdminRevenue({
    this.date,
    this.adminRevenue,
    this.promoterRevenue,
    this.mediaHouseRevenue,
  });

  factory AllAdminRevenue.fromJson(Map<String, dynamic> json) => AllAdminRevenue(
    date: json["date"] ,
    adminRevenue: json["adminRevenue"],
    promoterRevenue: json["promoterRevenue"],
    mediaHouseRevenue: json["mediaHouseRevenue"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "adminRevenue": adminRevenue,
    "promoterRevenue": promoterRevenue,
    "mediaHouseRevenue": mediaHouseRevenue,
  };
}

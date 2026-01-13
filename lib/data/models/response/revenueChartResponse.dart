class RevenueChartResponse {
  String? message;
  RevenueChartObject? data;
  int? statusCode;
  bool? success;

  RevenueChartResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory RevenueChartResponse.fromJson(Map<String, dynamic> json) => RevenueChartResponse(
    message: json["message"],
    data: json["data"] == null ? null : RevenueChartObject.fromJson(json["data"]),
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

class RevenueChartObject {
  int? promoter;
  int? mediaHouse;
  int? admin;

  RevenueChartObject({
    this.promoter,
    this.mediaHouse,
    this.admin,
  });

  factory RevenueChartObject.fromJson(Map<String, dynamic> json) => RevenueChartObject(
    promoter: json["Promoter"],
    mediaHouse: json["Media House"],
    admin: json["Admin"],
  );

  Map<String, dynamic> toJson() => {
    "Promoter": promoter,
    "Media House": mediaHouse,
    "Admin": admin,
  };
}

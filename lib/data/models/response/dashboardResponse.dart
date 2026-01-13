class DashbordResponse {
  DashboardData? data;
  String? message;
  int? statusCode;
  bool? isSuccess;

  DashbordResponse({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  factory DashbordResponse.fromJson(Map<String, dynamic> json) => DashbordResponse(
    data: json["data"] == null ? null : DashboardData.fromJson(json["data"]),
    message: json["message"],
    statusCode: json["statusCode"],
    isSuccess: json["isSuccess"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "message": message,
    "statusCode": statusCode,
    "isSuccess": isSuccess,
  };
}

class DashboardData {
  int? totalUserCount;
  int? userContent;
  int? totalContent;
  int? totalMediaHouses;
  int? totalPromoter;

  DashboardData({
    this.totalUserCount,
    this.userContent,
    this.totalContent,
    this.totalMediaHouses,
    this.totalPromoter,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    totalUserCount: json["totalUserCount"],
    userContent: json["userContent"],
    totalContent: json["totalApprovedContent"],
    totalMediaHouses: json["totalMediaHouses"],
    totalPromoter: json["totalPromoter"],
  );

  Map<String, dynamic> toJson() => {
    "totalUserCount": totalUserCount,
    "userContent": userContent,
    "totalContent": totalContent,
    "totalMediaHouses": totalMediaHouses,
    "totalPromoter": totalPromoter,
  };
}

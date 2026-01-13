class MediaHouseDashboardCount {
  MediaHouseDashboardData? data;
  String? message;
  int? statusCode;
  bool? isSuccess;

  MediaHouseDashboardCount({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  factory MediaHouseDashboardCount.fromJson(Map<String, dynamic> json) => MediaHouseDashboardCount(
    data: json["data"] == null ? null : MediaHouseDashboardData.fromJson(json["data"]),
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

class MediaHouseDashboardData {
  int? approvedContent;
  int? upcomingContentCount;
  int? totalViews;
  double? viewRevenue;
  int? pendingContentCount;
  int? rejectedContentCount;

  MediaHouseDashboardData({
    this.approvedContent,
    this.upcomingContentCount,
    this.totalViews,
    this.viewRevenue,
    this.pendingContentCount,
    this.rejectedContentCount,
  });

  factory MediaHouseDashboardData.fromJson(Map<String, dynamic> json) => MediaHouseDashboardData(
    approvedContent: json["Approved Content"]??0,
    upcomingContentCount: json["Upcoming Content Count"]??0,
    totalViews: json["totalViews"]??0,
    viewRevenue: json["viewRevenue"]??0.0,
    pendingContentCount: json["Pending Content Count"]??0,
    rejectedContentCount: json["Rejected Content Count"]??0,
  );

  Map<String, dynamic> toJson() => {
    "Approved Content": approvedContent,
    "Upcoming Content Count": upcomingContentCount,
    "totalViews": totalViews,
    "viewRevenue": viewRevenue,
    "Pending Content Count": pendingContentCount,
    "Rejected Content Count": rejectedContentCount,
  };
}

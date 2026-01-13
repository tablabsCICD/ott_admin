class ReportAndDataResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  ReportAndDataResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory ReportAndDataResponse.fromJson(Map<String, dynamic> json) => ReportAndDataResponse(
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
  List<ReportAndDataObject>? mediaHouse;

  Data({
    this.mediaHouse,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    mediaHouse: json["MediaHouse"] == null ? [] : List<ReportAndDataObject>.from(json["MediaHouse"]!.map((x) => ReportAndDataObject.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "MediaHouse": mediaHouse == null ? [] : List<dynamic>.from(mediaHouse!.map((x) => x.toJson())),
  };
}

class ReportAndDataObject {
  int? contentId;
  String? contentName;
  String? contentStatus;
  dynamic releasedDate;
  int? totalViews;
  dynamic totalRevenue;
  int? currentPecentageIncentive;
  int? earnedIncentive;

  ReportAndDataObject({
    this.contentId,
    this.contentName,
    this.contentStatus,
    this.releasedDate,
    this.totalViews,
    this.totalRevenue,
    this.currentPecentageIncentive,
    this.earnedIncentive,
  });

  factory ReportAndDataObject.fromJson(Map<String, dynamic> json) => ReportAndDataObject(
    contentId: json["contentId"],
    contentName: json["contentName"],
    contentStatus: json["contentStatus"],
    releasedDate: json["releasedDate"],
    totalViews: json["totalViews"],
    totalRevenue: json["totalRevenue"],
    currentPecentageIncentive: json["currentPecentageIncentive"],
    earnedIncentive: json["earnedIncentive"],
  );

  Map<String, dynamic> toJson() => {
    "contentId": contentId,
    "contentName": contentName,
    "contentStatus": contentStatus,
    "releasedDate": releasedDate,
    "totalViews": totalViews,
    "totalRevenue": totalRevenue,
    "currentPecentageIncentive": currentPecentageIncentive,
    "earnedIncentive": earnedIncentive,
  };
}

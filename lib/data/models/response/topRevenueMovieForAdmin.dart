class TopRevenueMovieForAdmin {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  TopRevenueMovieForAdmin({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory TopRevenueMovieForAdmin.fromJson(Map<String, dynamic> json) => TopRevenueMovieForAdmin(
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
  List<ContentWithRevenue>? contentWithRevenue;

  Data({
    this.contentWithRevenue,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    contentWithRevenue: json["contentWithRatings"] == null ? [] : List<ContentWithRevenue>.from(json["contentWithRatings"]!.map((x) => ContentWithRevenue.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "contentWithRatings": contentWithRevenue == null ? [] : List<dynamic>.from(contentWithRevenue!.map((x) => x.toJson())),
  };
}

class ContentWithRevenue {
  double? totalRevenue;
  String? name;

  ContentWithRevenue({
    this.totalRevenue,
    this.name,
  });

  factory ContentWithRevenue.fromJson(Map<String, dynamic> json) => ContentWithRevenue(
    totalRevenue: json["totalRevenue"]??0.0,
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "totalRevenue": totalRevenue,
    "Name": name,
  };
}

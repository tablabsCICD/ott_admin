class TopRevenueMovie {
  String? message;
  Data? data;
  int? statusCode;
  String? total;
  String? totalViews;
  String? totalLikes;
  String? totalRevenue;
  bool? success;

  TopRevenueMovie({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
    this.success,
  });

  factory TopRevenueMovie.fromJson(dynamic json) {
    if (json == null) return TopRevenueMovie();
    if (json is List) {
      return TopRevenueMovie(
        success: true,
        statusCode: 200,
        data: Data.fromJson(json),
      );
    }
    if (json is! Map) return TopRevenueMovie();

    return TopRevenueMovie(
      message: json["message"]?.toString(),
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      statusCode: json["statusCode"] is num
          ? (json["statusCode"] as num).toInt()
          : int.tryParse(json["statusCode"]?.toString() ?? ''),
      total: json["total"]?.toString(),
      totalViews: json["totalViews"]?.toString(),
      totalLikes: json["totalLikes"]?.toString(),
      totalRevenue: json["totalRevenue"]?.toString(),
      success: json["success"] == true ||
          json["success"] == "true" ||
          json["statusCode"] == 200 ||
          json["message"] == "Data fetched successfully",
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "total": total,
        "totalViews": totalViews,
        "totalLikes": totalLikes,
        "totalRevenue": totalRevenue,
        "success": success,
      };
}

class Data {
  List<ContentWithRevenue>? contentWithRevenue;

  Data({
    this.contentWithRevenue,
  });

  factory Data.fromJson(dynamic json) {
    if (json == null) return Data(contentWithRevenue: []);
    if (json is List) {
      return Data(
        contentWithRevenue: List<ContentWithRevenue>.from(
          json.map((x) => ContentWithRevenue.fromJson(
              x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x as Map))),
        ),
      );
    }
    if (json is Map) {
      final list = json["contentWithRevenue"] ??
          json["content"] ??
          json["list"] ??
          json["data"] ??
          json["movies"];
      if (list is List) {
        return Data(
          contentWithRevenue: List<ContentWithRevenue>.from(
            list.map((x) => ContentWithRevenue.fromJson(
                x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x as Map))),
          ),
        );
      }
    }
    return Data(contentWithRevenue: []);
  }

  Map<String, dynamic> toJson() => {
        "contentWithRevenue": contentWithRevenue == null
            ? []
            : List<dynamic>.from(contentWithRevenue!.map((x) => x.toJson())),
      };
}

class ContentWithRevenue {
  double? totalRevenue;
  double? mediaHouseNetRevenue;
  double? mediaHouseGrossRevenue;
  String? name;

  ContentWithRevenue({
    this.totalRevenue,
    this.mediaHouseNetRevenue,
    this.mediaHouseGrossRevenue,
    this.name,
  });

  factory ContentWithRevenue.fromJson(Map<String, dynamic> json) =>
      ContentWithRevenue(
        totalRevenue: _toDouble(json["totalRevenue"] ?? json["total"] ?? json["value"]),
        mediaHouseNetRevenue: _toDouble(json["mediaHouseNetRevenue"] ??
            json["netRevenue"] ??
            json["totalRevenue"]),
        mediaHouseGrossRevenue: _toDouble(json["mediaHouseGrossRevenue"] ??
            json["grossRevenue"] ??
            json["customerPayment"] ??
            json["totalRevenue"]),
        name: json["Name"]?.toString() ??
            json["name"]?.toString() ??
            json["title"]?.toString() ??
            json["Title"]?.toString() ??
            json["movieName"]?.toString() ??
            json["label"]?.toString() ??
            'Content',
      );

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
        "totalRevenue": totalRevenue,
        "mediaHouseNetRevenue": mediaHouseNetRevenue,
        "mediaHouseGrossRevenue": mediaHouseGrossRevenue,
        "Name": name,
      };
}


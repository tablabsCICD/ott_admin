class ChartResponse {
  String? message;
  ChartResponseData? data;
  int? statusCode;
  bool? success;

  ChartResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory ChartResponse.fromJson(Map<String, dynamic> json) => ChartResponse(
    message: json["message"],
    data: json["data"] == null ? null : ChartResponseData.fromJson(json["data"]),
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

class ChartResponseData {
  DataData? data;
  bool? success;
  String? message;
  int? statusCode;

  ChartResponseData({
    this.data,
    this.success,
    this.message,
    this.statusCode,
  });

  factory ChartResponseData.fromJson(Map<String, dynamic> json) => ChartResponseData(
    data: json["data"] == null ? null : DataData.fromJson(json["data"]),
    success: json["success"],
    message: json["message"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "success": success,
    "message": message,
    "statusCode": statusCode,
  };
}

class DataData {
  Map<String, int>? data;
  bool? success;
  String? message;
  int? statusCode;

  DataData({
    this.data,
    this.success,
    this.message,
    this.statusCode,
  });

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
    data: Map.from(json["data"]!).map((k, v) => MapEntry<String, int>(k, v)),
    success: json["success"],
    message: json["message"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "data": Map.from(data!).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "success": success,
    "message": message,
    "statusCode": statusCode,
  };
}

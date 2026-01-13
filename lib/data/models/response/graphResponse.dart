class GraphResponse {
  String? message;
  List<GraphData>? data;
  int? statusCode;
  bool? success;
  String? total;

  GraphResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
    this.total
  });

  factory GraphResponse.fromJson(Map<String, dynamic> json) => GraphResponse(
    message: json["message"],
    data: json["data"] == null ? [] : List<GraphData>.from(json["data"]!.map((x) => GraphData.fromJson(x))),
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

class GraphData {
  String? label;
  int? value;

  GraphData({
    this.label,
    this.value,
  });

  factory GraphData.fromJson(Map<String, dynamic> json) => GraphData(
    label: json["label"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "value": value,
  };
}

class ChartResponse {
  String? message;
  List<Datum>? data;
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
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
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

class Datum {
  String? label;
  int? value;

  Datum({
    this.label,
    this.value,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    label: json["label"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "value": value,
  };
}

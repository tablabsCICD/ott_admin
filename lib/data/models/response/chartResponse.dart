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
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        statusCode: json["statusCode"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "statusCode": statusCode,
        "success": success,
      };
}

class Datum {
  String? label;
  double? value;

  Datum({
    this.label,
    this.value,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        label: json["label"],
        value: _parseToDouble(json["value"]),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "value": value,
      };

  static double _parseToDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    return 0.0;
  }
}

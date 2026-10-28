
class ReportingPromotersResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  ReportingPromotersResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory ReportingPromotersResponse.fromJson(Map<String, dynamic> json) => ReportingPromotersResponse(
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
  List<PromotersList>? promotersList;

  Data({
    this.promotersList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    promotersList: json["PromotersList"] == null ? [] : List<PromotersList>.from(json["PromotersList"]!.map((x) => PromotersList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "PromotersList": promotersList == null ? [] : List<dynamic>.from(promotersList!.map((x) => x.toJson())),
  };
}

class PromotersList {
  int? id;
  String? promoterName;
  String? level;

  PromotersList({
    this.id,
    this.promoterName,
    this.level,
  });

  factory PromotersList.fromJson(Map<String, dynamic> json) => PromotersList(
    id: json["id"],
    promoterName: json["promoterName"],
    level: json["level"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "promoterName": promoterName,
    "level": level,
  };
}

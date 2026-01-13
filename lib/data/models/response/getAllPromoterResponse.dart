import '../../../domain/entities/promoter.dart';

class GetAllPromoterResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAllPromoterResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory GetAllPromoterResponse.fromJson(Map<String, dynamic> json) => GetAllPromoterResponse(
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
  List<Promoters>? promoters;

  Data({
    this.promoters,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    promoters: json["Promoters"] == null ? [] : List<Promoters>.from(json["Promoters"]!.map((x) => Promoters.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Promoters": promoters == null ? [] : List<dynamic>.from(promoters!.map((x) => x.toJson())),
  };
}
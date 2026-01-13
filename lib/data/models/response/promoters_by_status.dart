import 'package:admin_ott/domain/entities/promoter.dart';

class PromotersByStatus {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  PromotersByStatus({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory PromotersByStatus.fromJson(Map<String, dynamic> json) => PromotersByStatus(
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
  List<Promoters>? cast;

  Data({
    this.cast,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    cast: json["cast"] == null ? [] : List<Promoters>.from(json["cast"]!.map((x) => Promoters.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cast": cast == null ? [] : List<dynamic>.from(cast!.map((x) => x.toJson())),
  };
}

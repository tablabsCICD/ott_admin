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

  factory Data.fromJson(Map<String, dynamic> json) {
    // This endpoint has returned both the original `Promoters` array and a
    // Spring-page response (`promoters.content`) in different deployments.
    // Accept both spellings/shapes so a backend pagination change does not
    // silently turn a valid response into an empty Manage Promoters list.
    dynamic rawPromoters = json["Promoters"] ?? json["promoters"];
    if (rawPromoters is Map<String, dynamic>) {
      rawPromoters = rawPromoters["content"] ??
          rawPromoters["Promoters"] ??
          rawPromoters["promoters"];
    }

    final promoterList = rawPromoters is List
        ? rawPromoters
            .whereType<Map>()
            .map((item) => Promoters.fromJson(
                Map<String, dynamic>.from(item)))
            .toList()
        : <Promoters>[];

    return Data(promoters: promoterList);
  }

  Map<String, dynamic> toJson() => {
    "Promoters": promoters == null ? [] : List<dynamic>.from(promoters!.map((x) => x.toJson())),
  };
}

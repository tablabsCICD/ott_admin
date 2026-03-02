class ImageUploadResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  ImageUploadResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) => ImageUploadResponse(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    statusCode: json["statusCode"],
    total: json["total"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "total": total,
    "success": success,
  };
}

class Data {
  String? fileUrl;

  Data({
    this.fileUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    fileUrl: json["fileUrl"],
  );

  Map<String, dynamic> toJson() => {
    "fileUrl": fileUrl,
  };
}

class VideoUploadResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  VideoUploadResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory VideoUploadResponse.fromJson(Map<String, dynamic> json) => VideoUploadResponse(
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
  String? videoUrl;
  String? videoId;
  String? status;

  Data({
    this.videoUrl,
    this.videoId,
    this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    videoUrl: json["videoUrl"],
    videoId: json["videoId"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "videoUrl": videoUrl,
    "videoId": videoId,
    "status": status,
  };
}

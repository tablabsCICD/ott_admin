import '../../../domain/entities/content.dart';

class AddVideoResponse {
  Content? data;
  String? message;
  int? statusCode;
  bool? isSuccess;

  AddVideoResponse({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  factory AddVideoResponse.fromJson(Map<String, dynamic> json) {
    Content? contentData;
    if (json["data"] != null && json["data"] is Map<String, dynamic>) {
      contentData = Content.fromJson(json["data"]);
    } else if (json["content"] != null && json["content"] is Map<String, dynamic>) {
      contentData = Content.fromJson(json["content"]);
    } else if (json["id"] != null) {
      contentData = Content.fromJson(json);
    }

    final bool success = json["isSuccess"] == true ||
        json["success"] == true ||
        json["status"] == "SUCCESS" ||
        (json["statusCode"] != null && (json["statusCode"] == 200 || json["statusCode"] == 201)) ||
        contentData != null;

    return AddVideoResponse(
      data: contentData,
      message: json["message"] ?? json["msg"] ?? json["error"],
      statusCode: json["statusCode"] is int
          ? json["statusCode"]
          : int.tryParse(json["statusCode"]?.toString() ?? ''),
      isSuccess: success,
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "message": message,
    "statusCode": statusCode,
    "isSuccess": isSuccess,
  };
}





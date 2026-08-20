import 'package:admin_ott/domain/entities/content.dart';

class GetAllVideoResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAllVideoResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory GetAllVideoResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"] ?? json["Data"];
    Data? parsedData;
    if (rawData is Map<String, dynamic>) {
      parsedData = Data.fromJson(rawData);
    } else if (rawData is Map) {
      parsedData = Data.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List) {
      parsedData = Data(
        contentList: rawData
            .map((x) => x is Map<String, dynamic>
                ? Content.fromJson(x)
                : x is Map
                    ? Content.fromJson(Map<String, dynamic>.from(x))
                    : null)
            .whereType<Content>()
            .toList(),
      );
    } else if (json.containsKey("ContentList") || json.containsKey("contentList")) {
      parsedData = Data.fromJson(json);
    }

    final rawSuccess = json["success"] ?? json["Success"] ?? json["status"] ?? json["Status"];
    final bool isSuccess = rawSuccess == true ||
        rawSuccess?.toString().toLowerCase() == "true" ||
        rawSuccess?.toString().toLowerCase() == "success";

    final rawStatusCode = json["statusCode"] ?? json["StatusCode"] ?? json["code"] ?? json["status"];

    return GetAllVideoResponse(
      message: json["message"]?.toString() ?? json["Message"]?.toString() ?? json["msg"]?.toString(),
      data: parsedData,
      statusCode: rawStatusCode is int
          ? rawStatusCode
          : int.tryParse(rawStatusCode?.toString() ?? ''),
      success: isSuccess,
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "success": success,
  };
}

class Data {
  List<Content>? contentList;

  Data({
    this.contentList,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final rawList = json["ContentList"] ??
        json["contentList"] ??
        json["contents"] ??
        json["Contents"] ??
        json["content"] ??
        json["data"] ??
        json["videos"] ??
        json["Videos"] ??
        json["items"] ??
        json["Items"] ??
        json["list"] ??
        json["List"];

    return Data(
      contentList: rawList is List
          ? rawList
              .map((x) => x is Map<String, dynamic>
                  ? Content.fromJson(x)
                  : x is Map
                      ? Content.fromJson(Map<String, dynamic>.from(x))
                      : null)
              .whereType<Content>()
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "ContentList": contentList == null ? [] : List<dynamic>.from(contentList!.map((x) => x.toJson())),
  };
}
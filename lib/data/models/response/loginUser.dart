import '../../../domain/entities/user.dart';

class LoginUserResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  dynamic totalViews;
  dynamic totalLikes;
  dynamic totalRevenue;
  bool? success;

  LoginUserResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
    this.success,
  });

  factory LoginUserResponse.fromJson(Map<String, dynamic> json) =>
      LoginUserResponse(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        statusCode: json["statusCode"],
        total: json["total"],
        totalViews: json["totalViews"],
        totalLikes: json["totalLikes"],
        totalRevenue: json["totalRevenue"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "total": total,
        "totalViews": totalViews,
        "totalLikes": totalLikes,
        "totalRevenue": totalRevenue,
        "success": success,
      };
}

class Data {
  String? sessionId;
  String? tokenType;
  ActiveDevice? activeDevice;
  User? user;
  String? jwt;
  String? token;

  Data({
    this.sessionId,
    this.tokenType,
    this.activeDevice,
    this.user,
    this.jwt,
    this.token,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        sessionId: json["sessionId"],
        tokenType: json["tokenType"],
        activeDevice: json["activeDevice"] == null
            ? null
            : ActiveDevice.fromJson(json["activeDevice"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        jwt: json["jwt"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "sessionId": sessionId,
        "tokenType": tokenType,
        "activeDevice": activeDevice?.toJson(),
        "user": user?.toJson(),
        "jwt": jwt,
        "token": token,
      };
}

class ActiveDevice {
  int? id;
  String? deviceId;
  String? deviceName;
  String? deviceType;
  String? sessionId;
  List<int>? loginTime;
  List<int>? lastAccessTime;
  String? appVersion;

  ActiveDevice({
    this.id,
    this.deviceId,
    this.deviceName,
    this.deviceType,
    this.sessionId,
    this.loginTime,
    this.lastAccessTime,
    this.appVersion,
  });

  factory ActiveDevice.fromJson(Map<String, dynamic> json) => ActiveDevice(
        id: json["id"],
        deviceId: json["deviceId"],
        deviceName: json["deviceName"],
        deviceType: json["deviceType"],
        sessionId: json["sessionId"],
        loginTime: json["loginTime"] == null
            ? null
            : List<int>.from(json["loginTime"].map((x) => x)),
        lastAccessTime: json["lastAccessTime"] == null
            ? null
            : List<int>.from(json["lastAccessTime"].map((x) => x)),
        appVersion: json["appVersion"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "deviceId": deviceId,
        "deviceName": deviceName,
        "deviceType": deviceType,
        "sessionId": sessionId,
        "loginTime": loginTime == null
            ? null
            : List<dynamic>.from(loginTime!.map((x) => x)),
        "lastAccessTime": lastAccessTime == null
            ? null
            : List<dynamic>.from(lastAccessTime!.map((x) => x)),
        "appVersion": appVersion,
      };
}

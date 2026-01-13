import '../../../domain/entities/user.dart';

class GetAllUserResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAllUserResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory GetAllUserResponse.fromJson(Map<String, dynamic> json) => GetAllUserResponse(
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
  List<User>? users;

  Data({
    this.users,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    users: json["users"] == null ? [] : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
  };
}
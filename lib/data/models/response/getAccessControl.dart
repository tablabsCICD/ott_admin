class GetAccessControlResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAccessControlResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory GetAccessControlResponse.fromJson(Map<String, dynamic> json) => GetAccessControlResponse(
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
  List<AccessControlList>? accessControlList;

  Data({
    this.accessControlList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accessControlList: json["accessControlList"] == null ? [] : List<AccessControlList>.from(json["accessControlList"]!.map((x) => AccessControlList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "accessControlList": accessControlList == null ? [] : List<dynamic>.from(accessControlList!.map((x) => x.toJson())),
  };
}

class AccessControlList {
  int? id;
  String? promoterLevel;
  bool? manageUser;
  bool? manageMediaHouse;
  bool? manageContent;
  bool? manageTrasaction;
  bool? helpDesk;

  AccessControlList({
    this.id,
    this.promoterLevel,
    this.manageUser,
    this.manageMediaHouse,
    this.manageContent,
    this.manageTrasaction,
    this.helpDesk,
  });

  factory AccessControlList.fromJson(Map<String, dynamic> json) => AccessControlList(
    id: json["id"],
    promoterLevel: json["promoterLevel"],
    manageUser: json["manageUser"],
    manageMediaHouse: json["manageMediaHouse"],
    manageContent: json["manageContent"],
    manageTrasaction: json["manageTrasaction"],
    helpDesk: json["helpDesk"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "promoterLevel": promoterLevel,
    "manageUser": manageUser,
    "manageMediaHouse": manageMediaHouse,
    "manageContent": manageContent,
    "manageTrasaction": manageTrasaction,
    "helpDesk": helpDesk,
  };
}

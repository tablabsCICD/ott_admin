import 'package:admin_ott/domain/entities/user.dart';

import 'location.dart';

class Promoters {
  int? id;
  String? promoterName;
  String? level;
  Location? location;
  User? userId;
  String? role;
  String? status;
  String? access;
  String? createdDate;
  dynamic promoterId;
  bool? active;

  Promoters({
    this.id,
    this.promoterName,
    this.level,
    this.location,
    this.userId,
    this.role,
    this.status,
    this.access,
    this.createdDate,
    this.promoterId,
    this.active,
  });

  factory Promoters.fromJson(Map<String, dynamic> json) => Promoters(
    id: json["id"],
    promoterName: json["promoterName"],
    level: json["level"],
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    userId: json["userId"] == null ? null : User.fromJson(json["userId"]),
    role: json["role"],
    status: json["status"],
    access: json["access"],
    createdDate: json["createdDate"],
    promoterId: json["promoterId"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "promoterName": promoterName,
    "level": level,
    "location": location?.toJson(),
    "userId": userId?.toJson(),
    "role": role,
    "status": status,
    "access": access,
    "createdDate": createdDate,
    "promoterId": promoterId,
    "active": active,
  };
}

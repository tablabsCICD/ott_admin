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
  String? aadharCard;
  String? accountNumber;
  String? bankName;
  String? branchName;
  String? contactNumber;
  String? gst;
  String? ifscCode;
  String? panCard;
  String? pincode;
  String? refferedBy;
  String? registrationCertificate;
  String? website;

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
    this.aadharCard,
    this.accountNumber,
    this.bankName,
    this.branchName,
    this.contactNumber,
    this.gst,
    this.ifscCode,
    this.panCard,
    this.pincode,
    this.refferedBy,
    this.registrationCertificate,
    this.website,
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
    aadharCard: json["aadharCard"],
    accountNumber: json["accountNumber"],
    bankName: json["bankName"],
    branchName: json["branchName"],
    contactNumber: json["contactNumber"],
    gst: json["gst"],
    ifscCode: json["ifscCode"],
    panCard: json["panCard"],
    pincode: json["pincode"],
    refferedBy: json["refferedBy"],
    registrationCertificate: json["registrationCertificate"],
    website: json["website"],
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
    "aadharCard": aadharCard,
    "accountNumber": accountNumber,
    "bankName": bankName,
    "branchName": branchName,
    "contactNumber": contactNumber,
    "gst": gst,
    "ifscCode": ifscCode,
    "panCard": panCard,
    "pincode": pincode,
    "refferedBy": refferedBy,
    "registrationCertificate": registrationCertificate,
    "website": website,
  };
}

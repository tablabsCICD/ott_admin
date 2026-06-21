import 'package:admin_ott/domain/entities/location.dart';
import 'package:admin_ott/domain/entities/user.dart';

class MediaHouse {
  int? id;
  String? mediaHouseName;
  String? address;
  String? contactNumber;
  String? email;
  String? registrationCertificate;
  String? gstCertificates;
  String? adharCard;
  dynamic shopAct;
  String? panCard;
  int? createdDate;
  dynamic updatedDate;
  dynamic profileImage;
  dynamic otp;
  String? password;
  String? status;
  dynamic joinDate;
  dynamic logo;
  String? totalReveneu;
  String? postCount;
  dynamic discription;
  String? bankAccountNumber;
  String? bankIfscNumber;
  String? bankProof;
  String? identityProof;
  String? addressProof;
  dynamic bankName;
  dynamic accountHolderName;
  dynamic firmType;
  String? designation;
  User? user;
  int? directorId;
  int? ceoId;
  Location? location;
  String? totalViews;
  String? mediaHouseRevenue;
  String? totalRevenue;
  bool? active;
  String? adminRevnue;

  String? get displayTotalRevenue => totalRevenue ?? totalReveneu;

  MediaHouse({
    this.id,
    this.mediaHouseName,
    this.address,
    this.contactNumber,
    this.email,
    this.registrationCertificate,
    this.gstCertificates,
    this.adharCard,
    this.shopAct,
    this.panCard,
    this.createdDate,
    this.updatedDate,
    this.profileImage,
    this.otp,
    this.password,
    this.status,
    this.joinDate,
    this.logo,
    this.totalReveneu,
    this.postCount,
    this.discription,
    this.bankAccountNumber,
    this.bankIfscNumber,
    this.bankProof,
    this.identityProof,
    this.addressProof,
    this.bankName,
    this.accountHolderName,
    this.firmType,
    this.designation,
    this.user,
    this.directorId,
    this.ceoId,
    this.location,
    this.totalViews,
    this.mediaHouseRevenue,
    this.totalRevenue,
    this.active,
    this.adminRevnue,
  });

  factory MediaHouse.fromJson(Map<String, dynamic> json) => MediaHouse(
        id: json["id"],
        mediaHouseName: json["mediaHouseName"],
        address: json["address"],
        contactNumber: json["contactNumber"],
        email: json["email"],
        registrationCertificate: json["registrationCertificate"],
        gstCertificates: json["gstCertificates"],
        adharCard: json["adharCard"],
        shopAct: json["shopAct"],
        panCard: json["panCard"],
        createdDate: json["createdDate"],
        updatedDate: json["updatedDate"],
        profileImage: json["profileImage"],
        otp: json["otp"],
        password: json["password"],
        status: json["status"],
        joinDate: json["joinDate"],
        logo: json["logo"],
        totalReveneu: _readString(json["totalReveneu"]),
        postCount: json["postCount"],
        discription: json["discription"],
        bankAccountNumber: json["bankAccountNumber"],
        bankIfscNumber: json["bankIFSCNumber"],
        bankProof: json["bankProof"],
        identityProof: json["identityProof"],
        addressProof: json["addressProof"],
        bankName: json["bankName"],
        accountHolderName: json["accountHolderName"],
        firmType: json["firmType"],
        designation: json["designation"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        directorId: json["directorId"],
        ceoId: json["ceoId"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        totalViews: _readString(json["totalViews"]),
        mediaHouseRevenue: _readString(
          json["mediaHouseRevenue"] ?? json["productionHouseRevenue"],
        ),
        totalRevenue: _readString(json["totalRevenue"]),
        active: json["active"],
        adminRevnue: _readString(
          json["AdminRevnue"] ?? json["adminRevenue"] ?? json["adminRevnue"],
        ),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mediaHouseName": mediaHouseName,
        "address": address,
        "contactNumber": contactNumber,
        "email": email,
        "registrationCertificate": registrationCertificate,
        "gstCertificates": gstCertificates,
        "adharCard": adharCard,
        "shopAct": shopAct,
        "panCard": panCard,
        "createdDate": createdDate,
        "updatedDate": updatedDate,
        "profileImage": profileImage,
        "otp": otp,
        "password": password,
        "status": status,
        "joinDate": joinDate,
        "logo": logo,
        "totalReveneu": totalReveneu,
        "postCount": postCount,
        "discription": discription,
        "bankAccountNumber": bankAccountNumber,
        "bankIFSCNumber": bankIfscNumber,
        "bankProof": bankProof,
        "identityProof": identityProof,
        "addressProof": addressProof,
        "bankName": bankName,
        "accountHolderName": accountHolderName,
        "firmType": firmType,
        "designation": designation,
        "user": user?.toJson(),
        "directorId": directorId,
        "ceoId": ceoId,
        "location": location?.toJson(),
        "totalViews": totalViews,
        "mediaHouseRevenue": mediaHouseRevenue,
        "totalRevenue": totalRevenue,
        "active": active,
        "AdminRevnue": adminRevnue,
      };

  static String? _readString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}

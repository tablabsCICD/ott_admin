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

  // Contact and Location flattened parameters
  String? area;
  String? city;
  String? district;
  String? taluka;
  String? state;
  String? country;
  String? pincode;
  String? officeBuilding;
  int? userId;

  String? gstNumber;
  String? authorizedPerson;
  String? companyVerificationStatus;
  dynamic companyVerificationSubmittedAt;
  dynamic companyVerificationReviewedAt;
  String? companyVerificationRejectionRemarks;
  String? companyVerificationAdminRemark;

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
    this.area,
    this.city,
    this.district,
    this.taluka,
    this.state,
    this.country,
    this.pincode,
    this.officeBuilding,
    this.userId,
    this.gstNumber,
    this.authorizedPerson,
    this.companyVerificationStatus,
    this.companyVerificationSubmittedAt,
    this.companyVerificationReviewedAt,
    this.companyVerificationRejectionRemarks,
    this.companyVerificationAdminRemark,
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
        createdDate: json["createdDate"] is int
            ? json["createdDate"]
            : int.tryParse(json["createdDate"]?.toString() ?? ''),
        updatedDate: json["updatedDate"],
        profileImage: json["profileImage"],
        otp: json["otp"],
        password: json["password"],
        status: json["status"],
        joinDate: json["joinDate"],
        logo: json["logo"],
        totalReveneu: _readString(json["totalReveneu"]),
        postCount: _readString(json["postCount"]),
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
        active: json["active"] is bool ? json["active"] : (json["active"] == 1 || json["active"] == 'true'),
        adminRevnue: _readString(
          json["AdminRevnue"] ?? json["adminRevenue"] ?? json["adminRevnue"],
        ),
        area: _readString(json["area"] ?? (json["location"] is Map ? json["location"]["area"] : null)),
        city: _readString(json["city"] ?? (json["location"] is Map ? json["location"]["city"] : null)),
        district: _readString(json["district"] ?? (json["location"] is Map ? json["location"]["district"] : null)),
        taluka: _readString(json["taluka"] ?? (json["location"] is Map ? json["location"]["taluka"] : null)),
        state: _readString(json["state"] ?? (json["location"] is Map ? json["location"]["state"] : null)),
        country: _readString(json["country"] ?? (json["location"] is Map ? json["location"]["country"] : null)),
        pincode: _readString(json["pincode"] ?? (json["location"] is Map ? json["location"]["pincode"] : null)),
        officeBuilding: _readString(json["officeBuilding"] ?? (json["location"] is Map ? json["location"]["officeBuilding"] : null)),
        userId: json["userId"] ?? (json["user"] is Map ? json["user"]["id"] : null),
        gstNumber: _readString(json["gstNumber"]),
        authorizedPerson: _readString(json["authorizedPerson"]),
        companyVerificationStatus:
            _readString(json["companyVerificationStatus"]),
        companyVerificationSubmittedAt: json["companyVerificationSubmittedAt"],
        companyVerificationReviewedAt: json["companyVerificationReviewedAt"],
        companyVerificationRejectionRemarks:
            _readString(json["companyVerificationRejectionRemarks"]),
        companyVerificationAdminRemark:
            _readString(json["companyVerificationAdminRemark"]),
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
        "area": area,
        "city": city,
        "district": district,
        "taluka": taluka,
        "state": state,
        "country": country,
        "pincode": pincode,
        "officeBuilding": officeBuilding,
        "userId": userId,
      };

  /// Serializes into the exact 31-parameter flat model required by Update API
  Map<String, dynamic> toUpdateJson() => {
        "active": active ?? true,
        "address": address ?? '',
        "adharCard": adharCard ?? '',
        "area": area ?? location?.area ?? '',
        "city": city ?? location?.city ?? '',
        "contactNumber": contactNumber ?? '',
        "country": country ?? location?.country ?? '',
        "designation": designation ?? '',
        "discription": discription?.toString() ?? '',
        "district": district ?? location?.district ?? '',
        "email": email ?? '',
        "gstCertificates": gstCertificates ?? '',
        "id": id ?? 0,
        "joinDate": joinDate?.toString() ?? '',
        "logo": logo?.toString() ?? '',
        "mediaHouseName": mediaHouseName ?? '',
        "officeBuilding": officeBuilding ?? location?.officeBuilding ?? '',
        "panCard": panCard ?? '',
        "password": password ?? '',
        "pincode": pincode ?? location?.pincode ?? '',
        "postCount": postCount ?? '0',
        "profileImage": profileImage?.toString() ?? '',
        "registrationCertificate": registrationCertificate ?? '',
        "shopAct": shopAct?.toString() ?? '',
        "state": state ?? location?.state ?? '',
        "status": status ?? 'ACTIVE',
        "taluka": taluka ?? location?.taluka ?? '',
        "totalReveneu": totalReveneu ?? '0',
        "totalViews": totalViews ?? '0',
        "updatedDate": DateTime.now().toUtc().toIso8601String(),
        "userId": null,
      };

  MediaHouse copyWith({
    int? id,
    String? mediaHouseName,
    String? address,
    String? contactNumber,
    String? email,
    String? registrationCertificate,
    String? gstCertificates,
    String? adharCard,
    dynamic shopAct,
    String? panCard,
    int? createdDate,
    dynamic updatedDate,
    dynamic profileImage,
    dynamic otp,
    String? password,
    String? status,
    dynamic joinDate,
    dynamic logo,
    String? totalReveneu,
    String? postCount,
    dynamic discription,
    String? bankAccountNumber,
    String? bankIfscNumber,
    String? bankProof,
    String? identityProof,
    String? addressProof,
    dynamic bankName,
    dynamic accountHolderName,
    dynamic firmType,
    String? designation,
    User? user,
    int? directorId,
    int? ceoId,
    Location? location,
    String? totalViews,
    String? mediaHouseRevenue,
    String? totalRevenue,
    bool? active,
    String? adminRevnue,
    String? area,
    String? city,
    String? district,
    String? taluka,
    String? state,
    String? country,
    String? pincode,
    String? officeBuilding,
    int? userId,
  }) {
    return MediaHouse(
      id: id ?? this.id,
      mediaHouseName: mediaHouseName ?? this.mediaHouseName,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      registrationCertificate:
          registrationCertificate ?? this.registrationCertificate,
      gstCertificates: gstCertificates ?? this.gstCertificates,
      adharCard: adharCard ?? this.adharCard,
      shopAct: shopAct ?? this.shopAct,
      panCard: panCard ?? this.panCard,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      profileImage: profileImage ?? this.profileImage,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      logo: logo ?? this.logo,
      totalReveneu: totalReveneu ?? this.totalReveneu,
      postCount: postCount ?? this.postCount,
      discription: discription ?? this.discription,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscNumber: bankIfscNumber ?? this.bankIfscNumber,
      bankProof: bankProof ?? this.bankProof,
      identityProof: identityProof ?? this.identityProof,
      addressProof: addressProof ?? this.addressProof,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      firmType: firmType ?? this.firmType,
      designation: designation ?? this.designation,
      user: user ?? this.user,
      directorId: directorId ?? this.directorId,
      ceoId: ceoId ?? this.ceoId,
      location: location ?? this.location,
      totalViews: totalViews ?? this.totalViews,
      mediaHouseRevenue: mediaHouseRevenue ?? this.mediaHouseRevenue,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      active: active ?? this.active,
      adminRevnue: adminRevnue ?? this.adminRevnue,
      area: area ?? this.area,
      city: city ?? this.city,
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      officeBuilding: officeBuilding ?? this.officeBuilding,
      userId: userId ?? this.userId,
      gstNumber: gstNumber ?? this.gstNumber,
      authorizedPerson: authorizedPerson ?? this.authorizedPerson,
      companyVerificationStatus:
          companyVerificationStatus ?? this.companyVerificationStatus,
      companyVerificationSubmittedAt:
          companyVerificationSubmittedAt ?? this.companyVerificationSubmittedAt,
      companyVerificationReviewedAt:
          companyVerificationReviewedAt ?? this.companyVerificationReviewedAt,
      companyVerificationRejectionRemarks:
          companyVerificationRejectionRemarks ??
              this.companyVerificationRejectionRemarks,
      companyVerificationAdminRemark:
          companyVerificationAdminRemark ??
              this.companyVerificationAdminRemark,
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}

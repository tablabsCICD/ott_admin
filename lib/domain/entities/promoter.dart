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

  /// Returns normalized level string: 'National', 'State', 'District', 'Taluka'
  String get normalizedLevel {
    final raw = (level ?? '').trim().toLowerCase();
    if (raw.contains('nation') || raw.contains('country')) return 'National';
    if (raw.contains('state')) return 'State';
    if (raw.contains('district')) return 'District';
    if (raw.contains('taluka')) return 'Taluka';
    return level?.trim().isNotEmpty == true ? level!.trim() : 'Taluka';
  }

  /// Normalized status
  String get displayStatus {
    if (status != null && status!.trim().isNotEmpty) {
      final s = status!.trim().toUpperCase();
      if (s == 'ACTIVE' || s == 'APPROVED') return 'Active';
      if (s == 'INACTIVE' || s == 'REJECTED') return 'Inactive';
      if (s == 'SUSPENDED' || s == 'PENDING') return 'Suspended';
      return status!;
    }
    if (active == true) return 'Active';
    if (active == false) return 'Inactive';
    return 'Active';
  }

  bool get isActive => displayStatus == 'Active';
  bool get isInactive => displayStatus == 'Inactive';
  bool get isSuspended => displayStatus == 'Suspended';

  bool get isKycCompleted {
    final hasPan = panCard != null && panCard!.trim().isNotEmpty;
    final hasAadhar = aadharCard != null && aadharCard!.trim().isNotEmpty;
    final hasBank = accountNumber != null && accountNumber!.trim().isNotEmpty;
    return (hasPan || hasAadhar) && hasBank;
  }

  String get formattedAddress {
    final parts = <String>[
      if (location?.officeBuilding != null && location!.officeBuilding!.trim().isNotEmpty) location!.officeBuilding!.trim(),
      if (location?.area != null && location!.area!.trim().isNotEmpty) location!.area!.trim(),
      if (location?.city != null && location!.city!.trim().isNotEmpty) location!.city!.trim(),
      if (location?.taluka != null && location!.taluka!.trim().isNotEmpty) location!.taluka!.trim(),
      if (location?.district != null && location!.district!.trim().isNotEmpty) location!.district!.trim(),
      if (location?.state != null && location!.state!.trim().isNotEmpty) location!.state!.trim(),
      if (location?.country != null && location!.country!.trim().isNotEmpty) location!.country!.trim(),
      if (pincode != null && pincode!.trim().isNotEmpty) 'PIN: ${pincode!.trim()}',
    ];
    if (parts.isEmpty) {
      final userLocation = userId?.location;
      if (userLocation != null) {
        final uParts = <String>[
          if (userLocation.taluka != null && userLocation.taluka!.trim().isNotEmpty) userLocation.taluka!.trim(),
          if (userLocation.district != null && userLocation.district!.trim().isNotEmpty) userLocation.district!.trim(),
          if (userLocation.state != null && userLocation.state!.trim().isNotEmpty) userLocation.state!.trim(),
          if (userLocation.country != null && userLocation.country!.trim().isNotEmpty) userLocation.country!.trim(),
        ];
        if (uParts.isNotEmpty) return uParts.join(', ');
      }
      return 'N/A';
    }
    return parts.join(', ');
  }

  Promoters copyWith({
    int? id,
    String? promoterName,
    String? level,
    Location? location,
    User? userId,
    String? role,
    String? status,
    String? access,
    String? createdDate,
    dynamic promoterId,
    bool? active,
    String? aadharCard,
    String? accountNumber,
    String? bankName,
    String? branchName,
    String? contactNumber,
    String? gst,
    String? ifscCode,
    String? panCard,
    String? pincode,
    String? refferedBy,
    String? registrationCertificate,
    String? website,
  }) {
    return Promoters(
      id: id ?? this.id,
      promoterName: promoterName ?? this.promoterName,
      level: level ?? this.level,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      access: access ?? this.access,
      createdDate: createdDate ?? this.createdDate,
      promoterId: promoterId ?? this.promoterId,
      active: active ?? this.active,
      aadharCard: aadharCard ?? this.aadharCard,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      contactNumber: contactNumber ?? this.contactNumber,
      gst: gst ?? this.gst,
      ifscCode: ifscCode ?? this.ifscCode,
      panCard: panCard ?? this.panCard,
      pincode: pincode ?? this.pincode,
      refferedBy: refferedBy ?? this.refferedBy,
      registrationCertificate: registrationCertificate ?? this.registrationCertificate,
      website: website ?? this.website,
    );
  }
}

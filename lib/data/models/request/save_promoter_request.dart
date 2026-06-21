class SavePromoterRequest {
  String? aadharCard;
  String? access;
  String? accountNumber;
  bool? active;
  String? area;
  String? bankName;
  String? branchName;
  String? city;
  String? contactNumber;
  String? country;
  String? createdDate;
  String? district;
  String? gst;
  int? id;
  String? ifscCode;
  String? level;
  String? panCard;
  String? pincode;
  int? promoterId;
  String? promoterName;
  String? refferedBy;
  String? registrationCertificate;
  String? role;
  String? state;
  String? taluka;
  int? userId;
  String? website;

  SavePromoterRequest({
    this.aadharCard,
    this.access,
    this.accountNumber,
    this.active,
    this.area,
    this.bankName,
    this.branchName,
    this.city,
    this.contactNumber,
    this.country,
    this.createdDate,
    this.district,
    this.gst,
    this.id,
    this.ifscCode,
    this.level,
    this.panCard,
    this.pincode,
    this.promoterId,
    this.promoterName,
    this.refferedBy,
    this.registrationCertificate,
    this.role,
    this.state,
    this.taluka,
    this.userId,
    this.website,
  });

  SavePromoterRequest.fromJson(Map<String, dynamic> json) {
    aadharCard = json['aadharCard'];
    access = json['access'];
    accountNumber = json['accountNumber'];
    active = json['active'];
    area = json['area'];
    bankName = json['bankName'];
    branchName = json['branchName'];
    city = json['city'];
    contactNumber = json['contactNumber'];
    country = json['country'];
    createdDate = json['createdDate'];
    district = json['district'];
    gst = json['gst'];
    id = json['id'];
    ifscCode = json['ifscCode'];
    level = json['level'];
    panCard = json['panCard'];
    pincode = json['pincode'];
    promoterId = json['promoterId'];
    promoterName = json['promoterName'];
    refferedBy = json['refferedBy'];
    registrationCertificate = json['registrationCertificate'];
    role = json['role'];
    state = json['state'];
    taluka = json['taluka'];
    userId = json['userId'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['aadharCard'] = aadharCard ?? '';
    data['access'] = access ?? '';
    data['accountNumber'] = accountNumber ?? '';
    data['active'] = active ?? true;
    data['area'] = area ?? '';
    data['bankName'] = bankName ?? '';
    data['branchName'] = branchName ?? '';
    data['city'] = city ?? '';
    data['contactNumber'] = contactNumber ?? '';
    data['country'] = country ?? '';
    data['createdDate'] = createdDate ?? '';
    data['district'] = district ?? '';
    data['gst'] = gst ?? '';
    data['id'] = id ?? 0;
    data['ifscCode'] = ifscCode ?? '';
    data['level'] = level ?? '';
    data['panCard'] = panCard ?? '';
    data['pincode'] = pincode ?? '';
    data['promoterId'] = promoterId ?? 0;
    data['promoterName'] = promoterName ?? '';
    data['refferedBy'] = refferedBy ?? '';
    data['registrationCertificate'] = registrationCertificate ?? '';
    data['role'] = role ?? '';
    data['state'] = state ?? '';
    data['taluka'] = taluka ?? '';
    data['userId'] = userId ?? 0;
    data['website'] = website ?? '';
    return data;
  }
}

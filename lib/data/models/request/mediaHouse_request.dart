class SaveMediaHouse {
  String? address;
  String? adharCard;
  String? area;
  String? city;
  String? contactNumber;
  String? country;
  String? createdDate;
  String? discription;
  String? district;
  String? email;
  String? gstCertificates;
  String? joinDate;
  String? logo;
  String? mediaHouseName;
  String? officeBuilding;
  String? otp;
  String? panCard;
  String? password;
  String? pincode;
  String? postCount;
  String? profileImage;
  String? registrationCertificate;
  String? shopAct;
  String? state;
  String? status;
  String? taluka;
  String? totalReveneu;
  String? totalViews;
  String? updatedDate;
  int? userId;

  String? firmType;
  String? designation;
  String? emailId;
  String? mobileNumber;
  String? refferedBy;
  String? dob;
  String? ceoName;
  String? ceoEmail;
  String? ceoMobile;
  String? directorName;
  String? directorEmail;
  String? directorMobile;
  String? accountHolderName;
  String? bankName;
  String? bankAccountNumber;
  String? bankIFSCNumber;
  String? addressProof;
  String? bankProof;

  SaveMediaHouse({
    this.address,
    this.adharCard,
    this.area,
    this.city,
    this.contactNumber,
    this.country,
    this.createdDate,
    this.discription,
    this.district,
    this.email,
    this.gstCertificates,
    this.joinDate,
    this.logo,
    this.mediaHouseName,
    this.officeBuilding,
    this.otp,
    this.panCard,
    this.password,
    this.pincode,
    this.postCount,
    this.profileImage,
    this.registrationCertificate,
    this.shopAct,
    this.state,
    this.status,
    this.taluka,
    this.totalReveneu,
    this.totalViews,
    this.updatedDate,
    this.userId,
    this.firmType,
    this.designation,
    this.emailId,
    this.mobileNumber,
    this.refferedBy,
    this.dob,
    this.ceoName,
    this.ceoEmail,
    this.ceoMobile,
    this.directorName,
    this.directorEmail,
    this.directorMobile,
    this.accountHolderName,
    this.bankName,
    this.bankAccountNumber,
    this.bankIFSCNumber,
    this.addressProof,
    this.bankProof,
  });

  SaveMediaHouse.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    adharCard = json['adharCard'];
    area = json['area'];
    city = json['city'];
    contactNumber = json['contactNumber'];
    country = json['country'];
    createdDate = json['createdDate'];
    discription = json['discription'];
    district = json['district'];
    email = json['email'];
    gstCertificates = json['gstCertificates'];
    joinDate = json['joinDate'];
    logo = json['logo'];
    mediaHouseName = json['mediaHouseName'];
    officeBuilding = json['officeBuilding'];
    otp = json['otp'];
    panCard = json['panCard'];
    password = json['password'];
    pincode = json['pincode'];
    postCount = json['postCount'];
    profileImage = json['profileImage'];
    registrationCertificate = json['registrationCertificate'];
    shopAct = json['shopAct'];
    state = json['state'];
    status = json['status'];
    taluka = json['taluka'];
    totalReveneu = json['totalReveneu'];
    totalViews = json['totalViews'];
    updatedDate = json['updatedDate'];
    userId = json['userId'];
    firmType = json['firmType'];
    designation = json['designation'];
    emailId = json['emailId'];
    mobileNumber = json['mobileNumber'];
    refferedBy = json['refferedBy'];
    dob = json['dob'];
    ceoName = json['ceoName'];
    ceoEmail = json['ceoEmail'];
    ceoMobile = json['ceoMobile'];
    directorName = json['directorName'];
    directorEmail = json['directorEmail'];
    directorMobile = json['directorMobile'];
    accountHolderName = json['accountHolderName'];
    bankName = json['bankName'];
    bankAccountNumber = json['bankAccountNumber'];
    bankIFSCNumber = json['bankIFSCNumber'];
    addressProof = json['addressProof'];
    bankProof = json['bankProof'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['adharCard'] = adharCard;
    data['area'] = area;
    data['city'] = city;
    data['contactNumber'] = contactNumber;
    data['country'] = country;
    data['createdDate'] = createdDate;
    data['discription'] = discription;
    data['district'] = district;
    data['email'] = email;
    data['gstCertificates'] = gstCertificates;
    data['joinDate'] = joinDate;
    data['logo'] = logo;
    data['mediaHouseName'] = mediaHouseName;
    data['officeBuilding'] = officeBuilding;
    data['otp'] = otp;
    data['panCard'] = panCard;
    data['password'] = password;
    data['pincode'] = pincode;
    data['postCount'] = postCount;
    data['profileImage'] = profileImage;
    data['registrationCertificate'] = registrationCertificate;
    data['shopAct'] = shopAct;
    data['state'] = state;
    data['status'] = status;
    data['taluka'] = taluka;
    data['totalReveneu'] = totalReveneu;
    data['totalViews'] = totalViews;
    data['updatedDate'] = updatedDate;
    data['userId'] = userId;
    data['firmType'] = firmType;
    data['designation'] = designation;
    data['emailId'] = emailId;
    data['mobileNumber'] = mobileNumber;
    data['refferedBy'] = refferedBy;
    data['dob'] = dob;
    data['ceoName'] = ceoName;
    data['ceoEmail'] = ceoEmail;
    data['ceoMobile'] = ceoMobile;
    data['directorName'] = directorName;
    data['directorEmail'] = directorEmail;
    data['directorMobile'] = directorMobile;
    data['accountHolderName'] = accountHolderName;
    data['bankName'] = bankName;
    data['bankAccountNumber'] = bankAccountNumber;
    data['bankIFSCNumber'] = bankIFSCNumber;
    data['addressProof'] = addressProof;
    data['bankProof'] = bankProof;
    return data;
  }
}

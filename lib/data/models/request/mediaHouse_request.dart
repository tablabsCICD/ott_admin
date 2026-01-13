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

   SaveMediaHouse(
  {this.address,
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
  this.userId});

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
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['address'] = this.address;
  data['adharCard'] = this.adharCard;
  data['area'] = this.area;
  data['city'] = this.city;
  data['contactNumber'] = this.contactNumber;
  data['country'] = this.country;
  data['createdDate'] = this.createdDate;
  data['discription'] = this.discription;
  data['district'] = this.district;
  data['email'] = this.email;
  data['gstCertificates'] = this.gstCertificates;
  data['joinDate'] = this.joinDate;
  data['logo'] = this.logo;
  data['mediaHouseName'] = this.mediaHouseName;
  data['officeBuilding'] = this.officeBuilding;
  data['otp'] = this.otp;
  data['panCard'] = this.panCard;
  data['password'] = this.password;
  data['pincode'] = this.pincode;
  data['postCount'] = this.postCount;
  data['profileImage'] = this.profileImage;
  data['registrationCertificate'] = this.registrationCertificate;
  data['shopAct'] = this.shopAct;
  data['state'] = this.state;
  data['status'] = this.status;
  data['taluka'] = this.taluka;
  data['totalReveneu'] = this.totalReveneu;
  data['totalViews'] = this.totalViews;
  data['updatedDate'] = this.updatedDate;
  data['userId'] = this.userId;
  return data;
  }
  }

class UserRequest {

  bool? admin;
  String? age;
  String? area;
  String? city;
  String? country;
  String? deviceId;
  String? deviceName;
  String? deviceToken;
  String? district;
  String? dob;
  String? emailId;
  String? firstName;
  String? gender;
  String? joinDate;
  String? lastName;
  int? locationId;
  String? mobileNumber;
  String? officeBuilding;
  String? osName;
  String? password;
  String? pincode;
  String? profilePhoto;
  String? refferedBy;
  String? state;
  String? taluka;
  bool? verified;

  UserRequest(
      {
        this.admin,
        this.age,
        this.area,
        this.city,
        this.country,
        this.deviceId,
        this.deviceName,
        this.deviceToken,
        this.district,
        this.dob,
        this.emailId,
        this.firstName,
        this.gender,
        this.joinDate,
        this.lastName,
        this.locationId,
        this.mobileNumber,
        this.officeBuilding,
        this.osName,
        this.password,
        this.pincode,
        this.profilePhoto,
        this.refferedBy,

        this.state,
        this.taluka,
        this.verified});

  UserRequest.fromJson(Map<String, dynamic> json) {

    admin = json['admin'];
    age = json['age'];
    area = json['area'];
    city = json['city'];
    country = json['country'];
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    deviceToken = json['deviceToken'];
    district = json['district'];
    dob = json['dob'];
    emailId = json['emailId'];
    firstName = json['firstName'];
    gender = json['gender'];
    joinDate = json['joinDate'];
    lastName = json['lastName'];
    locationId = json['locationId'];
    mobileNumber = json['mobileNumber'];
    officeBuilding = json['officeBuilding'];
    osName = json['osName'];
    password = json['password'];
    pincode = json['pincode'];
    profilePhoto = json['profilePhoto'];
    refferedBy = json['refferedBy'];


    state = json['state'];
    taluka = json['taluka'];
    verified = json['verified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['admin'] = this.admin;
    data['age'] = this.age;
    data['area'] = this.area;
    data['city'] = this.city;
    data['country'] = this.country;
    data['deviceId'] = this.deviceId;
    data['deviceName'] = this.deviceName;
    data['deviceToken'] = this.deviceToken;
    data['district'] = this.district;
    data['dob'] = this.dob;
    data['emailId'] = this.emailId;
    data['firstName'] = this.firstName;
    data['gender'] = this.gender;
    data['joinDate'] = this.joinDate;
    data['lastName'] = this.lastName;
    data['locationId'] = this.locationId;
    data['mobileNumber'] = this.mobileNumber;
    data['officeBuilding'] = this.officeBuilding;
    data['osName'] = this.osName;
    data['password'] = this.password;
    data['pincode'] = this.pincode;
    data['profilePhoto'] = this.profilePhoto;
    data['refferedBy'] = this.refferedBy;

    data['state'] = this.state;
    data['taluka'] = this.taluka;
    data['verified'] = this.verified;
    return data;
  }
}

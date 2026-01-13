import 'location.dart';

class User {
  int? id;
  String? refferedBy;
  String? lastName;
  List<String>? role;
  String? gender;
  String? mobileNumber;
  bool? admin;
  String? emailId;
  String? refferCode;
  String? deviceId;
  String? deviceName;
  String? password;
  String? profilePhoto;
  String? joinDate;
  String? registrationDate;
  List<String>? selectedLanguages;
  bool? verified;
  bool? active;
  dynamic otp;
  String? osName;
  String? deviceToken;
  String? firstName;
  String? dob;
  Location? location;
  String? age;

  User({
    this.id,
    this.refferedBy,
    this.lastName,
    this.role,
    this.gender,
    this.mobileNumber,
    this.admin,
    this.emailId,
    this.refferCode,
    this.deviceId,
    this.deviceName,
    this.password,
    this.profilePhoto,
    this.joinDate,
    this.registrationDate,
    this.selectedLanguages,
    this.verified,
    this.active,
    this.otp,
    this.osName,
    this.deviceToken,
    this.firstName,
    this.dob,
    this.location,
    this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    refferedBy: json["refferedBy"],
    lastName: json["lastName"],
    role: json["role"] == null ? [] : List<String>.from(json["role"]!.map((x) => x)),
    gender: json["gender"],
    mobileNumber: json["mobileNumber"],
    admin: json["admin"],
    emailId: json["emailId"],
    refferCode: json["refferCode"],
    deviceId: json["deviceId"],
    deviceName: json["deviceName"],
    password: json["password"],
    profilePhoto: json["profilePhoto"],
    joinDate: json["joinDate"],
    registrationDate: json["registrationDate"],
    selectedLanguages: json["selectedLanguages"] == null ? [] : List<String>.from(json["selectedLanguages"]!.map((x) => x)),
    verified: json["verified"],
    active: json["active"],
    otp: json["otp"],
    osName: json["osName"],
    deviceToken: json["deviceToken"],
    firstName: json["firstName"],
    dob: json["dob"],
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    age: json["age"],
  );

  Map<String, dynamic> toJson() => {
    "id":id,
    "refferedBy": refferedBy,
    "lastName": lastName,
    "role": role == null ? [] : List<dynamic>.from(role!.map((x) => x)),
    "gender": gender,
    "mobileNumber": mobileNumber,
    "admin": admin,
    "emailId": emailId,
    "refferCode": refferCode,
    "deviceId": deviceId,
    "deviceName": deviceName,
    "password": password,
    "profilePhoto": profilePhoto,
    "joinDate": joinDate,
    "registrationDate": registrationDate,
    "selectedLanguages": selectedLanguages == null ? [] : List<dynamic>.from(selectedLanguages!.map((x) => x)),
    "verified": verified,
    "active": active,
    "otp": otp,
    "osName": osName,
    "deviceToken": deviceToken,
    "firstName": firstName,
    "dob": dob,
    "location": location?.toJson(),
    "age": age,
  };
}



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

  factory User.fromJson(Map<String, dynamic> json) {
    final rawId = json["id"];
    final int? id = rawId is int
        ? rawId
        : (rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? ''));

    final rawAdmin = json["admin"];
    final bool? admin = rawAdmin is bool
        ? rawAdmin
        : (rawAdmin != null ? rawAdmin.toString().toLowerCase() == 'true' : null);

    final rawVerified = json["verified"];
    final bool? verified = rawVerified is bool
        ? rawVerified
        : (rawVerified != null ? rawVerified.toString().toLowerCase() == 'true' : null);

    final rawActive = json["active"];
    final bool? active = rawActive is bool
        ? rawActive
        : (rawActive != null ? rawActive.toString().toLowerCase() == 'true' : null);

    final rawRole = json["role"];
    List<String>? role;
    if (rawRole != null) {
      if (rawRole is List) {
        role = rawRole.map((x) => x?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      } else {
        role = [rawRole.toString()];
      }
    }

    final rawLangs = json["selectedLanguages"];
    List<String>? selectedLanguages;
    if (rawLangs != null) {
      if (rawLangs is List) {
        selectedLanguages = rawLangs.map((x) => x?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      } else {
        selectedLanguages = [rawLangs.toString()];
      }
    }

    final rawLoc = json["location"];
    Location? location;
    if (rawLoc is Map<String, dynamic>) {
      location = Location.fromJson(rawLoc);
    } else if (rawLoc is Map) {
      location = Location.fromJson(Map<String, dynamic>.from(rawLoc));
    }

    return User(
      id: id,
      refferedBy: json["refferedBy"]?.toString(),
      lastName: json["lastName"]?.toString(),
      role: role ?? [],
      gender: json["gender"]?.toString(),
      mobileNumber: json["mobileNumber"]?.toString(),
      admin: admin,
      emailId: json["emailId"]?.toString(),
      refferCode: json["refferCode"]?.toString(),
      deviceId: json["deviceId"]?.toString(),
      deviceName: json["deviceName"]?.toString(),
      password: json["password"]?.toString(),
      profilePhoto: json["profilePhoto"]?.toString(),
      joinDate: _safeDateString(json["joinDate"]),
      registrationDate: _safeDateString(json["registrationDate"]),
      selectedLanguages: selectedLanguages ?? [],
      verified: verified,
      active: active,
      otp: json["otp"],
      osName: json["osName"]?.toString(),
      deviceToken: json["deviceToken"]?.toString(),
      firstName: json["firstName"]?.toString(),
      dob: _safeDateString(json["dob"]),
      location: location,
      age: json["age"]?.toString(),
    );
  }

  static String? _safeDateString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) {
      if (value <= 0) return null;
      if (value < 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000).toIso8601String();
      }
      return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
    }
    if (value is num) {
      final intVal = value.toInt();
      if (intVal <= 0) return null;
      if (intVal < 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intVal * 1000).toIso8601String();
      }
      return DateTime.fromMillisecondsSinceEpoch(intVal).toIso8601String();
    }
    return value.toString();
  }

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



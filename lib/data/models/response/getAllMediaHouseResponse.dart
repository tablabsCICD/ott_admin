import 'package:admin_ott/domain/entities/mediaHouse.dart';

class GetAllMediaHouseResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  GetAllMediaHouseResponse(
      {this.message, this.data, this.statusCode, this.success});

  GetAllMediaHouseResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    return data;
  }
}

class Data {
  List<MediaHouse>? mediaHouse;

  Data({this.mediaHouse});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['mediaHouses'] != null) {
      mediaHouse = <MediaHouse>[];
      json['mediaHouses'].forEach((v) {
        mediaHouse!.add(new MediaHouse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mediaHouse != null) {
      data['mediaHouses'] = this.mediaHouse!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


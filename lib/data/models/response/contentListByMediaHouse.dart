import 'package:admin_ott/domain/entities/content.dart';

class ContentListByMediaHouse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  ContentListByMediaHouse({this.message, this.data, this.statusCode, this.success});

  ContentListByMediaHouse.fromJson(Map<String, dynamic> json) {
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
  List<Content>? contentList;

  Data({this.contentList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['contentList'] != null) {
      contentList = <Content>[];
      json['contentList'].forEach((v) {
        contentList!.add(new Content.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.contentList != null) {
      data['contentList'] = this.contentList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
import '../../../domain/entities/promoter.dart';

class AddPromoterResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  AddPromoterResponse({this.message, this.data, this.statusCode, this.success});

  AddPromoterResponse.fromJson(Map<String, dynamic> json) {
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
  Promoters? promoters;

  Data({this.promoters});

  Data.fromJson(Map<String, dynamic> json) {
    promoters = json['Promoters'] != null
        ? new Promoters.fromJson(json['Promoters'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.promoters != null) {
      data['Promoters'] = this.promoters!.toJson();
    }
    return data;
  }
}


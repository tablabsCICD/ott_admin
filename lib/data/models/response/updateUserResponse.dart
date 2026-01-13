
import '../../../domain/entities/user.dart';

class UpdateUserResponse {
  String? message;
  User? data;
  bool? success;

  UpdateUserResponse({this.message, this.data, this.success});

  UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new User.fromJson(json['data']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['success'] = this.success;
    return data;
  }
}
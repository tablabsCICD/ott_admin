class SearchResponse {
  String? message;
  List<dynamic>? data; // Changed from List<Data> to List<dynamic>
  int? statusCode;
  bool? success;

  SearchResponse({this.message, this.data, this.statusCode, this.success});

  SearchResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = json['data']; // Assign as dynamic
    }
    statusCode = json['statusCode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data; // Serialize as dynamic
    }
    data['statusCode'] = statusCode;
    data['success'] = success;
    return data;
  }
}

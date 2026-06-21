import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  NotificationApiService({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  final ApiHelper _apiHelper;

  Future<Map<String, dynamic>> getNotifications({
    required int pageNo,
    required int pageSize,
  }) async {
    final response = await _apiHelper.getApi(
      ApiConstant.notifications(pageNo: pageNo, pageSize: pageSize),
    ) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> deleteNotification(String id) async {
    final response = await _apiHelper
        .deleteApi(ApiConstant.deleteNotification(id)) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> resendNotification(String id) async {
    final response = await _apiHelper
        .postApi(ApiConstant.resendNotification(id)) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> sendNotification(
      Map<String, dynamic> body) async {
    final response = await _apiHelper.postApiWithBody(
      ApiConstant.sendNotification,
      body,
    ) as http.Response;
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid API response (${response.statusCode}). Expected JSON.',
      );
    }

    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message']?.toString() ??
          'Request failed (${response.statusCode})');
    }

    return body;
  }
}

import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:http/http.dart' as http;

class AdminSettingsApiService {
  AdminSettingsApiService({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  final ApiHelper _apiHelper;

  Future<Map<String, dynamic>> getRevenueShareRules() async {
    final response = await _apiHelper
        .getApi(ApiConstant.getAllRevenueShareRules) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> saveRevenueShareRule(
      Map<String, dynamic> body) async {
    final response = await _apiHelper.postApiWithBody(
      ApiConstant.saveRevenueShareRule,
      body,
    ) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateRevenueShareRule(
      int id, Map<String, dynamic> body) async {
    final response = await _apiHelper.putApiWithBody(
      ApiConstant.updateRevenueShareRule(id),
      body,
    ) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> getRegistrationFeeRules() async {
    final response = await _apiHelper
        .getApi(ApiConstant.getAllRegistrationFeeRules) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> saveRegistrationFeeRule(
      Map<String, dynamic> body) async {
    final response = await _apiHelper.postApiWithBody(
      ApiConstant.saveRegistrationFeeRule,
      body,
    ) as http.Response;
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateRegistrationFeeRule(
      int id, Map<String, dynamic> body) async {
    final response = await _apiHelper.putApiWithBody(
      ApiConstant.updateRegistrationFeeRule(id),
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

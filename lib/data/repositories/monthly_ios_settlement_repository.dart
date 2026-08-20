import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app/core/constant/api_constant.dart';
import '../../app/core/network/api_helper.dart';
import '../models/response/monthly_ios_settlement.dart';

class MonthlyIosSettlementRepository {
  MonthlyIosSettlementRepository({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  final ApiHelper _apiHelper;

  Future<void> generateMonthlySettlement(String month) async {
    final url = ApiConstant.generateMonthlyIosSettlement;
    final body = {'month': month};
    debugPrint("========== GENERATE MONTHLY SETTLEMENT API REQUEST ==========");
    debugPrint("URL: $url");
    debugPrint("Method: POST");
    debugPrint("Payload: ${jsonEncode(body)}");

    final response = await _apiHelper.postApiWithBody(url, body) as http.Response;

    debugPrint("========== GENERATE MONTHLY SETTLEMENT API RESPONSE ==========");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Body: ${response.body}");
    debugPrint("=============================================================");

    _ensureSuccess(response, 'Failed to generate monthly iOS settlement.');
  }

  Future<MonthlySettlementListResponse> getMonthlySettlementList({
    String? month,
    String? status,
    String? userId,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (month != null && month.isNotEmpty) query['month'] = month;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (userId != null && userId.isNotEmpty) query['userId'] = userId;

    final uri = Uri.parse(ApiConstant.monthlyIosSettlementList)
        .replace(queryParameters: query);

    debugPrint("========== MONTHLY SETTLEMENT LIST API REQUEST ==========");
    debugPrint("URL: $uri");
    debugPrint("Method: GET");

    final response = await _apiHelper.getApi(uri.toString()) as http.Response;

    debugPrint("========== MONTHLY SETTLEMENT LIST API RESPONSE ==========");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Body: ${response.body}");
    debugPrint("=========================================================");

    _ensureSuccess(response, 'Failed to load monthly iOS settlements.');
    return MonthlySettlementListResponse.fromJson(_decode(response));
  }

  Future<MonthlySettlementDetailModel> getMonthlySettlementDetail(
    dynamic settlementId,
  ) async {
    final url = ApiConstant.monthlyIosSettlementDetail(settlementId);
    debugPrint("========== SETTLEMENT DETAILS (MONTHLY iOS) API REQUEST ==========");
    debugPrint("URL: $url");
    debugPrint("Method: GET");

    final response = await _apiHelper.getApi(url) as http.Response;

    debugPrint("========== SETTLEMENT DETAILS (MONTHLY iOS) API RESPONSE ==========");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Body: ${response.body}");
    debugPrint("==================================================================");

    _ensureSuccess(response, 'Failed to load monthly iOS settlement details.');
    final parsed = MonthlySettlementDetailResponse.fromJson(_decode(response));
    final data = parsed.data;
    if (data == null) {
      throw Exception(parsed.message ?? 'No settlement details available.');
    }
    return data;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{'data': body};
  }

  void _ensureSuccess(http.Response response, String fallback) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String? message;
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic> && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {
      message = null;
    }
    throw Exception(message ?? fallback);
  }
}

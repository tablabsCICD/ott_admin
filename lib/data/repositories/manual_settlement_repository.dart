import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/data/models/request/manual_settlement_request.dart';
import 'package:admin_ott/data/models/response/manual_settlement_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ManualSettlementException implements Exception {
  final String message;
  final int? statusCode;

  ManualSettlementException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ManualSettlementRepository {
  final ApiHelper _apiHelper;

  ManualSettlementRepository({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  Future<ManualSettlementResponse> processManualSettlement(
    ManualSettlementRequest request,
  ) async {
    final url = ApiConstant.manualSettlement;
    final payload = request.toJson();

    debugPrint("========== MANUAL SETTLEMENT API REQUEST ==========");
    debugPrint("URL: $url");
    debugPrint("Method: POST");
    debugPrint("Payload: ${jsonEncode(payload)}");

    try {
      final response = await _apiHelper
          .postApiWithBody(url, payload)
          .timeout(const Duration(seconds: 30));

      final httpResponse = response as http.Response;
      final statusCode = httpResponse.statusCode;

      debugPrint("========== MANUAL SETTLEMENT API RESPONSE ==========");
      debugPrint("Status Code: $statusCode");
      debugPrint("Body: ${httpResponse.body}");
      debugPrint("=================================================");

      Map<String, dynamic>? decodedBody;
      try {
        final bodyString = utf8.decode(httpResponse.bodyBytes);
        if (bodyString.isNotEmpty) {
          final jsonParsed = jsonDecode(bodyString);
          if (jsonParsed is Map<String, dynamic>) {
            decodedBody = jsonParsed;
          }
        }
      } catch (e) {
        debugPrint('Failed to decode manual settlement response: $e');
      }

      final backendMessage = decodedBody?['message']?.toString();

      if (statusCode >= 200 && statusCode < 300) {
        if (decodedBody != null) {
          final parsedResponse = ManualSettlementResponse.fromJson(decodedBody);
          if (parsedResponse.success == true) {
            return parsedResponse;
          } else {
            throw ManualSettlementException(
              parsedResponse.message ??
                  backendMessage ??
                  'Failed to process manual settlement.',
              statusCode: statusCode,
            );
          }
        } else {
          throw ManualSettlementException(
            'Received malformed response from server.',
            statusCode: statusCode,
          );
        }
      }

      final fallbackMessage = _getFallbackMessage(statusCode);
      final finalMessage = (backendMessage != null && backendMessage.trim().isNotEmpty)
          ? backendMessage
          : fallbackMessage;

      throw ManualSettlementException(finalMessage, statusCode: statusCode);
    } on SocketException catch (_) {
      throw ManualSettlementException(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException catch (_) {
      throw ManualSettlementException(
        'Request timed out. Please try again later.',
      );
    } on ManualSettlementException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during manual settlement: $e');
      throw ManualSettlementException(
        'An unexpected error occurred while processing settlement.',
      );
    }
  }

  String _getFallbackMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request parameters. Please verify the input values.';
      case 401:
        return 'Session expired or invalid authentication token. Please log in again.';
      case 403:
        return 'Access denied. You do not have permission to perform manual settlement.';
      case 404:
        return 'Settlement endpoint not found. Please contact support.';
      case 409:
        return 'A settlement operation is already in progress or conflicts with existing data.';
      case 500:
        return 'Internal server error occurred while processing settlement.';
      default:
        return 'Server returned status code $statusCode. Please try again.';
    }
  }
}

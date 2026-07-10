import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class PromoterSettlementException implements Exception {
  final String message;

  const PromoterSettlementException(this.message);

  @override
  String toString() => message;
}

/// Downloads the settlement workbook in browser builds while preserving the
/// filename supplied by the API's Content-Disposition header.
class PromoterSettlementService {
  const PromoterSettlementService();

  Future<String> downloadSettlementExcel({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _downloadFile(
      uri: Uri.parse(ApiConstant.promoterSettlementExcel).replace(
        queryParameters: _dateQuery(fromDate: fromDate, toDate: toDate),
      ),
      fallbackFilename:
          'promoter-payment-settlement-${_apiDate(DateTime.now())}.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      failureMessage: 'Failed to download settlement Excel.',
    );
  }

  Future<String> downloadMonthlyIosSettlementCsv(dynamic settlementId) async {
    return _downloadFile(
      uri: Uri.parse(ApiConstant.monthlyIosSettlementDownload(settlementId)),
      fallbackFilename:
          'monthly-ios-settlement-$settlementId-${_apiDate(DateTime.now())}.csv',
      mimeType: 'text/csv',
      failureMessage: 'Failed to download settlement CSV.',
    );
  }

  Future<String> _downloadFile({
    required Uri uri,
    required String fallbackFilename,
    required String mimeType,
    required String failureMessage,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(SharedPreferencesConstant.authToken);
    final tokenType = preferences
            .getString(SharedPreferencesConstant.authTokenType) ??
        'Bearer';
    final headers = <String, String>{'accept': '*/*'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = '$tokenType $token';
    }

    final response = await http.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PromoterSettlementException(_errorMessage(response, failureMessage));
    }

    final filename = _filenameFrom(response.headers['content-disposition']) ??
        fallbackFilename;
    final blob = html.Blob([response.bodyBytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final link = html.AnchorElement(href: url)..download = filename;
    html.document.body?.children.add(link);
    link.click();
    link.remove();
    html.Url.revokeObjectUrl(url);
    return filename;
  }

  Map<String, String>? _dateQuery({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final queryParameters = <String, String>{};
    if (fromDate != null) queryParameters['fromDate'] = _apiDate(fromDate);
    if (toDate != null) queryParameters['toDate'] = _apiDate(toDate);
    return queryParameters.isEmpty ? null : queryParameters;
  }

  String _apiDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic> && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {
      // A non-JSON error body falls back to the standard failure message.
    }
    return fallback;
  }

  String? _filenameFrom(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final utf8Match = RegExp(r"filename\*=UTF-8''([^;]+)", caseSensitive: false)
        .firstMatch(contentDisposition);
    if (utf8Match != null) return Uri.decodeComponent(utf8Match.group(1)!);
    final match = RegExp(r'filename="?([^";]+)"?', caseSensitive: false)
        .firstMatch(contentDisposition);
    return match?.group(1)?.trim();
  }
}

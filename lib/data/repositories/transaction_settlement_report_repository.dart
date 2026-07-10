import 'dart:convert';

import '../../app/core/constant/api_constant.dart';
import '../../app/core/network/api_helper.dart';
import '../models/response/transaction_settlement_report.dart';

class TransactionSettlementReportRepository {
  const TransactionSettlementReportRepository();

  Future<TransactionSettlementReportData> fetchTransactionSettlementReport(
    dynamic transactionId,
  ) async {
    final response = await ApiHelper().getApi(
      ApiConstant.transactionSettlementReport(transactionId),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch transaction settlement report. Status code: ${response.statusCode}',
      );
    }

    final body = json.decode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid transaction settlement report response.');
    }

    final report = TransactionSettlementReportResponse.fromJson(body);
    if (report.success && report.data != null) {
      return report.data!;
    }

    throw Exception(
      report.message ?? 'Unable to load transaction settlement report.',
    );
  }
}

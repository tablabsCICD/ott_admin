class MonthlySettlementListResponse {
  const MonthlySettlementListResponse({
    this.message,
    this.success,
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final String? message;
  final bool? success;
  final List<MonthlySettlementModel> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  factory MonthlySettlementListResponse.fromJson(Map<String, dynamic> json) {
    final pageData = _readPageData(json);
    final items = pageData.items
        .whereType<Map>()
        .map((entry) => MonthlySettlementModel.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList();

    return MonthlySettlementListResponse(
      message: _readString(json, const ['message', 'Message']),
      success: _readSuccess(json),
      items: items,
      page: _readInt(pageData.source['number'] ??
              pageData.source['page'] ??
              pageData.source['pageNo'] ??
              json['page']) ??
          0,
      size: _readInt(pageData.source['size'] ??
              pageData.source['pageSize'] ??
              json['size']) ??
          items.length,
      totalElements: _readInt(pageData.source['totalElements'] ??
              pageData.source['totalRecords'] ??
              json['totalElements']) ??
          items.length,
      totalPages: _readInt(pageData.source['totalPages'] ??
              pageData.source['pages'] ??
              json['totalPages']) ??
          1,
    );
  }
}

class MonthlySettlementDetailResponse {
  const MonthlySettlementDetailResponse({
    this.message,
    this.success,
    required this.data,
  });

  final String? message;
  final bool? success;
  final MonthlySettlementDetailModel? data;

  factory MonthlySettlementDetailResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['settlement'] ?? json;
    return MonthlySettlementDetailResponse(
      message: _readString(json, const ['message', 'Message']),
      success: _readSuccess(json),
      data: raw is Map
          ? MonthlySettlementDetailModel.fromJson(
              Map<String, dynamic>.from(raw),
            )
          : null,
    );
  }
}

class MonthlySettlementModel {
  const MonthlySettlementModel({
    this.id,
    this.settlementMonth,
    this.settlementType,
    this.operatingSystem,
    this.paymentGateway,
    this.status,
    this.totalTransactions,
    this.customerPayment,
    this.appleDeduction,
    this.creditedAmount,
    this.netSettlement,
    this.createdDate,
  });

  final dynamic id;
  final String? settlementMonth;
  final String? settlementType;
  final String? operatingSystem;
  final String? paymentGateway;
  final String? status;
  final int? totalTransactions;
  final double? customerPayment;
  final double? appleDeduction;
  final double? creditedAmount;
  final double? netSettlement;
  final DateTime? createdDate;

  factory MonthlySettlementModel.fromJson(Map<String, dynamic> json) {
    return MonthlySettlementModel(
      id: json['id'] ??
          json['settlementId'] ??
          json['monthlySettlementId'] ??
          json['transactionId'],
      settlementMonth: _readString(json, const [
        'settlementMonth',
        'month',
        'settlement_month',
      ]),
      settlementType: _readString(json, const [
        'settlementType',
        'type',
        'settlement_type',
      ]),
      operatingSystem: _readString(json, const [
        'operatingSystem',
        'os',
        'operating_system',
      ]),
      paymentGateway: _readString(json, const [
        'paymentGateway',
        'gateway',
        'payment_gateway',
      ]),
      status: _readString(json, const ['status', 'settlementStatus']),
      totalTransactions: _readInt(json['totalTransactions'] ??
          json['transactions'] ??
          json['transactionCount']),
      customerPayment: _readDouble(json['customerPayment'] ??
          json['customerCollection'] ??
          json['totalIosCollection'] ??
          json['totalCollection']),
      appleDeduction: _readDouble(json['appleDeduction'] ??
          json['deduction'] ??
          json['totalAppleDeduction']),
      creditedAmount: _readDouble(json['creditedAmount'] ??
          json['totalCreditedAmount'] ??
          json['credited']),
      netSettlement: _readDouble(json['netSettlement'] ??
          json['netAmount'] ??
          json['finalSettlement']),
      createdDate: _readDate(json['createdDate'] ??
          json['createdAt'] ??
          json['created_date']),
    );
  }
}

class MonthlySettlementDetailModel {
  const MonthlySettlementDetailModel({
    this.id,
    this.settlementMonth,
    this.status,
    this.periodStart,
    this.periodEnd,
    this.operatingSystem,
    this.paymentGateway,
    required this.summaryCards,
    required this.transactions,
  });

  final dynamic id;
  final String? settlementMonth;
  final String? status;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String? operatingSystem;
  final String? paymentGateway;
  final List<MonthlySummaryCardModel> summaryCards;
  final List<MonthlyTransactionDetailModel> transactions;

  factory MonthlySettlementDetailModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summaryCards'] ?? json['summary'] ?? json['metrics'];
    final transactions =
        json['transactions'] ?? json['transactionDetails'] ?? json['content'];

    return MonthlySettlementDetailModel(
      id: json['id'] ?? json['settlementId'] ?? json['monthlySettlementId'],
      settlementMonth: _readString(json, const [
        'settlementMonth',
        'month',
        'settlement_month',
      ]),
      status: _readString(json, const ['status', 'settlementStatus']),
      periodStart: _readDate(json['periodStart'] ??
          json['fromDate'] ??
          json['startDate'] ??
          json['settlementStartDate']),
      periodEnd: _readDate(json['periodEnd'] ??
          json['toDate'] ??
          json['endDate'] ??
          json['settlementEndDate']),
      operatingSystem: _readString(json, const [
        'operatingSystem',
        'os',
        'operating_system',
      ]),
      paymentGateway: _readString(json, const [
        'paymentGateway',
        'gateway',
        'payment_gateway',
      ]),
      summaryCards: _readList(summary)
          .whereType<Map>()
          .map((entry) => MonthlySummaryCardModel.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      transactions: _readList(transactions)
          .whereType<Map>()
          .map((entry) => MonthlyTransactionDetailModel.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList(),
    );
  }
}

class MonthlySummaryCardModel {
  const MonthlySummaryCardModel({
    required this.label,
    required this.value,
    required this.displayOrder,
  });

  final String label;
  final dynamic value;
  final int displayOrder;

  factory MonthlySummaryCardModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryCardModel(
      label: _readString(json, const [
            'label',
            'title',
            'name',
            'metricName',
          ]) ??
          'Summary',
      value: json['value'] ?? json['amount'] ?? json['metricValue'],
      displayOrder: _readInt(json['displayOrder'] ?? json['order']) ?? 0,
    );
  }
}

class MonthlyTransactionDetailModel {
  const MonthlyTransactionDetailModel({
    this.transactionId,
    this.user,
    this.paymentDate,
    this.requestedAmount,
    this.deduction,
    this.creditedAmount,
    this.status,
    this.operatingSystem,
    this.gateway,
    this.deductionReason,
  });

  final String? transactionId;
  final String? user;
  final DateTime? paymentDate;
  final double? requestedAmount;
  final double? deduction;
  final double? creditedAmount;
  final String? status;
  final String? operatingSystem;
  final String? gateway;
  final String? deductionReason;

  factory MonthlyTransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return MonthlyTransactionDetailModel(
      transactionId: _readString(json, const [
        'transactionId',
        'txnId',
        'paymentId',
      ]),
      user: _readString(json, const [
        'user',
        'userName',
        'customerName',
        'name',
      ]),
      paymentDate: _readDate(json['paymentDate'] ??
          json['paidAt'] ??
          json['transactionDate']),
      requestedAmount: _readDouble(json['requestedAmount'] ??
          json['customerPayment'] ??
          json['amount']),
      deduction: _readDouble(json['deduction'] ??
          json['appleDeduction'] ??
          json['deductionAmount']),
      creditedAmount: _readDouble(json['creditedAmount'] ??
          json['credited'] ??
          json['netAmount']),
      status: _readString(json, const ['status', 'paymentStatus']),
      operatingSystem: _readString(json, const [
        'operatingSystem',
        'os',
        'operating_system',
      ]),
      gateway: _readString(json, const [
        'gateway',
        'paymentGateway',
        'payment_gateway',
      ]),
      deductionReason: _readString(json, const [
        'deductionReason',
        'reason',
        'appleDeductionReason',
      ]),
    );
  }
}

class _PageData {
  const _PageData(this.source, this.items);

  final Map<String, dynamic> source;
  final List<dynamic> items;
}

_PageData _readPageData(Map<String, dynamic> json) {
  final raw = json['data'] ?? json['content'] ?? json['settlements'] ?? json;
  if (raw is List) return _PageData(json, raw);
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final items =
        map['content'] ?? map['data'] ?? map['items'] ?? map['settlements'];
    if (items is List) return _PageData(map, items);
  }
  return _PageData(json, const []);
}

List<dynamic> _readList(dynamic value) {
  if (value is List) return value;
  if (value is Map) {
    final nested = value['content'] ?? value['data'] ?? value['items'];
    if (nested is List) return nested;
  }
  return const [];
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

bool? _readSuccess(Map<String, dynamic> json) {
  final value = json['success'] ?? json['status'];
  if (value is bool) return value;
  final text = value?.toString().toLowerCase();
  if (text == 'success' || text == 'true') return true;
  if (text == 'failed' || text == 'false') return false;
  return null;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final text = value
          ?.toString()
          .replaceAll(',', '')
          .replaceAll('Rs.', '')
          .replaceAll('Rs', '')
          .replaceAll('₹', '')
          .trim() ??
      '';
  return double.tryParse(RegExp(r'-?\d+(\.\d+)?').stringMatch(text) ?? '');
}

DateTime? _readDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  final numeric = int.tryParse(text);
  if (numeric != null) return DateTime.fromMillisecondsSinceEpoch(numeric);
  return DateTime.tryParse(text);
}

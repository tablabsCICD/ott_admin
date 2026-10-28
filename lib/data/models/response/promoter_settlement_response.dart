class PromoterSettlementResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final List<PromoterSettlementItem>? data;

  PromoterSettlementResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory PromoterSettlementResponse.fromJson(Map<String, dynamic> json) {
    List<PromoterSettlementItem> list = [];
    if (json['data'] != null) {
      if (json['data'] is List) {
        list = (json['data'] as List)
            .map((e) => PromoterSettlementItem.fromJson(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
            .toList();
      } else if (json['data'] is Map<String, dynamic>) {
        final dataMap = json['data'] as Map<String, dynamic>;
        final innerList = dataMap['settlements'] ??
            dataMap['content'] ??
            dataMap['items'] ??
            dataMap['list'];
        if (innerList is List) {
          list = innerList
              .map((e) => PromoterSettlementItem.fromJson(
                  e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
              .toList();
        } else {
          list = [PromoterSettlementItem.fromJson(dataMap)];
        }
      }
    } else if (json['settlements'] is List) {
      list = (json['settlements'] as List)
          .map((e) => PromoterSettlementItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return PromoterSettlementResponse(
      success: json['success'] == true ||
          json['status']?.toString().toLowerCase() == 'success',
      message: json['message']?.toString(),
      statusCode: json['statusCode'] is int
          ? json['statusCode']
          : int.tryParse(json['statusCode']?.toString() ?? ''),
      data: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'statusCode': statusCode,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class PromoterSettlementItem {
  final dynamic id;
  final String? batchId;
  final String? settlementDate;
  final double? grossAmount;
  final double? baseAmount;
  final double? promoterRate;
  final double? promoterShare;
  final double? tdsAmount;
  final double? charges;
  final double? netAmount;
  final String? status;
  final String? paymentReference;
  final String? bankName;
  final String? accountNumber;
  final String? periodFrom;
  final String? periodTo;

  PromoterSettlementItem({
    this.id,
    this.batchId,
    this.settlementDate,
    this.grossAmount,
    this.baseAmount,
    this.promoterRate,
    this.promoterShare,
    this.tdsAmount,
    this.charges,
    this.netAmount,
    this.status,
    this.paymentReference,
    this.bankName,
    this.accountNumber,
    this.periodFrom,
    this.periodTo,
  });

  factory PromoterSettlementItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;
    }

    return PromoterSettlementItem(
      id: json['id'] ?? json['settlementId'],
      batchId: json['batchId']?.toString() ??
          json['settlementBatchReference']?.toString() ??
          json['referenceId']?.toString(),
      settlementDate: json['settlementDate']?.toString() ??
          json['date']?.toString() ??
          json['createdDate']?.toString() ??
          json['disbursedAt']?.toString(),
      grossAmount: parseDouble(json['grossAmount'] ??
          json['totalRevenue'] ??
          json['customerPayment']),
      baseAmount: parseDouble(json['baseAmount'] ?? json['baseRevenue']),
      promoterRate: parseDouble(json['promoterRate'] ??
          json['percentage'] ??
          json['rate'] ??
          json['commissionPercentage']),
      promoterShare: parseDouble(json['promoterShare'] ??
          json['commissionEarned'] ??
          json['earnedAmount'] ??
          json['totalShare']),
      tdsAmount: parseDouble(json['tdsAmount'] ?? json['tds']),
      charges: parseDouble(json['charges'] ??
          json['paymentGatewayFee'] ??
          json['transferCharges']),
      netAmount: parseDouble(json['netAmount'] ??
          json['walletAmount'] ??
          json['finalAmount'] ??
          json['amount'] ??
          json['settledAmount']),
      status: json['status']?.toString() ??
          json['settlementStatus']?.toString() ??
          'COMPLETED',
      paymentReference: json['paymentReference']?.toString() ??
          json['utrNumber']?.toString() ??
          json['transactionId']?.toString() ??
          json['txnId']?.toString(),
      bankName: json['bankName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      periodFrom: json['periodFrom']?.toString() ?? json['startDate']?.toString(),
      periodTo: json['periodTo']?.toString() ?? json['endDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'batchId': batchId,
        'settlementDate': settlementDate,
        'grossAmount': grossAmount,
        'baseAmount': baseAmount,
        'promoterRate': promoterRate,
        'promoterShare': promoterShare,
        'tdsAmount': tdsAmount,
        'charges': charges,
        'netAmount': netAmount,
        'status': status,
        'paymentReference': paymentReference,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'periodFrom': periodFrom,
        'periodTo': periodTo,
      };
}

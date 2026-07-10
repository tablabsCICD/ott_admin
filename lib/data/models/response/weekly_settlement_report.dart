class WeeklySettlementReportResponse {
  final bool success;
  final String? message;
  final WeeklySettlementReportData? data;
  final int? statusCode;

  WeeklySettlementReportResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory WeeklySettlementReportResponse.fromJson(Map<String, dynamic> json) {
    return WeeklySettlementReportResponse(
      success: json["success"] == true ||
          json["status"]?.toString().toLowerCase() == "success",
      message: json["message"]?.toString(),
      data: json["data"] is Map<String, dynamic>
          ? WeeklySettlementReportData.fromJson(json["data"])
          : null,
      statusCode: _asInt(json["statusCode"]),
    );
  }
}

class WeeklySettlementReportData {
  final Map<String, dynamic> raw;
  final String? transactionId;
  final String? settlementReference;
  final String? title;
  final String? status;
  final String? customerPayment;
  final String? customerPaymentLabel;
  final String? customerName;
  final String? contentTitle;
  final String? currency;
  final String? currencySymbol;
  final String? settlementPeriod;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int? totalTransactions;
  final List<SettlementReportMetric> metrics;
  final List<SettlementReportSection> sections;
  final List<SettlementReportFlexibleBlock> promoterCards;
  final List<SettlementReportFlexibleBlock> finalSummary;

  WeeklySettlementReportData({
    required this.raw,
    this.transactionId,
    this.settlementReference,
    this.title,
    this.status,
    this.customerPayment,
    this.customerPaymentLabel,
    this.customerName,
    this.contentTitle,
    this.currency,
    this.currencySymbol,
    this.settlementPeriod,
    this.periodStart,
    this.periodEnd,
    this.totalTransactions,
    required this.metrics,
    required this.sections,
    required this.promoterCards,
    required this.finalSummary,
  });

  factory WeeklySettlementReportData.fromJson(Map<String, dynamic> json) {
    final metrics = _asMapList(json["metrics"])
        .map(SettlementReportMetric.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return WeeklySettlementReportData(
      raw: Map<String, dynamic>.from(json),
      transactionId: _firstText(json, const [
        "transactionId",
        "transactionID",
        "settlementId",
        "settlementID",
      ]),
      settlementReference: _firstText(json, const [
        "settlementReference",
        "settlementRef",
        "reference",
        "settlementId",
        "transactionId",
        "id",
      ]),
      title: json["title"]?.toString(),
      status: _firstText(json, const [
            "settlementStatus",
            "settlement_status",
            "paymentStatus",
            "status",
          ]) ??
          _firstNestedText(json, const [
            "settlement",
            "settlementPeriod",
            "settlementInfo",
            "settlementInformation",
            "settlementDetails",
          ], const [
            "status",
            "settlementStatus",
            "settlement_status",
            "paymentStatus",
          ]),
      customerPayment: json["customerPayment"]?.toString(),
      customerPaymentLabel: json["customerPaymentLabel"]?.toString(),
      customerName: json["customerName"]?.toString(),
      contentTitle: json["contentTitle"]?.toString(),
      currency: _firstText(json, const ["currency", "currencyCode"]),
      currencySymbol: _firstText(json, const ["currencySymbol", "symbol"]),
      settlementPeriod: _settlementPeriodText(json),
      periodStart: _firstDateFromSources(json, const [
        "periodStart",
        "startDate",
        "fromDate",
        "settlementStartDate",
      ]),
      periodEnd: _firstDateFromSources(json, const [
        "periodEnd",
        "endDate",
        "toDate",
        "settlementEndDate",
      ]),
      totalTransactions: _firstInt(json, const [
        "totalTransactions",
        "transactionCount",
        "transactions",
      ]),
      metrics: metrics,
      sections: _asMapList(json["sections"])
          .map(SettlementReportSection.fromJson)
          .toList(),
      promoterCards: _asMapList(json["promoterCards"])
          .map(SettlementReportFlexibleBlock.fromJson)
          .toList(),
      finalSummary: _asMapList(json["finalSummary"])
          .map(SettlementReportFlexibleBlock.fromJson)
          .toList(),
    );
  }

  String get displayCurrencySymbol {
    final symbol = currencySymbol?.trim();
    if (symbol != null && symbol.isNotEmpty) {
      return symbol.replaceAll("Rs.", "\u20B9").replaceAll("Rs", "\u20B9");
    }
    final code = currency?.trim().toUpperCase();
    if (code == null || code == "INR" || code == "RUPEE") return "\u20B9";
    return code;
  }

  String? amountTextFor(List<String> terms) {
    final metric = metrics.cast<SettlementReportMetric?>().firstWhere(
          (metric) => metric != null && _matchesAny(metric.searchText, terms),
          orElse: () => null,
        );
    if (metric != null) return metric.amount;

    for (final section in sections) {
      for (final row in section.rows) {
        if (_matchesAny("${section.title} ${section.code} ${row.label}", terms)) {
          return row.amount;
        }
      }
    }

    for (final block in [...promoterCards, ...finalSummary]) {
      for (final entry in block.displayEntries) {
        if (_matchesAny("${block.title} ${entry.key}", terms)) {
          return entry.value?.toString();
        }
      }
    }
    return null;
  }

  double amountFor(List<String> terms) => _asDouble(amountTextFor(terms));

  List<SettlementReportRow> rowsFor(List<String> terms) {
    return sections
        .where((section) => _matchesAny("${section.title} ${section.code}", terms))
        .expand((section) => section.rows)
        .toList();
  }

  SettlementBeneficiary beneficiaryFromSection({
    required String title,
    required List<String> sectionTerms,
    required List<String> grossTerms,
    required List<String> finalTerms,
  }) {
    final rows = rowsFor(sectionTerms);
    return SettlementBeneficiary(
      title: title,
      sharePercentage: _findRowValue(rows, const ["share", "percentage", "%"]),
      grossAmount: _findRowValue(rows, grossTerms),
      tds: _findRowValue(rows, const ["tds"]),
      payoutCharges: _findRowValue(rows, const ["payout", "charge"]),
      finalPayout: _findRowValue(rows, finalTerms),
      extraRows: rows,
    );
  }

  List<SettlementBeneficiary> get promoterBeneficiaries {
    return promoterCards
        .map(SettlementBeneficiary.fromBlock)
        .where((beneficiary) => !beneficiary.isFinanciallyEmpty)
        .toList();
  }

  SettlementBeneficiary get mediaHouseBeneficiary {
    return beneficiaryFromSection(
      title: "Media House",
      sectionTerms: const ["media", "production", "house"],
      grossTerms: const ["gross"],
      finalTerms: const ["final", "payout", "bank"],
    );
  }

  SettlementBeneficiary get platformBeneficiary {
    return beneficiaryFromSection(
      title: "Platform",
      sectionTerms: const ["platform"],
      grossTerms: const ["gross", "revenue"],
      finalTerms: const ["final", "revenue", "bank"],
    );
  }
}

class SettlementReportMetric {
  final String code;
  final String label;
  final String amount;
  final String icon;
  final int displayOrder;

  SettlementReportMetric({
    required this.code,
    required this.label,
    required this.amount,
    required this.icon,
    required this.displayOrder,
  });

  factory SettlementReportMetric.fromJson(Map<String, dynamic> json) {
    return SettlementReportMetric(
      code: json["code"]?.toString() ?? "",
      label: json["label"]?.toString() ?? "Metric",
      amount: json["amount"]?.toString() ?? "N/A",
      icon: json["icon"]?.toString() ?? "",
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
    );
  }

  String get searchText => "$code $label";
}

class SettlementReportSection {
  final String code;
  final String title;
  final List<SettlementReportRow> rows;

  SettlementReportSection({
    required this.code,
    required this.title,
    required this.rows,
  });

  factory SettlementReportSection.fromJson(Map<String, dynamic> json) {
    return SettlementReportSection(
      code: json["code"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "Settlement Details",
      rows: _asMapList(json["rows"]).map(SettlementReportRow.fromJson).toList(),
    );
  }
}

class SettlementReportRow {
  final String label;
  final String formula;
  final String amount;

  SettlementReportRow({
    required this.label,
    required this.formula,
    required this.amount,
  });

  factory SettlementReportRow.fromJson(Map<String, dynamic> json) {
    return SettlementReportRow(
      label: json["label"]?.toString() ?? "Detail",
      formula: json["formula"]?.toString() ?? "",
      amount: json["amount"]?.toString() ?? "N/A",
    );
  }
}

class SettlementReportFlexibleBlock {
  final String title;
  final Map<String, dynamic> values;

  SettlementReportFlexibleBlock({
    required this.title,
    required this.values,
  });

  factory SettlementReportFlexibleBlock.fromJson(Map<String, dynamic> json) {
    return SettlementReportFlexibleBlock(
      title: (json["title"] ?? json["label"] ?? json["name"] ?? "Summary")
          .toString(),
      values: Map<String, dynamic>.from(json),
    );
  }

  List<MapEntry<String, dynamic>> get displayEntries {
    const hiddenKeys = {
      "title",
      "label",
      "name",
      "code",
      "displayOrder",
      "formula",
    };
    return values.entries
        .where((entry) => !hiddenKeys.contains(entry.key))
        .where((entry) => !entry.key.toLowerCase().contains("formula"))
        .toList();
  }
}

class SettlementBeneficiary {
  final String title;
  final String? sharePercentage;
  final String? grossAmount;
  final String? tds;
  final String? payoutCharges;
  final String? finalPayout;
  final List<SettlementReportRow> extraRows;

  SettlementBeneficiary({
    required this.title,
    this.sharePercentage,
    this.grossAmount,
    this.tds,
    this.payoutCharges,
    this.finalPayout,
    this.extraRows = const [],
  });

  factory SettlementBeneficiary.fromBlock(SettlementReportFlexibleBlock block) {
    String? valueFor(List<List<String>> candidates) {
      MapEntry<String, dynamic>? entry;
      for (final terms in candidates) {
        entry = block.displayEntries.cast<MapEntry<String, dynamic>?>().firstWhere(
              (entry) => entry != null && _matchesAll(entry.key, terms),
              orElse: () => null,
            );
        if (entry != null) break;
      }
      return entry?.value?.toString();
    }

    return SettlementBeneficiary(
      title: block.title,
      sharePercentage: valueFor(const [
        ["share", "percentage"],
        ["percentage"],
        ["%"],
      ]),
      grossAmount: valueFor(const [
        ["gross"],
      ]),
      tds: valueFor(const [
        ["tds"],
      ]),
      payoutCharges: valueFor(const [
        ["payout", "charge"],
        ["payout", "fee"],
      ]),
      finalPayout: valueFor(const [
        ["final", "payout"],
        ["bank", "amount"],
        ["final"],
      ]),
    );
  }

  bool get isFinanciallyEmpty {
    final values = [sharePercentage, grossAmount, tds, payoutCharges, finalPayout];
    return values.every((value) => _asDouble(value) == 0);
  }
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }
  return [];
}

String? _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final rawValue = json[key];
    if (rawValue is Map || rawValue is List) continue;
    final value = rawValue?.toString().trim();
    final normalized = value?.toLowerCase();
    if (value != null &&
        value.isNotEmpty &&
        normalized != "n/a" &&
        normalized != "null") {
      return value;
    }
  }
  return null;
}

String? _firstNestedText(
  Map<String, dynamic> json,
  List<String> parentKeys,
  List<String> keys,
) {
  for (final parentKey in parentKeys) {
    final nested = _asStringMap(json[parentKey]);
    if (nested == null) continue;
    final value = _firstText(nested, keys);
    if (value != null) return value;
  }
  return null;
}

int? _firstInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _asInt(json[key]);
    if (value != null) return value;
  }
  return null;
}

DateTime? _firstDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final parsed = DateTime.tryParse(json[key]?.toString() ?? "");
    if (parsed != null) return parsed;
  }
  return null;
}

DateTime? _firstDateFromSources(Map<String, dynamic> json, List<String> keys) {
  final direct = _firstDate(json, keys);
  if (direct != null) return direct;

  const nestedKeys = [
    "settlementPeriod",
    "settlement",
    "period",
    "dateRange",
    "settlementInfo",
    "settlementInformation",
    "settlementDetails",
  ];
  for (final nestedKey in nestedKeys) {
    final nested = _asStringMap(json[nestedKey]);
    if (nested == null) continue;
    final parsed = _firstDate(nested, keys);
    if (parsed != null) return parsed;
  }
  return null;
}

String? _settlementPeriodText(Map<String, dynamic> json) {
  final direct = _firstText(json, const [
    "settlementPeriod",
    "settlement",
    "period",
    "dateRange",
  ]);
  if (direct != null) return direct;

  const nestedKeys = [
    "settlementPeriod",
    "period",
    "dateRange",
    "settlementInfo",
    "settlementInformation",
    "settlementDetails",
  ];
  for (final nestedKey in nestedKeys) {
    final nested = _asStringMap(json[nestedKey]);
    if (nested == null) continue;
    final from = _firstText(nested, const [
      "fromDate",
      "periodStart",
      "startDate",
      "settlementStartDate",
    ]);
    final to = _firstText(nested, const [
      "toDate",
      "periodEnd",
      "endDate",
      "settlementEndDate",
    ]);
    if (from != null && to != null) return "$from - $to";
  }
  return null;
}

Map<String, dynamic>? _asStringMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _findRowValue(List<SettlementReportRow> rows, List<String> terms) {
  final strictRow = rows.cast<SettlementReportRow?>().firstWhere(
        (row) => row != null && _matchesAll(row.label, terms),
        orElse: () => null,
      );
  if (strictRow != null) return strictRow.amount;

  final row = rows.cast<SettlementReportRow?>().firstWhere(
    (row) => row != null && _matchesAny(row.label, terms),
    orElse: () => null,
  );
  return row?.amount;
}

bool _matchesAny(String text, List<String> terms) {
  final normalized = text.toLowerCase();
  return terms.any((term) => normalized.contains(term.toLowerCase()));
}

bool _matchesAll(String text, List<String> terms) {
  final normalized = text.toLowerCase();
  return terms.every((term) => normalized.contains(term.toLowerCase()));
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "");
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  final text = value
          ?.toString()
          .replaceAll(",", "")
          .replaceAll("\u20B9", "")
          .replaceAll("Rs.", "")
          .replaceAll("Rs", "")
          .replaceAll("%", "")
          .trim() ??
      "";
  return double.tryParse(RegExp(r"-?\d+(\.\d+)?").stringMatch(text) ?? "") ?? 0;
}

class TransactionSettlementReportResponse {
  final bool success;
  final String? message;
  final int? statusCode;
  final TransactionSettlementReportData? data;

  TransactionSettlementReportResponse({
    required this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory TransactionSettlementReportResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionSettlementReportResponse(
      success: json["success"] == true ||
          json["status"]?.toString().toLowerCase() == "success",
      message: json["message"]?.toString(),
      statusCode: _asInt(json["statusCode"]),
      data: json["data"] is Map<String, dynamic>
          ? TransactionSettlementReportData.fromJson(json["data"])
          : null,
    );
  }
}

class TransactionSettlementReportData {
  final Map<String, dynamic> raw;
  final String? transactionId;
  final String? transactionTitle;
  final String? customerName;
  final String? contentTitle;
  final String? customerPayment;
  final String? status;
  final String? currency;
  final String? currencySymbol;
  final List<TransactionSettlementMetric> metrics;
  final List<TransactionSettlementSection> sections;
  final List<TransactionPromoterSettlement> promoterCards;
  final List<TransactionSettlementSummaryItem> finalSummary;

  TransactionSettlementReportData({
    required this.raw,
    this.transactionId,
    this.transactionTitle,
    this.customerName,
    this.contentTitle,
    this.customerPayment,
    this.status,
    this.currency,
    this.currencySymbol,
    required this.metrics,
    required this.sections,
    required this.promoterCards,
    required this.finalSummary,
  });

  factory TransactionSettlementReportData.fromJson(Map<String, dynamic> json) {
    final metrics = _asMapList(json["metrics"])
        .map(TransactionSettlementMetric.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return TransactionSettlementReportData(
      raw: Map<String, dynamic>.from(json),
      transactionId: _firstText(json, const [
        "transactionId",
        "transactionID",
        "id",
      ]),
      transactionTitle: _firstText(json, const [
        "transactionTitle",
        "title",
        "transactionName",
      ]),
      customerName: _firstText(json, const [
        "customerName",
        "userName",
        "name",
      ]),
      contentTitle: _firstText(json, const [
        "contentTitle",
        "movieTitle",
        "contentName",
      ]),
      customerPayment: _firstText(json, const [
        "customerPayment",
        "customerCollection",
        "paymentAmount",
      ]),
      status: _firstText(json, const ["status", "transactionStatus"]),
      currency: _firstText(json, const ["currency", "currencyCode"]),
      currencySymbol: _firstText(json, const ["currencySymbol", "symbol"]),
      metrics: metrics,
      sections: _asMapList(json["sections"])
          .map(TransactionSettlementSection.fromJson)
          .toList(),
      promoterCards: _asMapList(json["promoterCards"])
          .map(TransactionPromoterSettlement.fromJson)
          .toList(),
      finalSummary: _asMapList(json["finalSummary"])
          .map(TransactionSettlementSummaryItem.fromJson)
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
    final metric = metrics.cast<TransactionSettlementMetric?>().firstWhere(
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

    for (final summary in finalSummary) {
      if (_matchesAny("${summary.title} ${summary.label}", terms)) {
        return summary.amount;
      }
    }
    return null;
  }

  double amountFor(List<String> terms) => _asDouble(amountTextFor(terms));

  List<TransactionSettlementRow> rowsFor(List<String> terms) {
    return sections
        .where((section) => _matchesAny("${section.title} ${section.code}", terms))
        .expand((section) => section.rows)
        .toList();
  }

  TransactionProductionSettlement get productionSettlement {
    final rows = rowsFor(const ["production", "house", "media"]);
    return TransactionProductionSettlement(
      grossAmount: _findRowValue(rows, const ["gross"]),
      tds: _findRowValue(rows, const ["tds"]),
      afterTds: _findRowValue(rows, const ["after", "tds"]),
      payoutCharges: _findRowValue(rows, const ["payout", "charge"]),
      finalAmount: _findRowValue(rows, const ["final"]),
    );
  }

  TransactionPlatformSettlement get platformSettlement {
    final rows = rowsFor(const ["platform"]);
    return TransactionPlatformSettlement(
      platformGross: _findRowValue(rows, const ["gross"]),
      promoterAllocation: _findRowValue(rows, const ["promoter"]),
      platformFinal: _findRowValue(rows, const ["final"]),
    );
  }
}

class TransactionSettlementMetric {
  final String code;
  final String label;
  final String amount;
  final String icon;
  final int displayOrder;

  TransactionSettlementMetric({
    required this.code,
    required this.label,
    required this.amount,
    required this.icon,
    required this.displayOrder,
  });

  factory TransactionSettlementMetric.fromJson(Map<String, dynamic> json) {
    return TransactionSettlementMetric(
      code: json["code"]?.toString() ?? "",
      label: json["label"]?.toString() ?? "Metric",
      amount: json["amount"]?.toString() ?? "N/A",
      icon: json["icon"]?.toString() ?? "",
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
    );
  }

  String get searchText => "$code $label";
}

class TransactionSettlementSection {
  final String code;
  final String title;
  final List<TransactionSettlementRow> rows;

  TransactionSettlementSection({
    required this.code,
    required this.title,
    required this.rows,
  });

  factory TransactionSettlementSection.fromJson(Map<String, dynamic> json) {
    return TransactionSettlementSection(
      code: json["code"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "Settlement Details",
      rows:
          _asMapList(json["rows"]).map(TransactionSettlementRow.fromJson).toList(),
    );
  }
}

class TransactionSettlementRow {
  final String label;
  final String formula;
  final String amount;

  TransactionSettlementRow({
    required this.label,
    required this.formula,
    required this.amount,
  });

  factory TransactionSettlementRow.fromJson(Map<String, dynamic> json) {
    return TransactionSettlementRow(
      label: json["label"]?.toString() ?? "Detail",
      formula: json["formula"]?.toString() ?? "",
      amount: json["amount"]?.toString() ?? "N/A",
    );
  }
}

class TransactionProductionSettlement {
  final String? grossAmount;
  final String? tds;
  final String? afterTds;
  final String? payoutCharges;
  final String? finalAmount;

  TransactionProductionSettlement({
    this.grossAmount,
    this.tds,
    this.afterTds,
    this.payoutCharges,
    this.finalAmount,
  });
}

class TransactionPlatformSettlement {
  final String? platformGross;
  final String? promoterAllocation;
  final String? platformFinal;

  TransactionPlatformSettlement({
    this.platformGross,
    this.promoterAllocation,
    this.platformFinal,
  });
}

class TransactionPromoterSettlement {
  final String promoterLevel;
  final String? percentage;
  final String? grossAmount;
  final String? tds;
  final String? payoutCharges;
  final String? finalAmount;
  final String? badge;

  TransactionPromoterSettlement({
    required this.promoterLevel,
    this.percentage,
    this.grossAmount,
    this.tds,
    this.payoutCharges,
    this.finalAmount,
    this.badge,
  });

  factory TransactionPromoterSettlement.fromJson(Map<String, dynamic> json) {
    String? valueFor(List<List<String>> candidates) {
      for (final terms in candidates) {
        final entry = json.entries.cast<MapEntry<String, dynamic>?>().firstWhere(
              (entry) => entry != null && _matchesAll(entry.key, terms),
              orElse: () => null,
            );
        if (entry != null) return entry.value?.toString();
      }
      return null;
    }

    return TransactionPromoterSettlement(
      promoterLevel: _firstText(json, const [
            "promoterLevel",
            "level",
            "title",
            "name",
          ]) ??
          "Promoter",
      percentage: valueFor(const [
        ["percentage"],
        ["share"],
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
      finalAmount: valueFor(const [
        ["final", "amount"],
        ["final", "payout"],
        ["bank", "amount"],
        ["final"],
      ]),
      badge: _firstText(json, const ["badge", "status", "tag"]),
    );
  }
}

class TransactionSettlementSummaryItem {
  final String title;
  final String label;
  final String amount;
  final String? badge;

  TransactionSettlementSummaryItem({
    required this.title,
    required this.label,
    required this.amount,
    this.badge,
  });

  factory TransactionSettlementSummaryItem.fromJson(Map<String, dynamic> json) {
    return TransactionSettlementSummaryItem(
      title: (json["title"] ?? json["stakeholder"] ?? json["name"] ?? "Summary")
          .toString(),
      label: (json["label"] ?? json["stakeholder"] ?? json["name"] ?? "Summary")
          .toString(),
      amount: _firstText(json, const [
            "amount",
            "bankAmount",
            "finalAmount",
            "finalPayoutAmount",
            "value",
          ]) ??
          "0",
      badge: _firstText(json, const ["badge", "status", "tag"]),
    );
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
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

String? _findRowValue(List<TransactionSettlementRow> rows, List<String> terms) {
  final strictRow = rows.cast<TransactionSettlementRow?>().firstWhere(
        (row) => row != null && _matchesAll(row.label, terms),
        orElse: () => null,
      );
  if (strictRow != null) return strictRow.amount;

  final row = rows.cast<TransactionSettlementRow?>().firstWhere(
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

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
  final String? title;
  final String? settlementBatchReference;
  final String? settlementStatus;
  final SettlementPeriodModel? settlementPeriod;
  final String? reportType;
  final String? beneficiary;
  final String? currencySymbol;
  final List<SummaryCardModel> summaryCards;
  final SettlementPurchaseSummaryModel? settlementPurchaseSummary;
  final List<SettlementSectionModel> sections;
  final List<BeneficiarySettlementModel> beneficiarySettlementSummary;
  final TaxAndChargeSummaryModel? taxAndChargeSummary;
  final List<FinalSummaryItemModel> finalSummary;

  WeeklySettlementReportData({
    this.title,
    this.settlementBatchReference,
    this.settlementStatus,
    this.settlementPeriod,
    this.reportType,
    this.beneficiary,
    this.currencySymbol,
    required this.summaryCards,
    this.settlementPurchaseSummary,
    required this.sections,
    required this.beneficiarySettlementSummary,
    this.taxAndChargeSummary,
    required this.finalSummary,
  });

  factory WeeklySettlementReportData.fromJson(Map<String, dynamic> json) {
    final rawSummaryCards = _asMapList(json["summaryCards"])
        .map(SummaryCardModel.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final rawSections = _asMapList(json["sections"])
        .map(SettlementSectionModel.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final rawBeneficiaries = _asMapList(json["beneficiarySettlementSummary"])
        .map(BeneficiarySettlementModel.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final rawFinalSummary = _asMapList(json["finalSummary"])
        .map(FinalSummaryItemModel.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    SettlementPeriodModel? period;
    if (json["settlementPeriod"] is Map<String, dynamic>) {
      period = SettlementPeriodModel.fromJson(json["settlementPeriod"]);
    }

    SettlementPurchaseSummaryModel? purchaseSummary;
    if (json["settlementPurchaseSummary"] is Map<String, dynamic>) {
      purchaseSummary = SettlementPurchaseSummaryModel.fromJson(
        json["settlementPurchaseSummary"],
      );
    }

    TaxAndChargeSummaryModel? taxAndCharges;
    if (json["taxAndChargeSummary"] is Map<String, dynamic>) {
      taxAndCharges = TaxAndChargeSummaryModel.fromJson(
        json["taxAndChargeSummary"],
      );
    }

    return WeeklySettlementReportData(
      title: json["title"]?.toString(),
      settlementBatchReference: _firstText(json, const [
        "settlementBatchReference",
        "batchReference",
        "reference",
        "settlementReference",
        "transactionId",
      ]),
      settlementStatus: _firstText(json, const [
        "settlementStatus",
        "status",
        "paymentStatus",
      ]),
      settlementPeriod: period,
      reportType: json["reportType"]?.toString(),
      beneficiary: json["beneficiary"]?.toString(),
      currencySymbol: _firstText(json, const ["currencySymbol", "symbol", "currency"]),
      summaryCards: rawSummaryCards,
      settlementPurchaseSummary: purchaseSummary,
      sections: rawSections,
      beneficiarySettlementSummary: rawBeneficiaries,
      taxAndChargeSummary: taxAndCharges,
      finalSummary: rawFinalSummary,
    );
  }

  String get fallbackSymbol {
    final sym = currencySymbol?.trim();
    if (sym != null && sym.isNotEmpty) {
      return sym.replaceAll("Rs.", "₹").replaceAll("Rs", "₹");
    }
    return "₹";
  }
}

class SettlementPeriodModel {
  final dynamic fromDate;
  final dynamic toDate;

  SettlementPeriodModel({this.fromDate, this.toDate});

  factory SettlementPeriodModel.fromJson(Map<String, dynamic> json) {
    return SettlementPeriodModel(
      fromDate: json["fromDate"] ?? json["startDate"] ?? json["from"],
      toDate: json["toDate"] ?? json["endDate"] ?? json["to"],
    );
  }

  String get formattedPeriod {
    final fromStr = _formatAnyDate(fromDate);
    final toStr = _formatAnyDate(toDate);
    if (fromStr != null && toStr != null) return "$fromStr – $toStr";
    if (fromStr != null) return fromStr;
    if (toStr != null) return toStr;
    return "—";
  }
}

class SummaryCardModel {
  final String label;
  final String amount;
  final String? code;
  final String? icon;
  final int displayOrder;

  SummaryCardModel({
    required this.label,
    required this.amount,
    this.code,
    this.icon,
    required this.displayOrder,
  });

  factory SummaryCardModel.fromJson(Map<String, dynamic> json) {
    return SummaryCardModel(
      label: json["label"]?.toString() ?? "Summary",
      amount: _formatRawAmount(json["amount"]),
      code: json["code"]?.toString(),
      icon: json["icon"]?.toString(),
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
    );
  }
}

class SettlementPurchaseSummaryModel {
  final dynamic totalTransactions;
  final dynamic successfulTransactions;
  final dynamic failedTransactions;
  final dynamic refundedTransactions;
  final dynamic totalContentCount;
  final dynamic totalCustomerPayment;

  SettlementPurchaseSummaryModel({
    this.totalTransactions,
    this.successfulTransactions,
    this.failedTransactions,
    this.refundedTransactions,
    this.totalContentCount,
    this.totalCustomerPayment,
  });

  factory SettlementPurchaseSummaryModel.fromJson(Map<String, dynamic> json) {
    return SettlementPurchaseSummaryModel(
      totalTransactions: json["totalTransactions"] ?? json["transactionsCount"] ?? 0,
      successfulTransactions: json["successfulTransactions"] ?? json["successCount"] ?? 0,
      failedTransactions: json["failedTransactions"] ?? json["failedCount"] ?? 0,
      refundedTransactions: json["refundedTransactions"] ?? json["refundedCount"] ?? 0,
      totalContentCount: json["totalContentCount"] ?? json["contentCount"] ?? 0,
      totalCustomerPayment: _formatRawAmount(json["totalCustomerPayment"]),
    );
  }
}

class SettlementSectionModel {
  final String? code;
  final String title;
  final String? icon;
  final int displayOrder;
  final List<SettlementRowModel> rows;

  SettlementSectionModel({
    this.code,
    required this.title,
    this.icon,
    required this.displayOrder,
    required this.rows,
  });

  factory SettlementSectionModel.fromJson(Map<String, dynamic> json) {
    final rawRows = _asMapList(json["rows"])
        .map(SettlementRowModel.fromJson)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return SettlementSectionModel(
      code: json["code"]?.toString(),
      title: json["title"]?.toString() ?? "Section Details",
      icon: json["icon"]?.toString(),
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
      rows: rawRows,
    );
  }
}

class SettlementRowModel {
  final String label;
  final String? formula;
  final String amount;
  final int displayOrder;

  SettlementRowModel({
    required this.label,
    this.formula,
    required this.amount,
    required this.displayOrder,
  });

  factory SettlementRowModel.fromJson(Map<String, dynamic> json) {
    return SettlementRowModel(
      label: json["label"]?.toString() ?? "Detail",
      formula: json["formula"]?.toString(),
      amount: _formatRawAmount(json["amount"]),
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
    );
  }
}

class BeneficiarySettlementModel {
  final String? beneficiaryName;
  final String? beneficiaryType;
  final String? promoterLevel;
  final dynamic percentage;
  final dynamic gross;
  final dynamic tds;
  final dynamic afterTds;
  final dynamic payoutCharge;
  final dynamic finalAmount;
  final dynamic promoterAllocation;
  final dynamic roundingDifference;
  final int displayOrder;

  BeneficiarySettlementModel({
    this.beneficiaryName,
    this.beneficiaryType,
    this.promoterLevel,
    this.percentage,
    this.gross,
    this.tds,
    this.afterTds,
    this.payoutCharge,
    this.finalAmount,
    this.promoterAllocation,
    this.roundingDifference,
    required this.displayOrder,
  });

  factory BeneficiarySettlementModel.fromJson(Map<String, dynamic> json) {
    return BeneficiarySettlementModel(
      beneficiaryName: json["beneficiaryName"]?.toString(),
      beneficiaryType: json["beneficiaryType"]?.toString(),
      promoterLevel: json["promoterLevel"]?.toString(),
      percentage: json["percentage"],
      gross: _formatRawAmount(json["gross"]),
      tds: _formatRawAmount(json["tds"]),
      afterTds: _formatRawAmount(json["afterTds"]),
      payoutCharge: _formatRawAmount(json["payoutCharge"]),
      finalAmount: _formatRawAmount(json["finalAmount"]),
      promoterAllocation: json["promoterAllocation"] != null
          ? _formatRawAmount(json["promoterAllocation"])
          : null,
      roundingDifference: json["roundingDifference"] != null
          ? _formatRawAmount(json["roundingDifference"])
          : null,
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
    );
  }

  String get formattedBeneficiaryType {
    return _enumToTitleCase(beneficiaryType);
  }

  String get formattedPromoterLevel {
    return _enumToTitleCase(promoterLevel);
  }

  String get formattedPercentage {
    if (percentage == null) return "—";
    if (percentage is num) {
      final val = (percentage as num).toDouble();
      if (val == 0) return "0%";
      if (val % 1 == 0) return "${val.toInt()}%";
      return "$val%";
    }
    final text = percentage.toString().trim();
    if (text.isEmpty || text == "null") return "—";
    return text.endsWith("%") ? text : "$text%";
  }
}

class TaxAndChargeSummaryModel {
  final dynamic gstIncluded;
  final dynamic razorpayCollectionFee;
  final dynamic mediaHouseTds;
  final dynamic mediaHousePayoutCharge;
  final dynamic promoterTds;
  final dynamic promoterPayoutCharge;
  final dynamic totalTds;
  final dynamic totalPayoutCharge;

  TaxAndChargeSummaryModel({
    this.gstIncluded,
    this.razorpayCollectionFee,
    this.mediaHouseTds,
    this.mediaHousePayoutCharge,
    this.promoterTds,
    this.promoterPayoutCharge,
    this.totalTds,
    this.totalPayoutCharge,
  });

  factory TaxAndChargeSummaryModel.fromJson(Map<String, dynamic> json) {
    return TaxAndChargeSummaryModel(
      gstIncluded: _formatRawAmount(json["gstIncluded"] ?? json["gst"]),
      razorpayCollectionFee: _formatRawAmount(json["razorpayCollectionFee"] ?? json["razorpayFee"]),
      mediaHouseTds: _formatRawAmount(json["mediaHouseTds"]),
      mediaHousePayoutCharge: _formatRawAmount(json["mediaHousePayoutCharge"]),
      promoterTds: _formatRawAmount(json["promoterTds"]),
      promoterPayoutCharge: _formatRawAmount(json["promoterPayoutCharge"]),
      totalTds: _formatRawAmount(json["totalTds"]),
      totalPayoutCharge: _formatRawAmount(json["totalPayoutCharge"]),
    );
  }
}

class FinalSummaryItemModel {
  final String label;
  final String amount;
  final String? icon;
  final int displayOrder;

  FinalSummaryItemModel({
    required this.label,
    required this.amount,
    this.icon,
    required this.displayOrder,
  });

  factory FinalSummaryItemModel.fromJson(Map<String, dynamic> json) {
    return FinalSummaryItemModel(
      label: json["label"]?.toString() ?? "Final Summary",
      amount: _formatRawAmount(json["amount"]),
      icon: json["icon"]?.toString(),
      displayOrder: _asInt(json["displayOrder"]) ?? 999,
    );
  }
}

// Helpers
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
    if (value != null && value.isNotEmpty && value != "null") {
      return value;
    }
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "");
}

String _formatRawAmount(dynamic value) {
  if (value == null) return "—";
  if (value is num) {
    return value.toString();
  }
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == "null") return "—";
  return text;
}

String? _formatAnyDate(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(value);
      return "${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}";
    } catch (_) {}
  }
  final str = value.toString().trim();
  if (str.isEmpty || str == "null") return null;
  final epoch = int.tryParse(str);
  if (epoch != null) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
      return "${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}";
    } catch (_) {}
  }
  return str;
}

String _monthName(int month) {
  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  if (month >= 1 && month <= 12) return months[month - 1];
  return "";
}

String _enumToTitleCase(String? value) {
  if (value == null || value.trim().isEmpty) return "—";
  final text = value.trim();
  if (text.toUpperCase() == "MEDIA_HOUSE") return "Media House";
  if (text.toUpperCase() == "PROMOTER") return "Promoter";
  if (text.toUpperCase() == "ADMIN") return "Admin";
  if (text.toUpperCase() == "WEEKLY_SETTLEMENT") return "Weekly Settlement";

  return text
      .replaceAll("_", " ")
      .toLowerCase()
      .split(" ")
      .map((word) => word.isNotEmpty
          ? "${word[0].toUpperCase()}${word.substring(1)}"
          : "")
      .join(" ");
}

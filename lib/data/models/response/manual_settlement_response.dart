class ManualSettlementResponse {
  final String? message;
  final int? statusCode;
  final bool? success;
  final ManualSettlementData? data;

  const ManualSettlementResponse({
    this.message,
    this.statusCode,
    this.success,
    this.data,
  });

  factory ManualSettlementResponse.fromJson(Map<String, dynamic> json) {
    return ManualSettlementResponse(
      message: json['message'] as String?,
      statusCode: _parseInt(json['statusCode']),
      success: json['success'] as bool?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ManualSettlementData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class ManualSettlementData {
  final int? settlementHistoriesUpserted;
  final String? scheduledSettlementDay;
  final int? processedMediaHouseCount;
  final bool? includeUserOnboardingSettlement;
  final int? requestedMediaHouseId;
  final String? settlementWindowEndDate;
  final bool? userOnboardingSettlementSkipped;
  final bool? includeSettlementHistory;
  final String? settlementWindowStartDate;
  final String? scheduledSettlementTime;
  final String? scheduledSettlementTimezone;
  final String? nextScheduledSettlementAt;
  final bool? includeContentSettlement;
  final String? triggerType;

  const ManualSettlementData({
    this.settlementHistoriesUpserted,
    this.scheduledSettlementDay,
    this.processedMediaHouseCount,
    this.includeUserOnboardingSettlement,
    this.requestedMediaHouseId,
    this.settlementWindowEndDate,
    this.userOnboardingSettlementSkipped,
    this.includeSettlementHistory,
    this.settlementWindowStartDate,
    this.scheduledSettlementTime,
    this.scheduledSettlementTimezone,
    this.nextScheduledSettlementAt,
    this.includeContentSettlement,
    this.triggerType,
  });

  factory ManualSettlementData.fromJson(Map<String, dynamic> json) {
    return ManualSettlementData(
      settlementHistoriesUpserted: _parseInt(json['settlementHistoriesUpserted']),
      scheduledSettlementDay: json['scheduledSettlementDay'] as String?,
      processedMediaHouseCount: _parseInt(json['processedMediaHouseCount']),
      includeUserOnboardingSettlement:
          json['includeUserOnboardingSettlement'] as bool?,
      requestedMediaHouseId: _parseInt(json['requestedMediaHouseId']),
      settlementWindowEndDate: json['settlementWindowEndDate'] as String?,
      userOnboardingSettlementSkipped:
          json['userOnboardingSettlementSkipped'] as bool?,
      includeSettlementHistory: json['includeSettlementHistory'] as bool?,
      settlementWindowStartDate: json['settlementWindowStartDate'] as String?,
      scheduledSettlementTime: json['scheduledSettlementTime'] as String?,
      scheduledSettlementTimezone:
          json['scheduledSettlementTimezone'] as String?,
      nextScheduledSettlementAt: json['nextScheduledSettlementAt'] as String?,
      includeContentSettlement: json['includeContentSettlement'] as bool?,
      triggerType: json['triggerType'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

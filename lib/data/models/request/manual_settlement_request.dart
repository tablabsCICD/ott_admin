class ManualSettlementRequest {
  final String startDate;
  final String endDate;
  final int? mediaHouseId;
  final bool includeContentSettlement;
  final bool includeUserOnboardingSettlement;
  final bool includeSettlementHistory;

  const ManualSettlementRequest({
    required this.startDate,
    required this.endDate,
    this.mediaHouseId,
    this.includeContentSettlement = true,
    this.includeUserOnboardingSettlement = false,
    this.includeSettlementHistory = true,
  });

  Map<String, dynamic> toJson() {
    return {
      "startDate": startDate,
      "endDate": endDate,
      "mediaHouseId": mediaHouseId,
      "includeContentSettlement": includeContentSettlement,
      "includeUserOnboardingSettlement": includeUserOnboardingSettlement,
      "includeSettlementHistory": includeSettlementHistory,
    };
  }
}

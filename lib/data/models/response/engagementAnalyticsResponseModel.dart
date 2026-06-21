class EngagementAnalyticsResponseModel {
  EngagementAnalyticsResponseModel({
    this.success = false,
    this.data,
    this.message,
  });

  final bool success;
  final EngagementAnalyticsDataModel? data;
  final String? message;

  factory EngagementAnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return EngagementAnalyticsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: data is Map<String, dynamic>
          ? EngagementAnalyticsDataModel.fromJson(data)
          : null,
    );
  }
}

class EngagementAnalyticsDataModel {
  EngagementAnalyticsDataModel({
    required this.likes,
    required this.shares,
    required this.comments,
    required this.watchlistAdds,
    required this.downloads,
    required this.completionRate,
    required this.dropOffRate,
    required this.peakHours,
  });

  final int likes;
  final int shares;
  final int comments;
  final int watchlistAdds;
  final int downloads;
  final double completionRate;
  final double dropOffRate;
  final List<PeakHourAnalyticsModel> peakHours;

  factory EngagementAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return EngagementAnalyticsDataModel(
      likes: _asInt(json["likes"]) ?? 0,
      shares: _asInt(json["shares"]) ?? 0,
      comments: _asInt(json["comments"]) ?? 0,
      watchlistAdds: _asInt(json["watchlistAdds"]) ?? 0,
      downloads: _asInt(json["downloads"]) ?? 0,
      completionRate: _asDouble(json["completionRate"]) ?? 0,
      dropOffRate: _asDouble(json["dropOffRate"]) ?? 0,
      peakHours: _asList(json["peakHours"])
          .whereType<Map<String, dynamic>>()
          .map(PeakHourAnalyticsModel.fromJson)
          .toList(),
    );
  }
}

class PeakHourAnalyticsModel {
  PeakHourAnalyticsModel({
    required this.hour,
    required this.activeUsers,
  });

  final String hour;
  final int activeUsers;

  factory PeakHourAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final rawHour = json["hour"]?.toString().trim() ?? "";
    return PeakHourAnalyticsModel(
      hour: rawHour.isEmpty ? "Unknown" : rawHour,
      activeUsers: _asInt(json["activeUsers"]) ?? 0,
    );
  }
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

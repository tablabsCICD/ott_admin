class AgeWiseRevenueResponseModel {
  AgeWiseRevenueResponseModel({
    this.success = false,
    this.data = const [],
    this.message,
  });

  final bool success;
  final List<AgeWiseRevenueDataModel> data;
  final String? message;

  factory AgeWiseRevenueResponseModel.fromJson(Map<String, dynamic> json) {
    final rows = json["data"];
    return AgeWiseRevenueResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: rows is List
          ? rows
              .whereType<Map<String, dynamic>>()
              .map(AgeWiseRevenueDataModel.fromJson)
              .toList()
          : const [],
    );
  }
}

class AgeWiseRevenueDataModel {
  AgeWiseRevenueDataModel({
    required this.ageGroup,
    required this.users,
    required this.revenue,
    required this.subscriptionRevenue,
    required this.coinRevenue,
    required this.avgWatchTime,
    required this.retentionRate,
  });

  final String ageGroup;
  final int users;
  final double revenue;
  final double subscriptionRevenue;
  final double coinRevenue;
  final double avgWatchTime;
  final double retentionRate;

  factory AgeWiseRevenueDataModel.fromJson(Map<String, dynamic> json) {
    return AgeWiseRevenueDataModel(
      ageGroup: normalizeAgeGroup(json["ageGroup"]),
      users: _asInt(json["users"]) ?? 0,
      revenue: _asDouble(json["revenue"]) ?? 0,
      subscriptionRevenue: _asDouble(json["subscriptionRevenue"]) ?? 0,
      coinRevenue: _asDouble(json["coinRevenue"]) ?? 0,
      avgWatchTime: _asDouble(json["avgWatchTime"]) ?? 0,
      retentionRate: _asDouble(json["retentionRate"]) ?? 0,
    );
  }
}

class AgeWiseViewsResponseModel {
  AgeWiseViewsResponseModel({
    this.success = false,
    this.data = const [],
    this.message,
  });

  final bool success;
  final List<AgeWiseViewsDataModel> data;
  final String? message;

  factory AgeWiseViewsResponseModel.fromJson(Map<String, dynamic> json) {
    final rows = json["data"];
    return AgeWiseViewsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: rows is List
          ? rows
              .whereType<Map<String, dynamic>>()
              .map(AgeWiseViewsDataModel.fromJson)
              .toList()
          : const [],
    );
  }
}

class AgeWiseViewsDataModel {
  AgeWiseViewsDataModel({
    required this.ageGroup,
    required this.views,
    required this.uniqueUsers,
    required this.watchHours,
    required this.completionRate,
    required this.rewatchRate,
  });

  final String ageGroup;
  final int views;
  final int uniqueUsers;
  final double watchHours;
  final double completionRate;
  final double rewatchRate;

  factory AgeWiseViewsDataModel.fromJson(Map<String, dynamic> json) {
    return AgeWiseViewsDataModel(
      ageGroup: normalizeAgeGroup(json["ageGroup"]),
      views: _asInt(json["views"]) ?? 0,
      uniqueUsers: _asInt(json["uniqueUsers"]) ?? 0,
      watchHours: _asDouble(json["watchHours"]) ?? 0,
      completionRate: _asDouble(json["completionRate"]) ?? 0,
      rewatchRate: _asDouble(json["rewatchRate"]) ?? 0,
    );
  }
}

String normalizeAgeGroup(dynamic value) {
  final raw = value?.toString().trim() ?? "";
  if (raw.isEmpty || raw.toLowerCase() == "null") return "Unknown";
  final normalized = raw.replaceAll(" ", "");
  switch (normalized) {
    case "13-17":
    case "13-18":
      return "13-18";
    case "18-24":
    case "25-34":
    case "35-44":
      return normalized;
    case "45-54":
    case "45-60":
      return "45-60";
    case "55+":
    case "60+":
      return "60+";
    default:
      return raw;
  }
}

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

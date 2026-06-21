class DateWiseAnalyticsResponseModel {
  DateWiseAnalyticsResponseModel({
    this.success = false,
    this.data = const [],
    this.message,
  });

  final bool success;
  final List<DateWiseAnalyticsDataModel> data;
  final String? message;

  factory DateWiseAnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    final rows = json["data"];
    return DateWiseAnalyticsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: rows is List
          ? rows
              .whereType<Map<String, dynamic>>()
              .map(DateWiseAnalyticsDataModel.fromJson)
              .toList()
          : const [],
    );
  }
}

class DateWiseAnalyticsDataModel {
  DateWiseAnalyticsDataModel({
    required this.date,
    required this.revenue,
    required this.views,
    required this.watchHours,
    required this.activeUsers,
    required this.newSubscribers,
  });

  final DateTime? date;
  final double revenue;
  final int views;
  final double watchHours;
  final int activeUsers;
  final int newSubscribers;

  factory DateWiseAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return DateWiseAnalyticsDataModel(
      date: DateTime.tryParse(json["date"]?.toString() ?? ""),
      revenue: _asDouble(json["revenue"]) ?? 0,
      views: _asInt(json["views"]) ?? 0,
      watchHours: _asDouble(json["watchHours"]) ?? 0,
      activeUsers: _asInt(json["activeUsers"]) ?? 0,
      newSubscribers: _asInt(json["newSubscribers"]) ?? 0,
    );
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

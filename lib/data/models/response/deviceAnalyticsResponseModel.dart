class DeviceAnalyticsResponseModel {
  DeviceAnalyticsResponseModel({
    this.success = false,
    this.data = const [],
    this.message,
  });

  final bool success;
  final List<DeviceAnalyticsDataModel> data;
  final String? message;

  factory DeviceAnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    final rows = json["data"];
    return DeviceAnalyticsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: rows is List
          ? rows
              .whereType<Map<String, dynamic>>()
              .map(DeviceAnalyticsDataModel.fromJson)
              .toList()
          : const [],
    );
  }
}

class DeviceAnalyticsDataModel {
  DeviceAnalyticsDataModel({
    required this.device,
    required this.users,
    required this.revenue,
    required this.watchHours,
    required this.avgSessionTime,
  });

  final String device;
  final int users;
  final double revenue;
  final double watchHours;
  final double avgSessionTime;

  factory DeviceAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return DeviceAnalyticsDataModel(
      device: normalizeDeviceName(json["device"]),
      users: _asInt(json["users"]) ?? 0,
      revenue: _asDouble(json["revenue"]) ?? 0,
      watchHours: _asDouble(json["watchHours"]) ?? 0,
      avgSessionTime: _asDouble(json["avgSessionTime"]) ?? 0,
    );
  }
}

String normalizeDeviceName(dynamic value) {
  final raw = value?.toString().trim() ?? "";
  if (raw.isEmpty || raw.toLowerCase() == "null") return "Unknown";
  final normalized = raw.toLowerCase().replaceAll(RegExp(r"[\s_-]+"), "");
  switch (normalized) {
    case "android":
      return "Android";
    case "ios":
    case "iphone":
    case "ipad":
      return "iOS";
    case "web":
    case "browser":
      return "Web";
    case "tv":
    case "smarttv":
    case "androidtv":
      return "Smart TV";
    case "tablet":
      return "Tablet";
    case "unknown":
      return "Unknown";
    default:
      return raw
          .split(" ")
          .map((part) => part.isEmpty
              ? part
              : part[0].toUpperCase() + part.substring(1).toLowerCase())
          .join(" ");
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

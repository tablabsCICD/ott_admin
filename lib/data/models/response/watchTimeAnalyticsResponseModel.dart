class WatchTimeAnalyticsResponseModel {
  WatchTimeAnalyticsResponseModel({
    this.success = false,
    this.data,
    this.message,
  });

  final bool success;
  final WatchTimeAnalyticsDataModel? data;
  final String? message;

  factory WatchTimeAnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return WatchTimeAnalyticsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: data is Map<String, dynamic>
          ? WatchTimeAnalyticsDataModel.fromJson(data)
          : null,
    );
  }
}

class WatchTimeAnalyticsDataModel {
  WatchTimeAnalyticsDataModel({
    required this.totalWatchHours,
    required this.avgWatchTime,
    required this.byAge,
    required this.byLocation,
    required this.byDevice,
  });

  final double totalWatchHours;
  final double avgWatchTime;
  final List<WatchTimeAgeModel> byAge;
  final List<WatchTimeLocationModel> byLocation;
  final List<WatchTimeDeviceModel> byDevice;

  factory WatchTimeAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return WatchTimeAnalyticsDataModel(
      totalWatchHours: _asDouble(json["totalWatchHours"]) ?? 0,
      avgWatchTime: _asDouble(json["avgWatchTime"]) ?? 0,
      byAge: _asList(json["byAge"])
          .whereType<Map<String, dynamic>>()
          .map(WatchTimeAgeModel.fromJson)
          .toList(),
      byLocation: _asList(json["byLocation"])
          .whereType<Map<String, dynamic>>()
          .map(WatchTimeLocationModel.fromJson)
          .toList(),
      byDevice: _asList(json["byDevice"])
          .whereType<Map<String, dynamic>>()
          .map(WatchTimeDeviceModel.fromJson)
          .toList(),
    );
  }
}

class WatchTimeAgeModel {
  WatchTimeAgeModel({
    required this.ageGroup,
    required this.watchHours,
  });

  final String ageGroup;
  final double watchHours;

  factory WatchTimeAgeModel.fromJson(Map<String, dynamic> json) {
    return WatchTimeAgeModel(
      ageGroup: _normalizeAge(json["ageGroup"] ?? json["age"]),
      watchHours: _asDouble(json["watchHours"] ?? json["totalWatchHours"]) ?? 0,
    );
  }
}

class WatchTimeLocationModel {
  WatchTimeLocationModel({
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.watchHours,
    required this.avgWatchTime,
  });

  final String country;
  final String state;
  final String district;
  final String city;
  final double watchHours;
  final double avgWatchTime;

  factory WatchTimeLocationModel.fromJson(Map<String, dynamic> json) {
    return WatchTimeLocationModel(
      country: _normalizeLocation(json["country"]),
      state: _normalizeLocation(json["state"]),
      district: _normalizeLocation(json["district"] ?? json["taluka"]),
      city: _normalizeLocation(json["city"]),
      watchHours: _asDouble(json["watchHours"] ?? json["totalWatchHours"]) ?? 0,
      avgWatchTime: _asDouble(json["avgWatchTime"]) ?? 0,
    );
  }
}

class WatchTimeDeviceModel {
  WatchTimeDeviceModel({
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

  factory WatchTimeDeviceModel.fromJson(Map<String, dynamic> json) {
    return WatchTimeDeviceModel(
      device: _normalizeDevice(json["device"]),
      users: _asInt(json["users"]) ?? 0,
      revenue: _asDouble(json["revenue"]) ?? 0,
      watchHours: _asDouble(json["watchHours"] ?? json["totalWatchHours"]) ?? 0,
      avgSessionTime: _asDouble(json["avgSessionTime"]) ?? 0,
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

String _normalizeAge(dynamic value) {
  final raw = value?.toString().trim() ?? "";
  if (raw.isEmpty || raw.toLowerCase() == "null") return "Unknown";
  return raw;
}

String _normalizeLocation(dynamic value) {
  final raw = value?.toString().trim() ?? "";
  if (raw.isEmpty || raw.toLowerCase() == "null") return "Unknown";
  final normalized = raw.replaceAll(RegExp(r"\s+"), " ");
  final compact = normalized.toLowerCase().replaceAll(" ", "");
  if (compact == "ahilyanagar") return "Ahilya Nagar";
  return normalized.split(" ").map((part) {
    if (part.isEmpty) return part;
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  }).join(" ");
}

String _normalizeDevice(dynamic value) {
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

class LocationAnalyticsResponseModel {
  LocationAnalyticsResponseModel({
    this.success = false,
    this.data = const [],
    this.message,
  });

  final bool success;
  final List<LocationAnalyticsDataModel> data;
  final String? message;

  factory LocationAnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    final rows = json["data"];
    return LocationAnalyticsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: rows is List
          ? rows
              .whereType<Map<String, dynamic>>()
              .map(LocationAnalyticsDataModel.fromJson)
              .toList()
          : const [],
    );
  }
}

class LocationAnalyticsDataModel {
  LocationAnalyticsDataModel({
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.totalUsers,
    required this.paidUsers,
    required this.views,
    required this.watchHours,
    required this.revenue,
    required this.completionRate,
  });

  final String country;
  final String state;
  final String district;
  final String city;
  final int totalUsers;
  final int paidUsers;
  final int views;
  final int watchHours;
  final double revenue;
  final double completionRate;

  factory LocationAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return LocationAnalyticsDataModel(
      country: normalizeCountry(json["country"]),
      state: normalizeState(json["state"]),
      district: normalizeDistrict(json["district"]),
      city: normalizeCity(json["city"]),
      totalUsers: _asInt(json["totalUsers"]) ?? 0,
      paidUsers: _asInt(json["paidUsers"]) ?? 0,
      views: _asInt(json["views"]) ?? 0,
      watchHours: _asInt(json["watchHours"]) ?? 0,
      revenue: _asDouble(json["revenue"]) ?? 0,
      completionRate: _asDouble(json["completionRate"]) ?? 0,
    );
  }

  static String normalizeCountry(dynamic value) => _normalizeLocation(value);

  static String normalizeState(dynamic value) => _normalizeLocation(value);

  static String normalizeDistrict(dynamic value) {
    final normalized = _normalizeLocation(value);
    if (normalized.toLowerCase().replaceAll(" ", "") == "ahilyanagar") {
      return "Ahilya Nagar";
    }
    return normalized;
  }

  static String normalizeCity(dynamic value) {
    final normalized = _normalizeLocation(value);
    if (normalized.toLowerCase().replaceAll(" ", "") == "ahilyanagar") {
      return "Ahilya Nagar";
    }
    return normalized;
  }

  static String _normalizeLocation(dynamic value) {
    final raw = value?.toString().trim() ?? "";
    if (raw.isEmpty || raw.toLowerCase() == "null") return "Unknown";
    return raw.replaceAll(RegExp(r"\s+"), " ").split(" ").map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join(" ");
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

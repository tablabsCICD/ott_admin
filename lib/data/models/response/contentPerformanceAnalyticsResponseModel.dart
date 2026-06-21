class ContentPerformanceAnalyticsResponseModel {
  ContentPerformanceAnalyticsResponseModel({
    this.success = false,
    this.data,
    this.message,
  });

  final bool success;
  final ContentPerformanceAnalyticsDataModel? data;
  final String? message;

  factory ContentPerformanceAnalyticsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json["data"];
    return ContentPerformanceAnalyticsResponseModel(
      success: json["success"] == true,
      message: json["message"]?.toString(),
      data: data is Map<String, dynamic>
          ? ContentPerformanceAnalyticsDataModel.fromJson(data)
          : null,
    );
  }
}

class ContentPerformanceAnalyticsDataModel {
  ContentPerformanceAnalyticsDataModel({
    required this.totalViews,
    required this.totalRevenue,
    required this.engagementScore,
    required this.completionRate,
    required this.bounceRate,
    required this.retentionRate,
    required this.rewatchRate,
    required this.topSeries,
    required this.topEpisodes,
  });

  final int totalViews;
  final double totalRevenue;
  final double engagementScore;
  final double completionRate;
  final double bounceRate;
  final double retentionRate;
  final double rewatchRate;
  final List<TopSeriesPerformanceModel> topSeries;
  final List<TopEpisodePerformanceModel> topEpisodes;

  factory ContentPerformanceAnalyticsDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentPerformanceAnalyticsDataModel(
      totalViews: _asInt(json["totalViews"]) ?? 0,
      totalRevenue: _asDouble(json["totalRevenue"]) ?? 0,
      engagementScore: _asDouble(json["engagementScore"]) ?? 0,
      completionRate: _asDouble(json["completionRate"]) ?? 0,
      bounceRate: _asDouble(json["bounceRate"]) ?? 0,
      retentionRate: _asDouble(json["retentionRate"]) ?? 0,
      rewatchRate: _asDouble(json["rewatchRate"]) ?? 0,
      topSeries: _asList(json["topSeries"])
          .whereType<Map<String, dynamic>>()
          .map(TopSeriesPerformanceModel.fromJson)
          .toList(),
      topEpisodes: _asList(json["topEpisodes"])
          .whereType<Map<String, dynamic>>()
          .map(TopEpisodePerformanceModel.fromJson)
          .toList(),
    );
  }
}

class TopSeriesPerformanceModel {
  TopSeriesPerformanceModel({
    required this.contentId,
    required this.title,
    required this.views,
  });

  final int contentId;
  final String title;
  final int views;

  factory TopSeriesPerformanceModel.fromJson(Map<String, dynamic> json) {
    return TopSeriesPerformanceModel(
      contentId: _asInt(json["contentId"]) ?? 0,
      title: _cleanTitle(json["title"]),
      views: _asInt(json["views"]) ?? 0,
    );
  }
}

class TopEpisodePerformanceModel {
  TopEpisodePerformanceModel({
    required this.episodeId,
    required this.title,
    required this.views,
  });

  final int episodeId;
  final String title;
  final int views;

  factory TopEpisodePerformanceModel.fromJson(Map<String, dynamic> json) {
    return TopEpisodePerformanceModel(
      episodeId: _asInt(json["episodeId"]) ?? 0,
      title: _cleanTitle(json["title"]),
      views: _asInt(json["views"]) ?? 0,
    );
  }
}

String _cleanTitle(dynamic value) {
  final raw = value?.toString().trim() ?? "";
  return raw.isEmpty ? "Untitled" : raw;
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

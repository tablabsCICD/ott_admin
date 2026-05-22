enum RevenueAudienceScope {
  india('INDIA'),
  overseas('OVERSEAS');

  const RevenueAudienceScope(this.apiValue);

  final String apiValue;

  static RevenueAudienceScope fromApi(String? value) {
    return RevenueAudienceScope.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => RevenueAudienceScope.india,
    );
  }
}

enum RevenueContentType {
  movies('MOVIES'),
  series('SERIES'),
  shorts('SHORTS');

  const RevenueContentType(this.apiValue);

  final String apiValue;

  static RevenueContentType fromApi(String? value) {
    return RevenueContentType.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => RevenueContentType.movies,
    );
  }
}

class RevenueShareRule {
  final int? id;
  final double adminPercentage;
  final RevenueAudienceScope audienceScope;
  final RevenueContentType contentType;
  final DateTime? effectiveFrom;
  final bool isActive;
  final double mediaHousePercentage;
  final String remarks;

  const RevenueShareRule({
    this.id,
    required this.adminPercentage,
    required this.audienceScope,
    required this.contentType,
    required this.effectiveFrom,
    required this.isActive,
    required this.mediaHousePercentage,
    required this.remarks,
  });

  factory RevenueShareRule.fromJson(Map<String, dynamic> json) {
    return RevenueShareRule(
      id: _asInt(json['id'] ?? json['ruleId'] ?? json['revenueShareRuleId']),
      adminPercentage: _asDouble(json['adminPercentage']),
      audienceScope:
          RevenueAudienceScope.fromApi(json['audienceScope']?.toString()),
      contentType: RevenueContentType.fromApi(json['contentType']?.toString()),
      effectiveFrom: _asDateTime(json['effectiveFrom']),
      isActive: _asBool(json['isActive'] ?? json['active']) ?? false,
      mediaHousePercentage: _asDouble(json['mediaHousePercentage']),
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'adminPercentage': adminPercentage,
      'audienceScope': audienceScope.apiValue,
      'contentType': contentType.apiValue,
      'effectiveFrom': effectiveFrom?.toUtc().toIso8601String(),
      'isActive': isActive,
      'mediaHousePercentage': mediaHousePercentage,
      'remarks': remarks,
    };
  }

  bool matches(String query) {
    final text = [
      audienceScope.apiValue,
      contentType.apiValue,
      remarks,
      adminPercentage.toString(),
      mediaHousePercentage.toString(),
    ].join(' ').toLowerCase();
    return text.contains(query.trim().toLowerCase());
  }
}

class RegistrationFeeRule {
  final int? id;
  final RevenueAudienceScope audienceScope;
  final RevenueContentType contentType;
  final DateTime? effectiveFrom;
  final bool isActive;
  final double registrationFee;
  final String remarks;

  const RegistrationFeeRule({
    this.id,
    required this.audienceScope,
    required this.contentType,
    required this.effectiveFrom,
    required this.isActive,
    required this.registrationFee,
    required this.remarks,
  });

  factory RegistrationFeeRule.fromJson(Map<String, dynamic> json) {
    return RegistrationFeeRule(
      id: _asInt(json['id'] ?? json['ruleId'] ?? json['registrationFeeRuleId']),
      audienceScope:
          RevenueAudienceScope.fromApi(json['audienceScope']?.toString()),
      contentType: RevenueContentType.fromApi(json['contentType']?.toString()),
      effectiveFrom: _asDateTime(json['effectiveFrom']),
      isActive: _asBool(json['isActive'] ?? json['active']) ?? false,
      registrationFee: _asDouble(json['registrationFee']),
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'audienceScope': audienceScope.apiValue,
      'contentType': contentType.apiValue,
      'effectiveFrom': effectiveFrom?.toUtc().toIso8601String(),
      'isActive': isActive,
      'registrationFee': registrationFee,
      'remarks': remarks,
    };
  }

  bool matches(String query) {
    final text = [
      audienceScope.apiValue,
      contentType.apiValue,
      remarks,
      registrationFee.toString(),
    ].join(' ').toLowerCase();
    return text.contains(query.trim().toLowerCase());
  }
}

List<Map<String, dynamic>> extractListPayload(Map<String, dynamic> json) {
  final dynamic raw = json['data'] ??
      json['revenueShareRules'] ??
      json['registrationFeeRules'] ??
      json['rules'] ??
      json['content'] ??
      json;
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is Map) {
    final nested = raw['revenueShareRules'] ??
        raw['registrationFeeRules'] ??
        raw['content'] ??
        raw['rules'] ??
        raw['items'] ??
        raw['data'];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    for (final value in raw.values) {
      if (value is List && value.whereType<Map>().isNotEmpty) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
  }
  return const [];
}

String responseMessage(Map<String, dynamic> json, String fallback) {
  return json['message']?.toString() ?? fallback;
}

bool responseSuccess(Map<String, dynamic> json) {
  return json['success'] == true || json['status'] == true;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  final text = value?.toString().toLowerCase();
  if (text == 'true') return true;
  if (text == 'false') return false;
  return null;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return DateTime.tryParse(value.toString());
}

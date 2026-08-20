import 'dart:convert';
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/domain/entities/cast_crew.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CastRepository {
  final ApiHelper _apiHelper;

  CastRepository({ApiHelper? apiHelper})
      : _apiHelper = apiHelper ?? ApiHelper();

  /// Fetches Cast & Crew members based on the content type and parameters.
  ///
  /// Content Type API Mapping:
  /// - MOVIE: GET /api/Cast/getByContentId?contentId={contentId}
  /// - SERIES: GET /api/Cast/getByContentIdAndSeasonId?contentId={contentId}&seasonId={seasonId}
  /// - MINI SERIES: GET /api/Cast/getByShortId?shortId={shortId}
  /// - SHORT FILM: GET /api/Cast/getByContentId?contentId={contentId}
  Future<List<Cast>> getCastForContent({
    required String contentType,
    required dynamic contentId,
    dynamic seasonId,
    dynamic shortId,
  }) async {
    final normType = contentType.trim().toUpperCase();
    String url;

    if (normType == 'SERIES') {
      if (seasonId != null && seasonId != 0 && seasonId.toString() != '0') {
        url = ApiConstant.getCastByContentIdAndSeasonId(contentId, seasonId);
      } else {
        url = ApiConstant.getCastByContentId(contentId);
      }
    } else if (normType == 'MINI_SERIES' ||
        normType == 'MINI SERIES' ||
        normType == 'SHORTS') {
      final sId =
          (shortId != null && shortId.toString().isNotEmpty) ? shortId : contentId;
      url = ApiConstant.getCastByShortId(sId);
    } else if (normType == 'SHORT_FILM' || normType == 'SHORT FILM') {
      url = ApiConstant.getCastByContentId(contentId);
    } else {
      url = ApiConstant.getCastByContentId(contentId);
    }

    try {
      final response = await _apiHelper.getApi(url);
      if (response is http.Response) {
        return _parseCastList(response.body);
      } else if (response != null) {
        return _parseCastList(response);
      }
    } catch (e) {
      debugPrint("Error fetching cast from $url: $e");
      rethrow;
    }
    return [];
  }

  List<Cast> _parseCastList(dynamic body) {
    dynamic decoded = body;
    if (body is String) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {}
    }

    dynamic rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map) {
      final data = decoded['data'] ??
          decoded['castList'] ??
          decoded['cast'] ??
          decoded['casts'];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        final inner = data['castList'] ?? data['cast'] ?? data['items'];
        if (inner is List) rawList = inner;
      }
    }

    if (rawList is List) {
      return rawList
          .map((item) {
            if (item is Map<String, dynamic>) {
              return Cast.fromJson(item);
            } else if (item is Map) {
              return Cast.fromJson(Map<String, dynamic>.from(item));
            }
            return null;
          })
          .whereType<Cast>()
          .toList();
    }
    return [];
  }
}

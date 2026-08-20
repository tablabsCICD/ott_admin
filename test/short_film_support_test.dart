import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/data/models/response/admin_settings_models.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SHORT_FILM support', () {
    test('content response parses totalPurchase safely', () {
      expect(Content.fromJson({'totalPurchase': 125}).totalPurchase, 125);
      expect(Content.fromJson({'totalPurchase': null}).totalPurchase, isNull);
      expect(Content.fromJson({}).totalPurchase, isNull);
      expect(Content.fromJson({'totalPurchase': '8'}).toJson()['totalPurchase'],
          8);
    });

    test('content response accepts contentType and preserves the API value', () {
      final content = Content.fromJson({
        'id': 101,
        'title': 'A Short Film',
        'contentType': 'SHORT_FILM',
      });

      expect(content.type, 'SHORT_FILM');
      expect(content.toJson()['type'], 'SHORT_FILM');
      expect(formatContentTypeLabel(content.type), 'Short Film');
      expect(isMovieLike(content.type), isTrue);
    });

    test('unknown and null response types are safe', () {
      expect(formatContentTypeLabel(null), '-');
      expect(formatContentTypeLabel('FUTURE_TYPE'), 'FUTURE_TYPE');
      expect(isMovieLike(null), isFalse);
    });

    test('admin settings sends exact backend content type values', () {
      expect(RevenueContentType.movie.apiValue, 'MOVIE');
      expect(RevenueContentType.series.apiValue, 'SERIES');
      expect(RevenueContentType.miniSeries.apiValue, 'MINI_SERIES');
      expect(RevenueContentType.shortFilm.apiValue, 'SHORT_FILM');
      expect(RevenueContentType.fromApi('SHORT_FILM'),
          RevenueContentType.shortFilm);
      expect(RevenueContentType.fromApi('SHORTS'),
          RevenueContentType.miniSeries);
    });

    test('analytics URLs preserve SHORT_FILM query parameters', () {
      final topContentUrl = ApiConstant.topRevenueContentGraph(
        '2026-01-01',
        '2026-01-31',
        false,
        true,
        false,
        contentType: 'SHORT_FILM',
      );
      final reportUrl = ApiConstant.reportAndDataMediaHouse(
        contentType: 'SHORT_FILM',
        country: '',
        state: '',
        district: '',
        taluka: '',
        city: '',
        startDate: '',
        endDate: '',
        ageGroup: 'ALL',
        gender: 'ALL',
      );

      expect(Uri.parse(topContentUrl).queryParameters['contentType'],
          'SHORT_FILM');
      expect(Uri.parse(reportUrl).queryParameters['contentType'],
          'SHORT_FILM');
    });
  });
}

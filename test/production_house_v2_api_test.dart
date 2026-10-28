import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/widgets/financial_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Production House V2 API Endpoint Tests', () {
    test('1. Production House Profile V2 URL and Alias', () {
      final v2Url = ApiConstant.mediaHouseProfileV2(42);
      final aliasUrl = ApiConstant.mediaHouseProfileV2Alias(42);

      expect(v2Url, contains('/api/v2/mediaHouse/getMediaHouseById/42'));
      expect(aliasUrl, contains('/api/MediaHouse/getById?id=42'));
    });

    test('2. Video Catalog by Media House V2 URL and Alias', () {
      final v2Url = ApiConstant.videoByMediaHouseV2(101);
      final aliasUrl = ApiConstant.videoByMediaHouseV2Alias(101);

      expect(v2Url, contains('/api/v2/video/getVideoByMediaHouseId/101'));
      expect(aliasUrl, contains('/api/content/byMediaHouse?mediaHouseId=101'));
    });

    test('3. Shorts / Mini Series by Media House V2 URL and Alias', () {
      final v2Url = ApiConstant.shortsByMediaHouseV2(88);
      final aliasUrl = ApiConstant.shortsByMediaHouseV2Alias(88);

      expect(v2Url, contains('/api/v2/shorts/by-media-house/88'));
      expect(aliasUrl, contains('/api/shortsMaster/by-mediahouse/88'));
    });

    test('4. Dashboard Count V2 URL and Alias', () {
      final v2Url = ApiConstant.mediaHouseDashboardCountV2(42);
      final aliasUrl = ApiConstant.mediaHouseDashboardCountV2Alias(42);

      expect(v2Url, contains('/api/v2/mediaHouse/getMediaHouseDashboardCountForAdmin/42'));
      expect(aliasUrl, contains('/api/admin/mediaHouseDashboardApi?mediaHouseId=42'));
    });

    test('5. Revenue Graph V2 URL with Date Range and Type', () {
      final url = ApiConstant.mediaHouseRevenueGraphV2(
        15,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
        type: 'MOVIE',
      );
      final aliasUrl = ApiConstant.revenueGraphByMediaHouse(
        4,
        '2026-09-14',
        '2026-09-21',
        false,
        false,
        true,
        type: 'ALL',
      );

      expect(url, contains('/api/v2/mediaHouse/revenueGraphByMediaHouse'));
      expect(url, contains('mediaId=15'));
      expect(url, contains('startDate=2026-01-01'));
      expect(url, contains('endDate=2026-01-31'));
      expect(url, contains('type=MOVIE'));

      expect(aliasUrl, contains('/api/mediaHouseLineCharts/top-revenue-content-by-media-house'));
      expect(aliasUrl, contains('mediaHouseId=4'));
      expect(aliasUrl, contains('type=ALL'));
    });

    test('6. Scoped Financial Transactions V2 URL', () {
      final url = ApiConstant.mediaHouseTransactionsV2(
        50,
        page: 0,
        size: 20,
        startDate: '2026-02-01',
        endDate: '2026-02-28',
      );

      expect(url, contains('/api/v2/user/movie-transactions-by-media-house/50'));
      expect(url, contains('page=0'));
      expect(url, contains('size=20'));
      expect(url, contains('startDate=2026-02-01'));
      expect(url, contains('endDate=2026-02-28'));
    });

    test('7. Weekly Settlements V2 URL and Alias', () {
      final url = ApiConstant.mediaHouseWeeklySettlementsV2(99);
      final aliasUrl = ApiConstant.mediaHouseWeeklySettlementsV2Alias(99);

      expect(url, contains('/api/v2/settlement/weeklySettelementDataForMediaHouse/99'));
      expect(aliasUrl, contains('/api/settelment/mediaHouse/99'));
    });
  });

  group('Production House Financial Breakdown Precision Tests', () {
    test('Calculates 4-decimal precision values accurately without float drift', () {
      const gross = 1000.0;
      final gst = FinancialFormatter.calculateGst(gross);
      final base = FinancialFormatter.calculateBaseAmount(gross);
      final gw = base * 0.02;
      final net = base - gw;
      final platformRevenue = FinancialFormatter.calculatePlatformRevenue(net);
      final prodGross = FinancialFormatter.calculateProductionGrossRevenue(net);
      final tax = FinancialFormatter.calculateProductionTds(prodGross);
      final payoutFee = (prodGross - tax) * 0.02;
      final finalProdRevenue = prodGross - tax - payoutFee;

      expect(FinancialFormatter.format4(gross), equals('₹ 1,000.0000'));
      expect(FinancialFormatter.format4(gst), isNotEmpty);
      expect(FinancialFormatter.format4(base), isNotEmpty);
      expect(FinancialFormatter.format4(platformRevenue), isNotEmpty);
      expect(FinancialFormatter.format4(prodGross), isNotEmpty);
      expect(FinancialFormatter.format4(finalProdRevenue), isNotEmpty);
    });
  });
}

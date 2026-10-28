import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Graph API Type Parameter URL Tests', () {
    test('1. top-revenue-content-by-media-house contains type parameter', () {
      final url = ApiConstant.topRevenueContentGraphForMediaHouse(
        4,
        '2026-09-14',
        '2026-09-21',
        false,
        false,
        true,
        type: 'Movie',
      );
      expect(url, contains('mediaHouseId=4'));
      expect(url, contains('startDate=2026-09-14'));
      expect(url, contains('endDate=2026-09-21'));
      expect(url, contains('isWeek=true'));
      expect(url, contains('type=Movie'));
    });

    test('2. top-rated-content-by-media-house contains type parameter', () {
      final url = ApiConstant.topRatedContentGraph(
        4,
        '2026-09-14',
        '2026-09-21',
        false,
        true,
        false,
        type: 'Series',
      );
      expect(url, contains('mediaHouseId=4'));
      expect(url, contains('type=Series'));
    });

    test('3. revenueGraphByMediaHouse and V2 alias contain type parameter', () {
      final url1 = ApiConstant.revenueGraphByMediaHouse(
        10,
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'Mini Series',
      );
      final url2 = ApiConstant.mediaHouseRevenueGraphV2(
        10,
        startDate: '2026-01-01',
        endDate: '2026-01-07',
        type: 'Short Film',
      );
      expect(Uri.decodeFull(url1).replaceAll('+', ' '), contains('type=Mini Series'));
      expect(Uri.decodeFull(url2).replaceAll('+', ' '), contains('type=Short Film'));
    });

    test('4. contentRevenueGraph contains type parameter', () {
      final url = ApiConstant.contentRevenueGraph(
        99,
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'Movie',
      );
      expect(url, contains('contentListId=99'));
      expect(url, contains('type=Movie'));
    });

    test('5. releaseMovieCountGraphByMediaHouse and viewCountGraphByMediaHouse contain type parameter', () {
      final releaseUrl = ApiConstant.releaseMovieCountGraphByMediaHouse(
        5,
        '2026-01-01',
        '2026-01-30',
        false,
        true,
        false,
        type: 'Series',
      );
      final viewUrl = ApiConstant.viewCountGraphByMediaHouse(
        5,
        '2026-01-01',
        '2026-01-30',
        false,
        true,
        false,
        type: 'Mini Series',
      );
      expect(releaseUrl, contains('type=Series'));
      expect(viewUrl, contains('type=Mini Series'));
    });

    test('6. adminLineCharts userCount, purchaseCount, approvedContentCount contain type parameter', () {
      final purchaseUrl = ApiConstant.purchaseCountGraph(
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'Short Film',
      );
      final approvalUrl = ApiConstant.approvedContentCountGraph(
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'Movie',
      );
      final userUrl = ApiConstant.userCountGraph(
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'ALL',
      );
      expect(purchaseUrl, contains('type=Short Film'));
      expect(approvalUrl, contains('type=Movie'));
      expect(userUrl, contains('type=ALL'));
    });

    test('7. admin graph allRevenue and transactionRevenueGraph contain type parameter', () {
      final allRevUrl = ApiConstant.allRevenue(
        '2026-01-01',
        '2026-01-07',
        type: 'Series',
      );
      final txnRevUrl = ApiConstant.transactionRevenueGraph(
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'Mini Series',
      );
      expect(allRevUrl, contains('type=Series'));
      expect(txnRevUrl, contains('type=Mini Series'));
    });

    test('8. topRevenueContentGraph supports both contentType and type parameter', () {
      final url = ApiConstant.topRevenueContentGraph(
        '2026-01-01',
        '2026-01-07',
        false,
        false,
        true,
        type: 'Short Film',
      );
      final decoded = Uri.decodeFull(url).replaceAll('+', ' ');
      expect(decoded, contains('type=Short Film'));
      expect(decoded, contains('contentType=Short Film'));
    });

    test('9. promoter onboard revenue graph V2 and alias contain type parameter', () {
      final v2Url = ApiConstant.promoterOnboardRevenueGraphV2(
        12,
        startDate: '2026-01-01',
        endDate: '2026-01-07',
        type: 'Movie',
      );
      final aliasUrl = ApiConstant.promoterOnboardRevenueGraphV2Alias(
        12,
        startDate: '2026-01-01',
        endDate: '2026-01-07',
        type: 'Series',
      );
      expect(v2Url, contains('type=Movie'));
      expect(aliasUrl, contains('type=Series'));
    });
  });
}

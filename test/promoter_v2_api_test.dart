import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/data/models/response/promoter_dashboard_response.dart';
import 'package:admin_ott/data/models/response/promoter_settlement_response.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Promoter V2 API Endpoint URL Tests', () {
    const promoterId = 42;

    test('1. Promoter Profile V2 URL and Alias', () {
      expect(
        ApiConstant.promoterProfileV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/profile',
      );
      expect(
        ApiConstant.promoterProfileV2Alias(promoterId),
        '${ApiConstant.baseUrl}user/getUser/42',
      );
    });

    test('2. Promoter Users V2 URL and Alias', () {
      expect(
        ApiConstant.promoterUsersV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/users',
      );
      expect(
        ApiConstant.promoterUsersV2(promoterId, page: 0, size: 10),
        '${ApiConstant.baseUrl}api/v2/promoters/42/users?page=0&size=10',
      );
      expect(
        ApiConstant.promoterUsersV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/user/getUsersByPromoterId/42',
      );
    });

    test('3. Child Promoters V2 URL and Alias', () {
      expect(
        ApiConstant.childPromotersV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/child-promoters',
      );
      expect(
        ApiConstant.childPromotersV2(promoterId, page: 1, size: 20),
        '${ApiConstant.baseUrl}api/v2/promoters/42/child-promoters?page=1&size=20',
      );
      expect(
        ApiConstant.childPromotersV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/Promoters/getPromotersByPromoterId/42',
      );
    });

    test('4. Onboard & Revenue Graph V2 URL and Alias', () {
      expect(
        ApiConstant.promoterOnboardRevenueGraphV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/onboard-revenue-graph',
      );
      expect(
        ApiConstant.promoterOnboardRevenueGraphV2(
          promoterId,
          startDate: '2026-09-01',
          endDate: '2026-09-18',
        ),
        '${ApiConstant.baseUrl}api/v2/promoters/42/onboard-revenue-graph?start_date=2026-09-01&end_date=2026-09-18',
      );
      expect(
        ApiConstant.promoterOnboardRevenueGraphV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/user/getUserOnboardAndRevenueGraph?promoterId=42',
      );
    });

    test('5. User Movie Transactions V2 URL and Alias', () {
      expect(
        ApiConstant.promoterUserMovieTransactionsV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/user-movie-transactions',
      );
      expect(
        ApiConstant.promoterUserMovieTransactionsV2(promoterId, page: 0, size: 10),
        '${ApiConstant.baseUrl}api/v2/promoters/42/user-movie-transactions?page=0&size=10',
      );
      expect(
        ApiConstant.promoterUserMovieTransactionsV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/user/user_movie_transaction?promoterId=42',
      );
    });

    test('6. Update Promoter Level V2 URL and Alias', () {
      expect(
        ApiConstant.updatePromoterLevelV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/level',
      );
      expect(
        ApiConstant.updatePromoterLevelV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/Promoters/updateLevel/42',
      );
    });

    test('7. Assign Parent Promoter V2 URL and Alias', () {
      expect(
        ApiConstant.assignParentPromoterV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/Promoters/assignParent/42',
      );
      expect(
        ApiConstant.assignParentPromoterV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/parent',
      );
    });

    test('8. Promoter Settlements V2 URL and Alias', () {
      expect(
        ApiConstant.promoterSettlementsV2(promoterId),
        '${ApiConstant.baseUrl}api/v2/promoters/42/settlements',
      );
      expect(
        ApiConstant.promoterSettlementsV2(promoterId, page: 0, size: 10),
        '${ApiConstant.baseUrl}api/v2/promoters/42/settlements?page=0&size=10',
      );
      expect(
        ApiConstant.promoterSettlementsV2Alias(promoterId),
        '${ApiConstant.baseUrl}api/v2/settlement/promoter?promoterId=42',
      );
    });

    test('9. Content Users API URL with pagination', () {
      expect(
        ApiConstant.getUsersByContentId(contentId: 2, page: 0, size: 10),
        '${ApiConstant.baseUrl}api/contentList/getUsersByContentId?contentId=2&page=0&size=10',
      );
    });
  });

  group('Promoter Dashboard API Parsing Tests', () {
    test('Parses full nested promoter dashboard API response (data.dashboard)', () {
      final json = {
        "status": 200,
        "success": true,
        "message": "Dashboard data fetched successfully",
        "data": {
          "promoter": {
            "id": 42,
            "promoterId": 42,
            "promoterName": "Ramesh Patel",
            "mobileNumber": "9876543210",
            "email": "ramesh@example.com",
            "level": "Taluka",
            "designation": "Taluka Promoter",
            "isActive": true
          },
          "dashboard": {
            "totalRevenue": 100000.0,
            "customerPayment": 100000.0,
            "gstCharges": 15254.24,
            "baseAmountAfterGST": 84745.76,
            "platformRevenue": 42372.88,
            "productionHouseRevenue": 42372.88,
            "promoterPercentage": 10.0,
            "promoterRevenue": 8474.58,
            "tax": 847.46,
            "revenueAfterTds": 7627.12,
            "transferCharges": 152.54,
            "finalPromoterRevenue": 7474.58,
            "walletBalance": 5000.0,
            "totalWithdrawn": 2474.58,
            "pendingSettlement": 0.0,
            "totalPurchases": 120,
            "totalViews": 4500,
            "totalLikes": 350,
            "totalContent": 25,
            "totalUsers": 210,
            "totalPromoters": 15
          }
        }
      };

      final response = PromoterDashboardResponse.fromJson(json);
      expect(response.success, true);
      expect(response.data?.promoter?.promoterName, "Ramesh Patel");
      expect(response.data?.dashboard?.customerPayment, 100000.0);
      expect(response.data?.dashboard?.gstCharges, 15254.24);
      expect(response.data?.dashboard?.baseAmountAfterGST, 84745.76);
      expect(response.data?.dashboard?.platformRevenue, 42372.88);
      expect(response.data?.dashboard?.productionHouseRevenue, 42372.88);
      expect(response.data?.dashboard?.promoterPercentage, 10.0);
      expect(response.data?.dashboard?.promoterRevenue, 8474.58);
      expect(response.data?.dashboard?.tax, 847.46);
      expect(response.data?.dashboard?.revenueAfterTds, 7627.12);
      expect(response.data?.dashboard?.transferCharges, 152.54);
      expect(response.data?.dashboard?.finalPromoterRevenue, 7474.58);
      expect(response.data?.dashboard?.walletBalance, 5000.0);
      expect(response.data?.dashboard?.totalWithdrawn, 2474.58);
      expect(response.data?.dashboard?.totalPurchases, 120);
      expect(response.data?.dashboard?.totalViews, 4500);
      expect(response.data?.dashboard?.totalContent, 25);
    });

    test('Parses flat response structure with alias fields gracefully', () {
      final flatJson = {
        "status": 200,
        "success": true,
        "data": {
          "promoterId": 42,
          "promoterName": "Suresh Sharma",
          "grossRevenue": 50000.0,
          "gst": 7627.12,
          "baseRevenue": 42372.88,
          "promoterShare": 4237.28,
          "tdsDeduction": 423.72,
          "netRevenue": 3813.56,
          "bankTransferFee": 76.28,
          "netPayable": 3737.28,
          "wallet": 3000.0,
          "purchases": 50,
          "views": 1200
        }
      };

      final response = PromoterDashboardResponse.fromJson(flatJson);
      expect(response.success, true);
      expect(response.data?.promoter?.promoterName, "Suresh Sharma");
      expect(response.data?.dashboard?.customerPayment, 50000.0);
      expect(response.data?.dashboard?.gstCharges, 7627.12);
      expect(response.data?.dashboard?.baseAmountAfterGST, 42372.88);
      expect(response.data?.dashboard?.promoterRevenue, 4237.28);
      expect(response.data?.dashboard?.tax, 423.72);
      expect(response.data?.dashboard?.finalPromoterRevenue, 3737.28);
      expect(response.data?.dashboard?.totalPurchases, 50);
      expect(response.data?.dashboard?.totalViews, 1200);
    });
  });

  group('Promoter Settlement Response Parsing Tests', () {
    test('Parses standard JSON settlement list format', () {
      final json = {
        "success": true,
        "message": "Settlements retrieved successfully",
        "statusCode": 200,
        "data": [
          {
            "id": 101,
            "batchId": "BATCH-2026-W37",
            "settlementDate": "2026-09-14",
            "grossAmount": 50000.0,
            "baseAmount": 42372.8814,
            "promoterRate": 10.0,
            "promoterShare": 4237.2881,
            "tdsAmount": 423.7288,
            "charges": 76.2712,
            "netAmount": 3737.2881,
            "status": "COMPLETED",
            "paymentReference": "UTR987654321",
            "bankName": "HDFC Bank",
            "accountNumber": "987654321012"
          }
        ]
      };

      final response = PromoterSettlementResponse.fromJson(json);
      expect(response.success, true);
      expect(response.statusCode, 200);
      expect(response.data?.length, 1);

      final item = response.data!.first;
      expect(item.id, 101);
      expect(item.batchId, "BATCH-2026-W37");
      expect(item.settlementDate, "2026-09-14");
      expect(item.grossAmount, 50000.0);
      expect(item.netAmount, 3737.2881);
      expect(item.status, "COMPLETED");
      expect(item.paymentReference, "UTR987654321");
    });
  });

  group('PromoterProvider Hierarchy Validation Tests', () {
    final provider = PromoterProvider();

    test('Validates hierarchy rules correctly', () {
      final nationalPromoter = Promoters(id: 1, level: 'National', promoterName: 'National Admin');
      final statePromoter = Promoters(id: 2, level: 'State', promoterName: 'State Lead');

      // Circular assignment error
      final selfError = provider.validateHierarchyChange(
        promoter: nationalPromoter,
        newLevel: 'National',
        newParentId: 1,
      );
      expect(selfError, isNotNull);
      expect(selfError, contains('A promoter cannot be assigned as their own parent.'));

      // National promoter cannot report to another promoter
      final nationalParentError = provider.validateHierarchyChange(
        promoter: nationalPromoter,
        newLevel: 'National',
        newParentId: 2,
      );
      expect(nationalParentError, isNotNull);
      expect(nationalParentError, contains('National-level promoter cannot have a parent promoter'));

      // Valid State promotion
      final validState = provider.validateHierarchyChange(
        promoter: statePromoter,
        newLevel: 'State',
        newParentId: 1,
      );
      expect(validState, isNull);
    });
  });
}

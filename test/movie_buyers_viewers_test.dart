import 'dart:convert';
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_purchased_users_section.dart';
import 'package:admin_ott/domain/entities/location.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie Buyers & Viewers - Date & Timestamp Handling', () {
    test('Correctly parses numeric timestamp in milliseconds (1789380356000)', () {
      const numericTimestamp = 1789380356000;
      final dt = MovieBuyerDateHelper.parseDateTime(numericTimestamp);
      expect(dt, isNotNull);
      expect(dt!.millisecondsSinceEpoch, equals(numericTimestamp));

      final formatted = MovieBuyerDateHelper.format(numericTimestamp);
      expect(formatted, isNotEmpty);
      expect(formatted, isNot(equals('—')));
    });

    test('Correctly parses numeric timestamp in seconds (1789380356)', () {
      const secondsTimestamp = 1789380356;
      final dt = MovieBuyerDateHelper.parseDateTime(secondsTimestamp);
      expect(dt, isNotNull);
      expect(dt!.millisecondsSinceEpoch, equals(secondsTimestamp * 1000));
    });

    test('Correctly parses String numeric timestamp ("1789380356000")', () {
      const stringTimestamp = "1789380356000";
      final dt = MovieBuyerDateHelper.parseDateTime(stringTimestamp);
      expect(dt, isNotNull);
      expect(dt!.millisecondsSinceEpoch, equals(1789380356000));
    });

    test('Correctly parses ISO-8601 string date', () {
      const isoDate = "2026-09-28T05:50:47.732Z";
      final dt = MovieBuyerDateHelper.parseDateTime(isoDate);
      expect(dt, isNotNull);
      expect(dt!.year, equals(2026));
      expect(dt.month, equals(9));
      expect(dt.day, equals(28));
    });

    test('Handles null, empty, or invalid date values gracefully without throwing', () {
      expect(MovieBuyerDateHelper.parseDateTime(null), isNull);
      expect(MovieBuyerDateHelper.parseDateTime(""), isNull);
      expect(MovieBuyerDateHelper.parseDateTime("null"), isNull);
      expect(MovieBuyerDateHelper.parseDateTime("invalid-date-string"), isNull);
      expect(MovieBuyerDateHelper.format(null), equals('—'));
      expect(MovieBuyerDateHelper.format(""), equals('—'));
    });
  });

  group('MovieUserItem & MoviePurchaseDetail Response Mapping', () {
    test('Parses MovieUserItem with numeric timestamp registrationDate without TypeError', () {
      final jsonMap = {
        "id": 101,
        "firstName": "Rahul",
        "lastName": "Sharma",
        "emailId": "rahul.sharma@example.com",
        "mobileNumber": "9876543210",
        "gender": "MALE",
        "age": 29,
        "role": ["USER", "PROMOTER"],
        "profilePhoto": "https://example.com/avatar.jpg",
        "registrationDate": 1789380356000,
        "active": true,
        "location": {
          "id": 1,
          "state": "Maharashtra",
          "district": "Pune",
          "taluka": "Haveli",
          "city": "Pune",
          "pincode": 411001,
        },
        "purchaseDetails": {
          "purchaseId": 501,
          "purchaseDate": 1789380356000,
          "amount": 149.0,
          "paymentStatus": "SUCCESS",
          "transactionId": "TXN_998877",
        }
      };

      final userItem = MovieUserItem.fromJson(jsonMap);

      expect(userItem.id, equals(101));
      expect(userItem.fullName, equals("Rahul Sharma"));
      expect(userItem.emailId, equals("rahul.sharma@example.com"));
      expect(userItem.mobileNumber, equals("9876543210"));
      expect(userItem.gender, equals("MALE"));
      expect(userItem.age, equals("29"));
      expect(userItem.role, containsAll(["USER", "PROMOTER"]));
      expect(userItem.registrationDate, isNotNull);
      expect(userItem.registrationDate!.millisecondsSinceEpoch, equals(1789380356000));
      expect(userItem.formattedRegistrationDate, isNotEmpty);

      // Location checks
      expect(userItem.location, isNotNull);
      expect(userItem.location!.state, equals("Maharashtra"));
      expect(userItem.location!.district, equals("Pune"));
      expect(userItem.location!.taluka, equals("Haveli"));
      expect(userItem.location!.pincode, equals("411001"));

      // Purchase checks
      expect(userItem.purchaseDetails, isNotNull);
      expect(userItem.purchaseDetails!.purchaseId, equals(501));
      expect(userItem.purchaseDetails!.amount, equals(149.0));
      expect(userItem.purchaseDetails!.paymentStatus, equals("SUCCESS"));
      expect(userItem.purchaseDetails!.transactionId, equals("TXN_998877"));
      expect(userItem.purchaseDetails!.purchaseDate, isNotNull);
      expect(userItem.purchaseDetails!.purchaseDate!.millisecondsSinceEpoch, equals(1789380356000));
    });

    test('Parses nested user (UserContent structure) with flat amount and timestamp keys', () {
      final jsonMap = {
        "id": 999,
        "price": 199,
        "dateFrom": 1789380356000,
        "user": {
          "userId": 202,
          "firstName": "Priya",
          "lastName": "Patil",
          "joinDate": 1789380356000,
          "location": {
            "state": "Maharashtra",
            "district": "Mumbai",
          }
        },
        "txnId": "TXN_12345",
        "status": "SUCCESS"
      };

      final userItem = MovieUserItem.fromJson(jsonMap);

      expect(userItem.id, equals(202));
      expect(userItem.fullName, equals("Priya Patil"));
      expect(userItem.registrationDate, isNotNull);
      expect(userItem.purchaseDetails, isNotNull);
      expect(userItem.purchaseDetails!.amount, equals(199.0));
      expect(userItem.purchaseDetails!.transactionId, equals("TXN_12345"));
    });
  });

  group('User entity and Location entity null-safety tests', () {
    test('User.fromJson handles int timestamps for joinDate, registrationDate, dob', () {
      final userJson = {
        "id": 55,
        "firstName": "Amit",
        "lastName": "Kumar",
        "joinDate": 1789380356000,
        "registrationDate": 1789380356000,
        "dob": 631152000000,
        "age": 35,
        "admin": "true",
        "verified": 1,
        "active": true,
        "role": ["USER"],
        "selectedLanguages": ["Marathi", "Hindi"],
        "location": {
          "id": "12",
          "pincode": 411038,
          "city": "Pune",
          "state": "MH"
        }
      };

      final user = User.fromJson(userJson);
      expect(user.id, equals(55));
      expect(user.firstName, equals("Amit"));
      expect(user.joinDate, isNotNull);
      expect(user.registrationDate, isNotNull);
      expect(user.dob, isNotNull);
      expect(user.admin, isTrue);
      expect(user.location, isNotNull);
      expect(user.location!.id, equals(12));
      expect(user.location!.pincode, equals("411038"));
    });
  });

  group('Movie Buyers API Contract & Scoped Movie ID Query Tests', () {
    test('ApiConstant.getUsersByContentId builds correct endpoint with mandatory Movie ID', () {
      final url = ApiConstant.getUsersByContentId(
        contentId: 456,
        page: 0,
        size: 10,
      );

      final uri = Uri.parse(url);
      expect(uri.path, contains("api/contentList/getUsersByContentId"));
      expect(uri.queryParameters['contentId'], equals("456"));
      expect(uri.queryParameters['page'], equals("0"));
      expect(uri.queryParameters['size'], equals("10"));
    });

    test('ApiConstant.getUsersByContentId preserves Movie ID when keyword, location, and date range filters are applied', () {
      final url = ApiConstant.getUsersByContentId(
        contentId: 789,
        keyword: "john",
        state: "Maharashtra",
        district: "Pune",
        taluka: "Haveli",
        startDate: "2026-01-01",
        endDate: "2026-09-28",
        page: 2,
        size: 10,
      );

      final uri = Uri.parse(url);
      expect(uri.queryParameters['contentId'], equals("789"));
      expect(uri.queryParameters['keyword'], equals("john"));
      expect(uri.queryParameters['state'], equals("Maharashtra"));
      expect(uri.queryParameters['district'], equals("Pune"));
      expect(uri.queryParameters['taluka'], equals("Haveli"));
      expect(uri.queryParameters['startDate'], equals("2026-01-01"));
      expect(uri.queryParameters['endDate'], equals("2026-09-28"));
      expect(uri.queryParameters['page'], equals("2"));
      expect(uri.queryParameters['size'], equals("10"));
    });
  });
}

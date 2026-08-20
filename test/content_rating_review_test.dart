import 'dart:convert';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/content_rating_review_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Content Rating and Reviews Parsing Tests', () {
    test('parses rating and reviews response correctly', () {
      const responseJson = '''
      {
        "message": "Rating and Review fetched successfully",
        "data": {
          "reviewRating": {
            "reviews": [
              {
                "createdAt": 1786807298000,
                "contentId": 2,
                "rating": 5,
                "comment": "",
                "title": "",
                "reviewId": 1,
                "userId": 51,
                "userProfile": "",
                "username": "Sukhdeo  Jamdhade"
              },
              {
                "createdAt": 1786946389000,
                "contentId": 2,
                "rating": 5,
                "comment": "A highly enjoyable movie with strong story, great performance and visuals. ",
                "title": "A highly enjoyable movie with strong story, great performance and visuals. ",
                "reviewId": 2,
                "userId": 1,
                "userProfile": "https://d3vbkzy3heipvb.cloudfront.net/other/1786946903708-209332.jpg",
                "username": "Shital Shekade"
              }
            ],
            "ratingAvg": 5
          }
        },
        "statusCode": 200,
        "total": null,
        "totalViews": null,
        "totalLikes": null,
        "totalRevenue": null,
        "success": true
      }
      ''';

      final Map<String, dynamic> decoded = json.decode(responseJson);
      final reviewRatingJson = decoded['data']['reviewRating'] as Map<String, dynamic>;
      final ratingData = ReviewRatingData.fromJson(reviewRatingJson);

      expect(ratingData.ratingAvg, 5);
      expect(ratingData.reviews.length, 2);

      final r1 = ratingData.reviews[0];
      expect(r1.reviewId, 1);
      expect(r1.contentId, 2);
      expect(r1.rating, 5);
      expect(r1.username, 'Sukhdeo  Jamdhade');
      expect(r1.comment, '');

      final r2 = ratingData.reviews[1];
      expect(r2.reviewId, 2);
      expect(r2.userId, 1);
      expect(r2.rating, 5);
      expect(r2.username, 'Shital Shekade');
      expect(r2.comment, contains('highly enjoyable movie'));
      expect(r2.userProfile, contains('cloudfront.net'));
      expect(ratingData.count5Star, 2);
      expect(ratingData.count4Star, 0);
    });
  });
}

import 'dart:convert';
import 'package:admin_ott/data/models/response/getAllVideoResponse.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Content JSON parsing and data flow tests', () {
    test('Content.fromJson parses PascalCase and camelCase keys correctly', () {
      final pascalCaseJson = {
        "Id": 101,
        "Title": "Test Inception",
        "Description": "A mind-bending thriller",
        "Runtime": 148,
        "Ratings": 8.8,
        "Price": 199.99,
        "LanguageList": ["English", "Hindi"],
        "CastList": ["Leonardo DiCaprio", "Joseph Gordon-Levitt"],
        "GenreList": ["Sci-Fi", "Action"],
        "DirectorList": ["Christopher Nolan"],
        "TotalRevenue": 50000.0,
        "AdminRevnue": 25000.0,
        "MediaHouseRevenue": 25000.0,
        "AgeRating": "U/A 16+",
        "PosterUrlList": ["https://example.com/poster1.jpg"],
        "TrailerUrl": "https://example.com/trailer.mp4",
        "ContentUrl": "https://example.com/movie.mp4",
        "Type": "MOVIE",
        "ApprovalStatus": "APPROVED",
        "AdminIncentivePecentage": 50.0,
        "MediaHouseIncentivePecentage": 50.0,
      };

      final content = Content.fromJson(pascalCaseJson);
      expect(content.id, 101);
      expect(content.title, "Test Inception");
      expect(content.description, "A mind-bending thriller");
      expect(content.runtime, 148);
      expect(content.ratings, 8.8);
      expect(content.price, 199.99);
      expect(content.languageList, ["English", "Hindi"]);
      expect(content.castList, ["Leonardo DiCaprio", "Joseph Gordon-Levitt"]);
      expect(content.genreList, ["Sci-Fi", "Action"]);
      expect(content.directorList, ["Christopher Nolan"]);
      expect(content.totalRevenue, 50000.0);
      expect(content.adminRevnue, 25000.0);
      expect(content.mediaHouseRevenue, 25000.0);
      expect(content.ageRating, "U/A 16+");
      expect(content.posterUrlList, ["https://example.com/poster1.jpg"]);
      expect(content.trailerUrl, "https://example.com/trailer.mp4");
      expect(content.contentUrl, "https://example.com/movie.mp4");
      expect(content.type, "MOVIE");
      expect(content.approvalStatus, "APPROVED");
      expect(content.adminIncentivePecentage, 50.0);
    });

    test('Content.fromJson handles comma-separated and stringified collections', () {
      final jsonWithStrings = {
        "id": "202",
        "title": "Stringified Movie",
        "runtime": "125",
        "price": "1,500.50",
        "totalRevenue": "12,000",
        "genreList": "Action, Drama, Thriller",
        "languageList": "[\"Hindi\", \"Tamil\", \"Telugu\"]",
        "castList": "Actor One, Actor Two",
        "directorList": "Director Alpha",
        "posterUrlList": "https://example.com/poster.png",
      };

      final content = Content.fromJson(jsonWithStrings);
      expect(content.id, 202);
      expect(content.title, "Stringified Movie");
      expect(content.runtime, 125);
      expect(content.price, 1500.50);
      expect(content.totalRevenue, 12000.0);
      expect(content.genreList, ["Action", "Drama", "Thriller"]);
      expect(content.languageList, ["Hindi", "Tamil", "Telugu"]);
      expect(content.castList, ["Actor One", "Actor Two"]);
      expect(content.directorList, ["Director Alpha"]);
      expect(content.posterUrlList, ["https://example.com/poster.png"]);
    });

    test('Content.mergeWith overlays full details onto summary item without data loss', () {
      final summary = Content(
        id: 303,
        title: "Summary Title",
        posterUrlList: ["https://example.com/poster.jpg"],
        type: "MOVIE",
      );

      final full = Content(
        id: 303,
        title: "Summary Title",
        description: "Full synopsis here",
        runtime: 130,
        price: 99.0,
        castList: ["Actor A", "Actor B"],
        directorList: ["Director C"],
        genreList: ["Action"],
        languageList: ["English"],
        totalRevenue: 3000.0,
        adminRevnue: 1500.0,
        mediaHouseRevenue: 1500.0,
        adminIncentivePecentage: 50.0,
        mediaHouseIncentivePecentage: 50.0,
      );

      final merged = summary.mergeWith(full);
      expect(merged.id, 303);
      expect(merged.title, "Summary Title");
      expect(merged.posterUrlList, ["https://example.com/poster.jpg"]);
      expect(merged.description, "Full synopsis here");
      expect(merged.runtime, 130);
      expect(merged.price, 99.0);
      expect(merged.castList, ["Actor A", "Actor B"]);
      expect(merged.directorList, ["Director C"]);
      expect(merged.totalRevenue, 3000.0);
      expect(merged.adminIncentivePecentage, 50.0);
    });

    test('GetAllVideoResponse parses both camelCase and PascalCase payload formats', () {
      final pascalCasePayload = {
        "success": true,
        "message": "Videos fetched",
        "statusCode": 200,
        "data": {
          "ContentList": [
            {
              "id": 1,
              "title": "Movie 1",
              "posterUrlList": ["https://example.com/1.jpg"]
            }
          ]
        }
      };

      final res1 = GetAllVideoResponse.fromJson(pascalCasePayload);
      expect(res1.success, true);
      expect(res1.data?.contentList?.length, 1);
      expect(res1.data?.contentList?.first.title, "Movie 1");

      final camelCasePayload = {
        "success": "true",
        "message": "Success",
        "data": {
          "contentList": [
            {
              "id": 2,
              "title": "Movie 2",
              "posterUrlList": ["https://example.com/2.jpg"]
            }
          ]
        }
      };

      final res2 = GetAllVideoResponse.fromJson(camelCasePayload);
      expect(res2.success, true);
      expect(res2.data?.contentList?.length, 1);
      expect(res2.data?.contentList?.first.title, "Movie 2");

      final directListPayload = {
        "status": "success",
        "data": [
          {
            "id": 3,
            "title": "Movie 3",
          }
        ]
      };

      final res3 = GetAllVideoResponse.fromJson(directListPayload);
      expect(res3.success, true);
      expect(res3.data?.contentList?.length, 1);
      expect(res3.data?.contentList?.first.title, "Movie 3");
    });
  });
}

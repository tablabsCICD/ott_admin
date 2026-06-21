import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../../data/models/response/getPromoterPercentage.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';

class PromoterPercentageProvider extends ChangeNotifier {
  // Properly initialized (not nullable)
  final List<PromoterPercentage> allEntries = [];
  final Map<String, PromoterPercentage> latestByLevel = {};
  final Map<String, List<PromoterPercentage>> historyByLevel = {};

  Future<void> getAllPromoterPercentageData() async {
    final String apiUrl = ApiConstant.getPromoterPercentage;
    final ApiHelper apiHelper = ApiHelper();
    try {
      final response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final PercentagePromoterResponse parsed =
        PercentagePromoterResponse.fromJson(responseBody);
        if (parsed.success == true && parsed.data?.genres?.content != null) {
          // 1. Update master list
          allEntries
            ..clear()
            ..addAll(parsed.data!.genres!.content!);

          // 2. Latest entry per level
          latestByLevel
            ..clear()
            ..addAll({
              for (final entry in allEntries)
                entry.typeOfPromoters!: entry,
            });

          // 3. History per level
          historyByLevel.clear();
          for (final entry in allEntries) {
            final level = entry.typeOfPromoters ?? 'Unknown';
            historyByLevel.putIfAbsent(level, () => []).add(entry);
          }

          // 4. Sort each history list by date (descending)
          for (final list in historyByLevel.values) {
            list.sort((a, b) {
              final dateA = DateTime.fromMillisecondsSinceEpoch(a.date ?? 0);
              final dateB = DateTime.fromMillisecondsSinceEpoch(b.date ?? 0);
              return dateB.compareTo(dateA);
            });
          }

          notifyListeners();
        } else {
          debugPrint("Data not found or invalid: ${parsed.message}");
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error in getAllPromoterPercentageData: $error");
      throw Exception('An error occurred while fetching promoter data.');
    }
  }

  Future<void> setPromoterPercentageData(
      String level, double userPer, double viewPer) async {
    final String apiUrl = ApiConstant.setPromoterPercentage;
    final ApiHelper apiHelper = ApiHelper();

    try {
      final Map<String, dynamic> data = {
        "active": true,
        "date": DateTime.now().toIso8601String(),
        "id": 0,
        "newUserPercentage": userPer,
        "typeOfPromoters": level,
        "viewsPercentage": viewPer,
      };

      final response = await apiHelper.postApiWithBody(apiUrl, data);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody["success"] == true) {
          await getAllPromoterPercentageData(); // refresh with new data
        } else {
          debugPrint("Save failed: ${responseBody["message"]}");
        }
      } else {
        throw Exception('Save failed: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error in setPromoterPercentageData: $error");
      throw Exception('An error occurred while saving promoter data.');
    }
  }
}

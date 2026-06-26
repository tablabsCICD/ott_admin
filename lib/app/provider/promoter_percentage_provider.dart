import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../../data/models/response/getPromoterPercentage.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';

class PromoterPercentageProvider extends ChangeNotifier {
  final List<PromoterPercentage> allEntries = [];
  final Map<String, PromoterPercentage> latestByLevel = {};
  final Map<String, List<PromoterPercentage>> historyByLevel = {};

  Future<void> getAllPromoterPercentageData() async {
    final String apiUrl = ApiConstant.getPromoterPercentage;
    final ApiHelper apiHelper = ApiHelper();
    try {
      final response = await apiHelper.getApi(apiUrl);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final PercentagePromoterResponse parsed =
            PercentagePromoterResponse.fromJson(responseBody);
        final content = parsed.data?.genres?.content ?? <PromoterPercentage>[];

        if (parsed.success == true) {
          allEntries
            ..clear()
            ..addAll(content);

          allEntries.sort((a, b) {
            final dateA = DateTime.fromMillisecondsSinceEpoch(a.date ?? 0);
            final dateB = DateTime.fromMillisecondsSinceEpoch(b.date ?? 0);
            return dateB.compareTo(dateA);
          });

          latestByLevel.clear();
          for (final entry in allEntries) {
            final level = entry.typeOfPromoters;
            if (level != null && level.isNotEmpty) {
              latestByLevel.putIfAbsent(level, () => entry);
            }
          }

          historyByLevel.clear();
          for (final entry in allEntries) {
            final level = entry.typeOfPromoters ?? 'Unknown';
            historyByLevel.putIfAbsent(level, () => []).add(entry);
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
    String level,
    double moviePercentage,
    double seriesPercentage,
    double shortPercentage,
    double musicPercentage,
  ) async {
    final String apiUrl = ApiConstant.setPromoterPercentage;
    final ApiHelper apiHelper = ApiHelper();

    try {
      final Map<String, dynamic> data = {
        "active": true,
        "date": DateTime.now().toIso8601String(),
        "id": latestByLevel[level]?.id ?? 0,
        "typeOfPromoters": level,
        "moviePercentage": moviePercentage,
        "seriesPercentage": seriesPercentage,
        "shortPercentage": shortPercentage,
        "musicPercentage": musicPercentage,
      };

      final response = await apiHelper.postApiWithBody(apiUrl, data);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody =
            response.body.toString().trim().isEmpty
                ? <String, dynamic>{"success": true}
                : json.decode(response.body) as Map<String, dynamic>;
        if (responseBody["success"] != false) {
          await getAllPromoterPercentageData();
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

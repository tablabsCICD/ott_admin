import 'dart:developer';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';

import 'package:admin_ott/data/models/response/dashboardResponse.dart';
import 'package:admin_ott/data/models/response/graphResponse.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../ui/pages/dashboard page/component/revenue_chart.dart';
import '../widgets/show_toast.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardData _dashboardData = DashboardData();

  DashboardData get dashboardData => _dashboardData;

  // Fetch the revenue summary used by the dashboard revenue split card.
  Future<void> getDashboradData() async {
    String apiUrl = ApiConstant.dashboardCount;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        DashbordResponse dashbordResponse =
            DashbordResponse.fromJson(responseBody);
        if (dashbordResponse.isSuccess == true) {
          if (dashbordResponse.data != null) {
            _dashboardData = dashbordResponse.data!;
            notifyListeners();
          } else {
            debugPrint("data not found: ${dashbordResponse.message}");
          }
        } else {
          debugPrint("Error: ${dashbordResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching data.');
    }
  }

  List<Map<String, dynamic>>? chartDataList;
  int contentTypeTotal = 0;

  // Fetch the content category summary used by the dashboard pie chart.
  Future<void> getMovieTypeChartData() async {
    String apiUrl = ApiConstant.movieTypeChartData;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        final success = (responseBody['isSuccess'] == true ||
            responseBody['success'] == true);
        if (success) {
          final dynamic data = responseBody['data'];
          if (data is Map<String, dynamic>) {
            final rawBreakdown = data['breakdown'];
            final breakdown = rawBreakdown is List ? rawBreakdown : const [];
            chartDataList = breakdown.whereType<Map>().map((item) {
              final map = Map<String, dynamic>.from(item);
              final percentage =
                  (map['percentage'] as num?)?.toDouble() ?? 0.0;
              return {
                'title': _contentCategoryTitle(map['contentType']),
                'value': percentage,
                'count': (map['totalCount'] as num?)?.toInt() ?? 0,
                'percentText': '${percentage.toStringAsFixed(1)}%',
              };
            }).toList();
            contentTypeTotal = chartDataList!.fold<int>(0,
                (sum, item) => sum + ((item['count'] as num?)?.toInt() ?? 0));
            notifyListeners();
          } else if (data is List) {
            // Backward compatibility for older API list format.
            chartDataList = data.map<Map<String, dynamic>>((item) {
              final map = item as Map<String, dynamic>;
              final value = (map['value'] as num?)?.toDouble() ?? 0.0;
              return {
                "title": map['label'] ?? 'Unknown',
                "value": value,
                "percentText": "${value.toStringAsFixed(1)}%",
              };
            }).toList();
            contentTypeTotal = chartDataList!.fold<int>(0,
                (sum, item) => sum + ((item['value'] as num?)?.toInt() ?? 0));
            notifyListeners();
          } else {
            debugPrint("data not found: ${responseBody['message']}");
          }
        } else {
          debugPrint("Error: ${responseBody['message']}");
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching data.');
    }
  }

  List<Map<String, dynamic>>? revenueChartDataList;
  double revenueSummaryTotal = 0;
  bool isRevenueSummaryLoading = false;
  String? revenueSummaryError;

  // Fetch all users
  Future<void> getRevenueChartData() async {
    String apiUrl = ApiConstant.revenueChartData;
    ApiHelper apiHelper = ApiHelper();
    isRevenueSummaryLoading = true;
    revenueSummaryError = null;
    notifyListeners();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        final success = responseBody['success'] == true ||
            responseBody['isSuccess'] == true;
        if (success) {
          final rawData = responseBody['data'];
          final rawItems = rawData is Map<String, dynamic>
              ? rawData['breakdown'] ?? rawData['items']
              : rawData;

          revenueSummaryTotal = rawData is Map<String, dynamic>
              ? (rawData['totalRevenue'] as num?)?.toDouble() ?? 0
              : 0;

          final items = rawItems is List ? rawItems : const [];
          revenueChartDataList = items.whereType<Map>().map((item) {
            final map = Map<String, dynamic>.from(item);
            final revenue = map['revenue'] ?? map['amount'] ?? map['value'];
            return {
              'title': _revenueCategoryTitle(
                  map['contentType'] ?? map['category'] ?? map['label']),
              'revenue': (revenue as num?)?.toDouble() ?? 0,
              'percentage': (map['percentage'] as num?)?.toDouble(),
            };
          }).toList();

          if (revenueSummaryTotal <= 0) {
            revenueSummaryTotal = revenueChartDataList!.fold<double>(
                0, (sum, item) => sum + (item['revenue'] as double));
          }
        } else {
          throw Exception(responseBody['message'] ??
              'Unable to load the revenue summary.');
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      revenueChartDataList = [];
      revenueSummaryTotal = 0;
      revenueSummaryError = 'Unable to load revenue summary.';
    } finally {
      isRevenueSummaryLoading = false;
      notifyListeners();
    }
  }

  String _contentCategoryTitle(dynamic value) {
    switch (value?.toString().trim().toUpperCase()) {
      case 'MOVIE':
      case 'MOVIES':
        return 'Movies';
      case 'SHORT_FILM':
      case 'SHORT FILM':
        return 'Short Film';
      case 'SERIES':
        return 'Series';
      case 'MINI_SERIES':
      case 'MINI SERIES':
      case 'SHORT':
      case 'SHORTS':
        return 'Mini Series';
      default:
        return value?.toString() ?? 'Other';
    }
  }

  String _revenueCategoryTitle(dynamic value) {
    switch (value?.toString().trim().toUpperCase()) {
      case 'MOVIE':
      case 'MOVIES':
        return 'Movie Revenue';
      case 'SHORT_FILM':
      case 'SHORT FILM':
        return 'Short Film Revenue';
      case 'SERIES':
        return 'Series Revenue';
      case 'SHORT':
      case 'SHORTS':
      case 'MINI_SERIES':
        return 'Mini Series Revenue';
      default:
        return '${value ?? 'Other'} Revenue';
    }
  }

  List<ChartData> chartData = [];
  String totalRevenue = '0';
  Future<void> fetchAllRevenueGraph(String startDate, String endDate) async {
    String apiUrl = ApiConstant.allRevenue(startDate, endDate);
    ApiHelper apiHelper = ApiHelper();
    log("====== Fetching revenue graph data from API: $apiUrl");

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      GraphResponse adminRevenueChartResponse =
          GraphResponse.fromJson(responseBody);
      if (adminRevenueChartResponse.success == true) {
        chartData.clear(); // Clear previous data
        totalRevenue = adminRevenueChartResponse.total ?? "0";
        log("total revenue: $totalRevenue");
        log("revenue graph data: ${adminRevenueChartResponse.data}");
        for (var data in adminRevenueChartResponse.data!) {
          chartData.add(
            ChartData(
              data.label as String,
              (data.value as num).toDouble(),
            ),
          );
        }
        notifyListeners(); // Notify listeners for UI updates
      } else {
        CustomToast.show(adminRevenueChartResponse.message.toString(),
            isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }
}

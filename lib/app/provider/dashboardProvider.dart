import 'dart:developer';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';

import 'package:admin_ott/data/models/response/dashboardResponse.dart';
import 'package:admin_ott/data/models/response/getMovieTypeChart.dart';
import 'package:admin_ott/data/models/response/graphResponse.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../ui/pages/dashboard page/component/revenue_chart.dart';
import '../widgets/show_toast.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardData _dashboardData = DashboardData();

  DashboardData get dashboardData => _dashboardData;

  // Fetch all users
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

  // Fetch all users
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
            final movieCount = (data['movieCount'] as num?)?.toInt() ?? 0;
            final seriesCount = (data['seriesCount'] as num?)?.toInt() ?? 0;
            final shortCount = (data['shortCount'] as num?)?.toInt() ?? 0;
            contentTypeTotal = (data['total'] as num?)?.toInt() ??
                (movieCount + seriesCount + shortCount);

            chartDataList = [
              {
                "title": "Movies",
                "value": (data['moviePercent'] as num?)?.toDouble() ?? 0.0,
                "count": movieCount,
                "percentText":
                    "${((data['moviePercent'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}%",
              },
              {
                "title": "Series",
                "value": (data['seriesPercent'] as num?)?.toDouble() ?? 0.0,
                "count": seriesCount,
                "percentText":
                    "${((data['seriesPercent'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}%",
              },
              {
                "title": "Mini Series",
                "value": (data['shortPercent'] as num?)?.toDouble() ?? 0.0,
                "count": shortCount,
                "percentText":
                    "${((data['shortPercent'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}%",
              },
            ];
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

  // Fetch all users
  Future<void> getRevenueChartData() async {
    String apiUrl = ApiConstant.revenueChartData;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        MovieTypeChartResponse movieTypeChartResponse =
            MovieTypeChartResponse.fromJson(responseBody);
        if (movieTypeChartResponse.success == true) {
          if (movieTypeChartResponse.data != null) {
            revenueChartDataList = movieTypeChartResponse.data!.map((item) {
              return {
                "title": item.label,
                "value": item.value,
              };
            }).toList();
            notifyListeners();
          } else {
            debugPrint("data not found: ${movieTypeChartResponse.message}");
          }
        } else {
          debugPrint("Error: ${movieTypeChartResponse.message}");
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

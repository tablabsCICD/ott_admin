import 'dart:convert';
import 'package:admin_ott/data/models/response/allPromoterRevenueResponse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../widgets/show_toast.dart';
import 'package:intl/intl.dart';

class PromoterGraphProvider extends ChangeNotifier {
  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  String activeButton = '7D';
  String endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String startDate =
  DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 7)));

  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  List<Map<String, dynamic>> chartData = [];
  Future<List<Map<String, dynamic>>> filteredDataFuture =
  Future.value([]); // Initialize with an empty future.

  Future<void> fetchAllPromoterRevenueGraph(
      String startDate, String endDate, int selectedTimeRange) async {
    _updateFilterFlags(selectedTimeRange);

    String apiUrl = ApiConstant.allPromoterRevenueGraph(
      startDate,
      endDate,
      isYear,
      isMonth,
      isWeek,
    );
print(apiUrl);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      Map<String, dynamic> responseBody = json.decode(response.body);

      PromoterRevenueGraphResponse promoterRevenueGraphResponse =
      PromoterRevenueGraphResponse.fromJson(responseBody);

      if (promoterRevenueGraphResponse.success == true) {
        _updateChartData(promoterRevenueGraphResponse.data);
        notifyListeners();
      } else {
        CustomToast.show(promoterRevenueGraphResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  void _updateFilterFlags(int selectedTimeRange) {
    isWeek = selectedTimeRange == 0;
    isMonth = selectedTimeRange == 1;
    isYear = selectedTimeRange == 2;
  }

  void _updateChartData(List<PromoterRevenueList>? data) {
    if (data != null) {
      chartData.clear();
      for (var entry in data) {
        chartData.add({
          'date': entry.date,
          'National Revenue': entry.nationalRevenue,
          'State Revenue': entry.stateRevenue,
          'District Revenue': entry.districtRevenue,
          'Taluka Revenue': entry.talukaRevenue,
        });
      }
      updateFilteredData();
    }
  }

  void updateFilteredData() {
    final params = {
      'chartData': chartData,
      'start': selectedDateRange.start.toIso8601String(),
      'end': selectedDateRange.end.toIso8601String(),
      'activeButton': activeButton,
    };

    filteredDataFuture = compute(filterData, params);
  }

  static List<Map<String, dynamic>> filterData(Map<String, dynamic> params) {
    List<Map<String, dynamic>> chartData =
    List<Map<String, dynamic>>.from(params['chartData']);
    DateTime start = DateTime.parse(params['start']);
    DateTime end = DateTime.parse(params['end']);

    // Filter data based on the date range
    return chartData;
  }

  void setCustomDateRange(DateTimeRange range) {
    selectedDateRange = range;
    startDate = DateFormat('yyyy-MM-dd').format(range.start);
    endDate = DateFormat('yyyy-MM-dd').format(range.end);
    fetchAllPromoterRevenueGraph(startDate, endDate, 3);
  }
}

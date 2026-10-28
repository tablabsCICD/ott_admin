
import 'dart:convert';


import 'package:flutter/foundation.dart';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/response/reportAndDataResponse.dart';
import '../../data/models/response/topRatedMovie.dart';
import '../../data/models/response/topRevenueMovie.dart';
import '../core/constant/api_constant.dart';

import '../core/network/api_helper.dart';

import '../core/utils/sharepreferences.dart';
import '../widgets/show_toast.dart';



class GraphProvider extends ChangeNotifier {



  DateTimeRange? selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 7)),
    end: DateTime.now(),
  );
  DateTime get today => DateTime.now();
  DateTime? startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime? endDate =DateTime.now();
  String activeButton = 'Week';

  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  List<ContentWithRevenue> chartData = [];
  List<ContentWithRating> chartData1 = [];
  List<Map<String,dynamic>> graphData = [];


  falseAllFilter() {
    isYear = false;
    isMonth = false;
    isWeek = false;
  }

  bool isRevenueGraphLoading = false;
  String? revenueGraphError;

  Future<void> fetchTopPerformingMovieGraph(int selectedTimeRange, int id,
      {String type = "ALL"}) async {
    isRevenueGraphLoading = true;
    revenueGraphError = null;
    notifyListeners();

    String start = DateFormat('yyyy-MM-dd').format(startDate!);
    String end = DateFormat('yyyy-MM-dd').format(endDate!);
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = true;
    }

    final urls = [
      ApiConstant.mediaHouseRevenueGraphV2Clean(id),
      ApiConstant.mediaHouseRevenueGraphV2(id,
          startDate: start, endDate: end, type: type),
      ApiConstant.mediaHouseRevenueGraphV2Alias(id,
          startDate: start, endDate: end, type: type),
      ApiConstant.topRevenueContentGraphForMediaHouse(
        id,
        start,
        end,
        isYear,
        isMonth,
        isWeek,
        type: type,
      ),
    ];

    ApiHelper apiHelper = ApiHelper();

    for (final apiUrl in urls) {
      try {
        var response = await apiHelper.getApi(apiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = json.decode(response.body);
          TopRevenueMovie topRevenueMovie =
              TopRevenueMovie.fromJson(responseBody);
          final list = topRevenueMovie.data?.contentWithRevenue ?? [];
          if (list.isNotEmpty) {
            chartData.clear();
            graphData.clear();
            chartData = list;

            for (var data in chartData) {
              graphData.add({
                "label": data.name,
                "value": data.totalRevenue ?? 0.0,
                "grossRevenue": data.mediaHouseGrossRevenue ?? 0.0,
                "netRevenue": data.mediaHouseNetRevenue ?? 0.0,
                "totalRevenue": data.totalRevenue ?? 0.0,
              });
            }

            isRevenueGraphLoading = false;
            revenueGraphError = null;
            notifyListeners();
            return;
          }
        }
      } catch (error) {
        debugPrint("Error fetching graph from $apiUrl: $error");
      }
    }

    isRevenueGraphLoading = false;
    if (chartData.isEmpty) {
      revenueGraphError = "Revenue graph unavailable";
    }
    notifyListeners();
  }

  Future<void> fetchTopRatedMovieGraph(int selectedTimeRange, id,
      {String type = "ALL"}) async {
    print("start date $startDate && end date $endDate");
    String start = DateFormat('yyyy-MM-dd').format(startDate!);
    String end = DateFormat('yyyy-MM-dd').format(endDate!);
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = true;
    }

    String apiUrl = ApiConstant.topRatedContentGraph(
      id,
      start,
      end,
      isYear,
      isMonth,
      isWeek,
      type: type,
    );

    ApiHelper apiHelper = ApiHelper();
    print(apiUrl);

    try {
      var response = await apiHelper.getApi(apiUrl);
      print(response);
      Map<String, dynamic> responseBody = json.decode(response.body);

      TopRatedMovie topRevenueMovie = TopRatedMovie.fromJson(responseBody);
      if (topRevenueMovie.success == true) {
        if (topRevenueMovie.data!.contentWithRatings != null) {
          chartData1.clear();
          graphData.clear(); // Clear previous data to avoid duplication

          chartData1 = topRevenueMovie.data!.contentWithRatings!;

          for (var data in chartData1) {
            // Assuming ContentWithRating has `label` and `value` properties
            graphData.add({
              "label": data.name, // Replace with actual property name from ContentWithRating
              "value": data.avgRating, // Replace with actual property name from ContentWithRating
            });
          }

          notifyListeners();
        } else {
          CustomToast.show(topRevenueMovie.message.toString(), isSuccess: topRevenueMovie.success!,);
        }
      } else {
        CustomToast.show(topRevenueMovie.message.toString(), isSuccess: topRevenueMovie.success!,);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  void setDateRange(String label, int days, BuildContext context, bool isRevenue,
      int id, {String type = "ALL"}) {
    activeButton = label;

    // Set start and end date based on the label
    if (label == "Custom Dates") {
      pickDateRange(context, isRevenue, id, type: type); // Trigger date range picker
    } else {
      endDate = today;
      startDate = endDate!.subtract(Duration(days: days));
      selectedDateRange = DateTimeRange(start: startDate!, end: endDate!);

      // Fetch graph data based on the label
      if (label == "Week") {
        isRevenue
            ? fetchTopPerformingMovieGraph(0, id, type: type)
            : fetchTopRatedMovieGraph(0, id, type: type);
      } else if (label == "Month") {
        isRevenue
            ? fetchTopPerformingMovieGraph(1, id, type: type)
            : fetchTopRatedMovieGraph(1, id, type: type);
      } else if (label == "Year") {
        isRevenue
            ? fetchTopPerformingMovieGraph(2, id, type: type)
            : fetchTopRatedMovieGraph(2, id, type: type);
      } else {
        isRevenue
            ? fetchTopPerformingMovieGraph(0, id, type: type)
            : fetchTopRatedMovieGraph(0, id, type: type);
      }

      notifyListeners();
    }
  }

  Future<void> pickDateRange(BuildContext context, bool isRevenue, int id,
      {String type = "ALL"}) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    // Update dates if the user selects a custom range
    if (picked != null) {
      selectedDateRange = picked;
      activeButton = 'Custom Dates';
      startDate = picked.start;//DateFormat('yyyy-MM-dd').format(DateTime.parse("2025-05-01 00:00:00.000"));
      endDate = picked.end;
      print("start date $startDate && end date $endDate");
      isRevenue
          ? fetchTopPerformingMovieGraph(0, id, type: type)
          : fetchTopRatedMovieGraph(0, id, type: type);
      notifyListeners();
    }
  }




  List<ReportAndDataObject> _reportAndDataList = [];
  List<ReportAndDataObject> get reportAndDataList => _reportAndDataList;

  Future<void> getReportAndData(context) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();

    String apiUrl = ApiConstant.reportAndDataForMediaHouse(
        mediaHouse!.id
    );

    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      Map<String, dynamic> responseBody = json.decode(response.body);
      ReportAndDataResponse reportAndDataResponse = ReportAndDataResponse.fromJson(responseBody);
      if (reportAndDataResponse.success == true) {
        if (reportAndDataResponse.data!.mediaHouse != null) {
          _reportAndDataList.clear();
          _reportAndDataList = reportAndDataResponse.data!.mediaHouse!;
          notifyListeners();
        } else {
          CustomToast.show(reportAndDataResponse.message.toString(), isSuccess: reportAndDataResponse.success!,);
        }
      } else {
        CustomToast.show(reportAndDataResponse.message.toString(), isSuccess: reportAndDataResponse.success!,);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }


}
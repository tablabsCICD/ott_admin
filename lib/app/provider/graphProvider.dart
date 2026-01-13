
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

  Future<void> fetchTopPerformingMovieGraph(int selectedTimeRange,int id) async {
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

    String apiUrl = ApiConstant.topRevenueContentGraphForMediaHouse(
      id,
      start,
      end,
      isYear,
      isMonth,
      isWeek,
    );

    ApiHelper apiHelper = ApiHelper();
    print(apiUrl);

    try {
      var response = await apiHelper.getApi(apiUrl);
      print(response);
      Map<String, dynamic> responseBody = json.decode(response.body);

      TopRevenueMovie topRevenueMovie = TopRevenueMovie.fromJson(responseBody);
      if (topRevenueMovie.success == true) {
        if (topRevenueMovie.data!.contentWithRevenue != null) {
          chartData.clear();
          graphData.clear(); // Clear previous data to avoid duplication

          chartData = topRevenueMovie.data!.contentWithRevenue!;

          for (var data in chartData) {
            // Assuming ContentWithRating has `label` and `value` properties
            graphData.add({
              "label": data.name, // Replace with actual property name from ContentWithRating
              "value": data.totalRevenue, // Replace with actual property name from ContentWithRating
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

  Future<void> fetchTopRatedMovieGraph(int selectedTimeRange,id) async {
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

  void setDateRange(String label, int days, BuildContext context, bool isRevenue,int id) {
    activeButton = label;

    // Set start and end date based on the label
    if (label == "Custom Dates") {
      pickDateRange(context,isRevenue,id); // Trigger date range picker
    } else {
      endDate = today;
      startDate = endDate!.subtract(Duration(days: days));
      selectedDateRange = DateTimeRange(start: startDate!, end: endDate!);

      // Fetch graph data based on the label
      if (label == "Week") {
        isRevenue?fetchTopPerformingMovieGraph(0,id):fetchTopRatedMovieGraph(0,id);
      } else if (label == "Month") {
        isRevenue?fetchTopPerformingMovieGraph(1,id):fetchTopRatedMovieGraph(1,id);
      } else if (label == "Year") {
        isRevenue?fetchTopPerformingMovieGraph(2,id):fetchTopRatedMovieGraph(2,id);
      } else {
        isRevenue?fetchTopPerformingMovieGraph(0,id):fetchTopRatedMovieGraph(0,id);
      }

      notifyListeners();
    }
  }

  Future<void> pickDateRange(BuildContext context, bool isRevenue,int id) async {
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
      isRevenue?fetchTopPerformingMovieGraph(0,id):fetchTopRatedMovieGraph(0,id);
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
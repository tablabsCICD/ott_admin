import 'dart:math';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';

import 'package:admin_ott/app/ui/pages/dashboard%20page/component/MediaHouseSearch.dart';
import 'package:admin_ott/app/widgets/get_date_time.dart';
import 'package:admin_ott/data/models/api_response.dart';
import 'package:admin_ott/data/models/request/user_request.dart';
import 'package:admin_ott/data/models/response/addUserResponse.dart';
import 'package:admin_ott/data/models/response/adminRevenueResponse.dart';
import 'package:admin_ott/data/models/response/dashboardResponse.dart';
import 'package:admin_ott/data/models/response/getAllMediaHouseResponse.dart';
import 'package:admin_ott/data/models/response/getAllUserResponse.dart';
import 'package:admin_ott/data/models/response/getMovieTypeChart.dart';
import 'package:admin_ott/data/models/response/graphResponse.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ui/pages/dashboard page/component/revenue_chart.dart';
import '../widgets/show_toast.dart';

class DashboardProvider extends ChangeNotifier {

  DashboardProvider() : super(){
    getDashboradData();
    getMovieTypeChartData();
    getRevenueChartData();
  }

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
        DashbordResponse dashbordResponse = DashbordResponse.fromJson(responseBody);
        if (dashbordResponse.isSuccess == true) {
          if(dashbordResponse.data != null){
            _dashboardData = dashbordResponse.data!;
            notifyListeners();
          }else {
            debugPrint("data not found: ${dashbordResponse.message}");
          }
        } else {
          debugPrint("Error: ${dashbordResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching data.');
    }
  }

  List<Map<String, dynamic>>? chartDataList;

  // Fetch all users
  Future<void> getMovieTypeChartData() async {
    String apiUrl = ApiConstant.movieTypeChartData;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        MovieTypeChartResponse movieTypeChartResponse = MovieTypeChartResponse.fromJson(responseBody);
        if (movieTypeChartResponse.success == true) {
          if(movieTypeChartResponse.data != null){
            chartDataList = movieTypeChartResponse.data!.map((item) {
              return {
                "title": item.label,
                "value": item.value,
                "color": getRandomColor(), // Assigning random color
              };
            }).toList();
            notifyListeners();
          }else {
            debugPrint("data not found: ${movieTypeChartResponse.message}");
          }
        } else {
          debugPrint("Error: ${movieTypeChartResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
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
        MovieTypeChartResponse movieTypeChartResponse = MovieTypeChartResponse.fromJson(responseBody);
        if (movieTypeChartResponse.success == true) {
          if(movieTypeChartResponse.data != null){
            revenueChartDataList = movieTypeChartResponse.data!.map((item) {
              return {
                "title": item.label,
                "value": item.value,
                "color": getRandomColor(), // Assigning random color
              };
            }).toList();
            notifyListeners();
          }else {
            debugPrint("data not found: ${movieTypeChartResponse.message}");
          }
        } else {
          debugPrint("Error: ${movieTypeChartResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching data.');
    }
  }


  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255, // Alpha channel (fully opaque)
      random.nextInt(256), // Red channel
      random.nextInt(256), // Green channel
      random.nextInt(256), // Blue channel
    );
  }


  List<ChartData> chartData = [];
  String totalRevenue = '0';
  Future<void> fetchAllRevenueGraph(
      String startDate, String endDate) async {


    String apiUrl = ApiConstant.allRevenue(      startDate,
      endDate

    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      GraphResponse adminRevenueChartResponse =
      GraphResponse.fromJson(responseBody);
      if (adminRevenueChartResponse.success == true) {
        chartData.clear(); // Clear previous data
        totalRevenue = adminRevenueChartResponse.total??"0";
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
        CustomToast.show(adminRevenueChartResponse.message.toString(),isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }
}

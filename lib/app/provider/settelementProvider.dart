

import 'dart:convert';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';

class SettelementProvider extends ChangeNotifier {

  List<WeeklySettelementData> _weeklySettelement = [];
  List<WeeklySettelementData> get weeklySettelement => _weeklySettelement;

  List<WeeklySettelementData> _filleterdWeeklySettelement = [];
  List<WeeklySettelementData> get filleterdWeeklySettelement => _filleterdWeeklySettelement;
  // Fetch all moviesByMediaHouseId
  Future<void> fetchWeeklySettelementDataByMediaHouseId(int userId) async {
    String apiUrl = ApiConstant.weeklySettelementDataForMediaHouse(userId);
    print(apiUrl);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: "+response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: "+responseBody.toString());
        MediaHouseWeeklySattelment mediaHouseWeeklySattelment = MediaHouseWeeklySattelment.fromJson(responseBody);
        debugPrint("data::: "+mediaHouseWeeklySattelment.data.toString());
        if (mediaHouseWeeklySattelment.success == true) {
          if(mediaHouseWeeklySattelment.data != null){
            _weeklySettelement = mediaHouseWeeklySattelment.data!;
            _filleterdWeeklySettelement = _weeklySettelement;
            debugPrint("message : ${mediaHouseWeeklySattelment.message}");
            notifyListeners();
          }else {
            debugPrint("empty list: ${mediaHouseWeeklySattelment.message}");
          }
        } else {
          debugPrint("Error: ${mediaHouseWeeklySattelment.message}");
        }
      } else {
        throw Exception('Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  Future<void> fetchWeeklySettelementData() async {
    String apiUrl = ApiConstant.weeklySettelementData;
    print(apiUrl);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: "+response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: "+responseBody.toString());
        MediaHouseWeeklySattelment mediaHouseWeeklySattelment = MediaHouseWeeklySattelment.fromJson(responseBody);
        debugPrint("data::: "+mediaHouseWeeklySattelment.data.toString());
        if (mediaHouseWeeklySattelment.success == true) {
          if(mediaHouseWeeklySattelment.data != null){
            _weeklySettelement = mediaHouseWeeklySattelment.data!;
            _filleterdWeeklySettelement = _weeklySettelement;
            debugPrint("message : ${mediaHouseWeeklySattelment.message}");
            notifyListeners();
          }else {
            debugPrint("empty list: ${mediaHouseWeeklySattelment.message}");
          }
        } else {
          debugPrint("Error: ${mediaHouseWeeklySattelment.message}");
        }
      } else {
        throw Exception('Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }




}

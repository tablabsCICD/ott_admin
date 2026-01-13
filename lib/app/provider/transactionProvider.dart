import 'dart:convert';

import 'package:admin_ott/data/models/response/graphResponse.dart';
import 'package:flutter/material.dart';

import '../../data/models/response/userTransactionResponse.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../ui/pages/transaction page/TransactionPage.dart';
import '../widgets/show_toast.dart';

class TransactionProvider extends ChangeNotifier {

  TransactionProvider() : super() {
    searchController.addListener(filterData);
  }
  TextEditingController startDateController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController endDateNameController = TextEditingController();
  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  List<TransactionChartData> chartData = [];
  String? totalRevenue;

  falseAllFilter(){
    isYear = false;isMonth = false;isWeek = false;
  }

  Future<void> fetchTransactionGraph(int selectedTimeRange) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=true;
    }
    notifyListeners();
    String apiUrl = ApiConstant.transactionRevenueGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);


      Map<String, dynamic> responseBody = json.decode(response.body);

      GraphResponse chartResponse = GraphResponse.fromJson(responseBody);
      if(chartResponse.success==true){
        chartData.clear();
        for (var data in chartResponse.data!) {
          chartData.add(
            TransactionChartData(
              data.label as String,
              (data.value as num).toDouble(),
              0
            ),
          );
        }
        totalRevenue = chartResponse.total.toString();

        // Debug print to verify
        for (var item in chartData) {
          print('Label: ${item.date}, Value: ${item.revenue}');
        }
        notifyListeners();
      }else{
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  List<UserTransactionData> _userTransactionList =[];
  List<UserTransactionData> get userTransactionList => _userTransactionList;

  List<UserTransactionData> _filtteredUserTransactionList =[];
  List<UserTransactionData> get filtteredUserTransactionList => _filtteredUserTransactionList;

  Future<void> fetchUserTransactions(String search) async {
    String apiUrl = ApiConstant.userTransactionApi(search);
    print(apiUrl);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: "+response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: "+responseBody.toString());
        UserTransactionResponse userTransactionResponse = UserTransactionResponse.fromJson(responseBody);
        debugPrint("data::: "+userTransactionResponse.data.toString());
        if (userTransactionResponse.success == true) {
          if(userTransactionResponse.data != null){
            _userTransactionList = userTransactionResponse.data!;
            _filtteredUserTransactionList = _userTransactionList;
            debugPrint("message : ${userTransactionResponse.message}");
            notifyListeners();
          }else {
            debugPrint("empty list: ${userTransactionResponse.message}");
          }
        } else {
          debugPrint("Error: ${userTransactionResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }




  void filterData() {
    fetchUserTransactions(searchController.text);
  }
}

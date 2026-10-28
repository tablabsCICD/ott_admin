import 'dart:convert';

import 'package:admin_ott/data/models/response/graphResponse.dart';
import 'package:flutter/material.dart';

import '../../data/models/response/userTransactionResponse.dart';
import '../../data/models/response/transaction_settlement_report.dart';
import '../../data/repositories/transaction_settlement_report_repository.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../ui/pages/transaction page/TransactionPage.dart';
import '../widgets/show_toast.dart';

class TransactionProvider extends ChangeNotifier {

  TransactionProvider() : super() {
    searchController.addListener(filterData);
  }
  final TransactionSettlementReportRepository _settlementReportRepository =
      const TransactionSettlementReportRepository();
  TextEditingController startDateController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController endDateNameController = TextEditingController();
  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  List<TransactionChartData> chartData = [];
  String? totalRevenue;

  falseAllFilter() {
    isYear = false;
    isMonth = false;
    isWeek = false;
  }

  Future<void> fetchTransactionGraph(int selectedTimeRange,
      {String type = "ALL"}) async {
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
    notifyListeners();
    String apiUrl = ApiConstant.transactionRevenueGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
      type: type,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      Map<String, dynamic> responseBody = json.decode(response.body);

      GraphResponse chartResponse = GraphResponse.fromJson(responseBody);
      if (chartResponse.success == true) {
        chartData.clear();
        for (var data in chartResponse.data!) {
          chartData.add(
            TransactionChartData(
              data.label as String,
              (data.value as num).toDouble(),
              0,
            ),
          );
        }
        totalRevenue = chartResponse.total.toString();

        // Debug print to verify
        for (var item in chartData) {
          print('Label: ${item.date}, Value: ${item.revenue}');
        }
        notifyListeners();
      } else {
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

  String _selectedContentType = 'ALL';
  String get selectedContentType => _selectedContentType;

  void setSelectedContentType(String type) {
    _selectedContentType = type;
    applyFilters();
  }

  Future<void> fetchUserTransactions(String search) async {
    String apiUrl = ApiConstant.userTransactionApi(search);
    if (_selectedContentType != 'ALL') {
      final uri = Uri.parse(apiUrl);
      apiUrl = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'contentType': _selectedContentType,
      }).toString();
    }
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
            applyFilters();
            debugPrint("message : ${userTransactionResponse.message}");
          }else {
            _userTransactionList = [];
            applyFilters();
            debugPrint("empty list: ${userTransactionResponse.message}");
          }
        } else {
          _userTransactionList = [];
          applyFilters();
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

  Future<TransactionSettlementReportData> fetchTransactionSettlementReport(
      dynamic transactionId) {
    return _settlementReportRepository.fetchTransactionSettlementReport(
      transactionId,
    );
  }

  void filterData() {
    applyFilters();
  }

  void applyFilters() {
    final search = searchController.text.trim().toLowerCase();
    _filtteredUserTransactionList = _userTransactionList.where((txn) {
      final matchesSearch = search.isEmpty ||
          (txn.user?.firstName?.toLowerCase().contains(search) ?? false) ||
          (txn.user?.lastName?.toLowerCase().contains(search) ?? false) ||
          (txn.user?.mobileNumber?.contains(search) ?? false) ||
          (txn.movie?.title?.toLowerCase().contains(search) ?? false);

      final matchesType = _selectedContentType == 'ALL' ||
          (txn.movie?.type?.toUpperCase() == _selectedContentType.toUpperCase());

      return matchesSearch && matchesType;
    }).toList();
    notifyListeners();
  }
}

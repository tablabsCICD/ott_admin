import 'dart:convert';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/request/manual_settlement_request.dart';
import '../../data/models/response/manual_settlement_response.dart';
import '../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../data/models/response/monthly_ios_settlement.dart';
import '../../data/models/response/weekly_settlement_report.dart';
import '../../data/repositories/manual_settlement_repository.dart';
import '../../data/repositories/monthly_ios_settlement_repository.dart';
import '../../data/services/promoter_settlement_service.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';

class SettelementProvider extends ChangeNotifier {
  final MonthlyIosSettlementRepository _monthlyRepository =
      MonthlyIosSettlementRepository();
  final PromoterSettlementService _downloadService =
      const PromoterSettlementService();

  List<WeeklySettelementData> _weeklySettelement = [];
  List<WeeklySettelementData> get weeklySettelement => _weeklySettelement;

  List<WeeklySettelementData> _filleterdWeeklySettelement = [];
  List<WeeklySettelementData> get filleterdWeeklySettelement =>
      _filleterdWeeklySettelement;

  final List<MonthlySettlementModel> _monthlySettlements = [];
  List<MonthlySettlementModel> get monthlySettlements =>
      List.unmodifiable(_monthlySettlements);
  bool monthlyLoading = false;
  bool monthlyLoadingMore = false;
  bool monthlyGenerating = false;
  String? monthlyError;
  String? monthlyMonthFilter;
  String? monthlyStatusFilter;
  String? monthlyUserFilter;
  int monthlyPage = 0;
  int monthlySize = 20;
  int monthlyTotalPages = 1;
  int monthlyTotalElements = 0;

  bool get hasMoreMonthlySettlements => monthlyPage + 1 < monthlyTotalPages;

  // Fetch all moviesByMediaHouseId
  Future<void> fetchWeeklySettelementDataByMediaHouseId(int userId) async {
    String apiUrl = ApiConstant.weeklySettelementDataForMediaHouse(userId);
    debugPrint("========== WEEKLY SETTLEMENT BY MEDIA HOUSE API REQUEST ==========");
    debugPrint("URL: $apiUrl");
    debugPrint("Method: GET");
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("========== WEEKLY SETTLEMENT BY MEDIA HOUSE API RESPONSE ==========");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      debugPrint("==================================================================");
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        MediaHouseWeeklySattelment mediaHouseWeeklySattelment =
            MediaHouseWeeklySattelment.fromJson(responseBody);
        if (mediaHouseWeeklySattelment.success == true) {
          if (mediaHouseWeeklySattelment.data != null) {
            _weeklySettelement = mediaHouseWeeklySattelment.data!;
            _filleterdWeeklySettelement = _weeklySettelement;
            notifyListeners();
          } else {
            debugPrint("empty list: ${mediaHouseWeeklySattelment.message}");
          }
        } else {
          debugPrint("Error: ${mediaHouseWeeklySattelment.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  Future<void> fetchWeeklySettelementData() async {
    String apiUrl = ApiConstant.weeklySettelementData;
    debugPrint("========== WEEKLY SETTLEMENT API REQUEST ==========");
    debugPrint("URL: $apiUrl");
    debugPrint("Method: GET");
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("========== WEEKLY SETTLEMENT API RESPONSE ==========");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      debugPrint("==================================================");
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        MediaHouseWeeklySattelment mediaHouseWeeklySattelment =
            MediaHouseWeeklySattelment.fromJson(responseBody);
        if (mediaHouseWeeklySattelment.success == true) {
          if (mediaHouseWeeklySattelment.data != null) {
            _weeklySettelement = mediaHouseWeeklySattelment.data!;
            _filleterdWeeklySettelement = _weeklySettelement;
            notifyListeners();
          } else {
            debugPrint("empty list: ${mediaHouseWeeklySattelment.message}");
          }
        } else {
          debugPrint("Error: ${mediaHouseWeeklySattelment.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  Future<WeeklySettlementReportData> fetchWeeklySettlementReport(
      dynamic settelementId) async {
    String apiUrl = ApiConstant.weeklySettlementReport(settelementId);
    debugPrint("========== SETTLEMENT DETAILS (WEEKLY REPORT) API REQUEST ==========");
    debugPrint("URL: $apiUrl");
    debugPrint("Method: GET");
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("========== SETTLEMENT DETAILS (WEEKLY REPORT) API RESPONSE ==========");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      debugPrint("=====================================================================");
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        final settlementReport =
            WeeklySettlementReportResponse.fromJson(responseBody);
        if (settlementReport.success == true && settlementReport.data != null) {
          return settlementReport.data!;
        }
        throw Exception(
          settlementReport.message ?? 'Unable to load settlement report.',
        );
      } else {
        throw Exception(
            'Failed to fetch settlement report. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching settlement report.');
    }
  }

  Future<void> fetchMonthlySettlements({
    bool refresh = false,
    String? month,
    String? status,
    String? userId,
  }) async {
    if (monthlyLoading || monthlyLoadingMore) return;

    if (refresh) {
      monthlyPage = 0;
      _monthlySettlements.clear();
      if (month != null) monthlyMonthFilter = month;
      if (status != null) monthlyStatusFilter = status;
      if (userId != null) monthlyUserFilter = userId;
      monthlyLoading = true;
    } else {
      if (!hasMoreMonthlySettlements && _monthlySettlements.isNotEmpty) return;
      monthlyLoadingMore = _monthlySettlements.isNotEmpty;
      if (_monthlySettlements.isEmpty) monthlyLoading = true;
    }
    monthlyError = null;
    notifyListeners();

    try {
      final response = await _monthlyRepository.getMonthlySettlementList(
        month: monthlyMonthFilter,
        status: monthlyStatusFilter,
        userId: monthlyUserFilter,
        page: monthlyPage,
        size: monthlySize,
      );
      _monthlySettlements.addAll(response.items);
      monthlyPage = response.page;
      monthlySize = response.size;
      monthlyTotalPages = response.totalPages <= 0 ? 1 : response.totalPages;
      monthlyTotalElements = response.totalElements;
    } catch (error) {
      debugPrint("Monthly settlement error: $error");
      monthlyError = 'Unable to load monthly iOS settlements.';
    } finally {
      monthlyLoading = false;
      monthlyLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMonthlySettlements() async {
    if (!hasMoreMonthlySettlements || monthlyLoadingMore || monthlyLoading) {
      return;
    }
    monthlyPage += 1;
    await fetchMonthlySettlements();
  }

  Future<void> applyMonthlyFilters({
    String? month,
    String? status,
    String? userId,
  }) async {
    monthlyMonthFilter = month;
    monthlyStatusFilter = status;
    monthlyUserFilter = userId;
    await fetchMonthlySettlements(refresh: true);
  }

  Future<void> resetMonthlyFilters() async {
    monthlyMonthFilter = null;
    monthlyStatusFilter = null;
    monthlyUserFilter = null;
    await fetchMonthlySettlements(refresh: true);
  }

  Future<void> generateMonthlySettlement(String month) async {
    monthlyGenerating = true;
    notifyListeners();
    try {
      await _monthlyRepository.generateMonthlySettlement(month);
      monthlyMonthFilter = month;
      await fetchMonthlySettlements(refresh: true);
    } finally {
      monthlyGenerating = false;
      notifyListeners();
    }
  }

  Future<MonthlySettlementDetailModel> fetchMonthlySettlementDetail(
    dynamic settlementId,
  ) {
    return _monthlyRepository.getMonthlySettlementDetail(settlementId);
  }

  Future<String> downloadMonthlySettlement(dynamic settlementId) {
    return _downloadService.downloadMonthlyIosSettlementCsv(settlementId);
  }

  final ManualSettlementRepository _manualRepository =
      ManualSettlementRepository();

  Future<ManualSettlementResponse> processManualSettlement(
    ManualSettlementRequest request,
  ) async {
    final response = await _manualRepository.processManualSettlement(request);
    await fetchWeeklySettelementData();
    await fetchMonthlySettlements(refresh: true);
    return response;
  }
}

import 'dart:convert';
import 'package:admin_ott/data/models/response/ageAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/contentPerformanceAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/dateWiseAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/deviceAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/engagementAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/locationAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/topRevenueMovieForAdmin.dart';
import 'package:admin_ott/data/models/response/watchTimeAnalyticsResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/response/reportAndDataResponse.dart';
import '../../data/models/response/topRatedMovie.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../widgets/show_toast.dart';

class AnalyticsProvider extends ChangeNotifier {
  DateTimeRange? selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 7)),
    end: DateTime.now(),
  );
  DateTime get today => DateTime.now();
  DateTime? startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime? endDate = DateTime.now();
  String activeButton = 'Week';

  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  List<ContentWithRevenue> chartData = [];
  List<ContentWithRating> chartData1 = [];
  List<Map<String, dynamic>> graphData = [];
  bool isTopContentLoading = false;
  String? topContentLoadError;
  String topContentType = "ALL";
  String topContentCountry = "";
  String topContentState = "";
  String topContentDistrict = "";
  String topContentTaluka = "";
  String topContentCity = "";
  bool isReportLoading = false;
  String? reportLoadError;
  bool isSummaryLoading = false;
  String? summaryLoadError;
  bool isLocationAnalyticsLoading = false;
  String? locationAnalyticsError;
  List<LocationAnalyticsDataModel> _locationWiseAnalytics = [];
  List<LocationAnalyticsDataModel> get locationWiseAnalytics =>
      _locationWiseAnalytics;
  bool isAgeAnalyticsLoading = false;
  String? ageAnalyticsError;
  List<AgeWiseRevenueDataModel> _ageWiseRevenue = [];
  List<AgeWiseViewsDataModel> _ageWiseViews = [];
  List<AgeWiseRevenueDataModel> get ageWiseRevenue => _ageWiseRevenue;
  List<AgeWiseViewsDataModel> get ageWiseViews => _ageWiseViews;
  bool isContentPerformanceLoading = false;
  String? contentPerformanceError;
  ContentPerformanceAnalyticsDataModel? _contentPerformanceAnalytics;
  ContentPerformanceAnalyticsDataModel? get contentPerformanceAnalytics =>
      _contentPerformanceAnalytics;
  bool isDeviceAnalyticsLoading = false;
  String? deviceAnalyticsError;
  List<DeviceAnalyticsDataModel> _deviceAnalytics = [];
  List<DeviceAnalyticsDataModel> get deviceAnalytics => _deviceAnalytics;
  bool isEngagementAnalyticsLoading = false;
  String? engagementAnalyticsError;
  EngagementAnalyticsDataModel? _engagementAnalytics;
  EngagementAnalyticsDataModel? get engagementAnalytics => _engagementAnalytics;
  bool isWatchTimeAnalyticsLoading = false;
  String? watchTimeAnalyticsError;
  WatchTimeAnalyticsDataModel? _watchTimeAnalytics;
  WatchTimeAnalyticsDataModel? get watchTimeAnalytics => _watchTimeAnalytics;
  bool isDateWiseAnalyticsLoading = false;
  String? dateWiseAnalyticsError;
  List<DateWiseAnalyticsDataModel> _dateWiseAnalytics = [];
  List<DateWiseAnalyticsDataModel> get dateWiseAnalytics => _dateWiseAnalytics;
  AnalyticsSummaryData _summaryData = AnalyticsSummaryData();
  AnalyticsSummaryData get summaryData => _summaryData;
  Future<void>? _initialAnalyticsRequest;
  Future<void>? _topContentRequest;
  Future<void>? _summaryRequest;
  Future<void>? _locationRequest;
  Future<void>? _ageRequest;
  Future<void>? _contentPerformanceRequest;
  Future<void>? _deviceRequest;
  Future<void>? _engagementRequest;
  Future<void>? _watchTimeRequest;
  Future<void>? _dateWiseRequest;
  Future<void>? _reportRequest;
  String? _topContentRequestKey;
  String? _reportRequestKey;
  final Map<String, List<ReportAndDataObject>> _reportCache = {};
  final Map<String, List<Map<String, dynamic>>> _topContentGraphCache = {};

  Future<void> fetchInitialAnalytics() {
    _initialAnalyticsRequest ??= Future.wait([
      fetchAnalyticsSummary(),
      fetchLocationWiseAnalytics(),
      fetchAgeWiseAnalytics(),
      fetchContentPerformanceAnalytics(),
      fetchDeviceAnalytics(),
      fetchEngagementAnalytics(),
      fetchWatchTimeAnalytics(),
    ]).whenComplete(() => _initialAnalyticsRequest = null);
    return _initialAnalyticsRequest!;
  }

  falseAllFilter() {
    isYear = false;
    isMonth = false;
    isWeek = false;
  }

  Future<void> fetchTopPerformingMovieGraph(int selectedTimeRange) async {
    isTopContentLoading = true;
    topContentLoadError = null;
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

    String apiUrl = ApiConstant.topRevenueContentGraph(
      start,
      end,
      isYear,
      isMonth,
      isWeek,
      contentType: topContentType,
      country: topContentCountry,
      state: topContentState,
      district: topContentDistrict,
      taluka: topContentTaluka,
      city: topContentCity,
    );

    final cacheKey = [
      selectedTimeRange,
      start,
      end,
      topContentType,
      topContentCountry,
      topContentState,
      topContentDistrict,
      topContentTaluka,
      topContentCity,
    ].join('|');
    final cachedGraph = _topContentGraphCache[cacheKey];
    if (cachedGraph != null) {
      graphData = List<Map<String, dynamic>>.from(cachedGraph);
      isTopContentLoading = false;
      notifyListeners();
      return;
    }
    if (_topContentRequest != null && _topContentRequestKey == cacheKey) {
      return _topContentRequest!;
    }
    _topContentRequestKey = cacheKey;

    ApiHelper apiHelper = ApiHelper();

    _topContentRequest = (() async {
      try {
        var response = await apiHelper.getApi(apiUrl);
        Map<String, dynamic> responseBody = json.decode(response.body);

        TopRevenueMovieForAdmin topRevenueMovie =
            TopRevenueMovieForAdmin.fromJson(responseBody);
        if (topRevenueMovie.success == true) {
          final contentWithRevenue =
              topRevenueMovie.data?.contentWithRevenue ?? [];
          if (contentWithRevenue.isNotEmpty) {
            chartData.clear();
            graphData.clear(); // Clear previous data to avoid duplication

            chartData = contentWithRevenue;

            graphData = chartData
                .map((data) => {
                      "label": data.name,
                      "value": data.totalRevenue,
                    })
                .toList();
            _topContentGraphCache[cacheKey] =
                List<Map<String, dynamic>>.from(graphData);
          } else {
            chartData.clear();
            graphData.clear();
            topContentLoadError =
                topRevenueMovie.message ?? 'No top performing content found.';
          }
        } else {
          chartData.clear();
          graphData.clear();
          topContentLoadError = topRevenueMovie.message ??
              'Unable to load top performing content.';
          CustomToast.show(
            topRevenueMovie.message.toString(),
            isSuccess: topRevenueMovie.success!,
          );
        }
      } catch (error) {
        chartData.clear();
        graphData.clear();
        topContentLoadError = 'Unable to load top performing content.';
        debugPrint("Analytics revenue graph load failed: $error");
      } finally {
        isTopContentLoading = false;
        _topContentRequest = null;
        _topContentRequestKey = null;
        notifyListeners();
      }
    })();
    return _topContentRequest!;
  }

  void setTopContentType(String value) {
    topContentType = value;
    fetchTopPerformingMovieGraph(_activeRangeIndex);
  }

  void setTopContentLocationFilters({
    required String country,
    required String state,
    required String district,
    required String taluka,
    required String city,
  }) {
    topContentCountry = country.trim();
    topContentState = state.trim();
    topContentDistrict = district.trim();
    topContentTaluka = taluka.trim();
    topContentCity = city.trim();
    fetchTopPerformingMovieGraph(_activeRangeIndex);
  }

  void clearTopContentLocationFilters() {
    topContentCountry = "";
    topContentState = "";
    topContentDistrict = "";
    topContentTaluka = "";
    topContentCity = "";
    fetchTopPerformingMovieGraph(_activeRangeIndex);
  }

  int get _activeRangeIndex {
    if (activeButton == "Month") return 1;
    if (activeButton == "Year") return 2;
    return 0;
  }

  Future<void> fetchTopRatedMovieGraph(int selectedTimeRange) async {
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
      0,
      start,
      end,
      isYear,
      isMonth,
      isWeek,
    );

    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      Map<String, dynamic> responseBody = json.decode(response.body);

      TopRatedMovie topRevenueMovie = TopRatedMovie.fromJson(responseBody);
      if (topRevenueMovie.success == true) {
        final contentWithRatings =
            topRevenueMovie.data?.contentWithRatings ?? [];
        if (contentWithRatings.isNotEmpty) {
          chartData1.clear();
          graphData.clear(); // Clear previous data to avoid duplication

          chartData1 = contentWithRatings;

          for (var data in chartData1) {
            // Assuming ContentWithRating has `label` and `value` properties
            graphData.add({
              "label": data
                  .name, // Replace with actual property name from ContentWithRating
              "value": data
                  .avgRating, // Replace with actual property name from ContentWithRating
            });
          }

          notifyListeners();
        } else {
          CustomToast.show(
            topRevenueMovie.message.toString(),
            isSuccess: topRevenueMovie.success!,
          );
        }
      } else {
        CustomToast.show(
          topRevenueMovie.message.toString(),
          isSuccess: topRevenueMovie.success!,
        );
      }
    } catch (error) {
      chartData1.clear();
      graphData.clear();
      notifyListeners();
      debugPrint("Analytics rating graph load failed: $error");
    }
  }

  void setDateRange(
      String label, int days, BuildContext context, bool isRevenue) {
    activeButton = label;

    // Set start and end date based on the label
    if (label == "Custom Dates") {
      pickDateRange(context, isRevenue); // Trigger date range picker
    } else {
      endDate = today;
      startDate = endDate!.subtract(Duration(days: days));
      selectedDateRange = DateTimeRange(start: startDate!, end: endDate!);

      // Fetch graph data based on the label
      if (label == "Week") {
        isRevenue
            ? fetchTopPerformingMovieGraph(0)
            : fetchTopRatedMovieGraph(0);
      } else if (label == "Month") {
        isRevenue
            ? fetchTopPerformingMovieGraph(1)
            : fetchTopRatedMovieGraph(1);
      } else if (label == "Year") {
        isRevenue
            ? fetchTopPerformingMovieGraph(2)
            : fetchTopRatedMovieGraph(2);
      } else {
        isRevenue
            ? fetchTopPerformingMovieGraph(0)
            : fetchTopRatedMovieGraph(0);
      }

      notifyListeners();
    }
  }

  Future<void> pickDateRange(BuildContext context, bool isRevenue) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    // Update dates if the user selects a custom range
    if (picked != null) {
      selectedDateRange = picked;
      activeButton = 'Custom Dates';
      startDate = picked
          .start; //DateFormat('yyyy-MM-dd').format(DateTime.parse("2025-05-01 00:00:00.000"));
      endDate = picked.end;
      isRevenue ? fetchTopPerformingMovieGraph(0) : fetchTopRatedMovieGraph(0);
      notifyListeners();
    }
  }

  Future<void> fetchAnalyticsSummary() async {
    if (_summaryRequest != null) return _summaryRequest!;
    if (_summaryData.totalContent > 0 ||
        _summaryData.totalViews > 0 ||
        _summaryData.totalRevenue > 0) {
      return;
    }
    isSummaryLoading = true;
    summaryLoadError = null;
    notifyListeners();

    _summaryRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final response = await apiHelper.getApi(ApiConstant.analyticsSummary);
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final summaryResponse = AnalyticsSummaryResponse.fromJson(responseBody);

        if (summaryResponse.isSuccess == true) {
          _summaryData = summaryResponse.data ?? AnalyticsSummaryData();
        } else {
          summaryLoadError =
              summaryResponse.message ?? 'Unable to load analytics summary.';
        }
      } catch (error) {
        summaryLoadError = 'Unable to load analytics summary.';
        debugPrint("Analytics summary load failed: $error");
      } finally {
        isSummaryLoading = false;
        _summaryRequest = null;
        notifyListeners();
      }
    })();
    return _summaryRequest!;
  }

  Future<void> fetchLocationWiseAnalytics({bool forceRefresh = false}) async {
    if (_locationRequest != null) return _locationRequest!;
    if (!forceRefresh && _locationWiseAnalytics.isNotEmpty) return;
    isLocationAnalyticsLoading = true;
    locationAnalyticsError = null;
    notifyListeners();

    _locationRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final response =
            await apiHelper.getApi(ApiConstant.locationWiseAnalytics);
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final parsed = LocationAnalyticsResponseModel.fromJson(responseBody);
        if (parsed.success == true) {
          _locationWiseAnalytics = _dedupeLocationRows(parsed.data);
        } else {
          _locationWiseAnalytics = [];
          locationAnalyticsError =
              parsed.message ?? 'Unable to load location analytics.';
        }
      } catch (error) {
        _locationWiseAnalytics = [];
        locationAnalyticsError = 'Unable to load location analytics.';
        debugPrint("Location analytics load failed: $error");
      } finally {
        isLocationAnalyticsLoading = false;
        _locationRequest = null;
        notifyListeners();
      }
    })();
    return _locationRequest!;
  }

  Future<void> fetchAgeWiseAnalytics({bool forceRefresh = false}) async {
    if (_ageRequest != null) return _ageRequest!;
    if (!forceRefresh &&
        (_ageWiseRevenue.isNotEmpty || _ageWiseViews.isNotEmpty)) {
      return;
    }
    isAgeAnalyticsLoading = true;
    ageAnalyticsError = null;
    notifyListeners();

    _ageRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final responses = await Future.wait([
          apiHelper.getApi(ApiConstant.ageWiseRevenueAnalytics),
          apiHelper.getApi(ApiConstant.ageWiseViewsAnalytics),
        ]);
        final revenueBody =
            json.decode(responses[0].body) as Map<String, dynamic>;
        final viewsBody =
            json.decode(responses[1].body) as Map<String, dynamic>;
        final revenue = AgeWiseRevenueResponseModel.fromJson(revenueBody);
        final views = AgeWiseViewsResponseModel.fromJson(viewsBody);
        if (revenue.success == true || views.success == true) {
          _ageWiseRevenue = _dedupeAgeRevenue(revenue.data);
          _ageWiseViews = _dedupeAgeViews(views.data);
        } else {
          _ageWiseRevenue = [];
          _ageWiseViews = [];
          ageAnalyticsError = revenue.message ??
              views.message ??
              'Unable to load age-wise analytics.';
        }
      } catch (error) {
        _ageWiseRevenue = [];
        _ageWiseViews = [];
        ageAnalyticsError = 'Unable to load age-wise analytics.';
        debugPrint("Age analytics load failed: $error");
      } finally {
        isAgeAnalyticsLoading = false;
        _ageRequest = null;
        notifyListeners();
      }
    })();
    return _ageRequest!;
  }

  Future<void> fetchContentPerformanceAnalytics({
    bool forceRefresh = false,
  }) async {
    if (_contentPerformanceRequest != null) return _contentPerformanceRequest!;
    if (!forceRefresh && _contentPerformanceAnalytics != null) return;
    isContentPerformanceLoading = true;
    contentPerformanceError = null;
    notifyListeners();

    _contentPerformanceRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final response =
            await apiHelper.getApi(ApiConstant.contentPerformanceAnalytics);
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final parsed =
            ContentPerformanceAnalyticsResponseModel.fromJson(responseBody);
        if (parsed.success == true && parsed.data != null) {
          _contentPerformanceAnalytics = parsed.data;
        } else {
          _contentPerformanceAnalytics = null;
          contentPerformanceError =
              parsed.message ?? 'Unable to load content performance analytics.';
        }
      } catch (error) {
        _contentPerformanceAnalytics = null;
        contentPerformanceError =
            'Unable to load content performance analytics.';
        debugPrint("Content performance analytics load failed: $error");
      } finally {
        isContentPerformanceLoading = false;
        _contentPerformanceRequest = null;
        notifyListeners();
      }
    })();
    return _contentPerformanceRequest!;
  }

  Future<void> fetchDeviceAnalytics({bool forceRefresh = false}) async {
    if (_deviceRequest != null) return _deviceRequest!;
    if (!forceRefresh && _deviceAnalytics.isNotEmpty) return;
    isDeviceAnalyticsLoading = true;
    deviceAnalyticsError = null;
    notifyListeners();

    _deviceRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final response = await apiHelper.getApi(ApiConstant.deviceAnalytics);
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DeviceAnalyticsResponseModel.fromJson(responseBody);
        if (parsed.success == true) {
          _deviceAnalytics = _dedupeDeviceRows(parsed.data);
        } else {
          _deviceAnalytics = [];
          deviceAnalyticsError =
              parsed.message ?? 'Unable to load device analytics.';
        }
      } catch (error) {
        _deviceAnalytics = [];
        deviceAnalyticsError = 'Unable to load device analytics.';
        debugPrint("Device analytics load failed: $error");
      } finally {
        isDeviceAnalyticsLoading = false;
        _deviceRequest = null;
        notifyListeners();
      }
    })();
    return _deviceRequest!;
  }

  Future<void> fetchEngagementAnalytics({bool forceRefresh = false}) async {
    if (_engagementRequest != null) return _engagementRequest!;
    if (!forceRefresh && _engagementAnalytics != null) return;
    isEngagementAnalyticsLoading = true;
    engagementAnalyticsError = null;
    notifyListeners();

    _engagementRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final response =
            await apiHelper.getApi(ApiConstant.engagementAnalytics);
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final parsed = EngagementAnalyticsResponseModel.fromJson(responseBody);
        if (parsed.success == true && parsed.data != null) {
          _engagementAnalytics = parsed.data;
        } else {
          _engagementAnalytics = null;
          engagementAnalyticsError =
              parsed.message ?? 'Unable to load engagement analytics.';
        }
      } catch (error) {
        _engagementAnalytics = null;
        engagementAnalyticsError = 'Unable to load engagement analytics.';
        debugPrint("Engagement analytics load failed: $error");
      } finally {
        isEngagementAnalyticsLoading = false;
        _engagementRequest = null;
        notifyListeners();
      }
    })();
    return _engagementRequest!;
  }

  Future<void> fetchWatchTimeAnalytics({bool forceRefresh = false}) async {
    if (_watchTimeRequest != null) return _watchTimeRequest!;
    if (!forceRefresh && _watchTimeAnalytics != null) return;
    isWatchTimeAnalyticsLoading = true;
    watchTimeAnalyticsError = null;
    notifyListeners();

    _watchTimeRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final response = await apiHelper.getApi(ApiConstant.watchTimeAnalytics);
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final parsed = WatchTimeAnalyticsResponseModel.fromJson(responseBody);
        if (parsed.success == true && parsed.data != null) {
          _watchTimeAnalytics = parsed.data;
        } else {
          _watchTimeAnalytics = null;
          watchTimeAnalyticsError =
              parsed.message ?? 'Unable to load watch time analytics.';
        }
      } catch (error) {
        _watchTimeAnalytics = null;
        watchTimeAnalyticsError = 'Unable to load watch time analytics.';
        debugPrint("Watch time analytics load failed: $error");
      } finally {
        isWatchTimeAnalyticsLoading = false;
        _watchTimeRequest = null;
        notifyListeners();
      }
    })();
    return _watchTimeRequest!;
  }

  Future<void> fetchDateWiseAnalytics({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    if (_dateWiseRequest != null) return _dateWiseRequest!;
    isDateWiseAnalyticsLoading = true;
    dateWiseAnalyticsError = null;
    notifyListeners();

    _dateWiseRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final requestFormat = DateFormat('dd-MM-yyyy');
        final response = await apiHelper.getApi(
          ApiConstant.dateWiseAnalytics(
            requestFormat.format(fromDate),
            requestFormat.format(toDate),
          ),
        );
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DateWiseAnalyticsResponseModel.fromJson(responseBody);
        if (parsed.success == true) {
          _dateWiseAnalytics =
              List<DateWiseAnalyticsDataModel>.from(parsed.data)
                ..sort((a, b) {
                  final first =
                      a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final second =
                      b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return first.compareTo(second);
                });
        } else {
          _dateWiseAnalytics = [];
          dateWiseAnalyticsError =
              parsed.message ?? 'Unable to load date-wise analytics.';
        }
      } catch (error) {
        _dateWiseAnalytics = [];
        dateWiseAnalyticsError = 'Unable to load date-wise analytics.';
        debugPrint("Date-wise analytics load failed: $error");
      } finally {
        isDateWiseAnalyticsLoading = false;
        _dateWiseRequest = null;
        notifyListeners();
      }
    })();
    return _dateWiseRequest!;
  }

  List<DeviceAnalyticsDataModel> _dedupeDeviceRows(
    List<DeviceAnalyticsDataModel> rows,
  ) {
    final grouped = <String, DeviceAnalyticsDataModel>{};
    for (final row in rows) {
      final existing = grouped[row.device];
      if (existing == null) {
        grouped[row.device] = row;
      } else {
        final users = existing.users + row.users;
        grouped[row.device] = DeviceAnalyticsDataModel(
          device: row.device,
          users: users,
          revenue: existing.revenue + row.revenue,
          watchHours: existing.watchHours + row.watchHours,
          avgSessionTime: users == 0
              ? 0
              : ((existing.avgSessionTime * existing.users) +
                      (row.avgSessionTime * row.users)) /
                  users,
        );
      }
    }
    final order = ['Android', 'iOS', 'Web', 'Smart TV', 'Tablet', 'Unknown'];
    final ordered = [
      for (final device in order)
        grouped[device] ??
            DeviceAnalyticsDataModel(
              device: device,
              users: 0,
              revenue: 0,
              watchHours: 0,
              avgSessionTime: 0,
            ),
    ];
    final extras =
        grouped.values.where((row) => !order.contains(row.device)).toList();
    return [...ordered, ...extras];
  }

  List<AgeWiseRevenueDataModel> _dedupeAgeRevenue(
    List<AgeWiseRevenueDataModel> rows,
  ) {
    final grouped = <String, AgeWiseRevenueDataModel>{};
    for (final row in rows) {
      final existing = grouped[row.ageGroup];
      if (existing == null) {
        grouped[row.ageGroup] = row;
      } else {
        final users = existing.users + row.users;
        grouped[row.ageGroup] = AgeWiseRevenueDataModel(
          ageGroup: row.ageGroup,
          users: users,
          revenue: existing.revenue + row.revenue,
          subscriptionRevenue:
              existing.subscriptionRevenue + row.subscriptionRevenue,
          coinRevenue: existing.coinRevenue + row.coinRevenue,
          avgWatchTime: users == 0
              ? 0
              : ((existing.avgWatchTime * existing.users) +
                      (row.avgWatchTime * row.users)) /
                  users,
          retentionRate: users == 0
              ? 0
              : ((existing.retentionRate * existing.users) +
                      (row.retentionRate * row.users)) /
                  users,
        );
      }
    }
    return _orderedAgeRevenue(grouped);
  }

  List<AgeWiseViewsDataModel> _dedupeAgeViews(
    List<AgeWiseViewsDataModel> rows,
  ) {
    final grouped = <String, AgeWiseViewsDataModel>{};
    for (final row in rows) {
      final existing = grouped[row.ageGroup];
      if (existing == null) {
        grouped[row.ageGroup] = row;
      } else {
        final uniqueUsers = existing.uniqueUsers + row.uniqueUsers;
        grouped[row.ageGroup] = AgeWiseViewsDataModel(
          ageGroup: row.ageGroup,
          views: existing.views + row.views,
          uniqueUsers: uniqueUsers,
          watchHours: existing.watchHours + row.watchHours,
          completionRate: uniqueUsers == 0
              ? 0
              : ((existing.completionRate * existing.uniqueUsers) +
                      (row.completionRate * row.uniqueUsers)) /
                  uniqueUsers,
          rewatchRate: uniqueUsers == 0
              ? 0
              : ((existing.rewatchRate * existing.uniqueUsers) +
                      (row.rewatchRate * row.uniqueUsers)) /
                  uniqueUsers,
        );
      }
    }
    return _orderedAgeViews(grouped);
  }

  List<AgeWiseRevenueDataModel> _orderedAgeRevenue(
    Map<String, AgeWiseRevenueDataModel> rows,
  ) {
    const order = [
      '13-18',
      '18-24',
      '25-34',
      '35-44',
      '45-60',
      '60+',
      'Unknown'
    ];
    return [
      for (final age in order)
        rows[age] ??
            AgeWiseRevenueDataModel(
              ageGroup: age,
              users: 0,
              revenue: 0,
              subscriptionRevenue: 0,
              coinRevenue: 0,
              avgWatchTime: 0,
              retentionRate: 0,
            ),
    ];
  }

  List<AgeWiseViewsDataModel> _orderedAgeViews(
    Map<String, AgeWiseViewsDataModel> rows,
  ) {
    const order = [
      '13-18',
      '18-24',
      '25-34',
      '35-44',
      '45-60',
      '60+',
      'Unknown'
    ];
    return [
      for (final age in order)
        rows[age] ??
            AgeWiseViewsDataModel(
              ageGroup: age,
              views: 0,
              uniqueUsers: 0,
              watchHours: 0,
              completionRate: 0,
              rewatchRate: 0,
            ),
    ];
  }

  List<LocationAnalyticsDataModel> _dedupeLocationRows(
    List<LocationAnalyticsDataModel> rows,
  ) {
    final grouped = <String, LocationAnalyticsDataModel>{};
    for (final row in rows) {
      final key = [
        row.country,
        row.state,
        row.district,
        row.city,
      ].map((value) => value.trim().toLowerCase()).join('|');
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = row;
      } else {
        final totalUsers = existing.totalUsers + row.totalUsers;
        final weightedCompletion = totalUsers == 0
            ? 0.0
            : ((existing.completionRate * existing.totalUsers) +
                    (row.completionRate * row.totalUsers)) /
                totalUsers;
        grouped[key] = LocationAnalyticsDataModel(
          country: existing.country,
          state: existing.state,
          district: existing.district,
          city: existing.city,
          totalUsers: totalUsers,
          paidUsers: existing.paidUsers + row.paidUsers,
          views: existing.views + row.views,
          watchHours: existing.watchHours + row.watchHours,
          revenue: existing.revenue + row.revenue,
          completionRate: weightedCompletion,
        );
      }
    }
    return grouped.values.toList()
      ..sort((first, second) => second.revenue.compareTo(first.revenue));
  }

  List<ReportAndDataObject> _reportAndDataList = [];
  List<ReportAndDataObject> get reportAndDataList => _reportAndDataList;

  Future<void> getReportAndData({
    String contentType = "ALL",
    String country = "",
    String state = "",
    String district = "",
    String taluka = "",
    String city = "",
    String startDate = "",
    String endDate = "",
    String ageGroup = "ALL",
    String gender = "ALL",
  }) async {
    final cacheKey = _reportCacheKey(
      contentType: contentType,
      country: country,
      state: state,
      district: district,
      taluka: taluka,
      city: city,
      startDate: startDate,
      endDate: endDate,
      ageGroup: ageGroup,
      gender: gender,
    );
    final cachedRows = _reportCache[cacheKey];
    if (cachedRows != null) {
      _reportAndDataList = List<ReportAndDataObject>.from(cachedRows);
      reportLoadError = null;
      notifyListeners();
      return;
    }
    if (_reportRequest != null && _reportRequestKey == cacheKey) {
      return _reportRequest!;
    }
    _reportRequestKey = cacheKey;
    isReportLoading = true;
    reportLoadError = null;
    notifyListeners();
    _reportRequest = (() async {
      try {
        final apiHelper = ApiHelper();
        final isDefaultQuery = _isDefaultReportQuery(
          contentType: contentType,
          country: country,
          state: state,
          district: district,
          taluka: taluka,
          city: city,
          startDate: startDate,
          endDate: endDate,
          ageGroup: ageGroup,
          gender: gender,
        );
        final apiUrl = isDefaultQuery
            ? ApiConstant.reportAndDataMediaHouseBase
            : ApiConstant.reportAndDataMediaHouse(
                contentType: contentType,
                country: country,
                state: state,
                district: district,
                taluka: taluka,
                city: city,
                startDate: startDate,
                endDate: endDate,
                ageGroup: ageGroup,
                gender: gender,
              );
        var response = await apiHelper.getApi(apiUrl);
        Map<String, dynamic> responseBody = json.decode(response.body);
        ReportAndDataResponse reportAndDataResponse =
            ReportAndDataResponse.fromJson(responseBody);
        if (reportAndDataResponse.success == true) {
          _reportAndDataList = reportAndDataResponse.data?.mediaHouse ?? [];
          if (_reportAndDataList.isEmpty && isDefaultQuery) {
            _reportAndDataList = await _getLegacyReportRows(apiHelper);
          }
          _reportCache[cacheKey] = List<ReportAndDataObject>.from(
            _reportAndDataList,
          );
        } else {
          _reportAndDataList = [];
          reportLoadError =
              reportAndDataResponse.message ?? 'Unable to load report data.';
          CustomToast.show(
            reportAndDataResponse.message.toString(),
            isSuccess: false,
          );
        }
      } catch (error) {
        _reportAndDataList = [];
        reportLoadError = 'Unable to load report data.';
        debugPrint("Analytics report load failed: $error");
      } finally {
        isReportLoading = false;
        _reportRequest = null;
        _reportRequestKey = null;
        notifyListeners();
      }
    })();
    return _reportRequest!;
  }

  String _reportCacheKey({
    required String contentType,
    required String country,
    required String state,
    required String district,
    required String taluka,
    required String city,
    required String startDate,
    required String endDate,
    required String ageGroup,
    required String gender,
  }) {
    return [
      contentType,
      country.trim(),
      state.trim(),
      district.trim(),
      taluka.trim(),
      city.trim(),
      startDate.trim(),
      endDate.trim(),
      ageGroup,
      gender,
    ].join('|');
  }

  bool _isDefaultReportQuery({
    required String contentType,
    required String country,
    required String state,
    required String district,
    required String taluka,
    required String city,
    required String startDate,
    required String endDate,
    required String ageGroup,
    required String gender,
  }) {
    return contentType == "ALL" &&
        country.trim().isEmpty &&
        state.trim().isEmpty &&
        district.trim().isEmpty &&
        taluka.trim().isEmpty &&
        city.trim().isEmpty &&
        startDate.trim().isEmpty &&
        endDate.trim().isEmpty &&
        ageGroup == "ALL" &&
        gender == "ALL";
  }

  Future<List<ReportAndDataObject>> _getLegacyReportRows(
    ApiHelper apiHelper,
  ) async {
    try {
      final response = await apiHelper.getApi(ApiConstant.reportAndData);
      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      final reportAndDataResponse =
          ReportAndDataResponse.fromJson(responseBody);
      if (reportAndDataResponse.success == true) {
        return reportAndDataResponse.data?.mediaHouse ?? [];
      }
    } catch (error) {
      debugPrint("Analytics legacy report load failed: $error");
    }
    return [];
  }
}

class AnalyticsSummaryResponse {
  AnalyticsSummaryResponse({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  final AnalyticsSummaryData? data;
  final String? message;
  final int? statusCode;
  final bool? isSuccess;

  factory AnalyticsSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryResponse(
      data: json["data"] is Map<String, dynamic>
          ? AnalyticsSummaryData.fromJson(json["data"])
          : null,
      message: json["message"]?.toString(),
      statusCode: _asInt(json["statusCode"]),
      isSuccess: json["isSuccess"] == true || json["success"] == true,
    );
  }
}

class AnalyticsSummaryData {
  AnalyticsSummaryData({
    this.totalMovies = 0,
    this.totalShorts = 0,
    this.totalContent = 0,
    this.totalViews = 0,
    this.totalRevenue = 0,
    this.totalMediaHouses = 0,
    this.totalSeries = 0,
  });

  final int totalMovies;
  final int totalShorts;
  final int totalContent;
  final int totalViews;
  final num totalRevenue;
  final int totalMediaHouses;
  final int totalSeries;

  factory AnalyticsSummaryData.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryData(
      totalMovies: _asInt(json["totalMovies"]) ?? 0,
      totalShorts: _asInt(json["totalShorts"]) ?? 0,
      totalContent: _asInt(json["totalContent"]) ?? 0,
      totalViews: _asInt(json["totalViews"]) ?? 0,
      totalRevenue: _asNum(json["totalRevenue"]) ?? 0,
      totalMediaHouses: _asInt(json["totalMediaHouses"]) ?? 0,
      totalSeries: _asInt(json["totalSeries"]) ?? 0,
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

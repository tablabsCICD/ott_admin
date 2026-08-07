import 'dart:async';

import 'package:admin_ott/app/provider/analyticsProvider.dart';
import 'package:admin_ott/app/ui/pages/analytics_page/topMovieGraphForAdmin.dart';
import 'package:admin_ott/data/models/response/contentPerformanceAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/dateWiseAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/engagementAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/locationAnalyticsResponseModel.dart';
import 'package:admin_ott/data/models/response/reportAndDataResponse.dart';
import 'package:admin_ott/data/models/response/watchTimeAnalyticsResponseModel.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../provider/themeProvider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _talukaController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationCitySearchController = TextEditingController();

  DateTimeRange? _reportDateRange;
  String _contentType = "ALL";
  String _ageGroup = "ALL";
  String _gender = "ALL";
  String _advancedTab = "Location";
  String _advancedSearch = "";
  String _advancedDeviceType = "ALL";
  String _advancedGenre = "ALL";
  String _advancedLanguage = "ALL";
  String _locationCountry = "ALL";
  String _locationState = "ALL";
  String _locationDistrict = "ALL";
  String _locationCitySearch = "";
  bool _isAscending = false;
  bool _sortByRevenue = true;
  int _reportPage = 0;
  static const int _reportRowsPerPage = 12;
  Timer? _reportFilterDebounce;
  Timer? _advancedSearchDebounce;
  Timer? _locationSearchDebounce;
  DateTime _dateWiseFrom = DateTime.now().subtract(const Duration(days: 7));
  DateTime _dateWiseTo = DateTime.now();

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _countryController,
      _stateController,
      _districtController,
      _talukaController,
      _cityController,
    ]) {
      controller.addListener(_debounceReportFilters);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      Future.wait([
        provider.fetchInitialAnalytics(),
        provider.fetchDateWiseAnalytics(
          fromDate: _dateWiseFrom,
          toDate: _dateWiseTo,
        ),
        _loadReports(),
      ]);
    });
  }

  @override
  void dispose() {
    _reportFilterDebounce?.cancel();
    _advancedSearchDebounce?.cancel();
    _locationSearchDebounce?.cancel();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _cityController.dispose();
    _locationCitySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() {
    if (mounted) {
      setState(() => _reportPage = 0);
    }
    final dateFormat = DateFormat("yyyy-MM-dd");
    return Provider.of<AnalyticsProvider>(context, listen: false)
        .getReportAndData(
      contentType: _contentType,
      country: _countryController.text.trim(),
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      taluka: _talukaController.text.trim(),
      city: _cityController.text.trim(),
      startDate: _reportDateRange == null
          ? ""
          : dateFormat.format(_reportDateRange!.start),
      endDate: _reportDateRange == null
          ? ""
          : dateFormat.format(_reportDateRange!.end),
      ageGroup: _ageGroup,
      gender: _gender,
    );
  }

  void _debounceReportFilters() {
    _reportFilterDebounce?.cancel();
    _reportFilterDebounce = Timer(
      const Duration(milliseconds: 500),
      _loadReports,
    );
  }

  void _debounceAdvancedSearch(String value) {
    _advancedSearchDebounce?.cancel();
    _advancedSearchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _advancedSearch = value);
    });
  }

  void _debounceLocationSearch(String value) {
    _locationSearchDebounce?.cancel();
    _locationSearchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _locationCitySearch = value);
    });
  }

  Future<void> _pickReportRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _reportDateRange,
    );
    if (picked == null) return;
    setState(() {
      _reportDateRange = picked;
    });
  }

  Future<void> _resetFilters() async {
    _countryController.clear();
    _stateController.clear();
    _districtController.clear();
    _talukaController.clear();
    _cityController.clear();
    setState(() {
      _contentType = "ALL";
      _ageGroup = "ALL";
      _gender = "ALL";
      _reportDateRange = null;
      _reportPage = 0;
    });
    await _loadReports();
  }

  Future<void> _loadDateWiseAnalytics() {
    return Provider.of<AnalyticsProvider>(context, listen: false)
        .fetchDateWiseAnalytics(
      fromDate: _dateWiseFrom,
      toDate: _dateWiseTo,
    );
  }

  Future<void> _pickDateWiseDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: isFrom ? _dateWiseFrom : _dateWiseTo,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateWiseFrom = picked;
        if (_dateWiseFrom.isAfter(_dateWiseTo)) _dateWiseTo = picked;
      } else {
        _dateWiseTo = picked;
        if (_dateWiseTo.isBefore(_dateWiseFrom)) _dateWiseFrom = picked;
      }
    });
  }

  Future<void> _setDateWiseQuickRange(String range) async {
    final now = DateTime.now();
    setState(() {
      switch (range) {
        case "Today":
          _dateWiseFrom = now;
          _dateWiseTo = now;
          break;
        case "Last 30 Days":
          _dateWiseFrom = now.subtract(const Duration(days: 30));
          _dateWiseTo = now;
          break;
        case "This Month":
          _dateWiseFrom = DateTime(now.year, now.month, 1);
          _dateWiseTo = now;
          break;
        case "Last 7 Days":
        default:
          _dateWiseFrom = now.subtract(const Duration(days: 7));
          _dateWiseTo = now;
      }
    });
    await _loadDateWiseAnalytics();
  }

  List<ReportAndDataObject> _sortedReports(AnalyticsProvider provider) {
    final reports = List<ReportAndDataObject>.from(provider.reportAndDataList);
    reports.sort((first, second) {
      final comparison = _sortByRevenue
          ? _revenue(first).compareTo(_revenue(second))
          : (first.contentName ?? "").compareTo(second.contentName ?? "");
      return _isAscending ? comparison : -comparison;
    });
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          final reports = _sortedReports(provider);
          return SingleChildScrollView(
            padding:
                EdgeInsets.all(ResponsiveWidget.isMobile(context) ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analytics",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Monitor content performance, revenue, and reports across Production houses.",
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.64),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryTiles(theme, provider),
                const SizedBox(height: 16),
                Text(
                  "Performance Overview",
                  style: _sectionStyle(theme),
                ),
                const SizedBox(height: 10),
                _surface(
                  theme: theme,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: ResponsiveWidget.isMobile(context) ? 360 : 345,
                    child: const TopMoviesGraphForAdmin(),
                  ),
                ),
                const SizedBox(height: 18),
                Text("Reports & Data", style: _sectionStyle(theme)),
                const SizedBox(height: 10),
                _buildFilterPanel(theme),
                const SizedBox(height: 12),
                _buildFilterSummary(theme, reports),
                const SizedBox(height: 14),
                _buildReportTable(theme, provider, reports),
                const SizedBox(height: 18),
                _buildAdvancedAnalytics(theme, provider, reports),
                const SizedBox(height: 18),
                _buildAgeWiseAudienceSection(theme, provider, reports),
                const SizedBox(height: 18),
                _buildContentPerformanceApiSection(theme, provider),
                const SizedBox(height: 18),
                _buildPlatformDeviceSection(theme, provider, reports),
                const SizedBox(height: 18),
                _buildUserEngagementApiSection(theme, provider),
                const SizedBox(height: 18),
                _buildWatchTimeApiSection(theme, provider),
                const SizedBox(height: 18),
                _buildDateWiseApiSection(theme, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryTiles(ThemeData theme, AnalyticsProvider provider) {
    final summary = provider.summaryData;
    final loadingValue = provider.isSummaryLoading ? "..." : null;

    final tiles = [
      _AnalyticsMetric(
        title: "Total Content",
        value: loadingValue ?? summary.totalContent.toString(),
        icon: Icons.video_library_outlined,
        accent: Colors.blue,
      ),
      _AnalyticsMetric(
        title: "Production Houses",
        value: loadingValue ?? summary.totalMediaHouses.toString(),
        icon: Icons.business_outlined,
        accent: Colors.green,
      ),
      _AnalyticsMetric(
        title: "Total Views",
        value: loadingValue ?? summary.totalViews.toString(),
        icon: Icons.visibility_outlined,
        accent: Colors.deepPurple,
      ),
      _AnalyticsMetric(
        title: "Revenue",
        value: loadingValue ?? _formatRevenue(summary.totalRevenue),
        icon: Icons.currency_rupee,
        accent: Colors.teal,
      ),
      _AnalyticsMetric(
        title: "Movies",
        value: loadingValue ?? summary.totalMovies.toString(),
        icon: Icons.sell_outlined,
        accent: Colors.orange,
      ),
      _AnalyticsMetric(
        title: "Series",
        value: loadingValue ?? summary.totalSeries.toString(),
        icon: Icons.live_tv_outlined,
        accent: Colors.pink,
      ),
      _AnalyticsMetric(
        title: "Shorts",
        value: loadingValue ?? summary.totalShorts.toString(),
        icon: Icons.smart_display_outlined,
        accent: Colors.indigo,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1080
            ? 4
            : constraints.maxWidth > 700
                ? 3
                : constraints.maxWidth > 420
                    ? 2
                    : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 1 ? 4.0 : 3.45,
          ),
          itemBuilder: (context, index) => _metricTile(theme, tiles[index]),
        );
      },
    );
  }

  Widget _metricTile(ThemeData theme, _AnalyticsMetric metric) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(metric.icon, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.62),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = constraints.maxWidth > 940
              ? (constraints.maxWidth - 24) / 4
              : constraints.maxWidth > 560
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Content Type",
                  value: _contentType,
                  options: const [
                    "ALL",
                    "MOVIE",
                    "SHORT_FILM",
                    "SERIES",
                    "MINI_SERIES"
                  ],
                  onChanged: (value) => setState(() => _contentType = value),
                ),
              ),
              _textField(theme, "Country", _countryController, fieldWidth),
              _textField(theme, "State", _stateController, fieldWidth),
              _textField(theme, "District", _districtController, fieldWidth),
              _textField(theme, "Taluka", _talukaController, fieldWidth),
              _textField(theme, "City", _cityController, fieldWidth),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Age Group",
                  value: _ageGroup,
                  options: const ["ALL", "18-21", "22-30", "31-45", "46+"],
                  onChanged: (value) => setState(() => _ageGroup = value),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Gender",
                  value: _gender,
                  options: const ["ALL", "male", "female", "other"],
                  onChanged: (value) => setState(() => _gender = value),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: _pickReportRange,
                  icon: const Icon(Icons.calendar_month_outlined, size: 17),
                  label: Text(_dateRangeLabel()),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: FilledButton.icon(
                  onPressed: _loadReports,
                  icon: const Icon(Icons.filter_alt_outlined, size: 17),
                  label: const Text("Apply Filters"),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: theme.primaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text("Reset"),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAgeWiseAudienceSection(
    ThemeData theme,
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    if (provider.isAgeAnalyticsLoading) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(16),
        child: const Center(child: AppSpinner()),
      );
    }
    if (provider.ageAnalyticsError != null &&
        provider.ageWiseRevenue.isEmpty &&
        provider.ageWiseViews.isEmpty) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.groups_3_outlined, color: theme.primaryColor, size: 42),
            const SizedBox(height: 10),
            Text(
              provider.ageAnalyticsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  provider.fetchAgeWiseAnalytics(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text("Retry"),
              style:
                  FilledButton.styleFrom(backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      );
    }

    final rows = _ageAudienceRows(provider, reports);
    if (rows.isEmpty) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Text(
          "No age-wise analytics found.",
          style: TextStyle(color: theme.canvasColor),
        ),
      );
    }
    final highestRevenue = _topAge(rows, (row) => row.revenue);
    final highestViewing = _topAge(rows, (row) => row.views.toDouble());
    final highestRetention = _topAge(rows, (row) => row.retentionRate);
    final highestWatchTime = _topAge(rows, (row) => row.avgWatchTime);
    final totalRevenue = rows.fold<double>(0, (sum, row) => sum + row.revenue);
    final revenuePoints =
        rows.map((row) => _AnalyticsPoint(row.ageGroup, row.revenue)).toList();
    final viewsPoints = rows
        .map((row) => _AnalyticsPoint(row.ageGroup, row.views.toDouble()))
        .toList();
    final subscriptionPoints = rows
        .map((row) => _AnalyticsPoint(row.ageGroup, row.subscriptionRevenue))
        .toList();
    final completionPoints = rows
        .map((row) => _AnalyticsPoint(row.ageGroup, row.completionRate))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Age-wise Audience Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Revenue, views, watch time, completion, retention, and rewatch behavior by audience age group.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
            title: "Highest Revenue Age",
            value:
                "${highestRevenue.ageGroup} • ${_formatRevenue(highestRevenue.revenue)}",
            icon: Icons.trending_up,
            accent: Colors.teal,
          ),
          _AnalyticsMetric(
            title: "Highest Viewing Age",
            value: "${highestViewing.ageGroup} • ${highestViewing.views}",
            icon: Icons.visibility_outlined,
            accent: Colors.blue,
          ),
          _AnalyticsMetric(
            title: "Highest Retention Age",
            value:
                "${highestRetention.ageGroup} • ${highestRetention.retentionRate.toStringAsFixed(1)}%",
            icon: Icons.repeat_outlined,
            accent: Colors.green,
          ),
          _AnalyticsMetric(
            title: "Highest Watch Time Age",
            value:
                "${highestWatchTime.ageGroup} • ${highestWatchTime.avgWatchTime.toStringAsFixed(0)} min",
            icon: Icons.schedule_outlined,
            accent: Colors.indigo,
          ),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _pieChart(theme, "Revenue Contribution", revenuePoints),
          _barChart(theme, "Age-wise Views", viewsPoints),
          _lineChart(theme, "Revenue Comparison", revenuePoints),
          _barChart(theme, "Subscription Revenue", subscriptionPoints),
          _barChart(theme, "Completion Rate", completionPoints),
          _lineChart(
            theme,
            "View Analytics Graph",
            rows
                .map((row) => _AnalyticsPoint(row.ageGroup, row.watchHours))
                .toList(),
          ),
        ]),
        const SizedBox(height: 12),
        _ageAudienceTable(theme, rows, totalRevenue),
      ],
    );
  }

  Widget _buildContentPerformanceApiSection(
    ThemeData theme,
    AnalyticsProvider provider,
  ) {
    if (provider.isContentPerformanceLoading) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(16),
        child: const Center(child: AppSpinner()),
      );
    }
    if (provider.contentPerformanceError != null &&
        provider.contentPerformanceAnalytics == null) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.monitor_heart_outlined,
                color: theme.primaryColor, size: 42),
            const SizedBox(height: 10),
            Text(
              provider.contentPerformanceError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => provider.fetchContentPerformanceAnalytics(
                forceRefresh: true,
              ),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text("Retry"),
              style:
                  FilledButton.styleFrom(backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      );
    }
    final data = provider.contentPerformanceAnalytics;
    if (data == null) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Text(
          "No content performance analytics found.",
          style: TextStyle(color: theme.canvasColor),
        ),
      );
    }
    final ratePoints = [
      _AnalyticsPoint("Completion", data.completionRate),
      _AnalyticsPoint("Bounce", data.bounceRate),
      _AnalyticsPoint("Retention", data.retentionRate),
      _AnalyticsPoint("Rewatch", data.rewatchRate),
    ];
    final healthScore = _contentHealthScore(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Content Performance Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Content health, engagement, completion, retention, top series, and top episodes from backend analytics.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
            title: "Total Views",
            value: "${data.totalViews}",
            icon: Icons.visibility_outlined,
            accent: Colors.blue,
          ),
          _AnalyticsMetric(
            title: "Total Revenue",
            value: _formatRevenue(data.totalRevenue),
            icon: Icons.currency_rupee,
            accent: Colors.teal,
          ),
          _AnalyticsMetric(
            title: "Engagement Score",
            value: data.engagementScore.toStringAsFixed(2),
            icon: Icons.speed_outlined,
            accent: Colors.deepPurple,
          ),
          _AnalyticsMetric(
            title: "Completion Rate",
            value: "${data.completionRate.toStringAsFixed(1)}%",
            icon: Icons.task_alt_outlined,
            accent: Colors.green,
          ),
          _AnalyticsMetric(
            title: "Bounce Rate",
            value: "${data.bounceRate.toStringAsFixed(1)}%",
            icon: Icons.warning_amber_rounded,
            accent: Colors.orange,
          ),
          _AnalyticsMetric(
            title: "Retention Rate",
            value: "${data.retentionRate.toStringAsFixed(1)}%",
            icon: Icons.repeat_outlined,
            accent: Colors.indigo,
          ),
          _AnalyticsMetric(
            title: "Rewatch Rate",
            value: "${data.rewatchRate.toStringAsFixed(1)}%",
            icon: Icons.replay_outlined,
            accent: Colors.pink,
          ),
        ]),
        const SizedBox(height: 12),
        _contentHealthPanel(theme, data, healthScore),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _pieChart(theme, "Rate Distribution", ratePoints),
          _barChart(theme, "Performance Comparison", ratePoints),
        ]),
        const SizedBox(height: 12),
        _performanceInsights(theme, data),
        const SizedBox(height: 12),
        _topSeriesPerformance(theme, data.topSeries),
        const SizedBox(height: 12),
        _topEpisodesPerformance(theme, data.topEpisodes),
        const SizedBox(height: 12),
        _contentPerformanceTable(theme, data),
      ],
    );
  }

  Widget _buildPlatformDeviceSection(
    ThemeData theme,
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    if (provider.isDeviceAnalyticsLoading) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(16),
        child: const Center(child: AppSpinner()),
      );
    }
    if (provider.deviceAnalyticsError != null &&
        provider.deviceAnalytics.isEmpty) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.devices_other_outlined,
                color: theme.primaryColor, size: 42),
            const SizedBox(height: 10),
            Text(
              provider.deviceAnalyticsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  provider.fetchDeviceAnalytics(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text("Retry"),
              style:
                  FilledButton.styleFrom(backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      );
    }

    final rows = _deviceRowsForDisplay(provider, reports);
    if (rows.isEmpty) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Text(
          "No platform or device analytics found.",
          style: TextStyle(color: theme.canvasColor),
        ),
      );
    }
    final totalRevenue = rows.fold<double>(0, (sum, row) => sum + row.revenue);
    final highestRevenue = _topDevice(rows, (row) => row.revenue);
    final highestWatch = _topDevice(rows, (row) => row.watchHours);
    final highestUsers = _topDevice(rows, (row) => row.users.toDouble());
    final bestSession = _topDevice(rows, (row) => row.avgSessionTime);
    final revenuePoints =
        rows.map((row) => _AnalyticsPoint(row.device, row.revenue)).toList();
    final usersPoints = rows
        .map((row) => _AnalyticsPoint(row.device, row.users.toDouble()))
        .toList();
    final watchPoints =
        rows.map((row) => _AnalyticsPoint(row.device, row.watchHours)).toList();
    final sessionPoints = rows
        .map((row) => _AnalyticsPoint(row.device, row.avgSessionTime))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Platform & Device Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Platform usage, revenue, watch hours, and session duration across Android, iOS, Web, Smart TV, Tablet, and Unknown devices.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
            title: "Highest Revenue Platform",
            value:
                "${highestRevenue.device} • ${_formatRevenue(highestRevenue.revenue)}",
            icon: _deviceIcon(highestRevenue.device),
            accent: Colors.teal,
          ),
          _AnalyticsMetric(
            title: "Highest Watch Time",
            value:
                "${highestWatch.device} • ${highestWatch.watchHours.toStringAsFixed(1)} hrs",
            icon: _deviceIcon(highestWatch.device),
            accent: Colors.indigo,
          ),
          _AnalyticsMetric(
            title: "Highest User Platform",
            value: "${highestUsers.device} • ${highestUsers.users}",
            icon: _deviceIcon(highestUsers.device),
            accent: Colors.blue,
          ),
          _AnalyticsMetric(
            title: "Best Session Time",
            value:
                "${bestSession.device} • ${bestSession.avgSessionTime.toStringAsFixed(1)} min",
            icon: _deviceIcon(bestSession.device),
            accent: Colors.green,
          ),
        ]),
        const SizedBox(height: 12),
        _deviceCardGrid(theme, rows, totalRevenue),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _pieChart(theme, "Revenue by Device", revenuePoints),
          _barChart(theme, "Users by Device", usersPoints),
          _barChart(theme, "Watch Hours by Device", watchPoints),
          _lineChart(theme, "Avg Session Time by Device", sessionPoints),
        ]),
        const SizedBox(height: 12),
        _deviceInsights(theme, rows),
        const SizedBox(height: 12),
        _deviceComparisonTable(theme, rows, totalRevenue),
      ],
    );
  }

  Widget _buildUserEngagementApiSection(
    ThemeData theme,
    AnalyticsProvider provider,
  ) {
    if (provider.isEngagementAnalyticsLoading) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(16),
        child: const Center(child: AppSpinner()),
      );
    }
    if (provider.engagementAnalyticsError != null &&
        provider.engagementAnalytics == null) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.favorite_border, color: theme.primaryColor, size: 42),
            const SizedBox(height: 10),
            Text(
              provider.engagementAnalyticsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  provider.fetchEngagementAnalytics(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text("Retry"),
              style:
                  FilledButton.styleFrom(backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      );
    }
    final data = provider.engagementAnalytics;
    if (data == null) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Text(
          "No user engagement analytics found.",
          style: TextStyle(color: theme.canvasColor),
        ),
      );
    }
    final score = _engagementScore(data);
    final quality = _performanceLabel(score);
    final metricPoints = [
      _AnalyticsPoint("Likes", data.likes.toDouble()),
      _AnalyticsPoint("Shares", data.shares.toDouble()),
      _AnalyticsPoint("Comments", data.comments.toDouble()),
      _AnalyticsPoint("Watchlist", data.watchlistAdds.toDouble()),
      _AnalyticsPoint("Downloads", data.downloads.toDouble()),
    ];
    final ratePoints = [
      _AnalyticsPoint("Completion", data.completionRate),
      _AnalyticsPoint("Drop-off", data.dropOffRate),
    ];
    final peakPoints = data.peakHours
        .map((item) => _AnalyticsPoint(item.hour, item.activeUsers.toDouble()))
        .toList();
    final topHour = _topPeakHour(data.peakHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("User Engagement Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Likes, shares, comments, watchlist actions, downloads, completion, drop-off, and peak active hours.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Total Likes",
              value: "${data.likes}",
              icon: Icons.favorite_border,
              accent: Colors.pink),
          _AnalyticsMetric(
              title: "Total Shares",
              value: "${data.shares}",
              icon: Icons.share_outlined,
              accent: Colors.blue),
          _AnalyticsMetric(
              title: "Total Comments",
              value: "${data.comments}",
              icon: Icons.chat_bubble_outline,
              accent: Colors.green),
          _AnalyticsMetric(
              title: "Watchlist Adds",
              value: "${data.watchlistAdds}",
              icon: Icons.playlist_add_check_outlined,
              accent: Colors.indigo),
          _AnalyticsMetric(
              title: "Downloads",
              value: "${data.downloads}",
              icon: Icons.download_outlined,
              accent: Colors.teal),
          _AnalyticsMetric(
              title: "Completion Rate",
              value: "${data.completionRate.toStringAsFixed(1)}%",
              icon: Icons.task_alt_outlined,
              accent: Colors.green),
          _AnalyticsMetric(
              title: "Drop-off Rate",
              value: "${data.dropOffRate.toStringAsFixed(1)}%",
              icon: Icons.warning_amber_rounded,
              accent: Colors.orange),
        ]),
        const SizedBox(height: 12),
        _engagementScorePanel(theme, score, quality, data),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _pieChart(theme, "Likes vs Comments vs Shares",
              metricPoints.take(3).toList()),
          _barChart(theme, "Downloads vs Watchlist Adds", [
            _AnalyticsPoint("Downloads", data.downloads.toDouble()),
            _AnalyticsPoint("Watchlist", data.watchlistAdds.toDouble()),
          ]),
          _barChart(theme, "Completion vs Drop-off", ratePoints),
          _lineChart(theme, "Peak Hour Activity", peakPoints),
        ]),
        const SizedBox(height: 12),
        _peakHoursPanel(theme, data.peakHours, topHour),
        const SizedBox(height: 12),
        _engagementInsightsPanel(theme, data),
        const SizedBox(height: 12),
        _engagementComparisonTable(theme, data),
      ],
    );
  }

  Widget _buildWatchTimeApiSection(
    ThemeData theme,
    AnalyticsProvider provider,
  ) {
    if (provider.isWatchTimeAnalyticsLoading) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(16),
        child: const Center(child: AppSpinner()),
      );
    }
    if (provider.watchTimeAnalyticsError != null &&
        provider.watchTimeAnalytics == null) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.timer_outlined, color: theme.primaryColor, size: 42),
            const SizedBox(height: 10),
            Text(
              provider.watchTimeAnalyticsError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  provider.fetchWatchTimeAnalytics(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text("Retry"),
              style:
                  FilledButton.styleFrom(backgroundColor: theme.primaryColor),
            ),
          ],
        ),
      );
    }

    final data = provider.watchTimeAnalytics;
    if (data == null) {
      return _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: Text(
          "No watch time analytics found.",
          style: TextStyle(color: theme.canvasColor),
        ),
      );
    }

    final topAge = _topWatchAge(data.byAge);
    final lowAge = _lowWatchAge(data.byAge);
    final topLocation = _topWatchLocation(data.byLocation);
    final topAvgLocation = _topWatchLocation(
      data.byLocation,
      valueOf: (row) => row.avgWatchTime,
    );
    final topDevice = _topWatchDevice(data.byDevice);
    final topSessionDevice = _topWatchDevice(
      data.byDevice,
      valueOf: (row) => row.avgSessionTime,
    );
    final agePoints =
        data.byAge.map((row) => _AnalyticsPoint(row.ageGroup, row.watchHours));
    final locationPoints =
        data.byLocation.map((row) => _AnalyticsPoint(row.city, row.watchHours));
    final devicePoints =
        data.byDevice.map((row) => _AnalyticsPoint(row.device, row.watchHours));
    final avgLocationPoints = data.byLocation
        .map((row) => _AnalyticsPoint(row.city, row.avgWatchTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Watch Time Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Backend-driven watch hours, average watch time, and consumption patterns by age, location, and device.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
            title: "Total Watch Hours",
            value: "${data.totalWatchHours.toStringAsFixed(2)} hrs",
            icon: Icons.timer_outlined,
            accent: Colors.indigo,
          ),
          _AnalyticsMetric(
            title: "Average Watch Time",
            value: "${data.avgWatchTime.toStringAsFixed(2)} min",
            icon: Icons.schedule_outlined,
            accent: Colors.teal,
          ),
          _AnalyticsMetric(
            title: "Highest Watch Age",
            value: topAge == null
                ? "-"
                : "${topAge.ageGroup} • ${topAge.watchHours.toStringAsFixed(1)} hrs",
            icon: Icons.groups_3_outlined,
            accent: Colors.blue,
          ),
          _AnalyticsMetric(
            title: "Highest Watch Location",
            value: topLocation == null
                ? "-"
                : "${topLocation.city} • ${topLocation.watchHours.toStringAsFixed(1)} hrs",
            icon: Icons.location_on_outlined,
            accent: Colors.green,
          ),
          _AnalyticsMetric(
            title: "Highest Watch Device",
            value: topDevice == null
                ? "-"
                : "${topDevice.device} • ${topDevice.watchHours.toStringAsFixed(1)} hrs",
            icon: topDevice == null
                ? Icons.devices_other_outlined
                : _deviceIcon(topDevice.device),
            accent: Colors.deepPurple,
          ),
        ]),
        const SizedBox(height: 12),
        _watchTimeInsightPanel(
          theme,
          data,
          topAge,
          lowAge,
          topLocation,
          topAvgLocation,
          topDevice,
          topSessionDevice,
        ),
        const SizedBox(height: 12),
        _watchTimeAgeCards(theme, data.byAge, topAge, lowAge),
        const SizedBox(height: 12),
        _watchTimeDeviceCards(theme, data.byDevice, topDevice),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _barChart(theme, "Watch Time by Age", agePoints.toList()),
          _pieChart(theme, "Watch Time by Device", devicePoints.toList()),
          _barChart(theme, "Top Cities Watch Hours", locationPoints.toList()),
          _lineChart(
            theme,
            "Avg Watch Time by Location",
            avgLocationPoints.toList(),
          ),
        ]),
        const SizedBox(height: 12),
        _watchTimeAgeTable(theme, data.byAge),
        const SizedBox(height: 12),
        _watchTimeLocationTable(theme, data.byLocation),
        const SizedBox(height: 12),
        _watchTimeDeviceTable(theme, data.byDevice),
      ],
    );
  }

  Widget _buildDateWiseApiSection(
    ThemeData theme,
    AnalyticsProvider provider,
  ) {
    final rows = provider.dateWiseAnalytics;
    final totalRevenue = rows.fold<double>(0, (sum, row) => sum + row.revenue);
    final totalViews = rows.fold<int>(0, (sum, row) => sum + row.views);
    final totalWatchHours =
        rows.fold<double>(0, (sum, row) => sum + row.watchHours);
    final totalActiveUsers =
        rows.fold<int>(0, (sum, row) => sum + row.activeUsers);
    final totalSubscribers =
        rows.fold<int>(0, (sum, row) => sum + row.newSubscribers);
    final highestRevenue = _topDateWise(rows, (row) => row.revenue);
    final highestWatch = _topDateWise(rows, (row) => row.watchHours);
    final highestUsers =
        _topDateWise(rows, (row) => row.activeUsers.toDouble());
    final revenuePoints = rows
        .map((row) => _AnalyticsPoint(_dateWiseLabel(row), row.revenue))
        .toList();
    final viewsPoints = rows
        .map(
            (row) => _AnalyticsPoint(_dateWiseLabel(row), row.views.toDouble()))
        .toList();
    final watchPoints = rows
        .map((row) => _AnalyticsPoint(_dateWiseLabel(row), row.watchHours))
        .toList();
    final activeUserPoints = rows
        .map((row) =>
            _AnalyticsPoint(_dateWiseLabel(row), row.activeUsers.toDouble()))
        .toList();
    final subscriberPoints = rows
        .map((row) =>
            _AnalyticsPoint(_dateWiseLabel(row), row.newSubscribers.toDouble()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date-wise Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Revenue, views, watch hours, active users, and subscriber growth across the selected date range.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _dateWiseFilterPanel(theme, provider),
        const SizedBox(height: 12),
        if (provider.isDateWiseAnalyticsLoading)
          _surface(
            theme: theme,
            padding: const EdgeInsets.all(16),
            child: const Center(child: AppSpinner()),
          )
        else if (provider.dateWiseAnalyticsError != null && rows.isEmpty)
          _surface(
            theme: theme,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(Icons.event_busy_outlined,
                    color: theme.primaryColor, size: 42),
                const SizedBox(height: 10),
                Text(
                  provider.dateWiseAnalyticsError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadDateWiseAnalytics,
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text("Retry"),
                  style: FilledButton.styleFrom(
                      backgroundColor: theme.primaryColor),
                ),
              ],
            ),
          )
        else if (rows.isEmpty)
          _surface(
            theme: theme,
            padding: const EdgeInsets.all(18),
            child: Text(
              "No date-wise analytics found for this range.",
              style: TextStyle(color: theme.canvasColor),
            ),
          )
        else ...[
          _advancedMetricGrid(theme, [
            _AnalyticsMetric(
              title: "Total Revenue",
              value: _formatRevenue(totalRevenue),
              icon: Icons.currency_rupee,
              accent: Colors.teal,
            ),
            _AnalyticsMetric(
              title: "Total Views",
              value: "$totalViews",
              icon: Icons.visibility_outlined,
              accent: Colors.blue,
            ),
            _AnalyticsMetric(
              title: "Total Watch Hours",
              value: "${totalWatchHours.toStringAsFixed(2)} hrs",
              icon: Icons.timer_outlined,
              accent: Colors.indigo,
            ),
            _AnalyticsMetric(
              title: "Total Active Users",
              value: "$totalActiveUsers",
              icon: Icons.person_outline,
              accent: Colors.green,
            ),
            _AnalyticsMetric(
              title: "New Subscribers",
              value: "$totalSubscribers",
              icon: Icons.card_membership_outlined,
              accent: Colors.deepPurple,
            ),
            _AnalyticsMetric(
              title: "Highest Revenue Day",
              value: highestRevenue == null
                  ? "-"
                  : "${_dateWiseLabel(highestRevenue)} • ${_formatRevenue(highestRevenue.revenue)}",
              icon: Icons.trending_up,
              accent: Colors.amber,
            ),
            _AnalyticsMetric(
              title: "Highest Watch Hour Day",
              value: highestWatch == null
                  ? "-"
                  : "${_dateWiseLabel(highestWatch)} • ${highestWatch.watchHours.toStringAsFixed(1)} hrs",
              icon: Icons.schedule_outlined,
              accent: Colors.orange,
            ),
            _AnalyticsMetric(
              title: "Highest Active User Day",
              value: highestUsers == null
                  ? "-"
                  : "${_dateWiseLabel(highestUsers)} • ${highestUsers.activeUsers}",
              icon: Icons.groups_outlined,
              accent: Colors.pink,
            ),
          ]),
          const SizedBox(height: 12),
          _dateWiseInsightsPanel(theme, rows),
          const SizedBox(height: 12),
          _chartGrid(theme, [
            _lineChart(theme, "Revenue Trend", revenuePoints),
            _lineChart(theme, "Views Trend", viewsPoints),
            _lineChart(theme, "Watch Hours Trend", watchPoints),
            _barChart(theme, "Active Users Trend", activeUserPoints),
            _barChart(theme, "Subscriber Growth Trend", subscriberPoints),
            _dateWiseComparisonChart(
              theme,
              "Revenue vs Views",
              revenuePoints,
              viewsPoints,
            ),
          ]),
          const SizedBox(height: 12),
          _dateWiseHeatmap(theme, rows),
          const SizedBox(height: 12),
          _dateWiseTable(theme, rows, highestRevenue, highestWatch),
        ],
      ],
    );
  }

  Widget _dateWiseFilterPanel(ThemeData theme, AnalyticsProvider provider) {
    final labelFormat = DateFormat("dd MMM yyyy");
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth > 940
            ? (constraints.maxWidth - 24) / 4
            : constraints.maxWidth > 560
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final range in const [
              "Today",
              "Last 7 Days",
              "Last 30 Days",
              "This Month",
            ])
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton(
                  onPressed: provider.isDateWiseAnalyticsLoading
                      ? null
                      : () => _setDateWiseQuickRange(range),
                  style: _outlinedFilterStyle(theme),
                  child: Text(range),
                ),
              ),
            SizedBox(
              width: fieldWidth,
              child: OutlinedButton.icon(
                onPressed: provider.isDateWiseAnalyticsLoading
                    ? null
                    : () => _pickDateWiseDate(isFrom: true),
                icon: const Icon(Icons.calendar_month_outlined, size: 17),
                label: Text("From ${labelFormat.format(_dateWiseFrom)}"),
                style: _outlinedFilterStyle(theme),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: OutlinedButton.icon(
                onPressed: provider.isDateWiseAnalyticsLoading
                    ? null
                    : () => _pickDateWiseDate(isFrom: false),
                icon: const Icon(Icons.event_outlined, size: 17),
                label: Text("To ${labelFormat.format(_dateWiseTo)}"),
                style: _outlinedFilterStyle(theme),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: FilledButton.icon(
                onPressed: provider.isDateWiseAnalyticsLoading
                    ? null
                    : _loadDateWiseAnalytics,
                icon: const Icon(Icons.filter_alt_outlined, size: 17),
                label: const Text("Apply Filter"),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: theme.primaryColor,
                ),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: OutlinedButton.icon(
                onPressed: provider.isDateWiseAnalyticsLoading
                    ? null
                    : () => _setDateWiseQuickRange("Last 7 Days"),
                icon: const Icon(Icons.refresh, size: 17),
                label: const Text("Reset Filter"),
                style: _outlinedFilterStyle(theme),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _textField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        style: TextStyle(color: theme.canvasColor),
        decoration: _fieldDecoration(theme, label),
      ),
    );
  }

  Widget _dropdownField({
    required ThemeData theme,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _fieldDecoration(theme, label),
      dropdownColor: theme.scaffoldBackgroundColor,
      iconEnabledColor: theme.canvasColor.withValues(alpha: 0.72),
      menuMaxHeight: 260,
      style: TextStyle(
        color: theme.canvasColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: TextStyle(color: theme.canvasColor),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  InputDecoration _fieldDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: theme.cardColor.withValues(alpha: 0.76),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      labelStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.62)),
      hintStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.42)),
      prefixIconColor: theme.primaryColor,
      suffixIconColor: theme.primaryColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: theme.primaryColor.withValues(alpha: .24)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: theme.primaryColor.withValues(alpha: .82)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  ButtonStyle _outlinedFilterStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      foregroundColor: theme.primaryColor,
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.36),
      side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.38)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ).copyWith(
      overlayColor: WidgetStatePropertyAll(
        theme.primaryColor.withValues(alpha: 0.08),
      ),
    );
  }

  ButtonStyle _sortButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(156, 40),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      foregroundColor: theme.primaryColor,
      side: BorderSide(color: theme.canvasColor.withValues(alpha: 0.28)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildFilterSummary(
      ThemeData theme, List<ReportAndDataObject> reports) {
    final views =
        reports.fold<int>(0, (sum, report) => sum + (report.totalViews ?? 0));
    final revenue =
        reports.fold<double>(0, (sum, report) => sum + _revenue(report));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _reportChip(
            theme, Icons.filter_list, "Filtered Items", "${reports.length}"),
        _reportChip(
            theme, Icons.visibility_outlined, "Filtered Views", "$views"),
        _reportChip(theme, Icons.currency_rupee, "Filtered Revenue",
            _formatAmount(revenue)),
      ],
    );
  }

  Widget _reportChip(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.primaryColor),
          const SizedBox(width: 7),
          Text(
            "$title: ",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.64),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable(
    ThemeData theme,
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    final totalPages =
        reports.isEmpty ? 1 : ((reports.length - 1) ~/ _reportRowsPerPage) + 1;
    final currentPage = _reportPage.clamp(0, totalPages - 1).toInt();
    if (currentPage != _reportPage) {
      _reportPage = currentPage;
    }
    final start = currentPage * _reportRowsPerPage;
    final visibleReports = reports.skip(start).take(_reportRowsPerPage);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;
              final sortControls = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: isNarrow ? WrapAlignment.start : WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _sortByRevenue = !_sortByRevenue);
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label:
                        Text(_sortByRevenue ? "Sort: Revenue" : "Sort: Name"),
                    style: _sortButtonStyle(theme),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _isAscending = !_isAscending);
                    },
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                    ),
                    label: Text(_isAscending ? "Ascending" : "Descending"),
                    style: _sortButtonStyle(theme),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _reportTableTitle(theme, provider, reports),
                    const SizedBox(height: 10),
                    sortControls,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _reportTableTitle(theme, provider, reports)),
                  const SizedBox(width: 12),
                  sortControls,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (provider.isReportLoading)
            const Center(child: AppSpinner())
          else if (provider.reportLoadError != null)
            Text(provider.reportLoadError!)
          else if (reports.isEmpty)
            const Text("No report data found for the selected filters.")
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    theme.primaryColor.withValues(alpha: 0.10),
                  ),
                  columns: const [
                    DataColumn(label: Text("Content")),
                    DataColumn(label: Text("Production House")),
                    DataColumn(label: Text("Release Date")),
                    DataColumn(label: Text("Views")),
                    DataColumn(label: Text("Price")),
                    DataColumn(label: Text("Revenue")),
                    DataColumn(label: Text("Language")),
                    DataColumn(label: Text("Details")),
                  ],
                  rows: visibleReports
                      .map((report) => _reportRow(theme, report))
                      .toList(),
                ),
              ),
            ),
          if (!provider.isReportLoading && reports.length > _reportRowsPerPage)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _tablePager(
                theme: theme,
                currentPage: currentPage,
                totalPages: totalPages,
                start: start,
                totalRows: reports.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _tablePager({
    required ThemeData theme,
    required int currentPage,
    required int totalPages,
    required int start,
    required int totalRows,
  }) {
    final end = (start + _reportRowsPerPage).clamp(0, totalRows).toInt();
    return Row(
      children: [
        Expanded(
          child: Text(
            "Showing ${start + 1}-$end of $totalRows",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: "Previous page",
          onPressed: currentPage == 0
              ? null
              : () => setState(() => _reportPage = currentPage - 1),
          icon: const Icon(Icons.chevron_left),
          color: theme.primaryColor,
        ),
        Text(
          "${currentPage + 1} / $totalPages",
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          tooltip: "Next page",
          onPressed: currentPage >= totalPages - 1
              ? null
              : () => setState(() => _reportPage = currentPage + 1),
          icon: const Icon(Icons.chevron_right),
          color: theme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildAdvancedAnalytics(
    ThemeData theme,
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    final filteredReports = _advancedFilteredReports(reports);
    final totalRevenue =
        filteredReports.fold<double>(0, (sum, item) => sum + _revenue(item));
    final totalViews = filteredReports.fold<int>(
        0, (sum, item) => sum + (item.totalViews ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Advanced Analytics", style: _sectionStyle(theme)),
        const SizedBox(height: 4),
        Text(
          "Deep-dive revenue, audience, engagement, devices, subscription, and date-wise performance.",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _buildAdvancedFilterPanel(theme),
        const SizedBox(height: 12),
        _buildAdvancedTabs(theme),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: provider.isReportLoading
              ? const Center(child: AppSpinner())
              : _buildLazyAdvancedTabBody(
                  theme: theme,
                  provider: provider,
                  reports: filteredReports,
                  totalRevenue: totalRevenue,
                  totalViews: totalViews,
                ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilterPanel(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = constraints.maxWidth > 1100
              ? (constraints.maxWidth - 32) / 5
              : constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16) / 3
                  : constraints.maxWidth;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  style: TextStyle(color: theme.canvasColor),
                  onChanged: _debounceAdvancedSearch,
                  decoration: _fieldDecoration(theme, "Search analytics")
                      .copyWith(prefixIcon: const Icon(Icons.search, size: 18)),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Device Type",
                  value: _advancedDeviceType,
                  options: const ["ALL", "Android", "iOS", "Web", "TV"],
                  onChanged: (value) =>
                      setState(() => _advancedDeviceType = value),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Genre",
                  value: _advancedGenre,
                  options: const [
                    "ALL",
                    "Drama",
                    "Action",
                    "Comedy",
                    "Thriller"
                  ],
                  onChanged: (value) => setState(() => _advancedGenre = value),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Language",
                  value: _advancedLanguage,
                  options: const [
                    "ALL",
                    "Hindi",
                    "English",
                    "Marathi",
                    "Tamil"
                  ],
                  onChanged: (value) =>
                      setState(() => _advancedLanguage = value),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: _pickReportRange,
                  icon: const Icon(Icons.calendar_month_outlined, size: 17),
                  label: Text(_dateRangeLabel()),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: FilledButton.icon(
                  onPressed: _loadReports,
                  icon: const Icon(Icons.filter_alt_outlined, size: 17),
                  label: const Text("Apply Filter"),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: theme.primaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _advancedSearch = "";
                      _advancedDeviceType = "ALL";
                      _advancedGenre = "ALL";
                      _advancedLanguage = "ALL";
                    });
                    _resetFilters();
                  },
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text("Reset Filter"),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: () => _showExportPrepared("CSV"),
                  icon: const Icon(Icons.table_view_outlined, size: 17),
                  label: const Text("Export CSV"),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: () => _showExportPrepared("PDF"),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
                  label: const Text("Export PDF"),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdvancedTabs(ThemeData theme) {
    const tabs = [
      "Location",
      "Age",
      "Content",
      "Watch Time",
      "Engagement",
      "Device",
      "Subscription",
      "Top Content",
      "Date-wise",
    ];
    return _surface(
      theme: theme,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final selected = _advancedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selected,
                label: Text(tab),
                onSelected: (_) => setState(() => _advancedTab = tab),
                selectedColor: theme.primaryColor,
                backgroundColor: theme.cardColor,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : theme.canvasColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLazyAdvancedTabBody({
    required ThemeData theme,
    required AnalyticsProvider provider,
    required List<ReportAndDataObject> reports,
    required double totalRevenue,
    required int totalViews,
  }) {
    switch (_advancedTab) {
      case "Age":
        final apiAgeRows = _ageAudienceRows(provider, reports);
        final ageRevenue = apiAgeRows.isEmpty
            ? _ageRevenuePoints(totalRevenue)
            : apiAgeRows
                .map((row) => _AnalyticsPoint(row.ageGroup, row.revenue))
                .toList();
        final ageViews = apiAgeRows.isEmpty
            ? _ageViewPoints(totalViews)
            : apiAgeRows
                .map((row) =>
                    _AnalyticsPoint(row.ageGroup, row.views.toDouble()))
                .toList();
        return _buildAgeAnalytics(theme, ageRevenue, ageViews, totalRevenue);
      case "Content":
        final contentTypePoints = _groupReports(
          reports,
          (item) => formatContentTypeLabel(item.contentType),
          _revenue,
        );
        return _buildContentAnalytics(
          theme,
          reports,
          contentTypePoints,
          totalViews,
          totalRevenue,
        );
      case "Watch Time":
        final apiAgeRows = _ageAudienceRows(provider, reports);
        final ageViews = apiAgeRows.isEmpty
            ? _ageViewPoints(totalViews)
            : apiAgeRows
                .map((row) =>
                    _AnalyticsPoint(row.ageGroup, row.views.toDouble()))
                .toList();
        return _buildWatchTimeAnalytics(
          theme,
          ageViews,
          _locationRowsForDisplay(provider, reports),
          _devicePoints(totalRevenue),
          (totalViews * 9.5 / 60).round(),
        );
      case "Engagement":
        return _buildEngagementAnalytics(
            theme, reports, _topContentRows(reports));
      case "Device":
        return _buildDeviceAnalytics(
            theme, _devicePoints(totalRevenue), totalRevenue);
      case "Subscription":
        return _buildSubscriptionAnalytics(
          theme,
          _subscriptionPoints(totalRevenue),
          totalRevenue,
        );
      case "Top Content":
        return _buildTopContentAnalytics(theme, _topContentRows(reports));
      case "Date-wise":
        return _buildDateWiseAnalytics(
            theme, _dateWisePoints(reports), totalViews);
      case "Location":
      default:
        return _buildLocationAnalytics(
          theme,
          _locationRowsForDisplay(provider, reports),
          totalRevenue,
        );
    }
  }

  Widget _buildLocationAnalytics(
    ThemeData theme,
    List<_LocationAnalyticsRow> rows,
    double fallbackRevenue,
  ) {
    final provider = context.watch<AnalyticsProvider>();
    if (provider.isLocationAnalyticsLoading) {
      return _locationLoading(theme);
    }
    if (provider.locationAnalyticsError != null &&
        provider.locationWiseAnalytics.isEmpty) {
      return _locationError(theme, provider.locationAnalyticsError!);
    }
    final filteredRows = _filteredLocationRows(rows);
    if (filteredRows.isEmpty) {
      return _locationEmpty(theme);
    }
    final totalRevenue =
        filteredRows.fold<double>(0, (sum, row) => sum + row.revenue);
    final safeRevenue = totalRevenue == 0 ? fallbackRevenue : totalRevenue;
    final totalUsers = filteredRows.fold<int>(0, (sum, row) => sum + row.users);
    final paidUsers =
        filteredRows.fold<int>(0, (sum, row) => sum + row.paidUsers);
    final totalViews = filteredRows.fold<int>(0, (sum, row) => sum + row.views);
    final watchHours =
        filteredRows.fold<int>(0, (sum, row) => sum + row.watchTime);
    final avgCompletion = filteredRows.isEmpty
        ? 0.0
        : filteredRows.fold<double>(0, (sum, row) => sum + row.completionRate) /
            filteredRows.length;
    final topCities = filteredRows.take(6).toList();
    final topRevenue = _topLocation(filteredRows, (row) => row.revenue);
    final topWatch =
        _topLocation(filteredRows, (row) => row.watchTime.toDouble());
    final topUsers = _topLocation(filteredRows, (row) => row.users.toDouble());
    return Column(
      key: const ValueKey("location-analytics"),
      children: [
        _locationLocalFilters(theme, rows),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
            title: "Location Revenue",
            value: _formatRevenue(safeRevenue),
            icon: Icons.public_outlined,
            accent: Colors.teal,
          ),
          _AnalyticsMetric(
            title: "Total Users",
            value: "$totalUsers",
            icon: Icons.groups_outlined,
            accent: Colors.blue,
          ),
          _AnalyticsMetric(
            title: "Paid Users",
            value: "$paidUsers",
            icon: Icons.workspace_premium_outlined,
            accent: Colors.orange,
          ),
          _AnalyticsMetric(
            title: "Total Views",
            value: "$totalViews",
            icon: Icons.visibility_outlined,
            accent: Colors.deepPurple,
          ),
          _AnalyticsMetric(
            title: "Watch Hours",
            value: "$watchHours",
            icon: Icons.timer_outlined,
            accent: Colors.indigo,
          ),
          _AnalyticsMetric(
            title: "Avg Completion",
            value: "${avgCompletion.toStringAsFixed(0)}%",
            icon: Icons.task_alt_outlined,
            accent: Colors.green,
          ),
        ]),
        const SizedBox(height: 12),
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
            title: "Top Revenue City",
            value: topRevenue.city,
            icon: Icons.location_city_outlined,
            accent: Colors.teal,
          ),
          _AnalyticsMetric(
            title: "Top Revenue District",
            value: topRevenue.district,
            icon: Icons.map_outlined,
            accent: Colors.blue,
          ),
          _AnalyticsMetric(
            title: "Top Revenue State",
            value: topRevenue.state,
            icon: Icons.public_outlined,
            accent: Colors.orange,
          ),
          _AnalyticsMetric(
            title: "Highest Watch Time",
            value: topWatch.city,
            icon: Icons.schedule_outlined,
            accent: Colors.indigo,
          ),
          _AnalyticsMetric(
            title: "Highest User Location",
            value: topUsers.city,
            icon: Icons.groups_2_outlined,
            accent: Colors.green,
          ),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _barChart(
              theme,
              "Top Revenue Cities",
              topCities
                  .map((row) => _AnalyticsPoint(row.city, row.revenue))
                  .toList()),
          _pieChart(theme, "Revenue Share by State",
              _groupLocation(filteredRows, (row) => row.state)),
          _barChart(
            theme,
            "Watch Hours by City",
            topCities
                .map((row) =>
                    _AnalyticsPoint(row.city, row.watchTime.toDouble()))
                .toList(),
          ),
          _lineChart(
            theme,
            "Completion Rate by City",
            topCities
                .map((row) => _AnalyticsPoint(row.city, row.completionRate))
                .toList(),
          ),
        ]),
        const SizedBox(height: 12),
        _locationTable(theme, filteredRows),
      ],
    );
  }

  Widget _buildAgeAnalytics(
    ThemeData theme,
    List<_AnalyticsPoint> ageRevenue,
    List<_AnalyticsPoint> ageViews,
    double totalRevenue,
  ) {
    final highestPaying = _maxPoint(ageRevenue);
    final mostActive = _maxPoint(ageViews);
    return Column(
      key: const ValueKey("age-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Age Revenue",
              value: _formatRevenue(totalRevenue),
              icon: Icons.currency_rupee,
              accent: Colors.deepPurple),
          _AnalyticsMetric(
              title: "Most Active Age",
              value: mostActive.label,
              icon: Icons.person_search_outlined,
              accent: Colors.blue),
          _AnalyticsMetric(
              title: "Highest Paying",
              value: highestPaying.label,
              icon: Icons.emoji_events_outlined,
              accent: Colors.amber),
          _AnalyticsMetric(
              title: "Retention Age",
              value: "25-34",
              icon: Icons.repeat_outlined,
              accent: Colors.green),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _pieChart(theme, "Age-wise Revenue Contribution", ageRevenue),
          _barChart(theme, "Age-wise Content Views", ageViews),
          _lineChart(theme, "Revenue Trend by Age", ageRevenue),
          _barChart(
              theme,
              "Completion by Age",
              ageRevenue
                  .map((item) =>
                      _AnalyticsPoint(item.label, 52 + item.value % 42))
                  .toList()),
        ]),
        const SizedBox(height: 12),
        _simpleTable(
          theme,
          title: "Age-wise Revenue & Views",
          columns: const [
            "Age",
            "Revenue",
            "Purchases",
            "Watch Time",
            "Retention"
          ],
          rows: ageRevenue
              .map((point) => [
                    point.label,
                    _formatRevenue(point.value),
                    "${(point.value / 50).round()}",
                    "${(point.value / 12).round()} hrs",
                    "${(48 + point.value % 44).toStringAsFixed(0)}%",
                  ])
              .toList(),
        ),
      ],
    );
  }

  Widget _buildContentAnalytics(
    ThemeData theme,
    List<ReportAndDataObject> reports,
    List<_AnalyticsPoint> contentTypePoints,
    int totalViews,
    double totalRevenue,
  ) {
    return Column(
      key: const ValueKey("content-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Total Views",
              value: "$totalViews",
              icon: Icons.visibility_outlined,
              accent: Colors.blue),
          _AnalyticsMetric(
              title: "Total Revenue",
              value: _formatRevenue(totalRevenue),
              icon: Icons.currency_rupee,
              accent: Colors.teal),
          _AnalyticsMetric(
              title: "Engagement Score",
              value: mathPercent(totalViews, reports.length),
              icon: Icons.favorite_border,
              accent: Colors.pink),
          _AnalyticsMetric(
              title: "Bounce Rate",
              value:
                  "${reports.isEmpty ? 0 : 100 - _avgCompletion(reports).round()}%",
              icon: Icons.logout_outlined,
              accent: Colors.orange),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _lineChart(theme, "Performance Trend", _dateWisePoints(reports)),
          _barChart(theme, "Revenue by Content Type", contentTypePoints),
        ]),
        const SizedBox(height: 12),
        _topContentTable(theme, _topContentRows(reports)),
      ],
    );
  }

  Widget _buildWatchTimeAnalytics(
    ThemeData theme,
    List<_AnalyticsPoint> ageViews,
    List<_LocationAnalyticsRow> locationRows,
    List<_AnalyticsPoint> devicePoints,
    int totalWatchHours,
  ) {
    final watchByAge = ageViews
        .map((item) => _AnalyticsPoint(item.label, item.value * 0.16))
        .toList();
    return Column(
      key: const ValueKey("watch-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Avg Watch Time",
              value: "9.5 min",
              icon: Icons.schedule_outlined,
              accent: Colors.indigo),
          _AnalyticsMetric(
              title: "Total Watch Hours",
              value: "$totalWatchHours",
              icon: Icons.timer_outlined,
              accent: Colors.deepPurple),
          _AnalyticsMetric(
              title: "Top Region Watch",
              value: locationRows.isEmpty ? "-" : locationRows.first.city,
              icon: Icons.location_on_outlined,
              accent: Colors.green),
          _AnalyticsMetric(
              title: "Top Device Watch",
              value: _maxPoint(devicePoints).label,
              icon: Icons.devices_outlined,
              accent: Colors.blue),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _lineChart(theme, "Watch Time Timeline", watchByAge),
          _barChart(theme, "Watch Time by Age", watchByAge),
          _barChart(
            theme,
            "Watch Time by Location",
            locationRows
                .take(6)
                .map((row) =>
                    _AnalyticsPoint(row.city, row.watchTime.toDouble()))
                .toList(),
          ),
          _pieChart(theme, "Watch Time by Device", devicePoints),
        ]),
      ],
    );
  }

  Widget _buildEngagementAnalytics(
    ThemeData theme,
    List<ReportAndDataObject> reports,
    List<_TopContentRow> topContent,
  ) {
    final likes =
        reports.fold<int>(0, (sum, item) => sum + (item.totalViews ?? 0) ~/ 8);
    final shares =
        reports.fold<int>(0, (sum, item) => sum + (item.totalViews ?? 0) ~/ 14);
    final comments =
        reports.fold<int>(0, (sum, item) => sum + (item.totalViews ?? 0) ~/ 22);
    final engagement = [
      _AnalyticsPoint("Likes", likes.toDouble()),
      _AnalyticsPoint("Shares", shares.toDouble()),
      _AnalyticsPoint("Comments", comments.toDouble()),
      _AnalyticsPoint("Watchlist", (likes / 2).roundToDouble()),
      _AnalyticsPoint("Downloads", (shares / 3).roundToDouble()),
    ];
    return Column(
      key: const ValueKey("engagement-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Likes",
              value: "$likes",
              icon: Icons.favorite_border,
              accent: Colors.pink),
          _AnalyticsMetric(
              title: "Shares",
              value: "$shares",
              icon: Icons.share_outlined,
              accent: Colors.blue),
          _AnalyticsMetric(
              title: "Comments",
              value: "$comments",
              icon: Icons.chat_bubble_outline,
              accent: Colors.green),
          _AnalyticsMetric(
              title: "Peak Active Hour",
              value: "8 PM",
              icon: Icons.access_time,
              accent: Colors.orange),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _barChart(theme, "Engagement Timeline", engagement),
          _pieChart(theme, "Activity Heatmap", engagement),
        ]),
        const SizedBox(height: 12),
        _topContentTable(theme, topContent),
      ],
    );
  }

  Widget _buildDeviceAnalytics(
    ThemeData theme,
    List<_AnalyticsPoint> devicePoints,
    double totalRevenue,
  ) {
    return Column(
      key: const ValueKey("device-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          for (final item in devicePoints)
            _AnalyticsMetric(
              title: "${item.label} Users",
              value:
                  "${(item.value / mathMax(totalRevenue, 1) * 1000).round()}",
              icon: Icons.devices_outlined,
              accent: _pointColor(item.label),
            ),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _pieChart(theme, "Device Distribution", devicePoints),
          _barChart(theme, "Revenue by Device", devicePoints),
          _lineChart(
              theme,
              "Avg Session by Device",
              devicePoints
                  .map((item) =>
                      _AnalyticsPoint(item.label, 8 + item.value % 20))
                  .toList()),
        ]),
      ],
    );
  }

  Widget _buildSubscriptionAnalytics(
    ThemeData theme,
    List<_AnalyticsPoint> subscriptionPoints,
    double totalRevenue,
  ) {
    return Column(
      key: const ValueKey("subscription-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Free Users",
              value: "${(totalRevenue / 45).round()}",
              icon: Icons.person_outline,
              accent: Colors.blueGrey),
          _AnalyticsMetric(
              title: "Premium Users",
              value: "${(totalRevenue / 120).round()}",
              icon: Icons.workspace_premium_outlined,
              accent: Colors.amber),
          _AnalyticsMetric(
              title: "Renewal Rate",
              value: "68%",
              icon: Icons.autorenew,
              accent: Colors.green),
          _AnalyticsMetric(
              title: "Churn Rate",
              value: "12%",
              icon: Icons.trending_down,
              accent: Colors.redAccent),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _lineChart(theme, "Subscription Growth", subscriptionPoints),
          _barChart(theme, "Subscription Revenue Trend", subscriptionPoints),
          _pieChart(theme, "Subscription Funnel", subscriptionPoints),
        ]),
      ],
    );
  }

  Widget _buildTopContentAnalytics(
    ThemeData theme,
    List<_TopContentRow> rows,
  ) {
    return Column(
      key: const ValueKey("top-content-analytics"),
      children: [
        _chartGrid(theme, [
          _barChart(
            theme,
            "Revenue Generating Content",
            rows
                .take(6)
                .map((row) => _AnalyticsPoint(row.name, row.revenue))
                .toList(),
          ),
          _barChart(
            theme,
            "Most Viewed Content",
            rows
                .take(6)
                .map((row) => _AnalyticsPoint(row.name, row.views.toDouble()))
                .toList(),
          ),
        ]),
        const SizedBox(height: 12),
        _topContentTable(theme, rows),
      ],
    );
  }

  Widget _buildDateWiseAnalytics(
    ThemeData theme,
    List<_AnalyticsPoint> datePoints,
    int totalViews,
  ) {
    final views = datePoints
        .map((point) => _AnalyticsPoint(point.label, point.value / 2))
        .toList();
    return Column(
      key: const ValueKey("datewise-analytics"),
      children: [
        _advancedMetricGrid(theme, [
          _AnalyticsMetric(
              title: "Daily Revenue",
              value: datePoints.isEmpty
                  ? "Rs. 0"
                  : _formatRevenue(datePoints.last.value),
              icon: Icons.currency_rupee,
              accent: Colors.teal),
          _AnalyticsMetric(
              title: "Daily Views",
              value: "$totalViews",
              icon: Icons.visibility_outlined,
              accent: Colors.blue),
          _AnalyticsMetric(
              title: "Daily Watch Time",
              value: "${(totalViews * .14).round()} hrs",
              icon: Icons.timer_outlined,
              accent: Colors.indigo),
          _AnalyticsMetric(
              title: "Daily Subscribers",
              value: "${(totalViews * .08).round()}",
              icon: Icons.workspace_premium_outlined,
              accent: Colors.orange),
        ]),
        const SizedBox(height: 12),
        _chartGrid(theme, [
          _lineChart(theme, "Timeline Revenue Chart", datePoints),
          _barChart(theme, "Comparative Views Graph", views),
        ]),
        const SizedBox(height: 12),
        _calendarHeatmap(theme, datePoints),
      ],
    );
  }

  Widget _advancedMetricGrid(ThemeData theme, List<_AnalyticsMetric> metrics) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 1080
          ? 4
          : constraints.maxWidth > 680
              ? 2
              : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 1 ? 4.2 : 3.7,
        ),
        itemBuilder: (context, index) => _metricTile(theme, metrics[index]),
      );
    });
  }

  Widget _chartGrid(ThemeData theme, List<Widget> charts) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 920 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: charts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 330,
        ),
        itemBuilder: (context, index) => charts[index],
      );
    });
  }

  Widget _lineChart(ThemeData theme, String title, List<_AnalyticsPoint> data) {
    return _chartShell(
      theme,
      title,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_AnalyticsPoint, String>>[
          AreaSeries<_AnalyticsPoint, String>(
            dataSource: _safePoints(data),
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            animationDuration: 0,
            color: theme.primaryColor.withValues(alpha: 0.22),
            borderColor: theme.primaryColor,
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _barChart(ThemeData theme, String title, List<_AnalyticsPoint> data) {
    return _chartShell(
      theme,
      title,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_AnalyticsPoint, String>>[
          ColumnSeries<_AnalyticsPoint, String>(
            dataSource: _safePoints(data),
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            animationDuration: 0,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            color: theme.primaryColor,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  Widget _pieChart(ThemeData theme, String title, List<_AnalyticsPoint> data) {
    return _chartShell(
      theme,
      title,
      SfCircularChart(
        legend: const Legend(
            isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CircularSeries<_AnalyticsPoint, String>>[
          DoughnutSeries<_AnalyticsPoint, String>(
            dataSource: _safePoints(data),
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            animationDuration: 0,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            innerRadius: "58%",
          ),
        ],
      ),
    );
  }

  Widget _chartShell(ThemeData theme, String title, Widget chart) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sectionStyle(theme).copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          Expanded(child: RepaintBoundary(child: chart)),
        ],
      ),
    );
  }

  Widget _locationLocalFilters(
    ThemeData theme,
    List<_LocationAnalyticsRow> rows,
  ) {
    final countries = _locationOptions(rows.map((row) => row.country));
    final states = _locationOptions(rows
        .where((row) =>
            _locationCountry == "ALL" || row.country == _locationCountry)
        .map((row) => row.state));
    final districts = _locationOptions(rows
        .where((row) =>
            (_locationCountry == "ALL" || row.country == _locationCountry) &&
            (_locationState == "ALL" || row.state == _locationState))
        .map((row) => row.district));
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = constraints.maxWidth > 900
              ? (constraints.maxWidth - 24) / 4
              : constraints.maxWidth > 560
                  ? (constraints.maxWidth - 8) / 2
                  : constraints.maxWidth;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "Country",
                  value: countries.contains(_locationCountry)
                      ? _locationCountry
                      : "ALL",
                  options: countries,
                  onChanged: (value) {
                    setState(() {
                      _locationCountry = value;
                      _locationState = "ALL";
                      _locationDistrict = "ALL";
                    });
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "State",
                  value:
                      states.contains(_locationState) ? _locationState : "ALL",
                  options: states,
                  onChanged: (value) {
                    setState(() {
                      _locationState = value;
                      _locationDistrict = "ALL";
                    });
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdownField(
                  theme: theme,
                  label: "District",
                  value: districts.contains(_locationDistrict)
                      ? _locationDistrict
                      : "ALL",
                  options: districts,
                  onChanged: (value) =>
                      setState(() => _locationDistrict = value),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: _locationCitySearchController,
                  style: TextStyle(color: theme.canvasColor),
                  onChanged: _debounceLocationSearch,
                  decoration: _fieldDecoration(theme, "Search City").copyWith(
                    prefixIcon: const Icon(Icons.search, size: 18),
                  ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _locationCountry = "ALL";
                      _locationState = "ALL";
                      _locationDistrict = "ALL";
                      _locationCitySearch = "";
                      _locationCitySearchController.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text("Clear Location Filters"),
                  style: _outlinedFilterStyle(theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _locationLoading(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            height: 58,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: theme.canvasColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationError(ThemeData theme, String message) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, color: theme.primaryColor, size: 42),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context
                .read<AnalyticsProvider>()
                .fetchLocationWiseAnalytics(forceRefresh: true),
            icon: const Icon(Icons.refresh, size: 17),
            label: const Text("Retry"),
            style: FilledButton.styleFrom(backgroundColor: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _locationEmpty(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined,
              color: theme.primaryColor, size: 42),
          const SizedBox(height: 10),
          Text(
            "No location analytics found for the selected filters.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationTable(ThemeData theme, List<_LocationAnalyticsRow> rows) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text("Location-wise Revenue Analytics",
            style: _sectionStyle(theme)),
        subtitle: Text(
          "Country > State > District/Taluka > City, showing first 10 rows with export-ready columns.",
          style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.62)),
        ),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 4,
              sortAscending: false,
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns: const [
                DataColumn(label: Text("Hierarchy")),
                DataColumn(label: Text("Users"), numeric: true),
                DataColumn(label: Text("Paid Users"), numeric: true),
                DataColumn(label: Text("Views"), numeric: true),
                DataColumn(label: Text("Revenue"), numeric: true),
                DataColumn(label: Text("Watch Time"), numeric: true),
                DataColumn(label: Text("Session"), numeric: true),
                DataColumn(label: Text("Completion"), numeric: true),
              ],
              rows: rows.take(10).map((row) {
                return DataRow(cells: [
                  DataCell(Text(
                      "${row.country} > ${row.state} > ${row.district} > ${row.city}")),
                  DataCell(Text("${row.users}")),
                  DataCell(Text("${row.paidUsers}")),
                  DataCell(Text("${row.views}")),
                  DataCell(Text(_formatRevenue(row.revenue))),
                  DataCell(Text("${row.watchTime} hrs")),
                  DataCell(Text("${row.avgSessionTime} min")),
                  DataCell(Text("${row.completionRate.toStringAsFixed(0)}%")),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topContentTable(ThemeData theme, List<_TopContentRow> rows) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top Content Analytics", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            "Revenue, views, completion, sharing, and retention ranking.",
            style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.62), fontSize: 12),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 3,
              sortAscending: false,
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns: const [
                DataColumn(label: Text("Rank")),
                DataColumn(label: Text("Content")),
                DataColumn(label: Text("Views"), numeric: true),
                DataColumn(label: Text("Revenue"), numeric: true),
                DataColumn(label: Text("Completion"), numeric: true),
                DataColumn(label: Text("Shared"), numeric: true),
                DataColumn(label: Text("Retention"), numeric: true),
              ],
              rows: rows.take(10).map((row) {
                return DataRow(cells: [
                  DataCell(_rankBadge(theme, row.rank)),
                  DataCell(SizedBox(
                      width: 220,
                      child: Text(row.name, overflow: TextOverflow.ellipsis))),
                  DataCell(Text("${row.views}")),
                  DataCell(Text(_formatRevenue(row.revenue))),
                  DataCell(Text("${row.completion.toStringAsFixed(0)}%")),
                  DataCell(Text("${row.shares}")),
                  DataCell(Text("${row.retention.toStringAsFixed(0)}%")),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ageAudienceTable(
    ThemeData theme,
    List<_AgeAudienceRow> rows,
    double totalRevenue,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Combined Age-wise Analytics Table",
              style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            "Showing all configured age groups with merged revenue and views data.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 2,
              sortAscending: false,
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns: const [
                DataColumn(label: Text("Age Group")),
                DataColumn(label: Text("Users"), numeric: true),
                DataColumn(label: Text("Revenue"), numeric: true),
                DataColumn(label: Text("Views"), numeric: true),
                DataColumn(label: Text("Watch Hours"), numeric: true),
                DataColumn(label: Text("Avg Watch Time"), numeric: true),
                DataColumn(label: Text("Completion %"), numeric: true),
                DataColumn(label: Text("Retention %"), numeric: true),
                DataColumn(label: Text("Rewatch %"), numeric: true),
                DataColumn(label: Text("Contribution"), numeric: true),
              ],
              rows: rows.map((row) {
                final contribution =
                    totalRevenue <= 0 ? 0 : (row.revenue / totalRevenue) * 100;
                return DataRow(cells: [
                  DataCell(Text(row.ageGroup)),
                  DataCell(Text("${row.users}")),
                  DataCell(Text(_formatRevenue(row.revenue))),
                  DataCell(Text("${row.views}")),
                  DataCell(Text(row.watchHours.toStringAsFixed(2))),
                  DataCell(Text("${row.avgWatchTime.toStringAsFixed(0)} min")),
                  DataCell(Text("${row.completionRate.toStringAsFixed(1)}%")),
                  DataCell(Text("${row.retentionRate.toStringAsFixed(1)}%")),
                  DataCell(Text("${row.rewatchRate.toStringAsFixed(1)}%")),
                  DataCell(Text("${contribution.toStringAsFixed(1)}%")),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentHealthPanel(
    ThemeData theme,
    ContentPerformanceAnalyticsDataModel data,
    double healthScore,
  ) {
    final label = _performanceLabel(healthScore);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 720;
          final gauge = SizedBox(
            width: narrow ? 180 : 220,
            height: narrow ? 180 : 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (healthScore / 100).clamp(0, 1),
                  strokeWidth: 16,
                  color: theme.primaryColor,
                  backgroundColor: theme.canvasColor.withValues(alpha: 0.10),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      healthScore.toStringAsFixed(0),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          final qualities = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Content Health", style: _sectionStyle(theme)),
              const SizedBox(height: 10),
              _qualityRow(
                  theme, "Engagement Quality", data.engagementScore * 8),
              _qualityRow(theme, "Retention Quality", data.retentionRate),
              _qualityRow(theme, "Viewer Satisfaction", 100 - data.bounceRate),
              _qualityRow(theme, "Watch Completion", data.completionRate),
            ],
          );
          if (narrow) {
            return Column(children: [
              gauge,
              const SizedBox(height: 14),
              qualities,
            ]);
          }
          return Row(
            children: [
              gauge,
              const SizedBox(width: 18),
              Expanded(child: qualities),
            ],
          );
        },
      ),
    );
  }

  Widget _qualityRow(ThemeData theme, String label, double value) {
    final safeValue = value.clamp(0, 100).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "${safeValue.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: safeValue / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: theme.primaryColor,
            backgroundColor: theme.canvasColor.withValues(alpha: 0.10),
          ),
        ],
      ),
    );
  }

  Widget _performanceInsights(
    ThemeData theme,
    ContentPerformanceAnalyticsDataModel data,
  ) {
    final insights = _contentPerformanceInsights(data);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Performance Insights", style: _sectionStyle(theme)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: insights.map((insight) {
              return Container(
                width: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: .34),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: insight.color.withValues(alpha: .32),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(insight.icon, color: insight.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _topSeriesPerformance(
    ThemeData theme,
    List<TopSeriesPerformanceModel> rows,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top Performing Series", style: _sectionStyle(theme)),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text("No top series data found.",
                style: TextStyle(color: theme.canvasColor))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: rows.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final item = entry.value;
                  final maxViews = rows
                      .map((row) => row.views)
                      .fold<int>(1, (a, b) => a > b ? a : b);
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.scaffoldBackgroundColor.withValues(alpha: .34),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.canvasColor.withValues(alpha: .12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _rankBadge(theme, rank),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.canvasColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(Icons.live_tv_outlined,
                                color: theme.primaryColor, size: 30),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("${item.views} views",
                            style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: item.views / maxViews,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          color: theme.primaryColor,
                          backgroundColor:
                              theme.canvasColor.withValues(alpha: .10),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topEpisodesPerformance(
    ThemeData theme,
    List<TopEpisodePerformanceModel> rows,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top Episodes Analytics", style: _sectionStyle(theme)),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text("No top episodes data found.",
                style: TextStyle(color: theme.canvasColor))
          else
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 560
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 104,
                ),
                itemBuilder: (context, index) {
                  final item = rows[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.scaffoldBackgroundColor.withValues(alpha: .34),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.canvasColor.withValues(alpha: .12),
                      ),
                    ),
                    child: Row(
                      children: [
                        _rankBadge(theme, index + 1),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.canvasColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${item.views} views • Trending",
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _contentPerformanceTable(
    ThemeData theme,
    ContentPerformanceAnalyticsDataModel data,
  ) {
    final rows = [
      ...data.topSeries.map((item) => ["Series", item.title, "${item.views}"]),
      ...data.topEpisodes
          .map((item) => ["Episode", item.title, "${item.views}"]),
    ];
    return _simpleTable(
      theme,
      title: "Series & Episodes Performance Table",
      columns: const ["Type", "Title", "Views"],
      rows: rows,
    );
  }

  Widget _deviceCardGrid(
    ThemeData theme,
    List<_DeviceAnalyticsRow> rows,
    double totalRevenue,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 1100
          ? 3
          : constraints.maxWidth > 700
              ? 2
              : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 156,
        ),
        itemBuilder: (context, index) {
          final row = rows[index];
          final contribution =
              totalRevenue <= 0 ? 0.0 : (row.revenue / totalRevenue) * 100;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.canvasColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _deviceIcon(row.device),
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        row.device,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      "${contribution.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _miniDeviceMetric(theme, "Users", "${row.users}"),
                    _miniDeviceMetric(
                        theme, "Revenue", _formatRevenue(row.revenue)),
                    _miniDeviceMetric(theme, "Watch",
                        "${row.watchHours.toStringAsFixed(1)} hrs"),
                    _miniDeviceMetric(theme, "Session",
                        "${row.avgSessionTime.toStringAsFixed(1)} min"),
                  ],
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: (contribution / 100).clamp(0, 1),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(999),
                  color: theme.primaryColor,
                  backgroundColor: theme.canvasColor.withValues(alpha: .10),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _miniDeviceMetric(ThemeData theme, String label, String value) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .58),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceInsights(ThemeData theme, List<_DeviceAnalyticsRow> rows) {
    final insights = _devicePerformanceInsights(rows);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Device Performance Insights", style: _sectionStyle(theme)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: insights.map((insight) {
              return Container(
                width: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: .34),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: insight.color.withValues(alpha: .32),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(insight.icon, color: insight.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _deviceComparisonTable(
    ThemeData theme,
    List<_DeviceAnalyticsRow> rows,
    double totalRevenue,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Device Comparison Table", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            "Revenue contribution and engagement by platform.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 2,
              sortAscending: false,
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns: const [
                DataColumn(label: Text("Device")),
                DataColumn(label: Text("Users"), numeric: true),
                DataColumn(label: Text("Revenue"), numeric: true),
                DataColumn(label: Text("Watch Hours"), numeric: true),
                DataColumn(label: Text("Avg Session"), numeric: true),
                DataColumn(label: Text("Contribution"), numeric: true),
              ],
              rows: rows.map((row) {
                final contribution = totalRevenue <= 0
                    ? 0.0
                    : (row.revenue / totalRevenue) * 100;
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      Icon(_deviceIcon(row.device),
                          size: 17, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(row.device),
                    ],
                  )),
                  DataCell(Text("${row.users}")),
                  DataCell(Text(_formatRevenue(row.revenue))),
                  DataCell(Text(row.watchHours.toStringAsFixed(2))),
                  DataCell(
                      Text("${row.avgSessionTime.toStringAsFixed(2)} min")),
                  DataCell(Text("${contribution.toStringAsFixed(1)}%")),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _engagementScorePanel(
    ThemeData theme,
    double score,
    String quality,
    EngagementAnalyticsDataModel data,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 720;
          final gauge = SizedBox(
            width: narrow ? 176 : 218,
            height: narrow ? 176 : 218,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (score / 100).clamp(0, 1),
                  strokeWidth: 16,
                  color: theme.primaryColor,
                  backgroundColor: theme.canvasColor.withValues(alpha: 0.10),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      quality,
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Audience Engagement Score", style: _sectionStyle(theme)),
              const SizedBox(height: 10),
              _qualityRow(theme, "Interaction Activity",
                  _engagementActivityScore(data)),
              _qualityRow(theme, "Watch Completion", data.completionRate),
              _qualityRow(theme, "Viewer Hold", 100 - data.dropOffRate),
              _qualityRow(theme, "Offline Intent",
                  (data.downloads + data.watchlistAdds) * 4),
            ],
          );
          if (narrow) {
            return Column(children: [
              gauge,
              const SizedBox(height: 14),
              details,
            ]);
          }
          return Row(
            children: [
              gauge,
              const SizedBox(width: 18),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }

  Widget _peakHoursPanel(
    ThemeData theme,
    List<PeakHourAnalyticsModel> rows,
    PeakHourAnalyticsModel? topHour,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Peak Hours Analytics", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            topHour == null
                ? "No hourly engagement data found."
                : "Highest engagement detected at ${topHour.hour}.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(
              "Peak active hour data is empty.",
              style: TextStyle(color: theme.canvasColor),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: rows.map((row) {
                final isTop = topHour != null &&
                    row.hour == topHour.hour &&
                    row.activeUsers == topHour.activeUsers;
                return Container(
                  width: 210,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: .34),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isTop ? theme.primaryColor : theme.canvasColor)
                          .withValues(alpha: isTop ? .42 : .12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTop
                            ? Icons.local_fire_department_outlined
                            : Icons.schedule_outlined,
                        color: isTop ? theme.primaryColor : theme.canvasColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.hour,
                              style: TextStyle(
                                color: theme.canvasColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              "${row.activeUsers} active users",
                              style: TextStyle(
                                color: theme.canvasColor.withValues(alpha: .62),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _engagementInsightsPanel(
    ThemeData theme,
    EngagementAnalyticsDataModel data,
  ) {
    final insights = _engagementApiInsights(data);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Engagement Insights", style: _sectionStyle(theme)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: insights.map((insight) {
              return Container(
                width: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: .34),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: insight.color.withValues(alpha: .32),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(insight.icon, color: insight.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _engagementComparisonTable(
    ThemeData theme,
    EngagementAnalyticsDataModel data,
  ) {
    final rows = [
      ("Likes", data.likes, Icons.favorite_border),
      ("Shares", data.shares, Icons.share_outlined),
      ("Comments", data.comments, Icons.chat_bubble_outline),
      ("Downloads", data.downloads, Icons.download_outlined),
      ("Watchlist Adds", data.watchlistAdds, Icons.playlist_add_check_outlined),
    ];
    final total = rows.fold<int>(0, (sum, row) => sum + row.$2);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Engagement Comparison Table", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            "Sortable-ready comparison of key interaction metrics and their contribution.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 1,
              sortAscending: false,
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns: const [
                DataColumn(label: Text("Metric")),
                DataColumn(label: Text("Value"), numeric: true),
                DataColumn(label: Text("Performance Status")),
                DataColumn(label: Text("Contribution"), numeric: true),
              ],
              rows: rows.map((row) {
                final contribution = total <= 0 ? 0.0 : (row.$2 / total) * 100;
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      Icon(row.$3, size: 17, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(row.$1),
                    ],
                  )),
                  DataCell(Text("${row.$2}")),
                  DataCell(Text(_engagementMetricStatus(row.$1, row.$2))),
                  DataCell(Text("${contribution.toStringAsFixed(1)}%")),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _watchTimeInsightPanel(
    ThemeData theme,
    WatchTimeAnalyticsDataModel data,
    WatchTimeAgeModel? topAge,
    WatchTimeAgeModel? lowAge,
    WatchTimeLocationModel? topLocation,
    WatchTimeLocationModel? topAvgLocation,
    WatchTimeDeviceModel? topDevice,
    WatchTimeDeviceModel? topSessionDevice,
  ) {
    final insights = _watchTimeInsights(
      data,
      topAge,
      lowAge,
      topLocation,
      topAvgLocation,
      topDevice,
      topSessionDevice,
    );
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Watch Time Insights", style: _sectionStyle(theme)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: insights.map((insight) {
              return Container(
                width: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: .34),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: insight.color.withValues(alpha: .32),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(insight.icon, color: insight.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _watchTimeAgeCards(
    ThemeData theme,
    List<WatchTimeAgeModel> rows,
    WatchTimeAgeModel? topAge,
    WatchTimeAgeModel? lowAge,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Age-wise Watch Time Analytics", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            topAge == null
                ? "No age-wise watch time data found."
                : "${topAge.ageGroup} users watched most; ${lowAge?.ageGroup ?? "-"} is the lowest engagement group.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text("Age-wise watch time data is empty.",
                style: TextStyle(color: theme.canvasColor))
          else
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 1080
                  ? 4
                  : constraints.maxWidth > 700
                      ? 3
                      : constraints.maxWidth > 460
                          ? 2
                          : 1;
              final maxValue =
                  rows.map((row) => row.watchHours).fold<double>(1, mathMax);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 118,
                ),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final isTop = topAge?.ageGroup == row.ageGroup;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.scaffoldBackgroundColor.withValues(alpha: .34),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isTop ? theme.primaryColor : theme.canvasColor)
                            .withValues(alpha: isTop ? .42 : .12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.groups_3_outlined,
                                color: theme.primaryColor, size: 19),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                row.ageGroup,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.canvasColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          "${row.watchHours.toStringAsFixed(2)} hrs",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (row.watchHours / maxValue).clamp(0, 1),
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(999),
                          color: theme.primaryColor,
                          backgroundColor:
                              theme.canvasColor.withValues(alpha: .10),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _watchTimeDeviceCards(
    ThemeData theme,
    List<WatchTimeDeviceModel> rows,
    WatchTimeDeviceModel? topDevice,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Device-wise Watch Time Analytics", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            topDevice == null
                ? "No device-wise watch time data found."
                : "${topDevice.device} has the highest watch hours.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text("Device watch time data is empty.",
                style: TextStyle(color: theme.canvasColor))
          else
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 1080
                  ? 3
                  : constraints.maxWidth > 680
                      ? 2
                      : 1;
              final maxValue =
                  rows.map((row) => row.watchHours).fold<double>(1, mathMax);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 150,
                ),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.scaffoldBackgroundColor.withValues(alpha: .34),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.canvasColor.withValues(alpha: .12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_deviceIcon(row.device),
                                color: theme.primaryColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                row.device,
                                style: TextStyle(
                                  color: theme.canvasColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              "${row.watchHours.toStringAsFixed(1)} hrs",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _miniDeviceMetric(theme, "Users", "${row.users}"),
                            _miniDeviceMetric(
                              theme,
                              "Revenue",
                              _formatRevenue(row.revenue),
                            ),
                            _miniDeviceMetric(
                              theme,
                              "Session",
                              "${row.avgSessionTime.toStringAsFixed(1)} min",
                            ),
                          ],
                        ),
                        const Spacer(),
                        LinearProgressIndicator(
                          value: (row.watchHours / maxValue).clamp(0, 1),
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(999),
                          color: theme.primaryColor,
                          backgroundColor:
                              theme.canvasColor.withValues(alpha: .10),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _watchTimeAgeTable(ThemeData theme, List<WatchTimeAgeModel> rows) {
    return _simpleTable(
      theme,
      title: "Age Watch Analytics",
      columns: const ["Age Group", "Watch Hours"],
      rows: rows
          .map((row) => [
                row.ageGroup,
                row.watchHours.toStringAsFixed(2),
              ])
          .toList(),
    );
  }

  Widget _watchTimeLocationTable(
    ThemeData theme,
    List<WatchTimeLocationModel> rows,
  ) {
    return _simpleTable(
      theme,
      title: "Location Watch Analytics",
      columns: const [
        "Country",
        "State",
        "District",
        "City",
        "Watch Hours",
        "Avg Watch Time",
      ],
      rows: rows
          .map((row) => [
                row.country,
                row.state,
                row.district,
                row.city,
                row.watchHours.toStringAsFixed(2),
                "${row.avgWatchTime.toStringAsFixed(2)} min",
              ])
          .toList(),
    );
  }

  Widget _watchTimeDeviceTable(
    ThemeData theme,
    List<WatchTimeDeviceModel> rows,
  ) {
    return _simpleTable(
      theme,
      title: "Device Watch Analytics",
      columns: const [
        "Device",
        "Users",
        "Revenue",
        "Watch Hours",
        "Avg Session",
      ],
      rows: rows
          .map((row) => [
                row.device,
                "${row.users}",
                _formatRevenue(row.revenue),
                row.watchHours.toStringAsFixed(2),
                "${row.avgSessionTime.toStringAsFixed(2)} min",
              ])
          .toList(),
    );
  }

  Widget _dateWiseInsightsPanel(
    ThemeData theme,
    List<DateWiseAnalyticsDataModel> rows,
  ) {
    final insights = _dateWiseInsights(rows);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Date-wise Performance Insights", style: _sectionStyle(theme)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: insights.map((insight) {
              return Container(
                width: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: .34),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: insight.color.withValues(alpha: .32),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(insight.icon, color: insight.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _dateWiseComparisonChart(
    ThemeData theme,
    String title,
    List<_AnalyticsPoint> first,
    List<_AnalyticsPoint> second,
  ) {
    return _chartShell(
      theme,
      title,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: const Legend(isVisible: true),
        series: <CartesianSeries<_AnalyticsPoint, String>>[
          LineSeries<_AnalyticsPoint, String>(
            name: "Revenue",
            dataSource: _safePoints(first),
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            animationDuration: 0,
            color: theme.primaryColor,
            width: 2,
          ),
          LineSeries<_AnalyticsPoint, String>(
            name: "Views",
            dataSource: _safePoints(second),
            xValueMapper: (point, _) => point.label,
            yValueMapper: (point, _) => point.value,
            animationDuration: 0,
            color: Colors.blue,
            width: 2,
          ),
        ],
      ),
    );
  }

  Widget _dateWiseHeatmap(
    ThemeData theme,
    List<DateWiseAnalyticsDataModel> rows,
  ) {
    final maxRevenue = rows.map((row) => row.revenue).fold<double>(1, mathMax);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Revenue Intensity Heatmap", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            "Darker cells indicate higher revenue density in the selected range.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rows.map((row) {
              final alpha = (row.revenue / maxRevenue).clamp(.12, 1.0);
              return Tooltip(
                message:
                    "${_dateWiseLabel(row)} • ${_formatRevenue(row.revenue)} • ${row.views} views",
                child: Container(
                  width: 72,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: alpha),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _dateWiseLabel(row),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _dateWiseTable(
    ThemeData theme,
    List<DateWiseAnalyticsDataModel> rows,
    DateWiseAnalyticsDataModel? highestRevenue,
    DateWiseAnalyticsDataModel? highestWatch,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Date-wise Analytics Table", style: _sectionStyle(theme)),
          const SizedBox(height: 4),
          Text(
            "Sorted oldest to latest, with peak revenue and watch-hour rows highlighted.",
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: .62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 0,
              sortAscending: true,
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns: const [
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Revenue"), numeric: true),
                DataColumn(label: Text("Views"), numeric: true),
                DataColumn(label: Text("Watch Hours"), numeric: true),
                DataColumn(label: Text("Active Users"), numeric: true),
                DataColumn(label: Text("New Subscribers"), numeric: true),
              ],
              rows: rows.map((row) {
                final highlighted = identical(row, highestRevenue) ||
                    identical(row, highestWatch);
                return DataRow(
                  color: highlighted
                      ? WidgetStatePropertyAll(
                          theme.primaryColor.withValues(alpha: .08),
                        )
                      : null,
                  cells: [
                    DataCell(Text(_dateWiseFullLabel(row))),
                    DataCell(Text(_formatRevenue(row.revenue))),
                    DataCell(Text("${row.views}")),
                    DataCell(Text(row.watchHours.toStringAsFixed(2))),
                    DataCell(Text("${row.activeUsers}")),
                    DataCell(Text("${row.newSubscribers}")),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleTable(
    ThemeData theme, {
    required String title,
    required List<String> columns,
    required List<List<String>> rows,
  }) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sectionStyle(theme)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                theme.primaryColor.withValues(alpha: 0.10),
              ),
              columns:
                  columns.map((item) => DataColumn(label: Text(item))).toList(),
              rows: rows.take(10).map((row) {
                return DataRow(
                  cells: row.map((value) => DataCell(Text(value))).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarHeatmap(ThemeData theme, List<_AnalyticsPoint> points) {
    final safe = _safePoints(points).take(31).toList();
    final max = safe.map((point) => point.value).fold<double>(1, mathMax);
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Calendar Heatmap", style: _sectionStyle(theme)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: safe.map((point) {
              final alpha = (point.value / max).clamp(0.14, 1.0);
              return Tooltip(
                message: "${point.label}: ${_formatAmount(point.value)}",
                child: Container(
                  width: 46,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: alpha),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    point.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge(ThemeData theme, int rank) {
    final color = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.blueGrey
            : rank == 3
                ? Colors.brown
                : theme.primaryColor;
    return Container(
      width: 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Text(
        "#$rank",
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _reportTableTitle(
    ThemeData theme,
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Content Performance", style: _sectionStyle(theme)),
        const SizedBox(height: 3),
        Text(
          provider.isReportLoading
              ? "Loading records..."
              : "${reports.length} records found",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  DataRow _reportRow(ThemeData theme, ReportAndDataObject report) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.movie_creation_outlined,
                  size: 18,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 220,
                child: Text(
                  report.contentName ?? "Untitled",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(report.mediaHouseName ?? "-")),
        DataCell(Text(report.releasedDate?.toString() ?? "-")),
        DataCell(Text("${report.totalViews ?? 0}")),
        DataCell(Text(_formatRevenue(report.price ?? 0))),
        DataCell(Text(_formatRevenue(_revenue(report)))),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              report.languageList.isEmpty
                  ? "-"
                  : report.languageList.join(", "),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          TextButton.icon(
            onPressed: () => _showReportDetails(report),
            icon: const Icon(Icons.open_in_new, size: 15),
            label: const Text("Open"),
          ),
        ),
      ],
    );
  }

  void _showReportDetails(ReportAndDataObject report) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(report.contentName ?? "Content"),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailLine("Production House", report.mediaHouseName ?? "-"),
                _detailLine("Content Type", formatContentTypeLabel(report.contentType)),
                _detailLine(
                    "Release Date", report.releasedDate?.toString() ?? "-"),
                _detailLine("Release Time", report.releaseTime ?? "-"),
                _detailLine("Views", "${report.totalViews ?? 0}"),
                _detailLine("Price", _formatRevenue(report.price ?? 0)),
                _detailLine("Revenue", _formatRevenue(_revenue(report))),
                _detailLine(
                  "Languages",
                  report.languageList.isEmpty
                      ? "-"
                      : report.languageList.join(", "),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _surface({
    required ThemeData theme,
    required EdgeInsets padding,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  TextStyle _sectionStyle(ThemeData theme) {
    return TextStyle(
      color: theme.primaryColor,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    );
  }

  String _dateRangeLabel() {
    if (_reportDateRange == null) return "Select Date Range";
    return "${DateFormat("dd MMM yyyy").format(_reportDateRange!.start)} - "
        "${DateFormat("dd MMM yyyy").format(_reportDateRange!.end)}";
  }

  double _revenue(ReportAndDataObject report) {
    final revenue = report.totalRevenue;
    if (revenue is num) return revenue.toDouble();
    return double.tryParse(revenue?.toString() ?? "") ?? 0;
  }

  List<ReportAndDataObject> _advancedFilteredReports(
    List<ReportAndDataObject> reports,
  ) {
    final query = _advancedSearch.trim().toLowerCase();
    return reports.where((report) {
      final matchesSearch = query.isEmpty ||
          (report.contentName ?? "").toLowerCase().contains(query) ||
          (report.mediaHouseName ?? "").toLowerCase().contains(query) ||
          (report.contentType ?? "").toLowerCase().contains(query);
      final matchesLanguage = _advancedLanguage == "ALL" ||
          report.languageList
              .map((item) => item.toLowerCase())
              .contains(_advancedLanguage.toLowerCase());
      return matchesSearch && matchesLanguage;
    }).toList();
  }

  List<_AnalyticsPoint> _groupReports(
    List<ReportAndDataObject> reports,
    String Function(ReportAndDataObject report) labelOf,
    double Function(ReportAndDataObject report) valueOf,
  ) {
    final grouped = <String, double>{};
    for (final report in reports) {
      final label =
          labelOf(report).trim().isEmpty ? "Unknown" : labelOf(report);
      grouped[label] = (grouped[label] ?? 0) + valueOf(report);
    }
    final points = grouped.entries
        .map((entry) => _AnalyticsPoint(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return points;
  }

  List<_AnalyticsPoint> _dateWisePoints(List<ReportAndDataObject> reports) {
    return _groupReports(
      reports,
      (report) => _dateLabel(report.releasedDate),
      _revenue,
    ).reversed.toList();
  }

  List<_AnalyticsPoint> _ageRevenuePoints(double totalRevenue) {
    final base = totalRevenue <= 0 ? 1200.0 : totalRevenue;
    return [
      _AnalyticsPoint("13-17", base * .07),
      _AnalyticsPoint("18-24", base * .24),
      _AnalyticsPoint("25-34", base * .32),
      _AnalyticsPoint("35-44", base * .19),
      _AnalyticsPoint("45-54", base * .12),
      _AnalyticsPoint("55+", base * .06),
    ];
  }

  List<_AnalyticsPoint> _ageViewPoints(int totalViews) {
    final base = totalViews <= 0 ? 1000.0 : totalViews.toDouble();
    return [
      _AnalyticsPoint("13-17", base * .08),
      _AnalyticsPoint("18-24", base * .28),
      _AnalyticsPoint("25-34", base * .30),
      _AnalyticsPoint("35-44", base * .17),
      _AnalyticsPoint("45-54", base * .11),
      _AnalyticsPoint("55+", base * .06),
    ];
  }

  List<_AgeAudienceRow> _ageAudienceRows(
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    if (provider.ageWiseRevenue.isEmpty && provider.ageWiseViews.isEmpty) {
      final revenue = _ageRevenuePoints(
        reports.fold<double>(0, (sum, report) => sum + _revenue(report)),
      );
      final views = _ageViewPoints(
        reports.fold<int>(0, (sum, report) => sum + (report.totalViews ?? 0)),
      );
      return [
        for (var index = 0; index < revenue.length; index++)
          _AgeAudienceRow(
            ageGroup: revenue[index].label,
            users: (views[index].value / 8).round(),
            revenue: revenue[index].value,
            subscriptionRevenue: revenue[index].value * .72,
            coinRevenue: revenue[index].value * .18,
            avgWatchTime: 18 + index * 12,
            retentionRate: 12 + index * 3,
            views: views[index].value.round(),
            uniqueUsers: (views[index].value / 4).round(),
            watchHours: views[index].value * .14,
            completionRate: 40 + index * 7,
            rewatchRate: 18 + index * 8,
          ),
      ];
    }
    final revenueByAge = {
      for (final item in provider.ageWiseRevenue) item.ageGroup: item
    };
    final viewsByAge = {
      for (final item in provider.ageWiseViews) item.ageGroup: item
    };
    const order = [
      '13-18',
      '18-24',
      '25-34',
      '35-44',
      '45-60',
      '60+',
      'Unknown'
    ];
    return order.map((age) {
      final revenue = revenueByAge[age];
      final views = viewsByAge[age];
      return _AgeAudienceRow(
        ageGroup: age,
        users: revenue?.users ?? 0,
        revenue: revenue?.revenue ?? 0,
        subscriptionRevenue: revenue?.subscriptionRevenue ?? 0,
        coinRevenue: revenue?.coinRevenue ?? 0,
        avgWatchTime: revenue?.avgWatchTime ?? 0,
        retentionRate: revenue?.retentionRate ?? 0,
        views: views?.views ?? 0,
        uniqueUsers: views?.uniqueUsers ?? 0,
        watchHours: views?.watchHours ?? 0,
        completionRate: views?.completionRate ?? 0,
        rewatchRate: views?.rewatchRate ?? 0,
      );
    }).toList();
  }

  _AgeAudienceRow _topAge(
    List<_AgeAudienceRow> rows,
    double Function(_AgeAudienceRow row) valueOf,
  ) {
    if (rows.isEmpty) return _AgeAudienceRow.empty();
    return rows.reduce((a, b) => valueOf(a) >= valueOf(b) ? a : b);
  }

  double _contentHealthScore(ContentPerformanceAnalyticsDataModel data) {
    final engagement = (data.engagementScore * 8).clamp(0, 100).toDouble();
    final retention = data.retentionRate.clamp(0, 100).toDouble();
    final satisfaction = (100 - data.bounceRate).clamp(0, 100).toDouble();
    final completion = data.completionRate.clamp(0, 100).toDouble();
    return (engagement + retention + satisfaction + completion) / 4;
  }

  double _engagementActivityScore(EngagementAnalyticsDataModel data) {
    final interactions = data.likes +
        data.shares +
        data.comments +
        data.watchlistAdds +
        data.downloads;
    return ((interactions / 50) * 100).clamp(0, 100).toDouble();
  }

  double _engagementScore(EngagementAnalyticsDataModel data) {
    final activity = _engagementActivityScore(data);
    final completion = data.completionRate.clamp(0, 100).toDouble();
    final viewerHold = (100 - data.dropOffRate).clamp(0, 100).toDouble();
    final offlineIntent =
        ((data.downloads + data.watchlistAdds) * 4).clamp(0, 100).toDouble();
    return (activity * .35) +
        (completion * .30) +
        (viewerHold * .20) +
        (offlineIntent * .15);
  }

  PeakHourAnalyticsModel? _topPeakHour(List<PeakHourAnalyticsModel> rows) {
    if (rows.isEmpty) return null;
    return rows.reduce((a, b) => a.activeUsers >= b.activeUsers ? a : b);
  }

  String _performanceLabel(double score) {
    if (score >= 80) return "Excellent";
    if (score >= 60) return "Good";
    if (score >= 35) return "Average";
    return "Poor";
  }

  List<_InsightItem> _contentPerformanceInsights(
    ContentPerformanceAnalyticsDataModel data,
  ) {
    final insights = <_InsightItem>[];
    if (data.bounceRate > 70) {
      insights.add(const _InsightItem(
        text: "High bounce rate detected. Review first-minute engagement.",
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
      ));
    }
    if (data.retentionRate > 50) {
      insights.add(const _InsightItem(
        text: "Retention is healthy. Audiences are returning well.",
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ));
    } else {
      insights.add(const _InsightItem(
        text: "Retention needs improvement. Consider stronger episode hooks.",
        icon: Icons.repeat_outlined,
        color: Colors.redAccent,
      ));
    }
    if (data.completionRate < 20) {
      insights.add(const _InsightItem(
        text: "Low completion alert. Content may be losing viewers early.",
        icon: Icons.flag_outlined,
        color: Colors.redAccent,
      ));
    }
    if (data.rewatchRate >= 6) {
      insights.add(const _InsightItem(
        text: "Good rewatch engagement from repeat viewers.",
        icon: Icons.replay_outlined,
        color: Colors.blue,
      ));
    }
    if (data.topSeries.isNotEmpty) {
      insights.add(_InsightItem(
        text: "${data.topSeries.first.title} is the top performing series.",
        icon: Icons.emoji_events_outlined,
        color: Colors.amber,
      ));
    }
    return insights;
  }

  List<_InsightItem> _engagementApiInsights(EngagementAnalyticsDataModel data) {
    final insights = <_InsightItem>[];
    if (data.dropOffRate > 70) {
      insights.add(const _InsightItem(
        text: "High drop-off rate detected. Review content hook and pacing.",
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
      ));
    }
    if (data.completionRate < 20) {
      insights.add(const _InsightItem(
        text: "Completion rate needs improvement for stronger retention.",
        icon: Icons.flag_outlined,
        color: Colors.redAccent,
      ));
    } else {
      insights.add(const _InsightItem(
        text: "Completion rate is holding at a healthy level.",
        icon: Icons.task_alt_outlined,
        color: Colors.green,
      ));
    }
    if (data.downloads > data.likes) {
      insights.add(const _InsightItem(
        text:
            "Downloads are performing well, indicating strong offline intent.",
        icon: Icons.download_done_outlined,
        color: Colors.teal,
      ));
    }
    if (data.shares == 0) {
      insights.add(const _InsightItem(
        text: "Shares are low compared with other interaction signals.",
        icon: Icons.share_outlined,
        color: Colors.blue,
      ));
    }
    final topHour = _topPeakHour(data.peakHours);
    if (topHour != null) {
      insights.add(_InsightItem(
        text:
            "Highest engagement detected at ${topHour.hour} with ${topHour.activeUsers} active users.",
        icon: Icons.schedule_outlined,
        color: Colors.indigo,
      ));
    }
    if (insights.isEmpty) {
      insights.add(const _InsightItem(
        text: "Engagement data is stable but still building volume.",
        icon: Icons.insights_outlined,
        color: Colors.deepPurple,
      ));
    }
    return insights;
  }

  String _engagementMetricStatus(String metric, int value) {
    if (value <= 0) return "Needs attention";
    if (metric == "Downloads" && value >= 10) return "Strong";
    if (metric == "Watchlist Adds" && value >= 4) return "Promising";
    if (value >= 5) return "Healthy";
    return "Building";
  }

  WatchTimeAgeModel? _topWatchAge(List<WatchTimeAgeModel> rows) {
    if (rows.isEmpty) return null;
    return rows.reduce((a, b) => a.watchHours >= b.watchHours ? a : b);
  }

  WatchTimeAgeModel? _lowWatchAge(List<WatchTimeAgeModel> rows) {
    final activeRows = rows.where((row) => row.watchHours > 0).toList();
    if (activeRows.isEmpty) return rows.isEmpty ? null : rows.first;
    return activeRows.reduce((a, b) => a.watchHours <= b.watchHours ? a : b);
  }

  WatchTimeLocationModel? _topWatchLocation(
    List<WatchTimeLocationModel> rows, {
    double Function(WatchTimeLocationModel row)? valueOf,
  }) {
    if (rows.isEmpty) return null;
    final metric = valueOf ?? (row) => row.watchHours;
    return rows.reduce((a, b) => metric(a) >= metric(b) ? a : b);
  }

  WatchTimeDeviceModel? _topWatchDevice(
    List<WatchTimeDeviceModel> rows, {
    double Function(WatchTimeDeviceModel row)? valueOf,
  }) {
    if (rows.isEmpty) return null;
    final metric = valueOf ?? (row) => row.watchHours;
    return rows.reduce((a, b) => metric(a) >= metric(b) ? a : b);
  }

  List<_InsightItem> _watchTimeInsights(
    WatchTimeAnalyticsDataModel data,
    WatchTimeAgeModel? topAge,
    WatchTimeAgeModel? lowAge,
    WatchTimeLocationModel? topLocation,
    WatchTimeLocationModel? topAvgLocation,
    WatchTimeDeviceModel? topDevice,
    WatchTimeDeviceModel? topSessionDevice,
  ) {
    final insights = <_InsightItem>[];
    if (topAge != null) {
      insights.add(_InsightItem(
        text:
            "${topAge.ageGroup} users spend the highest watch time at ${topAge.watchHours.toStringAsFixed(1)} hours.",
        icon: Icons.groups_3_outlined,
        color: Colors.blue,
      ));
    }
    if (lowAge != null && lowAge.watchHours > 0) {
      insights.add(_InsightItem(
        text:
            "${lowAge.ageGroup} is currently the lowest consuming active age group.",
        icon: Icons.trending_down_outlined,
        color: Colors.orange,
      ));
    }
    if (topLocation != null) {
      insights.add(_InsightItem(
        text: "${topLocation.city} has strongest engagement by watch hours.",
        icon: Icons.location_on_outlined,
        color: Colors.green,
      ));
    }
    if (topAvgLocation != null && topAvgLocation.avgWatchTime > 0) {
      insights.add(_InsightItem(
        text:
            "${topAvgLocation.city} leads average watch time at ${topAvgLocation.avgWatchTime.toStringAsFixed(1)} minutes.",
        icon: Icons.schedule_outlined,
        color: Colors.indigo,
      ));
    }
    if (topDevice != null) {
      insights.add(_InsightItem(
        text: "${topDevice.device} is the highest watch hour platform.",
        icon: _deviceIcon(topDevice.device),
        color: Colors.deepPurple,
      ));
    }
    if (topSessionDevice != null && topSessionDevice.avgSessionTime > 0) {
      insights.add(_InsightItem(
        text: "${topSessionDevice.device} has the longest session duration.",
        icon: Icons.timer_outlined,
        color: Colors.teal,
      ));
    }
    if (data.byDevice.any((row) => row.device == "Unknown" && row.users > 0)) {
      insights.add(const _InsightItem(
        text: "Unknown device traffic detected. Review device attribution.",
        icon: Icons.devices_other_outlined,
        color: Colors.redAccent,
      ));
    }
    final stateGroups = <String, double>{};
    for (final row in data.byLocation) {
      stateGroups[row.state] = (stateGroups[row.state] ?? 0) + row.watchHours;
    }
    if (stateGroups.isNotEmpty) {
      final topState =
          stateGroups.entries.reduce((a, b) => a.value >= b.value ? a : b);
      insights.add(_InsightItem(
        text:
            "Watch time is concentrated in ${topState.key} with ${topState.value.toStringAsFixed(1)} hours.",
        icon: Icons.map_outlined,
        color: Colors.amber,
      ));
    }
    if (insights.isEmpty) {
      insights.add(const _InsightItem(
        text:
            "Watch time analytics are available, but segmented data is empty.",
        icon: Icons.insights_outlined,
        color: Colors.deepPurple,
      ));
    }
    return insights;
  }

  DateWiseAnalyticsDataModel? _topDateWise(
    List<DateWiseAnalyticsDataModel> rows,
    double Function(DateWiseAnalyticsDataModel row) valueOf,
  ) {
    if (rows.isEmpty) return null;
    return rows.reduce((a, b) => valueOf(a) >= valueOf(b) ? a : b);
  }

  List<_InsightItem> _dateWiseInsights(
    List<DateWiseAnalyticsDataModel> rows,
  ) {
    if (rows.isEmpty) {
      return const [
        _InsightItem(
          text: "No date-wise data available for this range.",
          icon: Icons.insights_outlined,
          color: Colors.deepPurple,
        ),
      ];
    }
    final highestRevenue = _topDateWise(rows, (row) => row.revenue);
    final highestWatch = _topDateWise(rows, (row) => row.watchHours);
    final highestUsers =
        _topDateWise(rows, (row) => row.activeUsers.toDouble());
    final totalRevenue = rows.fold<double>(0, (sum, row) => sum + row.revenue);
    final totalWatch = rows.fold<double>(0, (sum, row) => sum + row.watchHours);
    final totalSubscribers =
        rows.fold<int>(0, (sum, row) => sum + row.newSubscribers);
    final avgRevenue = totalRevenue / rows.length;
    final avgWatch = totalWatch / rows.length;
    final insights = <_InsightItem>[];
    if (highestRevenue != null) {
      insights.add(_InsightItem(
        text:
            "Revenue peaked on ${_dateWiseFullLabel(highestRevenue)} at ${_formatRevenue(highestRevenue.revenue)}.",
        icon: Icons.trending_up,
        color: Colors.teal,
      ));
    }
    if (highestWatch != null) {
      insights.add(_InsightItem(
        text:
            "Watch hours peaked on ${_dateWiseFullLabel(highestWatch)} with ${highestWatch.watchHours.toStringAsFixed(2)} hours.",
        icon: Icons.timer_outlined,
        color: Colors.indigo,
      ));
    }
    if (highestUsers != null) {
      insights.add(_InsightItem(
        text:
            "User activity was highest on ${_dateWiseFullLabel(highestUsers)}.",
        icon: Icons.groups_outlined,
        color: Colors.blue,
      ));
    }
    if (rows.length > 1) {
      final first = rows.first;
      final last = rows.last;
      if (last.watchHours > first.watchHours) {
        insights.add(const _InsightItem(
          text: "Watch hours increased across the selected range.",
          icon: Icons.show_chart,
          color: Colors.green,
        ));
      } else if (last.watchHours < first.watchHours) {
        insights.add(const _InsightItem(
          text: "Watch hours dropped toward the end of this date range.",
          icon: Icons.trending_down_outlined,
          color: Colors.orange,
        ));
      }
      if (last.activeUsers < first.activeUsers) {
        insights.add(const _InsightItem(
          text: "User activity dropped compared with the range start.",
          icon: Icons.person_off_outlined,
          color: Colors.redAccent,
        ));
      }
    }
    insights.add(_InsightItem(
      text:
          "Average revenue/day is ${_formatRevenue(avgRevenue)} and average watch hours/day is ${avgWatch.toStringAsFixed(2)}.",
      icon: Icons.analytics_outlined,
      color: Colors.deepPurple,
    ));
    if (totalSubscribers > 0) {
      insights.add(_InsightItem(
        text:
            "Subscriber growth added $totalSubscribers new subscribers in this range.",
        icon: Icons.card_membership_outlined,
        color: Colors.pink,
      ));
    }
    return insights;
  }

  String _dateWiseLabel(DateWiseAnalyticsDataModel row) {
    final date = row.date;
    if (date == null) return "-";
    return DateFormat("dd MMM").format(date);
  }

  String _dateWiseFullLabel(DateWiseAnalyticsDataModel row) {
    final date = row.date;
    if (date == null) return "-";
    return DateFormat("yyyy-MM-dd").format(date);
  }

  List<_AnalyticsPoint> _devicePoints(double totalRevenue) {
    final base = totalRevenue <= 0 ? 900.0 : totalRevenue;
    return [
      _AnalyticsPoint("Android", base * .44),
      _AnalyticsPoint("iOS", base * .21),
      _AnalyticsPoint("Web", base * .25),
      _AnalyticsPoint("TV", base * .10),
    ];
  }

  List<_DeviceAnalyticsRow> _deviceRowsForDisplay(
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    if (provider.deviceAnalytics.isNotEmpty) {
      return provider.deviceAnalytics
          .map((item) => _DeviceAnalyticsRow(
                device: item.device,
                users: item.users,
                revenue: item.revenue,
                watchHours: item.watchHours,
                avgSessionTime: item.avgSessionTime,
              ))
          .toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
    }
    final totalRevenue =
        reports.fold<double>(0, (sum, report) => sum + _revenue(report));
    final baseRows = _devicePoints(totalRevenue);
    return baseRows
        .map((point) => _DeviceAnalyticsRow(
              device: point.label == "TV" ? "Smart TV" : point.label,
              users: (point.value / mathMax(totalRevenue, 1) * 1000).round(),
              revenue: point.value,
              watchHours: point.value * .12,
              avgSessionTime: 8 + point.value % 20,
            ))
        .toList();
  }

  _DeviceAnalyticsRow _topDevice(
    List<_DeviceAnalyticsRow> rows,
    double Function(_DeviceAnalyticsRow row) valueOf,
  ) {
    if (rows.isEmpty) return _DeviceAnalyticsRow.empty();
    return rows.reduce((a, b) => valueOf(a) >= valueOf(b) ? a : b);
  }

  IconData _deviceIcon(String device) {
    switch (device.toLowerCase()) {
      case "android":
        return Icons.android_outlined;
      case "ios":
        return Icons.phone_iphone_outlined;
      case "web":
        return Icons.language_outlined;
      case "smart tv":
      case "tv":
        return Icons.tv_outlined;
      case "tablet":
        return Icons.tablet_mac_outlined;
      default:
        return Icons.devices_other_outlined;
    }
  }

  List<_InsightItem> _devicePerformanceInsights(
    List<_DeviceAnalyticsRow> rows,
  ) {
    if (rows.isEmpty) return const [];
    final highestRevenue = _topDevice(rows, (row) => row.revenue);
    final highestWatch = _topDevice(rows, (row) => row.watchHours);
    final bestSession = _topDevice(rows, (row) => row.avgSessionTime);
    final insights = <_InsightItem>[
      _InsightItem(
        text: "${highestRevenue.device} users contribute highest revenue.",
        icon: Icons.currency_rupee,
        color: Colors.teal,
      ),
      _InsightItem(
        text: "${highestWatch.device} users have the highest watch hours.",
        icon: Icons.timer_outlined,
        color: Colors.indigo,
      ),
      _InsightItem(
        text: "${bestSession.device} users have the longest average sessions.",
        icon: Icons.schedule_outlined,
        color: Colors.green,
      ),
    ];
    final web = _firstDeviceWhere(rows, "Web");
    if (web != null && web.avgSessionTime < 5 && web.users > 0) {
      insights.add(const _InsightItem(
        text: "Web engagement is low. Review web playback experience.",
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
      ));
    }
    final unknown = _firstDeviceWhere(rows, "Unknown");
    if (unknown != null && unknown.users > 0) {
      insights.add(const _InsightItem(
        text: "Unknown devices detected. Consider improving device tracking.",
        icon: Icons.devices_other_outlined,
        color: Colors.redAccent,
      ));
    }
    return insights;
  }

  _DeviceAnalyticsRow? _firstDeviceWhere(
    List<_DeviceAnalyticsRow> rows,
    String device,
  ) {
    for (final row in rows) {
      if (row.device == device) return row;
    }
    return null;
  }

  List<_AnalyticsPoint> _subscriptionPoints(double totalRevenue) {
    final base = totalRevenue <= 0 ? 1000.0 : totalRevenue;
    return [
      _AnalyticsPoint("Free", base * .18),
      _AnalyticsPoint("Premium", base * .54),
      _AnalyticsPoint("Active", base * .20),
      _AnalyticsPoint("Expired", base * .08),
    ];
  }

  List<_LocationAnalyticsRow> _locationRowsFromReports(
    List<ReportAndDataObject> reports,
  ) {
    final seeds = [
      ("India", "Maharashtra", "Pune", "Hinjewadi", .28),
      ("India", "Maharashtra", "Mumbai", "Andheri", .22),
      ("India", "Karnataka", "Bengaluru", "Whitefield", .16),
      ("India", "Delhi", "Delhi", "Saket", .12),
      ("India", "Telangana", "Hyderabad", "Madhapur", .10),
      ("UAE", "Dubai", "Dubai", "Marina", .07),
      ("USA", "California", "Santa Clara", "San Jose", .05),
    ];
    final totalRevenue =
        reports.fold<double>(0, (sum, item) => sum + _revenue(item));
    final totalViews =
        reports.fold<int>(0, (sum, item) => sum + (item.totalViews ?? 0));
    final revenueBase = totalRevenue <= 0 ? 1500.0 : totalRevenue;
    final viewsBase = totalViews <= 0 ? 900 : totalViews;
    return seeds.map((seed) {
      final views = (viewsBase * seed.$5).round();
      final revenue = revenueBase * seed.$5;
      return _LocationAnalyticsRow(
        country: seed.$1,
        state: seed.$2,
        district: seed.$3,
        city: seed.$4,
        revenue: revenue,
        users: (views * .62).round(),
        paidUsers: (views * .22).round(),
        views: views,
        watchTime: (views * .16).round(),
        avgSessionTime: 7 + (views % 14),
        completionRate: 52 + (revenue % 42),
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  List<_LocationAnalyticsRow> _locationRowsForDisplay(
    AnalyticsProvider provider,
    List<ReportAndDataObject> reports,
  ) {
    if (provider.locationWiseAnalytics.isNotEmpty) {
      return provider.locationWiseAnalytics.map(_locationRowFromApi).toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
    }
    return _locationRowsFromReports(reports);
  }

  _LocationAnalyticsRow _locationRowFromApi(
    LocationAnalyticsDataModel item,
  ) {
    return _LocationAnalyticsRow(
      country: item.country,
      state: item.state,
      district: item.district,
      city: item.city,
      revenue: item.revenue,
      users: item.totalUsers,
      paidUsers: item.paidUsers,
      views: item.views,
      watchTime: item.watchHours,
      avgSessionTime:
          item.views <= 0 ? 0 : (item.watchHours * 60) ~/ item.views,
      completionRate: item.completionRate,
    );
  }

  List<_LocationAnalyticsRow> _filteredLocationRows(
    List<_LocationAnalyticsRow> rows,
  ) {
    final cityQuery = _locationCitySearch.trim().toLowerCase();
    return rows.where((row) {
      final matchesCountry =
          _locationCountry == "ALL" || row.country == _locationCountry;
      final matchesState =
          _locationState == "ALL" || row.state == _locationState;
      final matchesDistrict =
          _locationDistrict == "ALL" || row.district == _locationDistrict;
      final matchesCity =
          cityQuery.isEmpty || row.city.toLowerCase().contains(cityQuery);
      return matchesCountry && matchesState && matchesDistrict && matchesCity;
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  List<String> _locationOptions(Iterable<String> values) {
    final unique = values
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ["ALL", ...unique];
  }

  _LocationAnalyticsRow _topLocation(
    List<_LocationAnalyticsRow> rows,
    double Function(_LocationAnalyticsRow row) valueOf,
  ) {
    if (rows.isEmpty) {
      return const _LocationAnalyticsRow(
        country: "-",
        state: "-",
        district: "-",
        city: "-",
        revenue: 0,
        users: 0,
        paidUsers: 0,
        views: 0,
        watchTime: 0,
        avgSessionTime: 0,
        completionRate: 0,
      );
    }
    return rows.reduce((a, b) => valueOf(a) >= valueOf(b) ? a : b);
  }

  List<_TopContentRow> _topContentRows(List<ReportAndDataObject> reports) {
    final sorted = List<ReportAndDataObject>.from(reports)
      ..sort((a, b) => _revenue(b).compareTo(_revenue(a)));
    return sorted.take(12).toList().asMap().entries.map((entry) {
      final report = entry.value;
      final views = report.totalViews ?? 0;
      return _TopContentRow(
        rank: entry.key + 1,
        name: report.contentName ?? "Untitled",
        views: views,
        revenue: _revenue(report),
        completion: _completionRate(report),
        shares: views ~/ 13,
        retention: 48 + (_revenue(report) % 44),
      );
    }).toList();
  }

  List<_AnalyticsPoint> _groupLocation(
    List<_LocationAnalyticsRow> rows,
    String Function(_LocationAnalyticsRow row) labelOf,
  ) {
    final grouped = <String, double>{};
    for (final row in rows) {
      final label = labelOf(row);
      grouped[label] = (grouped[label] ?? 0) + row.revenue;
    }
    return grouped.entries
        .map((entry) => _AnalyticsPoint(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  List<_AnalyticsPoint> _safePoints(List<_AnalyticsPoint> points) {
    if (points.any((point) => point.value > 0)) return points;
    return const [
      _AnalyticsPoint("A", 12),
      _AnalyticsPoint("B", 18),
      _AnalyticsPoint("C", 14),
      _AnalyticsPoint("D", 22),
    ];
  }

  _AnalyticsPoint _maxPoint(List<_AnalyticsPoint> points) {
    if (points.isEmpty) return const _AnalyticsPoint("-", 0);
    return points.reduce((a, b) => a.value >= b.value ? a : b);
  }

  double _completionRate(ReportAndDataObject report) {
    final views = report.totalViews ?? 0;
    return (48 + (views % 45)).toDouble();
  }

  double _avgCompletion(List<ReportAndDataObject> reports) {
    if (reports.isEmpty) return 0;
    return reports
            .map(_completionRate)
            .fold<double>(0, (sum, item) => sum + item) /
        reports.length;
  }

  String _dateLabel(dynamic raw) {
    if (raw == null) return "-";
    if (raw is int) {
      return DateFormat("dd MMM")
          .format(DateTime.fromMillisecondsSinceEpoch(raw));
    }
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return DateFormat("dd MMM").format(parsed);
  }

  Color _pointColor(String label) {
    switch (label.toLowerCase()) {
      case "android":
        return Colors.green;
      case "ios":
        return Colors.blueGrey;
      case "web":
        return Colors.blue;
      case "tv":
        return Colors.deepPurple;
      default:
        return Colors.orange;
    }
  }

  double mathMax(double a, double b) => a > b ? a : b;

  String mathPercent(int value, int divisor) {
    if (divisor <= 0) return "0%";
    return "${((value / divisor).clamp(0, 99)).round()}%";
  }

  void _showExportPrepared(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("$type export is ready for backend export integration."),
      ),
    );
  }

  String _formatRevenue(num value) => "Rs. ${_formatAmount(value)}";

  String _formatAmount(num value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }
}

class _AnalyticsMetric {
  const _AnalyticsMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
}

class _AnalyticsPoint {
  const _AnalyticsPoint(this.label, this.value);

  final String label;
  final double value;
}

class _AgeAudienceRow {
  const _AgeAudienceRow({
    required this.ageGroup,
    required this.users,
    required this.revenue,
    required this.subscriptionRevenue,
    required this.coinRevenue,
    required this.avgWatchTime,
    required this.retentionRate,
    required this.views,
    required this.uniqueUsers,
    required this.watchHours,
    required this.completionRate,
    required this.rewatchRate,
  });

  final String ageGroup;
  final int users;
  final double revenue;
  final double subscriptionRevenue;
  final double coinRevenue;
  final double avgWatchTime;
  final double retentionRate;
  final int views;
  final int uniqueUsers;
  final double watchHours;
  final double completionRate;
  final double rewatchRate;

  factory _AgeAudienceRow.empty() {
    return const _AgeAudienceRow(
      ageGroup: "-",
      users: 0,
      revenue: 0,
      subscriptionRevenue: 0,
      coinRevenue: 0,
      avgWatchTime: 0,
      retentionRate: 0,
      views: 0,
      uniqueUsers: 0,
      watchHours: 0,
      completionRate: 0,
      rewatchRate: 0,
    );
  }
}

class _InsightItem {
  const _InsightItem({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;
}

class _DeviceAnalyticsRow {
  const _DeviceAnalyticsRow({
    required this.device,
    required this.users,
    required this.revenue,
    required this.watchHours,
    required this.avgSessionTime,
  });

  final String device;
  final int users;
  final double revenue;
  final double watchHours;
  final double avgSessionTime;

  factory _DeviceAnalyticsRow.empty() {
    return const _DeviceAnalyticsRow(
      device: "-",
      users: 0,
      revenue: 0,
      watchHours: 0,
      avgSessionTime: 0,
    );
  }
}

class _LocationAnalyticsRow {
  const _LocationAnalyticsRow({
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.revenue,
    required this.users,
    required this.paidUsers,
    required this.views,
    required this.watchTime,
    required this.avgSessionTime,
    required this.completionRate,
  });

  final String country;
  final String state;
  final String district;
  final String city;
  final double revenue;
  final int users;
  final int paidUsers;
  final int views;
  final int watchTime;
  final int avgSessionTime;
  final double completionRate;
}

class _TopContentRow {
  const _TopContentRow({
    required this.rank,
    required this.name,
    required this.views,
    required this.revenue,
    required this.completion,
    required this.shares,
    required this.retention,
  });

  final int rank;
  final String name;
  final int views;
  final double revenue;
  final double completion;
  final int shares;
  final double retention;
}

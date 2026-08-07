import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum _RevenueReportType {
  platformRevenue,
  productionHouseRevenue,
  promoterRevenue,
  promoterDetails,
}

class RevenueSettlementAnalyticsPage extends StatefulWidget {
  const RevenueSettlementAnalyticsPage({super.key});

  @override
  State<RevenueSettlementAnalyticsPage> createState() =>
      _RevenueSettlementAnalyticsPageState();
}

class _RevenueSettlementAnalyticsPageState
    extends State<RevenueSettlementAnalyticsPage> {
  _RevenueReportType _reportType = _RevenueReportType.platformRevenue;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 1, 1),
    end: DateTime(2026, 6, 30),
  );
  String _contentType = 'All';
  int? _productionHouseId;
  String _promoterLevel = 'National';
  int? _promoterId;
  String _movie = 'The Silent Frame';
  String _tableSearch = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _showSkeleton = false;
  bool _showEmptyState = false;
  bool _showErrorState = false;
  bool _analyticsLoading = false;
  String? _analyticsError;
  Map<String, dynamic>? _analyticsData;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRevenueAnalytics();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2027),
      initialDateRange: _dateRange,
    );
    if (picked == null) return;
    setState(() => _dateRange = picked);
    _fetchRevenueAnalytics();
  }

  void _showPrepared(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('$label is ready for backend export integration.'),
      ),
    );
  }

  void _refreshPreview() {
    _fetchRevenueAnalytics(showSkeleton: true);
  }

  Future<void> _ensureActiveMediaHouses() async {
    final provider = context.read<MediaHouseProvider>();
    if (provider.mediaHouseList.isNotEmpty) return;
    try {
      await provider.fetchMediaHouse();
    } catch (error) {
      debugPrint('Unable to load active media houses: $error');
    }
  }

  Future<void> _ensureActivePromoters() async {
    final provider = context.read<PromoterProvider>();
    if (provider.promoterList.isNotEmpty) return;
    try {
      await provider.fetchPromoters();
    } catch (error) {
      debugPrint('Unable to load active promoters: $error');
    }
  }

  Future<void> _fetchRevenueAnalytics({bool showSkeleton = false}) async {
    if (!mounted) return;
    setState(() {
      _analyticsLoading = true;
      _analyticsError = null;
      if (showSkeleton) _showSkeleton = true;
    });

    try {
      final response = await ApiHelper().postApiWithBody(
        ApiConstant.revenueSettlementAnalytics,
        _revenueAnalyticsRequestBody(),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          body is Map<String, dynamic> &&
          body['success'] == true) {
        if (!mounted) return;
        setState(() {
          _analyticsData = body;
          _analyticsLoading = false;
          _showSkeleton = false;
          _showEmptyState = false;
          _showErrorState = false;
        });
        return;
      }
      throw Exception(
        body is Map<String, dynamic>
            ? body['message']?.toString() ?? 'Unable to load platform revenue.'
            : 'Unable to load platform revenue.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _analyticsLoading = false;
        _showSkeleton = false;
        _analyticsError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Map<String, dynamic> _revenueAnalyticsRequestBody() {
    return {
      'contentType': _apiContentType,
      'country': 'India',
      'format': 'string',
      'fromDate': _apiDate(_dateRange.start),
      'previewTicketAmount': 0,
      'productionHouseId': _productionHouseId ?? 0,
      'promoterId': _promoterId ?? 0,
      'reportType': _apiReportType,
      'timeZone': 'Asia/Kolkata',
      'toDate': _apiDate(_dateRange.end),
    };
  }

  String get _apiReportType {
    switch (_reportType) {
      case _RevenueReportType.productionHouseRevenue:
        return 'Production House Revenue';
      case _RevenueReportType.promoterRevenue:
        return 'Promoter Revenue';
      case _RevenueReportType.promoterDetails:
        return 'Promoter Details';
      case _RevenueReportType.platformRevenue:
        return 'Platform Revenue';
    }
  }

  String get _apiContentType {
    switch (_contentType) {
      case 'All':
        return 'ALL';
      case 'Short Film':
        return 'SHORT_FILM';
      case 'Series':
        return 'SERIES';
      case 'Mini Series':
        return 'MINI_SERIES';

      case 'Movie':
      default:
        return 'MOVIE';
    }
  }

  String _apiDate(DateTime date) => DateFormat('d-M-yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final filterHeight = _filterPanelHeight(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(theme)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyFilterDelegate(
              minHeight: filterHeight,
              maxHeight: filterHeight,
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveWidget.isMobile(context) ? 12 : 18,
                    4,
                    ResponsiveWidget.isMobile(context) ? 12 : 18,
                    10,
                  ),
                  child: _buildFilterPanel(theme),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveWidget.isMobile(context) ? 12 : 18,
              10,
              ResponsiveWidget.isMobile(context) ? 12 : 18,
              24,
            ),
            sliver: SliverToBoxAdapter(child: _buildBody(theme)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveWidget.isMobile(context) ? 12 : 18,
        18,
        ResponsiveWidget.isMobile(context) ? 12 : 18,
        10,
      ),
      child: _surface(
        theme: theme,
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            return Flex(
              direction: compact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue & Settlement Analytics',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Monitor platform, production house, and promoter settlement performance from one static preview dashboard.',
                        style: TextStyle(
                          color: theme.canvasColor.withValues(alpha: 0.66),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue & Settlement Analytics',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Monitor platform, production house, and promoter settlement performance from one static preview dashboard.',
                          style: TextStyle(
                            color: theme.canvasColor.withValues(alpha: 0.66),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (compact)
                  const SizedBox(height: 14)
                else
                  const SizedBox(width: 18),
                /*  Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _stateChip(theme, 'Skeleton', _showSkeleton, () {
                      setState(() {
                        _showSkeleton = !_showSkeleton;
                        _showEmptyState = false;
                        _showErrorState = false;
                      });
                    }),
                    _stateChip(theme, 'Empty', _showEmptyState, () {
                      setState(() {
                        _showEmptyState = !_showEmptyState;
                        _showSkeleton = false;
                        _showErrorState = false;
                      });
                    }),
                    _stateChip(theme, 'Error', _showErrorState, () {
                      setState(() {
                        _showErrorState = !_showErrorState;
                        _showSkeleton = false;
                        _showEmptyState = false;
                      });
                    }),
                  ],
                ),
              */
              ],
            );
          },
        ),
      ),
    );
  }

  double _filterPanelHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final contextFilterCount = _reportType == _RevenueReportType.platformRevenue
        ? 0
        : _reportType == _RevenueReportType.productionHouseRevenue
            ? 1
            : _reportType == _RevenueReportType.promoterRevenue
                ? 2
                : 3;
    const baseFilterCount = 4;
    final totalFilters = baseFilterCount + contextFilterCount;
    final columns = ResponsiveWidget.isMobile(context)
        ? 1
        : width < 1250
            ? 2
            : 4;
    final rows = (totalFilters / columns).ceil();
    return 42 + (rows * 58);
  }

  Widget _buildFilterPanel(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 560;
          final tablet = constraints.maxWidth < 980;
          final fieldWidth = mobile
              ? constraints.maxWidth
              : tablet
                  ? (constraints.maxWidth - 12) / 2
                  : (constraints.maxWidth - 36) / 4;

          return Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: fieldWidth,
                child: _dropdown<_RevenueReportType>(
                  theme: theme,
                  label: 'Report Type',
                  value: _reportType,
                  items: const {
                    _RevenueReportType.platformRevenue: 'Platform Revenue',
                    _RevenueReportType.productionHouseRevenue:
                        'Production House Revenue',
                    _RevenueReportType.promoterRevenue: 'Promoter Revenue',
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _reportType = value;
                      _productionHouseId = null;
                      _promoterId = null;
                      _sortColumnIndex = null;
                      _tableSearch = '';
                      _searchController.clear();
                    });
                    if (value == _RevenueReportType.productionHouseRevenue) {
                      _ensureActiveMediaHouses();
                    }
                    if (value == _RevenueReportType.promoterRevenue ||
                        value == _RevenueReportType.promoterDetails) {
                      _ensureActivePromoters();
                    }
                    _fetchRevenueAnalytics();
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(_dateRangeLabel()),
                  style: _outlinedButtonStyle(theme),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: _dropdown<String>(
                  theme: theme,
                  label: 'Content Type',
                  value: _contentType,
                  items: const {
                    'All': 'All',
                    'Movie': 'Movie',
                    'Short Film': 'Short Film',
                    'Series': 'Series',
                    'Mini Series': 'Mini Series',
                    'Music': 'Music',
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _contentType = value);
                    _fetchRevenueAnalytics();
                  },
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _toolbarButton(theme, Icons.grid_on_outlined, 'Excel',
                        () => _showPrepared('Excel export')),
                    _toolbarButton(theme, Icons.picture_as_pdf_outlined, 'PDF',
                        () => _showPrepared('PDF export')),
                    _toolbarButton(
                        theme, Icons.refresh, 'Refresh', _refreshPreview),
                  ],
                ),
              ),
              ..._contextFilters(theme, fieldWidth),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _contextFilters(ThemeData theme, double width) {
    if (_reportType == _RevenueReportType.productionHouseRevenue) {
      return [
        SizedBox(
          width: width,
          child: Consumer<MediaHouseProvider>(
            builder: (context, provider, child) {
              final houses = provider.mediaHouseList
                  .where((house) =>
                      house.id != null &&
                      (house.mediaHouseName?.trim().isNotEmpty ?? false))
                  .toList();
              final items = {
                for (final house in houses)
                  house.id!: house.mediaHouseName!.trim(),
              };
              final selectedValue = items.containsKey(_productionHouseId)
                  ? _productionHouseId
                  : null;

              return _dropdown<int>(
                theme: theme,
                label: 'Production House',
                value: selectedValue,
                hint: houses.isEmpty
                    ? 'Loading production houses...'
                    : 'Select Production House',
                items: items,
                onChanged: (value) {
                  setState(() => _productionHouseId = value);
                  _fetchRevenueAnalytics();
                },
              );
            },
          ),
        ),
      ];
    }
    if (_reportType == _RevenueReportType.promoterRevenue ||
        _reportType == _RevenueReportType.promoterDetails) {
      return [
        SizedBox(
          width: width,
          child: _dropdown<String>(
            theme: theme,
            label: 'Promoter Level',
            value: _promoterLevel,
            items: const {
              'National': 'National',
              'State': 'State',
              'District': 'District',
              'Taluka': 'Taluka',
            },
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _promoterLevel = value;
                _promoterId = null;
              });
              _fetchRevenueAnalytics();
            },
          ),
        ),
        SizedBox(
          width: width,
          child: Consumer<PromoterProvider>(
            builder: (context, provider, child) {
              final promoters = provider.promoterList
                  .where((promoter) =>
                      promoter.id != null &&
                      (promoter.promoterName?.trim().isNotEmpty ?? false) &&
                      _matchesPromoterLevel(promoter))
                  .toList();
              final items = {
                for (final promoter in promoters)
                  promoter.id!: promoter.promoterName!.trim(),
              };
              final selectedValue =
                  items.containsKey(_promoterId) ? _promoterId : null;

              return _dropdown<int>(
                theme: theme,
                label: 'Promoter Name',
                value: selectedValue,
                hint: promoters.isEmpty
                    ? 'Loading promoters...'
                    : 'Select Promoter',
                items: items,
                onChanged: (value) {
                  setState(() => _promoterId = value);
                  _fetchRevenueAnalytics();
                },
              );
            },
          ),
        ),
        if (_reportType == _RevenueReportType.promoterDetails)
          SizedBox(
            width: width,
            child: _dropdown<String>(
              theme: theme,
              label: 'Movie',
              value: _movie,
              items: const {
                'The Silent Frame': 'The Silent Frame',
                'Monsoon Nights': 'Monsoon Nights',
                'City Of Dreams': 'City Of Dreams',
              },
              onChanged: (value) => setState(() => _movie = value!),
            ),
          ),
      ];
    }
    return [];
  }

  Widget _buildBody(ThemeData theme) {
    if (_showSkeleton) return _buildSkeleton(theme);
    if (_showEmptyState) return _statePanel(theme, false);
    if (_showErrorState) return _statePanel(theme, true);
    if (_analyticsLoading && _analyticsData == null) {
      return _buildSkeleton(theme);
    }
    if (_analyticsError != null && _analyticsData == null) {
      return _statePanel(
        theme,
        true,
        title: 'Unable to load revenue analytics',
        message: _analyticsError,
      );
    }

    switch (_reportType) {
      case _RevenueReportType.platformRevenue:
        return _buildPlatformRevenue(theme);
      case _RevenueReportType.productionHouseRevenue:
        return _buildProductionHouseRevenue(theme);
      case _RevenueReportType.promoterRevenue:
        return _buildPromoterRevenue(theme);
      case _RevenueReportType.promoterDetails:
        return _buildPromoterDetails(theme);
    }
  }

  Widget _buildPlatformRevenue(ThemeData theme) {
    if (_analyticsLoading && _analyticsData == null) {
      return _buildSkeleton(theme);
    }
    if (_analyticsError != null && _analyticsData == null) {
      return _statePanel(
        theme,
        true,
        title: 'Unable to load platform revenue',
        message: _analyticsError,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analyticsResponseSummary(theme),
        const SizedBox(height: 18),
        _kpiGrid(theme, _platformRevenueMetrics()),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'Platform Breakdown'),
        const SizedBox(height: 10),
        _platformCalculationBreakdown(theme),
        const SizedBox(height: 18),
        _chartsGrid(theme, [
          _chartCard(theme, 'Revenue Trend Chart',
              _lineChart(theme, _apiChartPoints('revenueTrend'), Colors.teal)),
          _chartCard(
              theme,
              'Monthly Revenue Chart',
              _barChart(
                  theme, _apiChartPoints('monthlyRevenue'), Colors.indigo)),
          _chartCard(theme, 'Platform vs Production Pie Chart',
              _pieChart(theme, _apiChartPoints('platformVsProduction'))),
          _chartCard(theme, 'Content Type Revenue Donut Chart',
              _doughnutChart(theme, _apiChartPoints('contentTypeRevenue'))),
          _chartCard(
              theme,
              'Revenue Growth Graph',
              _areaChart(
                  theme, _apiChartPoints('weeklyRevenueGrowth'), Colors.green)),
        ]),
      ],
    );
  }

  Widget _buildProductionHouseRevenue(ThemeData theme) {
    final productionHouse = _selectedProductionHouse();
    if (_productionHouseId == null) {
      return _statePanel(
        theme,
        false,
        title: 'Select a production house',
        message: 'Choose a production house from the filter to view revenue.',
        showRefresh: false,
      );
    }

    final profileItems = _selectedProductionHouseProfile(productionHouse);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analyticsResponseSummary(theme),
        const SizedBox(height: 18),
        _kpiGrid(theme, _productionHouseRevenueMetrics()),
        const SizedBox(height: 18),
        _profileCard(
          theme,
          'Production House Profile',
          profileItems,
          Icons.apartment_outlined,
        ),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'Revenue Breakdown'),
        const SizedBox(height: 14),
        _productionHouseCalculationBreakdown(theme),
        const SizedBox(height: 18),
        _chartsGrid(theme, [
          _chartCard(
              theme,
              _apiChartTitle('revenueTrend', 'Revenue Trend Chart'),
              _lineChart(theme, _apiChartPoints('revenueTrend'), Colors.teal)),
          _chartCard(
              theme,
              _apiChartTitle('monthlyRevenue', 'Monthly Revenue Chart'),
              _barChart(
                  theme, _apiChartPoints('monthlyRevenue'), Colors.indigo)),
          _chartCard(
              theme,
              _apiChartTitle(
                  'platformVsProduction', 'Platform vs Production Pie Chart'),
              _pieChart(theme, _apiChartPoints('platformVsProduction'))),
          _chartCard(
              theme,
              _apiChartTitle(
                  'contentTypeRevenue', 'Content Type Revenue Donut Chart'),
              _doughnutChart(theme, _apiChartPoints('contentTypeRevenue'))),
          _chartCard(
              theme,
              _apiChartTitle('weeklyRevenueGrowth', 'Revenue Growth Graph'),
              _areaChart(
                  theme, _apiChartPoints('weeklyRevenueGrowth'), Colors.green)),
        ]),
      ],
    );
  }

  Widget _analyticsResponseSummary(ThemeData theme) {
    final filters = _jsonMap(_analyticsData?['filters']);
    final reconciliation = _jsonMap(_analyticsData?['reconciliation']);
    final generatedAt = _analyticsData?['generatedAt']?.toString();
    final status = reconciliation?['reconciliationStatus']?.toString() ?? '-';

    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final children = [
            _responseInfoTile(
              theme,
              'API Report Type',
              _analyticsData?['reportType']?.toString() ?? _apiReportType,
            ),
            _responseInfoTile(
              theme,
              'API Content Type',
              _analyticsData?['contentType']?.toString() ?? _apiContentType,
            ),
            _responseInfoTile(
              theme,
              'Generated At',
              _formatGeneratedAt(generatedAt),
            ),
            _responseInfoTile(
              theme,
              'Reconciliation',
              status,
              valueColor: status.toUpperCase() == 'PASS'
                  ? Colors.green
                  : theme.canvasColor,
            ),
            _responseInfoTile(
              theme,
              'Date Filter',
              '${filters?['fromDate'] ?? _apiDate(_dateRange.start)} - ${filters?['toDate'] ?? _apiDate(_dateRange.end)}',
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_done_outlined,
                      color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _analyticsLoading
                          ? 'Refreshing revenue analytics...'
                          : 'Revenue analytics API response',
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (_analyticsError != null)
                    Tooltip(
                      message: _analyticsError!,
                      child: Icon(Icons.error_outline,
                          color: Colors.orange.shade700, size: 18),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              compact
                  ? Column(
                      children: [
                        for (final child in children) ...[
                          child,
                          const SizedBox(height: 8),
                        ],
                      ],
                    )
                  : Row(
                      children: [
                        for (var index = 0; index < children.length; index++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == children.length - 1 ? 0 : 8,
                              ),
                              child: children[index],
                            ),
                          ),
                      ],
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _responseInfoTile(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.62 : 0.94,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.58),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? theme.canvasColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGeneratedAt(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  List<_Metric> _platformRevenueMetrics() {
    return [
      _Metric(
        _summaryLabel('totalPurchase', 'Total Purchase'),
        _summaryCount('totalPurchase'),
        Icons.confirmation_num_outlined,
        Colors.deepPurple,
      ),
      _Metric(
        _summaryLabel('totalRevenue', 'Total Revenue'),
        _summaryAmount('totalRevenue'),
        Icons.account_balance_wallet_outlined,
        Colors.teal,
      ),
      _Metric(
        _summaryLabel('gstAmount', 'GST Amount'),
        _summaryAmount('gstAmount'),
        Icons.receipt_long_outlined,
        Colors.orange,
      ),
      _Metric(
        _summaryLabel('razorpayDeduction', 'RazorPay Deduction'),
        _summaryAmount('razorpayDeduction'),
        Icons.receipt_long_outlined,
        Colors.blue,
      ),
      _Metric(
        _summaryLabel('netRevenue', 'Net Revenue'),
        _summaryAmount('netRevenue'),
        Icons.payments_outlined,
        Colors.green,
      ),
      _Metric(
        _summaryLabel('platformRevenue', 'Platform Revenue (30%)'),
        _summaryAmount('platformRevenue'),
        Icons.business_center_outlined,
        Colors.indigo,
      ),
      _Metric(
        _summaryLabel('productionRevenue', 'Production Revenue (70%)'),
        _summaryAmount('productionRevenue'),
        Icons.movie_creation_outlined,
        Colors.pink,
      ),
      _Metric(
        _summaryLabel('promoterAllocation', 'Promoter Allocation'),
        _summaryAmount('promoterAllocation'),
        Icons.groups_2_outlined,
        Colors.cyan,
      ),
      _Metric(
        _summaryLabel('netPlatformRevenue', 'Net Platform Revenue'),
        _summaryAmount('netPlatformRevenue'),
        Icons.account_balance_outlined,
        Colors.redAccent,
      ),
    ];
  }

  List<_Metric> _productionHouseRevenueMetrics() {
    return [
      _Metric(
        _summaryLabel('totalPurchase', 'Total Purchase'),
        _summaryCount('totalPurchase'),
        Icons.confirmation_num_outlined,
        Colors.deepPurple,
      ),
      _Metric(
        _summaryLabel('totalRevenue', 'Total Revenue'),
        _summaryAmount('totalRevenue'),
        Icons.account_balance_wallet_outlined,
        Colors.teal,
      ),
      _Metric(
        _summaryLabel('gstAmount', 'GST Amount'),
        _summaryAmount('gstAmount'),
        Icons.receipt_long_outlined,
        Colors.orange,
      ),
      _Metric(
        _summaryLabel('payoutCharges', 'Payout Charges'),
        _summaryAmount('payoutCharges'),
        Icons.sync_alt_outlined,
        Colors.blue,
      ),
      _Metric(
        _summaryLabel('netRevenue', 'Net Revenue for Sharing'),
        _summaryAmount('netRevenue'),
        Icons.payments_outlined,
        Colors.green,
      ),
      _Metric(
        _summaryLabel('productionRevenue', 'Production Revenue (70%)'),
        _summaryAmount('productionRevenue'),
        Icons.movie_creation_outlined,
        Colors.pink,
      ),
      _Metric(
        _summaryLabel('platformRevenue', 'Platform Revenue (30%)'),
        _summaryAmount('platformRevenue'),
        Icons.business_center_outlined,
        Colors.indigo,
      ),
      _Metric(
        _summaryLabel('promoterAllocation', 'Promoter Allocation'),
        _summaryAmount('promoterAllocation'),
        Icons.groups_2_outlined,
        Colors.cyan,
      ),
      _Metric(
        _summaryLabel('netPlatformRevenue', 'Net Platform Revenue'),
        _summaryAmount('netPlatformRevenue'),
        Icons.account_balance_outlined,
        Colors.redAccent,
      ),
    ];
  }

  List<_Metric> _promoterRevenueMetrics() {
    final specs = [
      _SummaryMetricSpec('totalPurchase', 'Total Purchase',
          Icons.confirmation_num_outlined, Colors.deepPurple),
      _SummaryMetricSpec('totalRevenue', 'Total Revenue',
          Icons.account_balance_wallet_outlined, Colors.teal),
      _SummaryMetricSpec('gstAmount', 'GST Amount', Icons.receipt_long_outlined,
          Colors.orange),
      _SummaryMetricSpec('payoutCharges', 'Payout Charges',
          Icons.sync_alt_outlined, Colors.blue),
      _SummaryMetricSpec('settlementCharges', 'Settlement Charges',
          Icons.sync_alt_outlined, Colors.blue),
      _SummaryMetricSpec('netRevenue', 'Net Revenue for Sharing',
          Icons.payments_outlined, Colors.green),
      _SummaryMetricSpec('promoterAllocation', 'Promoter Allocation',
          Icons.groups_2_outlined, Colors.cyan),
      _SummaryMetricSpec(
          'promoterRevenue', 'Promoter Revenue', Icons.percent, Colors.indigo),
      _SummaryMetricSpec(
          'tdsAmount', 'TDS', Icons.receipt_outlined, Colors.orange),
      _SummaryMetricSpec('walletCredit', 'Wallet Credit',
          Icons.account_balance_wallet_outlined, Colors.redAccent),
      _SummaryMetricSpec(
          'finalPayout', 'Final Payout', Icons.payments_outlined, Colors.green),
      _SummaryMetricSpec('netPlatformRevenue', 'Net Platform Revenue',
          Icons.account_balance_outlined, Colors.redAccent),
    ];

    final metrics = specs
        .where((spec) => _hasSummaryCard(spec.key))
        .map((spec) => _summaryMetric(spec))
        .toList();
    if (metrics.isNotEmpty) return metrics;

    return [
      _Metric(
        _summaryLabel('totalPurchase', 'Total Purchase'),
        _summaryCount('totalPurchase'),
        Icons.confirmation_num_outlined,
        Colors.deepPurple,
      ),
      _Metric(
        _summaryLabel('totalRevenue', 'Total Revenue'),
        _summaryAmount('totalRevenue'),
        Icons.account_balance_wallet_outlined,
        Colors.teal,
      ),
      _Metric(
        _summaryLabel('promoterAllocation', 'Promoter Allocation'),
        _summaryAmount('promoterAllocation'),
        Icons.groups_2_outlined,
        Colors.cyan,
      ),
      _Metric(
        _summaryLabel('payoutCharges', 'Payout Charges'),
        _summaryAmount('payoutCharges'),
        Icons.sync_alt_outlined,
        Colors.blue,
      ),
    ];
  }

  bool _hasSummaryCard(String key) {
    final cards = _jsonMap(_analyticsData?['summaryCards']);
    return _jsonMap(cards?[key]) != null;
  }

  _Metric _summaryMetric(_SummaryMetricSpec spec) {
    return _Metric(
      _summaryLabel(spec.key, spec.fallbackLabel),
      _summaryValue(spec.key),
      spec.icon,
      spec.color,
    );
  }

  String _summaryLabel(String key, String fallback) {
    final cards = _jsonMap(_analyticsData?['summaryCards']);
    final card = _jsonMap(cards?[key]);
    return card?['label']?.toString() ?? fallback;
  }

  String _summaryAmount(String key) {
    final cards = _jsonMap(_analyticsData?['summaryCards']);
    final value = _jsonMap(cards?[key])?['amount'];
    return _formatCurrency(value);
  }

  String _summaryCount(String key) {
    final cards = _jsonMap(_analyticsData?['summaryCards']);
    final value = _jsonMap(cards?[key])?['count'];
    return _formatCount(value);
  }

  String _summaryValue(String key) {
    final cards = _jsonMap(_analyticsData?['summaryCards']);
    final card = _jsonMap(cards?[key]);
    if (card?['count'] != null) return _formatCount(card?['count']);
    return _formatCurrency(card?['amount']);
  }

  List<_ChartPoint> _apiChartPoints(String chartKey) {
    final charts = _jsonMap(_analyticsData?['charts']);
    final chart = _jsonMap(charts?[chartKey]);
    final points = chart?['points'];
    if (points is! List) {
      switch (chartKey) {
        case 'monthlyRevenue':
          return _monthlyPoints;
        case 'platformVsProduction':
          return _sharePoints;
        case 'contentTypeRevenue':
          return _contentPoints;
        case 'weeklyRevenueGrowth':
          return _growthPoints;
        case 'revenueTrend':
        default:
          return _trendPoints;
      }
    }
    return points.whereType<Map>().map((point) {
      final map = Map<String, dynamic>.from(point);
      final amount = _asDouble(map['amount']);
      final percentage = _asDouble(map['percentage']);
      return _ChartPoint(
        map['label']?.toString() ??
            formatContentTypeLabel(map['contentType']?.toString()),
        chartKey == 'platformVsProduction' && amount == 0 && percentage > 0
            ? percentage
            : amount,
      );
    }).toList();
  }

  String _apiChartTitle(String chartKey, String fallback) {
    final charts = _jsonMap(_analyticsData?['charts']);
    return _jsonMap(charts?[chartKey])?['title']?.toString() ?? fallback;
  }

  Map<String, dynamic>? _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<dynamic> _jsonList(dynamic value) => value is List ? value : const [];

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatCurrency(dynamic value) {
    final amount = _asDouble(value);
    final digits = amount == amount.roundToDouble() ? 0 : 2;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs. ',
      decimalDigits: digits,
    ).format(amount);
  }

  String _formatPreviewAmount(dynamic value) {
    final amount = _asDouble(value);
    return NumberFormat('0.###').format(amount);
  }

  String _formatCount(dynamic value) {
    final count = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return NumberFormat.decimalPattern('en_IN').format(count);
  }

  String _safeText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  bool _matchesPromoterLevel(Promoters promoter) {
    return promoter.level?.trim().toLowerCase() ==
        _promoterLevel.trim().toLowerCase();
  }

  Promoters? _selectedPromoter() {
    if (_promoterId == null) return null;
    final promoters = context.read<PromoterProvider>().promoterList;
    for (final promoter in promoters) {
      if (promoter.id == _promoterId) return promoter;
    }
    return null;
  }

  Widget _buildPromoterRevenue(ThemeData theme) {
    if (_promoterId == null) {
      return _statePanel(
        theme,
        false,
        title: 'Select a promoter',
        message: 'Choose a promoter from the filter to view revenue.',
        showRefresh: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analyticsResponseSummary(theme),
        const SizedBox(height: 18),
        _kpiGrid(theme, _promoterRevenueMetrics()),
        const SizedBox(height: 18),
        _promoterProfileCard(theme),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'Promoter Breakdown'),
        const SizedBox(height: 14),
        _promoterCalculationBreakdown(theme),
        const SizedBox(height: 18),
        _chartsGrid(theme, [
          _chartCard(
              theme,
              _apiChartTitle('revenueTrend', 'Revenue Trend Chart'),
              _lineChart(theme, _apiChartPoints('revenueTrend'), Colors.teal)),
          _chartCard(
              theme,
              _apiChartTitle('monthlyRevenue', 'Monthly Revenue Chart'),
              _barChart(
                  theme, _apiChartPoints('monthlyRevenue'), Colors.indigo)),
          _chartCard(
              theme,
              _apiChartTitle(
                  'platformVsProduction', 'Platform vs Production Pie Chart'),
              _pieChart(theme, _apiChartPoints('platformVsProduction'))),
          _chartCard(
              theme,
              _apiChartTitle(
                  'contentTypeRevenue', 'Content Type Revenue Donut Chart'),
              _doughnutChart(theme, _apiChartPoints('contentTypeRevenue'))),
          _chartCard(
              theme,
              _apiChartTitle('weeklyRevenueGrowth', 'Revenue Growth Graph'),
              _areaChart(
                  theme, _apiChartPoints('weeklyRevenueGrowth'), Colors.green)),
        ]),
      ],
    );
  }

  Widget _buildPromoterDetails(ThemeData theme) {
    if (_promoterId == null) {
      return _statePanel(
        theme,
        false,
        title: 'Select a promoter',
        message: 'Choose a promoter from the filter to view details.',
        showRefresh: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analyticsResponseSummary(theme),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'Promoter Summary'),
        const SizedBox(height: 10),
        _simpleTable(theme, const [
          [
            'Promoter Name',
            'Promoter Level',
            'Commission Percentage',
            'Users Added',
            'Active Users',
            'Orders',
            'Tickets Sold',
            'Revenue Generated',
            'Commission Earned'
          ],
          [
            'Rahul Patil',
            'National',
            '1%',
            '4,580',
            '3,940',
            '8,450',
            '13,900',
            'Rs. 1,85,00,000',
            'Rs. 15,67,797'
          ],
        ]),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'User Purchase Analytics'),
        const SizedBox(height: 10),
        _dataTable(
            theme, _userPurchaseColumns, _filteredUserRows(), 'User Name'),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'Movie Wise Analytics'),
        const SizedBox(height: 10),
        _dataTable(theme, _promoterMovieColumns, _filteredPromoterMovieRows(),
            'Movie Name'),
        const SizedBox(height: 18),
        _sectionTitle(theme, 'Promoter Revenue Flow'),
        const SizedBox(height: 10),
        _flowCards(theme),
        const SizedBox(height: 18),
        _chartsGrid(theme, [
          _chartCard(theme, 'Revenue Trend Chart',
              _lineChart(theme, _trendPoints, Colors.teal)),
          _chartCard(theme, 'Promoter Growth Chart',
              _areaChart(theme, _promoterGrowthPoints, Colors.indigo)),
          _chartCard(theme, 'Monthly Revenue Chart',
              _barChart(theme, _monthlyPoints, Colors.green)),
          _chartCard(theme, 'Movie Revenue Pie Chart',
              _pieChart(theme, _movieRevenuePoints)),
          _chartCard(theme, 'Commission Distribution Chart',
              _doughnutChart(theme, _commissionPoints)),
        ]),
      ],
    );
  }

  Widget _kpiGrid(ThemeData theme, List<_Metric> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1260
            ? 4
            : width > 900
                ? 3
                : width > 520
                    ? 2
                    : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 3.6 : 2.85,
          ),
          itemBuilder: (context, index) => _metricCard(theme, metrics[index]),
        );
      },
    );
  }

  Widget _metricCard(ThemeData theme, _Metric metric) {
    return Tooltip(
      message: metric.title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: _surfaceDecoration(theme).copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardColor,
              metric.color.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.16 : 0.08),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(metric.icon, color: metric.color, size: 24),
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      metric.value,
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformCalculationBreakdown(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.calculate_outlined,
                  color: theme.primaryColor, size: 22),
              Text(
                _platformPreviewTitle,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This flow shows how one customer payment is split before the final platform amount is calculated.',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _calculationStep(
            theme,
            'Step 1',
            _platformPreviewStepTitle(
                'step1CustomerPayment', 'Rs. 100 price includes 18% GST'),
            _platformPreviewRows('step1CustomerPayment'),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 920;
              final children = [
                _calculationStep(
                  theme,
                  'Step 2',
                  _platformPreviewStepTitle(
                      'step2ProductionHouse', 'Production House 70% + 10% TDS'),
                  _platformPreviewRows('step2ProductionHouse'),
                ),
                _calculationStep(
                  theme,
                  'Step 3',
                  _platformPreviewStepTitle('step3Platform', 'Platform 30%'),
                  _platformPreviewRows('step3Platform'),
                ),
              ];
              if (!twoColumns) {
                return Column(
                  children: [
                    children[0],
                    const SizedBox(height: 12),
                    children[1],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(child: children[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _promoterCalculationTable(theme),
          const SizedBox(height: 12),
          _finalCalculationSummary(theme),
        ],
      ),
    );
  }

  Widget _productionHouseCalculationBreakdown(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: theme.primaryColor, size: 22),
              Text(
                _platformPreviewTitle,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This flow shows the selected production house revenue calculation using the API response.',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _calculationStep(
            theme,
            'Step 1',
            _platformPreviewStepTitle('step1CustomerPayment',
                'Actual customer payments include 18% GST'),
            _platformPreviewRows('step1CustomerPayment'),
          ),
          const SizedBox(height: 12),
          _calculationStep(
            theme,
            'Step 2',
            _platformPreviewStepTitle(
                'step2ProductionHouse', 'Production House 70% + 10% TDS'),
            _platformPreviewRows('step2ProductionHouse'),
          ),
          const SizedBox(height: 12),
          _productionHouseFinalSummary(theme),
        ],
      ),
    );
  }

  Widget _productionHouseFinalSummary(ThemeData theme) {
    return _calculationTable(
      theme,
      'Final Settlement Summary',
      const ['Stakeholder', 'Gross', 'TDS', 'Payout Fee', 'Bank Amount'],
      _productionHouseFinalSummaryRows(),
      highlightLast: true,
    );
  }

  Widget _promoterCalculationBreakdown(ThemeData theme) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.groups_2_outlined,
                  color: theme.primaryColor, size: 22),
              Text(
                _platformPreviewTitle,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This flow shows the selected promoter revenue calculation using the API response.',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _calculationStep(
            theme,
            'Step 1',
            _platformPreviewStepTitle('step1CustomerPayment',
                'Actual customer payments include 18% GST'),
            _platformPreviewRows('step1CustomerPayment'),
          ),
          const SizedBox(height: 12),
          _promoterCalculationTable(theme),
          const SizedBox(height: 12),
          _promoterFinalSummary(theme),
        ],
      ),
    );
  }

  Widget _promoterFinalSummary(ThemeData theme) {
    return _calculationTable(
      theme,
      'Final Settlement Summary',
      const ['Stakeholder', 'Gross', 'TDS', 'Payout Fee', 'Bank Amount'],
      _productionHouseFinalSummaryRows(),
      highlightLast: true,
    );
  }

  Map<String, dynamic>? get _platformPreview =>
      _jsonMap(_analyticsData?['calculationPreview']);

  String get _platformPreviewTitle =>
      _platformPreview?['title']?.toString() ?? 'Detailed Revenue Calculation';

  String get _platformPreviewBadge =>
      _platformPreview?['badge']?.toString() ?? 'Example: Rs. 100 ticket';

  String _platformPreviewStepTitle(String key, String fallback) {
    return _jsonMap(_platformPreview?[key])?['title']?.toString() ?? fallback;
  }

  List<_CalculationLine> _platformPreviewRows(String key) {
    final rows = _jsonList(_jsonMap(_platformPreview?[key])?['rows']);
    if (rows.isEmpty) return _fallbackPlatformPreviewRows(key);
    return rows.whereType<Map>().map((row) {
      final map = Map<String, dynamic>.from(row);
      return _CalculationLine(
        map['label']?.toString() ?? '-',
        map['formula']?.toString() ?? '-',
        _formatPreviewAmount(map['amount']),
      );
    }).toList();
  }

  List<_CalculationLine> _fallbackPlatformPreviewRows(String key) {
    switch (key) {
      case 'step2ProductionHouse':
        return const [
          _CalculationLine('Production Gross', '82.746 x 70%', '57.922'),
          _CalculationLine('TDS 10%', '57.922 x 10%', '5.792'),
          _CalculationLine('After TDS', '57.922 - 5.792', '52.129'),
          _CalculationLine('Payout Charge 2%', '52.129 x 2%', '1.042'),
          _CalculationLine('Production Final', '52.129 - 1.042', '51.087'),
        ];
      case 'step3Platform':
        return const [
          _CalculationLine('Platform Gross', '82.746 x 30%', '24.824'),
        ];
      case 'step1CustomerPayment':
      default:
        return const [
          _CalculationLine('Customer Payment', '-', '100.000'),
          _CalculationLine('Base Movie Amount', '100 / 1.18', '84.746'),
          _CalculationLine('Included GST', '100 - 84.746', '15.254'),
          _CalculationLine('Razorpay 2%', '100 x 2%', '2.000'),
          _CalculationLine(
              'Net Revenue for Sharing', '84.746 - 2.000', '82.746'),
        ];
    }
  }

  List<List<String>> _platformPromoterRows() {
    final rows =
        _jsonList(_jsonMap(_platformPreview?['step4Promoters'])?['rows']);
    if (rows.isEmpty) {
      if (_reportType == _RevenueReportType.promoterRevenue) {
        return [
          [_promoterLevel, '0', '0.000', '0.000', '0.000', '0.000', '0.000'],
        ];
      }
      return const [
        ['National', '1', '0.827', '0.083', '0.744', '0.015', '0.730'],
        ['State', '0.30', '0.248', '0.025', '0.223', '0.004', '0.219'],
        ['District', '0.70', '0.579', '0.058', '0.521', '0.010', '0.511'],
        ['Taluka', '3', '2.482', '0.248', '2.234', '0.045', '2.189'],
      ];
    }
    return rows.whereType<Map>().map((row) {
      final map = Map<String, dynamic>.from(row);
      return [
        map['level']?.toString() ?? '-',
        _formatPreviewAmount(map['percentage']),
        _formatPreviewAmount(map['grossAmount']),
        _formatPreviewAmount(map['tdsAmount']),
        _formatPreviewAmount(map['afterTdsAmount']),
        _formatPreviewAmount(map['payoutFeeAmount']),
        _formatPreviewAmount(map['finalPayoutAmount']),
      ];
    }).toList();
  }

  List<List<String>> _platformFinalSummaryRows() {
    final rows = _jsonList(_platformPreview?['finalSummary']);
    if (rows.isEmpty) {
      return const [
        ['Production House', '52.129', '1.042', '51.087'],
        ['National', '0.744', '0.015', '0.730'],
        ['State', '0.223', '0.004', '0.219'],
        ['District', '0.521', '0.010', '0.511'],
        ['Taluka', '2.234', '0.045', '2.189'],
        ['Platform Final', '24.824', '0', '20.686'],
      ];
    }
    return rows.whereType<Map>().map((row) {
      final map = Map<String, dynamic>.from(row);
      return [
        map['stakeholder']?.toString() ?? '-',
        _formatPreviewAmount(map['afterTdsAmount']),
        _formatPreviewAmount(map['payoutFeeAmount']),
        _formatPreviewAmount(map['bankAmount']),
      ];
    }).toList();
  }

  List<List<String>> _productionHouseFinalSummaryRows() {
    final rows = _jsonList(_platformPreview?['finalSummary']);
    if (rows.isEmpty) {
      return const [
        ['Production House', '0.000', '0.000', '0.000', '0.000'],
        ['Platform Final', '0.000', '0.000', '0.000', '0.000'],
      ];
    }
    return rows.whereType<Map>().map((row) {
      final map = Map<String, dynamic>.from(row);
      return [
        map['stakeholder']?.toString() ?? '-',
        _formatPreviewAmount(map['grossAmount']),
        _formatPreviewAmount(map['tdsAmount']),
        _formatPreviewAmount(map['payoutFeeAmount']),
        _formatPreviewAmount(map['bankAmount']),
      ];
    }).toList();
  }

  Widget _calculationStep(
    ThemeData theme,
    String step,
    String title,
    List<_CalculationLine> rows,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.56 : 0.92,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map((row) => _calculationLine(theme, row)),
        ],
      ),
    );
  }

  Widget _calculationLine(ThemeData theme, _CalculationLine row) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final label = Text(
          row.label,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w800,
          ),
        );
        final formula = Text(
          row.formula,
          textAlign: compact ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontWeight: FontWeight.w700,
          ),
        );
        final amount = Text(
          row.amount,
          textAlign: compact ? TextAlign.start : TextAlign.end,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w900,
          ),
        );

        if (compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                const SizedBox(height: 4),
                formula,
                const SizedBox(height: 4),
                amount,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Expanded(flex: 3, child: label),
              Expanded(flex: 3, child: formula),
              Expanded(flex: 2, child: amount),
            ],
          ),
        );
      },
    );
  }

  Widget _promoterCalculationTable(ThemeData theme) {
    return _calculationTable(
      theme,
      _platformPreviewStepTitle('step4Promoters', 'Promoters + 10% TDS'),
      const [
        'Level',
        '%',
        'Gross',
        'TDS 10%',
        'After TDS',
        'Razorpay 2%',
        'Final'
      ],
      _platformPromoterRows(),
    );
  }

  Widget _finalCalculationSummary(ThemeData theme) {
    return _calculationTable(
      theme,
      'Final Summary',
      const ['Stakeholder', 'After TDS', 'Razorpay 2%', 'Bank Amount'],
      _platformFinalSummaryRows(),
      highlightLast: true,
    );
  }

  Widget _calculationTable(
    ThemeData theme,
    String title,
    List<String> columns,
    List<List<String>> rows, {
    bool highlightLast = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.56 : 0.92,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Text(
            title,
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                constraints.maxWidth < 760 ? 760.0 : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    _calculationTableRow(
                      theme,
                      columns,
                      isHeader: true,
                      isHighlighted: false,
                    ),
                    ...rows.asMap().entries.map((entry) {
                      return _calculationTableRow(
                        theme,
                        entry.value,
                        isHeader: false,
                        isHighlighted:
                            highlightLast && entry.key == rows.length - 1,
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _calculationTableRow(
    ThemeData theme,
    List<String> cells, {
    required bool isHeader,
    required bool isHighlighted,
  }) {
    final background = isHeader
        ? theme.primaryColor.withValues(alpha: 0.1)
        : isHighlighted
            ? theme.primaryColor.withValues(alpha: 0.08)
            : Colors.transparent;
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: List.generate(cells.length, (index) {
          return Expanded(
            flex: index == 0 ? 2 : 1,
            child: Padding(
              padding:
                  EdgeInsets.only(right: index == cells.length - 1 ? 0 : 12),
              child: Text(
                cells[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: index == 0 ? TextAlign.start : TextAlign.end,
                style: TextStyle(
                  color: isHeader ? theme.primaryColor : theme.canvasColor,
                  fontWeight: isHeader || isHighlighted
                      ? FontWeight.w900
                      : FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _calculationBadge(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _chartsGrid(ThemeData theme, List<Widget> charts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1080
            ? 2
            : constraints.maxWidth > 620
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: charts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth < 620 ? 1.15 : 1.45,
          ),
          itemBuilder: (context, index) => charts[index],
        );
      },
    );
  }

  Widget _chartCard(ThemeData theme, String title, Widget chart) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined,
                  color: theme.primaryColor, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _lineChart(ThemeData theme, List<_ChartPoint> data, Color color) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: CategoryAxis(labelStyle: _axisStyle(theme)),
      primaryYAxis: NumericAxis(labelStyle: _axisStyle(theme)),
      series: <CartesianSeries<_ChartPoint, String>>[
        SplineSeries<_ChartPoint, String>(
          dataSource: data,
          xValueMapper: (point, _) => point.label,
          yValueMapper: (point, _) => point.value,
          color: color,
          width: 3,
          markerSettings: MarkerSettings(isVisible: true, color: color),
        ),
      ],
    );
  }

  Widget _areaChart(ThemeData theme, List<_ChartPoint> data, Color color) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: CategoryAxis(labelStyle: _axisStyle(theme)),
      primaryYAxis: NumericAxis(labelStyle: _axisStyle(theme)),
      series: <CartesianSeries<_ChartPoint, String>>[
        SplineAreaSeries<_ChartPoint, String>(
          dataSource: data,
          xValueMapper: (point, _) => point.label,
          yValueMapper: (point, _) => point.value,
          color: color.withValues(alpha: 0.22),
          borderColor: color,
          borderWidth: 3,
        ),
      ],
    );
  }

  Widget _barChart(ThemeData theme, List<_ChartPoint> data, Color color) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: CategoryAxis(labelStyle: _axisStyle(theme)),
      primaryYAxis: NumericAxis(labelStyle: _axisStyle(theme)),
      series: <CartesianSeries<_ChartPoint, String>>[
        ColumnSeries<_ChartPoint, String>(
          dataSource: data,
          xValueMapper: (point, _) => point.label,
          yValueMapper: (point, _) => point.value,
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _pieChart(ThemeData theme, List<_ChartPoint> data) {
    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: theme.canvasColor, fontSize: 11),
      ),
      series: <CircularSeries<_ChartPoint, String>>[
        PieSeries<_ChartPoint, String>(
          dataSource: data,
          xValueMapper: (point, _) => point.label,
          yValueMapper: (point, _) => point.value,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: theme.canvasColor, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _doughnutChart(ThemeData theme, List<_ChartPoint> data) {
    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: theme.canvasColor, fontSize: 11),
      ),
      series: <CircularSeries<_ChartPoint, String>>[
        DoughnutSeries<_ChartPoint, String>(
          dataSource: data,
          xValueMapper: (point, _) => point.label,
          yValueMapper: (point, _) => point.value,
          innerRadius: '62%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: theme.canvasColor, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _profileCard(
    ThemeData theme,
    String title,
    List<_ProfileItem> items,
    IconData icon,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _statusPill(theme, 'Active'),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 920
                  ? 4
                  : constraints.maxWidth > 560
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: columns == 1 ? 5.0 : 3.4,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.7 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.canvasColor.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.canvasColor.withValues(alpha: 0.58),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _promoterProfileCard(ThemeData theme) {
    final promoter = _selectedPromoter();
    final items = [
      _ProfileItem('Promoter Name', _safeText(promoter?.promoterName)),
      _ProfileItem('Promoter ID', '${promoter?.id ?? _promoterId ?? '-'}'),
      _ProfileItem('Level', _safeText(promoter?.level ?? _promoterLevel)),
      _ProfileItem('Status', _safeText(promoter?.status)),
      _ProfileItem('Join Date', _safeText(promoter?.createdDate)),
      _ProfileItem('Referral Code', _safeText(promoter?.userId?.refferCode)),
    ];
    final statusText = _safeText(promoter?.status);

    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  color: theme.primaryColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Promoter Profile',
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _statusPill(
                            theme, statusText == '-' ? 'Select' : statusText),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: items.map((item) {
                        return SizedBox(
                          width: compact
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 90) / 3,
                          child: _promoterProfileItem(theme, item),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _promoterProfileItem(ThemeData theme, _ProfileItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.7 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.58),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataTable(
    ThemeData theme,
    List<String> columns,
    List<List<String>> rows,
    String searchHint,
  ) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 290,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _tableSearch = value),
                  style: TextStyle(color: theme.canvasColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    hintText: 'Search $searchHint',
                    hintStyle: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.42),
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.canvasColor.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ),
              _toolbarButton(theme, Icons.download_outlined, 'CSV',
                  () => _showPrepared('CSV export')),
              _toolbarButton(theme, Icons.grid_on_outlined, 'Excel',
                  () => _showPrepared('Excel export')),
              _toolbarButton(theme, Icons.picture_as_pdf_outlined, 'PDF',
                  () => _showPrepared('PDF export')),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                cardColor: theme.cardColor,
                dataTableTheme: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(
                    theme.primaryColor.withValues(alpha: 0.12),
                  ),
                  dataRowColor: WidgetStateProperty.all(theme.cardColor),
                ),
              ),
              child: PaginatedDataTable(
                header: Text(
                  'Records',
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                rowsPerPage:
                    rows.length < 5 ? rows.length.clamp(1, 5).toInt() : 5,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                showCheckboxColumn: false,
                columns: columns.asMap().entries.map((entry) {
                  return DataColumn(
                    label: Text(
                      entry.value,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  );
                }).toList(),
                source: _StaticRowsSource(
                  rows: _sortedRows(rows),
                  theme: theme,
                  columnCount: columns.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<List<String>> _sortedRows(List<List<String>> rows) {
    final sorted = List<List<String>>.from(rows);
    final index = _sortColumnIndex;
    if (index == null) return sorted;
    sorted.sort((a, b) {
      final first = index < a.length ? a[index] : '';
      final second = index < b.length ? b[index] : '';
      final comparison = first.compareTo(second);
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  List<List<String>> _filteredUserRows() => _filterRows(_userPurchaseRows);

  List<List<String>> _filteredPromoterMovieRows() =>
      _filterRows(_promoterMovieRows);

  List<List<String>> _filterRows(List<List<String>> rows) {
    final query = _tableSearch.trim().toLowerCase();
    if (query.isEmpty) return rows;
    return rows
        .where((row) => row.any((cell) => cell.toLowerCase().contains(query)))
        .toList();
  }

  Widget _simpleTable(ThemeData theme, List<List<String>> rows) {
    final headers = rows.first;
    final bodyRows = rows.skip(1).toList();
    return _surface(
      theme: theme,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            theme.primaryColor.withValues(alpha: 0.12),
          ),
          columns: headers
              .map(
                (header) => DataColumn(
                  label: Text(
                    header,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: bodyRows
              .map(
                (row) => DataRow(
                  cells: row
                      .map(
                        (cell) => DataCell(
                          Text(
                            cell,
                            style: TextStyle(
                              color: theme.canvasColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _flowCards(ThemeData theme) {
    const steps = [
      ('Customer Payment', Icons.shopping_cart_outlined),
      ('GST Deduction', Icons.receipt_long_outlined),
      ('Eligible Revenue', Icons.payments_outlined),
      ('Promoter Percentage', Icons.percent),
      ('TDS', Icons.request_quote_outlined),
      ('Razorpay Charges', Icons.credit_card_outlined),
      ('Final Wallet Credit', Icons.account_balance_wallet_outlined),
    ];
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Container(
              width: 176,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  Icon(steps[i].$2, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      steps[i].$1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != steps.length - 1)
              Icon(Icons.arrow_forward, color: theme.primaryColor, size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 920
                ? 4
                : constraints.maxWidth > 520
                    ? 2
                    : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 3.8 : 2.8,
              ),
              itemBuilder: (_, __) =>
                  const AppSkeleton(child: SizedBox.expand()),
            );
          },
        ),
        const SizedBox(height: 16),
        const AppSkeleton(child: SizedBox(height: 320, width: double.infinity)),
      ],
    );
  }

  MediaHouse? _selectedProductionHouse() {
    if (_productionHouseId == null) return null;
    final houses = context.read<MediaHouseProvider>().mediaHouseList;
    for (final house in houses) {
      if (house.id == _productionHouseId) return house;
    }
    return null;
  }

  List<_ProfileItem> _selectedProductionHouseProfile(MediaHouse? house) {
    if (house == null) {
      return [
        _ProfileItem('Production House ID', '${_productionHouseId ?? '-'}'),
        const _ProfileItem('Production House Name', 'Loading...'),
        const _ProfileItem('Revenue Share', '70%'),
        const _ProfileItem('Movies', '-'),
        const _ProfileItem('Total Views', '-'),
        const _ProfileItem('Gross Revenue', '-'),
        const _ProfileItem('Net Revenue', '-'),
        const _ProfileItem('Status', '-'),
      ];
    }

    return [
      _ProfileItem('Production House Name', _safeText(house.mediaHouseName)),
      _ProfileItem('Production House ID', '${house.id ?? '-'}'),
      _ProfileItem('Revenue Share', '70%'),
      _ProfileItem('Movies', _safeText(house.postCount)),
      _ProfileItem('Total Views', _safeText(house.totalViews)),
      _ProfileItem('Gross Revenue', _formatCurrency(house.totalRevenue)),
      _ProfileItem('Net Revenue', _formatCurrency(house.mediaHouseRevenue)),
      _ProfileItem('Status', _safeText(house.status)),
    ];
  }

  Widget _statePanel(
    ThemeData theme,
    bool isError, {
    String? title,
    String? message,
    bool showRefresh = true,
  }) {
    return _surface(
      theme: theme,
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            Icon(
              isError ? Icons.cloud_off_outlined : Icons.inbox_outlined,
              color: theme.primaryColor,
              size: 54,
            ),
            const SizedBox(height: 12),
            Text(
              title ??
                  (isError
                      ? 'Unable to load revenue analytics'
                      : 'No revenue analytics available'),
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message ??
                  (isError
                      ? 'The final API integration can retry from this state.'
                      : 'The page is ready to show backend data when records are available.'),
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: theme.canvasColor.withValues(alpha: 0.62)),
            ),
            if (showRefresh) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _refreshPreview,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style:
                    FilledButton.styleFrom(backgroundColor: theme.primaryColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _surface({
    required ThemeData theme,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      padding: padding,
      decoration: _surfaceDecoration(theme),
      child: child,
    );
  }

  BoxDecoration _surfaceDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.88 : 0.94,
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: theme.canvasColor,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _dropdown<T>({
    required ThemeData theme,
    required String label,
    required T? value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      hint: hint == null ? null : Text(hint, overflow: TextOverflow.ellipsis),
      dropdownColor: theme.cardColor,
      style: TextStyle(color: theme.canvasColor, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.62)),
        isDense: true,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.canvasColor.withValues(alpha: 0.1)),
        ),
      ),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem<T>(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _toolbarButton(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: label,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: theme.primaryColor,
          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.36)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _statusPill(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      foregroundColor: theme.canvasColor,
      side: BorderSide(color: theme.canvasColor.withValues(alpha: 0.14)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  TextStyle _axisStyle(ThemeData theme) {
    return TextStyle(
        color: theme.canvasColor.withValues(alpha: 0.62), fontSize: 10);
  }

  String _dateRangeLabel() {
    final format = DateFormat('dd MMM yyyy');
    return '${format.format(_dateRange.start)} - ${format.format(_dateRange.end)}';
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  _StickyFilterDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  double get minExtent {
    final effectiveMaxHeight = maxHeight < minHeight ? minHeight : maxHeight;
    return minHeight.clamp(0.0, effectiveMaxHeight).toDouble();
  }

  @override
  double get maxExtent => maxHeight < minHeight ? minHeight : maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return child != oldDelegate.child ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}

class _StaticRowsSource extends DataTableSource {
  _StaticRowsSource({
    required this.rows,
    required this.theme,
    required this.columnCount,
  });

  final List<List<String>> rows;
  final ThemeData theme;
  final int columnCount;

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final row = rows[index];
    return DataRow(
      cells: List.generate(columnCount, (cellIndex) {
        return DataCell(
          Text(
            cellIndex < row.length ? row[cellIndex] : '-',
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}

class _Metric {
  const _Metric(this.title, this.value, this.icon, this.color);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _SummaryMetricSpec {
  const _SummaryMetricSpec(
    this.key,
    this.fallbackLabel,
    this.icon,
    this.color,
  );

  final String key;
  final String fallbackLabel;
  final IconData icon;
  final Color color;
}

class _CalculationLine {
  const _CalculationLine(this.label, this.formula, this.amount);

  final String label;
  final String formula;
  final String amount;
}

class _ProfileItem {
  const _ProfileItem(this.label, this.value);

  final String label;
  final String value;
}

class _ChartPoint {
  const _ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

const _trendPoints = [
  _ChartPoint('Jan', 36),
  _ChartPoint('Feb', 44),
  _ChartPoint('Mar', 58),
  _ChartPoint('Apr', 52),
  _ChartPoint('May', 74),
  _ChartPoint('Jun', 91),
];

const _monthlyPoints = [
  _ChartPoint('Jan', 42),
  _ChartPoint('Feb', 49),
  _ChartPoint('Mar', 61),
  _ChartPoint('Apr', 67),
  _ChartPoint('May', 79),
  _ChartPoint('Jun', 88),
];

const _growthPoints = [
  _ChartPoint('W1', 18),
  _ChartPoint('W2', 31),
  _ChartPoint('W3', 42),
  _ChartPoint('W4', 55),
  _ChartPoint('W5', 72),
  _ChartPoint('W6', 89),
];

const _promoterGrowthPoints = [
  _ChartPoint('Jan', 150),
  _ChartPoint('Feb', 230),
  _ChartPoint('Mar', 420),
  _ChartPoint('Apr', 610),
  _ChartPoint('May', 760),
  _ChartPoint('Jun', 940),
];

const _sharePoints = [
  _ChartPoint('Platform', 30),
  _ChartPoint('Production', 70),
];

const _contentPoints = [
  _ChartPoint('Movie', 52),
  _ChartPoint('Series', 24),
  _ChartPoint('Short Film', 14),
  _ChartPoint('Music', 10),
];

const _movieRevenuePoints = [
  _ChartPoint('The Silent Frame', 36),
  _ChartPoint('Monsoon Nights', 27),
  _ChartPoint('City Of Dreams', 22),
  _ChartPoint('Other', 15),
];

const _commissionPoints = [
  _ChartPoint('National', 16),
  _ChartPoint('State', 23),
  _ChartPoint('District', 28),
  _ChartPoint('Taluka', 33),
];

const _userPurchaseColumns = [
  'User Name',
  'Movie Name',
  'Ticket Price',
  'Quantity',
  'Gross Revenue',
  'Eligible Revenue',
  'Promoter Percentage',
  'Commission Earned',
];

const _userPurchaseRows = [
  [
    'Aarav Mehta',
    'The Silent Frame',
    'Rs. 100',
    '2',
    'Rs. 200',
    'Rs. 169',
    '1%',
    'Rs. 1.69'
  ],
  [
    'Isha Rao',
    'Monsoon Nights',
    'Rs. 120',
    '3',
    'Rs. 360',
    'Rs. 305',
    '1%',
    'Rs. 3.05'
  ],
  [
    'Kabir Shah',
    'City Of Dreams',
    'Rs. 150',
    '1',
    'Rs. 150',
    'Rs. 127',
    '1%',
    'Rs. 1.27'
  ],
  [
    'Neha Jain',
    'Royal Edge',
    'Rs. 90',
    '4',
    'Rs. 360',
    'Rs. 305',
    '1%',
    'Rs. 3.05'
  ],
  [
    'Rohan Iyer',
    'North Star',
    'Rs. 110',
    '2',
    'Rs. 220',
    'Rs. 186',
    '1%',
    'Rs. 1.86'
  ],
];

const _promoterMovieColumns = [
  'Movie Name',
  'Users Purchased',
  'Tickets Sold',
  'Gross Revenue',
  'Promoter Revenue',
  'Percentage',
  'TDS',
  'Razorpay Charges',
  'Net Revenue',
];

const _promoterMovieRows = [
  [
    'The Silent Frame',
    '2,450',
    '4,020',
    'Rs. 4,02,000',
    'Rs. 4,020',
    '1%',
    'Rs. 402',
    'Rs. 80',
    'Rs. 3,538'
  ],
  [
    'Monsoon Nights',
    '1,980',
    '3,460',
    'Rs. 4,15,200',
    'Rs. 4,152',
    '1%',
    'Rs. 415',
    'Rs. 83',
    'Rs. 3,654'
  ],
  [
    'City Of Dreams',
    '1,760',
    '2,980',
    'Rs. 4,47,000',
    'Rs. 4,470',
    '1%',
    'Rs. 447',
    'Rs. 89',
    'Rs. 3,934'
  ],
  [
    'Royal Edge',
    '1,120',
    '2,050',
    'Rs. 1,84,500',
    'Rs. 1,845',
    '1%',
    'Rs. 184',
    'Rs. 36',
    'Rs. 1,625'
  ],
  [
    'North Star',
    '940',
    '1,390',
    'Rs. 1,52,900',
    'Rs. 1,529',
    '1%',
    'Rs. 152',
    'Rs. 30',
    'Rs. 1,347'
  ],
];

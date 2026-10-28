import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/add_mediaHouse.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/media_house_profile.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'component/media_house_table.dart';

class ManageMediaHousePage extends StatefulWidget {
  const ManageMediaHousePage({super.key});

  @override
  State<ManageMediaHousePage> createState() => _ManageMediaHousePageState();
}

class _ManageMediaHousePageState extends State<ManageMediaHousePage> {
  String _selectedPeriod = 'Week';
  String _selectedStatusFilter = 'ALL';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MediaHouseProvider>(context, listen: false);
      provider.fetchMediaHouse();
      provider.fetchMediaHouseCountGraph(0);
    });
  }

  void _updateChart(String period, MediaHouseProvider provider) {
    if (period == "Week") {
      provider.fetchMediaHouseCountGraph(0);
    } else if (period == "Month") {
      provider.fetchMediaHouseCountGraph(1);
    } else {
      provider.fetchMediaHouseCountGraph(2);
    }
    setState(() {
      _selectedPeriod = period;
    });
  }

  Future<void> _refreshData(MediaHouseProvider provider) async {
    setState(() => _isRefreshing = true);
    await provider.fetchMediaHouse();
    _updateChart(_selectedPeriod, provider);
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _showAddMediaHouseDialog(MediaHouseProvider provider) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMediaHouseWidget(),
      ),
    );

    if (result == true && mounted) {
      provider.fetchMediaHouse();
      _updateChart(_selectedPeriod, provider);
    }
  }

  double _parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 0.0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₹ ',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  String _formatCompact(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toInt().toString();
  }

  List<MediaHouse> _getFilteredList(List<MediaHouse> list) {
    if (_selectedStatusFilter == 'ALL') return list;
    return list.where((house) {
      final status = (house.status ?? (house.active == true ? 'ACTIVE' : 'PENDING')).toUpperCase();
      if (_selectedStatusFilter == 'ACTIVE') {
        return status == 'ACTIVE' || status == 'APPROVED';
      } else if (_selectedStatusFilter == 'PENDING') {
        return status == 'PENDING';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Consumer<MediaHouseProvider>(
      builder: (context, provider, child) {
        final allMediaHouses = provider.mediaHouseList;
        final filteredBySearch = provider.filteredMediaHouseList;
        final displayList = _getFilteredList(filteredBySearch);

        // Aggregated Metrics
        final totalHouses = allMediaHouses.length;
        int totalContents = 0;
        int totalViews = 0;
        double totalRevenue = 0.0;

        for (final house in allMediaHouses) {
          totalContents += int.tryParse(house.postCount ?? '0') ?? 0;
          totalViews += int.tryParse(house.totalViews ?? '0') ?? 0;
          final houseRev = _parseNumber(house.displayTotalRevenue);
          totalRevenue += houseRev;
        }
        debugPrint("[ManageMediaHouse] Aggregated Metrics: Houses=$totalHouses, Contents=$totalContents, Views=$totalViews, GrossRevenue=$totalRevenue");

        final isMobile = ResponsiveWidget.isMobile(context);
        final isTablet = ResponsiveWidget.isTablet(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () => _refreshData(provider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Banner
                  _buildHeader(theme, provider, totalHouses, isMobile),
                  const SizedBox(height: 20),

                  // 4 KPI Summary Cards
                  _buildKpiMetrics(
                    theme,
                    totalHouses: totalHouses,
                    totalContents: totalContents,
                    totalViews: totalViews,
                    totalRevenue: totalRevenue,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 24),

                  // Search and Filter Bar
                  _buildSearchAndFilterBar(theme, provider, isMobile),
                  const SizedBox(height: 24),

                  // Featured / Recent Cards Carousel
                  if (displayList.isNotEmpty) ...[
                    _buildCardsSection(theme, provider, displayList),
                    const SizedBox(height: 24),
                  ],

                  // Analytics Chart & Table Section
                  if (isMobile)
                    Column(
                      children: [
                        _buildChartCard(theme, provider),
                        const SizedBox(height: 20),
                        MediaHouseTable(mediaHouseData: displayList),
                      ],
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1100) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildChartCard(theme, provider),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 6,
                                child: MediaHouseTable(mediaHouseData: displayList),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildChartCard(theme, provider),
                              const SizedBox(height: 24),
                              MediaHouseTable(mediaHouseData: displayList),
                            ],
                          );
                        }
                      },
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMediaHouseDialog(provider),
            backgroundColor: theme.primaryColor,
            elevation: 4,
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: const Text(
              'Add Production House',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    MediaHouseProvider provider,
    int totalHouses,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Production Houses',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w800,
                        color: theme.canvasColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$totalHouses Partners',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage media partners, review catalog volumes, views, and revenue distributions.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: theme.canvasColor.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            IconButton(
              onPressed: _isRefreshing ? null : () => _refreshData(provider),
              icon: _isRefreshing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      color: theme.canvasColor.withValues(alpha: 0.7),
                    ),
              tooltip: 'Refresh Data',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddMediaHouseDialog(provider),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Production House'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiMetrics(
    ThemeData theme, {
    required int totalHouses,
    required int totalContents,
    required int totalViews,
    required double totalRevenue,
    required bool isMobile,
    required bool isTablet,
  }) {
    final cards = [
      _KpiCardData(
        title: 'Production Houses',
        value: totalHouses.toString(),
        subtitle: 'Registered entities',
        icon: Icons.business_outlined,
        color: const Color(0xFF2563EB),
      ),
      _KpiCardData(
        title: 'Published Content',
        value: totalContents.toString(),
        subtitle: 'Movies & Series',
        icon: Icons.movie_outlined,
        color: const Color(0xFF7C3AED),
      ),
      _KpiCardData(
        title: 'Total Viewership',
        value: _formatCompact(totalViews.toDouble()),
        subtitle: 'Aggregated Views',
        icon: Icons.visibility_outlined,
        color: const Color(0xFFEA580C),
      ),
      _KpiCardData(
        title: 'Gross Revenue',
        value: _formatCurrency(totalRevenue),
        subtitle: 'Lifetime Total',
        icon: Icons.currency_rupee_rounded,
        color: const Color(0xFF16A34A),
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildKpiCardItem(card, theme),
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 800 ? 2 : 4;
        final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 14)) / crossAxisCount;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: _buildKpiCardItem(card, theme),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildKpiCardItem(_KpiCardData data, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.canvasColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: theme.canvasColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.canvasColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(
    ThemeData theme,
    MediaHouseProvider provider,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: provider.searchMediaHouseController,
                  hintText: 'Search by production house name, contact, email, or city...',
                  textInputType: TextInputType.text,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.canvasColor.withValues(alpha: 0.6),
                  ),
                  suffixIcon: Icons.search,
                ),
              ),
              if (isMobile) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isRefreshing ? null : () => _refreshData(provider),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilterChip('ALL', 'All Partners', theme),
                const SizedBox(width: 8),
                _buildStatusFilterChip('ACTIVE', 'Active / Approved', theme),
                const SizedBox(width: 8),
                _buildStatusFilterChip('PENDING', 'Pending Approval', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String value, String label, ThemeData theme) {
    final isSelected = _selectedStatusFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatusFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.canvasColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.canvasColor.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : theme.canvasColor.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection(
    ThemeData theme,
    MediaHouseProvider provider,
    List<MediaHouse> list,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.view_carousel_outlined, size: 18, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Partner Highlights',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.canvasColor,
                  ),
                ),
              ],
            ),
            Text(
              '${list.length} Displayed',
              style: TextStyle(
                fontSize: 12,
                color: theme.canvasColor.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 255,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final mediaHouse = list[index];
              return ProfilePageCard(mediaHouse, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(ThemeData theme, MediaHouseProvider provider) {
    final chartData = provider.chartData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Time Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.show_chart_rounded,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Onboarding Trend',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.canvasColor,
                            ),
                          ),
                          Text(
                            'Production houses onboarded ($_selectedPeriod view)',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.canvasColor.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Button Bar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.canvasColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodPill('Week', provider, theme),
                    _buildPeriodPill('Month', provider, theme),
                    _buildPeriodPill('Year', provider, theme),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Graph View
          SizedBox(
            height: 320,
            child: chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.query_stats_outlined,
                          size: 38,
                          color: theme.canvasColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No onboarding records found for this period.',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.canvasColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: 'Onboarded',
                      canShowMarker: true,
                      textStyle: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    primaryXAxis: CategoryAxis(
                      labelIntersectAction: AxisLabelIntersectAction.rotate45,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.canvasColor.withValues(alpha: 0.7),
                      ),
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: AxisLine(
                        color: theme.canvasColor.withValues(alpha: 0.15),
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      labelFormat: '{value}',
                      interval: 1,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        color: theme.canvasColor.withValues(alpha: 0.7),
                      ),
                      majorGridLines: MajorGridLines(
                        color: theme.canvasColor.withValues(alpha: 0.06),
                        dashArray: const <double>[4, 4],
                      ),
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    series: <CartesianSeries>[
                      SplineAreaSeries<LineChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (LineChartData data, _) => data.label,
                        yValueMapper: (LineChartData data, _) => data.value,
                        name: 'Onboarded',
                        color: theme.primaryColor,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.35),
                            theme.primaryColor.withValues(alpha: 0.02),
                          ],
                        ),
                        borderColor: theme.primaryColor,
                        borderWidth: 2.5,
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          height: 6,
                          width: 6,
                          color: theme.cardColor,
                          borderColor: theme.primaryColor,
                          borderWidth: 2,
                        ),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: chartData.length <= 15,
                          labelAlignment: ChartDataLabelAlignment.top,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodPill(
    String period,
    MediaHouseProvider provider,
    ThemeData theme,
  ) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () => _updateChart(period, provider),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : theme.canvasColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _KpiCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _KpiCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

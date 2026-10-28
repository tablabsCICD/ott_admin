import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../data/models/response/topRevenueMovie.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../provider/graphProvider.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../widgets/financial_formatter.dart';

class TopMoviesLineGraph extends StatefulWidget {
  final bool isRevenue;
  final int mediaHouseId;
  final String type;

  const TopMoviesLineGraph({
    super.key,
    required this.isRevenue,
    required this.mediaHouseId,
    this.type = "ALL",
  });

  @override
  State<TopMoviesLineGraph> createState() => _TopMoviesLineGraphState();
}

class _TopMoviesLineGraphState extends State<TopMoviesLineGraph> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        if (data is ContentWithRevenue) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name?.isNotEmpty == true
                      ? data.name!
                      : 'Content',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Gross Revenue: ${FinancialFormatter.format4(data.mediaHouseGrossRevenue ?? 0.0)}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.tealAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Net Revenue: ${FinancialFormatter.format4(data.mediaHouseNetRevenue ?? 0.0)}',
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Total Revenue: ${FinancialFormatter.format4(data.totalRevenue ?? 0.0)}',
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(6),
          color: Colors.black87,
          child: Text(
            '${point.x} : ${point.y}',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  @override
  void didUpdateWidget(covariant TopMoviesLineGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        oldWidget.mediaHouseId != widget.mediaHouseId ||
        oldWidget.isRevenue != widget.isRevenue) {
      getData();
    }
  }

  Future<void> getData() async {
    if (widget.mediaHouseId <= 0) return;
    try {
      if (widget.isRevenue) {
        await Provider.of<GraphProvider>(context, listen: false)
            .fetchTopPerformingMovieGraph(0, widget.mediaHouseId,
                type: widget.type);
      } else {
        await Provider.of<GraphProvider>(context, listen: false)
            .fetchTopRatedMovieGraph(0, widget.mediaHouseId,
                type: widget.type);
      }
    } catch (e) {
      debugPrint("Error loading graph in TopMoviesLineGraph: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<GraphProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  widget.isRevenue
                      ? Icons.bar_chart_rounded
                      : Icons.star_rate_rounded,
                  color: selectedThemeData.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isRevenue
                      ? 'Revenue by Content'
                      : 'Top Rated Content',
                  style: TextStyle(
                    color: selectedThemeData.canvasColor,
                    fontSize: ResponsiveWidget.isMobile(context) ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildDateSelection(selectedThemeData, provider),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildChart(selectedThemeData, provider)),
            const SizedBox(height: 8),
            _buildFilterOptions(selectedThemeData, provider),
          ],
        );
      },
    );
  }

  Widget _buildDateSelection(ThemeData theme, GraphProvider provider) {
    return Text(
      provider.selectedDateRange == null
          ? "All Time"
          : "${DateFormat('dd MMM').format(provider.selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(provider.selectedDateRange!.end)}",
      style: TextStyle(
        fontSize: ResponsiveWidget.isMobile(context) ? 11 : 13,
        fontWeight: FontWeight.w600,
        color: theme.canvasColor.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildChart(ThemeData theme, GraphProvider provider) {
    if (provider.isRevenueGraphLoading) {
      return Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.primaryColor,
          ),
        ),
      );
    }

    if (widget.isRevenue) {
      if (provider.chartData.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart_rounded,
                  size: 38, color: theme.canvasColor.withValues(alpha: 0.3)),
              const SizedBox(height: 6),
              Text(
                provider.revenueGraphError ?? 'Revenue graph unavailable',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.canvasColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        );
      }

      return SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.top,
          alignment: ChartAlignment.center,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          labelStyle: TextStyle(
            fontSize: 10,
            color: theme.canvasColor.withValues(alpha: 0.8),
          ),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelStyle: TextStyle(
            fontSize: 10,
            color: theme.canvasColor.withValues(alpha: 0.8),
          ),
          numberFormat: NumberFormat.currency(
            symbol: '₹',
            decimalDigits: 0,
          ),
        ),
        series: <CartesianSeries<ContentWithRevenue, String>>[
          ColumnSeries<ContentWithRevenue, String>(
            name: 'Gross Revenue',
            dataSource: provider.chartData,
            xValueMapper: (ContentWithRevenue movie, _) => movie.name ?? 'N/A',
            yValueMapper: (ContentWithRevenue movie, _) =>
                movie.mediaHouseGrossRevenue ?? 0.0,
            color: Colors.amber.shade700,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
            spacing: 0.2,
          ),
          ColumnSeries<ContentWithRevenue, String>(
            name: 'Net Revenue',
            dataSource: provider.chartData,
            xValueMapper: (ContentWithRevenue movie, _) => movie.name ?? 'N/A',
            yValueMapper: (ContentWithRevenue movie, _) =>
                movie.mediaHouseNetRevenue ?? 0.0,
            color: Colors.teal.shade600,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
            spacing: 0.2,
          ),
          ColumnSeries<ContentWithRevenue, String>(
            name: 'Total Revenue',
            dataSource: provider.chartData,
            xValueMapper: (ContentWithRevenue movie, _) => movie.name ?? 'N/A',
            yValueMapper: (ContentWithRevenue movie, _) =>
                movie.totalRevenue ?? 0.0,
            color: theme.primaryColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
            spacing: 0.2,
          ),
        ],
      );
    }

    // Fallback for rating graph
    if (provider.graphData.isEmpty) {
      return Center(
        child: Text(
          'No ratings data available',
          style: TextStyle(
            fontSize: 13,
            color: theme.canvasColor.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        labelStyle: TextStyle(
          fontSize: 10,
          color: theme.canvasColor.withValues(alpha: 0.8),
        ),
      ),
      primaryYAxis: const NumericAxis(),
      tooltipBehavior: _tooltipBehavior,
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        LineSeries<Map<String, dynamic>, String>(
          name: 'Rating',
          dataSource: provider.graphData,
          xValueMapper: (movie, _) => movie['label']?.toString() ?? '',
          yValueMapper: (movie, _) =>
              (movie['value'] as num?)?.toDouble() ?? 0.0,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: theme.primaryColor,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildFilterOptions(ThemeData theme, GraphProvider provider) {
    final filterOptions = [
      {'label': 'Week', 'days': 7},
      {'label': 'Month', 'days': 30},
      {'label': 'Year', 'days': 365},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...filterOptions.map((range) => _buildFilterButton(
              theme,
              range['label'] as String,
              range['days'] as int,
              provider)),
          const SizedBox(width: 6),
          _buildFilterButton(theme, 'Custom Dates', 0, provider,
              isCustom: true),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
      ThemeData theme, String label, int days, GraphProvider provider,
      {bool isCustom = false}) {
    final bool isActive = provider.activeButton == label;
    return GestureDetector(
      onTap: isCustom
          ? () => provider.pickDateRange(
              context, widget.isRevenue, widget.mediaHouseId,
              type: widget.type)
          : () => provider.setDateRange(
              label, days, context, widget.isRevenue, widget.mediaHouseId,
              type: widget.type),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryColor
              : theme.canvasColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? theme.primaryColor
                : theme.canvasColor.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : theme.canvasColor,
          ),
        ),
      ),
    );
  }
}


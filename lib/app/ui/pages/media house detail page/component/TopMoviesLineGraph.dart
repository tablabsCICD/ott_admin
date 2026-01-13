import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../provider/graphProvider.dart';
import '../../../../provider/themeProvider.dart';

class TopMoviesLineGraph extends StatefulWidget {
  bool isRevenue;
  int mediaHouseId;
  TopMoviesLineGraph({required this.isRevenue,required this.mediaHouseId});
  @override
  _TopMoviesLineGraphState createState() => _TopMoviesLineGraphState();
}

class _TopMoviesLineGraphState extends State<TopMoviesLineGraph> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    widget.isRevenue?
    await Provider.of<GraphProvider>(context, listen: false).fetchTopPerformingMovieGraph(0,widget.mediaHouseId):await Provider.of<GraphProvider>(context, listen: false).fetchTopRatedMovieGraph(0,widget.mediaHouseId);
  }



  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<GraphProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Top Performing Movies',
                  style: TextStyle(
                    color: selectedThemeData.primaryColor,
                    fontSize: ResponsiveWidget.isMobile(context) ? 14 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                _buildDateSelection(selectedThemeData,provider),
              ],
            ),
            SizedBox(height: 20),
            _buildChart(selectedThemeData,provider),
            _buildFilterOptions(selectedThemeData,provider),
          ],
        );
      },
    );
  }

  Widget _buildDateSelection(ThemeData theme, GraphProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          provider.selectedDateRange == null
              ? "Select Date Range"
              : "${DateFormat.yMMMd().format(provider.selectedDateRange!.start)} - ${DateFormat.yMMMd().format(provider.selectedDateRange!.end)}",
          style: TextStyle(
              fontSize: ResponsiveWidget.isMobile(context) ? 12 : 16,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChart(ThemeData theme, GraphProvider provider) {
    return Expanded(
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: <CartesianSeries<Map<String, dynamic>, String>>[
          LineSeries<Map<String, dynamic>, String>(
            dataSource: provider.graphData,
            xValueMapper: (movie, _) => movie['label'],
            yValueMapper: (movie, _) => movie['value'],
            dataLabelSettings: DataLabelSettings(isVisible: true),
            color: theme.primaryColor,
            markerSettings: MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(ThemeData theme, GraphProvider provider) {
    final filterOptions = [
      {'label': 'Week', 'days': 7},
      {'label': 'Month', 'days': 30},
      {'label': 'Year', 'days': 365},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...filterOptions.map((range) => _buildFilterButton(
            theme, range['label'] as String, range['days'] as int,provider)),
        _buildFilterButton(theme, 'Custom Dates', 0,provider, isCustom: true),
      ],
    );
  }

  Widget _buildFilterButton(
      ThemeData theme, String label, int days, GraphProvider provider,
      {bool isCustom = false}) {
    final bool isActive = provider.activeButton == label;
    return GestureDetector(
      onTap: isCustom
          ? () => provider.pickDateRange(context,widget.isRevenue,widget.mediaHouseId) // Pass `context` explicitly
          : () => provider.setDateRange(label, days,context,widget.isRevenue,widget.mediaHouseId),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryColor
              : theme.canvasColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? theme.primaryColor
                : theme.canvasColor.withOpacity(0.7),
            width: 0.4,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : theme.canvasColor,
          ),
        ),
      ),
    );
  }
}

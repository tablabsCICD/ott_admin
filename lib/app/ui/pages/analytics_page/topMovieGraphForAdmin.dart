import 'package:admin_ott/app/provider/analyticsProvider.dart';
import 'package:admin_ott/data/repositories/mediahouselist.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/themeProvider.dart';


class TopMoviesGraphForAdmin extends StatefulWidget {
  TopMoviesGraphForAdmin();

  @override
  _TopMoviesGraphForAdminState createState() => _TopMoviesGraphForAdminState();
}

class _TopMoviesGraphForAdminState extends State<TopMoviesGraphForAdmin> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    await Provider.of<AnalyticsProvider>(context, listen: false).fetchTopPerformingMovieGraph(0);
  }



  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<AnalyticsProvider>(
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

  Widget _buildDateSelection(ThemeData theme, AnalyticsProvider provider) {
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

  Widget _buildChart(ThemeData theme, AnalyticsProvider provider) {
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

  Widget _buildFilterOptions(ThemeData theme, AnalyticsProvider provider) {
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
      ThemeData theme, String label, int days, AnalyticsProvider provider,
      {bool isCustom = false}) {
    final bool isActive = provider.activeButton == label;
    return GestureDetector(
      onTap: isCustom
          ? () => provider.pickDateRange(context,true) // Pass `context` explicitly
          : () => provider.setDateRange(label, days,context,true),
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

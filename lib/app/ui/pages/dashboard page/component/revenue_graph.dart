import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../provider/userGraphProvider.dart'; // Import intl for number formatting

class RevenueGraph extends StatefulWidget {
  final int selectedTimeRange;
  final double height;

  const RevenueGraph(
      {super.key, required this.selectedTimeRange, required this.height});

  @override
  State<RevenueGraph> createState() => _RevenueGraphState();
}

class _RevenueGraphState extends State<RevenueGraph> {
  bool _hasRequestedData = false;

  @override
  void initState() {
    super.initState();
    _fetchGraphData();
  }

  @override
  void didUpdateWidget(covariant RevenueGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTimeRange != widget.selectedTimeRange) {
      _fetchGraphData();
    }
  }

  void _fetchGraphData() {
    _hasRequestedData = true;
    Provider.of<UserGraphProvider>(context, listen: false)
        .fetchPurchaseGraph(widget.selectedTimeRange);
  }

  @override
  Widget build(BuildContext context) {
    var selectedTheme =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Consumer<UserGraphProvider>(builder: (context, provider, child) {
      if (!_hasRequestedData || provider.chartData.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fetchGraphData();
        });
      }
      return SizedBox(
        height: widget.height,
        child: SfCartesianChart(
          backgroundColor: selectedTheme.cardColor,
          primaryXAxis: CategoryAxis(
            title: AxisTitle(
              text: '<-------------- Time -------------->',
              textStyle: TextStyle(
                color: selectedTheme.canvasColor,
                fontSize: 12,
              ),
            ),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: '<---------- Revenue ---------->',
              textStyle: TextStyle(
                color: selectedTheme.canvasColor,
                fontSize: 12,
              ),
            ),
            axisLine: const AxisLine(width: 0),
            majorGridLines: const MajorGridLines(width: 0.5),
          ),
          series: <CartesianSeries>[
            LineSeries<LineChartData, String>(
              dataSource: provider.chartData,
              xValueMapper: (LineChartData data, _) => data.label,
              yValueMapper: (LineChartData data, _) => data.value,
              color: selectedTheme.primaryColor,
              markerSettings: MarkerSettings(
                isVisible: true,
                color: selectedTheme.primaryColor,
                shape: DataMarkerType.circle,
              ),
              width: 3,
            ),
          ],
          tooltipBehavior: TooltipBehavior(enable: true),
          borderWidth: 1,
          borderColor: selectedTheme.canvasColor,
        ),
      );
    });
  }
}

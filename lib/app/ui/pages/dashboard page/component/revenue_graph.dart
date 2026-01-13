import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchGraphData();
  }

  _fetchGraphData(){
    Provider.of<UserGraphProvider>(context, listen: false).fetchPurchaseGraph(widget.selectedTimeRange);
  }

  @override
  Widget build(BuildContext context) {
    var selectedTheme =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Consumer<UserGraphProvider>(
        builder: (context, provider, child) {
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
          );});
  }
}


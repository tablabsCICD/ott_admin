// widgets/content_approved_graph.dart
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

import '../../../../provider/userGraphProvider.dart';

class ContentApprovedGraph extends StatefulWidget {
  final int selectedTimeRange;

  const ContentApprovedGraph({Key? key, required this.selectedTimeRange})
      : super(key: key);

  @override
  State<ContentApprovedGraph> createState() => _ContentApprovedGraphState();
}

class _ContentApprovedGraphState extends State<ContentApprovedGraph> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchGraphData();
  }

  _fetchGraphData(){
    Provider.of<UserGraphProvider>(context, listen: false).fetchApprovedContentGraph(widget.selectedTimeRange);
  }

  @override
  Widget build(BuildContext context) {
    var selectedTheme =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Consumer<UserGraphProvider>(
        builder: (context, provider, child) {
          return SizedBox(
            height: 350,
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
                  text: '<---------- Managers Onboarded ---------->',
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


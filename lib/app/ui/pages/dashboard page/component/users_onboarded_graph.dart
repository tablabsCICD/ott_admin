import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/userGraphProvider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class UsersOnboardedGraph extends StatefulWidget {
  final int selectedTimeRange;

  const UsersOnboardedGraph({Key? key, required this.selectedTimeRange})
      : super(key: key);

  @override
  State<UsersOnboardedGraph> createState() => _UsersOnboardedGraphState();
}

class _UsersOnboardedGraphState extends State<UsersOnboardedGraph> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fetchGraphData();
  }

  _fetchGraphData(){
    Provider.of<UserGraphProvider>(context, listen: false).fetchUserGraph(widget.selectedTimeRange);
  }

  @override
  Widget build(BuildContext context) {
    var selectedTheme =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

       return Consumer<UserGraphProvider>(
        builder: (context, provider, child) {
      return SizedBox(
        height: ResponsiveWidget.isMobile(context) ? 300 : 350,
        child: SfCartesianChart(
          backgroundColor: selectedTheme.cardColor,
          margin: const EdgeInsets.fromLTRB(10, 10, 20, 10),
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
              text: '<---------- Users Onboarded ---------->',
              textStyle: TextStyle(
                color: selectedTheme.canvasColor,
                fontSize: 12,
              ),
            ),
            axisLine: const AxisLine(width: 0),
            majorGridLines: const MajorGridLines(width: 0.5),
            numberFormat: NumberFormat.compact(),
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
        ),
      );}
    );
  }
}

// LineChartData model class
class LineChartData {
  final String label;
  final double value;

  LineChartData(this.label, this.value);
}

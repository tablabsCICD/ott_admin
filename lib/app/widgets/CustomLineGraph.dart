import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

import '../ui/pages/dashboard page/component/users_onboarded_graph.dart';

class CustomLineGraph extends StatefulWidget {
  final String title;
  final String yAxisLabel;
  int graphNumber;
  int mediaHouseId;
  final List<String> metrics; // e.g. ["revenue", "users_onboarded"]
  final bool canPop;

  CustomLineGraph({
    super.key,
    required this.title,
    required this.yAxisLabel,
    required this.metrics,
    this.canPop = false,
    required this.graphNumber,
    required this.mediaHouseId,
  });

  @override
  _CustomLineGraphState createState() => _CustomLineGraphState();
}

class _CustomLineGraphState extends State<CustomLineGraph> {
  DateTimeRange? selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 7)),
    end: DateTime.now(),
  );
  DateTime get today => DateTime.now();
  DateTime? startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime? endDate = DateTime.now();
  String activeButton = '1W';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchGraphData(0, DateTime.now().subtract(Duration(days: 7)), DateTime.now());
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        activeButton = 'Custom Dates';
        startDate = picked.start;//DateFormat('yyyy-MM-dd').format(DateTime.parse("2025-05-01 00:00:00.000"));
        endDate = picked.end;
        print("start date $startDate && end date $endDate");
        _fetchGraphData(3,startDate!,endDate!);
      });
    }
  }

  Future<void> _setDateRange(String label, int days) async {
    int selectedTimeRange;
    if (label == '1W') {
      selectedTimeRange = 0;
    } else if (label == '1M') {
      selectedTimeRange = 1;
    } else {
      selectedTimeRange = 2;
    }

    final DateTime calculatedEndDate = DateTime.now();
    final DateTime calculatedStartDate = calculatedEndDate.subtract(Duration(days: days));

    // Fetch the graph data first
    await _fetchGraphData(selectedTimeRange, calculatedStartDate, calculatedEndDate);

    // Update the state after data is fetched
    setState(() {
      activeButton = label;
      startDate = calculatedStartDate;
      endDate = calculatedEndDate;
      selectedDateRange = DateTimeRange(start: startDate!, end: endDate!);
    });
  }

  Future<void> _fetchGraphData(int selectedTimeRange, DateTime startDate, DateTime endDate) async {
    final mediaHouseProvider = Provider.of<MediaHouseProvider>(context, listen: false);

    final startDateString = DateFormat("yyyy-MM-dd").format(startDate);
    final endDateString = DateFormat("yyyy-MM-dd").format(endDate);

    if (widget.graphNumber == 0) {
      await mediaHouseProvider.revenueGraphByMediaHouse(
        selectedTimeRange,
        startDateString,
        endDateString,
        widget.mediaHouseId,
      );
    } else if (widget.graphNumber == 1) {
      await mediaHouseProvider.viewsCountGraph(
        selectedTimeRange,
        startDateString,
        endDateString,
        widget.mediaHouseId,
      );
    } else if (widget.graphNumber == 2) {
      await mediaHouseProvider.releaseMovieCountGraph(
        selectedTimeRange,
        startDateString,
        endDateString,
        widget.mediaHouseId,
      );
    } else if (widget.graphNumber == 3) {
      await mediaHouseProvider.revenueGraphByMediaHouse(
        selectedTimeRange,
        startDateString,
        endDateString,
        widget.mediaHouseId,
      );
    } else {
      await mediaHouseProvider.revenueGraphByMediaHouse(
        selectedTimeRange,
        startDateString,
        endDateString,
        widget.mediaHouseId,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          widget.canPop
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_sharp),
              ),
            ],
          )
              : SizedBox(height: 5),
          _buildTitle(selectedThemeData),
          const SizedBox(height: 10),
          _buildDateSelection(),
          const SizedBox(height: 10),
          _buildChart(selectedThemeData),
          const SizedBox(height: 10),
          _buildFilterOptions(selectedThemeData),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData selectedThemeData) {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: selectedThemeData.primaryColor,
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          selectedDateRange == null
              ? "Select Date Range"
              : "${DateFormat.yMMMd().format(selectedDateRange!.start)} - ${DateFormat.yMMMd().format(selectedDateRange!.end)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChart(ThemeData selectedThemeData) {
    return Expanded(
      child: Consumer<MediaHouseProvider>(
        builder: (context, provider, child) {
          return SfCartesianChart(
            primaryXAxis: CategoryAxis(
              title: AxisTitle(
                text: '<-------------- Time -------------->',
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              LineSeries<LineChartData, String>(
                dataSource: provider.graphData,
                xValueMapper: (LineChartData data, _) => data.label,
                yValueMapper: (LineChartData data, _) => data.value,
                color: selectedThemeData.primaryColor,
                markerSettings: MarkerSettings(
                  isVisible: true,
                  color: selectedThemeData.primaryColor,
                  shape: DataMarkerType.circle,
                ),
                width: 3,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions(ThemeData selectedThemeData) {
    final filterOptions = [
      {'label': '1W', 'days': 7},
      {'label': '1M', 'days': 30},
      {'label': '1Y', 'days': 365},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...filterOptions.map((range) => _buildFilterButton(
          range['label'] as String,
          range['days'] as int,
          selectedThemeData,
        )),
        _buildFilterButton('Custom Dates', 0, selectedThemeData, isCustom: true),
      ],
    );
  }

  Widget _buildFilterButton(String label, int days, ThemeData selectedThemeData, {bool isCustom = false}) {
    final bool isActive = activeButton == label;
    return GestureDetector(
      onTap: isCustom ? _pickDateRange : () => _setDateRange(label, days),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? selectedThemeData.primaryColor : selectedThemeData.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? selectedThemeData.primaryColor : Colors.grey,
            width: 0.4,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : selectedThemeData.canvasColor,
          ),
        ),
      ),
    );
  }
}

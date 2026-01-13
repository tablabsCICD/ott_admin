import 'dart:convert';
import 'package:admin_ott/app/provider/dashboardProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin_ott/app/provider/fullscreenProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/location_data.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatefulWidget {
  @override
  _RevenueChartState createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  String selectedCountry = 'India';
  String? selectedState;
  String? selectedDistrict;
  String? selectedArea;
  DateTime todaysDate = DateTime.now();
  String endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String startDate =
  DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 7)));
  String? activeButton = '1W';


  @override
  void initState() {
    super.initState();
   _fetchGraphData();

  }


  Future<void> _fetchGraphData() async {
    await Provider.of<DashboardProvider>(context, listen: false)
        .fetchAllRevenueGraph(startDate, endDate);
  }


  Widget buildDropdown<T>(
    String hint,
    T? value,
    List<T> items,
    ValueChanged<T?> onChanged,
    Color dropdownColor,
  ) {
    return DropdownButton<T>(
      dropdownColor: dropdownColor,
      value: value,
      hint: Text(hint),
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text(item.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }


  Future<void> _openDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        activeButton = 'Custom';
        startDate = DateFormat('yyyy-MM-dd').format(picked.start);
        endDate = DateFormat('yyyy-MM-dd').format(picked.end);
        _fetchGraphData();
      });
    }
  }

  /*void _openDateRangePicker(BuildContext context) async {
    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (selectedRange != null) {
      setState(() {
        startDate = selectedRange.start;
        endDate = selectedRange.end;
      });
      updateChartData();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    final fullScreenProvider = Provider.of<FullScreenProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

    return   Consumer<DashboardProvider>(
        builder: (context, provider, child) {
      return Stack(
        children: [
          SizedBox(
            height: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildDropdown(
                      'Country',
                      selectedCountry,
                      locationSelection.keys.toList(),
                      (value) {
                        if (value != null) {
                          setState(() {
                            selectedCountry = value;
                            selectedState = null;
                            selectedDistrict = null;
                            selectedArea = null;
                          });
                        }
                      },
                      selectedThemeData.cardColor,
                    ),
                    const SizedBox(width: 10),
                    if (locationSelection[selectedCountry]?.isNotEmpty ?? false)
                      buildDropdown(
                        'State',
                        selectedState,
                        locationSelection[selectedCountry]!.keys.toList(),
                        (value) {
                          if (value != null) {
                            setState(() {
                              selectedState = value;
                              selectedDistrict = null;
                              selectedArea = null;
                            });
                          }
                        },
                        selectedThemeData.cardColor,
                      ),
                    const SizedBox(width: 10),
                    if (selectedState != null &&
                        locationSelection[selectedCountry]?[selectedState] !=
                            null &&
                        locationSelection[selectedCountry]![selectedState]!
                            .isNotEmpty)
                      buildDropdown(
                        'District',
                        selectedDistrict,
                        locationSelection[selectedCountry]![selectedState]!
                            .keys
                            .toList(),
                        (value) {
                          if (value != null) {
                            setState(() {
                              selectedDistrict = value;
                              selectedArea = null;
                            });
                          }
                        },
                        selectedThemeData.cardColor,
                      ),
                    const SizedBox(width: 10),
                    if (selectedDistrict != null &&
                        locationSelection[selectedCountry]?[selectedState]
                                ?[selectedDistrict] !=
                            null &&
                        locationSelection[selectedCountry]?[selectedState]
                                ?[selectedDistrict] !=
                            null)
                      buildDropdown(
                        'Taluka',
                        selectedArea,
                        locationSelection[selectedCountry]?[selectedState]
                                    ?[selectedDistrict]
                                ?.toList() ??
                            [],
                        (value) {
                          if (value != null) {
                            setState(() {
                              selectedArea = value;
                            });
                          }
                        },
                        selectedThemeData.cardColor,
                      ),
                  ],
                ),
                ///////////////////////////////   GRAPH  ///////////////////////////////
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: TextStyle(color: selectedThemeData.textTheme.headlineSmall?.color),
                      interval: 1, // Ensures all labels are displayed
                      labelRotation: 45, // Rotates labels to avoid overlapping
                    ),
                    title: ChartTitle(
                      text: startDate != null && endDate != null
                          ? 'Revenue Data ($startDate - $endDate) Total : ${provider.totalRevenue}'
                          : 'Revenue Data (No Date Range)',
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      LineSeries<ChartData, String>(
                        dataSource: provider.chartData, // Ensure this is updated by your provider
                        xValueMapper: (data, _) => data.label,
                        yValueMapper: (data, _) => data.value,
                        name: 'Revenue',
                        markerSettings: const MarkerSettings(isVisible: true),
                        color: selectedThemeData.primaryColor,
                      ),
                    ],
                  ),
                ),

                ///////////////////////////////   BUTTONS  ///////////////////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...[
                      {'label': '1W', 'days': 7},
                      {'label': '1M', 'days': 30},
                      {'label': '1Y', 'days': 365},
                    ].map((range) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              activeButton = range['label'] as String;
                              endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              startDate = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now().subtract(Duration(days: int.parse(range['days'].toString()))));
                            });
                            // Fetch the graph data
                            await provider.fetchAllRevenueGraph(startDate, endDate);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeButton == range['label']
                                  ? selectedThemeData.primaryColor
                                  : selectedThemeData.canvasColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: activeButton == range['label']
                                    ? selectedThemeData.primaryColor
                                    : selectedThemeData.canvasColor.withOpacity(0.7),
                                width: 0.4,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            child: Text(
                              range['label'] as String,
                              style: TextStyle(
                                color: activeButton == range['label']
                                    ? Colors.white
                                    : selectedThemeData.canvasColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          activeButton = 'Custom Dates';
                        });
                        _openDateRangePicker();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: activeButton == 'Custom Dates'
                              ? selectedThemeData.primaryColor
                              : selectedThemeData.canvasColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: activeButton == 'Custom Dates'
                                ? selectedThemeData.primaryColor
                                : selectedThemeData.canvasColor.withOpacity(0.7),
                            width: 0.4,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: Text(
                          'Custom Dates',
                          style: TextStyle(
                            color: activeButton == 'Custom Dates'
                                ? Colors.white
                                : selectedThemeData.canvasColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            right: 10,
            child: IconButton(
              icon: Icon(
                fullScreenProvider.isFullScreen
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                color: selectedThemeData.canvasColor,
              ),
              onPressed: () {
                fullScreenProvider.toggleFullScreen();
              },
            ),
          ),
        ],
      );}
    );
  }
}

class ChartData {
  final String label;
  final double value;
  ChartData(this.label, this.value);
}
///// ///// tested ok.
//

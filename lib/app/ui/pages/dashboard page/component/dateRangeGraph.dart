import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoter_details_page.dart';
import 'package:admin_ott/data/repositories/dateWiseRevenue.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class DateRangeGraphWidget extends StatefulWidget {
  String title;
  DateRangeGraphWidget({
    super.key,
    required this.title,
  });
  @override
  _DateRangeGraphWidgetState createState() => _DateRangeGraphWidgetState();
}

class _DateRangeGraphWidgetState extends State<DateRangeGraphWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  void _selectStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  void _selectEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  void _resetDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: selectedThemeData.cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selectedThemeData.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _selectStartDate,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedThemeData.canvasColor.withOpacity(0.2),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _startDate == null
                            ? 'Start Date'
                            : '${_startDate!.toLocal()}'.split(' ')[0],
                        style: TextStyle(
                          color: selectedThemeData.canvasColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_double_arrow_right_sharp,
                ),
                GestureDetector(
                  onTap: _selectEndDate,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedThemeData.canvasColor.withOpacity(0.2),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _endDate == null
                            ? 'End Date'
                            : '${_endDate!.toLocal()}'.split(' ')[0],
                        style: TextStyle(
                          color: selectedThemeData.canvasColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _startDate != null && _endDate != null
                    ? ElevatedButton(
                        onPressed: _resetDates,
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: selectedThemeData.primaryColor,
                          ),
                        ),
                      )
                    : SizedBox(),
                _startDate != null && _endDate != null
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedThemeData.primaryColor,
                        ),
                        onPressed: () {
                          if (_startDate != null && _endDate != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DateRangeGraphPage(
                                  startDate: _startDate!,
                                  endDate: _endDate!,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Show Graph',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class DateRangeGraphPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  DateRangeGraphPage({required this.startDate, required this.endDate});

  @override
  _DateRangeGraphPageState createState() => _DateRangeGraphPageState();
}

class _DateRangeGraphPageState extends State<DateRangeGraphPage> {
  String selectedButton = 'Custom'; // Default for custom range
  String selectedGraphType = 'Revenue'; // Default graph type
  late List<ChartData> chartData;
  late List<ChartData> filteredData;

  @override
  void initState() {
    super.initState();
    chartData = dateWiseRevenue
        .map((entry) => ChartData(
            entry['date'], entry['revenue'], entry['users_onboarded']))
        .toList();
    filteredData = getFilteredDataByRange(widget.startDate, widget.endDate);
  }

  List<ChartData> getFilteredDataByRange(DateTime startDate, DateTime endDate) {
    return chartData.where((data) {
      DateTime dataDate = DateTime.parse(data.date);
      return dataDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          dataDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  void switchGraphType(String type) {
    setState(() {
      selectedGraphType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis"),
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        // actions: [
        //   DropdownButton<String>(
        //     value: selectedGraphType,
        //     dropdownColor: Colors.black,
        //     icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        //     underline: const SizedBox(),
        //     items: ['Revenue', 'Users Onboarded'].map((String value) {
        //       return DropdownMenuItem<String>(
        //         value: value,
        //         child: Text(
        //           value,
        //           style: const TextStyle(color: Colors.white),
        //         ),
        //       );
        //     }).toList(),
        //     onChanged: (String? newValue) {
        //       if (newValue != null) switchGraphType(newValue);
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(
                    text: selectedGraphType == 'Revenue'
                        ? 'Revenue Analysis'
                        : 'User Onboarding Analysis'),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: filteredData,
                    xValueMapper: (ChartData data, _) => data.date,
                    yValueMapper: (ChartData data, _) =>
                        selectedGraphType == 'Revenue'
                            ? data.revenue
                            : data.usersOnboarded,
                    color: selectedThemeData.primaryColor,
                    markerSettings: const MarkerSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

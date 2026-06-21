import 'package:admin_ott/app/provider/promoterGraphProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class CustomBarGraph extends StatefulWidget {
  const CustomBarGraph({Key? key}) : super(key: key);

  @override
  State<CustomBarGraph> createState() => _CustomBarGraphState();
}

class _CustomBarGraphState extends State<CustomBarGraph> {
  @override
  void initState() {
    super.initState();
    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    final provider = Provider.of<PromoterGraphProvider>(context, listen: false);
    await provider.fetchAllPromoterRevenueGraph(
      provider.startDate,
      provider.endDate,
      _getSelectedTimeRange(provider),
    );
  }

  int _getSelectedTimeRange(PromoterGraphProvider provider) {
    switch (provider.activeButton) {
      case '7D':
        return 0;
      case 'Month':
        return 1;
      case 'Year':
        return 2;
      default:
        return 3; // Custom date range
    }
  }

  void _setDateRange(String label, int days) async {
    final provider = Provider.of<PromoterGraphProvider>(context, listen: false);
    setState(() {
      provider.activeButton = label;
      provider.selectedDateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: days)),
        end: DateTime.now(),
      );
      provider.startDate =
          DateFormat('yyyy-MM-dd').format(provider.selectedDateRange!.start);
      provider.endDate =
          DateFormat('yyyy-MM-dd').format(provider.selectedDateRange!.end);
    });
    await _fetchGraphData();
  }

  Future<void> _pickDateRange() async {
    final provider = Provider.of<PromoterGraphProvider>(context, listen: false);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        provider.activeButton = 'Custom';
        provider.selectedDateRange = picked;
        provider.startDate = DateFormat('yyyy-MM-dd').format(picked.start);
        provider.endDate = DateFormat('yyyy-MM-dd').format(picked.end);
      });
      await _fetchGraphData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      body: Consumer<PromoterGraphProvider>(
        builder: (context, provider, child) {
          return Card(
            color: selectedThemeData.cardColor,
            child: Column(
              children: [
                _buildDateInfo(provider, selectedThemeData),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: provider.filteredDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: AppSpinner());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No data available for the selected range'),
                        );
                      }

                      final filteredData = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            interval: 1,
                            labelRotation: -45,
                            majorGridLines: const MajorGridLines(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            numberFormat: NumberFormat.compact(),
                          ),
                          legend: Legend(isVisible: true),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <CartesianSeries<Map<String, dynamic>, String>>[
                            _buildColumnSeries(
                              filteredData,
                              'State Revenue',
                              'State Level',
                              const Color(0xFF4A4A4A),
                            ),
                            _buildColumnSeries(
                              filteredData,
                              'District Revenue',
                              'District Level',
                              const Color(0xFF787878),
                            ),
                            _buildColumnSeries(
                              filteredData,
                              'Taluka Revenue',
                              'Taluka Level',
                              const Color(0xFFA0A0A0),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _buildFilterOptions(selectedThemeData, provider),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateInfo(
      PromoterGraphProvider provider, ThemeData selectedThemeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Start Date: ${provider.startDate}",
            style: selectedThemeData.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "End Date: ${provider.endDate}",
            style: selectedThemeData.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  ColumnSeries<Map<String, dynamic>, String> _buildColumnSeries(
      List<Map<String, dynamic>> data, String key, String name, Color color) {
    return ColumnSeries<Map<String, dynamic>, String>(
      name: name,
      color: color,
      dataSource: data,
      xValueMapper: (data, _) => data['date'],
      yValueMapper: (data, _) => (data[key] ?? 0).toDouble(),
    );
  }

  Widget _buildFilterOptions(
      ThemeData selectedThemeData, PromoterGraphProvider provider) {
    final filterOptions = [
      {'label': '7D', 'days': 7},
      {'label': 'Month', 'days': 30},
      {'label': 'Year', 'days': 365},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...filterOptions.map(
              (range) => _buildFilterButton(
            range['label'] as String,
            range['days'] as int,
            selectedThemeData,
            provider,
          ),
        ),
        _buildFilterButton('Custom', 0, selectedThemeData, provider, isCustom: true),
      ],
    );
  }

  Widget _buildFilterButton(String label, int days, ThemeData selectedThemeData,
      PromoterGraphProvider provider,
      {bool isCustom = false}) {
    final isActive = provider.activeButton == label;
    return GestureDetector(
      onTap: isCustom ? _pickDateRange : () => _setDateRange(label, days),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? selectedThemeData.primaryColor
              : selectedThemeData.cardColor,
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

import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/add_mediaHouse.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/media_house_profile.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

import 'component/media_house_table.dart';

class ManageMediaHousePage extends StatefulWidget {
  const ManageMediaHousePage({super.key});

  @override
  State<ManageMediaHousePage> createState() => _ManageMediaHousePageState();
}

class _ManageMediaHousePageState extends State<ManageMediaHousePage> {
  String _selectedPeriod = 'Week';
  late MediaHouseProvider mediaHouseProvider;

  @override
  void initState() {
    super.initState();
    Provider.of<MediaHouseProvider>(context, listen: false)
        .fetchMediaHouseCountGraph(0);
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  void _updateChart(String period, MediaHouseProvider provider) {
    if (period == "Week") {
      provider.fetchMediaHouseCountGraph(0);
    } else if (period == "Month") {
      provider.fetchMediaHouseCountGraph(1);
    } else {
      provider.fetchMediaHouseCountGraph(2);
    }
    setState(() {
      _selectedPeriod = period;
    });
  }

  Future<void> _showAddMediaHouseDialog(MediaHouseProvider provider) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMediaHouseWidget(),
      ),
    );

    // Refresh user list if a new user was added
    if (result == true) {
      Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouse();
    }
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required int index,
  }) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return SizedBox(
      width: 250,
      height: 90,
      child: Card(
        color: selectedThemeData.cardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selectedThemeData.canvasColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: selectedThemeData.primaryColor,
              ),
            ),
          ],
          /*  title:
          subtitle:
          trailing: IconButton(
            onPressed: () {
              // _showGraphPopup(index);
            },
            icon: Icon(
              Icons.bar_chart_rounded,
            ),
            color: selectedThemeData.primaryColor,
          ),*/
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ResponsiveWidget.isMobile(context)
              ? Column(
                  children: [
                    // _buildStatisticCard(
                    //   title: 'Total Media Houses',
                    //   value: provider.mediaHouseList.length.toString(),
                    //   icon: Icons.shopping_cart,
                    //   index: 1,
                    // ),
                    CustomTextField(
                      controller: provider.searchMediaHouseController,
                      hintText: 'Search Media Houses',
                      textInputType: TextInputType.text,
                      prefixIcon: Icon(Icons.search_sharp),
                    ),
                    provider.filteredMediaHouseList.isEmpty
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "The media house list is empty because no media houses have been added yet.",
                                style: TextStyle(
                                    color: selectedThemeData.primaryColor),
                              ),
                            ],
                          ))
                        : Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: provider.filteredMediaHouseList.length,
                              itemBuilder: (context, index) {
                                MediaHouse mediaHouse =
                                    provider.filteredMediaHouseList[index];
                                return ProfilePageCard(mediaHouse, provider);
                              },
                            ),
                          )
                  ],
                )
              : Column(
                  children: [
                    Container(
                      height: 100,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatisticCard(
                            title: 'Total Media Houses',
                            value: provider.mediaHouseList.length.toString(),
                            icon: Icons.shopping_cart,
                            index: 1,
                          ),
                          SizedBox(
                            width: 500,
                            child: CustomTextField(
                              controller: provider.searchMediaHouseController,
                              hintText: 'Search Media Houses',
                              textInputType: TextInputType.text,
                              prefixIcon: Icon(Icons.search_sharp),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: provider.filteredMediaHouseList.isEmpty
                          ? Center(
                              child: Text(
                              "The media house list is empty because no media houses have been added yet..",
                              style: TextStyle(
                                  color: selectedThemeData.primaryColor),
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.filteredMediaHouseList.length,
                              itemBuilder: (context, index) {
                                MediaHouse mediaHouse =
                                    provider.filteredMediaHouseList[index];
                                return ProfilePageCard(mediaHouse, provider);
                              },
                            ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                _updateChart('Week', provider),
                                            child: Text(
                                              'Week',
                                              style: TextStyle(
                                                color: _selectedPeriod == 'Week'
                                                    ? selectedThemeData
                                                        .primaryColor
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                _updateChart('Month', provider),
                                            child: Text(
                                              'Month',
                                              style: TextStyle(
                                                color:
                                                    _selectedPeriod == 'Month'
                                                        ? selectedThemeData
                                                            .primaryColor
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                _updateChart('Year', provider),
                                            child: Text(
                                              'Year',
                                              style: TextStyle(
                                                color: _selectedPeriod == 'Year'
                                                    ? selectedThemeData
                                                        .primaryColor
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: selectedThemeData.cardColor,
                                        child: SfCartesianChart(
                                          title: ChartTitle(
                                            text:
                                                'Media Houses Onboarded ($_selectedPeriod View)',
                                          ),
                                          tooltipBehavior:
                                              TooltipBehavior(enable: true),
                                          series: <CartesianSeries>[
                                            LineSeries<LineChartData, String>(
                                              dataSource: provider.chartData,
                                              xValueMapper:
                                                  (LineChartData data, _) =>
                                                      data.label,
                                              yValueMapper:
                                                  (LineChartData data, _) =>
                                                      data.value,
                                              name: 'Onboarded',
                                              color: selectedThemeData
                                                  .primaryColor,
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                isVisible: true,
                                                labelAlignment:
                                                    ChartDataLabelAlignment.top,
                                                textStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              markerSettings: MarkerSettings(
                                                  isVisible: true),
                                            ),
                                          ],
                                          primaryXAxis: CategoryAxis(),
                                          primaryYAxis: NumericAxis(
                                            labelFormat: '{value}',
                                            title: AxisTitle(
                                                text: 'Total Media Houses'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              child: Column(
                                children: [
                                  Expanded(
                                      child: MediaHouseTable(
                                          mediaHouseData:
                                              provider.filteredMediaHouseList))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            _showAddMediaHouseDialog(provider);
          },
          child: Container(
            height: 40,
            width: 170,
            decoration: BoxDecoration(
              color: selectedThemeData.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Add media house',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ChartData {
  ChartData(this.category, this.value);

  final String category;
  final int value;
}

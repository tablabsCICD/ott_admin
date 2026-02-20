import 'package:admin_ott/app/provider/dashboardProvider.dart';
import 'package:admin_ott/app/provider/fullscreenProvider.dart';
import 'package:admin_ott/app/provider/userGraphProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/contentApprovalWidget.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/media_house_onboardGraph.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/pieChart.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/MediaHouseApprovalsWidget.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/MediaHouseSearch.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/PromoterApprovalsWidget.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/PromoterSearch.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/content_approved_graph.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/managers_onboarded_graph.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/revenue_chart.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/revenue_graph.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/toggleButton.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTimeRange = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final fullScreenProvider = Provider.of<FullScreenProvider>(context);

    return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistic Cards
                    Consumer<DashboardProvider>(
                        builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // Statistic Cards to display
                          ResponsiveWidget.isMobile(context)
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildStatisticCard(
                                            title: 'Total Users',
                                            value: provider.dashboardData
                                                    .totalUserCount
                                                    ?.toString() ??
                                                '0',
                                            icon: Icons.people,
                                            index: 0,
                                          ),
                                          _buildStatisticCard(
                                            title: 'Total Purchases',
                                            value: provider
                                                    .dashboardData.userContent
                                                    ?.toString() ??
                                                '0',
                                            icon: Icons.shopping_cart,
                                            index: 1,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildStatisticCard(
                                            title: 'Total Promoters',
                                            value: provider
                                                    .dashboardData.totalPromoter
                                                    ?.toString() ??
                                                '0',
                                            icon: Icons.supervisor_account,
                                            index: 2,
                                          ),
                                          _buildStatisticCard(
                                            title: 'Content Approved',
                                            value: provider
                                                    .dashboardData.totalContent
                                                    ?.toString() ??
                                                '0',
                                            icon: Icons.check_circle,
                                            index: 3,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatisticCard(
                                        title: 'Total Users',
                                        value: provider
                                                .dashboardData.totalUserCount
                                                ?.toString() ??
                                            '0',
                                        icon: Icons.people,
                                        index: 0,
                                      ),
                                      _buildStatisticCard(
                                        title: 'Total Purchases',
                                        value: provider
                                                .dashboardData.userContent
                                                ?.toString() ??
                                            '0',
                                        icon: Icons.shopping_cart,
                                        index: 1,
                                      ),
                                      _buildStatisticCard(
                                        title: 'Total Media Houses',
                                        value: provider
                                                .dashboardData.totalMediaHouses
                                                ?.toString() ??
                                            '0',
                                        icon: Icons.shopping_cart,
                                        index: 4,
                                      ),
                                      _buildStatisticCard(
                                        title: 'Total Promoters',
                                        value: provider
                                                .dashboardData.totalPromoter
                                                ?.toString() ??
                                            '0',
                                        icon: Icons.supervisor_account,
                                        index: 2,
                                      ),
                                      _buildStatisticCard(
                                        title: 'Content Approved',
                                        value: provider
                                                .dashboardData.totalContent
                                                ?.toString() ??
                                            '0',
                                        icon: Icons.check_circle,
                                        index: 3,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      );
                    }),
                    Divider(
                      color: selectedThemeData.cardColor,
                    ),

                    // Cards for Requests (Responsive Layout)
                    ResponsiveWidget.isMobile(context)
                        ? SizedBox()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: Container(
                                    height: 450,
                                    decoration: BoxDecoration(
                                      color: selectedThemeData.cardColor,
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    child: RevenueChart(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                    height: 450,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: MediaHouseSearch(),
                                          // _searchMediaHouseProgress(context),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: PromoterSearch(),
                                          //_searchPromoterProgress(context),
                                        ),
                                      ],
                                    )),
                              )
                            ],
                          ),
                    SizedBox(
                      height: 10,
                    ),

                    ResponsiveWidget.isMobile(context) //// for mobile screen
                        ? SizedBox(
                            height: 900,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 450,
                                    child: _buildRequestCard(context,
                                        title: 'Content Approvals',
                                        child:
                                            ContentApprovalWidget() /////////// add list of pending movies of that perticular media house
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 450,
                                    child: _buildRequestCard(
                                      context,
                                      title: 'Media House Approvals',
                                      child: MediaHouseApprovalsWidget(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 450,
                                    child: _buildRequestCard(
                                      context,
                                      title: 'Promoter Approvals',
                                      child: PromoterApprovalsWidget(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            // for web n tablet screen
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 450,
                                  child: _buildRequestCard(context,
                                      title: 'Content Approvals',
                                      child: ContentApprovalWidget()),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 450,
                                  child: _buildRequestCard(
                                    context,
                                    title: 'Media House Approvals',
                                    child: MediaHouseApprovalsWidget(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 450,
                                  child: _buildRequestCard(
                                    context,
                                    title: 'Promoter Approvals',
                                    child: PromoterApprovalsWidget(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    SizedBox(
                      height: ResponsiveWidget.isMobile(context) ? 10 : 10,
                    ),
                    ResponsiveWidget.isDesktop(context)
                        ? Consumer<DashboardProvider>(
                            builder: (context, provider, child) {
                            return Row(
                              // for web n tablet screen
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 400,
                                    child: Card(
                                      color: selectedThemeData.cardColor,
                                      child: PieChartClass(
                                          title: 'Average Revenue',
                                          chartDataList:
                                              provider.revenueChartDataList ??
                                                  []),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedThemeData.cardColor,
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    height: 400,
                                    child: Card(
                                      color: selectedThemeData.cardColor,
                                      child: PieChartClass(
                                          title: 'Content Types',
                                          chartDataList:
                                              provider.chartDataList ?? []),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(flex: 1, child: SizedBox()),
                              ],
                            );
                          })
                        : SizedBox(),
                  ],
                ),
              ),
            ),
            fullScreenProvider
                    .isFullScreen //display revenue graph on fullsscreen
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                      ),
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedThemeData.cardColor,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Center(child: RevenueChart()),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ));
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required int index,
  }) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return SizedBox(
      // height: 90,
      width: 250,
      child: Card(
        color: selectedThemeData.cardColor,
        child: ListTile(
          // leading: Icon(
          //   icon,
          //   color: selectedThemeData.primaryColor,
          // ),
          title: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selectedThemeData.canvasColor,
              ),
            ),
          ),
          subtitle: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: selectedThemeData.primaryColor,
              ),
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              _showGraphPopup(index);
            },
            icon: Icon(
              Icons.bar_chart_rounded,
            ),
            color: selectedThemeData.primaryColor,
          ),
        ),
      ),
    );
  }

  void _showGraphPopup(int index) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                          color: selectedThemeData.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_ios_new,
                                  color: selectedThemeData.primaryColor),
                              const Text(' Back to Dashboard '),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGraphContent(
                        index, setState), // Display the graph for selected card
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGraphContent(int graphIndex, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (graphIndex == 0) ...[
          _buildGraphHeader('Total Users Onboarded Graph',
              'This graph represents the total users onboarded for the selected time range.'),
          UsersOnboardedGraph(selectedTimeRange: _selectedTimeRange),
        ] else if (graphIndex == 1) ...[
          _buildGraphHeader('Total Revenue Graph',
              'This graph represents the total revenue for the selected time range.'),
          RevenueGraph(
            selectedTimeRange: _selectedTimeRange,
            height: ResponsiveWidget.isMobile(context) ? 300 : 350,
          ),
        ] else if (graphIndex == 2) ...[
          _buildGraphHeader('Managers Onboarded Graph',
              'This graph represents the managers onboarded for the selected time range.'),
          ManagersOnboardedGraph(selectedTimeRange: _selectedTimeRange),
        ] else if (graphIndex == 4) ...[
          _buildGraphHeader('MediaHouse Onboarded Graph',
              'This graph represents the media house onboarded for the selected time range.'),
          MediaHouseOnboardgraph(selectedTimeRange: _selectedTimeRange),
        ] else if (graphIndex == 3) ...[
          _buildGraphHeader('Content Approved Graph',
              'This graph represents the total content approved for the selected time range.'),
          ContentApprovedGraph(selectedTimeRange: _selectedTimeRange),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: _buildToggleButton(
              graphIndex,
              (index) {
                _handleToggleChange(index, graphIndex, setState);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleToggleChange(int index, int graphIndex, StateSetter setState) {
    setState(() {
      _selectedTimeRange = index;
    });
    callApi(index, graphIndex);
  }

  Widget _buildGraphHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildToggleButton(int graphIndex, void Function(int) onToggle) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 50,
      width: 200,
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context, listen: false)
            .getTheme
            .cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ToggleButtonWidget(
              label: 'Week',
              index: 0,
              selectedIndex: _selectedTimeRange,
              onToggle: onToggle),
          ToggleButtonWidget(
              label: 'Month',
              index: 1,
              selectedIndex: _selectedTimeRange,
              onToggle: onToggle),
          ToggleButtonWidget(
              label: 'Year',
              index: 2,
              selectedIndex: _selectedTimeRange,
              onToggle: onToggle),
        ],
      ),
    );
  }

  void callApi(int index, int graphIndex) {
    final userGraphProvider =
        Provider.of<UserGraphProvider>(context, listen: false);

    switch (graphIndex) {
      case 0:
        print("Fetching User Graph Data for time range $index");
        userGraphProvider.fetchUserGraph(index);
        break;
      case 1:
        print("Fetching Revenue Graph Data for time range $index");
        userGraphProvider.fetchPurchaseGraph(index);
        break;
      case 2:
        print("Fetching Manager Graph Data for time range $index");
        userGraphProvider.fetchPromoterCountGraph(index);
        break;
      case 3:
        print("Fetching Content Approved Graph Data for time range $index");
        userGraphProvider.fetchApprovedContentGraph(index);
        break;
      case 4:
        print("Fetching Media House Graph Data for time range $index");
        userGraphProvider.fetchMediaHouseCountGraph(index);
        break;
      default:
        print("Invalid graph index $graphIndex");
    }
  }

  Widget _buildRequestCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: selectedThemeData.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedThemeData.cardColor,
          width: 2,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedThemeData.primaryColor,
                ),
              ),
              Spacer(),
              // GestureDetector(
              //   onTap: () {
              //     ontap_see_all;
              //   },
              //   child: Text('See All',
              //       style: TextStyle(color: selectedThemeData.primaryColor)),
              // ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

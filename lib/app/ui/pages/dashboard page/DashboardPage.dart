import 'package:admin_ott/app/provider/dashboardProvider.dart';
import 'package:admin_ott/app/provider/fullscreenProvider.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/provider/userGraphProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/ShortsApprovalsWidget.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/contentApprovalWidget.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/media_house_onboardGraph.dart';
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
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTimeRange = 0; // 0: Week, 1: Month, 2: Year
  int? _revenueTouchedIndex;
  int? _contentTouchedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoProvider>(context, listen: false)
          .fetchMoviesByStatusAndMediaHouseId("PENDING", 0);
      Provider.of<MediaHouseProvider>(context, listen: false)
          .fetchMediaHouseByStatus("PENDING");
      Provider.of<PromoterProvider>(context, listen: false)
          .fetchPromotersByStatus("PENDING");
      Provider.of<ShortsProvider>(context, listen: false)
          .fetchShortsByStatus(status: "PENDING");
    });
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

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final fullScreenProvider = Provider.of<FullScreenProvider>(context);
    final showContentApprovals = context
        .watch<VideoProvider>()
        .filteredContentListByMediaHouse
        .isNotEmpty;
    final showMediaHouseApprovals = context
        .watch<MediaHouseProvider>()
        .filteredMediaHouseListByStatus
        .isNotEmpty;
    final showPromoterApprovals =
        context.watch<PromoterProvider>().filteredPromotersByStatus.isNotEmpty;
    final shortsProvider = context.watch<ShortsProvider>();
    final showShortsApprovals = shortsProvider.isStatusListLoading ||
        shortsProvider.filteredShortsByStatus.isNotEmpty;

    final allApprovalsPresent = showContentApprovals &&
        showMediaHouseApprovals &&
        showPromoterApprovals &&
        showShortsApprovals;

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
                              ? _buildMobileStatsBento(provider)
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

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ResponsiveWidget.isMobile(
                              context) //// for mobile screen
                          ? Column(
                              children: [
                                if (showContentApprovals)
                                  SizedBox(
                                    height: 250,
                                    child: _buildRequestCard(
                                      context,
                                      title: 'Content Approvals',
                                      child: ContentApprovalWidget(),
                                    ),
                                  ),
                                if (showContentApprovals &&
                                    (showMediaHouseApprovals ||
                                        showPromoterApprovals ||
                                        showShortsApprovals))
                                  const SizedBox(height: 10),
                                if (showMediaHouseApprovals)
                                  SizedBox(
                                    height: 250,
                                    child: _buildRequestCard(
                                      context,
                                      title: 'Media House Approvals',
                                      child: MediaHouseApprovalsWidget(),
                                    ),
                                  ),
                                if (showMediaHouseApprovals &&
                                    (showPromoterApprovals ||
                                        showShortsApprovals))
                                  const SizedBox(height: 10),
                                if (showPromoterApprovals)
                                  SizedBox(
                                    height: 250,
                                    child: _buildRequestCard(
                                      context,
                                      title: 'Promoter Approvals',
                                      child: PromoterApprovalsWidget(),
                                    ),
                                  ),
                                if (showPromoterApprovals &&
                                    showShortsApprovals)
                                  const SizedBox(height: 10),
                                if (showShortsApprovals)
                                  SizedBox(
                                    height: 250,
                                    child: _buildRequestCard(
                                      context,
                                      title: 'Shorts Approvals',
                                      child: ShortsApprovalsWidget(),
                                    ),
                                  ),
                              ],
                            )
                          : allApprovalsPresent // this condition is also used in _buildInsightsSection  to manage space when all 4 approvals are present, also used in
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 450,
                                        child: _buildRequestCard(
                                          context,
                                          title: 'Content Approvals',
                                          child: ContentApprovalWidget(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 450,
                                        child: _buildRequestCard(
                                          context,
                                          title: 'Shorts Approvals',
                                          child: const ShortsApprovalsWidget(),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Row(
                                  children: [
                                    if (showContentApprovals)
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 450,
                                          child: _buildRequestCard(
                                            context,
                                            title: 'Content Approvals',
                                            child: ContentApprovalWidget(),
                                          ),
                                        ),
                                      ),
                                    if (showContentApprovals &&
                                        (showMediaHouseApprovals ||
                                            showPromoterApprovals ||
                                            showShortsApprovals))
                                      const SizedBox(width: 10),
                                    if (showMediaHouseApprovals)
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
                                    if (showMediaHouseApprovals &&
                                        (showPromoterApprovals ||
                                            showShortsApprovals))
                                      const SizedBox(width: 10),
                                    if (showPromoterApprovals)
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
                                    if (showPromoterApprovals &&
                                        showShortsApprovals)
                                      const SizedBox(width: 10),
                                    if (showShortsApprovals)
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 450,
                                          child: _buildRequestCard(
                                            context,
                                            title: 'Shorts Approvals',
                                            child:
                                                const ShortsApprovalsWidget(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ResponsiveWidget.isMobile(context)
                        ? SizedBox(
                            height: 350,
                            child: Card(
                                color: Theme.of(context).cardColor,
                                child: RevenueChart()),
                          )
                        : SizedBox(),

                    Consumer<DashboardProvider>(
                        builder: (context, provider, _) {
                      return _buildInsightsSection(
                          context, provider, allApprovalsPresent);
                    }),
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
      width: ResponsiveWidget.isMobile(context) ? double.infinity : 250,
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

  Widget _buildMobileStatsBento(DashboardProvider provider) {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        StaggeredGridTile.fit(
          crossAxisCellCount: 2,
          child: _buildBentoCard(
            title: 'Total Users',
            value: provider.dashboardData.totalUserCount?.toString() ?? '0',
            icon: Icons.people,
            index: 0,
            big: true,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildBentoCard(
            title: 'Total Purchases',
            value: provider.dashboardData.userContent?.toString() ?? '0',
            icon: Icons.shopping_cart,
            index: 1,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildBentoCard(
            title: 'Total Promoters',
            value: provider.dashboardData.totalPromoter?.toString() ?? '0',
            icon: Icons.supervisor_account,
            index: 2,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildBentoCard(
            title: 'Content Approved',
            value: provider.dashboardData.totalContent?.toString() ?? '0',
            icon: Icons.check_circle,
            index: 3,
          ),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: _buildBentoCard(
            title: 'Total Media Houses',
            value: provider.dashboardData.totalMediaHouses?.toString() ?? '0',
            icon: Icons.home_work,
            index: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required IconData icon,
    required int index,
    bool big = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.cardColor,
          width: 2,
        ),
      ),
      child: GestureDetector(
          // borderRadius: BorderRadius.circular(18),
          onTap: () => _showGraphPopup(index),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.canvasColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.primaryColor, size: 24),
                    const Spacer(),
                    Icon(Icons.bar_chart_rounded,
                        color: theme.primaryColor, size: 20),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: big ? 28 : 22,
                    fontWeight: FontWeight.w700,
                    color: theme.canvasColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.canvasColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildInsightsSection(BuildContext context, DashboardProvider provider,
      bool allApprovalsPresent) {
    final isMobile = ResponsiveWidget.isMobile(context);
    final revenueData = _buildRevenueSplitData();
    final contentData = _buildContentTypeData(provider);

    if (isMobile) {
      return Column(
        children: [
          _buildInsightCard(
            title: 'Average Revenue',
            subtitle: 'Revenue split by content category',
            totalLabel: 'Total Revenue',
            totalValue: '1000',
            data: revenueData,
            chartKey: 'revenue',
            isCurrency: true,
          ),
          const SizedBox(height: 10),
          _buildInsightCard(
            title: 'Content Types',
            subtitle: 'Distribution of approved content',
            totalLabel: 'Total Units',
            totalValue: provider.contentTypeTotal > 0
                ? provider.contentTypeTotal.toString()
                : contentData
                    .fold<num>(0, (sum, item) => sum + (item['value'] as num))
                    .toStringAsFixed(0),
            data: contentData,
            chartKey: 'content',
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        allApprovalsPresent
            ? Expanded(
                flex: 1,
                child: SizedBox(
                  height: 450,
                  child: _buildRequestCard(
                    context,
                    title: 'Media House Approvals',
                    child: MediaHouseApprovalsWidget(),
                  ),
                ),
              )
            : SizedBox(),
        allApprovalsPresent ? const SizedBox(width: 10) : SizedBox(),
        Expanded(
          flex: 1,
          child: _buildInsightCard(
            title: 'Average Revenue',
            subtitle: 'Revenue split by content category',
            totalLabel: 'Total Revenue',
            totalValue: '1000',
            data: revenueData,
            chartKey: 'revenue',
            isCurrency: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: _buildInsightCard(
            title: 'Content Types',
            subtitle: 'Distribution of approved content',
            totalLabel: 'Total Units',
            totalValue: provider.contentTypeTotal > 0
                ? provider.contentTypeTotal.toString()
                : contentData
                    .fold<num>(0, (sum, item) => sum + (item['value'] as num))
                    .toStringAsFixed(0),
            data: contentData,
            chartKey: 'content',
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildRevenueSplitData() {
    return [
      {
        'title': 'Movie Revenue',
        'revenue': 750.0,
        'value': 75.0,
        'percentText': '75%',
      },
      {
        'title': 'Series Revenue',
        'revenue': 127.0,
        'value': 12.7,
        'percentText': '12.7%',
      },
      {
        'title': 'Short Revenue',
        'revenue': 123.0,
        'value': 12.3,
        'percentText': '12.3%',
      },
    ];
  }

  List<Map<String, dynamic>> _buildContentTypeData(DashboardProvider provider) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final primary = theme.primaryColor;

    if ((provider.chartDataList ?? []).isNotEmpty) {
      final mapped = provider.chartDataList!.take(4).map((item) {
        final value = (item['value'] as num?)?.toDouble() ?? 0.0;
        return {
          'title': item['title'] ?? 'Unknown',
          'value': value,
          'percentText':
              item['percentText']?.toString() ?? '${value.toStringAsFixed(1)}%',
          'count': (item['count'] as num?)?.toInt(),
        };
      }).toList();
      return mapped;
    }

    return [
      {
        'title': 'Movies',
        'value': 52.0,
        'percentText': '52%',
        'color': primary,
      },
      {
        'title': 'Series',
        'value': 28.0,
        'percentText': '28%',
        'color':
            Color.alphaBlend(primary.withValues(alpha: 0.45), Colors.green),
      },
      {
        'title': 'Shorts',
        'value': 20.0,
        'percentText': '20%',
        'color':
            Color.alphaBlend(primary.withValues(alpha: 0.5), Colors.orange),
      },
    ];
  }

  Widget _buildInsightCard({
    required String title,
    required String subtitle,
    required String totalLabel,
    required String totalValue,
    required List<Map<String, dynamic>> data,
    required String chartKey,
    bool isCurrency = false,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final total =
        data.fold<num>(0, (sum, item) => sum + (item['value'] as num));
    final touchedIndex =
        chartKey == 'revenue' ? _revenueTouchedIndex : _contentTouchedIndex;

    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 430;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.canvasColor.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 14),
            compact
                ? Column(
                    children: [
                      _buildInteractiveChart(
                        data: data,
                        theme: theme,
                        touchedIndex: touchedIndex,
                        totalValue: totalValue,
                        chartKey: chartKey,
                        total: total,
                      ),
                      const SizedBox(height: 12),
                      _buildInsightSummary(
                        theme: theme,
                        totalLabel: totalLabel,
                        totalValue: totalValue,
                        total: total,
                        isCurrency: isCurrency,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildInteractiveChart(
                          data: data,
                          theme: theme,
                          touchedIndex: touchedIndex,
                          totalValue: totalValue,
                          chartKey: chartKey,
                          total: total,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInsightSummary(
                          theme: theme,
                          totalLabel: totalLabel,
                          totalValue: totalValue,
                          total: total,
                          isCurrency: isCurrency,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(data.length, (index) {
                final item = data[index];
                final tileColor = _sliceColorForIndex(
                  theme.primaryColor,
                  index,
                );
                return _buildDataMetricTile(
                  theme: theme,
                  color: tileColor,
                  title: item['title'].toString(),
                  percentText: item['percentText']?.toString() ?? '',
                  revenueText: isCurrency
                      ? '₹${(item['revenue'] as num).toStringAsFixed(0)}'
                      : ((item['count'] as int?) != null
                          ? '${item['count']} items'
                          : null),
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInteractiveChart({
    required List<Map<String, dynamic>> data,
    required ThemeData theme,
    required int? touchedIndex,
    required String totalValue,
    required String chartKey,
    required num total,
  }) {
    final hasValidTouchedIndex =
        touchedIndex != null && touchedIndex >= 0 && touchedIndex < data.length;

    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 5,
              centerSpaceRadius: 49,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final section = response?.touchedSection;
                  final index = section?.touchedSectionIndex ?? -1;
                  final isValidIndex = index >= 0 && index < data.length;

                  if (!event.isInterestedForInteractions || !isValidIndex) {
                    setState(() {
                      if (chartKey == 'revenue') {
                        _revenueTouchedIndex = null;
                      } else {
                        _contentTouchedIndex = null;
                      }
                    });
                    return;
                  }
                  setState(() {
                    if (chartKey == 'revenue') {
                      _revenueTouchedIndex = index;
                    } else {
                      _contentTouchedIndex = index;
                    }
                  });
                },
              ),
              sections: List.generate(data.length, (index) {
                final value = (data[index]['value'] as num).toDouble();
                final highlighted = touchedIndex == index;
                return PieChartSectionData(
                  value: value,
                  color: theme.primaryColor,
                  title: (data[index]['title'] ?? '').toString(),
                  titleStyle: TextStyle(
                    fontSize: highlighted ? 12 : 0,
                    fontWeight: FontWeight.w600,
                    color: theme.canvasColor,
                  ),
                  radius: highlighted ? 40 : 34,
                );
              }),
            ),
          ),
          Text(
            hasValidTouchedIndex
                ? data[touchedIndex]['percentText'].toString()
                : totalValue, //total.toStringAsFixed(0),
            style: TextStyle(
              fontSize: hasValidTouchedIndex ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: theme.canvasColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSummary({
    required ThemeData theme,
    required String totalLabel,
    required String totalValue,
    required num total,
    required bool isCurrency,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalLabel,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isCurrency ? '₹$totalValue' : totalValue,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.canvasColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Chart Total: ${total.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 11,
              color: theme.canvasColor.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_rounded,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hover or tap on chart slices to inspect segments.',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.canvasColor.withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataMetricTile({
    required ThemeData theme,
    required Color color,
    required String title,
    required String percentText,
    String? revenueText,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 125, maxWidth: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.canvasColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  percentText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                if (revenueText != null)
                  Text(
                    revenueText,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.canvasColor.withValues(alpha: 0.72),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _sliceColorForIndex(Color primary, int index) {
    const alphas = [0.95, 0.75, 0.55, 0.38, 0.24];
    return primary.withValues(alpha: alphas[index % alphas.length]);
  }
}

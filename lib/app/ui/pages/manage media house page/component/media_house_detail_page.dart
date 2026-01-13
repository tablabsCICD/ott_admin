import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/contentApprovalWidget.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/buildSummaryCard.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/mediaHouse_content_approval.dart';
import 'package:admin_ott/app/ui/pages/media%20house%20detail%20page/component/settlementCards.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/stat_tile.dart';
import 'package:admin_ott/app/widgets/CustomLineGraph.dart';
import 'package:admin_ott/app/ui/pages/media%20house%20detail%20page/component/TopMoviesLineGraph.dart';
import 'package:admin_ott/data/repositories/settlement_list.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/utils/sharepreferences.dart';
import '../../dashboard page/component/mediaHouse_profile_page.dart';
import '../../manage video page/component/movie_details_dialog.dart.dart';

class MediaHouseDetailPage extends StatefulWidget {
  final MediaHouse mediaHouse;
  MediaHouseDetailPage(
      {super.key, required this.mediaHouse});

  @override
  State<MediaHouseDetailPage> createState() => _MediaHouseDetailPageState();
}

class _MediaHouseDetailPageState extends State<MediaHouseDetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   getData();
  }

  getData() async {
    final localSharePreferences = LocalSharePreferences();
    localSharePreferences.setString( SharedPreferencesConstant.currentMediaHouseId, widget.mediaHouse.id!.toString());
    await Provider.of<MediaHouseProvider>(context, listen: false).fetchMoviesByMediaHouseId(widget.mediaHouse.id!);
    await Provider.of<MediaHouseProvider>(context, listen: false).fetchMoviesByStatusAndMediaHouseId("PENDING",widget.mediaHouse.id!);
    await Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouseDashboardData(widget.mediaHouse.id!);

  }
  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {

      debugPrint("contentList:::" +
          provider.filteredContentListByMediaHouse.length.toString());
      return Scaffold(
        appBar: AppBar(

          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.analytics_outlined,
                  color: selectedThemeData.canvasColor,
                ),
                onPressed: () {
                  /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RevenueAnalyticsPage(
                      contentList: mediaHouse.mediaHouseName??'' ?? [],
                    ),
                  ),
                );*/
                },
              ),
            ),
          ],
          backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Card(
                              color: selectedThemeData.cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: widget.mediaHouse.logo !=
                                              null
                                          ? NetworkImage(
                                              widget.mediaHouse.logo!)
                                          : const AssetImage(
                                                  'assets/default_profile_pic.png')
                                              as ImageProvider,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      widget.mediaHouse.mediaHouseName ??
                                          'Unknown Name',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    //const SizedBox(height: 5),
                                    Text(
                                      widget.mediaHouse.discription ??
                                          'No description available.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    //const SizedBox(height: 5),
                                    Text(
                                      widget.mediaHouse.contactNumber ??
                                          'Not available.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    //const SizedBox(height: 5),
                                    Text(
                                      widget.mediaHouse.email ??
                                          'Not available.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    InkWell(
                                      onTap: (){

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MediaHouseProfilePage(mediaHouse: widget.mediaHouse),
                                          ),
                                        );
                                      },
                                      child: Text(

                                            'View Full Detail',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.blue),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selectedThemeData.canvasColor
                                                .withOpacity(
                                              0.3,
                                            ),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      height: 450,
                                      child: _buildRequestCard(
                                        context,
                                        title: 'Content Approvals',
                                        child: MediahouseContentApprovalWidget(widget.mediaHouse.id!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            BuildSummaryCard(
                                              icon: Icons.currency_rupee_sharp,
                                              title: "Revenue",
                                              value: provider.mediaHouseDashboardData.viewRevenue.toString(),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      backgroundColor:
                                                          selectedThemeData
                                                              .cardColor,
                                                      child: CustomLineGraph(
                                                        title: 'Revenue Graph',
                                                        yAxisLabel: 'sales',
                                                        canPop: true,
                                                       mediaHouseId: widget.mediaHouse.id!,
                                                       graphNumber:0,
                                                       /* graphData: *//*[
                                                          {
                                                            "date":
                                                                "2023-12-12",
                                                            "revenue": 4149.06
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-13",
                                                            "revenue": 858.26
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-14",
                                                            "revenue": 4782.18
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-15",
                                                            "revenue": 4695.45
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-16",
                                                            "revenue": 4149.06
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-17",
                                                            "revenue": 858.26
                                                          },
                                                        ],*//*provider.revenueCountList??[],*/
                                                        metrics: ["revenue"],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            SizedBox(width: 10),
                                            BuildSummaryCard(
                                              icon: Icons.visibility_outlined,
                                              title: "Views",
                                              value: provider.mediaHouseDashboardData.totalViews.toString(),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      backgroundColor:
                                                          selectedThemeData
                                                              .cardColor,
                                                      child: CustomLineGraph(
                                                        title: 'Views Graph',
                                                        yAxisLabel: 'views',
                                                        mediaHouseId: widget.mediaHouse.id!,
                                                        graphNumber:1,
                                                        canPop: true,
                                                      /*  graphData: [
                                                          {
                                                            "date":
                                                                "2023-12-12",
                                                            "revenue": 414
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-13",
                                                            "revenue": 851
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-14",
                                                            "revenue": 678
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-15",
                                                            "revenue": 769
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-16",
                                                            "revenue": 214
                                                          },
                                                          {
                                                            "date":
                                                                "2023-12-17",
                                                            "revenue": 450
                                                          },
                                                        ],*/
                                                        metrics: ["views"],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            SizedBox(width: 10),
                                            BuildSummaryCard(
                                              icon: Icons
                                                  .play_circle_outline_sharp,
                                              title: "Live Content",
                                              value: provider.mediaHouseDashboardData.approvedContent.toString(),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      backgroundColor:
                                                          selectedThemeData
                                                              .cardColor,
                                                      child: CustomLineGraph(
                                                        title: 'Live Content',
                                                        yAxisLabel: 'live',
                                                        canPop: true,
                                                        mediaHouseId: widget.mediaHouse.id!,
                                                        graphNumber:2,
                                                       /* graphData: provider.releaseMovieCountList??[],*/
                                                        metrics: ["live"],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            SizedBox(width: 10),
                                            BuildSummaryCard(
                                              icon:
                                                  Icons.hourglass_top_outlined,
                                              title: "Pending Content",
                                              value: provider.mediaHouseDashboardData.pendingContentCount.toString(),
                                              onTap: () {

                                              },
                                            ),
                                            SizedBox(width: 10),
                                            BuildSummaryCard(
                                              icon: Icons.schedule,
                                              title: "Upcoming Content",
                                              value: provider.mediaHouseDashboardData.upcomingContentCount.toString(),
                                              onTap: () {

                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  height: 300,
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: ContentUploadCrad(),
                                      // ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      Expanded(
                                        flex: 4,
                                        child: Card(
                                          color: selectedThemeData.cardColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TopMoviesLineGraph(isRevenue: true,mediaHouseId:widget.mediaHouse.id!,),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SettlementCard(
                                    widget.mediaHouse
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // CircleAvatar(
                //   radius: 50,
                //   backgroundImage: widget.mediaHouse.logo != null
                //       ? NetworkImage(widget.mediaHouse.logo!)
                //       : const AssetImage('assets/default_profile_pic.png')
                //           as ImageProvider,
                // ),
                // const SizedBox(height: 20),
                // Text(
                //   widget.mediaHouse.mediaHouseName ?? 'Unknown Name',
                //   style: const TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 10),
                // Text(
                //   widget.mediaHouse.discription ?? 'No description available.',
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(fontSize: 16, color: Colors.grey),
                // ),
                // const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     StatTile(
                //       label: 'Posts',
                //       value: (widget.mediaHouse.totalReveneu ?? 0).toString(),
                //     ),
                //     StatTile(
                //       label: 'Views',
                //       value: (widget.mediaHouse.totalViews ?? 0).toString(),
                //     ),
                //     StatTile(
                //       label: 'Revenue',
                //       value: '${(widget.mediaHouse.totalReveneu ?? 0.0)}',
                //     ),
                //   ],
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Divider(
                    color: Colors.grey.withOpacity(0.4),
                    thickness: 1,
                  ),
                ),
                provider.filteredContentListByMediaHouse.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap:
                            true, // Makes the GridView take only necessary space
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveWidget.isDesktop(context)
                              ? 6
                              : ResponsiveWidget.isTablet(context)
                                  ? 4
                                  : 3,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          childAspectRatio: 27 / 40,
                        ),
                        itemCount: provider.filteredContentListByMediaHouse.length,
                        itemBuilder: (context, index) {
                          final content =
                              provider.filteredContentListByMediaHouse[index];
                          return GestureDetector(
                            onTap: () => showMovieDetailsDialog(context, content),
                            child: Card(
                              elevation: 4,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child:Image.network(
                                        (content.posterUrlList != null && content.posterUrlList!.isNotEmpty)
                                            ? content.posterUrlList!.first
                                            : 'https://via.placeholder.com/300x400?text=No+Image',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey,
                                              child: const Center(
                                                child: Icon(Icons.error,
                                                    color: Colors.white),
                                              ),
                                            ),
                                      )
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: ResponsiveWidget.isMobile(context)
                                        ? 5
                                        : 10,
                                    left: ResponsiveWidget.isMobile(context)
                                        ? 5
                                        : 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: selectedThemeData.cardColor
                                              .withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2,
                                          bottom: 2,
                                          left: 5,
                                          right: 5,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.remove_red_eye_outlined,
                                              color: const Color.fromARGB(
                                                  219, 255, 255, 255),
                                              size: 14,
                                            ),
                                            Text(
                                              ' ${content.views}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 5,
                                    right: 5,
                                    child: Text(
                                      '${content.title}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: SizedBox(
                          height: 200,
                          child: Text(
                            "No content availablee",
                          ),
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

//
class RevenueAnalyticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> contentList;

  const RevenueAnalyticsPage({super.key, required this.contentList});

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    List<_RevenueData> revenueData = contentList.map((content) {
      double totalRevenue = content['revenue'] ?? 0.0;
      return _RevenueData(
        content['title'],
        totalRevenue,
        totalRevenue * 0.5, // Media House (50%)
        totalRevenue * 0.3, // Urmee Talkies (30%)
        totalRevenue * 0.2, // Promoters (20%)
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Revenue Analytics",
          style: TextStyle(color: selectedThemeData.canvasColor),
        ),
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'Revenue Generated by Movies'),
          legend: Legend(isVisible: true),
          series: <CartesianSeries<_RevenueData, String>>[
            ColumnSeries<_RevenueData, String>(
              color: selectedThemeData.canvasColor,
              dataSource: revenueData,
              xValueMapper: (_RevenueData data, _) => data.movieTitle,
              yValueMapper: (_RevenueData data, _) => data.revenue,
              name: 'Total Revenue',
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
            ColumnSeries<_RevenueData, String>(
              color: selectedThemeData.primaryColor,
              dataSource: revenueData,
              xValueMapper: (_RevenueData data, _) => data.movieTitle,
              yValueMapper: (_RevenueData data, _) => data.mediaHouseShare,
              name: 'Media House (50%)',
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
            ColumnSeries<_RevenueData, String>(
              color: Color(0xFFB20710),
              dataSource: revenueData,
              xValueMapper: (_RevenueData data, _) => data.movieTitle,
              yValueMapper: (_RevenueData data, _) => data.urmeeTalkiesShare,
              name: 'Urmee Talkies (30%)',
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
            ColumnSeries<_RevenueData, String>(
              color: Color(0xFF8A060A),
              dataSource: revenueData,
              xValueMapper: (_RevenueData data, _) => data.movieTitle,
              yValueMapper: (_RevenueData data, _) => data.promotersShare,
              name: 'Promoters (20%)',
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueData {
  final String movieTitle;
  final double revenue;
  final double mediaHouseShare;
  final double urmeeTalkiesShare;
  final double promotersShare;

  _RevenueData(
    this.movieTitle,
    this.revenue,
    this.mediaHouseShare,
    this.urmeeTalkiesShare,
    this.promotersShare,
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

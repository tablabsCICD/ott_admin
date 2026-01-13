import 'package:admin_ott/app/provider/analyticsProvider.dart';
import 'package:admin_ott/app/ui/pages/analytics_page/topMovieGraphForAdmin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/reportAndDataResponse.dart';
import '../../../provider/themeProvider.dart';
import '../media house detail page/component/TopMoviesLineGraph.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  /*final List<Map<String, dynamic>> movies = [
    {
      "id": 1,
      "name": "Inception",
      "releaseDate": "2025-01-10",
      "views": 5000,
      "revenue": 1500000,
      "commission": 35,
      "profit": 1500000 - (35 / 100 * 1500000),
    },
    {
      "id": 2,
      "name": "Batman",
      "releaseDate": "2025-01-12",
      "views": 6200,
      "revenue": 1800000,
      "commission": 46,
      "profit": 1800000 - (46 / 100 * 1800000),
    },
    {
      "id": 3,
      "name": "The Dark Knight",
      "releaseDate": "2025-01-15",
      "views": 8500,
      "revenue": 2500000,
      "commission": 40,
      "profit": 2500000 - (40 / 100 * 2500000),
    },
    {
      "id": 4,
      "name": "Avengers: Endgame",
      "releaseDate": "2025-01-18",
      "views": 10000,
      "revenue": 3500000,
      "commission": 35,
      "profit": 3500000 - (35 / 100 * 3500000),
    },
    {
      "id": 5,
      "name": "Zero",
      "releaseDate": "2025-01-22",
      "views": 7800,
      "revenue": 2200000,
      "commission": 39,
      "profit": 2200000 - (39 / 100 * 2200000),
    },
    {
      "id": 6,
      "name": "The Matrix",
      "releaseDate": "2025-01-25",
      "views": 5400,
      "revenue": 1600000,
      "commission": 56,
      "profit": 1600000 - (56 / 100 * 1600000),
    },
    {
      "id": 1,
      "name": "Inception",
      "releaseDate": "2025-01-10",
      "views": 5000,
      "revenue": 1500000,
      "commission": 35,
      "profit": 1500000 - (35 / 100 * 1500000),
    },
    {
      "id": 2,
      "name": "Batman",
      "releaseDate": "2025-01-12",
      "views": 6200,
      "revenue": 1800000,
      "commission": 46,
      "profit": 1800000 - (46 / 100 * 1800000),
    },
    {
      "id": 3,
      "name": "The Dark Knight",
      "releaseDate": "2025-01-15",
      "views": 8500,
      "revenue": 2500000,
      "commission": 40,
      "profit": 2500000 - (40 / 100 * 2500000),
    },
    {
      "id": 4,
      "name": "Avengers: Endgame",
      "releaseDate": "2025-01-18",
      "views": 10000,
      "revenue": 3500000,
      "commission": 35,
      "profit": 3500000 - (35 / 100 * 3500000),
    },
    {
      "id": 5,
      "name": "Zero",
      "releaseDate": "2025-01-22",
      "views": 7800,
      "revenue": 2200000,
      "commission": 39,
      "profit": 2200000 - (39 / 100 * 2200000),
    },
    {
      "id": 6,
      "name": "The Matrix",
      "releaseDate": "2025-01-25",
      "views": 5400,
      "revenue": 1600000,
      "commission": 56,
      "profit": 1600000 - (56 / 100 * 1600000),
    },
  ];*/

  bool _isAscending = true;
  bool _sortByRevenue = true;

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  void _toggleSortCriteria() {
    setState(() {
      _sortByRevenue = !_sortByRevenue;
    });
  }

  List<ReportAndDataObject> getSortedMovies(AnalyticsProvider provider) {
    List<ReportAndDataObject> sortedMovies = List.from(provider.reportAndDataList);
    sortedMovies.sort((a, b) {
      if (_sortByRevenue) {
        return _isAscending
            ? a.totalRevenue.compareTo(b.totalRevenue)
            : b.totalRevenue.compareTo(a.totalRevenue);
      } else {
        return _isAscending
            ? a.contentName!.compareTo(b.contentName!)
            : b.contentName!.compareTo(a.contentName!);
      }
    });
    return sortedMovies;
  }

  Widget buildMovieTable(AnalyticsProvider provider) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    // List<ReportAndDataObject> sortedMovies = getSortedMovies(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: selectedThemeData.cardColor,
                foregroundColor: selectedThemeData.canvasColor,
              ),
              onPressed: _toggleSortCriteria,
              child: Text(
                _sortByRevenue ? "Sort by Name" : "Sort by Revenue",
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: selectedThemeData.cardColor,
                foregroundColor: selectedThemeData.canvasColor,
              ),
              onPressed: _toggleSortOrder,
              child: Text(
                _isAscending ? "Descending" : "Ascending",
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              _tableHeader("Movie Name", selectedThemeData.primaryColor),
              _tableHeader("Release Date", selectedThemeData.primaryColor),
              _tableHeader("Views", selectedThemeData.primaryColor),
              _tableHeader("Revenue", selectedThemeData.primaryColor),
              _tableHeader("Commission %", selectedThemeData.primaryColor),
              _tableHeader("Net Revenue", selectedThemeData.primaryColor),
              _tableHeader("Movie Details", selectedThemeData.primaryColor),
            ]),
            ...provider.reportAndDataList
                .map((movie) => TableRow(children: [
              _tableCell(movie.contentName??''),
              _tableCell(movie.releasedDate??'0'),
              _tableCell("${movie.totalViews??'0'}"),
              _tableCell("${movie.totalRevenue??'0'}"),
              _tableCell("${movie.currentPecentageIncentive??'0'}%"),
              _tableCell("${movie.earnedIncentive}"),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: selectedThemeData.cardColor,
                    foregroundColor: selectedThemeData.primaryColor,
                  ),
                  onPressed: () {
                   /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsPage(
                          movieId: movie.contentId!,
                        ),
                      ),
                    );*/
                  },
                  child: Text("See Details"),
                ),
              ),
            ]))
                .toList(),
          ],
        ),
      ],
    );
  }

  Widget _tableHeader(String title, Color color) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _tableCell(String value) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(value),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  _initData() async {
    await Provider.of<AnalyticsProvider>(context, listen: false).getReportAndData(context);
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        body: Consumer<AnalyticsProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Performance Overview",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        height: 400,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedThemeData.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        child: TopMoviesGraphForAdmin(),
                      ),
                      SizedBox(height: 20),
                      Text("Reports & Data",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Card(
                          color: selectedThemeData.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: buildMovieTable(provider),
                          )),
                    ],
                  ),
                ),
              );}
        )
    );
  }
}


import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../../domain/entities/user.dart';
import 'package:intl/intl.dart';

import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';


class AdminSettlementCard extends StatefulWidget {

  @override
  _AdminSettlementCardState createState() => _AdminSettlementCardState();
}

class _AdminSettlementCardState extends State<AdminSettlementCard> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredSettlements = [];



  @override
  void initState() {
    super.initState();
    _initData();
    _updateFilteredSettlements();
    searchController.addListener(_updateFilteredSettlements);
  }

  Future<void> _initData() async {



    await Provider.of<SettelementProvider>(context, listen: false)
        .fetchWeeklySettelementData();


  }

  @override
  void dispose() {
    searchController.removeListener(_updateFilteredSettlements);
    searchController.dispose();
    super.dispose();
  }



  void _updateFilteredSettlements() {
    String searchText = searchController.text.toLowerCase();

    /*  setState(() {
      filteredSettlements = widget.settlementsData["settlementsList"]
              ?.where((settlement) =>
                  (settlement["transactionId"]?.toLowerCase() ?? '')
                      .contains(searchText) ||
                  (settlement["startDate"]?.toLowerCase() ?? '')
                      .contains(searchText) ||
                  (settlement["endDate"]?.toLowerCase() ?? '')
                      .contains(searchText))
              .toList() ??
          [];
    });*/
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;


    return Consumer<SettelementProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSearchBar(selectedThemeData),
              const SizedBox(height: 5),
              provider.filleterdWeeklySettelement.isEmpty
                  ? Center(
                child: Text(
                  "No settlement data available",
                  style: TextStyle(color: selectedThemeData.primaryColor),
                ),
              )
                  : _buildSettlementList(provider),
            ],
          );}
    );
  }

  Widget _buildSearchBar(ThemeData selectedThemeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ResponsiveWidget.isMobile(context)
          ? SizedBox(
        width: 400,
        child: CustomTextField(
          controller: searchController,
          hintText: 'Search by dates, transaction ID ...',
          textInputType: TextInputType.text,
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Weekly Settlement',
            style: TextStyle(
              color: selectedThemeData.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 400,
            child: CustomTextField(
              controller: searchController,
              hintText: 'Search by dates, transaction ID ...',
              textInputType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementList(SettelementProvider provider) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.filleterdWeeklySettelement.length,
        itemBuilder: (context, index) {
          final data = provider.filleterdWeeklySettelement[index];
          return _buildSettlementCard(context, data);
        },
      ),
    );
  }

  Widget _buildSettlementCard(BuildContext context, WeeklySettelementData data) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data.startDate!);
    String? startDate = DateFormat('dd-MM-yyyy').format(date);
    DateTime date1 = DateTime.fromMillisecondsSinceEpoch(data.endDate!);
    String? endDate = DateFormat('dd-MM-yyyy').format(date1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: 350,
        child: Card(
          color: selectedThemeData.cardColor,
          child: Stack(
            children: [
              Positioned(
                top: 5,
                right: 10,
                child: InkWell(
                  onTap: () => _showDetailsDialog(context, data),
                  child: Text(
                    'See details',
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedThemeData.primaryColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, data, selectedThemeData),
                      const SizedBox(height: 5),
                      Text(
                        "${startDate ?? 'N/A'} - ${endDate ?? 'N/A'}",
                        overflow: TextOverflow.visible,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Divider(),
                      ),
                      _buildDetailRow(
                        'Total Revenue',
                        _parseNumber(data.grossRevenue),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _buildDetailRow(
                        'Total Purchases',
                        _parseNumber(data.totalPurchases),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _buildDetailRow(
                        'Total Movies Sold',
                        _parseNumber(data.totalUniqueMoviesSold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _buildDetailRow('Most Purchased Movie',
                          data.mostPurchasedMovie ?? 'N/A'),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeeklySettelementData data,
      ThemeData selectedThemeData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Transaction ID: ${data.transactionId ?? 'N/A'}",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selectedThemeData.primaryColor,
          ),
        ),
      ],
    );
  }

  void _showDetailsDialog(BuildContext context, WeeklySettelementData data) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data.startDate!);
    String? startDate = DateFormat('dd-MM-yyyy').format(date);
    DateTime date1 = DateTime.fromMillisecondsSinceEpoch(data.endDate!);
    String? endDate = DateFormat('dd-MM-yyyy').format(date1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
        return AlertDialog(
          backgroundColor: selectedThemeData.cardColor,
          title: const Text("Detailed Transaction"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transaction ID: ${data.transactionId ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectedThemeData.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "From: ${startDate ?? 'N/A'} - To: ${endDate ?? 'N/A'}",
                ),
                Divider(
                  color: selectedThemeData.canvasColor.withOpacity(0.2),
                ),
                _buildDetailRow(
                    'Gross Revenue', _parseNumber(data.grossRevenue)),
                _buildDetailRow(
                    'Tax Deduction', _parseNumber(data.taxDeduction)),
                _buildDetailRow(
                    'Net Revenue', _parseNumber(data.netRevenue)),
                Divider(
                  color: selectedThemeData.canvasColor.withOpacity(0.2),
                ),
                _buildDetailRow('OTT Platform Share %',
                    _parseNumber(data.ottPlatformSharePercentage)),
                _buildDetailRow('OTT Platform Revenue Share',
                    _parseNumber(data.ottPlatformRevenueShare)),
                Divider(
                  color: selectedThemeData.canvasColor.withOpacity(0.2),
                ),
                _buildDetailRow('Media House Share %',
                    _parseNumber(data.mediaHouseSharePercentage)),
                _buildDetailRow('Media House Revenue Share',
                    _parseNumber(data.mediaHouseRevenueShare)),
                Divider(
                  color: selectedThemeData.canvasColor.withOpacity(0.2),
                ),
                SizedBox(
                  height: 150,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text("Movies Sold",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ..._getMoviesSoldList(data),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                "PDF",
                style: TextStyle(color: selectedThemeData.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(color: selectedThemeData.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getMoviesSoldList(WeeklySettelementData data) {
    ListOfMoviesSold? moviesSold = data.listOfMoviesSold;
    if (moviesSold == null) {
      return [const Text("No movie data available")];
    }

    return moviesSold!.entries.entries.map((entry) {
      return _buildDetailRow(entry.key, _parseNumber(entry.value));
    }).toList();

    // return [];
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(value, textAlign: TextAlign.end),
      ],
    );
  }

  String _parseNumber(dynamic value) {
    if (value is int || value is double) return value.toString();
    if (value is String) return int.tryParse(value)?.toString() ?? 'N/A';
    return 'N/A';
  }
}

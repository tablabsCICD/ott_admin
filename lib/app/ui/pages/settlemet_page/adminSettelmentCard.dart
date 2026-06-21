import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
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
    _updateFilteredSettlements();
    searchController.addListener(_updateFilteredSettlements);
  }

  @override
  void dispose() {
    searchController.removeListener(_updateFilteredSettlements);
    searchController.dispose();
    super.dispose();
  }

  void _updateFilteredSettlements() {}

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Consumer<SettelementProvider>(builder: (context, provider, child) {
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
      );
    });
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
      height: 176,
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

  Widget _buildSettlementCard(
      BuildContext context, WeeklySettelementData data) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data.startDate!);
    String startDate = DateFormat('dd-MM-yyyy').format(date);
    DateTime date1 = DateTime.fromMillisecondsSinceEpoch(data.endDate!);
    String endDate = DateFormat('dd-MM-yyyy').format(date1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: 320,
        child: Card(
          color: selectedThemeData.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedThemeData.canvasColor.withOpacity(0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildHeader(context, data, selectedThemeData),
                    ),
                    _buildViewButton(
                      selectedThemeData,
                      onPressed: () => _showDetailsDialog(context, data),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _buildDateBand(
                  selectedThemeData,
                  "$startDate - $endDate",
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryMetric(
                        selectedThemeData,
                        'Revenue',
                        _parseNumber(data.grossRevenue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryMetric(
                        selectedThemeData,
                        'Purchases',
                        _parseNumber(data.totalPurchases),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryMetric(
                        selectedThemeData,
                        'Movies',
                        _parseNumber(data.totalUniqueMoviesSold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeeklySettelementData data,
      ThemeData selectedThemeData) {
    return Text(
      "Transaction ID: ${data.transactionId ?? 'N/A'}",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: selectedThemeData.primaryColor,
      ),
    );
  }

  Widget _buildViewButton(ThemeData theme, {required VoidCallback onPressed}) {
    return SizedBox(
      height: 28,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 28),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: theme.primaryColor.withOpacity(0.32)),
        ),
        icon: const Icon(Icons.visibility_outlined, size: 13),
        label: const Text('View', style: TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildDateBand(ThemeData theme, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.canvasColor.withOpacity(0.76),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(ThemeData theme, String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 55),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor.withOpacity(0.65),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, WeeklySettelementData data) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data.startDate!);
    String startDate = DateFormat('dd-MM-yyyy').format(date);
    DateTime date1 = DateTime.fromMillisecondsSinceEpoch(data.endDate!);
    String endDate = DateFormat('dd-MM-yyyy').format(date1);
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
                  "From: $startDate - To: $endDate",
                ),
                Divider(
                  color: selectedThemeData.canvasColor.withOpacity(0.2),
                ),
                _buildDetailRow(
                    'Gross Revenue', _parseNumber(data.grossRevenue)),
                _buildDetailRow(
                    'Tax Deduction', _parseNumber(data.taxDeduction)),
                _buildDetailRow('Net Revenue', _parseNumber(data.netRevenue)),
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
                _buildDetailRow('Production House Share %',
                    _parseNumber(data.mediaHouseSharePercentage)),
                _buildDetailRow('Production House Revenue Share',
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

    return moviesSold.entries.entries.map((entry) {
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

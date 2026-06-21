import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../provider/settelementProvider.dart';
import 'package:intl/intl.dart';

import '../../../../provider/themeProvider.dart';
import '../../../../widgets/custom_textfield.dart';

class SettlementCard extends StatefulWidget {
  final MediaHouse mediaHouse;
  SettlementCard(this.mediaHouse);

  @override
  _SettlementCardState createState() => _SettlementCardState();
}

class _SettlementCardState extends State<SettlementCard> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
    _updateFilteredSettlements();
    searchController.addListener(_updateFilteredSettlements);
  }

  Future<void> _initData() async {
    User? user = widget.mediaHouse.user;

    if (user == null || user.id == null) {
      debugPrint("User or User ID is null. Cannot fetch settlement data.");
      return;
    }

    await Provider.of<SettelementProvider>(context, listen: false)
        .fetchWeeklySettelementDataByMediaHouseId(user.id!);
  }

  @override
  void dispose() {
    searchController.removeListener(_updateFilteredSettlements);
    searchController.dispose();
    super.dispose();
  }

  void _updateFilteredSettlements() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Consumer<SettelementProvider>(builder: (context, provider, child) {
      final settlements = _filteredSettlements(provider);
      return Column(
        children: [
          _buildSearchBar(selectedThemeData),
          const SizedBox(height: 5),
          settlements.isEmpty
              ? Center(
                  child: Text(
                    "No settlement data available",
                    style: TextStyle(color: selectedThemeData.primaryColor),
                  ),
                )
              : _buildSettlementList(settlements),
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

  Widget _buildSettlementList(List<WeeklySettelementData> settlements) {
    return SizedBox(
      height: 196,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: settlements.length,
        itemBuilder: (context, index) {
          final data = settlements[index];
          return _buildSettlementCard(context, data);
        },
      ),
    );
  }

  Widget _buildSettlementCard(
      BuildContext context, WeeklySettelementData data) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    final startDate = _formatDate(data.startDate);
    final endDate = _formatDate(data.endDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: ResponsiveWidget.isMobile(context) ? 310 : 360,
        child: Card(
          color: selectedThemeData.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedThemeData.canvasColor.withOpacity(0.12),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 8),
                _buildDateBand(
                  selectedThemeData,
                  startDate: startDate,
                  endDate: endDate,
                ),
                const SizedBox(height: 10),
                _buildMetricGrid(selectedThemeData, data),
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
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: selectedThemeData.primaryColor,
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, WeeklySettelementData data) {
    final startDate = _formatDate(data.startDate);
    final endDate = _formatDate(data.endDate);
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
        Expanded(child: Text(title)),
        const SizedBox(width: 10),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    );
  }

  String _parseNumber(dynamic value) {
    if (value is int) return value.toString();
    if (value is double) {
      return value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(2);
    }
    if (value is num) return value.toString();
    if (value is String) {
      final parsed = num.tryParse(value);
      return parsed?.toString() ?? 'N/A';
    }
    return 'N/A';
  }

  String _formatDate(int? epoch) {
    if (epoch == null) return 'N/A';
    return DateFormat('dd-MM-yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(epoch));
  }

  Widget _buildDateBand(
    ThemeData theme, {
    required String startDate,
    required String endDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$startDate - $endDate',
        style: TextStyle(
          color: theme.canvasColor.withOpacity(0.78),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetricGrid(ThemeData theme, WeeklySettelementData data) {
    final metrics = [
      MapEntry('Gross', _parseNumber(data.grossRevenue)),
      MapEntry('Net', _parseNumber(data.netRevenue)),
      MapEntry('Purchases', _parseNumber(data.totalPurchases)),
    ];

    return Row(
      children: metrics
          .map(
            (metric) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: metric == metrics.last ? 0 : 8,
                ),
                child: _buildSummaryMetric(theme, metric),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSummaryMetric(ThemeData theme, MapEntry<String, String> metric) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.key,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor.withOpacity(0.68),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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

  List<WeeklySettelementData> _filteredSettlements(
      SettelementProvider provider) {
    final query = searchController.text.trim().toLowerCase();
    final settlements = provider.filleterdWeeklySettelement;
    if (query.isEmpty) return settlements;

    return settlements.where((settlement) {
      final searchableText = [
        settlement.transactionId?.toString(),
        _formatDate(settlement.startDate),
        _formatDate(settlement.endDate),
        settlement.mostPurchasedMovie,
        ...?settlement.listOfMoviesSold?.entries.keys,
      ].whereType<String>().join(' ').toLowerCase();
      return searchableText.contains(query);
    }).toList();
  }
}

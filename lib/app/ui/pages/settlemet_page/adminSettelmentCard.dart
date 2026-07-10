import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
import 'package:intl/intl.dart';

import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';
import 'settlement_report_detail_page.dart';

class AdminSettlementCard extends StatefulWidget {
  const AdminSettlementCard({super.key});

  @override
  State<AdminSettlementCard> createState() => _AdminSettlementCardState();
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
      return Card(
        elevation: 2,
        color: selectedThemeData.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(selectedThemeData),
              const SizedBox(height: 12),
              provider.filleterdWeeklySettelement.isEmpty
                  ? Center(
                      child: Text(
                        "No settlement data available",
                        style: TextStyle(color: selectedThemeData.primaryColor),
                      ),
                    )
                  : _buildSettlementList(provider),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar(ThemeData selectedThemeData) {
    final searchField = CustomTextField(
      controller: searchController,
      hintText: 'Search by dates, transaction ID ...',
      textInputType: TextInputType.text,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack =
              ResponsiveWidget.isMobile(context) || constraints.maxWidth < 680;

          final title = Text(
            'Weekly Settlement',
            style: TextStyle(
              color: selectedThemeData.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          );

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: 10),
                searchField,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, minWidth: 260),
                child: searchField,
              ),
            ],
          );
        },
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
    final startDate = _formatEpochDate(data.startDate);
    final endDate = _formatEpochDate(data.endDate);
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
                color: selectedThemeData.canvasColor.withValues(alpha: 0.12),
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
                      onPressed: () => _openSettlementReport(context, data),
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
          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.32)),
        ),
        icon: const Icon(Icons.visibility_outlined, size: 13),
        label: const Text('View', style: TextStyle(fontSize: 11)),
      ),
    );
  }

  void _openSettlementReport(BuildContext context, WeeklySettelementData data) {
    final transactionLabel = data.id?.toString();
    final reportId = _settlementReportId(transactionLabel);

    if (reportId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settlement transaction id is missing.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettlementReportDetailPage(
          reportId: reportId,
          transactionLabel: transactionLabel,
        ),
      ),
    );
  }

  String _settlementReportId(String? transactionId) {
    final text = transactionId?.trim() ?? "";
    if (text.isEmpty) return "";
    final digits =
        RegExp(r"\d+").allMatches(text).map((m) => m.group(0)).join();
    return digits.isNotEmpty ? digits : text;
  }

  Widget _buildDateBand(ThemeData theme, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.canvasColor.withValues(alpha: 0.76),
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
        color: theme.primaryColor.withValues(alpha: 0.08),
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
              color: theme.canvasColor.withValues(alpha: 0.65),
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

  String _parseNumber(dynamic value) {
    if (value is int || value is double) return value.toString();
    if (value is String) return int.tryParse(value)?.toString() ?? 'N/A';
    return 'N/A';
  }

  String _formatEpochDate(int? value) {
    if (value == null || value <= 0) return 'N/A';
    return DateFormat('dd-MM-yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(value),
    );
  }
}

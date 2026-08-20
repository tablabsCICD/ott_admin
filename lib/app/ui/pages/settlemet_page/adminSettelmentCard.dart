import 'package:admin_ott/app/provider/settelementProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/models/response/mediaHouseWeeklySettelement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'settlement_report_detail_page.dart';

class AdminSettlementCard extends StatefulWidget {
  const AdminSettlementCard({super.key});

  @override
  State<AdminSettlementCard> createState() => _AdminSettlementCardState();
}

class _AdminSettlementCardState extends State<AdminSettlementCard> {
  final TextEditingController searchController = TextEditingController();
  final Set<dynamic> _expandedCardIds = {};

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _toggleExpanded(dynamic id) {
    setState(() {
      if (_expandedCardIds.contains(id)) {
        _expandedCardIds.remove(id);
      } else {
        _expandedCardIds.add(id);
      }
    });
  }

  List<WeeklySettelementData> _filterSettlements(
    List<WeeklySettelementData> allSettlements,
  ) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return allSettlements;

    return allSettlements.where((item) {
      final txId = (item.transactionId ?? '').toString().toLowerCase();
      final displayTxId = _formatTransactionIdDisplay(item.transactionId).toLowerCase();
      final beneficiary = _getBeneficiaryType(item.transactionId).toLowerCase();
      final status = _getStatusLabel(item.isDone).toLowerCase();
      final incentive = (item.typeOfIncentive ?? '').toLowerCase();
      final topMovie = (item.mostPurchasedMovie ?? '').toLowerCase();
      final desc = (item.description ?? '').toLowerCase();
      final userId = (item.userId ?? '').toString().toLowerCase();
      final id = (item.id ?? '').toString().toLowerCase();

      final startDateStr = _formatDate(item.startDate).toLowerCase();
      final endDateStr = _formatDate(item.endDate).toLowerCase();

      return txId.contains(query) ||
          displayTxId.contains(query) ||
          beneficiary.contains(query) ||
          status.contains(query) ||
          incentive.contains(query) ||
          topMovie.contains(query) ||
          desc.contains(query) ||
          userId.contains(query) ||
          id.contains(query) ||
          startDateStr.contains(query) ||
          endDateStr.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Consumer<SettelementProvider>(
      builder: (context, provider, child) {
        final allSettlements = provider.weeklySettelement;
        final filteredSettlements = _filterSettlements(allSettlements);

        return Card(
          elevation: 2,
          color: theme.cardColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchBar(theme),
                const SizedBox(height: 16),
                if (allSettlements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        "No settlement records found.",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                else if (filteredSettlements.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        "No matching settlement records found.",
                        style: TextStyle(
                          color: theme.canvasColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSettlements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final data = filteredSettlements[index];
                      final cardKey = data.id ?? 'idx_$index';
                      final isExpanded = _expandedCardIds.contains(cardKey);

                      return _buildSettlementCard(
                        context,
                        theme,
                        data,
                        isExpanded,
                        () => _toggleExpanded(cardKey),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;

        final title = Text(
          'Settlement Records',
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        );

        final searchField = CustomTextField(
          controller: searchController,
          hintText: 'Search by transaction ID, beneficiary, status, date...',
          textInputType: TextInputType.text,
        );

        if (isNarrow) {
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
              constraints: const BoxConstraints(maxWidth: 420, minWidth: 260),
              child: searchField,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettlementCard(
    BuildContext context,
    ThemeData theme,
    WeeklySettelementData data,
    bool isExpanded,
    VoidCallback onToggleExpand,
  ) {
    final statusLabel = _getStatusLabel(data.isDone);
    final statusBgColor = _getStatusBgColor(data.isDone);
    final statusTextColor = _getStatusTextColor(data.isDone);

    final beneficiaryType = _getBeneficiaryType(data.transactionId);
    final displayTxId = _formatTransactionIdDisplay(data.transactionId);
    final startDateStr = _formatDate(data.startDate);
    final endDateStr = _formatDate(data.endDate);
    final createdDateStr = _formatDateTime(data.createdDate);

    final schedDay = _formatText(data.scheduledSettlementDay);
    final schedTime = _formatText(data.scheduledSettlementTime);
    final schedTz = _formatText(data.scheduledSettlementTimezone);
    final scheduleLine = (schedDay == '—' && schedTime == '—')
        ? '—'
        : '$schedDay at $schedTime ${schedTz != '—' ? "($schedTz)" : ""}';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Settlement #${data.id ?? '—'}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: theme.canvasColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                label: statusLabel,
                                bgColor: statusBgColor,
                                textColor: statusTextColor,
                              ),
                              const SizedBox(width: 6),
                              _buildBadge(
                                label: beneficiaryType,
                                bgColor: theme.primaryColor.withValues(alpha: 0.12),
                                textColor: theme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tx ID: $displayTxId",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.canvasColor.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      createdDateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.canvasColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Main Summary Financial Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final earnedMetric = _buildMetricBox(
                      theme,
                      'Earned Incentive',
                      _formatCurrency(data.earnedIncentive, maxDecimals: 4),
                      highlight: true,
                    );
                    final grossMetric = _buildMetricBox(
                      theme,
                      'Gross Revenue',
                      _formatCurrency(data.grossRevenue),
                    );
                    final taxMetric = _buildMetricBox(
                      theme,
                      'Tax Deduction',
                      _formatCurrency(data.taxDeduction),
                    );
                    final netMetric = _buildMetricBox(
                      theme,
                      'Net Revenue',
                      _formatCurrency(data.netRevenue),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: earnedMetric),
                              const SizedBox(width: 8),
                              Expanded(child: grossMetric),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: taxMetric),
                              const SizedBox(width: 8),
                              Expanded(child: netMetric),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: earnedMetric),
                        const SizedBox(width: 8),
                        Expanded(child: grossMetric),
                        const SizedBox(width: 8),
                        Expanded(child: taxMetric),
                        const SizedBox(width: 8),
                        Expanded(child: netMetric),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Period & Purchase Quick Info Band
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14,
                              color: theme.canvasColor.withValues(alpha: 0.6)),
                          const SizedBox(width: 6),
                          Text(
                            "Period: $startDateStr – $endDateStr",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.canvasColor.withValues(alpha: 0.85),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Schedule: $scheduleLine",
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.canvasColor.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Incentive: ${_formatText(data.typeOfIncentive)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.canvasColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Purchases: ${_formatInt(data.totalPurchases)}  |  Unique: ${_formatInt(data.totalUniqueMoviesSold)}  |  Top: ${_formatText(data.mostPurchasedMovie)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: theme.canvasColor.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onToggleExpand,
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: theme.primaryColor,
                      ),
                      label: Text(
                        isExpanded ? 'Hide Details' : 'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openSettlementReport(context, data),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 30),
                        side: BorderSide(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined, size: 14),
                      label: const Text('Full Report', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Expanded Financial Breakdown Section
          if (isExpanded) ...[
            Divider(height: 1, color: theme.canvasColor.withValues(alpha: 0.1)),
            Container(
              padding: const EdgeInsets.all(14),
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(theme, 'Revenue & Tax Breakdown'),
                  const SizedBox(height: 8),
                  _buildGridDetails(theme, [
                    _DetailItem('Gross Revenue', _formatCurrency(data.grossRevenue)),
                    _DetailItem('Base Amount', _formatCurrency(data.baseAmount)),
                    _DetailItem('GST Rate', _formatPercent(data.gstRate)),
                    _DetailItem('GST Amount', _formatCurrency(data.gstAmount)),
                    _DetailItem('Tax Deduction', _formatCurrency(data.taxDeduction)),
                    _DetailItem('Razorpay Fee', _formatCurrency(data.razorpayFee)),
                    _DetailItem('Net Revenue', _formatCurrency(data.netRevenue)),
                  ]),
                  const SizedBox(height: 14),
                  _buildSectionTitle(theme, 'Admin / OTT Platform Breakdown'),
                  const SizedBox(height: 8),
                  _buildGridDetails(theme, [
                    _DetailItem('Platform Share %', _formatPercent(data.ottPlatformSharePercentage)),
                    _DetailItem('Revenue Share', _formatCurrency(data.ottPlatformRevenueShare)),
                    _DetailItem('Admin Gross Revenue', _formatCurrency(data.adminGrossRevenue)),
                    _DetailItem('Admin TDS Amount', _formatCurrency(data.adminTdsAmount)),
                    _DetailItem('Admin Payout Charge', _formatCurrency(data.adminPayoutCharge)),
                    _DetailItem('Admin Final Revenue', _formatCurrency(data.adminFinalRevenue)),
                  ]),
                  const SizedBox(height: 14),
                  _buildSectionTitle(theme, 'Media House Breakdown'),
                  const SizedBox(height: 8),
                  _buildGridDetails(theme, [
                    _DetailItem('Media House Share %', _formatPercent(data.mediaHouseSharePercentage)),
                    _DetailItem('Revenue Share', _formatCurrency(data.mediaHouseRevenueShare)),
                    _DetailItem('Media House TDS Amount', _formatCurrency(data.mediaHouseTdsAmount)),
                    _DetailItem('Payout Charge', _formatCurrency(data.mediaHousePayoutCharge)),
                    _DetailItem('Final Payout', _formatCurrency(data.mediaHouseFinalPayout)),
                  ]),
                  const SizedBox(height: 14),
                  _buildSectionTitle(theme, 'Promoter Breakdown'),
                  const SizedBox(height: 8),
                  _buildGridDetails(theme, [
                    _DetailItem('Promoter Gross Share', _formatCurrency(data.promoterGrossRevenueShare)),
                    _DetailItem('Promoter TDS Amount', _formatCurrency(data.promoterTdsAmount)),
                    _DetailItem('Amount After TDS', _formatCurrency(data.promoterAmountAfterTds)),
                    _DetailItem('Payout Charge', _formatCurrency(data.promoterPayoutCharge)),
                    _DetailItem('Final Earning', _formatCurrency(data.promoterFinalEarning)),
                  ]),
                  const SizedBox(height: 14),
                  _buildSectionTitle(theme, 'Movies Sold'),
                  const SizedBox(height: 8),
                  _buildMoviesSoldTable(theme, data.listOfMoviesSold),
                  if (data.description != null && data.description!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildSectionTitle(theme, 'Description'),
                    const SizedBox(height: 4),
                    Text(
                      data.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.canvasColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricBox(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
  }) {
    final bgColor = highlight
        ? theme.primaryColor.withValues(alpha: 0.12)
        : theme.primaryColor.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlight ? theme.primaryColor : theme.canvasColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildGridDetails(ThemeData theme, List<_DetailItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 420 ? 3 : 2);
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: items.map((item) {
            final itemWidth = (constraints.maxWidth - (spacingWidth(crossAxisCount))) / crossAxisCount;
            return SizedBox(
              width: itemWidth.clamp(120, 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.canvasColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.canvasColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  double spacingWidth(int count) => (count - 1) * 12.0;

  Widget _buildMoviesSoldTable(ThemeData theme, ListOfMoviesSold? moviesSold) {
    if (moviesSold == null || moviesSold.entries.isEmpty) {
      return Text(
        "No movie purchase details available.",
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: theme.canvasColor.withValues(alpha: 0.55),
        ),
      );
    }

    final entries = moviesSold.entries.entries.toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(1),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: theme.canvasColor.withValues(alpha: 0.08)),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.08),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Movie Title',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Purchases',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...entries.map((entry) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${entry.value ?? 0}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }),
        ],
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

  String _formatTransactionIdDisplay(dynamic rawId) {
    final str = rawId?.toString().trim() ?? '';
    if (str.isEmpty) return '—';
    if (str.contains(':')) {
      final parts = str.split(':');
      final prefix = parts[0]
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
          .join(' ');
      return '$prefix #${parts.sublist(1).join(':')}';
    }
    return str.replaceAll('_', ' ');
  }

  String _getBeneficiaryType(dynamic rawId) {
    final str = rawId?.toString().toUpperCase() ?? '';
    if (str.startsWith('MEDIA_HOUSE')) return 'Media House';
    if (str.startsWith('PROMOTER')) return 'Promoter';
    if (str.startsWith('ADMIN') || str.startsWith('PLATFORM')) return 'Admin/Platform';
    return 'Other';
  }

  String _getStatusLabel(bool? isDone) {
    if (isDone == true) return 'Completed';
    if (isDone == false) return 'Pending';
    return 'Unknown';
  }

  Color _getStatusBgColor(bool? isDone) {
    if (isDone == true) return Colors.green.shade50;
    if (isDone == false) return Colors.orange.shade50;
    return Colors.grey.shade200;
  }

  Color _getStatusTextColor(bool? isDone) {
    if (isDone == true) return Colors.green.shade800;
    if (isDone == false) return Colors.orange.shade800;
    return Colors.grey.shade800;
  }

  String _formatCurrency(double? value, {int? maxDecimals}) {
    if (value == null) return '—';
    if (value == 0) return '₹0';

    final text = value.toString();
    if (text.contains('.')) {
      final parts = text.split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final formattedInt =
          NumberFormat('#,##,###', 'en_IN').format(int.tryParse(intPart) ?? 0);
      return '₹$formattedInt.$decPart';
    } else {
      final formattedInt =
          NumberFormat('#,##,###', 'en_IN').format(value.toInt());
      return '₹$formattedInt';
    }
  }

  String _formatPercent(double? value) {
    if (value == null) return '—';
    if (value == 0) return '0%';
    if (value % 1 == 0) return '${value.toInt()}%';
    return '${value.toStringAsFixed(2)}%';
  }

  String _formatText(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }

  String _formatInt(int? value) {
    if (value == null) return '—';
    return value.toString();
  }

  String _formatDate(int? epochMs) {
    if (epochMs == null || epochMs <= 0) return '—';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '—';
    }
  }

  String _formatDateTime(int? epochMs) {
    if (epochMs == null || epochMs <= 0) return '—';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return '—';
    }
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}

import 'package:admin_ott/app/provider/settelementProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/data/models/response/weekly_settlement_report.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettlementReportDetailPage extends StatefulWidget {
  const SettlementReportDetailPage({
    super.key,
    required this.reportId,
    this.transactionLabel,
  });

  final String reportId;
  final String? transactionLabel;

  @override
  State<SettlementReportDetailPage> createState() =>
      _SettlementReportDetailPageState();
}

class _SettlementReportDetailPageState
    extends State<SettlementReportDetailPage> {
  late Future<WeeklySettlementReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    _reportFuture = context
        .read<SettelementProvider>()
        .fetchWeeklySettlementReport(widget.reportId);
  }

  void _reloadReport() {
    setState(() {
      _loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.transactionLabel != null
              ? "Report #${widget.transactionLabel}"
              : "Weekly Settlement Report",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Report",
            onPressed: _reloadReport,
          ),
        ],
      ),
      body: FutureBuilder<WeeklySettlementReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppSpinner());
          }

          if (snapshot.hasError) {
            final errorMsg = snapshot.error?.toString() ?? "Failed to load settlement report.";
            return _StatePanel(
              theme: theme,
              icon: Icons.error_outline,
              title: "Unable to load settlement details.",
              subtitle: errorMsg.replaceFirst("Exception: ", ""),
              onRetry: _reloadReport,
            );
          }

          final report = snapshot.data;
          if (report == null) {
            return _StatePanel(
              theme: theme,
              icon: Icons.receipt_long_outlined,
              title: "Settlement report data is not available.",
              onRetry: _reloadReport,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reloadReport(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _SettlementDashboard(report: report, theme: theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettlementDashboard extends StatelessWidget {
  const _SettlementDashboard({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportHeaderCard(report: report, theme: theme),
        const SizedBox(height: 18),
        if (report.summaryCards.isNotEmpty) ...[
          _DynamicSummaryCards(report: report, theme: theme),
          const SizedBox(height: 18),
        ],
        if (report.settlementPurchaseSummary != null) ...[
          _PurchaseSummarySection(
            summary: report.settlementPurchaseSummary!,
            fallbackSymbol: report.fallbackSymbol,
            theme: theme,
          ),
          const SizedBox(height: 18),
        ],
        if (report.sections.isNotEmpty) ...[
          _CalculationSections(report: report, theme: theme),
          const SizedBox(height: 18),
        ],
        if (report.beneficiarySettlementSummary.isNotEmpty) ...[
          _BeneficiarySummarySection(report: report, theme: theme),
          const SizedBox(height: 18),
        ],
        if (report.taxAndChargeSummary != null) ...[
          _TaxAndChargeSummarySection(
            summary: report.taxAndChargeSummary!,
            fallbackSymbol: report.fallbackSymbol,
            theme: theme,
          ),
          const SizedBox(height: 18),
        ],
        if (report.finalSummary.isNotEmpty) ...[
          _FinalSummarySection(report: report, theme: theme),
        ],
      ],
    );
  }
}

class _ReportHeaderCard extends StatelessWidget {
  const _ReportHeaderCard({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final titleText = report.title ?? "Weekly Settlement Report";
    final batchRef = report.settlementBatchReference ?? "—";
    final statusStr = report.settlementStatus ?? "Unknown";
    final periodStr = report.settlementPeriod?.formattedPeriod ?? "—";
    final reportTypeStr = _formatReportType(report.reportType);
    final beneficiaryStr = report.beneficiary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assessment_outlined, color: theme.primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Batch: $batchRef",
                      style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: statusStr, theme: theme),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: theme.canvasColor.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              _HeaderMetaItem(
                theme: theme,
                icon: Icons.date_range_outlined,
                label: "Period",
                value: periodStr,
              ),
              _HeaderMetaItem(
                theme: theme,
                icon: Icons.category_outlined,
                label: "Report Type",
                value: reportTypeStr,
              ),
              if (beneficiaryStr != null && beneficiaryStr.trim().isNotEmpty)
                _HeaderMetaItem(
                  theme: theme,
                  icon: Icons.person_outline,
                  label: "Beneficiary",
                  value: beneficiaryStr,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatReportType(String? type) {
    if (type == null || type.trim().isEmpty) return "Weekly Settlement";
    if (type.toUpperCase() == "WEEKLY_SETTLEMENT") return "Weekly Settlement";
    return type
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .map((w) => w.isNotEmpty ? "${w[0].toUpperCase()}${w.substring(1)}" : "")
        .join(" ");
  }
}

class _HeaderMetaItem extends StatelessWidget {
  const _HeaderMetaItem({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.canvasColor.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DynamicSummaryCards extends StatelessWidget {
  const _DynamicSummaryCards({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cards = report.summaryCards;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 1050
            ? 4
            : (constraints.maxWidth >= 650 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 96,
          ),
          itemBuilder: (context, index) {
            final item = cards[index];
            final iconData = _mapIcon(item.icon);
            final displayAmount = _ensureCurrency(item.amount, report.fallbackSymbol);

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.canvasColor.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(iconData, color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.canvasColor.withValues(alpha: 0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            displayAmount,
                            style: TextStyle(
                              color: theme.canvasColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PurchaseSummarySection extends StatelessWidget {
  const _PurchaseSummarySection({
    required this.summary,
    required this.fallbackSymbol,
    required this.theme,
  });

  final SettlementPurchaseSummaryModel summary;
  final String fallbackSymbol;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      _PurchaseMetric("Total Transactions", summary.totalTransactions?.toString() ?? "0", Icons.receipt_long_outlined, theme.primaryColor),
      _PurchaseMetric("Successful", summary.successfulTransactions?.toString() ?? "0", Icons.check_circle_outline, Colors.green),
      _PurchaseMetric("Failed", summary.failedTransactions?.toString() ?? "0", Icons.highlight_off_outlined, Colors.red),
      _PurchaseMetric("Refunded", summary.refundedTransactions?.toString() ?? "0", Icons.history_outlined, Colors.orange),
      _PurchaseMetric("Total Content", summary.totalContentCount?.toString() ?? "0", Icons.movie_outlined, Colors.blue),
      _PurchaseMetric("Customer Payment", _ensureCurrency(summary.totalCustomerPayment?.toString() ?? "0", fallbackSymbol), Icons.payments_outlined, Colors.teal),
    ];

    return _SectionContainer(
      theme: theme,
      title: "Settlement Purchase Summary",
      icon: Icons.shopping_cart_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth >= 1050
              ? 6
              : (constraints.maxWidth >= 720 ? 3 : (constraints.maxWidth >= 480 ? 2 : 1));

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 80,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.canvasColor.withValues(alpha: 0.65),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.canvasColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PurchaseMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _PurchaseMetric(this.label, this.value, this.icon, this.color);
}

class _CalculationSections extends StatelessWidget {
  const _CalculationSections({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final sections = report.sections;

    return Column(
      children: sections.map((sec) {
        final iconData = _mapIcon(sec.icon);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _SectionContainer(
            theme: theme,
            title: sec.title,
            icon: iconData,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sec.rows.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.canvasColor.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, rIdx) {
                final row = sec.rows[rIdx];
                final displayAmount = _ensureCurrency(row.amount, report.fallbackSymbol);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: TextStyle(
                                color: theme.canvasColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (row.formula != null && row.formula!.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                row.formula!,
                                style: TextStyle(
                                  color: theme.canvasColor.withValues(alpha: 0.55),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        displayAmount,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BeneficiarySummarySection extends StatelessWidget {
  const _BeneficiarySummarySection({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final beneficiaries = report.beneficiarySettlementSummary;

    return _SectionContainer(
      theme: theme,
      title: "Beneficiary Settlement Summary",
      icon: Icons.people_outline,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          if (isMobile) {
            return Column(
              children: beneficiaries.map((b) {
                return _BeneficiaryCardMobile(
                  beneficiary: b,
                  fallbackSymbol: report.fallbackSymbol,
                  theme: theme,
                );
              }).toList(),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.0), // Beneficiary Name
                  1: FlexColumnWidth(1.4), // Type/Level
                  2: FlexColumnWidth(1.0), // Percentage
                  3: FlexColumnWidth(1.3), // Gross
                  4: FlexColumnWidth(1.1), // TDS
                  5: FlexColumnWidth(1.3), // After TDS
                  6: FlexColumnWidth(1.2), // Payout Charge
                  7: FlexColumnWidth(1.4), // Final Amount
                },
                border: TableBorder.symmetric(
                  inside: BorderSide(
                    color: theme.canvasColor.withValues(alpha: 0.08),
                  ),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                    ),
                    children: const [
                      _TableCellHeader('Beneficiary'),
                      _TableCellHeader('Type / Level'),
                      _TableCellHeader('Share %', alignRight: true),
                      _TableCellHeader('Gross', alignRight: true),
                      _TableCellHeader('TDS', alignRight: true),
                      _TableCellHeader('After TDS', alignRight: true),
                      _TableCellHeader('Payout Chg', alignRight: true),
                      _TableCellHeader('Final Amount', alignRight: true),
                    ],
                  ),
                  ...beneficiaries.map((b) {
                    final typeStr = b.formattedBeneficiaryType;
                    final levelStr = b.formattedPromoterLevel;
                    final typeLevel = (levelStr != "—") ? "$typeStr ($levelStr)" : typeStr;
                    final displayGross = _ensureCurrency(b.gross?.toString() ?? "—", report.fallbackSymbol);
                    final displayTds = _ensureCurrency(b.tds?.toString() ?? "—", report.fallbackSymbol);
                    final displayAfterTds = _ensureCurrency(b.afterTds?.toString() ?? "—", report.fallbackSymbol);
                    final displayPayoutChg = _ensureCurrency(b.payoutCharge?.toString() ?? "—", report.fallbackSymbol);
                    final displayFinal = _ensureCurrency(b.finalAmount?.toString() ?? "—", report.fallbackSymbol);

                    return TableRow(
                      children: [
                        _TableCell(b.beneficiaryName ?? "—", isBold: true),
                        _TableCell(typeLevel),
                        _TableCell(b.formattedPercentage, alignRight: true),
                        _TableCell(displayGross, alignRight: true),
                        _TableCell(displayTds, alignRight: true),
                        _TableCell(displayAfterTds, alignRight: true),
                        _TableCell(displayPayoutChg, alignRight: true),
                        _TableCell(displayFinal, alignRight: true, isHighlight: true),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BeneficiaryCardMobile extends StatelessWidget {
  const _BeneficiaryCardMobile({
    required this.beneficiary,
    required this.fallbackSymbol,
    required this.theme,
  });

  final BeneficiarySettlementModel beneficiary;
  final String fallbackSymbol;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final typeStr = beneficiary.formattedBeneficiaryType;
    final levelStr = beneficiary.formattedPromoterLevel;
    final typeLevel = (levelStr != "—") ? "$typeStr ($levelStr)" : typeStr;

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.canvasColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        title: Text(
          beneficiary.beneficiaryName ?? "Beneficiary",
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          "Final: ${_ensureCurrency(beneficiary.finalAmount?.toString() ?? "—", fallbackSymbol)}",
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                _KvRow(theme, "Type / Level", typeLevel),
                _KvRow(theme, "Percentage", beneficiary.formattedPercentage),
                _KvRow(theme, "Gross Amount", _ensureCurrency(beneficiary.gross?.toString() ?? "—", fallbackSymbol)),
                _KvRow(theme, "TDS Amount", _ensureCurrency(beneficiary.tds?.toString() ?? "—", fallbackSymbol)),
                _KvRow(theme, "After TDS", _ensureCurrency(beneficiary.afterTds?.toString() ?? "—", fallbackSymbol)),
                _KvRow(theme, "Payout Charge", _ensureCurrency(beneficiary.payoutCharge?.toString() ?? "—", fallbackSymbol)),
                if (beneficiary.promoterAllocation != null)
                  _KvRow(theme, "Promoter Allocation", _ensureCurrency(beneficiary.promoterAllocation?.toString() ?? "—", fallbackSymbol)),
                if (beneficiary.roundingDifference != null)
                  _KvRow(theme, "Rounding Difference", _ensureCurrency(beneficiary.roundingDifference?.toString() ?? "—", fallbackSymbol)),
                _KvRow(theme, "Final Amount", _ensureCurrency(beneficiary.finalAmount?.toString() ?? "—", fallbackSymbol), isHighlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCellHeader extends StatelessWidget {
  const _TableCellHeader(this.text, {this.alignRight = false});

  final String text;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(
    this.text, {
    this.alignRight = false,
    this.isBold = false,
    this.isHighlight = false,
  });

  final String text;
  final bool alignRight;
  final bool isBold;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: (isBold || isHighlight) ? FontWeight.bold : FontWeight.normal,
          color: isHighlight ? theme.primaryColor : theme.canvasColor,
        ),
      ),
    );
  }
}

class _TaxAndChargeSummarySection extends StatelessWidget {
  const _TaxAndChargeSummarySection({
    required this.summary,
    required this.fallbackSymbol,
    required this.theme,
  });

  final TaxAndChargeSummaryModel summary;
  final String fallbackSymbol;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ChargeItem("GST Included", _ensureCurrency(summary.gstIncluded?.toString() ?? "—", fallbackSymbol), false),
      _ChargeItem("Razorpay Fee", _ensureCurrency(summary.razorpayCollectionFee?.toString() ?? "—", fallbackSymbol), false),
      _ChargeItem("Media House TDS", _ensureCurrency(summary.mediaHouseTds?.toString() ?? "—", fallbackSymbol), false),
      _ChargeItem("Media House Payout Chg", _ensureCurrency(summary.mediaHousePayoutCharge?.toString() ?? "—", fallbackSymbol), false),
      _ChargeItem("Promoter TDS", _ensureCurrency(summary.promoterTds?.toString() ?? "—", fallbackSymbol), false),
      _ChargeItem("Promoter Payout Chg", _ensureCurrency(summary.promoterPayoutCharge?.toString() ?? "—", fallbackSymbol), false),
      _ChargeItem("Total TDS", _ensureCurrency(summary.totalTds?.toString() ?? "—", fallbackSymbol), true),
      _ChargeItem("Total Payout Charge", _ensureCurrency(summary.totalPayoutCharge?.toString() ?? "—", fallbackSymbol), true),
    ];

    return _SectionContainer(
      theme: theme,
      title: "Taxes and Charges",
      icon: Icons.request_quote_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth >= 1000
              ? 4
              : (constraints.maxWidth >= 600 ? 2 : 1);

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 76,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: item.isTotal
                      ? theme.primaryColor.withValues(alpha: 0.12)
                      : theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isTotal
                        ? theme.primaryColor.withValues(alpha: 0.3)
                        : theme.canvasColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: item.isTotal ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.isTotal ? theme.primaryColor : theme.canvasColor,
                        fontSize: item.isTotal ? 15 : 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChargeItem {
  final String label;
  final String value;
  final bool isTotal;

  _ChargeItem(this.label, this.value, this.isTotal);
}

class _FinalSummarySection extends StatelessWidget {
  const _FinalSummarySection({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = report.finalSummary;

    return _SectionContainer(
      theme: theme,
      title: "Final Settlement Summary",
      icon: Icons.fact_check_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth >= 1050
              ? 5
              : (constraints.maxWidth >= 700 ? 3 : (constraints.maxWidth >= 480 ? 2 : 1));

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 90,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final iconData = _mapIcon(item.icon);
              final displayAmount = _ensureCurrency(item.amount, report.fallbackSymbol);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(iconData, color: theme.primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.canvasColor.withValues(alpha: 0.65),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              displayAmount,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.theme,
    required this.title,
    required this.icon,
    required this.child,
  });

  final ThemeData theme;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.theme,
  });

  final String status;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final statusUpper = status.toUpperCase();
    Color textColor;
    Color bgColor;

    if (statusUpper.contains("COMPLETED") || statusUpper.contains("SUCCESS") || statusUpper.contains("PAID")) {
      textColor = Colors.green.shade800;
      bgColor = Colors.green.shade50;
    } else if (statusUpper.contains("PENDING")) {
      textColor = Colors.orange.shade800;
      bgColor = Colors.orange.shade50;
    } else if (statusUpper.contains("PROCESSING")) {
      textColor = Colors.blue.shade800;
      bgColor = Colors.blue.shade50;
    } else if (statusUpper.contains("FAILED") || statusUpper.contains("REJECT") || statusUpper.contains("CANCEL")) {
      textColor = Colors.red.shade800;
      bgColor = Colors.red.shade50;
    } else {
      textColor = Colors.grey.shade800;
      bgColor = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusUpper,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow(this.theme, this.label, this.value, {this.isHighlight = false});

  final ThemeData theme;
  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? theme.primaryColor : theme.canvasColor,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.theme,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 48),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _mapIcon(String? name) {
  if (name == null || name.trim().isEmpty) return Icons.analytics_outlined;
  final key = name.trim().toLowerCase();
  if (key.contains("receipt")) return Icons.receipt_long_outlined;
  if (key.contains("base")) return Icons.layers_outlined;
  if (key.contains("gst")) return Icons.percent_outlined;
  if (key.contains("wallet")) return Icons.account_balance_wallet_outlined;
  if (key.contains("settlement")) return Icons.payments_outlined;
  if (key.contains("production") || key.contains("media")) return Icons.business_outlined;
  if (key.contains("promoter")) return Icons.groups_outlined;
  if (key.contains("tax")) return Icons.request_quote_outlined;
  if (key.contains("charge") || key.contains("fee")) return Icons.sell_outlined;
  return Icons.analytics_outlined;
}

String _ensureCurrency(String rawAmount, String fallbackSymbol) {
  final text = rawAmount.trim();
  if (text.isEmpty || text == "—" || text == "null") return "—";
  if (text.contains("Rs.") || text.contains("Rs") || text.contains("₹") || text.contains("\$") || text.contains("€")) {
    return text.replaceAll("Rs.", "₹").replaceAll("Rs", "₹");
  }
  return "$fallbackSymbol $text";
}

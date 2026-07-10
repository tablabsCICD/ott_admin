import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/weekly_settlement_report.dart';
import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';
import '../../../widgets/app_loaders.dart';

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
  late final Future<WeeklySettlementReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = context
        .read<SettelementProvider>()
        .fetchWeeklySettlementReport(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        title: Text(
          widget.transactionLabel ?? "Settlement Report",
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<WeeklySettlementReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppSpinner());
          }

          if (snapshot.hasError) {
            return _StatePanel(
              theme: theme,
              icon: Icons.error_outline,
              title: "Unable to load settlement details.",
            );
          }

          final report = snapshot.data;
          if (report == null) {
            return _StatePanel(
              theme: theme,
              icon: Icons.receipt_long_outlined,
              title: "No settlement details available.",
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(18),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: _SettlementDashboard(report: report, theme: theme),
                    ),
                  ),
                ),
              ),
            ],
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
    final mediaHouse = report.mediaHouseBeneficiary;
    final platform = report.platformBeneficiary;
    final promoters = report.promoterBeneficiaries;
    final mediaHouseFinal = _amount(mediaHouse.finalPayout) == 0
        ? report.amountFor(const ["media house final", "production final"])
        : _amount(mediaHouse.finalPayout);
    final platformFinal = _amount(platform.finalPayout) == 0
        ? report.amountFor(const ["platform final", "platform revenue"])
        : _amount(platform.finalPayout);
    final promoterFinal = promoters.fold<double>(
      0,
      (total, promoter) => total + _amount(promoter.finalPayout),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(report: report, theme: theme),
        const SizedBox(height: 16),
        SummaryCard(
          theme: theme,
          items: [
            SettlementSummaryItem(
              "Total Settlement Amount",
              _money(
                  report.amountFor(const [
                    "total settlement",
                    "settlement amount",
                    "customer payment",
                  ]),
                  report),
              Icons.account_balance_wallet_outlined,
              Colors.indigo,
            ),
            SettlementSummaryItem(
              "Customer Collection",
              _money(
                  report.amountFor(
                      const ["customer collection", "customer payment"]),
                  report),
              Icons.payments_outlined,
              Colors.green,
            ),
            SettlementSummaryItem(
              "Media House Payout",
              _money(mediaHouseFinal, report),
              Icons.home_work_outlined,
              Colors.teal,
            ),
            SettlementSummaryItem(
              "Platform Revenue",
              _money(platformFinal, report),
              Icons.trending_up_outlined,
              Colors.deepPurple,
            ),
            SettlementSummaryItem(
              "Total Transactions",
              "${report.totalTransactions ?? 1}",
              Icons.receipt_long_outlined,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettlementInfoCard(report: report, theme: theme),
        const SizedBox(height: 16),
        MoneyFlowTimeline(report: report, theme: theme),
        const SizedBox(height: 16),
        _BeneficiarySection(
          theme: theme,
          mediaHouse: mediaHouse,
          platform: platform,
          promoters: promoters,
          report: report,
        ),
        const SizedBox(height: 16),
        ChargesCard(report: report, theme: theme),
        const SizedBox(height: 16),
        FinalSummaryCard(
          report: report,
          theme: theme,
          mediaHouseFinal: mediaHouseFinal,
          promoterFinal: promoterFinal,
          platformFinal: platformFinal,
        ),
      ],
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.summarize_outlined, color: theme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    report.title ?? "Weekly Settlement Report",
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if ((report.status ?? "").trim().isNotEmpty)
                    _StatusBadge(status: report.status!, theme: theme),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "Financial dashboard for settlement ${report.settlementReference ?? report.transactionId ?? "-"}",
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.items,
    required this.theme,
  });

  final List<SettlementSummaryItem> items;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 5
            : constraints.maxWidth >= 820
                ? 3
                : constraints.maxWidth >= 560
                    ? 2
                    : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 108,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _Surface(
              theme: theme,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.value,
                            style: TextStyle(
                              color: theme.canvasColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.canvasColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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

class SettlementInfoCard extends StatelessWidget {
  const SettlementInfoCard({
    super.key,
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoVm("Settlement Reference",
          report.settlementReference ?? report.transactionId ?? "N/A"),
      _InfoVm("Status", report.status ?? "N/A", status: true),
      _InfoVm("Settlement Period", _period(report)),
      _InfoVm("Currency", report.currency ?? report.displayCurrencySymbol),
    ];

    return _SectionSurface(
      theme: theme,
      icon: Icons.info_outline,
      title: "Settlement Information",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 560
                  ? 2
                  : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 82,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: _innerDecoration(theme),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    item.status
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child:
                                _StatusBadge(status: item.value, theme: theme),
                          )
                        : Text(
                            item.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.canvasColor,
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

class MoneyFlowTimeline extends StatelessWidget {
  const MoneyFlowTimeline({
    super.key,
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final flow = [
      _FlowVm(
          "Customer Payment",
          _money(
              report
                  .amountFor(const ["customer payment", "customer collection"]),
              report),
          Icons.person_outline,
          Colors.green),
      _FlowVm("GST", _money(report.amountFor(const ["gst"]), report),
          Icons.percent_outlined, Colors.orange),
      _FlowVm(
          "Base Amount",
          _money(report.amountFor(const ["base amount", "base movie"]), report),
          Icons.movie_outlined,
          Colors.blue),
      _FlowVm(
          "Razorpay Fee",
          _money(
              report.amountFor(const ["razorpay", "payment gateway"]), report),
          Icons.credit_card_outlined,
          Colors.redAccent),
      _FlowVm(
          "Net Revenue",
          _money(report.amountFor(const ["net revenue", "net amount"]), report),
          Icons.account_balance_outlined,
          Colors.indigo),
    ];

    return _SectionSurface(
      theme: theme,
      icon: Icons.timeline_outlined,
      title: "Money Flow",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 780;
          if (compact) {
            return Column(
              children: [
                for (var i = 0; i < flow.length; i++) ...[
                  _FlowNode(item: flow[i], theme: theme, expanded: true),
                  if (i != flow.length - 1) _DownConnector(theme: theme),
                ],
                _SplitTargets(report: report, theme: theme),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  for (var i = 0; i < flow.length; i++) ...[
                    Expanded(child: _FlowNode(item: flow[i], theme: theme)),
                    if (i != flow.length - 1)
                      Icon(Icons.arrow_forward, color: theme.primaryColor),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _SplitTargets(report: report, theme: theme),
            ],
          );
        },
      ),
    );
  }
}

class BeneficiaryCard extends StatelessWidget {
  const BeneficiaryCard({
    super.key,
    required this.beneficiary,
    required this.report,
    required this.theme,
    required this.icon,
    required this.color,
    this.platformMode = false,
  });

  final SettlementBeneficiary beneficiary;
  final WeeklySettlementReportData report;
  final ThemeData theme;
  final IconData icon;
  final Color color;
  final bool platformMode;

  @override
  Widget build(BuildContext context) {
    final rows = platformMode
        ? [
            _InfoVm("Gross Revenue",
                _money(_amount(beneficiary.grossAmount), report)),
            _InfoVm(
                "Promoter Allocation",
                _money(
                    report.promoterBeneficiaries.fold<double>(
                      0,
                      (total, promoter) =>
                          total + _amount(promoter.grossAmount),
                    ),
                    report)),
            _InfoVm("Final Revenue",
                _money(_amount(beneficiary.finalPayout), report)),
          ]
        : [
            _InfoVm("Share Percentage", _percent(beneficiary.sharePercentage)),
            _InfoVm("Gross Amount",
                _money(_amount(beneficiary.grossAmount), report)),
            _InfoVm("TDS", _money(_amount(beneficiary.tds), report)),
            _InfoVm("Payout Charges",
                _money(_amount(beneficiary.payoutCharges), report)),
            _InfoVm("Final Payout",
                _money(_amount(beneficiary.finalPayout), report)),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _innerDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  beneficiary.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((row) =>
              _KeyValueRow(theme: theme, label: row.label, value: row.value)),
        ],
      ),
    );
  }
}

class ChargesCard extends StatelessWidget {
  const ChargesCard({
    super.key,
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final gst = report.amountFor(const ["gst"]);
    final razorpay = report.amountFor(const ["razorpay", "payment gateway"]);
    final tds = report.amountFor(const ["total tds", "tds"]);
    final payout = report.amountFor(const ["payout charges", "payout fee"]);
    final total = report.amountFor(const ["total charges"]) == 0
        ? gst + razorpay + tds + payout
        : report.amountFor(const ["total charges"]);

    return _SectionSurface(
      theme: theme,
      icon: Icons.receipt_long_outlined,
      title: "Charges",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = [
            SettlementSummaryItem("GST", _money(gst, report),
                Icons.percent_outlined, Colors.orange),
            SettlementSummaryItem("Razorpay Fee", _money(razorpay, report),
                Icons.credit_card_outlined, Colors.redAccent),
            SettlementSummaryItem("TDS", _money(tds, report),
                Icons.request_quote_outlined, Colors.purple),
            SettlementSummaryItem("Payout Charges", _money(payout, report),
                Icons.send_to_mobile_outlined, Colors.blue),
            SettlementSummaryItem("Total Charges", _money(total, report),
                Icons.summarize_outlined, theme.primaryColor),
          ];
          final columns = constraints.maxWidth >= 980
              ? 5
              : constraints.maxWidth >= 700
                  ? 3
                  : constraints.maxWidth >= 460
                      ? 2
                      : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 92,
            ),
            itemBuilder: (context, index) =>
                _MiniMetric(item: items[index], theme: theme),
          );
        },
      ),
    );
  }
}

class FinalSummaryCard extends StatelessWidget {
  const FinalSummaryCard({
    super.key,
    required this.report,
    required this.theme,
    required this.mediaHouseFinal,
    required this.promoterFinal,
    required this.platformFinal,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;
  final double mediaHouseFinal;
  final double promoterFinal;
  final double platformFinal;

  @override
  Widget build(BuildContext context) {
    final totalTds = report.amountFor(const ["total tds", "tds"]);
    final totalCharges = report.amountFor(const ["total charges"]) == 0
        ? report.amountFor(const ["gst"]) +
            report.amountFor(const ["razorpay", "payment gateway"]) +
            totalTds +
            report.amountFor(const ["payout charges", "payout fee"])
        : report.amountFor(const ["total charges"]);

    final items = [
      SettlementSummaryItem(
          "Media House Final",
          _money(mediaHouseFinal, report),
          Icons.home_work_outlined,
          Colors.teal),
      SettlementSummaryItem("Promoter Final", _money(promoterFinal, report),
          Icons.groups_2_outlined, Colors.blue),
      SettlementSummaryItem("Platform Final", _money(platformFinal, report),
          Icons.account_balance_wallet_outlined, Colors.deepPurple),
      SettlementSummaryItem("Total TDS", _money(totalTds, report),
          Icons.request_quote_outlined, Colors.purple),
      SettlementSummaryItem("Total Charges", _money(totalCharges, report),
          Icons.receipt_long_outlined, theme.primaryColor),
    ];

    return _SectionSurface(
      theme: theme,
      icon: Icons.fact_check_outlined,
      title: "Final Settlement Summary",
      child: SummaryCard(items: items, theme: theme),
    );
  }
}

class _BeneficiarySection extends StatelessWidget {
  const _BeneficiarySection({
    required this.theme,
    required this.mediaHouse,
    required this.platform,
    required this.promoters,
    required this.report,
  });

  final ThemeData theme;
  final SettlementBeneficiary mediaHouse;
  final SettlementBeneficiary platform;
  final List<SettlementBeneficiary> promoters;
  final WeeklySettlementReportData report;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      theme: theme,
      icon: Icons.account_tree_outlined,
      title: "Beneficiaries",
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 780;
              final children = [
                BeneficiaryCard(
                  beneficiary: mediaHouse,
                  report: report,
                  theme: theme,
                  icon: Icons.home_work_outlined,
                  color: Colors.teal,
                ),
                BeneficiaryCard(
                  beneficiary: platform,
                  report: report,
                  theme: theme,
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.deepPurple,
                  platformMode: true,
                ),
              ];
              if (!twoColumns) {
                return Column(
                  children: [
                    children[0],
                    const SizedBox(height: 10),
                    children[1],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  const SizedBox(width: 10),
                  Expanded(child: children[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (promoters.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: _innerDecoration(theme),
              child: Text(
                "No promoter earnings available for this settlement.",
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 3
                    : constraints.maxWidth >= 640
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: promoters.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 218,
                  ),
                  itemBuilder: (context, index) {
                    return BeneficiaryCard(
                      beneficiary: promoters[index],
                      report: report,
                      theme: theme,
                      icon: Icons.groups_2_outlined,
                      color: Colors.blue,
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SplitTargets extends StatelessWidget {
  const _SplitTargets({
    required this.report,
    required this.theme,
  });

  final WeeklySettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      SettlementSummaryItem(
          "Media House",
          _money(_amount(report.mediaHouseBeneficiary.finalPayout), report),
          Icons.home_work_outlined,
          Colors.teal),
      SettlementSummaryItem(
          "Promoters",
          _money(
              report.promoterBeneficiaries.fold<double>(
                0,
                (total, promoter) => total + _amount(promoter.finalPayout),
              ),
              report),
          Icons.groups_2_outlined,
          Colors.blue),
      SettlementSummaryItem(
          "Platform",
          _money(_amount(report.platformBeneficiary.finalPayout), report),
          Icons.account_balance_wallet_outlined,
          Colors.deepPurple),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _innerDecoration(theme),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 3 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 78,
            ),
            itemBuilder: (context, index) =>
                _MiniMetric(item: items[index], theme: theme),
          );
        },
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.item,
    required this.theme,
    this.expanded = false,
  });

  final _FlowVm item;
  final ThemeData theme;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: _innerDecoration(theme),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.62),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.item,
    required this.theme,
  });

  final SettlementSummaryItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: _innerDecoration(theme),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({
    required this.theme,
    required this.icon,
    required this.title,
    required this.child,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor, size: 22),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
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

class _Surface extends StatelessWidget {
  const _Surface({
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final ThemeData theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
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
    final color = _statusColor(status, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.62),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownConnector extends StatelessWidget {
  const _DownConnector({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Icon(Icons.keyboard_arrow_down, color: theme.primaryColor),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.theme,
    required this.icon,
    required this.title,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettlementSummaryItem {
  const SettlementSummaryItem(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _InfoVm {
  const _InfoVm(this.label, this.value, {this.status = false});

  final String label;
  final String value;
  final bool status;
}

class _FlowVm {
  const _FlowVm(this.title, this.value, this.icon, this.color);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

BoxDecoration _innerDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.scaffoldBackgroundColor.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.56 : 0.9,
    ),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
  );
}

Color _statusColor(String status, ThemeData theme) {
  final normalized = status.toLowerCase();
  if (normalized.contains("paid") ||
      normalized.contains("complete") ||
      normalized.contains("success")) {
    return Colors.green;
  }
  if (normalized.contains("pending") || normalized.contains("process")) {
    return Colors.orange;
  }
  if (normalized.contains("fail") ||
      normalized.contains("reject") ||
      normalized.contains("cancel")) {
    return Colors.redAccent;
  }
  return theme.primaryColor;
}

String _period(WeeklySettlementReportData report) {
  if (report.periodStart != null && report.periodEnd != null) {
    final formatter = DateFormat("dd MMM yyyy");
    return "${formatter.format(report.periodStart!)} \u2013 ${formatter.format(report.periodEnd!)}";
  }
  final text = report.settlementPeriod?.trim();
  if (text != null && text.isNotEmpty) {
    return text.replaceAll(" - ", " \u2013 ").replaceAll(" to ", " \u2013 ");
  }
  return "N/A";
}

String _money(double amount, WeeklySettlementReportData report) {
  final symbol = report.displayCurrencySymbol;
  final formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 2,
    locale: symbol == "\u20B9" ? "en_IN" : "en_US",
  );
  return formatter.format(amount);
}

String _percent(String? value) {
  final amount = _amount(value);
  if (amount == 0) return "0%";
  return "${NumberFormat("0.##").format(amount)}%";
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  final text = value
          ?.toString()
          .replaceAll(",", "")
          .replaceAll("\u20B9", "")
          .replaceAll("Rs.", "")
          .replaceAll("Rs", "")
          .replaceAll("%", "")
          .trim() ??
      "";
  return double.tryParse(RegExp(r"-?\d+(\.\d+)?").stringMatch(text) ?? "") ?? 0;
}

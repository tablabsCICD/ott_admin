import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/stat_tile.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/buildList.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PromoterDetailsPage extends StatefulWidget {
  final Promoters promoter;

  const PromoterDetailsPage({super.key, required this.promoter});

  @override
  State<PromoterDetailsPage> createState() => _PromoterDetailsPageState();
}

class _PromoterDetailsPageState extends State<PromoterDetailsPage> {
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final userProvider = Provider.of<PromoterProvider>(context, listen: false);
    final referralCode = widget.promoter.userId?.refferCode;
    if (referralCode == null || referralCode.isEmpty) return;
    await userProvider.getUsersByUserReferalCode(referralCode);
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final promoter = widget.promoter;
    final user = promoter.userId;
    final location = user?.location;
    final locationText = [
      location?.taluka,
      location?.district,
      location?.state,
      location?.country
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraphPage(promoters: promoter),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  'Analysis ',
                  style: TextStyle(
                    color: selectedThemeData.primaryColor,
                  ),
                ),
                Icon(
                  Icons.analytics_outlined,
                  color: selectedThemeData.primaryColor,
                ),
              ],
            ),
          )
        ],
        backgroundColor: selectedThemeData.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Joining date: ${promoter.createdDate ?? "N/A"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 50,
              ),
              const SizedBox(height: 20),
              Text(
                promoter.promoterName ?? "Unknown Promoter",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.emailId ?? "N/A",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                user?.mobileNumber ?? "N/A",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                locationText.isEmpty ? "Location: N/A" : locationText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Consumer<PromoterProvider>(builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatTile(label: 'Refer', value: provider.refer ?? '0'),
                    StatTile(
                        label: 'Incentive', value: provider.incentive ?? '0'),
                    StatTile(label: 'Revenue', value: provider.revenue ?? '0'),
                  ],
                );
              }),
              const SizedBox(height: 20),
              Consumer<PromoterProvider>(builder: (context, provider, child) {
                return _buildRevenueCalculationCard(
                  selectedThemeData,
                  provider.revenue ?? '0',
                );
              }),
              const SizedBox(height: 20),
              _buildBankDetailsCard(selectedThemeData, promoter),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: Colors.grey.withValues(alpha: 0.4),
                  thickness: 1,
                ),
              ),
              SizedBox(
                height: 800,
                width: double.infinity,
                child: BuildList(widget.promoter),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(ThemeData theme, Promoters promoter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank & Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildDetailItem('Bank Name', promoter.bankName),
              _buildDetailItem('Branch Name', promoter.branchName),
              _buildDetailItem('Account Number', promoter.accountNumber),
              _buildDetailItem('IFSC Code', promoter.ifscCode),
              _buildDetailItem('PAN Card', promoter.panCard),
              _buildDetailItem('Aadhaar Card', promoter.aadharCard),
              _buildDetailItem('GST Number', promoter.gst),
              _buildDetailItem('Website', promoter.website),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCalculationCard(ThemeData theme, String revenue) {
    final calculation = _promoterRevenueCalculation(revenue);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.calculate_outlined,
                  color: theme.primaryColor, size: 22),
              const Text(
                'Revenue Calculation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _calculationBadge(theme, 'Promoter Settlement'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Detailed flow for promoter payout from customer payment to final wallet credit.',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _calculationStep(
            theme,
            'Step 1',
            'Calculate base revenue',
            [
              _CalculationLine(
                  'Customer Payment', '-', _formatMoney(calculation.gross)),
              _CalculationLine('GST Amount', 'Customer Payment - Base',
                  _formatMoney(calculation.gst)),
              _CalculationLine('Base Revenue', 'Customer Payment - GST',
                  _formatMoney(calculation.base)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 920;
              final steps = [
                _calculationStep(
                  theme,
                  'Step 2',
                  'Promoter share',
                  [
                    const _CalculationLine(
                        'Promoter %', 'Selected level percentage', '1%'),
                    _CalculationLine(
                        'Promoter Share',
                        'Base Revenue x Promoter %',
                        _formatMoney(calculation.share)),
                  ],
                ),
                _calculationStep(
                  theme,
                  'Step 3',
                  'Deductions and wallet credit',
                  [
                    _CalculationLine('TDS', 'Promoter Share x 10%',
                        _formatMoney(calculation.tds)),
                    _CalculationLine('Settlement Charges', 'Transfer charge',
                        _formatMoney(calculation.charges)),
                    _CalculationLine('Wallet Credit', 'Share - TDS - Charges',
                        _formatMoney(calculation.wallet)),
                  ],
                ),
              ];
              if (!twoColumns) {
                return Column(
                  children: [
                    steps[0],
                    const SizedBox(height: 12),
                    steps[1],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: steps[0]),
                  const SizedBox(width: 12),
                  Expanded(child: steps[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _calculationTable(
            theme,
            'Promoter Settlement Summary',
            const ['Description', 'Formula', 'Amount'],
            [
              ['Customer Payment', '-', _formatMoney(calculation.gross)],
              [
                'GST Amount',
                'Customer Payment - Base Revenue',
                _formatMoney(calculation.gst)
              ],
              [
                'Base Revenue',
                'Customer Payment - GST',
                _formatMoney(calculation.base)
              ],
              [
                'Promoter Share',
                'Base Revenue x 1%',
                _formatMoney(calculation.share)
              ],
              ['TDS', 'Promoter Share x 10%', _formatMoney(calculation.tds)],
              [
                'Settlement Charges',
                'Transfer charge',
                _formatMoney(calculation.charges)
              ],
              [
                'Wallet Credit',
                'Share - TDS - Charges',
                _formatMoney(calculation.wallet)
              ],
            ],
            highlightLast: true,
          ),
        ],
      ),
    );
  }

  Widget _calculationStep(
    ThemeData theme,
    String step,
    String title,
    List<_CalculationLine> rows,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.56 : 0.92,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                _calculationBadge(theme, step),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map((row) => _calculationLine(theme, row)),
        ],
      ),
    );
  }

  Widget _calculationLine(ThemeData theme, _CalculationLine row) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final label = Text(
          row.label,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w800,
          ),
        );
        final formula = Text(
          row.formula,
          textAlign: compact ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.62),
            fontWeight: FontWeight.w700,
          ),
        );
        final amount = Text(
          row.amount,
          textAlign: compact ? TextAlign.start : TextAlign.end,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w900,
          ),
        );

        if (compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                const SizedBox(height: 4),
                formula,
                const SizedBox(height: 4),
                amount,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Expanded(flex: 3, child: label),
              Expanded(flex: 3, child: formula),
              Expanded(flex: 2, child: amount),
            ],
          ),
        );
      },
    );
  }

  Widget _calculationTable(
    ThemeData theme,
    String title,
    List<String> columns,
    List<List<String>> rows, {
    bool highlightLast = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.56 : 0.92,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Text(
              title,
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth =
                  constraints.maxWidth < 760 ? 760.0 : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      _calculationTableRow(
                        theme,
                        columns,
                        isHeader: true,
                        isHighlighted: false,
                      ),
                      ...rows.asMap().entries.map((entry) {
                        return _calculationTableRow(
                          theme,
                          entry.value,
                          isHeader: false,
                          isHighlighted:
                              highlightLast && entry.key == rows.length - 1,
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _calculationTableRow(
    ThemeData theme,
    List<String> cells, {
    required bool isHeader,
    required bool isHighlighted,
  }) {
    final background = isHeader
        ? theme.primaryColor.withValues(alpha: 0.1)
        : isHighlighted
            ? theme.primaryColor.withValues(alpha: 0.08)
            : Colors.transparent;

    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: List.generate(cells.length, (index) {
          return Expanded(
            flex: index == 0 ? 2 : 1,
            child: Padding(
              padding:
                  EdgeInsets.only(right: index == cells.length - 1 ? 0 : 12),
              child: Text(
                cells[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: index == 0 ? TextAlign.start : TextAlign.end,
                style: TextStyle(
                  color: isHeader ? theme.primaryColor : theme.canvasColor,
                  fontWeight: isHeader || isHighlighted
                      ? FontWeight.w900
                      : FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _calculationBadge(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  _PromoterRevenueCalculation _promoterRevenueCalculation(String revenue) {
    final gross = _parseMoney(revenue);
    final base = gross == 0 ? 0.0 : gross / 1.18;
    final gst = gross - base;
    final share = base * 0.01;
    final tds = share * 0.10;
    final afterTds = share - tds;
    final charges = afterTds * 0.02;
    final wallet = afterTds - charges;

    return _PromoterRevenueCalculation(
      gross: gross,
      base: base,
      gst: gst,
      share: share,
      tds: tds,
      charges: charges,
      wallet: wallet,
    );
  }

  double _parseMoney(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatMoney(double value) {
    if (value == 0) return 'Rs. 0';
    final rounded = value.round();
    final text = rounded.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d\d)+\d$)'),
          (match) => '${match[1]},',
        );
    return 'Rs. $text';
  }

  Widget _buildDetailItem(String label, String? value) {
    final displayValue =
        value == null || value.trim().isEmpty ? 'N/A' : value.trim();

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class GraphPage extends StatefulWidget {
  final Promoters promoters;
  const GraphPage({super.key, required this.promoters});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String selectedButton = '1W'; // Default selected button
  String selectedGraphType = 'Revenue'; // Default graph type
  List<ChartData> chartData = []; // Initialize with an empty list
  List<ChartData> filteredData = []; // Initialize with an empty list

  Future<void> getUserData() async {
    final userProvider = Provider.of<PromoterProvider>(context, listen: false);
    final promoterId = widget.promoters.id;
    if (promoterId == null) {
      setState(() {
        chartData = [];
        filteredData = [];
      });
      return;
    }
    await userProvider.getUsersAndRevenue(promoterId);
    if (!mounted) return;

    setState(() {
      chartData = userProvider.promoterUserRevenueGraph
          .where((entry) =>
              entry.date != null &&
              entry.revenue != null &&
              entry.usersOnboarded != null)
          .map((entry) =>
              ChartData(entry.date!, entry.revenue!, entry.usersOnboarded!))
          .toList();
      filteredData = getFilteredData(7); // Default to 1W data
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<ChartData> getFilteredData(int count) {
    return count > chartData.length
        ? chartData
        : chartData.sublist(chartData.length - count);
  }

  void updateGraph(String buttonLabel, int days) {
    setState(() {
      selectedButton = buttonLabel;
      filteredData = getFilteredData(days);
    });
  }

  void switchGraphType(String type) {
    setState(() {
      selectedGraphType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis"),
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        actions: [
          DropdownButton<String>(
            value: selectedGraphType,
            dropdownColor: selectedThemeData.cardColor,
            icon: Icon(Icons.arrow_drop_down,
                color: selectedThemeData.canvasColor),
            underline: const SizedBox(),
            items: ['Revenue', 'Users Onboarded'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: selectedThemeData.canvasColor),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) switchGraphType(newValue);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(
                    text: selectedGraphType == 'Revenue'
                        ? 'Revenue Analysis'
                        : 'User Onboarding Analysis'),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: filteredData,
                    xValueMapper: (ChartData data, _) => data.date,
                    yValueMapper: (ChartData data, _) =>
                        selectedGraphType == 'Revenue'
                            ? data.revenue
                            : data.usersOnboarded,
                    color: selectedThemeData.primaryColor,
                    markerSettings: const MarkerSettings(isVisible: true),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton('1W', 7, selectedThemeData),
                _buildOptionButton('1M', 30, selectedThemeData),
                _buildOptionButton('3M', 90, selectedThemeData),
                _buildOptionButton('6M', 180, selectedThemeData),
                _buildOptionButton('1Y', 365, selectedThemeData),
                _buildOptionButton('All', chartData.length, selectedThemeData),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label, int days, selectedThemeData) {
    final isSelected = selectedButton == label;
    return GestureDetector(
      onTap: () => updateGraph(label, days),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE50914)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : selectedThemeData.canvasColor,
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String date;
  final double revenue;
  final int usersOnboarded;

  ChartData(this.date, this.revenue, this.usersOnboarded);
}

class _PromoterRevenueCalculation {
  const _PromoterRevenueCalculation({
    required this.gross,
    required this.base,
    required this.gst,
    required this.share,
    required this.tds,
    required this.charges,
    required this.wallet,
  });

  final double gross;
  final double base;
  final double gst;
  final double share;
  final double tds;
  final double charges;
  final double wallet;
}

class _CalculationLine {
  const _CalculationLine(this.label, this.formula, this.amount);

  final String label;
  final String formula;
  final String amount;
}

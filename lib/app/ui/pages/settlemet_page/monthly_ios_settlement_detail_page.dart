import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/monthly_ios_settlement.dart';
import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';
import '../../../widgets/app_loaders.dart';

class MonthlyIosSettlementDetailPage extends StatefulWidget {
  const MonthlyIosSettlementDetailPage({
    super.key,
    required this.settlementId,
    this.title,
  });

  final dynamic settlementId;
  final String? title;

  @override
  State<MonthlyIosSettlementDetailPage> createState() =>
      _MonthlyIosSettlementDetailPageState();
}

class _MonthlyIosSettlementDetailPageState
    extends State<MonthlyIosSettlementDetailPage> {
  late final Future<MonthlySettlementDetailModel> _future;
  final _horizontalController = ScrollController();
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _future = context
        .read<SettelementProvider>()
        .fetchMonthlySettlementDetail(widget.settlementId);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        title: Text(
          widget.title ?? 'Monthly iOS Settlement',
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _downloading ? null : _download,
              icon: _downloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(_downloading ? 'Downloading...' : 'Download CSV'),
            ),
          ),
        ],
      ),
      body: FutureBuilder<MonthlySettlementDetailModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppSpinner());
          }
          if (snapshot.hasError) {
            return _StatePanel(
              theme: theme,
              icon: Icons.error_outline,
              title: 'Unable to load monthly settlement details.',
            );
          }
          final detail = snapshot.data;
          if (detail == null) {
            return _StatePanel(
              theme: theme,
              icon: Icons.receipt_long_outlined,
              title: 'No settlement details available.',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(detail: detail, theme: theme),
                          const SizedBox(height: 16),
                          _SummaryGrid(detail: detail, theme: theme),
                          const SizedBox(height: 16),
                          _TransactionTable(
                            detail: detail,
                            theme: theme,
                            controller: _horizontalController,
                          ),
                        ],
                      ),
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

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      await context
          .read<SettelementProvider>()
          .downloadMonthlySettlement(widget.settlementId);
      if (!mounted) return;
      _showMessage('CSV downloaded successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to download settlement CSV.', isError: true);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.detail,
    required this.theme,
  });

  final MonthlySettlementDetailModel detail;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.phone_iphone_outlined, color: theme.primaryColor),
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
                          'Monthly iOS Settlement Report',
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _StatusBadge(status: detail.status ?? 'N/A', theme: theme),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _displayMonth(detail.settlementMonth),
                      style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final items = [
                _InfoVm('Settlement Month', _displayMonth(detail.settlementMonth)),
                _InfoVm('Settlement Period', _period(detail)),
                _InfoVm('Operating System', detail.operatingSystem ?? 'iOS'),
                _InfoVm('Payment Gateway', detail.paymentGateway ?? 'Apple'),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 76,
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
                        const SizedBox(height: 6),
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

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.detail,
    required this.theme,
  });

  final MonthlySettlementDetailModel detail;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cards = detail.summaryCards;
    if (cards.isEmpty) {
      return _Surface(
        theme: theme,
        child: Text(
          'No summary data available.',
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.68),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 4
            : constraints.maxWidth >= 760
                ? 3
                : constraints.maxWidth >= 520
                    ? 2
                    : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 108,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            final color = _summaryColor(index, theme);
            return _Surface(
              theme: theme,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_summaryIcon(card.label), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _summaryValue(card.value),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          card.label,
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

class _TransactionTable extends StatelessWidget {
  const _TransactionTable({
    required this.detail,
    required this.theme,
    required this.controller,
  });

  final MonthlySettlementDetailModel detail;
  final ThemeData theme;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      theme: theme,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Transactions',
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (detail.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No transactions available for this settlement.',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Scrollbar(
              controller: controller,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1120),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Transaction ID')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Payment Date')),
                      DataColumn(label: Text('Requested Amount'), numeric: true),
                      DataColumn(label: Text('Deduction'), numeric: true),
                      DataColumn(label: Text('Credited Amount'), numeric: true),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('OS')),
                      DataColumn(label: Text('Gateway')),
                      DataColumn(label: Text('Deduction Reason')),
                    ],
                    rows: detail.transactions.map((transaction) {
                      return DataRow(
                        cells: [
                          DataCell(Text(transaction.transactionId ?? 'N/A')),
                          DataCell(Text(transaction.user ?? 'N/A')),
                          DataCell(Text(_displayDate(transaction.paymentDate))),
                          DataCell(Text(_money(transaction.requestedAmount))),
                          DataCell(Text(_money(transaction.deduction))),
                          DataCell(Text(_money(transaction.creditedAmount))),
                          DataCell(_StatusBadge(
                            status: transaction.status ?? 'N/A',
                            theme: theme,
                          )),
                          DataCell(Text(transaction.operatingSystem ?? 'iOS')),
                          DataCell(Text(transaction.gateway ?? 'Apple')),
                          DataCell(Text(transaction.deductionReason ?? 'N/A')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(16),
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
    );
  }
}

class _InfoVm {
  const _InfoVm(this.label, this.value);

  final String label;
  final String value;
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

String _period(MonthlySettlementDetailModel detail) {
  if (detail.periodStart != null && detail.periodEnd != null) {
    return '${_displayDate(detail.periodStart)} - ${_displayDate(detail.periodEnd)}';
  }
  return 'N/A';
}

String _displayMonth(String? value) {
  if (value == null || value.trim().isEmpty) return 'N/A';
  final parsed = DateTime.tryParse('$value-01') ?? DateTime.tryParse(value);
  if (parsed == null) return value;
  return DateFormat('MMMM yyyy').format(parsed);
}

String _displayDate(DateTime? value) {
  if (value == null) return 'N/A';
  return DateFormat('dd MMM yyyy').format(value);
}

String _money(num? value) {
  if (value == null) return '₹0.00';
  final text = value.toString();
  if (text.contains('.')) {
    final parts = text.split('.');
    final intPart = parts[0];
    var decPart = parts[1];
    if (decPart.length == 1) {
      decPart = '${decPart}0';
    }
    final formattedInt =
        NumberFormat('#,##,###', 'en_IN').format(int.tryParse(intPart) ?? 0);
    return '₹$formattedInt.$decPart';
  }
  final formattedInt =
      NumberFormat('#,##,###', 'en_IN').format(value.toInt());
  return '₹$formattedInt.00';
}

String _summaryValue(dynamic value) {
  if (value is num) return _money(value);
  final text = value?.toString() ?? 'N/A';
  final looksMoney =
      text.contains('₹') || text.contains('Rs') || text.contains('.');
  final numeric = double.tryParse(text
      .replaceAll(',', '')
      .replaceAll('₹', '')
      .replaceAll('Rs.', '')
      .replaceAll('Rs', '')
      .trim());
  if (numeric != null && looksMoney) return _money(numeric);
  return text;
}

IconData _summaryIcon(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('apple') || normalized.contains('deduction')) {
    return Icons.percent_outlined;
  }
  if (normalized.contains('transaction')) return Icons.receipt_long_outlined;
  if (normalized.contains('credit')) return Icons.account_balance_outlined;
  return Icons.payments_outlined;
}

Color _summaryColor(int index, ThemeData theme) {
  const colors = [
    Colors.indigo,
    Colors.orange,
    Colors.green,
    Colors.deepPurple,
    Colors.teal,
  ];
  return colors[index % colors.length];
}

Color _statusColor(String status, ThemeData theme) {
  final normalized = status.toLowerCase();
  if (normalized.contains('paid') ||
      normalized.contains('complete') ||
      normalized.contains('success')) {
    return Colors.green;
  }
  if (normalized.contains('pending') || normalized.contains('process')) {
    return Colors.orange;
  }
  if (normalized.contains('fail') ||
      normalized.contains('reject') ||
      normalized.contains('cancel')) {
    return Colors.redAccent;
  }
  return theme.primaryColor;
}

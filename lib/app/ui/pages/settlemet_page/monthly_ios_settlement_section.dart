import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/monthly_ios_settlement.dart';
import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';
import '../../../widgets/app_loaders.dart';
import 'monthly_ios_settlement_detail_page.dart';

class MonthlyIosSettlementSection extends StatefulWidget {
  const MonthlyIosSettlementSection({super.key});

  @override
  State<MonthlyIosSettlementSection> createState() =>
      _MonthlyIosSettlementSectionState();
}

class _MonthlyIosSettlementSectionState
    extends State<MonthlyIosSettlementSection> {
  final _userController = TextEditingController();
  final _listController = ScrollController();
  DateTime? _generateMonth;
  DateTime? _filterMonth;
  String? _status;
  bool _downloadBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SettelementProvider>();
      if (provider.monthlySettlements.isEmpty && !provider.monthlyLoading) {
        provider.fetchMonthlySettlements(refresh: true);
      }
    });
    _listController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _userController.dispose();
    _listController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_listController.hasClients) return;
    final position = _listController.position;
    if (position.pixels > position.maxScrollExtent - 240) {
      context.read<SettelementProvider>().loadMoreMonthlySettlements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Consumer<SettelementProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GenerateCard(
              theme: theme,
              selectedMonth: _generateMonth,
              generating: provider.monthlyGenerating,
              onPickMonth: () => _pickMonth(
                initial: _generateMonth,
                onSelected: (value) => setState(() => _generateMonth = value),
              ),
              onGenerate: () => _generate(provider),
            ),
            const SizedBox(height: 16),
            _FilterCard(
              theme: theme,
              selectedMonth: _filterMonth,
              status: _status,
              userController: _userController,
              onPickMonth: () => _pickMonth(
                initial: _filterMonth,
                onSelected: (value) => setState(() => _filterMonth = value),
              ),
              onStatusChanged: (value) => setState(() => _status = value),
              onSearch: () => provider.applyMonthlyFilters(
                month: _apiMonth(_filterMonth),
                status: _status,
                userId: _userController.text.trim(),
              ),
              onReset: () {
                setState(() {
                  _filterMonth = null;
                  _status = null;
                  _userController.clear();
                });
                provider.resetMonthlyFilters();
              },
            ),
            const SizedBox(height: 16),
            if (provider.monthlyLoading)
              const SizedBox(height: 260, child: Center(child: AppSpinner()))
            else if (provider.monthlyError != null)
              _StatePanel(
                theme: theme,
                icon: Icons.error_outline,
                title: provider.monthlyError!,
                actionLabel: 'Retry',
                onAction: () => provider.fetchMonthlySettlements(refresh: true),
              )
            else if (provider.monthlySettlements.isEmpty)
              _StatePanel(
                theme: theme,
                icon: Icons.calendar_month_outlined,
                title: 'No monthly iOS settlements available.',
                actionLabel: 'Refresh',
                onAction: () => provider.fetchMonthlySettlements(refresh: true),
              )
            else ...[
              _MonthlyCardRail(
                theme: theme,
                settlements: provider.monthlySettlements,
                downloadBusy: _downloadBusy,
                onView: _openDetail,
                onDownload: _download,
              ),
              const SizedBox(height: 18),
              _MonthlyTable(
                theme: theme,
                controller: _listController,
                settlements: provider.monthlySettlements,
                loadingMore: provider.monthlyLoadingMore,
                totalElements: provider.monthlyTotalElements,
                onView: _openDetail,
                onDownload: _download,
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _pickMonth({
    DateTime? initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(now.year, now.month),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select Month',
    );
    if (picked != null) onSelected(DateTime(picked.year, picked.month));
  }

  Future<void> _generate(SettelementProvider provider) async {
    final month = _apiMonth(_generateMonth);
    if (month == null) {
      _showMessage('Please select a month.', isError: true);
      return;
    }
    try {
      await provider.generateMonthlySettlement(month);
      if (!mounted) return;
      _showMessage('Monthly settlement generated successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to generate monthly iOS settlement.', isError: true);
    }
  }

  void _openDetail(MonthlySettlementModel settlement) {
    final id = settlement.id;
    if (id == null || id.toString().trim().isEmpty) {
      _showMessage('Settlement ID is missing.', isError: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MonthlyIosSettlementDetailPage(
          settlementId: id,
          title: _displayMonth(settlement.settlementMonth),
        ),
      ),
    );
  }

  Future<void> _download(MonthlySettlementModel settlement) async {
    final id = settlement.id;
    if (id == null || id.toString().trim().isEmpty) {
      _showMessage('Settlement ID is missing.', isError: true);
      return;
    }
    setState(() => _downloadBusy = true);
    try {
      await context.read<SettelementProvider>().downloadMonthlySettlement(id);
      if (!mounted) return;
      _showMessage('CSV downloaded successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to download settlement CSV.', isError: true);
    } finally {
      if (mounted) setState(() => _downloadBusy = false);
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

class _GenerateCard extends StatelessWidget {
  const _GenerateCard({
    required this.theme,
    required this.selectedMonth,
    required this.generating,
    required this.onPickMonth,
    required this.onGenerate,
  });

  final ThemeData theme;
  final DateTime? selectedMonth;
  final bool generating;
  final VoidCallback onPickMonth;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      theme: theme,
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: _MonthField(
              theme: theme,
              label: 'Select Month',
              value: _displayDateMonth(selectedMonth),
              onTap: onPickMonth,
            ),
          ),
          FilledButton.icon(
            onPressed: generating ? null : onGenerate,
            icon: generating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.playlist_add_check_outlined),
            label: Text(generating ? 'Generating...' : 'Generate Settlement'),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.theme,
    required this.selectedMonth,
    required this.status,
    required this.userController,
    required this.onPickMonth,
    required this.onStatusChanged,
    required this.onSearch,
    required this.onReset,
  });

  final ThemeData theme;
  final DateTime? selectedMonth;
  final String? status;
  final TextEditingController userController;
  final VoidCallback onPickMonth;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Monthly Filters',
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final fields = [
                _MonthField(
                  theme: theme,
                  label: 'Month',
                  value: _displayDateMonth(selectedMonth),
                  onTap: onPickMonth,
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: theme.cardColor,
                  iconEnabledColor: theme.canvasColor,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.72),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'PENDING',
                      child: Text(
                        'Pending',
                        style: TextStyle(color: theme.canvasColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'PAID',
                      child: Text(
                        'Paid',
                        style: TextStyle(color: theme.canvasColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'FAILED',
                      child: Text(
                        'Failed',
                        style: TextStyle(color: theme.canvasColor),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'COMPLETED',
                      child: Text(
                        'Completed',
                        style: TextStyle(color: theme.canvasColor),
                      ),
                    ),
                  ],
                  onChanged: onStatusChanged,
                ),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ];

              if (compact) {
                return Column(
                  children: fields
                      .map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: field,
                          ))
                      .toList(),
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    Expanded(child: fields[i]),
                    if (i != fields.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthField extends StatelessWidget {
  const _MonthField({
    required this.theme,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final ThemeData theme;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: value == 'Select month'
                ? theme.canvasColor.withValues(alpha: 0.52)
                : theme.canvasColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MonthlyCardRail extends StatelessWidget {
  const _MonthlyCardRail({
    required this.theme,
    required this.settlements,
    required this.downloadBusy,
    required this.onView,
    required this.onDownload,
  });

  final ThemeData theme;
  final List<MonthlySettlementModel> settlements;
  final bool downloadBusy;
  final ValueChanged<MonthlySettlementModel> onView;
  final ValueChanged<MonthlySettlementModel> onDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly iOS Settlement',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 244,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: settlements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              return SizedBox(
                width: 340,
                child: _SettlementCard(
                  theme: theme,
                  settlement: settlement,
                  downloadBusy: downloadBusy,
                  onView: () => onView(settlement),
                  onDownload: () => onDownload(settlement),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.theme,
    required this.settlement,
    required this.downloadBusy,
    required this.onView,
    required this.onDownload,
  });

  final ThemeData theme;
  final MonthlySettlementModel settlement;
  final bool downloadBusy;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      theme: theme,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _displayMonth(settlement.settlementMonth),
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusBadge(status: settlement.status ?? 'N/A', theme: theme),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(theme: theme, icon: Icons.phone_iphone, text: settlement.operatingSystem ?? 'iOS'),
              _Pill(theme: theme, icon: Icons.account_balance_wallet_outlined, text: settlement.paymentGateway ?? 'Apple'),
              _Pill(theme: theme, icon: Icons.receipt_long_outlined, text: '${settlement.totalTransactions ?? 0} Transactions'),
            ],
          ),
          const SizedBox(height: 12),
          _MoneyGrid(theme: theme, settlement: settlement),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: downloadBusy ? null : onDownload,
                tooltip: 'Download CSV',
                icon: const Icon(Icons.download_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyGrid extends StatelessWidget {
  const _MoneyGrid({
    required this.theme,
    required this.settlement,
  });

  final ThemeData theme;
  final MonthlySettlementModel settlement;

  @override
  Widget build(BuildContext context) {
    final items = [
      MapEntry('Customer', settlement.customerPayment),
      MapEntry('Apple Deduction', settlement.appleDeduction),
      MapEntry('Credited', settlement.creditedAmount),
      MapEntry('Net Settlement', settlement.netSettlement),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 52,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.62),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _money(item.value),
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
  }
}

class _MonthlyTable extends StatelessWidget {
  const _MonthlyTable({
    required this.theme,
    required this.controller,
    required this.settlements,
    required this.loadingMore,
    required this.totalElements,
    required this.onView,
    required this.onDownload,
  });

  final ThemeData theme;
  final ScrollController controller;
  final List<MonthlySettlementModel> settlements;
  final bool loadingMore;
  final int totalElements;
  final ValueChanged<MonthlySettlementModel> onView;
  final ValueChanged<MonthlySettlementModel> onDownload;

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
            child: Text(
              'Settlement Records ($totalElements)',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            height: 420,
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: controller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1260),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Settlement Month')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('OS')),
                        DataColumn(label: Text('Gateway')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Transactions'), numeric: true),
                        DataColumn(label: Text('Customer Payment'), numeric: true),
                        DataColumn(label: Text('Apple Deduction'), numeric: true),
                        DataColumn(label: Text('Credited Amount'), numeric: true),
                        DataColumn(label: Text('Net Settlement'), numeric: true),
                        DataColumn(label: Text('Created Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        for (final settlement in settlements)
                          DataRow(
                            cells: [
                              DataCell(Text(_displayMonth(settlement.settlementMonth))),
                              DataCell(Text(settlement.settlementType ?? 'Monthly')),
                              DataCell(Text(settlement.operatingSystem ?? 'iOS')),
                              DataCell(Text(settlement.paymentGateway ?? 'Apple')),
                              DataCell(_StatusBadge(status: settlement.status ?? 'N/A', theme: theme)),
                              DataCell(Text('${settlement.totalTransactions ?? 0}')),
                              DataCell(Text(_money(settlement.customerPayment))),
                              DataCell(Text(_money(settlement.appleDeduction))),
                              DataCell(Text(_money(settlement.creditedAmount))),
                              DataCell(Text(_money(settlement.netSettlement))),
                              DataCell(Text(_displayDate(settlement.createdDate))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'View Details',
                                      onPressed: () => onView(settlement),
                                      icon: const Icon(Icons.visibility_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Download CSV',
                                      onPressed: () => onDownload(settlement),
                                      icon: const Icon(Icons.download_outlined),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (loadingMore)
                          DataRow(
                            cells: [
                              const DataCell(AppSpinner(size: 18)),
                              for (var i = 0; i < 11; i++)
                                const DataCell(Text('')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.theme,
    required this.icon,
    required this.text,
  });

  final ThemeData theme;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primaryColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: padding, child: child),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
    required this.actionLabel,
    required this.onAction,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
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
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String? _apiMonth(DateTime? value) {
  if (value == null) return null;
  return DateFormat('yyyy-MM').format(value);
}

String _displayDateMonth(DateTime? value) {
  if (value == null) return 'Select month';
  return DateFormat('MMMM yyyy').format(value);
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

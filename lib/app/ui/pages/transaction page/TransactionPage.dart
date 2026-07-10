import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/transactionProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/data/models/response/transaction_settlement_report.dart';
import 'package:admin_ott/data/models/response/userTransactionResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String selectedButton = '7D';
  String selectedGraphType = 'Revenue';

  @override
  void initState() {
    super.initState();
    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.fetchUserTransactions('');
    await provider.fetchTransactionGraph(0);
  }

  Future<void> updateGraph(String buttonLabel, int days) async {
    setState(() {
      selectedButton = buttonLabel;
    });

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    if (buttonLabel == "7D") {
      await provider.fetchTransactionGraph(0);
    } else if (buttonLabel == "1M") {
      await provider.fetchTransactionGraph(1);
    } else {
      await provider.fetchTransactionGraph(2);
    }
  }

  void switchGraphType(String type) {
    setState(() {
      selectedGraphType = type;
    });
  }

  void _openTransactionDetails(UserTransactionData transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _TransactionDetailsPage(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return ResponsiveWidget.isMobile(context)
                ? _buildMobileLayout(theme, provider)
                : _buildDesktopLayout(theme, provider);
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, TransactionProvider provider) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildHeader(theme, provider),
                const SizedBox(height: 14),
                _buildSummaryGrid(theme, provider, isMobile: true),
                const SizedBox(height: 14),
                _buildGraphPanel(theme, provider, compact: true),
                const SizedBox(height: 14),
                _buildSearchField(theme, provider),
                const SizedBox(height: 10),
                _buildListHeader(theme, provider),
              ],
            ),
          ),
        ),
        if (provider.filtteredUserTransactionList.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(theme),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) {
                    return const SizedBox(height: 10);
                  }

                  final transactionIndex = index ~/ 2;
                  return _buildTransactionCard(
                    theme,
                    provider.filtteredUserTransactionList[transactionIndex],
                    onTap: () => _openTransactionDetails(
                      provider.filtteredUserTransactionList[transactionIndex],
                    ),
                  );
                },
                childCount:
                    provider.filtteredUserTransactionList.length * 2 - 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, provider),
          const SizedBox(height: 16),
          _buildSummaryGrid(theme, provider),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _buildGraphPanel(theme, provider),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 4,
                  child: _buildTransactionPanel(theme, provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transactions',
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Revenue graph, purchases, users, and shareable transaction details.',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.62),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 18, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                '${provider.filtteredUserTransactionList.length} records',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(
    ThemeData theme,
    TransactionProvider provider, {
    bool isMobile = false,
  }) {
    final transactions = provider.filtteredUserTransactionList;
    final activeCount =
        transactions.where((transaction) => transaction.active == true).length;
    final giftedCount = transactions
        .where((transaction) => transaction.isGifted == true)
        .length;
    final contentCount = transactions
        .map((transaction) => transaction.movie?.id)
        .where((id) => id != null)
        .toSet()
        .length;

    final items = [
      _SummaryItem(
        label: 'Total Revenue',
        value: _formatRevenue(provider.totalRevenue),
        icon: Icons.currency_rupee,
      ),
      _SummaryItem(
        label: 'Transactions',
        value: '${transactions.length}',
        icon: Icons.payments_outlined,
      ),
      _SummaryItem(
        label: 'Active Access',
        value: '$activeCount',
        icon: Icons.verified_outlined,
      ),
      _SummaryItem(
        label: 'Gifted',
        value: '$giftedCount',
        icon: Icons.card_giftcard_outlined,
      ),
      if (!isMobile)
        _SummaryItem(
          label: 'Content Sold',
          value: '$contentCount',
          icon: Icons.movie_creation_outlined,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isMobile
            ? 2
            : constraints.maxWidth >= 1200
                ? 5
                : 4;

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
              _buildSummaryTile(theme, items[index]),
        );
      },
    );
  }

  Widget _buildSummaryTile(ThemeData theme, _SummaryItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.58),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphPanel(
    ThemeData theme,
    TransactionProvider provider, {
    bool compact = false,
  }) {
    return Container(
      height: compact ? 360 : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedGraphType == 'Revenue'
                        ? 'Revenue Analysis'
                        : 'User Onboarding Analysis',
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedGraphType == 'Revenue'
                        ? 'Total ${_formatRevenue(provider.totalRevenue)}'
                        : 'Users onboarded across the selected period',
                    style: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.56),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _buildGraphTypeToggle(theme),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: provider.chartData.isEmpty
                ? _buildEmptyState(theme, message: 'No graph data available')
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.62),
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      labelStyle: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.62),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      AreaSeries<TransactionChartData, String>(
                        dataSource: provider.chartData,
                        xValueMapper: (data, _) => data.date,
                        yValueMapper: (data, _) =>
                            selectedGraphType == 'Revenue'
                                ? data.revenue
                                : data.usersOnboarded,
                        borderColor: theme.primaryColor,
                        borderWidth: 2,
                        color: theme.primaryColor.withValues(alpha: 0.16),
                        markerSettings: const MarkerSettings(
                            isVisible: true, height: 5, width: 5),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOptionButton('7D', 7, theme),
              const SizedBox(width: 8),
              _buildOptionButton('1M', 30, theme),
              const SizedBox(width: 8),
              _buildOptionButton('1Y', 365, theme),
              const SizedBox(width: 8),
              _buildOptionButton('All', provider.chartData.length, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphTypeToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGraphTypeButton(theme, 'Revenue'),
          _buildGraphTypeButton(theme, 'Users'),
        ],
      ),
    );
  }

  Widget _buildGraphTypeButton(ThemeData theme, String label) {
    final isSelected = selectedGraphType == label;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => switchGraphType(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.canvasColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionPanel(
    ThemeData theme,
    TransactionProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildSearchField(theme, provider),
          const SizedBox(height: 12),
          _buildListHeader(theme, provider),
          const SizedBox(height: 10),
          Expanded(
            child: provider.filtteredUserTransactionList.isEmpty
                ? _buildEmptyState(theme)
                : ListView.separated(
                    itemCount: provider.filtteredUserTransactionList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(
                        theme,
                        provider.filtteredUserTransactionList[index],
                        onTap: () => _openTransactionDetails(
                          provider.filtteredUserTransactionList[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, TransactionProvider provider) {
    return TextField(
      controller: provider.searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by user name',
        prefixIcon: Icon(Icons.search, color: theme.canvasColor),
        suffixIcon: provider.searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: provider.searchController.clear,
                icon: const Icon(Icons.close),
              ),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.canvasColor.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.canvasColor.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildListHeader(ThemeData theme, TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Transaction List',
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${provider.filtteredUserTransactionList.length} shown',
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.56),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String label, int days, ThemeData theme) {
    final isSelected = selectedButton == label;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => updateGraph(label, days),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isSelected ? theme.primaryColor : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : theme.canvasColor.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.canvasColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    ThemeData theme,
    UserTransactionData transaction, {
    required VoidCallback onTap,
  }) {
    final isActive = transaction.active ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TXN${transaction.id ?? '-'}',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    theme,
                    isActive ? 'Active' : 'Expired',
                    isActive ? Colors.green : Colors.red,
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: theme.canvasColor),
                  IconButton(
                    tooltip: 'Share transaction',
                    icon: Icon(Icons.share_outlined, color: theme.primaryColor),
                    onPressed: () => Share.share(_shareText(transaction)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _userName(transaction),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'User ID: ${transaction.user?.id ?? '-'}',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.58),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                leftLabel: 'Content',
                leftValue: _contentTitle(transaction),
                rightLabel: 'Price',
                rightValue: _priceText(transaction),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                theme,
                leftLabel: 'Duration',
                leftValue: _runtimeText(transaction),
                rightLabel: 'Accessible Till',
                rightValue: _formatEpochDate(transaction.dateTo),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                theme,
                leftLabel: 'Referred By',
                leftValue: transaction.refferedBy ?? '-',
                rightLabel: 'Purchase Date',
                rightValue: _formatEpochDate(transaction.dateFrom),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Row(
      children: [
        Expanded(child: _buildDetailItem(theme, leftLabel, leftValue)),
        const SizedBox(width: 10),
        Expanded(child: _buildDetailItem(theme, rightLabel, rightValue)),
      ],
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.54),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    ThemeData theme, {
    String message = 'No transactions found',
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: theme.canvasColor.withValues(alpha: 0.36),
            size: 38,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _shareText(UserTransactionData transaction) {
    return 'Transaction Details\n'
        'Transaction ID: ${transaction.id ?? '-'}\n'
        'Purchase Date: ${_formatEpochDate(transaction.dateFrom)}\n'
        'Accessible Till: ${_formatEpochDate(transaction.dateTo)}\n'
        'User Name: ${_userName(transaction)}\n'
        'User ID: ${transaction.user?.id ?? '-'}\n'
        'Movie: ${_contentTitle(transaction)}\n'
        'Price: ${_priceText(transaction)}\n'
        'Status: ${transaction.active == true ? 'Active' : 'Expired'}\n';
  }

  String _userName(UserTransactionData transaction) {
    final user = transaction.user;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    if (fullName.isNotEmpty) return fullName;
    return user?.mobileNumber ?? user?.emailId ?? 'Unknown User';
  }

  String _contentTitle(UserTransactionData transaction) {
    return transaction.movie?.title ?? 'Untitled';
  }

  String _priceText(UserTransactionData transaction) {
    final price = transaction.price ?? transaction.movie?.price;
    if (price == null) return 'Rs. 0';
    final amount = price is num ? price : num.tryParse(price.toString()) ?? 0;
    return 'Rs. ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  }

  String _runtimeText(UserTransactionData transaction) {
    final runtime = transaction.movie?.runtime;
    if (runtime == null) return '-';
    return '$runtime min';
  }

  String _formatEpochDate(int? value) {
    if (value == null || value <= 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(value);
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatRevenue(String? value) {
    final amount = num.tryParse(value ?? '');
    if (amount == null) return 'Rs. 0';
    return 'Rs. ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _TransactionDetailsPage extends StatefulWidget {
  const _TransactionDetailsPage({required this.transaction});

  final UserTransactionData transaction;

  @override
  State<_TransactionDetailsPage> createState() =>
      _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<_TransactionDetailsPage> {
  late final Future<TransactionSettlementReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = context
        .read<TransactionProvider>()
        .fetchTransactionSettlementReport(widget.transaction.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.canvasColor,
        elevation: 0,
        title: Text('TXN${widget.transaction.id ?? '-'} Details'),
        actions: [
          IconButton(
            tooltip: 'Share transaction',
            onPressed: () => Share.share(_fallbackShareText),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: FutureBuilder<TransactionSettlementReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppSpinner());
          }

          if (snapshot.hasError) {
            return _TransactionStatePanel(
              theme: theme,
              icon: Icons.error_outline,
              title: 'Unable to load transaction settlement details.',
            );
          }

          final report = snapshot.data;
          if (report == null) {
            return _TransactionStatePanel(
              theme: theme,
              icon: Icons.receipt_long_outlined,
              title: 'No transaction settlement details available.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransactionHeaderCard(
                            report: report,
                            transaction: widget.transaction,
                            theme: theme,
                          ),
                          const SizedBox(height: 14),
                          _SummaryDashboard(report: report, theme: theme),
                          const SizedBox(height: 14),
                          MoneyFlowTimeline(report: report, theme: theme),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final twoColumns = constraints.maxWidth >= 860;
                              final production = ProductionSettlementCard(
                                report: report,
                                theme: theme,
                              );
                              final platform = PlatformSettlementCard(
                                report: report,
                                theme: theme,
                              );

                              if (!twoColumns) {
                                return Column(
                                  children: [
                                    production,
                                    const SizedBox(height: 14),
                                    platform,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: production),
                                  const SizedBox(width: 14),
                                  Expanded(child: platform),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _PromoterSettlementSection(
                            report: report,
                            theme: theme,
                          ),
                          const SizedBox(height: 14),
                          FinalSummaryCard(report: report, theme: theme),
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

  String get _fallbackShareText {
    return 'Transaction Details\n'
        'Transaction ID: ${widget.transaction.id ?? '-'}\n'
        'User Name: $_userName\n'
        'Movie: $_contentTitle\n'
        'Customer Payment: ${_fallbackMoney(_paymentAmount)}\n';
  }

  String get _userName {
    final user = widget.transaction.user;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    if (fullName.isNotEmpty) return fullName;
    return user?.mobileNumber ?? user?.emailId ?? 'Unknown User';
  }

  String get _contentTitle => widget.transaction.movie?.title ?? 'Untitled';

  double get _paymentAmount {
    final amount = widget.transaction.price ?? widget.transaction.movie?.price;
    if (amount == null) return 0;
    return amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0;
  }
}

class TransactionHeaderCard extends StatelessWidget {
  const TransactionHeaderCard({
    super.key,
    required this.report,
    required this.transaction,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final UserTransactionData transaction;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final customer = report.customerName ?? _transactionUserName(transaction);
    final content =
        report.contentTitle ?? transaction.movie?.title ?? 'Untitled';
    final payment = _settlementMoney(
      _settlementAmount(report.customerPayment) == 0
          ? report.amountFor(const ["customer payment", "customer collection"])
          : _settlementAmount(report.customerPayment),
      report,
    );

    return _SettlementSurface(
      theme: theme,
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _StatusBadge(
                    label:
                        'TXN${report.transactionId ?? transaction.id ?? '-'}',
                    color: theme.primaryColor,
                  ),
                  if ((report.status ?? transaction.status ?? '').isNotEmpty)
                    _StatusBadge(
                      label: report.status ?? transaction.status ?? '',
                      color: _transactionStatusColor(
                        report.status ?? transaction.status ?? '',
                        theme,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                report.transactionTitle ?? 'Transaction Settlement',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: compact ? 24 : 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

          final paymentBlock = Container(
            width: compact ? double.infinity : 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Payment',
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    payment,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          );

          final info = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoTile(theme: theme, label: 'Customer Name', value: customer),
              _InfoTile(theme: theme, label: 'Content Title', value: content),
              _InfoTile(
                theme: theme,
                label: 'Currency',
                value: report.currency ?? report.displayCurrencySymbol,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 16),
                paymentBlock,
                const SizedBox(height: 14),
                info,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 16),
                    info,
                  ],
                ),
              ),
              const SizedBox(width: 18),
              paymentBlock,
            ],
          );
        },
      ),
    );
  }
}

class _SummaryDashboard extends StatelessWidget {
  const _SummaryDashboard({
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      TransactionMetricItem(
        label: 'Base Amount',
        value:
            _settlementMoney(report.amountFor(const ["base amount"]), report),
        icon: Icons.movie_outlined,
        color: Colors.blue,
      ),
      TransactionMetricItem(
        label: 'GST Included',
        value: _settlementMoney(report.amountFor(const ["gst"]), report),
        icon: Icons.percent_outlined,
        color: Colors.orange,
      ),
      TransactionMetricItem(
        label: 'Production Final',
        value: _settlementMoney(
          _settlementAmount(report.productionSettlement.finalAmount) == 0
              ? report.amountFor(const ["production final"])
              : _settlementAmount(report.productionSettlement.finalAmount),
          report,
        ),
        icon: Icons.home_work_outlined,
        color: Colors.green,
      ),
      TransactionMetricItem(
        label: 'Platform Final',
        value: _settlementMoney(
          _settlementAmount(report.platformSettlement.platformFinal) == 0
              ? report.amountFor(const ["platform final"])
              : _settlementAmount(report.platformSettlement.platformFinal),
          report,
        ),
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.deepPurple,
      ),
    ];

    return LayoutBuilder(
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
            mainAxisExtent: 106,
          ),
          itemBuilder: (context, index) {
            return SummaryMetricCard(item: items[index], theme: theme);
          },
        );
      },
    );
  }
}

class SummaryMetricCard extends StatelessWidget {
  const SummaryMetricCard({
    super.key,
    required this.item,
    required this.theme,
  });

  final TransactionMetricItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _SettlementSurface(
      theme: theme,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
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

class MoneyFlowTimeline extends StatelessWidget {
  const MoneyFlowTimeline({
    super.key,
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final flow = [
      TransactionMetricItem(
        label: 'Customer Payment',
        value: _settlementMoney(
          report.amountFor(const ["customer payment", "customer collection"]),
          report,
        ),
        icon: Icons.person_outline,
        color: Colors.green,
      ),
      TransactionMetricItem(
        label: 'GST Included',
        value: _settlementMoney(report.amountFor(const ["gst"]), report),
        icon: Icons.percent_outlined,
        color: Colors.orange,
      ),
      TransactionMetricItem(
        label: 'Base Amount',
        value:
            _settlementMoney(report.amountFor(const ["base amount"]), report),
        icon: Icons.movie_outlined,
        color: Colors.blue,
      ),
      TransactionMetricItem(
        label: 'Razorpay Fee',
        value: _settlementMoney(
          report.amountFor(const ["razorpay", "payment gateway"]),
          report,
        ),
        icon: Icons.credit_card_outlined,
        color: Colors.redAccent,
      ),
      TransactionMetricItem(
        label: 'Net Revenue',
        value:
            _settlementMoney(report.amountFor(const ["net revenue"]), report),
        icon: Icons.account_balance_outlined,
        color: Colors.indigo,
      ),
    ];

    return _SectionSurface(
      theme: theme,
      icon: Icons.timeline_outlined,
      title: 'Money Flow',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          if (compact) {
            return Column(
              children: [
                for (var i = 0; i < flow.length; i++) ...[
                  _FlowNode(item: flow[i], theme: theme, expanded: true),
                  if (i != flow.length - 1)
                    Icon(Icons.keyboard_arrow_down, color: theme.primaryColor),
                ],
                const SizedBox(height: 10),
                _FlowSplit(report: report, theme: theme),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward,
                          color: theme.primaryColor,
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _FlowSplit(report: report, theme: theme),
            ],
          );
        },
      ),
    );
  }
}

class ProductionSettlementCard extends StatelessWidget {
  const ProductionSettlementCard({
    super.key,
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final settlement = report.productionSettlement;
    return _SectionSurface(
      theme: theme,
      icon: Icons.home_work_outlined,
      title: 'Production House Settlement',
      child: Column(
        children: [
          _SettlementAmountRow(
            theme: theme,
            label: 'Gross Amount',
            value: _settlementMoney(
                _settlementAmount(settlement.grossAmount), report),
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'TDS',
            value: _settlementMoney(_settlementAmount(settlement.tds), report),
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'After TDS',
            value: _settlementMoney(
                _settlementAmount(settlement.afterTds), report),
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Payout Charges',
            value: _settlementMoney(
              _settlementAmount(settlement.payoutCharges),
              report,
            ),
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Final Amount',
            value: _settlementMoney(
                _settlementAmount(settlement.finalAmount), report),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class PlatformSettlementCard extends StatelessWidget {
  const PlatformSettlementCard({
    super.key,
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final settlement = report.platformSettlement;
    return _SectionSurface(
      theme: theme,
      icon: Icons.account_balance_wallet_outlined,
      title: 'Platform Settlement',
      child: Column(
        children: [
          _SettlementAmountRow(
            theme: theme,
            label: 'Platform Gross',
            value: _settlementMoney(
              _settlementAmount(settlement.platformGross),
              report,
            ),
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Promoter Allocation',
            value: _settlementMoney(
              _settlementAmount(settlement.promoterAllocation),
              report,
            ),
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Platform Final',
            value: _settlementMoney(
              _settlementAmount(settlement.platformFinal),
              report,
            ),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class PromoterSettlementCard extends StatelessWidget {
  const PromoterSettlementCard({
    super.key,
    required this.promoter,
    required this.report,
    required this.theme,
  });

  final TransactionPromoterSettlement promoter;
  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _innerSettlementDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  promoter.promoterLevel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if ((promoter.badge ?? '').isNotEmpty)
                _StatusBadge(label: promoter.badge!, color: Colors.teal),
            ],
          ),
          const Divider(height: 20),
          _SettlementAmountRow(
            theme: theme,
            label: 'Percentage',
            value: _settlementPercent(promoter.percentage),
            dense: true,
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Gross Amount',
            value: _settlementMoney(
                _settlementAmount(promoter.grossAmount), report),
            dense: true,
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'TDS',
            value: _settlementMoney(_settlementAmount(promoter.tds), report),
            dense: true,
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Payout Charges',
            value: _settlementMoney(
                _settlementAmount(promoter.payoutCharges), report),
            dense: true,
          ),
          _SettlementAmountRow(
            theme: theme,
            label: 'Final Amount',
            value: _settlementMoney(
                _settlementAmount(promoter.finalAmount), report),
            dense: true,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class FinalSummaryCard extends StatelessWidget {
  const FinalSummaryCard({
    super.key,
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      theme: theme,
      icon: Icons.fact_check_outlined,
      title: 'Final Settlement Summary',
      child: report.finalSummary.isEmpty
          ? Text(
              'No final settlement summary available.',
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.64),
                fontWeight: FontWeight.w700,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 980
                    ? 4
                    : constraints.maxWidth >= 640
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.finalSummary.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 94,
                  ),
                  itemBuilder: (context, index) {
                    final item = report.finalSummary[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _innerSettlementDecoration(theme),
                      child: Row(
                        children: [
                          Icon(
                            Icons.summarize_outlined,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _settlementMoney(
                                    _settlementAmount(item.amount),
                                    report,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.canvasColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.canvasColor
                                        .withValues(alpha: 0.58),
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
            ),
    );
  }
}

class _PromoterSettlementSection extends StatelessWidget {
  const _PromoterSettlementSection({
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      theme: theme,
      icon: Icons.groups_2_outlined,
      title: 'Promoter Settlement',
      child: report.promoterCards.isEmpty
          ? Text(
              'No promoter settlement available.',
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.64),
                fontWeight: FontWeight.w700,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1060
                    ? 3
                    : constraints.maxWidth >= 680
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.promoterCards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 236,
                  ),
                  itemBuilder: (context, index) {
                    return PromoterSettlementCard(
                      promoter: report.promoterCards[index],
                      report: report,
                      theme: theme,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _FlowSplit extends StatelessWidget {
  const _FlowSplit({
    required this.report,
    required this.theme,
  });

  final TransactionSettlementReportData report;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final items = [
      TransactionMetricItem(
        label: 'Production House',
        value: _settlementMoney(
          _settlementAmount(report.productionSettlement.finalAmount),
          report,
        ),
        icon: Icons.home_work_outlined,
        color: Colors.green,
      ),
      TransactionMetricItem(
        label: 'Platform',
        value: _settlementMoney(
          _settlementAmount(report.platformSettlement.platformFinal),
          report,
        ),
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.deepPurple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 580 ? 2 : 1;
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
          itemBuilder: (context, index) {
            return _FlowNode(item: items[index], theme: theme, expanded: true);
          },
        );
      },
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.item,
    required this.theme,
    this.expanded = false,
  });

  final TransactionMetricItem item;
  final ThemeData theme;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.all(11),
      decoration: _innerSettlementDecoration(theme),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 9),
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
                    color: theme.canvasColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
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
    return _SettlementSurface(
      theme: theme,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
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

class _SettlementSurface extends StatelessWidget {
  const _SettlementSurface({
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.theme,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: _innerSettlementDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementAmountRow extends StatelessWidget {
  const _SettlementAmountRow({
    required this.theme,
    required this.label,
    required this.value,
    this.highlight = false,
    this.dense = false,
  });

  final ThemeData theme;
  final String label;
  final String value;
  final bool highlight;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: dense ? 6 : 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.canvasColor.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.canvasColor
                    .withValues(alpha: highlight ? 0.86 : 0.62),
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
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
                color: highlight ? theme.primaryColor : theme.canvasColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TransactionStatePanel extends StatelessWidget {
  const _TransactionStatePanel({
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
            Icon(icon, color: theme.primaryColor, size: 38),
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

class TransactionMetricItem {
  const TransactionMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

BoxDecoration _innerSettlementDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.scaffoldBackgroundColor.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.56 : 0.9,
    ),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
  );
}

Color _transactionStatusColor(String status, ThemeData theme) {
  final normalized = status.toLowerCase();
  if (normalized.contains('paid') ||
      normalized.contains('complete') ||
      normalized.contains('success') ||
      normalized.contains('active')) {
    return Colors.green;
  }
  if (normalized.contains('pending') || normalized.contains('process')) {
    return Colors.orange;
  }
  if (normalized.contains('fail') ||
      normalized.contains('reject') ||
      normalized.contains('cancel') ||
      normalized.contains('expired')) {
    return Colors.redAccent;
  }
  return theme.primaryColor;
}

String _transactionUserName(UserTransactionData transaction) {
  final user = transaction.user;
  final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
  if (fullName.isNotEmpty) return fullName;
  return user?.mobileNumber ?? user?.emailId ?? 'Unknown User';
}

String _settlementMoney(double amount, TransactionSettlementReportData report) {
  final symbol = report.displayCurrencySymbol;
  return NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 2,
    locale: symbol == '\u20B9' ? 'en_IN' : 'en_US',
  ).format(amount);
}

String _settlementPercent(String? value) {
  final amount = _settlementAmount(value);
  if (amount == 0) return '0%';
  return '${NumberFormat('0.##').format(amount)}%';
}

double _settlementAmount(dynamic value) {
  if (value is num) return value.toDouble();
  final text = value
          ?.toString()
          .replaceAll(',', '')
          .replaceAll('\u20B9', '')
          .replaceAll('Rs.', '')
          .replaceAll('Rs', '')
          .replaceAll('%', '')
          .trim() ??
      '';
  return double.tryParse(RegExp(r'-?\d+(\.\d+)?').stringMatch(text) ?? '') ?? 0;
}

String _fallbackMoney(num amount) {
  return NumberFormat.currency(
    symbol: '\u20B9',
    decimalDigits: 2,
    locale: 'en_IN',
  ).format(amount);
}

class TransactionChartData {
  final String date;
  final double revenue;
  final int usersOnboarded;

  TransactionChartData(this.date, this.revenue, this.usersOnboarded);
}

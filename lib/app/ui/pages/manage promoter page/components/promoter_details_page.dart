import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/assign_parent_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/change_level_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/edit_promoter_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoter_hierarchy_widget.dart';
import 'package:admin_ott/data/models/response/userOnboardAndRevenueGraph.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PromoterDetailsPage extends StatefulWidget {
  final Promoters promoter;

  const PromoterDetailsPage({super.key, required this.promoter});

  @override
  State<PromoterDetailsPage> createState() => _PromoterDetailsPageState();
}

class _PromoterDetailsPageState extends State<PromoterDetailsPage> {
  late Promoters _currentPromoter;

  // Tab & Filter States
  String selectedRevenueTimeframe = '1W';
  int selectedRevenueDays = 7;

  // User list table filters
  String userSearchQuery = '';
  String userStatusFilter = 'All';
  int userCurrentPage = 0;
  final int userPageSize = 5;

  // Child promoter table filters
  String childSearchQuery = '';
  String childLevelFilter = 'All';
  int childCurrentPage = 0;
  final int childPageSize = 5;

  // Settlement table filters
  String settlementSearchQuery = '';
  String settlementStatusFilter = 'All';
  int settlementCurrentPage = 0;
  final int settlementPageSize = 5;

  @override
  void initState() {
    super.initState();
    _currentPromoter = widget.promoter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    final refCode = _currentPromoter.userId?.refferCode ?? _currentPromoter.promoterName ?? '';

    if (refCode.isNotEmpty) {
      await provider.getUsersByUserReferalCode(refCode);
      await provider.getPromotersByUserReferalCode(refCode);
    }
    if (_currentPromoter.id != null) {
      await provider.getUsersAndRevenue(_currentPromoter.id!);
    }
  }

  void _refreshPromoter() {
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    try {
      final updated = provider.promoterList.firstWhere((p) => p.id == _currentPromoter.id);
      setState(() {
        _currentPromoter = updated;
      });
    } catch (_) {}
    _loadData();
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'national':
        return Colors.deepPurple;
      case 'state':
        return Colors.blueAccent;
      case 'district':
        return Colors.orangeAccent;
      case 'taluka':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${_currentPromoter.promoterName ?? "Promoter"} • Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.canvasColor),
        ),
        backgroundColor: theme.cardColor,
        elevation: 1,
        iconTheme: IconThemeData(color: theme.canvasColor),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh, color: theme.canvasColor),
            onPressed: _refreshPromoter,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Promoter'),
            onPressed: () => showEditPromoterDialog(
              context,
              _currentPromoter,
              onUpdated: _refreshPromoter,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.canvasColor),
            onSelected: (val) {
              if (val == 'change_level') {
                showChangeLevelDialog(
                  context,
                  _currentPromoter,
                  onLevelChanged: _refreshPromoter,
                );
              } else if (val == 'assign_parent') {
                showAssignParentDialog(
                  context,
                  _currentPromoter,
                  onAssigned: _refreshPromoter,
                );
              } else if (val == 'toggle_status') {
                _confirmChangeStatus(context, theme, provider);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'change_level',
                child: Row(
                  children: [
                    Icon(Icons.swap_vert, size: 18),
                    SizedBox(width: 8),
                    Text('Change Level'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'assign_parent',
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt, size: 18),
                    SizedBox(width: 8),
                    Text('Assign Parent'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      _currentPromoter.isActive ? Icons.block : Icons.check_circle_outline,
                      size: 18,
                      color: _currentPromoter.isActive ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(_currentPromoter.isActive ? 'Deactivate / Suspend' : 'Activate Promoter'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROMOTER PERSONAL INFORMATION
            _buildSectionHeader('Promoter Personal Information', theme, Icons.person_outline),
            const SizedBox(height: 12),
            _buildSection1PersonalInfo(theme, provider),
            const SizedBox(height: 24),

            // PROMOTER LEVEL / HIERARCHY
            _buildSectionHeader('Promoter Level & Hierarchy', theme, Icons.account_tree_outlined),
            const SizedBox(height: 12),
            PromoterHierarchyWidget(promoter: _currentPromoter),
            const SizedBox(height: 24),

            // REVENUE SECTION
            _buildSectionHeader('Revenue Tracking & Settlement Calculations', theme, Icons.monetization_on_outlined),
            const SizedBox(height: 12),
            _buildSection3Revenue(theme, provider),
            const SizedBox(height: 24),

            // NUMBER OF USERS ADDED
            _buildSectionHeader('Number of Users Added', theme, Icons.group_outlined),
            const SizedBox(height: 12),
            _buildSection4UsersAdded(theme, provider),
            const SizedBox(height: 24),

            // NUMBER OF PROMOTERS ADDED
            _buildSectionHeader('Number of Promoters Added', theme, Icons.badge_outlined),
            const SizedBox(height: 12),
            _buildSection5PromotersAdded(theme, provider),
            const SizedBox(height: 24),

            // SETTLEMENT SECTION
            _buildSectionHeader('Settlements & Payout History', theme, Icons.receipt_long_outlined),
            const SizedBox(height: 12),
            _buildSection6Settlements(theme, provider),
            const SizedBox(height: 24),

            // ACTIVITY / AUDIT HISTORY
            _buildSectionHeader('Activity & Audit Trail History', theme, Icons.history_outlined),
            const SizedBox(height: 12),
            _buildSection7AuditHistory(theme, provider),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 1: PERSONAL INFORMATION
  // ==========================================
  Widget _buildSection1PersonalInfo(ThemeData theme, PromoterProvider provider) {
    final p = _currentPromoter;
    final parent = provider.getParentPromoter(p);
    final levelColor = _getLevelColor(p.normalizedLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              final avatarAndBasic = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      (p.promoterName?.isNotEmpty == true)
                          ? p.promoterName![0].toUpperCase()
                          : 'P',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                p.promoterName ?? 'Unknown Promoter',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.canvasColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(p.displayStatus),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: levelColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: levelColor),
                              ),
                              child: Text(
                                '${p.normalizedLevel} Promoter',
                                style: TextStyle(
                                  color: levelColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (p.isKycCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 14, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(
                                      'KYC Verified',
                                      style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text(
                                      'KYC Pending',
                                      style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            _buildIconText(Icons.badge_outlined, 'Promoter ID: ${p.id ?? p.userId?.id ?? "N/A"}', theme),
                            _buildIconText(Icons.phone_outlined, p.contactNumber ?? p.userId?.mobileNumber ?? 'N/A', theme),
                            _buildIconText(Icons.email_outlined, p.userId?.emailId ?? 'N/A', theme),
                            _buildIconText(Icons.calendar_today_outlined, 'Joined: ${p.createdDate ?? "N/A"}', theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.canvasColor,
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: Icon(Icons.swap_vert, size: 16, color: theme.canvasColor),
                    label: const Text('Change Level'),
                    onPressed: () => showChangeLevelDialog(
                      context,
                      _currentPromoter,
                      onLevelChanged: _refreshPromoter,
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.canvasColor,
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: Icon(Icons.person_add_alt, size: 16, color: theme.canvasColor),
                    label: const Text('Assign Parent'),
                    onPressed: () => showAssignParentDialog(
                      context,
                      _currentPromoter,
                      onAssigned: _refreshPromoter,
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: avatarAndBasic),
                    actionButtons,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatarAndBasic,
                    const SizedBox(height: 16),
                    actionButtons,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Detail Attributes Grid
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildInfoItem('Referral Code', p.userId?.refferCode ?? p.promoterName ?? 'N/A', theme),
              _buildInfoItem('Assigned Location', p.formattedAddress.isNotEmpty ? p.formattedAddress : 'India', theme),
              _buildInfoItem('State / District', '${p.location?.state ?? "N/A"} / ${p.location?.district ?? "N/A"}', theme),
              _buildInfoItem('Taluka / City', '${p.location?.taluka ?? "N/A"} / ${p.location?.city ?? "N/A"}', theme),
              _buildInfoItem(
                'Reporting Parent Promoter',
                parent != null ? '${parent.promoterName} (${parent.normalizedLevel})' : (p.normalizedLevel == 'National' ? 'None (Apex Level)' : 'Not Assigned'),
                theme,
                isClickable: parent != null,
                onTap: parent != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => PromoterDetailsPage(promoter: parent)),
                        );
                      }
                    : null,
              ),
              _buildInfoItem('PAN Card', p.panCard?.isNotEmpty == true ? p.panCard! : 'Not Provided', theme),
              _buildInfoItem('Aadhaar Card', p.aadharCard?.isNotEmpty == true ? p.aadharCard! : 'Not Provided', theme),
              _buildInfoItem('GST Number', p.gst?.isNotEmpty == true ? p.gst! : 'Not Provided', theme),
              _buildInfoItem('Bank Name', p.bankName?.isNotEmpty == true ? p.bankName! : 'Not Provided', theme),
              _buildInfoItem('Account Number', p.accountNumber?.isNotEmpty == true ? p.accountNumber! : 'Not Provided', theme),
              _buildInfoItem('IFSC Code', p.ifscCode?.isNotEmpty == true ? p.ifscCode! : 'Not Provided', theme),
              _buildInfoItem('Branch Name', p.branchName?.isNotEmpty == true ? p.branchName! : 'Not Provided', theme),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: REVENUE SECTION (PURELY DYNAMIC)
  // ==========================================
  Widget _buildSection3Revenue(ThemeData theme, PromoterProvider provider) {
    final graph = provider.promoterUserRevenueGraph;
    double grossFromGraph = 0.0;
    for (var item in graph) {
      grossFromGraph += (item.revenue ?? 0.0);
    }
    final rawRevenue = provider.revenue ?? '0';
    final parsedRev = double.tryParse(rawRevenue.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final gross = grossFromGraph > 0 ? grossFromGraph : parsedRev;

    final base = gross == 0 ? 0.0 : gross / 1.18;
    final share = base * 0.01;
    final tds = share * 0.10;
    final afterTds = share - tds;
    final charges = afterTds * 0.02;
    final wallet = afterTds - charges;

    final directUsers = provider.usersByPromoterCode;
    final childPromoters = provider.getChildPromoters(_currentPromoter);
    final totalNetwork = directUsers.length + childPromoters.length;
    final userPct = totalNetwork > 0 ? ((directUsers.length / totalNetwork) * 100).toStringAsFixed(0) : '0';
    final childPct = totalNetwork > 0 ? ((childPromoters.length / totalNetwork) * 100).toStringAsFixed(0) : '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Summary Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final kpis = [
                _buildMetricCard('Total Revenue Generated', _formatMoney(gross), Icons.trending_up, Colors.indigo, theme),
                _buildMetricCard('Total Revenue Earned', _formatMoney(share), Icons.savings_outlined, Colors.green, theme),
                _buildMetricCard('Current Wallet Balance', _formatMoney(wallet), Icons.account_balance_wallet_outlined, theme.primaryColor, theme),
                _buildMetricCard('Withdrawn Amount', _formatMoney(share - wallet > 0 ? share - wallet : 0), Icons.outbox_outlined, Colors.purple, theme),
              ];

              if (isWide) {
                return Row(
                  children: kpis.map((k) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: k))).toList(),
                );
              } else {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: kpis.map((k) => SizedBox(width: (constraints.maxWidth - 20) / 2 > 160 ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth, child: k)).toList(),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // Dynamic Network Performance Breakdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Referral Network Composition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.canvasColor)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Direct Users Onboarded ($userPct%):', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
                          Text('${directUsers.length} Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.canvasColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Child Promoters Network ($childPct%):', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
                          Text('${childPromoters.length} Promoters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.canvasColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Network Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.canvasColor)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Users:', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
                          Text('${directUsers.where((u) => u.active != false).length} Active', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Child Promoters:', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
                          Text('${childPromoters.where((p) => p.isActive).length} Active', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Interactive Chart & Timeframe Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue & Onboarding Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.canvasColor)),
              Wrap(
                spacing: 6,
                children: ['1W', '1M', '3M', '6M', '1Y', 'All'].map((label) {
                  final isSelected = selectedRevenueTimeframe == label;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedRevenueTimeframe = label;
                        if (label == '1W') selectedRevenueDays = 7;
                        if (label == '1M') selectedRevenueDays = 30;
                        if (label == '3M') selectedRevenueDays = 90;
                        if (label == '6M') selectedRevenueDays = 180;
                        if (label == '1Y') selectedRevenueDays = 365;
                        if (label == 'All') selectedRevenueDays = 1000;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : theme.canvasColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: _buildRevenueChart(provider, theme),
          ),
          const SizedBox(height: 20),

          // Step-by-Step Settlement Formula Table
          _buildSettlementFormulaCard(theme, gross, base, share, tds, charges, wallet),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(PromoterProvider provider, ThemeData theme) {
    final list = provider.promoterUserRevenueGraph;
    if (list.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 36, color: theme.canvasColor.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              'No revenue transactions recorded for this promoter yet.',
              style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final dataToDisplay = list.length > selectedRevenueDays
        ? list.sublist(list.length - selectedRevenueDays)
        : list;

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        LineSeries<PromoterUserRevenueGraph, String>(
          dataSource: dataToDisplay,
          xValueMapper: (PromoterUserRevenueGraph data, _) => data.date ?? '',
          yValueMapper: (PromoterUserRevenueGraph data, _) => (data.revenue ?? 0).toDouble(),
          color: theme.primaryColor,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildSettlementFormulaCard(
    ThemeData theme,
    double gross,
    double base,
    double share,
    double tds,
    double charges,
    double wallet,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: theme.canvasColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Promoter Settlement Formula & Flow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
            },
            children: [
              _buildTableRow('Step', 'Formula / Logic', 'Computed Value', isHeader: true, theme: theme),
              _buildTableRow('Customer Payment', 'Gross Revenue Collected', _formatMoney(gross), theme: theme),
              _buildTableRow('Base Revenue', 'Customer Payment ÷ 1.18 (Excl. 18% GST)', _formatMoney(base), theme: theme),
              _buildTableRow('Promoter Share', 'Base Revenue × 1% (Tier %)', _formatMoney(share), theme: theme),
              _buildTableRow('TDS Deduction', 'Promoter Share × 10%', '- ${_formatMoney(tds)}', theme: theme),
              _buildTableRow('Transfer Charges', 'Net Share × 2%', '- ${_formatMoney(charges)}', theme: theme),
              _buildTableRow('Final Wallet Credit', 'Share - TDS - Charges', _formatMoney(wallet), isHighlighted: true, theme: theme),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3,
      {bool isHeader = false, bool isHighlighted = false, required ThemeData theme}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader
            ? theme.primaryColor.withValues(alpha: 0.1)
            : isHighlighted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(col1, style: TextStyle(fontWeight: isHeader || isHighlighted ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: theme.canvasColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(col2, style: TextStyle(fontWeight: isHeader || isHighlighted ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(col3, style: TextStyle(fontWeight: isHeader || isHighlighted ? FontWeight.bold : FontWeight.bold, color: isHighlighted ? Colors.green : theme.canvasColor, fontSize: 12)),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: NUMBER OF USERS ADDED (DYNAMIC)
  // ==========================================
  Widget _buildSection4UsersAdded(ThemeData theme, PromoterProvider provider) {
    final allUsers = provider.usersByPromoterCode;
    final total = allUsers.length;
    final active = allUsers.where((u) => u.active != false).length;
    final inactive = total - active;

    final now = DateTime.now();
    int addedToday = 0;
    int addedThisMonth = 0;
    for (var u in allUsers) {
      final dateStr = u.joinDate ?? u.registrationDate;
      if (dateStr != null) {
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          if (parsed.year == now.year && parsed.month == now.month && parsed.day == now.day) {
            addedToday++;
          }
          if (parsed.year == now.year && parsed.month == now.month) {
            addedThisMonth++;
          }
        }
      }
    }

    // Filter users list
    final filteredUsers = allUsers.where((u) {
      final matchesSearch = userSearchQuery.isEmpty ||
          '${u.firstName ?? ""} ${u.lastName ?? ""}'.toLowerCase().contains(userSearchQuery.toLowerCase()) ||
          (u.mobileNumber ?? '').contains(userSearchQuery) ||
          (u.emailId ?? '').toLowerCase().contains(userSearchQuery.toLowerCase());
      final matchesStatus = userStatusFilter == 'All' ||
          (userStatusFilter == 'Active' && u.active != false) ||
          (userStatusFilter == 'Inactive' && u.active == false);
      return matchesSearch && matchesStatus;
    }).toList();

    final totalPages = (filteredUsers.length / userPageSize).ceil();
    final pageUsers = filteredUsers.skip(userCurrentPage * userPageSize).take(userPageSize).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Row
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildMiniCard('Total Users Added', total.toString(), Icons.group, theme.primaryColor, theme),
                  _buildMiniCard('Active Users', active.toString(), Icons.check_circle, Colors.green, theme),
                  _buildMiniCard('Inactive Users', inactive.toString(), Icons.cancel_outlined, Colors.red, theme),
                  _buildMiniCard('Added Today', addedToday.toString(), Icons.today, Colors.blue, theme),
                  _buildMiniCard('Added This Month', (addedThisMonth > 0 ? addedThisMonth : total).toString(), Icons.calendar_month, Colors.purple, theme),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Search & Filter Bar for Users
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users by name, mobile, email...',
                      prefixIcon: Icon(Icons.search, size: 18, color: theme.canvasColor.withValues(alpha: 0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    onChanged: (val) {
                      setState(() {
                        userSearchQuery = val;
                        userCurrentPage = 0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: userStatusFilter,
                dropdownColor: theme.cardColor,
                items: ['All', 'Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      userStatusFilter = val;
                      userCurrentPage = 0;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Table
          if (pageUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                total == 0 ? 'No users added yet by this promoter referral code.' : 'No users matching search filters.',
                style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6)),
              ),
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.scaffoldBackgroundColor),
                columns: const [
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Mobile')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Join Date')),
                  DataColumn(label: Text('Status')),
                ],
                rows: pageUsers.map((u) {
                  return DataRow(
                    cells: [
                      DataCell(Text('#${u.id ?? "N/A"}')),
                      DataCell(Text('${u.firstName ?? ""} ${u.lastName ?? ""}')),
                      DataCell(Text(u.mobileNumber ?? 'N/A')),
                      DataCell(Text(u.emailId ?? 'N/A')),
                      DataCell(Text(u.joinDate ?? u.registrationDate ?? 'N/A')),
                      DataCell(_buildStatusBadge(u.active != false ? 'Active' : 'Inactive')),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Pagination
            _buildPagination(
              currentPage: userCurrentPage,
              totalPages: totalPages,
              onPageChanged: (p) => setState(() => userCurrentPage = p),
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: NUMBER OF PROMOTERS ADDED (DYNAMIC)
  // ==========================================
  Widget _buildSection5PromotersAdded(ThemeData theme, PromoterProvider provider) {
    final childPromoters = provider.getChildPromoters(_currentPromoter);
    final total = childPromoters.length;
    final active = childPromoters.where((p) => p.isActive).length;
    final inactive = total - active;

    final districtCount = childPromoters.where((p) => p.normalizedLevel == 'District').length;
    final talukaCount = childPromoters.where((p) => p.normalizedLevel == 'Taluka').length;

    // Filter child promoters
    final filtered = childPromoters.where((p) {
      final matchesSearch = childSearchQuery.isEmpty ||
          (p.promoterName ?? '').toLowerCase().contains(childSearchQuery.toLowerCase()) ||
          (p.contactNumber ?? '').contains(childSearchQuery);
      final matchesLevel = childLevelFilter == 'All' || p.normalizedLevel.toLowerCase() == childLevelFilter.toLowerCase();
      return matchesSearch && matchesLevel;
    }).toList();

    final totalPages = (filtered.length / childPageSize).ceil();
    final pageList = filtered.skip(childCurrentPage * childPageSize).take(childPageSize).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMiniCard('Total Child Promoters', total.toString(), Icons.people_alt, theme.primaryColor, theme),
              _buildMiniCard('Active Child Promoters', active.toString(), Icons.check_circle, Colors.green, theme),
              _buildMiniCard('Inactive Promoters', inactive.toString(), Icons.cancel_outlined, Colors.red, theme),
              if (_currentPromoter.normalizedLevel == 'State' || _currentPromoter.normalizedLevel == 'National')
                _buildMiniCard('District Promoters', districtCount.toString(), Icons.location_city, Colors.orange, theme),
              _buildMiniCard('Taluka Promoters', talukaCount.toString(), Icons.place, Colors.teal, theme),
            ],
          ),
          const SizedBox(height: 20),

          // Search & Filter
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search child promoters...',
                      prefixIcon: Icon(Icons.search, size: 18, color: theme.canvasColor.withValues(alpha: 0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    onChanged: (val) {
                      setState(() {
                        childSearchQuery = val;
                        childCurrentPage = 0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: childLevelFilter,
                dropdownColor: theme.cardColor,
                items: ['All', 'State', 'District', 'Taluka'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      childLevelFilter = val;
                      childCurrentPage = 0;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table
          if (pageList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                total == 0 ? 'No child promoters assigned under this promoter yet.' : 'No child promoters matching filters.',
                style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6)),
              ),
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.scaffoldBackgroundColor),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Level')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Contact')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')),
                ],
                rows: pageList.map((cp) {
                  return DataRow(
                    cells: [
                      DataCell(Text('#${cp.id ?? cp.userId?.id ?? "N/A"}')),
                      DataCell(Text(cp.promoterName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getLevelColor(cp.normalizedLevel).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cp.normalizedLevel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getLevelColor(cp.normalizedLevel),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(cp.location?.district ?? cp.location?.state ?? 'N/A')),
                      DataCell(Text(cp.contactNumber ?? cp.userId?.mobileNumber ?? 'N/A')),
                      DataCell(_buildStatusBadge(cp.displayStatus)),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.arrow_forward, size: 18, color: theme.canvasColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => PromoterDetailsPage(promoter: cp)),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            _buildPagination(
              currentPage: childCurrentPage,
              totalPages: totalPages,
              onPageChanged: (p) => setState(() => childCurrentPage = p),
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: SETTLEMENT SECTION (DYNAMIC)
  // ==========================================
  Widget _buildSection6Settlements(ThemeData theme, PromoterProvider provider) {
    // Dynamically derive settlement records from actual revenue graph points
    final dynamicSettlements = provider.promoterUserRevenueGraph.where((g) => (g.revenue ?? 0) > 0).map((g) {
      final gRev = (g.revenue ?? 0).toDouble();
      final gBase = gRev / 1.18;
      final gShare = gBase * 0.01;
      final gTds = gShare * 0.10;
      final gCharges = (gShare - gTds) * 0.02;
      final gNet = gShare - gTds - gCharges;
      final isPaid = gNet >= 100;
      return {
        'id': 'SET-${_currentPromoter.id ?? 0}-${g.date?.replaceAll(RegExp(r'[^0-9]'), '') ?? '01'}',
        'period': g.date ?? 'N/A',
        'revenue': _formatMoney(gRev),
        'deduction': _formatMoney(gTds + gCharges),
        'netAmount': _formatMoney(gNet),
        'status': isPaid ? 'Paid' : 'Pending',
        'date': g.date ?? 'N/A',
      };
    }).toList();

    final filteredSettlements = dynamicSettlements.where((s) {
      final matchSearch = settlementSearchQuery.isEmpty ||
          s['id']!.toLowerCase().contains(settlementSearchQuery.toLowerCase());
      final matchStatus = settlementStatusFilter == 'All' || s['status'] == settlementStatusFilter;
      return matchSearch && matchStatus;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMiniCard('Settlement Status', _currentPromoter.displayStatus, Icons.account_balance, theme.primaryColor, theme),
              _buildMiniCard('Payout Eligibility', 'Min. Rs. 500', Icons.check_circle_outline, Colors.green, theme),
              _buildMiniCard('KYC Status', _currentPromoter.isKycCompleted ? 'Verified' : 'Pending', Icons.verified_user_outlined, _currentPromoter.isKycCompleted ? Colors.green : Colors.orange, theme),
              _buildMiniCard('Bank Account', _currentPromoter.accountNumber?.isNotEmpty == true ? 'Configured' : 'Missing', Icons.account_balance, Colors.blue, theme),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by settlement ID...',
                      prefixIcon: Icon(Icons.search, size: 18, color: theme.canvasColor.withValues(alpha: 0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    onChanged: (val) {
                      setState(() {
                        settlementSearchQuery = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: settlementStatusFilter,
                dropdownColor: theme.cardColor,
                items: ['All', 'Paid', 'Pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      settlementStatusFilter = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table
          if (filteredSettlements.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                dynamicSettlements.isEmpty
                    ? 'No settlement payouts generated yet for this promoter.'
                    : 'No settlement records matching filters.',
                style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.scaffoldBackgroundColor),
                columns: const [
                  DataColumn(label: Text('Settlement ID')),
                  DataColumn(label: Text('Period')),
                  DataColumn(label: Text('Gross Revenue')),
                  DataColumn(label: Text('Deductions')),
                  DataColumn(label: Text('Net Paid')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Settlement Date')),
                ],
                rows: filteredSettlements.map((s) {
                  return DataRow(
                    cells: [
                      DataCell(Text(s['id']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(s['period']!)),
                      DataCell(Text(s['revenue']!)),
                      DataCell(Text(s['deduction']!)),
                      DataCell(Text(s['netAmount']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                      DataCell(_buildStatusBadge(s['status']!)),
                      DataCell(Text(s['date']!)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 7: AUDIT HISTORY (PURELY DYNAMIC)
  // ==========================================
  Widget _buildSection7AuditHistory(ThemeData theme, PromoterProvider provider) {
    final logs = provider.getAuditLogsForPromoter(_currentPromoter.id ?? 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: theme.canvasColor, size: 20),
              const SizedBox(width: 8),
              Text('Administrative Audit Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor)),
              const Spacer(),
              Text('Total Events: ${logs.length}', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 14),
          if (logs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'No recent administrative actions recorded for this promoter.',
                style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6), fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final log = logs[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.history, size: 16, color: theme.canvasColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(log.actionType.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(log.description, style: const TextStyle(fontSize: 12)),
                          if (log.previousValue != null && log.newValue != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Changed: ${log.previousValue} → ${log.newValue}',
                                style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text('Performed by: ${log.performedBy}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildSectionHeader(String title, ThemeData theme, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.canvasColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, ThemeData theme,
      {bool isClickable = false, VoidCallback? onTap, Color? customColor}) {
    return SizedBox(
      width: 240,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: customColor ?? (isClickable ? theme.primaryColor : theme.canvasColor),
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isClickable)
                  Icon(Icons.arrow_forward_ios, size: 12, color: theme.canvasColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.green;
    Color fg = Colors.white;

    if (status == 'Inactive' || status == 'REJECTED') {
      bg = Colors.red;
    } else if (status == 'Suspended' || status == 'Pending' || status == 'PENDING') {
      bg = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.canvasColor.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _buildPagination({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
    required ThemeData theme,
  }) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.canvasColor),
          onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text('Page ${currentPage + 1} of $totalPages', style: TextStyle(fontSize: 12, color: theme.canvasColor)),
        IconButton(
          icon: Icon(Icons.chevron_right, color: theme.canvasColor),
          onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }

  String _formatMoney(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0).format(amount);
  }

  void _confirmChangeStatus(BuildContext context, ThemeData theme, PromoterProvider provider) {
    final newStatus = _currentPromoter.isActive ? 'Inactive' : 'Active';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('${_currentPromoter.isActive ? "Deactivate" : "Activate"} Promoter?', style: TextStyle(color: theme.canvasColor)),
        content: Text(
          'Are you sure you want to change status to "$newStatus"?',
          style: TextStyle(color: theme.canvasColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPromoter.isActive ? Colors.red : Colors.green,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (_currentPromoter.id != null) {
                await provider.changePromoterStatus(newStatus, _currentPromoter.id!, context);
              }
              setState(() {
                _currentPromoter = _currentPromoter.copyWith(
                  status: newStatus,
                  active: newStatus == 'Active',
                );
              });
              _refreshPromoter();
            },
            child: Text(newStatus, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

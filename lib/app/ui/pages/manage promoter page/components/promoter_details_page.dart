import 'dart:convert';
import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/transactionProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/assign_parent_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/change_level_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/edit_promoter_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoter_hierarchy_widget.dart';
import 'package:admin_ott/app/widgets/financial_formatter.dart';
import 'package:admin_ott/data/models/response/promoter_dashboard_response.dart';
import 'package:admin_ott/data/models/response/userOnboardAndRevenueGraph.dart';
import 'package:admin_ott/data/models/response/userTransactionResponse.dart';
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
  int promoterDrillDownTab = 0; // 0: Production Houses, 1: Content, 2: Customer Transactions
  String promoterDrillDownSearch = '';

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
    final txnProvider = Provider.of<TransactionProvider>(context, listen: false);
    final promoterId = _currentPromoter.id ??
        widget.promoter.id ??
        (_currentPromoter.promoterId is int
            ? _currentPromoter.promoterId as int
            : int.tryParse(_currentPromoter.promoterId?.toString() ?? '')) ??
        provider.promoterDashboardData?.promoter?.promoterId ??
        provider.promoterDashboardData?.promoter?.id ??
        provider.selectedPromoter?.id ??
        _currentPromoter.userId?.id;
    final refCode = _currentPromoter.userId?.refferCode ?? _currentPromoter.promoterName ?? '';

    if (promoterId != null) {
      // 0. Fetch Hierarchy API (re-reads promoter hierarchy and parent details)
      final hierarchyInfo = await provider.fetchPromoterHierarchy(promoterId, fallback: _currentPromoter);

      // 1. Fetch Promoter Dashboard API (V2)
      await provider.fetchPromoterDashboard(promoterId, forceRefresh: true);

      // 2. Fetch updated promoter profile (V2)
      final updatedProfile = await provider.fetchPromoterProfile(promoterId);
      final dashProm = provider.promoterDashboardData?.promoter;
      final dashLevel = dashProm?.level ?? dashProm?.designation;
      final resolvedLevel = (hierarchyInfo?.level != null && hierarchyInfo!.level!.trim().isNotEmpty && hierarchyInfo.normalizedLevel != 'Taluka')
          ? hierarchyInfo.normalizedLevel
          : (updatedProfile?.level ?? dashLevel ?? _currentPromoter.level);

      if (mounted) {
        setState(() {
          if (updatedProfile != null) {
            _currentPromoter = updatedProfile.copyWith(
              id: promoterId,
              level: resolvedLevel,
              promoterName: hierarchyInfo?.promoterName ?? updatedProfile.promoterName ?? dashProm?.promoterName ?? _currentPromoter.promoterName,
              location: hierarchyInfo?.location ?? updatedProfile.location ?? _currentPromoter.location,
              refferedBy: hierarchyInfo?.parentName ?? updatedProfile.refferedBy ?? _currentPromoter.refferedBy,
              promoterId: hierarchyInfo?.parentPromoterId ?? updatedProfile.promoterId ?? _currentPromoter.promoterId,
            );
          } else if (dashProm != null) {
            _currentPromoter = _currentPromoter.copyWith(
              id: promoterId,
              promoterName: hierarchyInfo?.promoterName ?? dashProm.promoterName ?? _currentPromoter.promoterName,
              contactNumber: dashProm.mobileNumber ?? _currentPromoter.contactNumber,
              level: resolvedLevel,
              refferedBy: hierarchyInfo?.parentName ?? _currentPromoter.refferedBy,
              promoterId: hierarchyInfo?.parentPromoterId ?? _currentPromoter.promoterId,
            );
          } else if (hierarchyInfo != null) {
            _currentPromoter = _currentPromoter.copyWith(
              id: promoterId,
              promoterName: hierarchyInfo.promoterName ?? _currentPromoter.promoterName,
              level: resolvedLevel,
              refferedBy: hierarchyInfo.parentName ?? _currentPromoter.refferedBy,
              promoterId: hierarchyInfo.parentPromoterId ?? _currentPromoter.promoterId,
            );
          }
        });
      }

      // 3. Fetch promoter users (V2)
      await provider.fetchPromoterUsers(promoterId, refCode: refCode);

      // 4. Fetch child promoters (V2)
      await provider.fetchChildPromoters(promoterId, refCode: refCode);

      // 5. Fetch onboard & revenue graph (V2)
      final now = DateTime.now();
      final startDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: selectedRevenueDays)));
      final endDate = DateFormat('yyyy-MM-dd').format(now);
      await provider.fetchPromoterOnboardAndRevenueGraph(promoterId, startDate: startDate, endDate: endDate);

      // 6. Fetch user movie transactions (V2)
      await provider.fetchPromoterMovieTransactions(promoterId);

      // 7. Fetch promoter settlements (V2)
      await provider.fetchPromoterSettlements(promoterId);
    } else if (refCode.isNotEmpty) {
      await provider.getUsersByUserReferalCode(refCode);
      await provider.getPromotersByUserReferalCode(refCode);
    }

    await txnProvider.fetchUserTransactions('');
  }

  void _onTimeframeChanged(String label) {
    setState(() {
      selectedRevenueTimeframe = label;
      if (label == '1W') selectedRevenueDays = 7;
      if (label == '1M') selectedRevenueDays = 30;
      if (label == '3M') selectedRevenueDays = 90;
      if (label == '6M') selectedRevenueDays = 180;
      if (label == '1Y') selectedRevenueDays = 365;
      if (label == 'All') selectedRevenueDays = 1000;
    });
    if (_currentPromoter.id != null) {
      final now = DateTime.now();
      final startDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: selectedRevenueDays)));
      final endDate = DateFormat('yyyy-MM-dd').format(now);
      Provider.of<PromoterProvider>(context, listen: false)
          .getUsersAndRevenue(_currentPromoter.id!, startDate: startDate, endDate: endDate);
    }
  }

  void _refreshPromoter() {
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    final effectiveId = _currentPromoter.id ??
        widget.promoter.id ??
        (_currentPromoter.promoterId is int
            ? _currentPromoter.promoterId as int
            : int.tryParse(_currentPromoter.promoterId?.toString() ?? '')) ??
        provider.promoterDashboardData?.promoter?.promoterId ??
        provider.promoterDashboardData?.promoter?.id ??
        provider.selectedPromoter?.id ??
        _currentPromoter.userId?.id;

    if (effectiveId != null) {
      try {
        final updated = provider.promoterList.firstWhere(
          (p) => p.id == effectiveId || p.userId?.id == effectiveId,
        );
        setState(() {
          _currentPromoter = updated;
        });
      } catch (_) {}
    }
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

  // ==========================================
  // SANITIZATION HELPERS (PREVENT RAW JSON OUTPUT)
  // ==========================================
  String _sanitizeText(dynamic val, {String fallback = 'N/A'}) {
    if (val == null) return fallback;
    if (val is Map) {
      final candidate = val['mediaHouseName'] ??
          val['MediaHouseName'] ??
          val['name'] ??
          val['Name'] ??
          val['promoterName'] ??
          val['title'] ??
          val['Title'] ??
          val['productionHouse'] ??
          val['productionHouseName'] ??
          val['firstName'] ??
          val['city'] ??
          val['state'] ??
          val['district'] ??
          val['value'] ??
          val['label'];
      if (candidate != null && candidate.toString().trim().isNotEmpty) {
        return candidate.toString().trim();
      }
      return fallback;
    }
    if (val is String) {
      final trimmed = val.trim();
      if (trimmed.isEmpty || trimmed == 'null' || trimmed == 'undefined' || trimmed == 'N/A') {
        return fallback;
      }
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map) {
            final candidate = decoded['mediaHouseName'] ??
                decoded['MediaHouseName'] ??
                decoded['name'] ??
                decoded['Name'] ??
                decoded['promoterName'] ??
                decoded['title'] ??
                decoded['Title'] ??
                decoded['productionHouse'] ??
                decoded['productionHouseName'] ??
                decoded['firstName'] ??
                decoded['city'] ??
                decoded['state'] ??
                decoded['district'] ??
                decoded['value'] ??
                decoded['label'];
            if (candidate != null && candidate.toString().trim().isNotEmpty) {
              return candidate.toString().trim();
            }
          }
        } catch (_) {}

        final mediaHouseMatch = RegExp(r'mediaHouseName:\s*([^,}]+)').firstMatch(trimmed);
        if (mediaHouseMatch != null && mediaHouseMatch.group(1)?.trim().isNotEmpty == true) {
          return mediaHouseMatch.group(1)!.trim();
        }
        final nameMatch = RegExp(r'name:\s*([^,}]+)').firstMatch(trimmed);
        if (nameMatch != null && nameMatch.group(1)?.trim().isNotEmpty == true) {
          return nameMatch.group(1)!.trim();
        }
        final titleMatch = RegExp(r'title:\s*([^,}]+)').firstMatch(trimmed);
        if (titleMatch != null && titleMatch.group(1)?.trim().isNotEmpty == true) {
          return titleMatch.group(1)!.trim();
        }
        final promoterNameMatch = RegExp(r'promoterName:\s*([^,}]+)').firstMatch(trimmed);
        if (promoterNameMatch != null && promoterNameMatch.group(1)?.trim().isNotEmpty == true) {
          return promoterNameMatch.group(1)!.trim();
        }
      }
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is List) {
            final items = decoded
                .map((e) => _sanitizeText(e, fallback: ''))
                .where((s) => s.isNotEmpty)
                .join(', ');
            if (items.isNotEmpty) return items;
          }
        } catch (_) {}
      }
      return trimmed;
    }
    if (val is List) {
      final items = val
          .map((e) => _sanitizeText(e, fallback: ''))
          .where((s) => s.isNotEmpty)
          .join(', ');
      return items.isNotEmpty ? items : fallback;
    }
    return val.toString().trim();
  }

  String _formatDate(dynamic dateVal, {String pattern = 'dd MMM yyyy'}) {
    if (dateVal == null) return 'N/A';
    if (dateVal is int) {
      if (dateVal > 0) {
        try {
          final dt = DateTime.fromMillisecondsSinceEpoch(dateVal);
          return DateFormat(pattern).format(dt);
        } catch (_) {}
      }
    }
    final str = dateVal.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'N/A') return 'N/A';
    final parsedInt = int.tryParse(str);
    if (parsedInt != null && parsedInt > 100000000) {
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(parsedInt);
        return DateFormat(pattern).format(dt);
      } catch (_) {}
    }
    try {
      final dt = DateTime.tryParse(str);
      if (dt != null) {
        return DateFormat(pattern).format(dt);
      }
    } catch (_) {}
    return _sanitizeText(str, fallback: 'N/A');
  }

  String _maskAccountNumber(String? acc) {
    if (acc == null || acc.trim().isEmpty || acc == 'N/A' || acc == 'Not Provided') {
      return 'Not Provided';
    }
    final cleaned = _sanitizeText(acc, fallback: 'Not Provided');
    if (cleaned == 'Not Provided' || cleaned.length <= 4) return cleaned;
    final last4 = cleaned.substring(cleaned.length - 4);
    return '******$last4';
  }

  Promoters _getEffectivePromoter(PromoterProvider provider) {
    final dashProm = provider.promoterDashboardData?.promoter;
    final dashLevel = dashProm?.level ?? dashProm?.designation;
    final dashId = dashProm?.promoterId ?? dashProm?.id;

    Promoters p = _currentPromoter;
    if (p.id == null && dashId != null) {
      p = p.copyWith(id: dashId);
    }
    if ((p.promoterName == null || p.promoterName!.isEmpty) && dashProm?.promoterName != null) {
      p = p.copyWith(promoterName: dashProm!.promoterName);
    }
    if (dashLevel != null &&
        dashLevel.trim().isNotEmpty &&
        (p.level == null || p.level!.trim().isEmpty)) {
      p = p.copyWith(level: dashLevel);
    }
    return p;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    final promoterApi = provider.promoterDashboardData?.promoter;
    final displayName = _sanitizeText(
      promoterApi?.promoterName ?? _currentPromoter.promoterName ?? '${_currentPromoter.userId?.firstName ?? ""} ${_currentPromoter.userId?.lastName ?? ""}',
      fallback: 'Promoter',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '$displayName • Promoter Profile',
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
              _getEffectivePromoter(provider),
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
                  _getEffectivePromoter(provider),
                  onLevelChanged: _refreshPromoter,
                );
              } else if (val == 'assign_parent') {
                showAssignParentDialog(
                  context,
                  _getEffectivePromoter(provider),
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
            // DASHBOARD API LOADING / ERROR NOTIFIERS
            if (provider.isPromoterDashboardLoading && provider.promoterDashboardData == null) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: 12),
            ],
            if (provider.promoterDashboardError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to load promoter dashboard metrics: ${provider.promoterDashboardError}',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
                      label: const Text('Retry', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        final promoterId = _currentPromoter.id ?? _currentPromoter.userId?.id;
                        if (promoterId != null) {
                          provider.fetchPromoterDashboard(promoterId, forceRefresh: true);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],

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
  // SECTION 1: PERSONAL INFORMATION & OVERVIEW
  // ==========================================
  Widget _buildSection1PersonalInfo(ThemeData theme, PromoterProvider provider) {
    final p = _currentPromoter;
    final promoterApi = provider.promoterDashboardData?.promoter;
    final parent = provider.getParentPromoter(p);
    final currentLevel = _sanitizeText(
      (p.level != null && p.level!.trim().isNotEmpty && p.normalizedLevel != 'Taluka')
          ? p.normalizedLevel
          : (promoterApi?.level ?? p.normalizedLevel),
      fallback: 'Taluka',
    );
    final levelColor = _getLevelColor(currentLevel);
    final loc = p.location ?? p.userId?.location;

    final displayName = _sanitizeText(
      promoterApi?.promoterName ?? p.promoterName ?? '${p.userId?.firstName ?? ""} ${_currentPromoter.userId?.lastName ?? ""}',
      fallback: 'Promoter',
    );

    final displayMobile = _sanitizeText(
      promoterApi?.mobileNumber ?? p.contactNumber ?? p.userId?.mobileNumber,
      fallback: 'N/A',
    );

    final displayPromoterId = _sanitizeText(
      promoterApi?.promoterId ?? p.id ?? p.userId?.id,
      fallback: 'N/A',
    );

    final displayDesignation = _sanitizeText(
      promoterApi?.designation ?? p.role,
      fallback: 'PROMOTER',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. MAIN HEADER OVERVIEW CARD
        Container(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              final avatarAndBasic = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                    backgroundImage: (p.userId?.profilePhoto != null && p.userId!.profilePhoto!.trim().isNotEmpty)
                        ? NetworkImage(p.userId!.profilePhoto!.trim())
                        : null,
                    child: (p.userId?.profilePhoto == null || p.userId!.profilePhoto!.trim().isEmpty)
                        ? Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          )
                        : null,
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
                                displayName,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.military_tech_outlined, size: 14, color: levelColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$currentLevel Level Promoter',
                                    style: TextStyle(
                                      color: levelColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
                            _buildIconText(Icons.badge_outlined, 'Promoter ID: #$displayPromoterId', theme),
                            _buildIconText(Icons.phone_outlined, displayMobile, theme),
                            _buildIconText(Icons.email_outlined, _sanitizeText(p.userId?.emailId, fallback: 'N/A'), theme),
                            _buildIconText(Icons.calendar_today_outlined, 'Joined: ${_formatDate(p.createdDate ?? p.userId?.joinDate)}', theme),
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
                      _getEffectivePromoter(provider),
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
                      _getEffectivePromoter(provider),
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
        ),
        const SizedBox(height: 16),

        // 2. OVERVIEW DASHBOARD METRIC CARDS (API V2)
        LayoutBuilder(
          builder: (context, constraints) {
            final stats = provider.promoterDashboardData?.dashboard;
            final usersData = provider.promoterDashboardData?.users;
            final promotersData = provider.promoterDashboardData?.promoters;

            final double custPay = stats?.customerPayment ?? stats?.grossRevenue ?? 0.0;
            final double baseAmt = stats?.baseAmountAfterGST ?? stats?.baseRevenue ?? (custPay > 0 ? FinancialFormatter.calculateBaseAmount(custPay) : 0.0);
            final double promRev = stats?.promoterRevenue ?? stats?.promoterShare ?? 0.0;
            final double wallBal = stats?.walletBalance ?? stats?.finalPromoterRevenue ?? 0.0;

            final overviewCards = [
              _buildMetricCard(
                'Total Users',
                '${stats?.totalUsers ?? usersData?.totalUsers ?? provider.usersByPromoterCode.length}',
                Icons.group_outlined,
                theme.primaryColor,
                theme,
              ),
              _buildMetricCard(
                'Total Promoters',
                '${stats?.totalPromoters ?? promotersData?.totalPromoters ?? provider.promotersByPromoterCode.length}',
                Icons.badge_outlined,
                Colors.deepPurple,
                theme,
              ),
              _buildMetricCard(
                'Customer Payment',
                _formatMoney(custPay),
                Icons.payments_outlined,
                Colors.indigo,
                theme,
              ),
              _buildMetricCard(
                'Base Amount',
                _formatMoney(baseAmt),
                Icons.account_balance_outlined,
                Colors.blue,
                theme,
              ),
              _buildMetricCard(
                'Promoter Revenue',
                _formatMoney(promRev),
                Icons.savings_outlined,
                Colors.green,
                theme,
              ),
              _buildMetricCard(
                'Wallet Balance',
                _formatMoney(wallBal),
                Icons.account_balance_wallet_outlined,
                Colors.teal,
                theme,
              ),
              _buildMetricCard(
                'Total Purchases',
                '${stats?.totalPurchases ?? 0}',
                Icons.shopping_bag_outlined,
                Colors.purple,
                theme,
              ),
              _buildMetricCard(
                'Total Views',
                '${stats?.totalViews ?? 0}',
                Icons.visibility_outlined,
                Colors.orange,
                theme,
              ),
            ];

            return LayoutBuilder(
              builder: (ctx, box) {
                final isDesktop = box.maxWidth >= 1050;
                final isTablet = box.maxWidth >= 600;

                if (isDesktop) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: overviewCards
                        .map((card) => SizedBox(
                              width: (box.maxWidth - 36) / 4,
                              child: card,
                            ))
                        .toList(),
                  );
                } else if (isTablet) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: overviewCards
                        .map((card) => SizedBox(
                              width: (box.maxWidth - 24) / 3,
                              child: card,
                            ))
                        .toList(),
                  );
                } else {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: overviewCards
                        .map((card) => SizedBox(
                              width: (box.maxWidth - 12) / 2,
                              child: card,
                            ))
                        .toList(),
                  );
                }
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // 3. GRID OF DETAILS: PERSONAL INFO, CONTACT, LOCATION & HIERARCHY, BANKING & KYC
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;
            final cardWidth = isDesktop ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // CARD A: PERSONAL & IDENTITY INFORMATION
                SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                            Icon(Icons.person_outline, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Personal & Identity Details',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildInfoItem('Promoter Name', displayName, theme),
                            _buildInfoItem('Promoter ID', '#$displayPromoterId', theme),
                            _buildInfoItem('User ID', p.userId?.id != null ? '#${p.userId!.id}' : 'N/A', theme),
                            _buildInfoItem('First Name', _sanitizeText(p.userId?.firstName, fallback: 'N/A'), theme),
                            _buildInfoItem('Last Name', _sanitizeText(p.userId?.lastName, fallback: 'N/A'), theme),
                            _buildInfoItem('Designation', displayDesignation, theme),
                            _buildInfoItem('Gender', _sanitizeText(p.userId?.gender, fallback: 'N/A'), theme),
                            _buildInfoItem('Date of Birth', _formatDate(p.userId?.dob), theme),
                            _buildInfoItem('Registration Date', _formatDate(p.createdDate ?? p.userId?.registrationDate), theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // CARD B: CONTACT & REFERRAL INFORMATION
                SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                            Icon(Icons.contact_mail_outlined, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Contact & Referral Details',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildInfoItem('Mobile Number', displayMobile, theme),
                            _buildInfoItem('Email Address', _sanitizeText(p.userId?.emailId, fallback: 'N/A'), theme),
                            _buildInfoItem('Referral Code', _sanitizeText(p.userId?.refferCode ?? p.promoterName, fallback: 'N/A'), theme),
                            _buildInfoItem('Website', _sanitizeText(p.website, fallback: 'N/A'), theme),
                            _buildInfoItem(
                              'Reporting Parent Promoter',
                              parent != null
                                  ? '${_sanitizeText(parent.promoterName)} (${parent.normalizedLevel})'
                                  : (currentLevel == 'National' ? 'None (Apex Level)' : 'Not Assigned'),
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
                            _buildInfoItem('Account Status', p.displayStatus, theme, customColor: p.isActive ? Colors.green : Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // CARD C: ADDRESS & GEOGRAPHIC HIERARCHY
                SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                            Icon(Icons.location_on_outlined, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Address & Geographic Hierarchy',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Visual Hierarchy Breadcrumb
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                          ),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _buildLocationChip(_sanitizeText(loc?.country, fallback: 'India'), isApex: true),
                              _buildBreadcrumbArrow(),
                              _buildLocationChip(_sanitizeText(loc?.state, fallback: 'State N/A')),
                              _buildBreadcrumbArrow(),
                              _buildLocationChip(_sanitizeText(loc?.district, fallback: 'District N/A')),
                              _buildBreadcrumbArrow(),
                              _buildLocationChip(_sanitizeText(loc?.taluka, fallback: 'Taluka N/A')),
                              _buildBreadcrumbArrow(),
                              _buildLocationChip(_sanitizeText(loc?.city ?? loc?.area, fallback: 'City N/A')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildInfoItem('Country', _sanitizeText(loc?.country, fallback: 'India'), theme),
                            _buildInfoItem('State', _sanitizeText(loc?.state, fallback: 'N/A'), theme),
                            _buildInfoItem('District', _sanitizeText(loc?.district, fallback: 'N/A'), theme),
                            _buildInfoItem('Taluka', _sanitizeText(loc?.taluka, fallback: 'N/A'), theme),
                            _buildInfoItem('City / Village', _sanitizeText(loc?.city, fallback: 'N/A'), theme),
                            _buildInfoItem('Office / Building', _sanitizeText(loc?.officeBuilding, fallback: 'N/A'), theme),
                            _buildInfoItem('Area / Locality', _sanitizeText(loc?.area, fallback: 'N/A'), theme),
                            _buildInfoItem('Pincode / Postal Code', _sanitizeText(loc?.pincode ?? p.pincode, fallback: 'N/A'), theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // CARD D: BANKING & KYC DETAILS
                SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                            Icon(Icons.account_balance_outlined, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Banking & Statutory Verification',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (p.isKycCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.isKycCompleted ? 'Verified' : 'Verification Incomplete',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: p.isKycCompleted ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _buildDocumentInfoItem('PAN Card', p.panCard, context, theme),
                            _buildDocumentInfoItem('Aadhaar Card', p.aadharCard, context, theme),
                            _buildInfoItem('Bank Name', _sanitizeText(p.bankName, fallback: 'Not Provided'), theme),
                            _buildInfoItem('Account Number', _maskAccountNumber(p.accountNumber), theme),
                            _buildInfoItem('IFSC Code', _sanitizeText(p.ifscCode, fallback: 'Not Provided'), theme),
                            _buildInfoItem('Branch Name', _sanitizeText(p.branchName, fallback: 'Not Provided'), theme),
                            _buildInfoItem('GST Number', _sanitizeText(p.gst, fallback: 'Not Provided'), theme),
                            _buildDocumentInfoItem('Registration Cert.', p.registrationCertificate, context, theme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationChip(String text, {bool isApex = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isApex ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBreadcrumbArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward_ios, size: 9, color: Colors.grey),
    );
  }

  // ==========================================
  // ==========================================
  // SECTION 3: REVENUE & FINANCIAL BREAKDOWN (CONSOLIDATED FLOW)
  // ==========================================
  Widget _buildSection3Revenue(ThemeData theme, PromoterProvider provider) {
    final stats = provider.promoterDashboardData?.dashboard;
    final directUsers = provider.usersByPromoterCode;
    final childPromoters = provider.promotersByPromoterCode.isNotEmpty
        ? provider.promotersByPromoterCode
        : provider.getChildPromoters(_currentPromoter);

    final apiIncentive = double.tryParse((provider.incentive ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final apiEarned = double.tryParse((provider.revenue ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    final graph = provider.promoterUserRevenueGraph;
    double grossFromGraph = 0.0;
    for (var item in graph) {
      grossFromGraph += (item.revenue ?? 0.0);
    }

    // 1. Customer Payment (authoritative backend value first)
    final double gross = stats?.grossRevenue?.toDouble() ?? (stats?.customerPayment?.toDouble() ?? (apiIncentive > 0 ? apiIncentive : grossFromGraph));
    final double customerPayment = stats?.customerPayment?.toDouble() ?? gross;

    // 2. GST Charges
    final double gst = stats?.gstCharges?.toDouble() ?? stats?.gst?.toDouble() ?? (customerPayment * 0.18 / 1.18);

    // 3. Base Amount After GST
    final double base = stats?.baseAmountAfterGST?.toDouble() ?? stats?.baseRevenue?.toDouble() ?? (customerPayment == 0 ? 0.0 : (customerPayment - gst));

    // 4. Platform Charges (2%)
    final double platformChargesRate = stats?.platformChargesPercentage?.toDouble() ?? 2.0;
    final double platformCharges = stats?.platformCharges?.toDouble() ?? (base * (platformChargesRate / 100.0));

    // 5. Platform Payout Charges Deduction
    final double platformPayoutCharges = stats?.platformPayoutCharges?.toDouble() ?? stats?.paymentGatewayFee?.toDouble() ?? 0.0;

    // 6. Final Revenue (after all platform deductions)
    final double finalRevenue = stats?.finalRevenue?.toDouble() ?? (base - platformCharges - platformPayoutCharges);

    // 7. Promoter Percentage & 8. Promoter Revenue
    final double promoterRate = stats?.promoterPercentage?.toDouble() ?? FinancialFormatter.getPromoterRate(_currentPromoter.normalizedLevel);
    final double promoterRevenue = stats?.promoterRevenue?.toDouble() ?? stats?.promoterShare?.toDouble() ?? (apiEarned > 0 ? apiEarned : (base * (promoterRate > 1.0 ? promoterRate / 100.0 : promoterRate)));

    // 9. Tax Percentage & 10. Tax
    final double taxRate = stats?.taxPercentage?.toDouble() ?? stats?.tdsPercentage?.toDouble() ?? 10.0;
    final double tax = stats?.tax?.toDouble() ?? stats?.tdsDeduction?.toDouble() ?? (promoterRevenue * (taxRate / 100.0));

    // 11. Final Promoter Revenue
    final double finalPromoterRevenue = stats?.finalPromoterRevenue?.toDouble() ?? stats?.finalSettlementWallet?.toDouble() ?? (promoterRevenue - tax);

    // Balances
    final double walletBalance = stats?.walletBalance?.toDouble() ?? finalPromoterRevenue;
    final double totalWithdrawn = stats?.totalWithdrawn?.toDouble() ?? (promoterRevenue - walletBalance > 0 ? promoterRevenue - walletBalance : 0.0);
    final double pendingAmount = stats?.pendingAmount?.toDouble() ?? 0.0;

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
          // 1. ONE AUTHORITATIVE REVENUE & FINANCIAL BREAKDOWN FLOW
          _buildConsolidatedRevenueBreakdownCard(
            theme: theme,
            provider: provider,
            customerPayment: customerPayment,
            gst: gst,
            baseAmount: base,
            platformChargesRate: platformChargesRate,
            platformCharges: platformCharges,
            platformPayoutCharges: platformPayoutCharges,
            finalRevenue: finalRevenue,
            promoterRate: promoterRate,
            promoterRevenue: promoterRevenue,
            taxRate: taxRate,
            tax: tax,
            finalPromoterRevenue: finalPromoterRevenue,
            walletBalance: walletBalance,
            totalWithdrawn: totalWithdrawn,
            pendingAmount: pendingAmount,
            stats: stats,
          ),
          const SizedBox(height: 20),

          // 2. NETWORK PERFORMANCE & METRICS
          _buildNetworkCompositionRow(theme, directUsers, childPromoters, userPct, childPct),
          const SizedBox(height: 20),

          // 3. INTERACTIVE CHART & TIMEFRAME FILTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue & Onboarding Performance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.canvasColor),
              ),
              Wrap(
                spacing: 6,
                children: ['1W', '1M', '3M', '6M', '1Y', 'All'].map((label) {
                  final isSelected = selectedRevenueTimeframe == label;
                  return InkWell(
                    onTap: () => _onTimeframeChanged(label),
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
          const SizedBox(height: 24),

          // 4. TRANSACTION-LEVEL DRILL-DOWN (WITHOUT DUPLICATE SUMMARY CARDS)
          _buildPromoterDrillDownSection(
            theme: theme,
            promoterRate: promoterRate,
            platformChargesRate: platformChargesRate,
            taxRate: taxRate,
          ),
        ],
      ),
    );
  }

  Widget _buildConsolidatedRevenueBreakdownCard({
    required ThemeData theme,
    required PromoterProvider provider,
    required double customerPayment,
    required double gst,
    required double baseAmount,
    required double platformChargesRate,
    required double platformCharges,
    required double platformPayoutCharges,
    required double finalRevenue,
    required double promoterRate,
    required double promoterRevenue,
    required double taxRate,
    required double tax,
    required double finalPromoterRevenue,
    required double walletBalance,
    required double totalWithdrawn,
    required double pendingAmount,
    required PromoterDashboardStats? stats,
  }) {
    final isApiLoaded = provider.promoterDashboardData != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_tree_outlined, size: 20, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promoter Revenue & Financial Breakdown',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.canvasColor),
                      ),
                      Text(
                        'Authoritative Step-by-Step Financial Flow (Customer Payment → Final Promoter Revenue)',
                        style: TextStyle(fontSize: 11, color: theme.canvasColor.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isApiLoaded ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isApiLoaded ? Colors.green : Colors.orange, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: isApiLoaded ? Colors.green : Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        isApiLoaded ? 'Live API Verified' : 'Local Calculated Data',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApiLoaded ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 960;
                final colWidth = isDesktop ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    // ==========================================
                    // PANEL 1: REVENUE SUMMARY & PLATFORM FLOW (STEPS 1 - 6)
                    // ==========================================
                    SizedBox(
                      width: colWidth,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.payments_outlined, size: 16, color: Colors.indigo),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Revenue Summary & Platform Deductions',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Step 1: Customer Payment
                            _buildSequenceItem(
                              stepNum: '1',
                              label: 'Customer Payment',
                              value: _formatMoney(customerPayment),
                              subtitle: 'Actual gross payment collected from customers',
                              color: Colors.indigo,
                              isPrimary: true,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 2: GST Charges
                            _buildSequenceItem(
                              stepNum: '2',
                              label: 'GST Charges (18%)',
                              value: '- ${_formatMoney(gst)}',
                              subtitle: 'Statutory GST deduction',
                              color: Colors.redAccent,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 3: Base Amount After GST
                            _buildSequenceItem(
                              stepNum: '3',
                              label: 'Base Amount After GST',
                              value: _formatMoney(baseAmount),
                              subtitle: 'Customer Payment - GST Charges',
                              color: Colors.blue,
                              isHighlight: true,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 4: Platform Charges (2%)
                            _buildSequenceItem(
                              stepNum: '4',
                              label: 'Platform Charges (${platformChargesRate.toStringAsFixed(2)}%)',
                              value: '- ${_formatMoney(platformCharges)}',
                              subtitle: 'Base Amount After GST × 2%',
                              color: Colors.orange,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 5: Platform Payout Charges Deduction
                            _buildSequenceItem(
                              stepNum: '5',
                              label: 'Platform Payout Charges Deduction',
                              value: platformPayoutCharges > 0
                                  ? '- ${_formatMoney(platformPayoutCharges)}'
                                  : _formatMoney(0.0),
                              subtitle: 'Authoritative payout/transfer deduction',
                              color: Colors.blueGrey,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 6: Final Revenue
                            _buildSequenceItem(
                              stepNum: '6',
                              label: 'Final Revenue',
                              value: _formatMoney(finalRevenue),
                              subtitle: 'Base Amount - Platform Charges - Payout Charges',
                              color: Colors.deepPurple,
                              isHighlight: true,
                              isFinalStep: true,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==========================================
                    // PANEL 2: PROMOTER COMMISSION & NET PAYOUT (STEPS 7 - 10)
                    // ==========================================
                    SizedBox(
                      width: colWidth,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.savings_outlined, size: 16, color: Colors.green),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Promoter Commission & Payout Flow',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Step 7 & 8: Promoter Percentage & Promoter Revenue
                            _buildSequenceItem(
                              stepNum: '7-8',
                              label: 'Promoter Commission (${promoterRate.toStringAsFixed(2)}%)',
                              value: _formatMoney(promoterRevenue),
                              subtitle: 'Commission calculated on authoritative revenue base',
                              color: Colors.green,
                              isPrimary: true,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 9 & 10: Tax / Applicable Deductions
                            _buildSequenceItem(
                              stepNum: '9-10',
                              label: 'Tax / Other Deductions (TDS ${taxRate.toStringAsFixed(2)}%)',
                              value: '- ${_formatMoney(tax)}',
                              subtitle: 'Statutory tax withholding deduction',
                              color: Colors.redAccent,
                              theme: theme,
                            ),
                            _buildStepConnector(theme),

                            // Step 11: Final Promoter Revenue (Prominently Highlighted)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Final Promoter Revenue',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'Promoter Revenue - Tax / Applicable Deductions',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatMoney(finalPromoterRevenue),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey.withValues(alpha: 0.2)),
                            const SizedBox(height: 10),

                            // Wallet & Balances Sub-Section
                            Text(
                              'Promoter Wallet & Balances',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.canvasColor.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildWalletBalanceRow('Current Wallet Balance', _formatMoney(walletBalance), Colors.teal, theme),
                            const SizedBox(height: 6),
                            _buildWalletBalanceRow('Total Withdrawn to Bank', _formatMoney(totalWithdrawn), Colors.purple, theme),
                            const SizedBox(height: 6),
                            _buildWalletBalanceRow('Pending Settlement', _formatMoney(pendingAmount), Colors.orange, theme),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceItem({
    required String stepNum,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required ThemeData theme,
    bool isPrimary = false,
    bool isHighlight = false,
    bool isFinalStep = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? color.withValues(alpha: 0.08)
            : isPrimary
                ? theme.scaffoldBackgroundColor
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isHighlight ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              stepNum,
              style: TextStyle(
                fontSize: stepNum.length > 2 ? 9 : 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isHighlight || isPrimary ? FontWeight.bold : FontWeight.w600,
                    color: theme.canvasColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.canvasColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 13,
              fontWeight: isHighlight || isPrimary ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 10,
            color: Colors.grey.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_downward, size: 10, color: Colors.grey.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceRow(String label, String value, Color color, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: theme.canvasColor.withValues(alpha: 0.7)),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildNetworkCompositionRow(
    ThemeData theme,
    List directUsers,
    List childPromoters,
    String userPct,
    String childPct,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Network Composition',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.canvasColor),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Direct Users ($userPct%):', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
                    Text('${directUsers.length} Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.canvasColor)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Child Promoters ($childPct%):', style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
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
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Network Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.canvasColor),
                ),
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
    );
  }

  Widget _buildRevenueChart(PromoterProvider provider, ThemeData theme) {
    final graphData = provider.promoterUserRevenueGraph;
    if (graphData.isEmpty) {
      return Center(
        child: Text(
          'No revenue or onboarding graph data available for this timeframe',
          style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.6)),
        ),
      );
    }

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: TextStyle(fontSize: 10),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
        labelStyle: TextStyle(fontSize: 10),
      ),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<PromoterUserRevenueGraph, String>>[
        ColumnSeries<PromoterUserRevenueGraph, String>(
          name: 'Revenue (₹)',
          dataSource: graphData,
          xValueMapper: (PromoterUserRevenueGraph data, _) => data.date ?? '',
          yValueMapper: (PromoterUserRevenueGraph data, _) => (data.revenue ?? 0).toDouble(),
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        LineSeries<PromoterUserRevenueGraph, String>(
          name: 'Users Onboarded',
          dataSource: graphData,
          xValueMapper: (PromoterUserRevenueGraph data, _) => data.date ?? '',
          yValueMapper: (PromoterUserRevenueGraph data, _) => (data.usersOnboarded ?? 0).toDouble(),
          color: Colors.green,
          width: 2.5,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildPromoterDrillDownSection({
    required ThemeData theme,
    required double promoterRate,
    required double platformChargesRate,
    required double taxRate,
  }) {
    final provider = Provider.of<PromoterProvider>(context);
    final txnProvider = Provider.of<TransactionProvider>(context);
    final allTxns = txnProvider.filtteredUserTransactionList;
    final refCode = _currentPromoter.userId?.refferCode ?? _currentPromoter.promoterName ?? '';

    // Prioritize V2 User Movie Transactions API
    final v2Txns = provider.promoterMovieTransactions;

    // Filter transactions linked to this promoter if using platform txns fallback
    final matchedTxns = allTxns.where((t) {
      if (refCode.isEmpty) return false;
      final ref = t.refferedBy?.trim().toLowerCase() ?? '';
      final code = refCode.trim().toLowerCase();
      final name = (_currentPromoter.promoterName ?? '').trim().toLowerCase();
      return ref == code || (name.isNotEmpty && ref == name);
    }).toList();

    final txns = v2Txns.isNotEmpty ? v2Txns : (matchedTxns.isNotEmpty ? matchedTxns : allTxns);

    // Calculate unique counts
    final uniqueHouses = <String>{};
    final uniqueContents = <String>{};
    for (var t in txns) {
      uniqueHouses.add(_sanitizeText(t.movie?.mediaHouseName, fallback: 'Production House'));
      uniqueContents.add(_sanitizeText(t.movie?.title, fallback: 'Content'));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.analytics_outlined, color: theme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction / Revenue Details (Drill-Down)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.canvasColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Attribution across production houses, content catalog & customer transaction records',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '${txns.length} Transactions',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Sub Tabs Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDrillTabButton(
                    'Revenue by Production House',
                    Icons.business_outlined,
                    0,
                    uniqueHouses.length,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildDrillTabButton(
                    'Revenue by Content',
                    Icons.movie_filter_outlined,
                    1,
                    uniqueContents.length,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildDrillTabButton(
                    'Customer Transactions',
                    Icons.receipt_long_outlined,
                    2,
                    txns.length,
                    theme,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Table Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: promoterDrillDownTab == 0
                ? _buildRevenueByProductionHouseTable(theme, txns, promoterRate)
                : promoterDrillDownTab == 1
                    ? _buildRevenueByContentTable(theme, txns, promoterRate)
                    : _buildCustomerTransactionsTable(
                        theme: theme,
                        txns: txns,
                        promoterRate: promoterRate,
                        platformChargesRate: platformChargesRate,
                        taxRate: taxRate,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillTabButton(String label, IconData icon, int index, int count, ThemeData theme) {
    final isSelected = promoterDrillDownTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          promoterDrillDownTab = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.withValues(alpha: 0.25),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : theme.canvasColor.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.canvasColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'PH';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
      Colors.blueGrey,
      Colors.cyan,
      Colors.brown,
      Colors.deepPurple,
    ];
    int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  Widget _buildRevenueByProductionHouseTable(ThemeData theme, List<UserTransactionData> txns, double promoterRate) {
    final Map<String, List<UserTransactionData>> houseMap = {};
    for (var t in txns) {
      final house = _sanitizeText(t.movie?.mediaHouseName, fallback: 'Filmytell Productions');
      houseMap.putIfAbsent(house, () => []).add(t);
    }

    if (houseMap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.business_outlined, size: 42, color: theme.canvasColor.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text('No production house data available', style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    final totalOverallPayment = txns.fold<double>(0.0, (sum, t) => sum + (t.price ?? t.movie?.price ?? 0.0));
    final totalOverallBase = FinancialFormatter.calculateBaseAmount(totalOverallPayment);
    final totalOverallShare = FinancialFormatter.calculatePromoterRevenue(totalOverallPayment, promoterRate);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.08)),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Production House', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Customer Payment', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Base Amount (Ex. GST)', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Promoter Rate', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Promoter Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          ...houseMap.entries.map((entry) {
            final houseName = entry.key;
            final houseTxns = entry.value;
            final totalPayment = houseTxns.fold<double>(0.0, (sum, t) => sum + (t.price ?? t.movie?.price ?? 0.0));
            final baseAmount = FinancialFormatter.calculateBaseAmount(totalPayment);
            final promoterShare = FinancialFormatter.calculatePromoterRevenue(totalPayment, promoterRate);
            final avatarBg = _getAvatarColor(houseName);

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: avatarBg.withValues(alpha: 0.18),
                        child: Text(
                          _getInitials(houseName),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: avatarBg),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        houseName,
                        style: TextStyle(fontWeight: FontWeight.w600, color: theme.canvasColor),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${houseTxns.length} txns',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primaryColor),
                    ),
                  ),
                ),
                DataCell(Text(_formatMoney(totalPayment), style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(_formatMoney(baseAmount))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${promoterRate.toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatMoney(promoterShare),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                    ),
                  ),
                ),
              ],
            );
          }),
          // Summary Footer Row
          DataRow(
            color: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.06)),
            cells: [
              DataCell(
                Text(
                  'Total (${houseMap.length} Houses)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ),
              DataCell(
                Text(
                  '${txns.length} txns',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(totalOverallPayment),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(totalOverallBase),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '${promoterRate.toStringAsFixed(2)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(totalOverallShare),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByContentTable(ThemeData theme, List<UserTransactionData> txns, double promoterRate) {
    final Map<String, List<UserTransactionData>> contentMap = {};
    for (var t in txns) {
      final title = _sanitizeText(t.movie?.title, fallback: 'Untitled Content');
      contentMap.putIfAbsent(title, () => []).add(t);
    }

    if (contentMap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.movie_filter_outlined, size: 42, color: theme.canvasColor.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text('No content data available', style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    final totalOverallPayment = txns.fold<double>(0.0, (sum, t) => sum + (t.price ?? t.movie?.price ?? 0.0));
    final totalOverallBase = FinancialFormatter.calculateBaseAmount(totalOverallPayment);
    final totalOverallShare = FinancialFormatter.calculatePromoterRevenue(totalOverallPayment, promoterRate);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.08)),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Content Title', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Production House', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Customer Payment', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Base Amount (Ex. GST)', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Promoter Rate', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Promoter Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: [
          ...contentMap.entries.map((entry) {
            final title = entry.key;
            final cTxns = entry.value;
            final rawType = cTxns.first.movie?.type;
            final type = _sanitizeText(rawType, fallback: 'MOVIE');
            final houseName = _sanitizeText(cTxns.first.movie?.mediaHouseName, fallback: 'Production House');
            final totalPayment = cTxns.fold<double>(0.0, (sum, t) => sum + (t.price ?? t.movie?.price ?? 0.0));
            final baseAmount = FinancialFormatter.calculateBaseAmount(totalPayment);
            final promoterShare = FinancialFormatter.calculatePromoterRevenue(totalPayment, promoterRate);

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.movie_outlined, size: 16, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.canvasColor)),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                  ),
                ),
                DataCell(Text(houseName, style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8)))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cTxns.length} txns',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.primaryColor),
                    ),
                  ),
                ),
                DataCell(Text(_formatMoney(totalPayment), style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(_formatMoney(baseAmount))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${promoterRate.toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatMoney(promoterShare),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                    ),
                  ),
                ),
              ],
            );
          }),
          // Summary Footer Row
          DataRow(
            color: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.06)),
            cells: [
              DataCell(
                Text(
                  'Total (${contentMap.length} Items)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ),
              const DataCell(Text('-')),
              const DataCell(Text('-')),
              DataCell(
                Text(
                  '${txns.length} txns',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(totalOverallPayment),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(totalOverallBase),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '${promoterRate.toStringAsFixed(2)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(totalOverallShare),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTransactionsTable({
    required ThemeData theme,
    required List<UserTransactionData> txns,
    required double promoterRate,
    required double platformChargesRate,
    required double taxRate,
  }) {
    if (txns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 42, color: theme.canvasColor.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text('No transaction records found', style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    final query = promoterDrillDownSearch.trim().toLowerCase();
    final filtered = txns.where((t) {
      if (query.isEmpty) return true;
      final idStr = (t.id?.toString() ?? '').toLowerCase();
      final uName = '${t.user?.firstName ?? ""} ${t.user?.lastName ?? ""}'.toLowerCase();
      final phone = (t.user?.mobileNumber ?? '').toLowerCase();
      final title = (t.movie?.title ?? '').toLowerCase();
      final house = (t.movie?.mediaHouseName ?? '').toLowerCase();
      return idStr.contains(query) ||
          uName.contains(query) ||
          phone.contains(query) ||
          title.contains(query) ||
          house.contains(query);
    }).toList();

    final totalFilteredPayment = filtered.fold<double>(0.0, (sum, t) => sum + (t.price ?? t.movie?.price ?? 0.0));
    final totalFilteredGst = FinancialFormatter.calculateGst(totalFilteredPayment);
    final totalFilteredBase = FinancialFormatter.calculateBaseAmount(totalFilteredPayment);
    final totalFilteredPlatformCharges = totalFilteredBase * (platformChargesRate / 100.0);
    final totalFilteredPayoutCharges = 0.0;
    final totalFilteredFinalRevenue = totalFilteredBase - totalFilteredPlatformCharges - totalFilteredPayoutCharges;
    final totalFilteredShare = FinancialFormatter.calculatePromoterRevenue(totalFilteredPayment, promoterRate);
    final totalFilteredTax = totalFilteredShare * (taxRate / 100.0);
    final totalFilteredFinalPromoter = totalFilteredShare - totalFilteredTax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: 320,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by TXN ID, Customer, Content...',
                hintStyle: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, size: 16, color: theme.canvasColor.withValues(alpha: 0.7)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
              ),
              onChanged: (val) {
                setState(() {
                  promoterDrillDownSearch = val;
                });
              },
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.08)),
            dataRowMinHeight: 52,
            dataRowMaxHeight: 56,
            columns: const [
              DataColumn(label: Text('TXN ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Content / Movie', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Customer Payment', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('GST Charges (18%)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Base Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Platform (2%)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Payout Charges', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Final Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Promoter %', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Promoter Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tax (TDS)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Final Promoter Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: [
              ...filtered.map((t) {
                final dateStr = _formatDate(t.dateFrom);
                final displayName = _sanitizeText(
                  '${t.user?.firstName ?? ""} ${t.user?.lastName ?? ""}'.trim().isNotEmpty
                      ? '${t.user?.firstName ?? ""} ${t.user?.lastName ?? ""}'.trim()
                      : (t.user?.mobileNumber ?? t.user?.emailId ?? 'User #${t.user?.id ?? "-"}'),
                  fallback: 'User',
                );
                final contentTitle = _sanitizeText(t.movie?.title, fallback: 'Untitled Content');
                final payment = (t.price ?? t.movie?.price ?? 0.0).toDouble();
                final gst = FinancialFormatter.calculateGst(payment);
                final base = FinancialFormatter.calculateBaseAmount(payment);
                final platformCharge = base * (platformChargesRate / 100.0);
                final payoutCharge = 0.0;
                final finalRev = base - platformCharge - payoutCharge;
                final share = FinancialFormatter.calculatePromoterRevenue(payment, promoterRate);
                final tax = share * (taxRate / 100.0);
                final finalProm = share - tax;

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${t.id ?? "-"}',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                    DataCell(Text(dateStr, style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
                            child: Icon(Icons.person_outline, size: 14, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(displayName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: theme.canvasColor)),
                              if (t.user?.mobileNumber != null && t.user!.mobileNumber!.isNotEmpty)
                                Text(t.user!.mobileNumber!, style: TextStyle(fontSize: 10, color: theme.canvasColor.withValues(alpha: 0.6))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(contentTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.canvasColor)),
                    ),
                    DataCell(Text(_formatMoney(payment), style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('- ${_formatMoney(gst)}', style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.7)))),
                    DataCell(Text(_formatMoney(base), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue))),
                    DataCell(Text('- ${_formatMoney(platformCharge)}', style: const TextStyle(color: Colors.orange))),
                    DataCell(Text(_formatMoney(payoutCharge))),
                    DataCell(Text(_formatMoney(finalRev), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${promoterRate.toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ),
                    DataCell(Text(_formatMoney(share), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    DataCell(Text('- ${_formatMoney(tax)}', style: const TextStyle(color: Colors.redAccent))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatMoney(finalProm),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // Summary Footer Row
              DataRow(
                color: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.06)),
                cells: [
                  DataCell(
                    Text(
                      'Total (${filtered.length} Txns)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                  ),
                  const DataCell(Text('-')),
                  const DataCell(Text('-')),
                  const DataCell(Text('-')),
                  DataCell(
                    Text(
                      _formatMoney(totalFilteredPayment),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '- ${_formatMoney(totalFilteredGst)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatMoney(totalFilteredBase),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  DataCell(
                    Text(
                      '- ${_formatMoney(totalFilteredPlatformCharges)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatMoney(totalFilteredPayoutCharges),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatMoney(totalFilteredFinalRevenue),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${promoterRate.toStringAsFixed(2)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatMoney(totalFilteredShare),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  DataCell(
                    Text(
                      '- ${_formatMoney(totalFilteredTax)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatMoney(totalFilteredFinalPromoter),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: NUMBER OF USERS ADDED (DYNAMIC)
  // ==========================================
  Widget _buildSection4UsersAdded(ThemeData theme, PromoterProvider provider) {
    final usersData = provider.promoterDashboardData?.users;
    final allUsers = provider.usersByPromoterCode;
    final total = usersData?.totalUsers ?? (int.tryParse(provider.refer ?? '') ?? allUsers.length);
    final active = usersData?.activeUsers ?? allUsers.where((u) => u.active != false).length;
    final inactive = usersData?.inactiveUsers ?? (total - active > 0 ? total - active : 0);
    final newUsers = usersData?.newUsers ?? 0;

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
      final userName = _sanitizeText('${u.firstName ?? ""} ${u.lastName ?? ""}', fallback: '');
      final matchesSearch = userSearchQuery.isEmpty ||
          userName.toLowerCase().contains(userSearchQuery.toLowerCase()) ||
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
                  _buildMiniCard('New Users', (newUsers > 0 ? newUsers : addedThisMonth).toString(), Icons.person_add, Colors.teal, theme),
                  _buildMiniCard('Added Today', addedToday.toString(), Icons.today, Colors.blue, theme),
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
                  final userName = _sanitizeText(
                    '${u.firstName ?? ""} ${u.lastName ?? ""}'.trim().isNotEmpty
                        ? '${u.firstName ?? ""} ${u.lastName ?? ""}'.trim()
                        : 'User #${u.id ?? "-"}',
                    fallback: 'User',
                  );
                  return DataRow(
                    cells: [
                      DataCell(Text('#${u.id ?? "N/A"}')),
                      DataCell(Text(userName, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(_sanitizeText(u.mobileNumber, fallback: 'N/A'))),
                      DataCell(Text(_sanitizeText(u.emailId, fallback: 'N/A'))),
                      DataCell(Text(_formatDate(u.joinDate ?? u.registrationDate))),
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
    final promotersData = provider.promoterDashboardData?.promoters;
    final childPromoters = provider.promotersByPromoterCode.isNotEmpty
        ? provider.promotersByPromoterCode
        : provider.getChildPromoters(_currentPromoter);
    final total = promotersData?.totalPromoters ?? (int.tryParse(provider.totalPromoterUnderPromoter ?? '') ?? childPromoters.length);
    final active = promotersData?.activePromoters ?? childPromoters.where((p) => p.isActive).length;
    final inactive = promotersData?.inactivePromoters ?? (total - active > 0 ? total - active : 0);

    final districtCount = childPromoters.where((p) => p.normalizedLevel == 'District').length;
    final talukaCount = childPromoters.where((p) => p.normalizedLevel == 'Taluka').length;

    // Filter child promoters
    final filtered = childPromoters.where((p) {
      final name = _sanitizeText(p.promoterName, fallback: '');
      final matchesSearch = childSearchQuery.isEmpty ||
          name.toLowerCase().contains(childSearchQuery.toLowerCase()) ||
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
                  final cpName = _sanitizeText(cp.promoterName, fallback: 'Unknown');
                  final locText = _sanitizeText(cp.location?.district ?? cp.location?.state ?? cp.location?.city, fallback: 'N/A');
                  final contact = _sanitizeText(cp.contactNumber ?? cp.userId?.mobileNumber, fallback: 'N/A');

                  return DataRow(
                    cells: [
                      DataCell(Text('#${cp.id ?? cp.userId?.id ?? "N/A"}')),
                      DataCell(Text(cpName, style: const TextStyle(fontWeight: FontWeight.bold))),
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
                      DataCell(Text(locText)),
                      DataCell(Text(contact)),
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
    final stats = provider.promoterDashboardData?.dashboard;
    final rawRevenue = provider.revenue ?? '0';
    final earned = stats?.promoterShare?.toDouble() ?? (double.tryParse(rawRevenue.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0);
    final tds = stats?.tdsDeduction?.toDouble() ?? (earned * 0.10);
    final netEarned = stats?.finalSettlementWallet?.toDouble() ?? ((earned - tds) * 0.98);
    final walletBalance = stats?.walletBalance?.toDouble() ?? netEarned;
    final totalWithdrawn = stats?.totalWithdrawn?.toDouble() ?? 0.0;
    final pendingAmount = stats?.pendingAmount?.toDouble() ?? 0.0;
    final isEligible = walletBalance >= 500 && _currentPromoter.isKycCompleted && (_currentPromoter.accountNumber?.isNotEmpty == true);
    final settlements = provider.promoterSettlements;

    // Filter settlements
    final filteredSettlements = settlements.where((s) {
      final matchesSearch = settlementSearchQuery.isEmpty ||
          (s.batchId ?? '').toLowerCase().contains(settlementSearchQuery.toLowerCase()) ||
          (s.paymentReference ?? '').toLowerCase().contains(settlementSearchQuery.toLowerCase());
      final matchesStatus = settlementStatusFilter == 'All' ||
          (s.status ?? '').toLowerCase() == settlementStatusFilter.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    final totalPages = (filteredSettlements.length / settlementPageSize).ceil();
    final pageSettlements = filteredSettlements.skip(settlementCurrentPage * settlementPageSize).take(settlementPageSize).toList();

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
              _buildMiniCard('Wallet Balance', _formatMoney(walletBalance), Icons.account_balance_wallet_outlined, Colors.teal, theme),
              _buildMiniCard('Total Withdrawn', _formatMoney(totalWithdrawn), Icons.outbox_outlined, Colors.purple, theme),
              _buildMiniCard('Pending Settlement', _formatMoney(pendingAmount), Icons.hourglass_top_outlined, Colors.orange, theme),
              _buildMiniCard('Payout Eligibility', isEligible ? 'Eligible' : 'Threshold Pending', isEligible ? Icons.check_circle : Icons.info_outline, isEligible ? Colors.green : Colors.orange, theme),
              _buildMiniCard('KYC Status', _currentPromoter.isKycCompleted ? 'Verified' : 'Pending', Icons.verified_user_outlined, _currentPromoter.isKycCompleted ? Colors.green : Colors.orange, theme),
              _buildMiniCard('Bank Account', _currentPromoter.accountNumber?.isNotEmpty == true ? 'Configured' : 'Missing', Icons.account_balance, Colors.blue, theme),
            ],
          ),
          const SizedBox(height: 20),

          // Live Settlement Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Live Settlement Summary from Active API',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.canvasColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Total Commission Earned (API): ${FinancialFormatter.format4(earned)}\n'
                  '• TDS Deducted (10%): ${FinancialFormatter.format4(tds)}\n'
                  '• Net Settlement Wallet Credit: ${FinancialFormatter.format4(netEarned)}\n'
                  '• Available Wallet Balance: ${FinancialFormatter.format4(walletBalance)}\n'
                  '• Total Withdrawn to Bank: ${FinancialFormatter.format4(totalWithdrawn)}\n'
                  '• Pending Settlement: ${FinancialFormatter.format4(pendingAmount)}\n'
                  '• Bank Payout Status: ${_currentPromoter.accountNumber?.isNotEmpty == true ? "Direct Bank Transfer Configured (${_sanitizeText(_currentPromoter.bankName, fallback: 'Bank')})" : "Bank Account Details Pending"}\n'
                  '• Historical Disbursements: ${settlements.length} recorded settlement batch(es)',
                  style: TextStyle(fontSize: 12, height: 1.5, color: theme.canvasColor.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),

          if (settlements.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Disbursement History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.canvasColor),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  height: 38,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search batch/UTR...',
                      prefixIcon: Icon(Icons.search, size: 16, color: theme.canvasColor.withValues(alpha: 0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    onChanged: (val) {
                      setState(() {
                        settlementSearchQuery = val;
                        settlementCurrentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.scaffoldBackgroundColor),
                columns: const [
                  DataColumn(label: Text('Batch / ID')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Gross Revenue')),
                  DataColumn(label: Text('Commission')),
                  DataColumn(label: Text('TDS (10%)')),
                  DataColumn(label: Text('Charges')),
                  DataColumn(label: Text('Net Disbursed')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('UTR / Ref')),
                ],
                rows: pageSettlements.map((s) {
                  return DataRow(
                    cells: [
                      DataCell(Text(_sanitizeText(s.batchId ?? '#${s.id ?? "-"}'), style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor))),
                      DataCell(Text(_formatDate(s.settlementDate))),
                      DataCell(Text(_formatMoney(s.grossAmount ?? 0.0))),
                      DataCell(Text(_formatMoney(s.promoterShare ?? 0.0))),
                      DataCell(Text('- ${_formatMoney(s.tdsAmount ?? 0.0)}')),
                      DataCell(Text('- ${_formatMoney(s.charges ?? 0.0)}')),
                      DataCell(Text(_formatMoney(s.netAmount ?? 0.0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                      DataCell(_buildStatusBadge(_sanitizeText(s.status, fallback: 'COMPLETED'))),
                      DataCell(Text(_sanitizeText(s.paymentReference, fallback: '-'))),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            _buildPagination(
              currentPage: settlementCurrentPage,
              totalPages: totalPages,
              onPageChanged: (p) => setState(() => settlementCurrentPage = p),
              theme: theme,
            ),
          ],
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
                              Text(_sanitizeText(log.actionType.replaceAll('_', ' ')), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(_sanitizeText(log.description), style: const TextStyle(fontSize: 12)),
                          if (log.previousValue != null && log.newValue != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Changed: ${_sanitizeText(log.previousValue)} → ${_sanitizeText(log.newValue)}',
                                style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text('Performed by: ${_sanitizeText(log.performedBy)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
    final sanitizedVal = _sanitizeText(value, fallback: 'N/A');
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
                    sanitizedVal,
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

  Widget _buildDocumentInfoItem(String label, String? docValue, BuildContext context, ThemeData theme) {
    final hasDoc = docValue != null && docValue.trim().isNotEmpty && docValue.trim() != 'N/A';
    final isUrl = hasDoc &&
        (docValue.startsWith('http://') ||
            docValue.startsWith('https://') ||
            docValue.contains('/uploads/') ||
            docValue.contains('.jpg') ||
            docValue.contains('.jpeg') ||
            docValue.contains('.png') ||
            docValue.contains('.webp') ||
            docValue.contains('.pdf'));

    final displayLabel = hasDoc ? (isUrl ? 'Document Attached' : _sanitizeText(docValue)) : 'Not Provided';

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasDoc ? theme.canvasColor : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasDoc) ...[
                const SizedBox(width: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _showDocumentViewerDialog(context, label, docValue, theme),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined, size: 12, color: theme.primaryColor),
                        const SizedBox(width: 3),
                        Text(
                          'View',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentViewerDialog(
    BuildContext context,
    String documentTitle,
    String docValue,
    ThemeData theme,
  ) {
    final trimmed = docValue.trim();
    final isUrl = trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.contains('/uploads/') ||
        trimmed.contains('.jpg') ||
        trimmed.contains('.jpeg') ||
        trimmed.contains('.png') ||
        trimmed.contains('.webp') ||
        trimmed.contains('.pdf');

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: theme.primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        documentTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.canvasColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: theme.canvasColor,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Flexible(
                  child: Center(
                    child: isUrl
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.network(
                                trimmed,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Unable to load document image.\nURL: $trimmed',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _sanitizeText(docValue),
                              style: TextStyle(fontSize: 14, color: theme.canvasColor),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.green;
    Color fg = Colors.white;

    final sanitized = _sanitizeText(status, fallback: 'Active').toUpperCase();

    if (sanitized == 'INACTIVE' || sanitized == 'REJECTED') {
      bg = Colors.red;
    } else if (sanitized == 'SUSPENDED' || sanitized == 'PENDING') {
      bg = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _sanitizeText(status, fallback: 'Active'),
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
        Text(_sanitizeText(text), style: TextStyle(fontSize: 12, color: theme.canvasColor.withValues(alpha: 0.8))),
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
    return FinancialFormatter.format4(amount);
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

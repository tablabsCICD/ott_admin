import 'package:admin_ott/app/provider/admin_settings_provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/admin%20settings%20page/widgets/admin_rule_form_dialog.dart';
import 'package:admin_ott/app/ui/pages/admin%20settings%20page/widgets/admin_rule_list.dart';
import 'package:admin_ott/app/ui/pages/admin%20settings%20page/widgets/admin_settings_form_widgets.dart';
import 'package:admin_ott/data/models/response/admin_settings_models.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSettingsProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AdminSettingsProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            color: theme.primaryColor,
            onRefresh: provider.loadSettings,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(
                      ResponsiveWidget.isMobile(context) ? 12 : 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme, provider),
                        const SizedBox(height: 16),
                        _buildSearchAndTabs(theme, provider),
                        const SizedBox(height: 16),
                        if (provider.error != null)
                          _buildErrorCard(theme, provider),
                        if (provider.isLoading)
                          const AdminSettingsShimmer()
                        else
                          _buildCurrentTab(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AdminSettingsProvider provider) {
    final compact = ResponsiveWidget.isMobile(context);
    final addRevenueButton = _ActionButton(
      label: 'Set Platform Percentage',
      icon: Icons.percent,
      onPressed: provider.isSaving
          ? null
          : () => _openRuleForm(type: AdminRuleFormType.revenueShare),
    );
    final addFeeButton = _ActionButton(
      label: 'Set Content Registration Charges',
      icon: Icons.currency_rupee,
      onPressed: provider.isSaving
          ? null
          : () => _openRuleForm(type: AdminRuleFormType.registrationFee),
    );

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCopy(theme: theme),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: addRevenueButton),
                    const SizedBox(width: 10),
                    Expanded(child: addFeeButton),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _HeaderCopy(theme: theme)),
                const SizedBox(width: 16),
                addRevenueButton,
                const SizedBox(width: 10),
                addFeeButton,
              ],
            ),
    );
  }

  Widget _buildSearchAndTabs(
    ThemeData theme,
    AdminSettingsProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            style: TextStyle(color: theme.canvasColor),
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search by content type, audience, percentage, remarks',
              hintStyle:
                  TextStyle(color: theme.canvasColor.withValues(alpha: 0.48)),
              prefixIcon: Icon(Icons.search, color: theme.primaryColor),
              suffixIcon: provider.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        provider.setSearchQuery('');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: theme.canvasColor,
            tabs: [
              Tab(text: 'Revenue Share (${provider.revenueRules.length})'),
              Tab(
                  text:
                      'Registration Fee (${provider.registrationFeeRules.length})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(AdminSettingsProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _tabController.index == 0
          ? _SettingsSection(
              key: const ValueKey('revenueRules'),
              child: AdminRuleList(
                items: provider.revenueRules.map(_revenueItem).toList(),
                emptyTitle: 'No revenue share rules found',
                emptyMessage:
                    'Create rules for movies, series, and shorts across India or overseas audiences.',
              ),
            )
          : _SettingsSection(
              key: const ValueKey('feeRules'),
              child: AdminRuleList(
                items: provider.registrationFeeRules
                    .map(_registrationItem)
                    .toList(),
                emptyTitle: 'No registration fee rules found',
                emptyMessage:
                    'Create registration fee rules for every audience and content type.',
              ),
            ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, AdminSettingsProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.error!,
              style: TextStyle(color: theme.canvasColor),
            ),
          ),
          TextButton(
            onPressed: provider.loadSettings,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  AdminRuleListItem _revenueItem(RevenueShareRule rule) {
    return AdminRuleListItem(
      contentType: rule.contentType.apiValue,
      audienceScope: rule.audienceScope.apiValue,
      primaryLabel: 'Admin',
      primaryValue: '${_formatNumber(rule.adminPercentage)}%',
      secondaryLabel: 'Media House',
      secondaryValue: '${_formatNumber(rule.mediaHousePercentage)}%',
      effectiveFrom: rule.effectiveFrom,
      isActive: rule.isActive,
      remarks: rule.remarks,
      onEdit: () => _openRuleForm(
        type: AdminRuleFormType.revenueShare,
        revenueRule: rule,
      ),
    );
  }

  AdminRuleListItem _registrationItem(RegistrationFeeRule rule) {
    return AdminRuleListItem(
      contentType: rule.contentType.apiValue,
      audienceScope: rule.audienceScope.apiValue,
      primaryLabel: 'Fee',
      primaryValue: 'Rs. ${_formatNumber(rule.registrationFee)}',
      effectiveFrom: rule.effectiveFrom,
      isActive: rule.isActive,
      remarks: rule.remarks,
      onEdit: () => _openRuleForm(
        type: AdminRuleFormType.registrationFee,
        registrationFeeRule: rule,
      ),
    );
  }

  Future<void> _openRuleForm({
    required AdminRuleFormType type,
    RevenueShareRule? revenueRule,
    RegistrationFeeRule? registrationFeeRule,
  }) async {
    final form = AdminRuleFormDialog(
      type: type,
      revenueRule: revenueRule,
      registrationFeeRule: registrationFeeRule,
    );

    if (ResponsiveWidget.isMobile(context)) {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: form,
        ),
      );
      return;
    }

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: form,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

class _HeaderCopy extends StatelessWidget {
  const _HeaderCopy({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Settings',
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: ResponsiveWidget.isMobile(context) ? 24 : 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage revenue share and content registration fee rules.',
          style: TextStyle(
            color: theme.canvasColor.withValues(alpha: 0.65),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: EdgeInsets.all(ResponsiveWidget.isMobile(context) ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';

class TicketFilterBar extends StatefulWidget {
  final VoidCallback onRefresh;

  const TicketFilterBar({
    super.key,
    required this.onRefresh,
  });

  @override
  State<TicketFilterBar> createState() => _TicketFilterBarState();
}

class _TicketFilterBarState extends State<TicketFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<TicketProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _roleOptions = [
    {
      'label': 'All Roles',
      'role': null,
      'icon': Icons.groups_outlined,
      'color': null,
    },
    {
      'label': 'Promoter',
      'role': 'PROMOTER',
      'icon': Icons.campaign_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'label': 'User',
      'role': 'USER',
      'icon': Icons.person_outline_rounded,
      'color': Color(0xFF0EA5E9),
    },
    {
      'label': 'Admin',
      'role': 'ADMIN',
      'icon': Icons.admin_panel_settings_outlined,
      'color': Color(0xFFF59E0B),
    },
    {
      'label': 'Media House',
      'role': 'MEDIA_HOUSE',
      'icon': Icons.movie_creation_outlined,
      'color': Color(0xFF10B981),
    },
  ];

  static const List<Map<String, dynamic>> _levelOptions = [
    {
      'label': 'All Levels',
      'level': null,
      'icon': Icons.layers_outlined,
      'color': null,
    },
    {
      'label': 'National',
      'level': 'National',
      'icon': Icons.public_rounded,
      'color': Color(0xFF6366F1),
    },
    {
      'label': 'State',
      'level': 'State',
      'icon': Icons.map_outlined,
      'color': Color(0xFF3B82F6),
    },
    {
      'label': 'District',
      'level': 'District',
      'icon': Icons.location_city_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'label': 'Taluka',
      'level': 'Taluka',
      'icon': Icons.holiday_village_rounded,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final provider = context.watch<TicketProvider>();
    final isDesktop = ResponsiveWidget.isDesktop(context);

    final isPromoterActive = provider.userRoleFilter == 'PROMOTER' ||
        (provider.userRoleFilter == null && provider.isCurrentUserPromoter);

    final hasActiveFilters = provider.searchQuery.isNotEmpty ||
        provider.priorityFilter != null ||
        provider.categoryFilter != null ||
        provider.userRoleFilter != null ||
        provider.promoterLevelFilter != null;

    final searchField = SizedBox(
      width: isDesktop ? 260 : double.infinity,
      height: 36,
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 13, color: theme.canvasColor),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: theme.cardColor,
          hintText: "Search tickets by ID, topic, user...",
          hintStyle: TextStyle(fontSize: 12.5, color: theme.hintColor),
          prefixIcon: Icon(Icons.search, size: 16, color: theme.hintColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
          ),
        ),
        onChanged: (val) {
          setState(() {});
          provider.setSearchQuery(val);
        },
      ),
    );

    final roleChips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.badge_outlined, size: 14, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                "Role:",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          ..._roleOptions.map((opt) {
            final role = opt['role'] as String?;
            final label = opt['label'] as String;
            final icon = opt['icon'] as IconData;
            final accentColor = opt['color'] as Color?;
            final isSelected = provider.userRoleFilter == role;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _filterChip(
                theme: theme,
                label: label,
                icon: icon,
                accentColor: accentColor,
                isSelected: isSelected,
                onSelected: () => provider.setUserRoleFilter(role),
              ),
            );
          }),
        ],
      ),
    );

    final levelChips = isPromoterActive
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium_rounded, size: 13, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 4),
                        Text(
                          "Promoter Level:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._levelOptions.map((opt) {
                    final level = opt['level'] as String?;
                    final label = opt['label'] as String;
                    final icon = opt['icon'] as IconData;
                    final accentColor = opt['color'] as Color? ?? const Color(0xFF8B5CF6);
                    final isSelected = provider.promoterLevelFilter == level;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _filterChip(
                        theme: theme,
                        label: label,
                        icon: icon,
                        accentColor: accentColor,
                        isSelected: isSelected,
                        onSelected: () => provider.setPromoterLevelFilter(level),
                      ),
                    );
                  }),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    final isDateActive = provider.startDate != null || provider.endDate != null;

    final dateFilterWidget = InkWell(
      onTap: () => _selectDateRange(context, provider),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isDateActive
              ? theme.primaryColor.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDateActive
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isDateActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 13,
              color: isDateActive ? theme.primaryColor : theme.hintColor,
            ),
            const SizedBox(width: 4),
            Text(
              isDateActive
                  ? "${provider.startDate?.day}/${provider.startDate?.month} - ${provider.endDate?.day}/${provider.endDate?.month}"
                  : "Date Range",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isDateActive ? FontWeight.w700 : FontWeight.w500,
                color: isDateActive
                    ? theme.primaryColor
                    : theme.canvasColor.withValues(alpha: 0.8),
              ),
            ),
            if (isDateActive) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () => provider.setDateRange(null, null),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final priorityChips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_outlined, size: 14, color: theme.hintColor),
              const SizedBox(width: 4),
              Text(
                "Priority:",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          _filterChip(
            theme: theme,
            label: "All",
            isSelected: provider.priorityFilter == null,
            onSelected: () => provider.setPriorityFilter(null),
          ),
          const SizedBox(width: 6),
          ...TicketPriority.values.map((p) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _filterChip(
                theme: theme,
                label: p.label,
                icon: p.icon,
                accentColor: p.color,
                isSelected: provider.priorityFilter == p,
                onSelected: () => provider.setPriorityFilter(
                  provider.priorityFilter == p ? null : p,
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          dateFilterWidget,
          if (hasActiveFilters || isDateActive)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  provider.clearFilters();
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 15),
                label: const Text("Clear All", style: TextStyle(fontSize: 11.5)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: "Refresh board",
          onPressed: widget.onRefresh,
          icon: Icon(Icons.refresh_rounded, color: theme.canvasColor),
          style: IconButton.styleFrom(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                searchField,
                const SizedBox(width: 16),
                Expanded(child: roleChips),
                const SizedBox(width: 12),
                actionButtons,
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: priorityChips),
                if (isPromoterActive) ...[
                  const SizedBox(width: 16),
                  levelChips,
                ],
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 8),
                actionButtons,
              ],
            ),
            const SizedBox(height: 10),
            roleChips,
            if (isPromoterActive) ...[
              const SizedBox(height: 8),
              levelChips,
            ],
            const SizedBox(height: 8),
            priorityChips,
          ],
        ),
      );
    }
  }

  Future<void> _selectDateRange(BuildContext context, TicketProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
      builder: (context, child) {
        final theme = context.read<ThemeProvider>().getTheme;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              surface: theme.cardColor,
              onSurface: theme.canvasColor,
            ),
            dialogBackgroundColor: theme.cardColor,
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }

  Widget _filterChip({
    required ThemeData theme,
    required String label,
    IconData? icon,
    Color? accentColor,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final color = accentColor ?? theme.primaryColor;
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? color : theme.hintColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? color
                    : theme.canvasColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


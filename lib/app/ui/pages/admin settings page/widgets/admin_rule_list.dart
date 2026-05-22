import 'package:admin_ott/app/ui/pages/admin%20settings%20page/widgets/admin_settings_form_widgets.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';

class AdminRuleListItem {
  const AdminRuleListItem({
    required this.contentType,
    required this.audienceScope,
    required this.primaryLabel,
    required this.primaryValue,
    this.secondaryLabel,
    this.secondaryValue,
    required this.effectiveFrom,
    required this.isActive,
    required this.remarks,
    required this.onEdit,
  });

  final String contentType;
  final String audienceScope;
  final String primaryLabel;
  final String primaryValue;
  final String? secondaryLabel;
  final String? secondaryValue;
  final DateTime? effectiveFrom;
  final bool isActive;
  final String remarks;
  final VoidCallback onEdit;
}

class AdminRuleList extends StatelessWidget {
  const AdminRuleList({
    super.key,
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<AdminRuleListItem> items;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AdminSettingsEmptyState(
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return ResponsiveWidget.isDesktop(context)
        ? _DesktopRuleTable(items: items)
        : _RuleCardList(items: items);
  }
}

class _DesktopRuleTable extends StatelessWidget {
  const _DesktopRuleTable({required this.items});

  final List<AdminRuleListItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.08)),
        columnSpacing: 28,
        columns: const [
          DataColumn(label: Text('Content Type')),
          DataColumn(label: Text('Audience')),
          DataColumn(label: Text('Rule Value')),
          DataColumn(label: Text('Effective From')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Remarks')),
          DataColumn(label: Text('Action')),
        ],
        rows: items.map((item) {
          return DataRow(
            cells: [
              DataCell(_StrongText(item.contentType)),
              DataCell(Text(item.audienceScope)),
              DataCell(
                Text(
                  item.secondaryValue == null
                      ? '${item.primaryLabel}: ${item.primaryValue}'
                      : '${item.primaryLabel}: ${item.primaryValue}  |  '
                          '${item.secondaryLabel}: ${item.secondaryValue}',
                ),
              ),
              DataCell(Text(
                item.effectiveFrom == null
                    ? '-'
                    : formatAdminDate(item.effectiveFrom!),
              )),
              DataCell(AdminStatusChip(isActive: item.isActive)),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    item.remarks.isEmpty ? '-' : item.remarks,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  tooltip: 'Edit rule',
                  icon: Icon(Icons.edit_outlined, color: theme.primaryColor),
                  onPressed: item.onEdit,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _RuleCardList extends StatelessWidget {
  const _RuleCardList({required this.items});

  final List<AdminRuleListItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: items
          .map(
            (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: theme.canvasColor.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.contentType,
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      AdminStatusChip(isActive: item.isActive),
                      IconButton(
                        tooltip: 'Edit rule',
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.primaryColor,
                        ),
                        onPressed: item.onEdit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: 'Audience', value: item.audienceScope),
                      _InfoPill(
                        label: item.primaryLabel,
                        value: item.primaryValue,
                      ),
                      if (item.secondaryLabel != null &&
                          item.secondaryValue != null)
                        _InfoPill(
                          label: item.secondaryLabel!,
                          value: item.secondaryValue!,
                        ),
                      _InfoPill(
                        label: 'Effective',
                        value: item.effectiveFrom == null
                            ? '-'
                            : formatAdminDate(item.effectiveFrom!),
                      ),
                    ],
                  ),
                  if (item.remarks.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.remarks,
                      style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: theme.canvasColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StrongText extends StatelessWidget {
  const _StrongText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

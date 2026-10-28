import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeLevelDialog extends StatefulWidget {
  final Promoters promoter;
  final VoidCallback? onLevelChanged;

  const ChangeLevelDialog({
    super.key,
    required this.promoter,
    this.onLevelChanged,
  });

  @override
  State<ChangeLevelDialog> createState() => _ChangeLevelDialogState();
}

class _ChangeLevelDialogState extends State<ChangeLevelDialog> {
  late String targetLevel;
  Promoters? selectedParent;
  final List<String> levels = ['National', 'State', 'District', 'Taluka'];

  @override
  void initState() {
    super.initState();
    targetLevel = widget.promoter.normalizedLevel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    final currentLevel = widget.promoter.normalizedLevel;
    final existingChildren = provider.getChildPromoters(widget.promoter);

    // Parent candidates matching the target level
    final parentCandidates = provider.promoterList.where((p) {
      if (p.id == widget.promoter.id) return false;
      if (targetLevel == 'State') return p.normalizedLevel == 'National';
      if (targetLevel == 'District') return p.normalizedLevel == 'State';
      if (targetLevel == 'Taluka') return p.normalizedLevel == 'District';
      return false;
    }).toList();

    // Calculate validation error
    final validationError = provider.validateHierarchyChange(
      promoter: widget.promoter,
      newLevel: targetLevel,
      newParentId: selectedParent?.id,
      newParentName: selectedParent?.promoterName,
    );

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(Icons.swap_vert_circle_outlined, color: theme.primaryColor, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Change Promoter Level',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Promoter: ${widget.promoter.promoterName ?? "Unknown"}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'ID: ${widget.promoter.id ?? widget.promoter.userId?.id ?? "N/A"} • ${widget.promoter.location?.state ?? "India"}',
                style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Level Comparison
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Level', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            '$currentLevel Level',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New Target Level', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: targetLevel,
                            onChanged: (String? val) {
                              if (val != null) {
                                setState(() {
                                  targetLevel = val;
                                  selectedParent = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            dropdownColor: theme.cardColor,
                            items: levels.map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl))).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Required Parent Selection
              if (targetLevel != 'National') ...[
                Text(
                  'Assign Reporting Parent (${_getRequiredParentLevel(targetLevel)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<Promoters>(
                  initialValue: selectedParent,
                  onChanged: (Promoters? p) {
                    setState(() {
                      selectedParent = p;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select ${_getRequiredParentLevel(targetLevel)} promoter',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                  dropdownColor: theme.cardColor,
                  items: parentCandidates.map((p) {
                    return DropdownMenuItem<Promoters>(
                      value: p,
                      child: Text('${p.promoterName} (${p.normalizedLevel} - ${p.location?.state ?? "India"})'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Impact & Warning Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: validationError != null
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: validationError != null
                        ? Colors.red.withValues(alpha: 0.4)
                        : Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          validationError != null ? Icons.error_outline : Icons.info_outline,
                          color: validationError != null ? Colors.red : Colors.amber.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          validationError != null ? 'Hierarchy Validation Error' : 'Hierarchy Impact Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: validationError != null ? Colors.red : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (validationError != null)
                      Text(
                        validationError,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      )
                    else ...[
                      Text(
                        '• Child Promoters affected: ${existingChildren.length}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Text(
                        '• Associated users and commission tiers will automatically re-align.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: validationError != null ? Colors.grey : theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: validationError != null
              ? null
              : () async {
                  final confirmed = await _showConfirmation(context, theme, currentLevel, targetLevel);
                  if (confirmed == true && context.mounted) {
                    final success = await provider.changePromoterLevel(
                      promoter: widget.promoter,
                      newLevel: targetLevel,
                      newParentId: selectedParent?.id,
                      newParentName: selectedParent?.promoterName,
                    );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      widget.onLevelChanged?.call();
                    }
                  }
                },
          child: const Text('Confirm & Change Level'),
        ),
      ],
    );
  }

  String _getRequiredParentLevel(String level) {
    switch (level) {
      case 'State':
        return 'National';
      case 'District':
        return 'State';
      case 'Taluka':
        return 'District';
      default:
        return 'Reporting';
    }
  }

  Future<bool?> _showConfirmation(
      BuildContext context, ThemeData theme, String oldLvl, String newLvl) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Confirm Level Transition'),
        content: Text(
          'Are you sure you want to change ${widget.promoter.promoterName ?? "this promoter"}\'s level from $oldLvl to $newLvl?\n\nThis will re-calculate hierarchy and access permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}

void showChangeLevelDialog(BuildContext context, Promoters promoter, {VoidCallback? onLevelChanged}) {
  showDialog(
    context: context,
    builder: (BuildContext context) =>
        ChangeLevelDialog(promoter: promoter, onLevelChanged: onLevelChanged),
  );
}

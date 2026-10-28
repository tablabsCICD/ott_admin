import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssignParentDialog extends StatefulWidget {
  final Promoters promoter;
  final VoidCallback? onAssigned;

  const AssignParentDialog({
    super.key,
    required this.promoter,
    this.onAssigned,
  });

  @override
  State<AssignParentDialog> createState() => _AssignParentDialogState();
}

class _AssignParentDialogState extends State<AssignParentDialog> {
  Promoters? selectedParent;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    final promoterLevel = widget.promoter.normalizedLevel;
    final currentParent = provider.getParentPromoter(widget.promoter);

    // Parent candidates matching the required parent level
    final parentCandidates = provider.promoterList.where((p) {
      if (p.id == widget.promoter.id) return false;
      if (promoterLevel == 'State') return p.normalizedLevel == 'National';
      if (promoterLevel == 'District') return p.normalizedLevel == 'State';
      if (promoterLevel == 'Taluka') return p.normalizedLevel == 'District';
      return false;
    }).toList();

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(Icons.person_add_alt_1_outlined, color: theme.primaryColor, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Assign Parent Promoter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Promoter: ${widget.promoter.promoterName ?? "Unknown"}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                'Level: $promoterLevel • State: ${widget.promoter.location?.state ?? "India"}',
                style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('Current Parent: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      currentParent?.promoterName ?? widget.promoter.refferedBy ?? 'None',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select New Parent (${_getRequiredParentLevel(promoterLevel)})',
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
                  hintText: 'Select ${_getRequiredParentLevel(promoterLevel)} promoter',
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
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: selectedParent == null
              ? null
              : () async {
                  final success = await provider.assignParentPromoter(
                    promoter: widget.promoter,
                    parentId: selectedParent!.id!,
                    parentName: selectedParent!.promoterName ?? '',
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    widget.onAssigned?.call();
                  }
                },
          child: const Text('Save Parent Assignment'),
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
}

void showAssignParentDialog(BuildContext context, Promoters promoter, {VoidCallback? onAssigned}) {
  showDialog(
    context: context,
    builder: (BuildContext context) =>
        AssignParentDialog(promoter: promoter, onAssigned: onAssigned),
  );
}

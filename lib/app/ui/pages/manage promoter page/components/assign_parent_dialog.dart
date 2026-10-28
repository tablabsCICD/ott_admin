import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/response/promoter_hierarchy_response.dart';
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
  Promoters? _selectedParent;
  List<Promoters> _candidates = [];
  PromoterHierarchyInfo? _hierarchyInfo;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadParentCandidates();
  }

  int? get resolvedPromoterId {
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    final dashProm = provider.promoterDashboardData?.promoter;
    return _hierarchyInfo?.promoterId ??
        widget.promoter.id ??
        (widget.promoter.promoterId is int
            ? widget.promoter.promoterId as int
            : int.tryParse(widget.promoter.promoterId?.toString() ?? '')) ??
        dashProm?.promoterId ??
        dashProm?.id ??
        provider.selectedPromoter?.id ??
        widget.promoter.userId?.id;
  }

  Future<void> _loadParentCandidates() async {
    final provider = Provider.of<PromoterProvider>(context, listen: false);

    // Ensure effective promoter has the latest known level
    Promoters effectivePromoter = widget.promoter;
    final dashProm = provider.promoterDashboardData?.promoter;
    final dashLevel = dashProm?.level ?? dashProm?.designation;
    final pId = resolvedPromoterId;
    if (dashLevel != null && dashLevel.trim().isNotEmpty && (effectivePromoter.level == null || effectivePromoter.level!.trim().isEmpty)) {
      effectivePromoter = effectivePromoter.copyWith(level: dashLevel);
    }
    if (pId != null && effectivePromoter.id == null) {
      effectivePromoter = effectivePromoter.copyWith(id: pId);
    }

    final promoterLevel = effectivePromoter.normalizedLevel;
    if (promoterLevel == 'National') {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _candidates = [];
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        provider.getEligibleParentPromoters(effectivePromoter),
        provider.fetchPromoterHierarchy(pId, fallback: effectivePromoter),
      ]);

      final list = results[0] as List<Promoters>;
      final hierarchy = results[1] as PromoterHierarchyInfo?;

      if (!mounted) return;

      // Determine current parent for pre-selection
      Promoters? preselected;
      final currentParentId = hierarchy?.parentPromoterId?.toString() ??
          widget.promoter.promoterId?.toString();
      final currentReferral = (hierarchy?.parentName ?? widget.promoter.refferedBy)?.trim().toLowerCase();

      if (currentParentId != null && currentParentId.isNotEmpty && currentParentId != '0') {
        try {
          preselected = list.firstWhere(
            (p) => p.id?.toString() == currentParentId || p.userId?.id?.toString() == currentParentId,
          );
        } catch (_) {}
      }

      if (preselected == null && currentReferral != null && currentReferral.isNotEmpty && currentReferral != 'none' && currentReferral != 'null') {
        try {
          preselected = list.firstWhere(
            (p) => (p.promoterName ?? '').trim().toLowerCase() == currentReferral,
          );
        } catch (_) {}
      }

      setState(() {
        _candidates = list;
        _hierarchyInfo = hierarchy;
        _selectedParent = preselected;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load parent promoters. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _getParentSectionLabel(String level) {
    switch (level) {
      case 'State':
        return 'Select New Parent (National)';
      case 'District':
        return 'Select New Parent (State / National)';
      case 'Taluka':
        return 'Select New Parent (District / State / National)';
      default:
        return 'Select New Parent';
    }
  }

  String _getParentDropdownPlaceholder(String level) {
    switch (level) {
      case 'State':
        return 'Select National promoter';
      case 'District':
        return 'Select State or National promoter';
      case 'Taluka':
        return 'Select District, State or National promoter';
      default:
        return 'Select parent promoter';
    }
  }

  String _formatCandidateDisplay(Promoters p) {
    final name = p.promoterName?.trim().isNotEmpty == true ? p.promoterName!.trim() : 'Unnamed';
    final level = p.normalizedLevel;
    final state = p.location?.state ?? p.userId?.location?.state ?? '';
    final district = p.location?.district ?? p.userId?.location?.district ?? '';

    final locParts = <String>[];
    if (district.isNotEmpty && level == 'District') locParts.add(district);
    if (state.isNotEmpty) locParts.add(state);

    final locStr = locParts.isNotEmpty ? ' • ${locParts.join(', ')}' : '';
    return '$name — $level$locStr';
  }

  Future<void> _handleSave() async {
    if (_selectedParent == null) {
      CustomToast.show('Please select a parent promoter.');
      return;
    }

    final parentId = _selectedParent!.id ?? _selectedParent!.userId?.id;
    if (parentId == null) {
      CustomToast.show('Invalid parent promoter selected.');
      return;
    }

    final currentId = resolvedPromoterId;
    if (currentId != null && parentId == currentId) {
      CustomToast.show('A promoter cannot be assigned as their own parent.');
      return;
    }

    final currentRank = PromoterProvider.getPromoterLevelRank(_hierarchyInfo?.normalizedLevel ?? widget.promoter.normalizedLevel);
    final parentRank = PromoterProvider.getPromoterLevelRank(_selectedParent!.normalizedLevel);
    if (parentRank >= currentRank) {
      CustomToast.show('The selected parent must have a strictly higher hierarchy level.');
      return;
    }

    final parentReferralCode = _selectedParent!.userId?.refferCode ??
        _selectedParent!.refferedBy ??
        '';

    setState(() => _isSaving = true);
    final provider = Provider.of<PromoterProvider>(context, listen: false);

    final success = await provider.assignParentPromoter(
      promoter: widget.promoter,
      parentPromoterId: parentId,
      parentReferralCode: parentReferralCode,
      parentName: _selectedParent!.promoterName,
      parentLevel: _selectedParent!.normalizedLevel,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        widget.onAssigned?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    final promoterLevel = (_hierarchyInfo?.level != null && _hierarchyInfo!.level!.trim().isNotEmpty && _hierarchyInfo!.normalizedLevel != 'Taluka')
        ? _hierarchyInfo!.normalizedLevel
        : ((widget.promoter.level != null && widget.promoter.level!.trim().isNotEmpty)
            ? widget.promoter.normalizedLevel
            : (provider.promoterDashboardData?.promoter?.normalizedLevel ?? _hierarchyInfo?.normalizedLevel ?? widget.promoter.normalizedLevel));
    final isNational = promoterLevel == 'National';

    final promoterName = _hierarchyInfo?.promoterName ??
        widget.promoter.promoterName ??
        provider.promoterDashboardData?.promoter?.promoterName ??
        'Unknown Promoter';
    final promoterId = resolvedPromoterId;
    final country = _hierarchyInfo?.country ??
        widget.promoter.location?.country ??
        widget.promoter.userId?.location?.country ??
        'India';

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_add_alt_1_outlined, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Assign Parent Promoter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Promoter Profile Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            promoterName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$promoterLevel Level',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: #${promoterId ?? "N/A"} • $country',
                      style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Current Parent Display
              Container(
                padding: const EdgeInsets.all(12),
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
                        Icon(
                          Icons.supervisor_account_outlined,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Current Parent Promoter',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.canvasColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage != null)
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.orange, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadParentCandidates,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    else if (_hierarchyInfo != null && _hierarchyInfo!.hasParent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hierarchyInfo!.parentName ?? 'Parent Promoter',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (_hierarchyInfo!.parentLevel != null && _hierarchyInfo!.parentLevel!.isNotEmpty) ...[
                                      Text(
                                        '${_hierarchyInfo!.normalizedParentLevel} Level',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                                    ],
                                    if (_hierarchyInfo!.parentPromoterId != null)
                                      Text(
                                        'Promoter ID: #${_hierarchyInfo!.parentPromoterId}',
                                        style: TextStyle(
                                          color: theme.canvasColor.withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'Assigned',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 18,
                            color: theme.canvasColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No Parent Assigned',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.canvasColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // National Level Notice OR Parent Selection Dropdown
              if (isNational)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber, size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'National-level promoter cannot have a parent promoter.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  _getParentSectionLabel(promoterLevel),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),

                if (_isLoading)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading available parent promoters…',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.canvasColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadParentCandidates,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_candidates.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_off_outlined, color: theme.canvasColor.withValues(alpha: 0.5), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'No eligible parent promoters available.',
                          style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.6), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<Promoters>(
                    initialValue: _selectedParent,
                    isExpanded: true,
                    onChanged: (Promoters? p) {
                      setState(() {
                        _selectedParent = p;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: _getParentDropdownPlaceholder(promoterLevel),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: theme.canvasColor.withValues(alpha: 0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    dropdownColor: theme.cardColor,
                    items: _candidates.map((p) {
                      return DropdownMenuItem<Promoters>(
                        value: p,
                        child: Text(
                          _formatCandidateDisplay(p),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!isNational)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: (_selectedParent == null || _isLoading || _isSaving)
                ? null
                : _handleSave,
            child: _isSaving
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Assigning parent...'),
                    ],
                  )
                : const Text('Save Parent Assignment'),
          ),
      ],
    );
  }
}

void showAssignParentDialog(BuildContext context, Promoters promoter, {VoidCallback? onAssigned}) {
  showDialog(
    context: context,
    builder: (BuildContext context) =>
        AssignParentDialog(promoter: promoter, onAssigned: onAssigned),
  );
}

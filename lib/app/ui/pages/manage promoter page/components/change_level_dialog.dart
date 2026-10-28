import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/response/promoter_hierarchy_response.dart';
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
  final List<String> levels = ['National', 'State', 'District', 'Taluka'];

  late final TextEditingController stateController;
  late final TextEditingController districtController;
  late final TextEditingController talukaController;
  late final TextEditingController cityController;
  late final TextEditingController pincodeController;

  bool _isLoadingHierarchy = true;
  String? _hierarchyError;
  PromoterHierarchyInfo? _hierarchyInfo;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    targetLevel = widget.promoter.normalizedLevel;

    final loc = widget.promoter.location ?? widget.promoter.userId?.location;
    stateController = TextEditingController(text: loc?.state ?? '');
    districtController = TextEditingController(text: loc?.district ?? '');
    talukaController = TextEditingController(text: loc?.taluka ?? '');
    cityController = TextEditingController(text: loc?.city ?? '');
    pincodeController = TextEditingController(text: widget.promoter.pincode ?? loc?.pincode ?? '');

    _loadHierarchy();
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

  Future<void> _loadHierarchy() async {
    setState(() {
      _isLoadingHierarchy = true;
      _hierarchyError = null;
    });

    try {
      final provider = Provider.of<PromoterProvider>(context, listen: false);
      final pId = resolvedPromoterId;
      final info = await provider.fetchPromoterHierarchy(pId, fallback: widget.promoter);

      if (!mounted) return;

      if (info != null) {
        setState(() {
          _hierarchyInfo = info;
          final resolvedCurrentLevel = (info.level != null && info.level!.trim().isNotEmpty && info.normalizedLevel != 'Taluka')
              ? info.normalizedLevel
              : ((widget.promoter.level != null && widget.promoter.level!.trim().isNotEmpty)
                  ? widget.promoter.normalizedLevel
                  : info.normalizedLevel);
          targetLevel = resolvedCurrentLevel;

          if (info.state != null && info.state!.isNotEmpty) {
            stateController.text = info.state!;
          }
          if (info.district != null && info.district!.isNotEmpty) {
            districtController.text = info.district!;
          }
          if (info.taluka != null && info.taluka!.isNotEmpty) {
            talukaController.text = info.taluka!;
          }
          _isLoadingHierarchy = false;
        });
      } else {
        setState(() {
          _hierarchyError = 'Unable to load parent information.';
          _isLoadingHierarchy = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hierarchyError = 'Unable to load parent information.';
        _isLoadingHierarchy = false;
      });
    }
  }

  @override
  void dispose() {
    stateController.dispose();
    districtController.dispose();
    talukaController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final currentLevel = (_hierarchyInfo?.level != null && _hierarchyInfo!.level!.trim().isNotEmpty && _hierarchyInfo!.normalizedLevel != 'Taluka')
        ? _hierarchyInfo!.normalizedLevel
        : ((widget.promoter.level != null && widget.promoter.level!.trim().isNotEmpty)
            ? widget.promoter.normalizedLevel
            : (_hierarchyInfo?.normalizedLevel ?? widget.promoter.normalizedLevel));
    if (targetLevel.trim().toLowerCase() == currentLevel.trim().toLowerCase()) {
      CustomToast.show('Please select a new level different from current level.');
      return;
    }

    final promoterId = resolvedPromoterId;
    if (promoterId == null) {
      CustomToast.show('Promoter ID is missing.');
      return;
    }

    // Validate location inputs according to the selected target level
    if (targetLevel == 'State') {
      if (stateController.text.trim().isEmpty) {
        CustomToast.show('Please enter or select a state.');
        return;
      }
    } else if (targetLevel == 'District') {
      if (stateController.text.trim().isEmpty) {
        CustomToast.show('Please enter or select a state.');
        return;
      }
      if (districtController.text.trim().isEmpty) {
        CustomToast.show('Please enter or select a district.');
        return;
      }
    } else if (targetLevel == 'Taluka') {
      if (stateController.text.trim().isEmpty) {
        CustomToast.show('Please enter or select a state.');
        return;
      }
      if (districtController.text.trim().isEmpty) {
        CustomToast.show('Please enter or select a district.');
        return;
      }
      if (talukaController.text.trim().isEmpty) {
        CustomToast.show('Please enter or select a taluka.');
        return;
      }
    }

    // Build minimum location payload
    final locId = _hierarchyInfo?.location?.id ?? widget.promoter.location?.id ?? widget.promoter.userId?.location?.id;
    final locationMap = <String, dynamic>{
      if (locId != null) "id": locId,
      "country": "India",
    };

    if (targetLevel == 'State' || targetLevel == 'District' || targetLevel == 'Taluka') {
      locationMap["state"] = stateController.text.trim();
    }
    if (targetLevel == 'District' || targetLevel == 'Taluka') {
      locationMap["district"] = districtController.text.trim();
    }
    if (targetLevel == 'Taluka') {
      locationMap["taluka"] = talukaController.text.trim();
      if (cityController.text.trim().isNotEmpty) {
        locationMap["city"] = cityController.text.trim();
      }
      if (pincodeController.text.trim().isNotEmpty) {
        locationMap["pincode"] = pincodeController.text.trim();
      }
    }

    setState(() => _isUpdating = true);

    final provider = Provider.of<PromoterProvider>(context, listen: false);
    final success = await provider.changePromoterLevel(
      promoter: widget.promoter,
      newLevel: targetLevel,
      locationData: locationMap,
    );

    if (mounted) {
      setState(() => _isUpdating = false);
      if (success) {
        Navigator.pop(context);
        widget.onLevelChanged?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    final currentLevel = (_hierarchyInfo?.level != null && _hierarchyInfo!.level!.trim().isNotEmpty && _hierarchyInfo!.normalizedLevel != 'Taluka')
        ? _hierarchyInfo!.normalizedLevel
        : ((widget.promoter.level != null && widget.promoter.level!.trim().isNotEmpty)
            ? widget.promoter.normalizedLevel
            : (provider.promoterDashboardData?.promoter?.normalizedLevel ?? _hierarchyInfo?.normalizedLevel ?? widget.promoter.normalizedLevel));
    final isSameLevel = targetLevel.trim().toLowerCase() == currentLevel.trim().toLowerCase();
    final existingChildren = provider.getChildPromoters(widget.promoter);

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
            child: Icon(Icons.swap_vert_circle_outlined, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Change Promoter Level',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 550,
        child: _isLoadingHierarchy
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading promoter hierarchy...',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.canvasColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Current Promoter Summary Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promoterName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: #${promoterId ?? "N/A"} • $country',
                                  style: TextStyle(
                                    color: theme.canvasColor.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Current: $currentLevel Level',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Current Parent Promoter Section
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
                          if (_hierarchyError != null)
                            Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.orange, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _hierarchyError!,
                                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadHierarchy,
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
                                      if (_hierarchyInfo!.parentReferralCode != null &&
                                          _hierarchyInfo!.parentReferralCode!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Referral Code: ${_hierarchyInfo!.parentReferralCode}',
                                          style: TextStyle(
                                            color: theme.canvasColor.withValues(alpha: 0.5),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
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

                    // 3. Level Transition Section
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
                                  key: ValueKey(targetLevel),
                                  initialValue: levels.contains(targetLevel) ? targetLevel : 'Taluka',
                                  isDense: true,
                                  onChanged: (String? val) {
                                    if (val != null) {
                                      setState(() {
                                        targetLevel = val;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    filled: true,
                                    fillColor: theme.cardColor,
                                  ),
                                  dropdownColor: theme.cardColor,
                                  items: levels.map((lvl) {
                                    return DropdownMenuItem(
                                      value: lvl,
                                      child: Text(lvl, style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Dynamic Location Fields for New Level
                    Text(
                      'Location Details ($targetLevel Level)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    if (targetLevel == 'National')
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.public, color: Colors.blueAccent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Country: India (National Jurisdiction)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.canvasColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // State Field (Required for State, District, Taluka)
                      _buildTextField(
                        controller: stateController,
                        label: 'State *',
                        hint: 'Enter state name (e.g. Maharashtra)',
                        theme: theme,
                      ),
                      const SizedBox(height: 10),

                      // District Field (Required for District, Taluka)
                      if (targetLevel == 'District' || targetLevel == 'Taluka') ...[
                        _buildTextField(
                          controller: districtController,
                          label: 'District *',
                          hint: 'Enter district name (e.g. Pune)',
                          theme: theme,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Taluka & Optional Fields (Required for Taluka)
                      if (targetLevel == 'Taluka') ...[
                        _buildTextField(
                          controller: talukaController,
                          label: 'Taluka *',
                          hint: 'Enter taluka name (e.g. Haveli)',
                          theme: theme,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: cityController,
                                label: 'City (Optional)',
                                hint: 'e.g. Pune',
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller: pincodeController,
                                label: 'Pincode (Optional)',
                                hint: 'e.g. 411001',
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),

                    // 5. Impact Analysis Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSameLevel
                            ? Colors.grey.withValues(alpha: 0.1)
                            : Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSameLevel
                              ? Colors.grey.withValues(alpha: 0.3)
                              : Colors.amber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSameLevel ? Icons.info_outline : Icons.warning_amber_rounded,
                                color: isSameLevel ? Colors.grey : Colors.amber.shade800,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isSameLevel ? 'No Level Change' : 'Level Transition Impact',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSameLevel ? Colors.grey : Colors.amber.shade900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (isSameLevel)
                            const Text(
                              'Select a different target level from the dropdown to proceed.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          else ...[
                            Text(
                              '• Child Promoters currently reporting: ${existingChildren.length}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Text(
                              '• Level changes may require re-assigning parent promoter according to hierarchy rules.',
                              style: TextStyle(fontSize: 12),
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
          onPressed: _isUpdating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: (isSameLevel || _isLoadingHierarchy) ? Colors.grey : theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: (isSameLevel || _isUpdating || _isLoadingHierarchy) ? null : _handleSubmit,
          child: _isUpdating
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Text('Updating level...'),
                  ],
                )
              : const Text('Save Level Change'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.canvasColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: theme.canvasColor.withValues(alpha: 0.4)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
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
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
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

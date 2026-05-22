import 'package:admin_ott/app/provider/admin_settings_provider.dart';
import 'package:admin_ott/app/ui/pages/admin%20settings%20page/widgets/admin_settings_form_widgets.dart';
import 'package:admin_ott/data/models/response/admin_settings_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AdminRuleFormType { revenueShare, registrationFee }

class AdminRuleFormDialog extends StatefulWidget {
  const AdminRuleFormDialog({
    super.key,
    required this.type,
    this.revenueRule,
    this.registrationFeeRule,
  });

  final AdminRuleFormType type;
  final RevenueShareRule? revenueRule;
  final RegistrationFeeRule? registrationFeeRule;

  @override
  State<AdminRuleFormDialog> createState() => _AdminRuleFormDialogState();
}

class _AdminRuleFormDialogState extends State<AdminRuleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _adminPercentageCtrl = TextEditingController();
  final _mediaHousePercentageCtrl = TextEditingController();
  final _registrationFeeCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  RevenueAudienceScope _audienceScope = RevenueAudienceScope.india;
  RevenueContentType _contentType = RevenueContentType.movies;
  DateTime? _effectiveFrom;
  bool _isActive = true;

  bool get _isRevenue => widget.type == AdminRuleFormType.revenueShare;
  bool get _isEdit =>
      widget.revenueRule != null || widget.registrationFeeRule != null;

  @override
  void initState() {
    super.initState();
    final revenueRule = widget.revenueRule;
    final feeRule = widget.registrationFeeRule;

    if (revenueRule != null) {
      _audienceScope = revenueRule.audienceScope;
      _contentType = revenueRule.contentType;
      _effectiveFrom = revenueRule.effectiveFrom;
      _isActive = revenueRule.isActive;
      _adminPercentageCtrl.text = _formatNumber(revenueRule.adminPercentage);
      _mediaHousePercentageCtrl.text =
          _formatNumber(revenueRule.mediaHousePercentage);
      _remarksCtrl.text = revenueRule.remarks;
    } else if (feeRule != null) {
      _audienceScope = feeRule.audienceScope;
      _contentType = feeRule.contentType;
      _effectiveFrom = feeRule.effectiveFrom;
      _isActive = feeRule.isActive;
      _registrationFeeCtrl.text = _formatNumber(feeRule.registrationFee);
      _remarksCtrl.text = feeRule.remarks;
    }
  }

  @override
  void dispose() {
    _adminPercentageCtrl.dispose();
    _mediaHousePercentageCtrl.dispose();
    _registrationFeeCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AdminSettingsProvider>();
    final title = _isRevenue
        ? '${_isEdit ? 'Edit' : 'Add'} Platform Percentage'
        : '${_isEdit ? 'Edit' : 'Add'} Content Registration Fee';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 620,
        constraints: const BoxConstraints(maxHeight: 760),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        provider.isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildRuleBasics(),
                      const SizedBox(height: 14),
                      if (_isRevenue) _buildRevenueFields(),
                      if (!_isRevenue) _buildRegistrationFeeField(),
                      const SizedBox(height: 14),
                      AdminSettingsDateField(
                        label: 'Effective From Date',
                        value: _effectiveFrom,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 14),
                      AdminSettingsTextField(
                        controller: _remarksCtrl,
                        label: 'Remarks',
                        maxLines: 3,
                        prefixIcon: Icons.notes_outlined,
                        validator: _requiredValidator('Remarks'),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: theme.primaryColor,
                        value: _isActive,
                        title: Text(
                          'Active Rule',
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (value) => setState(() {
                          _isActive = value;
                        }),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: provider.isSaving ? null : _submit,
                          icon: provider.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(_isEdit ? Icons.save : Icons.add),
                          label: Text(_isEdit ? 'Update Rule' : 'Save Rule'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleBasics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final fields = [
          AdminSettingsDropdown<RevenueAudienceScope>(
            label: 'Audience Scope',
            value: _audienceScope,
            items: RevenueAudienceScope.values,
            itemLabel: (item) => item.apiValue,
            onChanged: (value) => setState(() {
              if (value != null) _audienceScope = value;
            }),
          ),
          AdminSettingsDropdown<RevenueContentType>(
            label: 'Content Type',
            value: _contentType,
            items: RevenueContentType.values,
            itemLabel: (item) => item.apiValue,
            onChanged: (value) => setState(() {
              if (value != null) _contentType = value;
            }),
          ),
        ];

        if (compact) {
          return Column(
            children: [
              fields[0],
              const SizedBox(height: 14),
              fields[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 14),
            Expanded(child: fields[1]),
          ],
        );
      },
    );
  }

  Widget _buildRevenueFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final fields = [
          AdminSettingsTextField(
            controller: _adminPercentageCtrl,
            label: 'Admin Percentage',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.percent,
            validator: _percentageValidator('Admin percentage'),
          ),
          AdminSettingsTextField(
            controller: _mediaHousePercentageCtrl,
            label: 'Media House Percentage',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.percent,
            validator: _percentageValidator('Media house percentage'),
          ),
        ];

        if (compact) {
          return Column(
            children: [
              fields[0],
              const SizedBox(height: 14),
              fields[1],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 14),
            Expanded(child: fields[1]),
          ],
        );
      },
    );
  }

  Widget _buildRegistrationFeeField() {
    return AdminSettingsTextField(
      controller: _registrationFeeCtrl,
      label: 'Registration Fee',
      keyboardType: TextInputType.number,
      prefixIcon: Icons.currency_rupee,
      validator: (value) {
        final required = _requiredValidator('Registration fee')(value);
        if (required != null) return required;
        final amount = double.tryParse(value!.trim());
        if (amount == null || amount < 0) return 'Enter a valid amount';
        return null;
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _effectiveFrom ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      setState(() {
        _effectiveFrom = DateTime(
          selected.year,
          selected.month,
          selected.day,
          now.hour,
          now.minute,
          now.second,
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Effective from date is required')),
      );
      return;
    }

    if (_isRevenue && !_percentagesEqualHundred()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin % + Media House % must equal 100'),
        ),
      );
      return;
    }

    if (_isEdit) {
      final confirmed = await _confirmUpdate();
      if (!mounted) return;
      if (!confirmed) return;
    }

    final provider = context.read<AdminSettingsProvider>();
    final success = _isRevenue
        ? await _saveRevenue(provider)
        : await _saveRegistrationFee(provider);

    if (!mounted || !success) return;
    Navigator.pop(context, true);
  }

  Future<bool> _saveRevenue(AdminSettingsProvider provider) {
    final rule = RevenueShareRule(
      id: widget.revenueRule?.id,
      adminPercentage: double.parse(_adminPercentageCtrl.text.trim()),
      audienceScope: _audienceScope,
      contentType: _contentType,
      effectiveFrom: _effectiveFrom,
      isActive: _isActive,
      mediaHousePercentage: double.parse(_mediaHousePercentageCtrl.text.trim()),
      remarks: _remarksCtrl.text.trim(),
    );
    return _isEdit
        ? provider.updateRevenueRule(rule)
        : provider.saveRevenueRule(rule);
  }

  Future<bool> _saveRegistrationFee(AdminSettingsProvider provider) {
    final rule = RegistrationFeeRule(
      id: widget.registrationFeeRule?.id,
      audienceScope: _audienceScope,
      contentType: _contentType,
      effectiveFrom: _effectiveFrom,
      isActive: _isActive,
      registrationFee: double.parse(_registrationFeeCtrl.text.trim()),
      remarks: _remarksCtrl.text.trim(),
    );
    return _isEdit
        ? provider.updateRegistrationFeeRule(rule)
        : provider.saveRegistrationFeeRule(rule);
  }

  Future<bool> _confirmUpdate() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update rule?'),
            content: const Text('This will update the selected rule.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Update'),
              ),
            ],
          ),
        ) ??
        false;
  }

  bool _percentagesEqualHundred() {
    final admin = double.tryParse(_adminPercentageCtrl.text.trim()) ?? 0;
    final media = double.tryParse(_mediaHousePercentageCtrl.text.trim()) ?? 0;
    return (admin + media - 100).abs() < 0.001;
  }

  String? Function(String?) _requiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      return null;
    };
  }

  String? Function(String?) _percentageValidator(String label) {
    return (value) {
      final required = _requiredValidator(label)(value);
      if (required != null) return required;
      final number = double.tryParse(value!.trim());
      if (number == null || number < 0 || number > 100) {
        return 'Enter a value from 0 to 100';
      }
      return null;
    };
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

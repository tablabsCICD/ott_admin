import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/settelementProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/request/manual_settlement_request.dart';
import 'package:admin_ott/data/models/response/manual_settlement_response.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'manual_settlement_summary_dialog.dart';

class ManualSettlementDialog extends StatefulWidget {
  const ManualSettlementDialog({super.key});

  @override
  State<ManualSettlementDialog> createState() => _ManualSettlementDialogState();
}

class _ManualSettlementDialogState extends State<ManualSettlementDialog> {
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedMediaHouseId;
  String? _selectedMediaHouseName;

  bool _includeContentSettlement = true;
  bool _includeUserOnboardingSettlement = false;
  bool _includeSettlementHistory = true;

  bool _isProcessing = false;
  String? _startDateError;
  String? _endDateError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mhProvider =
          Provider.of<MediaHouseProvider>(context, listen: false);
      if (mhProvider.mediaHouseList.isEmpty) {
        mhProvider.fetchMediaHouse();
      }
    });
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    if (_isProcessing) return;

    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              surface: theme.cardColor,
              onSurface: theme.canvasColor,
            ),
            dialogTheme: DialogThemeData(backgroundColor: theme.cardColor),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStartDate) {
        _startDate = picked;
        _startDateError = null;
      } else {
        _endDate = picked;
        _endDateError = null;
      }
      _generalError = null;
      _validateDates();
    });
  }

  bool _validateDates() {
    bool isValid = true;

    if (_startDate == null) {
      _startDateError = 'Start Date is required.';
      isValid = false;
    } else {
      _startDateError = null;
    }

    if (_endDate == null) {
      _endDateError = 'End Date is required.';
      isValid = false;
    } else {
      _endDateError = null;
    }

    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      _endDateError = 'Start Date must not be after End Date.';
      isValid = false;
    }

    return isValid;
  }

  void _onProcessPressed() {
    if (_isProcessing) return;

    setState(() {
      _generalError = null;
    });

    if (!_validateDates()) {
      setState(() {});
      return;
    }

    _showConfirmationDialog();
  }

  Future<void> _showConfirmationDialog() async {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    final startStr =
        _startDate != null ? _displayDateFormat.format(_startDate!) : '';
    final endStr = _endDate != null ? _displayDateFormat.format(_endDate!) : '';
    final targetMediaHouseStr = _selectedMediaHouseId == null
        ? 'all media houses'
        : (_selectedMediaHouseName ?? 'selected media house');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isProcessing,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: theme.cardColor,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 10),
              Text(
                'Process Manual Settlement?',
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will process settlement data from $startStr to $endStr for $targetMediaHouseStr.',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please verify the date range and selected settlement options before continuing.',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: theme.canvasColor.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm and Process'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _executeSettlement();
    }
  }

  Future<void> _executeSettlement() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _generalError = null;
    });

    final request = ManualSettlementRequest(
      startDate: _apiDateFormat.format(_startDate!),
      endDate: _apiDateFormat.format(_endDate!),
      mediaHouseId: _selectedMediaHouseId,
      includeContentSettlement: _includeContentSettlement,
      includeUserOnboardingSettlement: _includeUserOnboardingSettlement,
      includeSettlementHistory: _includeSettlementHistory,
    );

    try {
      final settlementProvider =
          Provider.of<SettelementProvider>(context, listen: false);
      final response =
          await settlementProvider.processManualSettlement(request);

      if (!mounted) return;

      Navigator.of(context).pop();

      CustomToast.show(
        response.message ?? 'Settlement processed successfully',
        isSuccess: true,
      );

      _showSummaryModal(context, response);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _generalError = error.toString().replaceAll('Exception: ', '');
      });
    }
  }

  static void _showSummaryModal(
    BuildContext context,
    ManualSettlementResponse response,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ManualSettlementSummaryDialog(response: response),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final mhProvider = context.watch<MediaHouseProvider>();
    final mediaHouseList = mhProvider.mediaHouseList;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              if (_generalError != null) ...[
                _buildErrorBanner(theme, _generalError!),
                const SizedBox(height: 16),
              ],
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateSelectors(theme),
                      const SizedBox(height: 16),
                      _buildMediaHouseDropdown(theme, mediaHouseList),
                      const SizedBox(height: 20),
                      _buildToggleOptions(theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.touch_app_outlined, color: theme.primaryColor, size: 26),
            const SizedBox(width: 10),
            Text(
              'Manual Settlement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.canvasColor,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: theme.canvasColor,
          ),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildErrorBanner(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectors(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 440;

        final startDateTile = _dateInputTile(
          theme: theme,
          label: 'Start Date',
          dateValue: _startDate,
          errorText: _startDateError,
          isStartDate: true,
        );

        final endDateTile = _dateInputTile(
          theme: theme,
          label: 'End Date',
          dateValue: _endDate,
          errorText: _endDateError,
          isStartDate: false,
        );

        if (isNarrow) {
          return Column(
            children: [
              startDateTile,
              const SizedBox(height: 14),
              endDateTile,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: startDateTile),
            const SizedBox(width: 14),
            Expanded(child: endDateTile),
          ],
        );
      },
    );
  }

  Widget _dateInputTile({
    required ThemeData theme,
    required String label,
    required DateTime? dateValue,
    required String? errorText,
    required bool isStartDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isProcessing
              ? null
              : () => _selectDate(isStartDate: isStartDate),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: errorText,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            child: Text(
              dateValue != null
                  ? _displayDateFormat.format(dateValue)
                  : 'Select Date',
              style: TextStyle(
                color: dateValue != null ? theme.canvasColor : theme.hintColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaHouseDropdown(
      ThemeData theme, List<MediaHouse> mediaHouses) {
    return DropdownButtonFormField<int?>(
      initialValue: _selectedMediaHouseId,
      dropdownColor: theme.cardColor,
      style: TextStyle(color: theme.canvasColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Media House',
        labelStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.7)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: theme.canvasColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(
            'All Media Houses',
            style: TextStyle(color: theme.canvasColor),
          ),
        ),
        ...mediaHouses.map((mh) {
          final mhId = mh.id;
          final mhName = mh.mediaHouseName ?? 'Media House #${mhId ?? ''}';
          return DropdownMenuItem<int?>(
            value: mhId,
            child: Text(
              mhName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.canvasColor),
            ),
          );
        }),
      ],
      onChanged: _isProcessing
          ? null
          : (val) {
              setState(() {
                _selectedMediaHouseId = val;
                if (val == null) {
                  _selectedMediaHouseName = null;
                } else {
                  final mhMatches = mediaHouses.where((e) => e.id == val);
                  if (mhMatches.isNotEmpty) {
                    _selectedMediaHouseName = mhMatches.first.mediaHouseName;
                  } else {
                    _selectedMediaHouseName = 'Media House #$val';
                  }
                }
              });
            },
    );
  }

  Widget _buildToggleOptions(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settlement Options',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.canvasColor.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            value: _includeContentSettlement,
            dense: true,
            activeColor: theme.primaryColor,
            checkColor: Colors.white,
            title: Text(
              'Include Content Settlement',
              style: TextStyle(color: theme.canvasColor, fontSize: 13),
            ),
            subtitle: Text(
              'Process revenue calculations for watched & purchased content',
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
            onChanged: _isProcessing
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _includeContentSettlement = val);
                    }
                  },
          ),
          Divider(height: 1, color: theme.canvasColor.withValues(alpha: 0.08)),
          CheckboxListTile(
            value: _includeUserOnboardingSettlement,
            dense: true,
            activeColor: theme.primaryColor,
            checkColor: Colors.white,
            title: Text(
              'Include User Onboarding Settlement',
              style: TextStyle(color: theme.canvasColor, fontSize: 13),
            ),
            subtitle: Text(
              'Process promoter onboarding commissions if applicable',
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
            onChanged: _isProcessing
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _includeUserOnboardingSettlement = val);
                    }
                  },
          ),
          Divider(height: 1, color: theme.canvasColor.withValues(alpha: 0.08)),
          CheckboxListTile(
            value: _includeSettlementHistory,
            dense: true,
            activeColor: theme.primaryColor,
            checkColor: Colors.white,
            title: Text(
              'Include Settlement History',
              style: TextStyle(color: theme.canvasColor, fontSize: 13),
            ),
            subtitle: Text(
              'Record audit history for this manual execution',
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
            onChanged: _isProcessing
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _includeSettlementHistory = val);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: BorderSide(color: theme.canvasColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.canvasColor),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _onProcessPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.flash_on_outlined, size: 18),
          label: Text(_isProcessing ? 'Processing...' : 'Process Settlement'),
        ),
      ],
    );
  }
}

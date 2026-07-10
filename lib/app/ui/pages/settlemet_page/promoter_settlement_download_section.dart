import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/data/services/promoter_settlement_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PromoterSettlementDownloadSection extends StatefulWidget {
  const PromoterSettlementDownloadSection({super.key});

  @override
  State<PromoterSettlementDownloadSection> createState() =>
      _PromoterSettlementDownloadSectionState();
}

class _PromoterSettlementDownloadSectionState
    extends State<PromoterSettlementDownloadSection> {
  final _service = const PromoterSettlementService();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _dateError;
  bool _isDownloading = false;

  bool get _hasInvalidRange =>
      _fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!);

  Future<void> _pickDate({required bool isFromDate}) async {
    if (_isDownloading) return;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null || !mounted) return;

    setState(() {
      if (isFromDate) {
        _fromDate = selectedDate;
      } else {
        _toDate = selectedDate;
      }
      _dateError =
          _hasInvalidRange ? 'fromDate cannot be greater than toDate' : null;
    });
  }

  Future<void> _download() async {
    if (_isDownloading) return;
    if (_hasInvalidRange) {
      setState(() => _dateError = 'fromDate cannot be greater than toDate');
      _showMessage(_dateError!, isError: true);
      return;
    }

    setState(() {
      _dateError = null;
      _isDownloading = true;
    });
    try {
      await _service.downloadSettlementExcel(
        fromDate: _fromDate,
        toDate: _toDate,
      );
      if (!mounted) return;
      _showMessage('Settlement Excel downloaded successfully.');
    } on PromoterSettlementException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        _showMessage('Failed to download settlement Excel.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _reset() {
    if (_isDownloading) return;
    setState(() {
      _fromDate = null;
      _toDate = null;
      _dateError = null;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Colors.red.shade700 : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return _buildFilterCard(theme);
  }

  Widget _buildFilterCard(ThemeData theme) {
    return Card(
      elevation: 2,
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitle(theme),
                const SizedBox(height: 6),
                Text(
                  'Select a settlement period and download the Excel report.',
                  style: TextStyle(color: theme.canvasColor.withOpacity(.7)),
                ),
                const SizedBox(height: 16),
                _buildDateFields(theme, isNarrow),
                if (_dateError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _dateError!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
                _buildActions(theme, isNarrow),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.download_outlined, color: theme.primaryColor),
        Text(
          'Download Settlement Excel',
          softWrap: true,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFields(ThemeData theme, bool isNarrow) {
    final fromField = _dateField(
      theme,
      label: 'From Date',
      value: _fromDate,
      isFromDate: true,
    );
    final toField = _dateField(
      theme,
      label: 'To Date',
      value: _toDate,
      isFromDate: false,
    );

    if (isNarrow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fromField,
          const SizedBox(height: 12),
          toField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: fromField),
        const SizedBox(width: 12),
        Expanded(child: toField),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, bool isNarrow) {
    final downloadButton = ElevatedButton.icon(
      onPressed: _isDownloading ? null : _download,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: _isDownloading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.download_outlined),
      label: Text(_isDownloading ? 'Downloading...' : 'Download Excel'),
    );

    final resetButton = OutlinedButton.icon(
      onPressed: _isDownloading ? null : _reset,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: const Icon(Icons.refresh),
      label: const Text('Reset'),
    );

    if (isNarrow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          downloadButton,
          const SizedBox(height: 12),
          resetButton,
        ],
      );
    }

    return Row(
      children: [
        downloadButton,
        const SizedBox(width: 12),
        resetButton,
      ],
    );
  }

  Widget _dateField(
    ThemeData theme, {
    required String label,
    required DateTime? value,
    required bool isFromDate,
  }) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: _isDownloading ? null : () => _pickDate(isFromDate: isFromDate),
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 40,
              minWidth: 40,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabled: !_isDownloading,
            border: const OutlineInputBorder(),
          ),
          child: Text(
            value == null ? 'yyyy-MM-dd' : _dateFormat.format(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: value == null ? theme.hintColor : theme.canvasColor,
            ),
          ),
        ),
      ),
    );
  }
}

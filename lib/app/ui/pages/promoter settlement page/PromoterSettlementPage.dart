import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/data/services/promoter_settlement_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PromoterSettlementPage extends StatefulWidget {
  const PromoterSettlementPage({super.key});

  @override
  State<PromoterSettlementPage> createState() =>
      _PromoterSettlementPageState();
}

class _PromoterSettlementPageState extends State<PromoterSettlementPage> {
  final _service = const PromoterSettlementService();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _dateError;
  bool _isDownloading = false;
  DateTime? _lastDownloadTime;

  bool get _hasInvalidRange =>
      _fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!);

  String get _settlementPeriod {
    if (_fromDate == null && _toDate == null) {
      return 'Latest available settlement';
    }
    final from = _fromDate == null ? 'Any start date' : _dateFormat.format(_fromDate!);
    final to = _toDate == null ? 'Any end date' : _dateFormat.format(_toDate!);
    return '$from - $to';
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    if (_isDownloading) return;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now()),
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
      _dateError = _hasInvalidRange ? 'fromDate cannot be greater than toDate' : null;
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
      setState(() => _lastDownloadTime = DateTime.now());
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
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : null,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final compact = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promoter Payment Settlement',
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    )),
                const SizedBox(height: 6),
                Text('Download weekly promoter settlement Excel reports.',
                    style: TextStyle(color: theme.canvasColor.withOpacity(.7))),
                const SizedBox(height: 20),
                _buildFilterCard(theme, compact),
                const SizedBox(height: 16),
                _buildDownloadCard(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(ThemeData theme, bool compact) {
    final fields = [
      Expanded(child: _dateField(theme, label: 'From Date', value: _fromDate, isFromDate: true)),
      const SizedBox(width: 16, height: 12),
      Expanded(child: _dateField(theme, label: 'To Date', value: _toDate, isFromDate: false)),
    ];
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Settlement Period',
              style: TextStyle(color: theme.canvasColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          compact
              ? Column(children: [
                  _dateField(theme, label: 'From Date', value: _fromDate, isFromDate: true),
                  const SizedBox(height: 12),
                  _dateField(theme, label: 'To Date', value: _toDate, isFromDate: false),
                ])
              : Row(children: fields),
          if (_dateError != null) ...[
            const SizedBox(height: 8),
            Text(_dateError!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 8, children: [
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _download,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: _isDownloading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_outlined),
              label: Text(_isDownloading ? 'Downloading...' : 'Download Excel'),
            ),
            OutlinedButton.icon(
              onPressed: _isDownloading ? null : _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _dateField(ThemeData theme, {
    required String label,
    required DateTime? value,
    required bool isFromDate,
  }) {
    return InkWell(
      onTap: _isDownloading ? null : () => _pickDate(isFromDate: isFromDate),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          enabled: !_isDownloading,
          border: const OutlineInputBorder(),
        ),
        child: Text(value == null ? 'yyyy-MM-dd' : _dateFormat.format(value),
            style: TextStyle(color: value == null ? theme.hintColor : theme.canvasColor)),
      ),
    );
  }

  Widget _buildDownloadCard(ThemeData theme) {
    /*
    final _ = _fromDate == null && _toDate == null
        ? 'Latest available settlement'
        : '${_fromDate == null ? 'Any start date' : _dateFormat.format(_fromDate!)} – ${_toDate == null ? 'Any end date' : _dateFormat.format(_toDate!)}';
    */
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.account_balance_wallet_outlined, color: theme.primaryColor),
            const SizedBox(width: 10),
            Text('Weekly Promoter Settlement', style: TextStyle(color: theme.canvasColor, fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          Text('Settlement Period: $_settlementPeriod', style: TextStyle(color: theme.canvasColor)),
          const SizedBox(height: 8),
          Text('Download promoter payment settlement reports for weekly payout processing.',
              style: TextStyle(color: theme.canvasColor.withOpacity(.7))),
          if (_lastDownloadTime != null) ...[
            const SizedBox(height: 8),
            Text('Last Download Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(_lastDownloadTime!)}',
                style: TextStyle(color: theme.canvasColor.withOpacity(.7), fontSize: 12)),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isDownloading ? null : _download,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(_isDownloading ? 'Downloading...' : 'Download Excel'),
          ),
        ]),
      ),
    );
  }
}

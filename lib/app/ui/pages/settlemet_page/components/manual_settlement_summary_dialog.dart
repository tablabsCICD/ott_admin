import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/data/models/response/manual_settlement_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ManualSettlementSummaryDialog extends StatelessWidget {
  final ManualSettlementResponse response;

  const ManualSettlementSummaryDialog({
    super.key,
    required this.response,
  });

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(rawDate.trim());
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatNextScheduled(ManualSettlementData? data) {
    if (data == null) return 'N/A';
    final raw = data.nextScheduledSettlementAt;
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final cleaned = raw.replaceAll(RegExp(r'\[.*\]'), '');
        final parsed = DateTime.parse(cleaned);
        final dateStr = DateFormat('dd MMM yyyy').format(parsed);
        final timeStr = DateFormat('hh:mm a').format(parsed);
        final tz = data.scheduledSettlementTimezone ?? 'Asia/Kolkata';
        return '$dateStr at $timeStr ($tz)';
      } catch (_) {
        return raw;
      }
    }

    if (data.scheduledSettlementDay != null || data.scheduledSettlementTime != null) {
      final day = data.scheduledSettlementDay ?? '';
      final time = data.scheduledSettlementTime ?? '';
      final tz = data.scheduledSettlementTimezone ?? '';
      return '$day $time ${tz.isNotEmpty ? "($tz)" : ""}'.trim();
    }

    return 'N/A';
  }

  String _getUserOnboardingStatus(ManualSettlementData? data) {
    if (data == null) return 'N/A';
    if (data.userOnboardingSettlementSkipped == true) {
      return 'Skipped';
    }
    if (data.includeUserOnboardingSettlement == true) {
      return 'Included';
    }
    if (data.includeUserOnboardingSettlement == false) {
      return 'Excluded';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final data = response.data;

    final startDateStr = _formatDate(data?.settlementWindowStartDate);
    final endDateStr = _formatDate(data?.settlementWindowEndDate);
    final periodStr = '$startDateStr – $endDateStr';

    final mediaHouseCount = data?.processedMediaHouseCount?.toString() ?? 'N/A';
    final historiesUpdated = data?.settlementHistoriesUpserted?.toString() ?? 'N/A';
    final contentSettlement = data?.includeContentSettlement == true
        ? 'Included'
        : (data?.includeContentSettlement == false ? 'Excluded' : 'N/A');
    final userOnboarding = _getUserOnboardingStatus(data);
    final settlementHistory = data?.includeSettlementHistory == true
        ? 'Included'
        : (data?.includeSettlementHistory == false ? 'Excluded' : 'N/A');
    final triggerType = data?.triggerType ?? 'manual-api';
    final nextScheduled = _formatNextScheduled(data);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Settlement Result Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                response.message ?? 'Manual settlement completed successfully.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.canvasColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(theme, 'Settlement period:', periodStr),
                    _buildDivider(theme),
                    _buildSummaryRow(theme, 'Media houses processed:', mediaHouseCount),
                    _buildDivider(theme),
                    _buildSummaryRow(
                      theme,
                      'Settlement histories updated:',
                      historiesUpdated,
                    ),
                    _buildDivider(theme),
                    _buildSummaryRow(theme, 'Content settlement:', contentSettlement),
                    _buildDivider(theme),
                    _buildSummaryRow(
                      theme,
                      'User onboarding settlement:',
                      userOnboarding,
                    ),
                    _buildDivider(theme),
                    _buildSummaryRow(theme, 'Settlement history:', settlementHistory),
                    _buildDivider(theme),
                    _buildSummaryRow(theme, 'Trigger type:', triggerType),
                    _buildDivider(theme),
                    _buildSummaryRow(theme, 'Next scheduled:', nextScheduled),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.canvasColor.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 12,
      thickness: 1,
      color: theme.canvasColor.withValues(alpha: 0.06),
    );
  }
}

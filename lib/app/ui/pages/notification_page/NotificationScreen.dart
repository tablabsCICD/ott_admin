import 'package:admin_ott/app/provider/notification_provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/data/models/response/notification_model.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailSubjectController = TextEditingController();
  final _attachmentController = TextEditingController();
  final _historySearchController = TextEditingController();
  final _dateFormatter = DateFormat('dd/M/yyyy HH:mm');

  String _recipientType = 'ALL_USERS';
  String _priority = 'MEDIUM';
  final Set<String> _channels = {'PUSH'};

  static const _recipientOptions = {
    'ALL_USERS': 'Send to All Users',
    'SELECTED_USERS': 'Send to Selected Users',
    'MEDIA_HOUSES': 'Send to Production Houses',
    'PROMOTERS': 'Send to Promoters',
    'ADMIN_ONLY': 'Send to Admin Only',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailSubjectController.dispose();
    _attachmentController.dispose();
    _historySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            color: theme.primaryColor,
            onRefresh: provider.refreshNotifications,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  EdgeInsets.all(ResponsiveWidget.isMobile(context) ? 12 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 16),
                  if (provider.error != null) _buildErrorState(theme, provider),
                  ResponsiveWidget.isDesktop(context)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _buildAnalytics(theme, provider),
                                  const SizedBox(height: 16),
                                  _buildSettings(theme),
                                  const SizedBox(height: 16),
                                  _buildComposer(theme, provider),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _buildRecentActivity(theme, provider),
                                  const SizedBox(height: 16),
                                  _buildHistory(theme, provider),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildAnalytics(theme, provider),
                            const SizedBox(height: 16),
                            _buildSettings(theme),
                            const SizedBox(height: 16),
                            _buildComposer(theme, provider),
                            const SizedBox(height: 16),
                            _buildRecentActivity(theme, provider),
                            const SizedBox(height: 16),
                            _buildHistory(theme, provider),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return _Panel(
      theme: theme,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _IconTile(
            theme: theme,
            icon: Icons.movie_filter,
            color: theme.primaryColor,
            size: 52,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: ResponsiveWidget.isMobile(context) ? 24 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Admin notifications, audience messaging, and delivery controls.',
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(ThemeData theme, NotificationProvider provider) {
    final items = provider.notifications;
    final failed =
        items.where((item) => item.status.toLowerCase() == 'failed').length;
    final sent =
        provider.totalElements == 0 ? items.length : provider.totalElements;
    final delivered = items.length - failed;
    final successRate =
        items.isEmpty ? 0 : ((delivered / items.length) * 100).round();

    return _Panel(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              theme: theme,
              icon: Icons.trending_up,
              title: 'Notification Analytics'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: ResponsiveWidget.isMobile(context) ? 2 : 4,
            childAspectRatio: ResponsiveWidget.isMobile(context) ? 1.85 : 1.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                  theme: theme,
                  icon: Icons.send,
                  label: 'Total Sent',
                  value: '$sent',
                  color: theme.primaryColor),
              _MetricCard(
                  theme: theme,
                  icon: Icons.error_outline,
                  label: 'Failed',
                  value: '$failed',
                  color: Colors.deepOrange),
              _MetricCard(
                  theme: theme,
                  icon: Icons.done_all,
                  label: 'Delivered',
                  value: '$delivered',
                  color: Colors.green),
              _MetricCard(
                  theme: theme,
                  icon: Icons.trending_up,
                  label: 'Success Rate',
                  value: '$successRate%',
                  color: Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(ThemeData theme) {
    return _Panel(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              theme: theme,
              icon: Icons.campaign,
              title: 'Notification Settings'),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _recipientType,
            dropdownColor: theme.cardColor,
            style: TextStyle(
                color: theme.canvasColor, fontWeight: FontWeight.w700),
            decoration:
                _inputDecoration(theme, 'Send Notification To', Icons.groups),
            items: _recipientOptions.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _recipientType = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(ThemeData theme, NotificationProvider provider) {
    return _Panel(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              theme: theme,
              icon: Icons.edit_notifications,
              title: 'Message Composer'),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: TextStyle(
                color: theme.canvasColor, fontWeight: FontWeight.w700),
            decoration:
                _inputDecoration(theme, 'Notification Title', Icons.title),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            minLines: 5,
            maxLines: 8,
            style: TextStyle(
                color: theme.canvasColor, fontWeight: FontWeight.w600),
            decoration:
                _inputDecoration(theme, 'Message Description', Icons.notes),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailSubjectController,
            style: TextStyle(
                color: theme.canvasColor, fontWeight: FontWeight.w600),
            decoration:
                _inputDecoration(theme, 'Email Subject', Icons.mail_outline),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _attachmentController,
            style: TextStyle(
                color: theme.canvasColor, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
                    theme, 'Optional Attachment URL', Icons.attach_file)
                .copyWith(
              suffixIcon: TextButton(
                onPressed: provider.isUploadingAttachment
                    ? null
                    : () => _pickAndUploadAttachment(provider),
                child: provider.isUploadingAttachment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Upload',
                        style: TextStyle(color: theme.primaryColor),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildPrioritySelector(theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _channelButton(theme, 'PUSH', 'Send Push Notification',
                  Icons.notifications_active),
              _channelButton(
                  theme, 'EMAIL', 'Send Email', Icons.mark_email_read),
              _channelButton(
                  theme, 'SMS', 'Send SMS/Text Message', Icons.sms_outlined),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _showPreview,
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                label: const Text('Preview Message'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onPressed:
                    provider.isSending ? null : () => _schedule(provider),
                icon: provider.isSending
                    ? const SizedBox.shrink()
                    : const Icon(Icons.send, size: 18),
                label: provider.isSending
                    ? const AppButtonLoader(label: 'Sending')
                    : const Text('Send Now'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onPressed: provider.isSending ? null : () => _sendNow(provider),
                icon: const Icon(Icons.schedule_send, size: 18),
                label: const Text('Schedule Notification'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector(ThemeData theme) {
    const priorities = {
      'LOW': (Icons.keyboard_arrow_down, 'Low'),
      'MEDIUM': (Icons.done, 'Medium'),
      'HIGH': (Icons.keyboard_arrow_up, 'High'),
      'URGENT': (Icons.priority_high, 'Urgent'),
    };

    return Wrap(
      spacing: 0,
      children: priorities.entries.map((entry) {
        final selected = _priority == entry.key;
        return InkWell(
          onTap: () => setState(() => _priority = entry.key),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? theme.primaryColor.withValues(alpha: 0.35)
                  : Colors.transparent,
              border:
                  Border.all(color: theme.canvasColor.withValues(alpha: 0.34)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(entry.value.$1, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(entry.value.$2,
                    style: TextStyle(
                        color: theme.canvasColor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _channelButton(
      ThemeData theme, String value, String label, IconData icon) {
    final selected = _channels.contains(value);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? theme.primaryColor : theme.cardColor,
        foregroundColor: selected ? Colors.white : theme.canvasColor,
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      onPressed: () {
        setState(() {
          if (selected) {
            _channels.remove(value);
          } else {
            _channels.add(value);
          }
        });
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, NotificationProvider provider) {
    final latest =
        provider.notifications.isEmpty ? null : provider.notifications.first;
    return _Panel(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              theme: theme, icon: Icons.trending_up, title: 'Recent Activity'),
          const SizedBox(height: 14),
          if (provider.isLoading)
            const AppSkeleton(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: SizedBox(height: 72, width: double.infinity),
            )
          else if (latest == null)
            Text('No recent activity',
                style:
                    TextStyle(color: theme.canvasColor.withValues(alpha: 0.65)))
          else
            Row(
              children: [
                _IconTile(
                    theme: theme,
                    icon: Icons.bolt,
                    color: theme.primaryColor,
                    size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(latest.title,
                          style: TextStyle(
                              color: theme.canvasColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Delivered via ${latest.type}',
                          style: TextStyle(
                              color:
                                  theme.canvasColor.withValues(alpha: 0.62))),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHistory(ThemeData theme, NotificationProvider provider) {
    final history = provider.paginatedNotifications;

    return _Panel(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _SectionTitle(
                      theme: theme,
                      icon: Icons.history,
                      title: 'Notification History')),
              CircleAvatar(
                backgroundColor: theme.primaryColor.withValues(alpha: 0.32),
                child: IconButton(
                  tooltip: 'Filter',
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _historySearchController,
            style: TextStyle(
                color: theme.canvasColor, fontWeight: FontWeight.w600),
            onChanged: provider.setSearchQuery,
            decoration: _inputDecoration(
                    theme, 'Search title, message, or sender', Icons.search)
                .copyWith(
              suffixIcon: Icon(Icons.arrow_forward, color: theme.canvasColor),
            ),
          ),
          const SizedBox(height: 14),
          if (provider.isLoading)
            const _HistorySkeleton()
          else if (history.isEmpty)
            _emptyHistory(theme)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _historyCard(theme, provider, history[index]),
            ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPagination(theme, provider),
          ],
        ],
      ),
    );
  }

  Widget _historyCard(
      ThemeData theme, NotificationProvider provider, NotificationModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconTile(
              theme: theme,
              icon: Icons.notifications_none,
              color: theme.primaryColor,
              size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: TextStyle(
                              color: theme.canvasColor,
                              fontWeight: FontWeight.w900)),
                    ),
                    _pill(theme, item.typeLabel, Colors.blue),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item.messagePreview,
                    style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.66))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(theme, item.sentBy, Colors.grey),
                    _pill(theme, _formatDate(item.createdAt), Colors.grey),
                    _pill(theme, item.audienceLabel, Colors.grey),
                    _pill(theme, item.status, _statusColor(item.status)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  children: [
                    _textAction(theme, Icons.remove_red_eye, 'View Details',
                        () => _showDetails(item)),
                    _textAction(theme, Icons.refresh, 'Resend',
                        () => provider.resendNotification(item.id)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(theme, provider, item),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(ThemeData theme, NotificationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${provider.currentPage + 1} / ${provider.totalPages}',
          style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.7)),
        ),
        IconButton(
          onPressed: provider.currentPage == 0
              ? null
              : () => provider.goToPage(provider.currentPage - 1),
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          onPressed: provider.currentPage >= provider.totalPages - 1
              ? null
              : () => provider.goToPage(provider.currentPage + 1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, NotificationProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(provider.error!,
                  style: TextStyle(color: theme.canvasColor))),
          TextButton(
              onPressed: provider.fetchNotifications,
              child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _emptyHistory(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined,
                color: theme.primaryColor, size: 56),
            const SizedBox(height: 12),
            Text('No notifications found',
                style: TextStyle(
                    color: theme.canvasColor, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      ThemeData theme, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: theme.canvasColor.withValues(alpha: 0.62),
          fontWeight: FontWeight.w700),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: theme.canvasColor.withValues(alpha: 0.34)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.primaryColor),
      ),
    );
  }

  Widget _pill(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color == Colors.grey ? theme.canvasColor : color,
              fontWeight: FontWeight.w800,
              fontSize: 12)),
    );
  }

  Widget _textAction(
      ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: theme.primaryColor),
      label: Text(label, style: TextStyle(color: theme.primaryColor)),
    );
  }

  Future<void> _sendNow(NotificationProvider provider) async {
    final sent = await _submitNotification(provider);

    if (!sent || !mounted) return;
    _clearComposer();
  }

  Future<void> _schedule(NotificationProvider provider) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final sent = await _submitNotification(
      provider,
      scheduledDateTime: scheduledAt,
    );

    if (!sent || !mounted) return;
    _clearComposer();
  }

  Future<bool> _submitNotification(
    NotificationProvider provider, {
    DateTime? scheduledDateTime,
  }) {
    return provider.sendNotification(
      title: _titleController.text,
      message: _messageController.text,
      recipientType: _recipientType,
      notificationTypes: _channels,
      priority: _priority,
      emailSubject: _emailSubjectController.text,
      attachmentUrl: _attachmentController.text,
      scheduledDateTime: scheduledDateTime,
    );
  }

  void _clearComposer() {
    _titleController.clear();
    _messageController.clear();
    _emailSubjectController.clear();
    _attachmentController.clear();
    setState(() {
      _channels
        ..clear()
        ..add('PUSH');
      _priority = 'MEDIUM';
    });
  }

  Future<void> _pickAndUploadAttachment(NotificationProvider provider) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    final file = result?.files.single;
    if (file == null) return;

    final url = await provider.uploadAttachment(file);
    if (url == null || !mounted) return;
    _attachmentController.text = url;
  }

  Future<void> _showPreview() async {
    final theme = context.read<ThemeProvider>().getTheme;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(_titleController.text.trim().isEmpty
            ? 'Notification Preview'
            : _titleController.text.trim()),
        content: Text(
          _messageController.text.trim().isEmpty
              ? 'Message description will appear here.'
              : _messageController.text.trim(),
          style: TextStyle(color: theme.canvasColor),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _showDetails(NotificationModel item) async {
    final theme = context.read<ThemeProvider>().getTheme;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(item.title, style: TextStyle(color: theme.canvasColor)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.message,
                  style: TextStyle(color: theme.canvasColor, height: 1.45)),
              const SizedBox(height: 16),
              _detail(theme, 'Audience', item.audienceLabel),
              _detail(theme, 'Type', item.typeLabel),
              _detail(theme, 'Sent By', item.sentBy),
              _detail(theme, 'Sent At', _formatDate(item.createdAt)),
              _detail(theme, 'Recipients', item.recipientCount.toString()),
              _detail(theme, 'Status', item.status),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ThemeData theme, NotificationProvider provider,
      NotificationModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Delete Notification',
            style: TextStyle(color: theme.canvasColor)),
        content: Text('Are you sure you want to delete "${item.title}"?',
            style: TextStyle(color: theme.canvasColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteNotification(item.id);
    }
  }

  Widget _detail(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 86,
              child: Text(label,
                  style: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w800))),
          Expanded(
              child: Text(value, style: TextStyle(color: theme.canvasColor))),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
      case 'delivered':
        return Colors.green;
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime? date) =>
      date == null ? '-' : _dateFormatter.format(date.toLocal());
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.theme,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final ThemeData theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.theme,
    required this.icon,
    required this.title,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                color: theme.canvasColor,
                fontSize: 22,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.theme,
    required this.icon,
    required this.color,
    required this.size,
  });

  final ThemeData theme;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        color: theme.canvasColor.withValues(alpha: 0.66),
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppSkeleton(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: SizedBox(height: 128, width: double.infinity),
          ),
        ),
      ),
    );
  }
}

extension on NotificationModel {
  String get audienceLabel => targetAudience
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  String get typeLabel => type
      .replaceAll(',', ' / ')
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

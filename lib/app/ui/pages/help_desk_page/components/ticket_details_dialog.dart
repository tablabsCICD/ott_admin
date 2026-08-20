import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/services/ai_task_assistant_service.dart';

void showTicketDetailsDialog(BuildContext context, TicketRaised ticket) {
  showDialog(
    context: context,
    builder: (_) => TicketDetailsDialog(ticket: ticket),
  );
}

class TicketDetailsDialog extends StatefulWidget {
  final TicketRaised ticket;

  const TicketDetailsDialog({super.key, required this.ticket});

  @override
  State<TicketDetailsDialog> createState() => _TicketDetailsDialogState();
}

class _TicketDetailsDialogState extends State<TicketDetailsDialog> {
  late final TextEditingController _replyController;
  late KanbanStatus _selectedStatus;
  bool _isSendingReply = false;
  bool _isStepsExpanded = false;
  late final List<String> _suggestedSteps;
  final Set<int> _completedStepIndices = {};

  final List<String> _quickReplyTemplates = [
    "Please share your payment transaction ID or receipt.",
    "We have cleared the streaming cache. Please try playing the video again.",
    "Your subscription status has been synced. Please relogin to verify.",
    "We are investigating this issue with our engineering team.",
    "This issue has been resolved. Please verify on your end.",
  ];

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    _selectedStatus = KanbanStatus.fromString(
      widget.ticket.status,
      isResolved: widget.ticket.isResolved,
    );
    _suggestedSteps =
        AiTaskAssistantService.instance.decomposeTask(widget.ticket);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  String _formatDateTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return 'Unknown Date';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'Unknown Date';
    }
  }

  void _openImageLightbox(String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(32),
                    color: Colors.black87,
                    child: const Text(
                      "Image preview not available",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon:
                      const Icon(Icons.close, color: Colors.black54, size: 20),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _appendReplyText(String text) {
    final current = _replyController.text.trim();
    if (current.isEmpty) {
      _replyController.text = text;
    } else {
      _replyController.text = "$current\n$text";
    }
  }

  Future<void> _handleSendReply({bool markResolved = false}) async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty && !markResolved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Please type a reply before sending."),
        ),
      );
      return;
    }

    if (_isSendingReply) return;
    setState(() => _isSendingReply = true);

    final provider = context.read<TicketProvider>();

    // Combine existing feedback with new reply if existing exists
    String combinedFeedback = replyText;
    if ((widget.ticket.feedback ?? '').isNotEmpty && replyText.isNotEmpty) {
      combinedFeedback =
          "${widget.ticket.feedback}\n\n[Admin Reply]: $replyText";
    } else if (replyText.isEmpty && markResolved) {
      combinedFeedback = widget.ticket.feedback ?? "Ticket resolved by Admin.";
    }

    final targetStatus = markResolved ? KanbanStatus.done : _selectedStatus;

    final result = await provider.updateTicketStatus(
      widget.ticket,
      targetStatus,
      resolutionNotes: combinedFeedback,
    );

    if (!mounted) return;
    setState(() => _isSendingReply = false);

    if (result['success'] == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text(
            markResolved
                ? "Reply sent & ticket resolved successfully!"
                : "Reply sent to customer successfully!",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content:
              Text(result['message']?.toString() ?? "Failed to send reply"),
        ),
      );
    }
  }

  Future<void> _handleReopenTicket() async {
    if (_isSendingReply) return;
    setState(() => _isSendingReply = true);

    final provider = context.read<TicketProvider>();
    final replyText = _replyController.text.trim();
    final note = replyText.isNotEmpty
        ? "${widget.ticket.feedback ?? ''}\n\n[Admin Reopened]: $replyText"
            .trim()
        : "${widget.ticket.feedback ?? ''}\n\n[Admin Reopened Ticket]".trim();

    final result = await provider.updateTicketStatus(
      widget.ticket,
      KanbanStatus.todo,
      resolutionNotes: note,
    );

    if (!mounted) return;
    setState(() => _isSendingReply = false);

    if (result['success'] == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue.shade700,
          content: const Text("Ticket reopened and moved to To Do."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content:
              Text(result['message']?.toString() ?? "Failed to reopen ticket"),
        ),
      );
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Support Ticket'),
        content: Text(
          'Are you sure you want to delete ticket #${widget.ticket.tickedId ?? ''}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = context.read<TicketProvider>();
              final result = await provider.deleteQuery(widget.ticket);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:
                        result['success'] == true ? Colors.green : Colors.red,
                    content:
                        Text(result['message']?.toString() ?? 'Ticket deleted'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final priority = TicketPriority.fromString(
      widget.ticket.priority ?? widget.ticket.topic,
    );
    final risk = AiTaskAssistantService.instance.calculateRisk(widget.ticket);
    final aiSummary =
        AiTaskAssistantService.instance.generateTaskSummary(widget.ticket);
    final nextAction =
        AiTaskAssistantService.instance.getSuggestedNextAction(widget.ticket);
    final isResolved = widget.ticket.isResolved == true ||
        _selectedStatus == KanbanStatus.done;
    final hasAdminFeedback = (widget.ticket.feedback ?? '').trim().isNotEmpty;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 820),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      "#${widget.ticket.tickedId ?? '-'}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.canvasColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priority.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(priority.icon, size: 12, color: priority.color),
                        const SizedBox(width: 4),
                        Text(
                          priority.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: priority.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: risk.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(risk.icon, size: 12, color: risk.color),
                        const SizedBox(width: 4),
                        Text(
                          risk.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: risk.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic Title
                    Text(
                      widget.ticket.topic ?? 'No Subject Provided',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.canvasColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // "Who Raised / Who Resolves" Ownership Overview Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Raised By Column
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: theme.primaryColor
                                          .withValues(alpha: 0.15),
                                      child: Text(
                                        (widget.ticket.email?.isNotEmpty == true
                                                ? widget.ticket.email![0]
                                                : 'U')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Builder(builder: (context) {
                                            final role = TicketProvider.resolveTicketRole(widget.ticket);
                                            final level = TicketProvider.resolveTicketPromoterLevel(widget.ticket);
                                            final isPromoter = role == 'PROMOTER';

                                            return Row(
                                              children: [
                                                Text(
                                                  "Raised By",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.hintColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: (isPromoter
                                                            ? const Color(0xFF8B5CF6)
                                                            : role == 'ADMIN'
                                                                ? const Color(0xFFF59E0B)
                                                                : role == 'MEDIA_HOUSE'
                                                                    ? const Color(0xFF10B981)
                                                                    : const Color(0xFF0EA5E9))
                                                        .withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    isPromoter
                                                        ? (level != null ? 'Promoter ($level)' : 'Promoter')
                                                        : role == 'ADMIN'
                                                            ? 'Admin'
                                                            : role == 'MEDIA_HOUSE'
                                                                ? 'Media House'
                                                                : 'User',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                      color: isPromoter
                                                          ? const Color(0xFF8B5CF6)
                                                          : role == 'ADMIN'
                                                              ? const Color(0xFFF59E0B)
                                                              : role == 'MEDIA_HOUSE'
                                                                  ? const Color(0xFF10B981)
                                                                  : const Color(0xFF0EA5E9),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                          const SizedBox(height: 2),
                                          Text(
                                            widget.ticket.email ?? 'Customer',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: theme.canvasColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if ((widget.ticket.mobileNumber ?? '')
                                              .isNotEmpty)
                                            Text(
                                              widget.ticket.mobileNumber!,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: theme.hintColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Assigned To
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Assigned To",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.support_agent_rounded,
                                          size: 14, color: Color(0xFF6366F1)),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Support Admin",
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: theme.canvasColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),

                              // Resolution Status
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Status",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isResolved
                                              ? KanbanStatus.done.color
                                              : _selectedStatus.color)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isResolved
                                          ? "Resolved"
                                          : _selectedStatus.label,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: isResolved
                                            ? KanbanStatus.done.color
                                            : _selectedStatus.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // AI Assistant Summary & Insight
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.08),
                            const Color(0xFF6366F1).withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 15, color: theme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "AI Task Insight",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            aiSummary,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.canvasColor.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded,
                                  size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Recommended Action: $nextAction",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: theme.canvasColor
                                        .withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Conversation Thread Section Header
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "Conversation Thread",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: theme.canvasColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Customer Message Bubble
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Customer Inquiry",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDateTime(widget.ticket.date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (widget.ticket.description ?? '').trim().isNotEmpty
                                ? widget.ticket.description!.trim()
                                : 'No description provided by customer.',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.canvasColor,
                              height: 1.4,
                            ),
                          ),
                          // Attachment Preview inside bubble
                          if (widget.ticket.image != null &&
                              widget.ticket.image!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () =>
                                  _openImageLightbox(widget.ticket.image!),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 120,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.ticket.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text(
                                        "Image preview",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Admin Previous Response Bubble (if available)
                    if (hasAdminFeedback) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF6366F1).withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(4),
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          border: Border.all(
                            color:
                                const Color(0xFF6366F1).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_rounded,
                                    size: 14, color: Color(0xFF6366F1)),
                                const SizedBox(width: 6),
                                const Text(
                                  "Admin Response / Resolution",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                const Spacer(),
                                if (isResolved)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "Resolved",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.ticket.feedback!.trim(),
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.canvasColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // AI Task Decomposition Checklist
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => setState(
                                () => _isStepsExpanded = !_isStepsExpanded),
                            child: Row(
                              children: [
                                Icon(Icons.checklist_rounded,
                                    size: 18, color: theme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  "Action Checklist (${_completedStepIndices.length}/${_suggestedSteps.length})",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: theme.canvasColor,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _isStepsExpanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          if (_isStepsExpanded) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 6),
                            ..._suggestedSteps.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stepText = entry.value;
                              final isDone =
                                  _completedStepIndices.contains(index);

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isDone) {
                                      _completedStepIndices.remove(index);
                                    } else {
                                      _completedStepIndices.add(index);
                                      _appendReplyText(
                                          "• Completed: $stepText");
                                    }
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isDone
                                            ? Icons.check_box_rounded
                                            : Icons
                                                .check_box_outline_blank_rounded,
                                        size: 16,
                                        color: isDone
                                            ? Colors.green
                                            : theme.hintColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          stepText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDone
                                                ? theme.hintColor
                                                : theme.canvasColor,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Reply Suggestion Chips
                    Text(
                      "Quick Reply Templates",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _quickReplyTemplates.map((template) {
                        return ActionChip(
                          avatar: const Icon(Icons.bolt_rounded,
                              size: 13, color: Color(0xFF6366F1)),
                          label: Text(
                            template,
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.15),
                            ),
                          ),
                          onPressed: () => _appendReplyText(template),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Reply Input Field
                    Text(
                      "Write a Reply to Customer",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.canvasColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _replyController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 13, color: theme.canvasColor),
                      decoration: InputDecoration(
                        hintText: "Type your reply to the customer here...",
                        hintStyle:
                            TextStyle(fontSize: 12.5, color: theme.hintColor),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modal Footer Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSendingReply ? null : _handleDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Colors.red),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _isSendingReply
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),

                  // If already resolved, show Reopen button
                  if (isResolved) ...[
                    ElevatedButton.icon(
                      onPressed: _isSendingReply ? null : _handleReopenTicket,
                      icon: const Icon(Icons.replay_rounded, size: 16),
                      label: const Text("Reopen Ticket"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Send Reply & Resolve Action (if not resolved)
                  if (!isResolved) ...[
                    OutlinedButton.icon(
                      onPressed: _isSendingReply
                          ? null
                          : () => _handleSendReply(markResolved: true),
                      icon: Icon(Icons.check_circle_outline_rounded,
                          size: 16, color: KanbanStatus.done.color),
                      label: Text(
                        "Resolve Ticket",
                        style: TextStyle(
                          color: KanbanStatus.done.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: KanbanStatus.done.color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Send Reply Action
                  ElevatedButton.icon(
                    onPressed: _isSendingReply
                        ? null
                        : () => _handleSendReply(markResolved: false),
                    icon: _isSendingReply
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 16),
                    label: Text(
                      _isSendingReply ? "Sending..." : "Send Reply",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

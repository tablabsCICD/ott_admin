import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';

import 'package:admin_ott/app/ui/pages/help_desk_page/services/ai_task_assistant_service.dart';

class KanbanCard extends StatefulWidget {
  final TicketRaised ticket;
  final VoidCallback onTap;
  final ValueChanged<KanbanStatus>? onQuickStatusChange;

  const KanbanCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onQuickStatusChange,
  });

  @override
  State<KanbanCard> createState() => _KanbanCardState();
}

class _KanbanCardState extends State<KanbanCard> {
  bool _isHovered = false;

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '-';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes <= 1) return 'Just now';
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final ticketProvider = context.watch<TicketProvider>();
    final isUpdating = ticketProvider.isTicketUpdating(widget.ticket.tickedId);

    final priority = TicketPriority.fromString(
      widget.ticket.priority ?? widget.ticket.topic,
    );
    final status = KanbanStatus.fromString(
      widget.ticket.status,
      isResolved: widget.ticket.isResolved,
    );
    final risk = AiTaskAssistantService.instance.calculateRisk(widget.ticket);
    final age = AiTaskAssistantService.instance.calculateAgeInDays(widget.ticket.date);

    final cardContent = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isUpdating ? SystemMouseCursors.wait : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? theme.primaryColor.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.15),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 10 : 4,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Ticket ID + Priority + Risk / Aging + Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          "#${widget.ticket.tickedId ?? '-'}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.canvasColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priority.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: priority.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(priority.icon, size: 11, color: priority.color),
                            const SizedBox(width: 3),
                            Text(
                              priority.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: priority.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status != KanbanStatus.done && risk == TaskRiskLevel.high) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "⚡ High Risk",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ] else if (status != KanbanStatus.done && age >= 3) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${age}d old",
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatDate(widget.ticket.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Topic / Title
                  Text(
                    widget.ticket.topic ?? 'No Topic',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: theme.canvasColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role & Promoter Level Badges
                  Builder(builder: (context) {
                    final role = TicketProvider.resolveTicketRole(widget.ticket);
                    final level = TicketProvider.resolveTicketPromoterLevel(widget.ticket);
                    final isPromoter = role == 'PROMOTER';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isPromoter
                                      ? const Color(0xFF8B5CF6)
                                      : role == 'ADMIN'
                                          ? const Color(0xFFF59E0B)
                                          : role == 'MEDIA_HOUSE'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF0EA5E9))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: (isPromoter
                                        ? const Color(0xFF8B5CF6)
                                        : role == 'ADMIN'
                                            ? const Color(0xFFF59E0B)
                                            : role == 'MEDIA_HOUSE'
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF0EA5E9))
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPromoter
                                      ? Icons.campaign_rounded
                                      : role == 'ADMIN'
                                          ? Icons.admin_panel_settings_outlined
                                          : role == 'MEDIA_HOUSE'
                                              ? Icons.movie_creation_outlined
                                              : Icons.person_outline_rounded,
                                  size: 10.5,
                                  color: isPromoter
                                      ? const Color(0xFF8B5CF6)
                                      : role == 'ADMIN'
                                          ? const Color(0xFFF59E0B)
                                          : role == 'MEDIA_HOUSE'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF0EA5E9),
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  isPromoter
                                      ? 'Promoter'
                                      : role == 'ADMIN'
                                          ? 'Admin'
                                          : role == 'MEDIA_HOUSE'
                                              ? 'Media House'
                                              : 'User',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isPromoter
                                        ? const Color(0xFF8B5CF6)
                                        : role == 'ADMIN'
                                            ? const Color(0xFFF59E0B)
                                            : role == 'MEDIA_HOUSE'
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF0EA5E9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isPromoter && level != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded, size: 10.5, color: Color(0xFF6366F1)),
                                  const SizedBox(width: 3.5),
                                  Text(
                                    "$level Level",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Description snippet
                  if ((widget.ticket.description ?? '').trim().isNotEmpty) ...[
                    Text(
                      widget.ticket.description!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.canvasColor.withValues(alpha: 0.65),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Bottom Row: User Avatar & Email + Attachment + Status / Quick Action
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          (widget.ticket.email?.isNotEmpty == true
                                  ? widget.ticket.email![0]
                                  : (widget.ticket.topic?.isNotEmpty == true
                                      ? widget.ticket.topic![0]
                                      : 'U'))
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.ticket.email ?? widget.ticket.mobileNumber ?? 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.canvasColor.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      if (widget.ticket.image != null && widget.ticket.image!.isNotEmpty) ...[
                        Icon(
                          Icons.attach_file_rounded,
                          size: 14,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (status == KanbanStatus.done)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: KanbanStatus.done.color,
                        )
                      else if (isUpdating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Loading overlay if updating
            if (isUpdating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Draggable<TicketRaised>(
      data: widget.ticket,
      feedback: Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 280,
          child: Opacity(
            opacity: 0.95,
            child: cardContent,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: cardContent,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: cardContent,
      ),
    );
  }
}

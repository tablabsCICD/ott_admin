import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';
import 'kanban_card.dart';

class KanbanColumn extends StatefulWidget {
  final KanbanStatus status;
  final List<TicketRaised> tickets;
  final int totalCount;
  final void Function(TicketRaised ticket, KanbanStatus newStatus) onTicketDropped;
  final ValueChanged<TicketRaised> onTicketTap;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tickets,
    required this.totalCount,
    required this.onTicketDropped,
    required this.onTicketTap,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  bool _isDraggingOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return DragTarget<TicketRaised>(
      onWillAcceptWithDetails: (details) {
        final currentStatus = KanbanStatus.fromString(
          details.data.status,
          isResolved: details.data.isResolved,
        );
        return currentStatus != widget.status;
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDraggingOver = false);
        widget.onTicketDropped(details.data, widget.status);
      },
      onMove: (_) {
        if (!_isDraggingOver) {
          setState(() => _isDraggingOver = true);
        }
      },
      onLeave: (_) {
        if (_isDraggingOver) {
          setState(() => _isDraggingOver = false);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: _isDraggingOver
                ? widget.status.color.withValues(alpha: 0.08)
                : theme.cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDraggingOver
                  ? widget.status.color
                  : theme.dividerColor.withValues(alpha: 0.15),
              width: _isDraggingOver ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: widget.status.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.status.color.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.status.label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: theme.canvasColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${widget.totalCount}",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: widget.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Task List
              Expanded(
                child: widget.tickets.isEmpty
                    ? _buildEmptyColumn(theme)
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: widget.tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final ticket = widget.tickets[index];
                          return KanbanCard(
                            key: ValueKey(ticket.tickedId ?? index),
                            ticket: ticket,
                            onTap: () => widget.onTicketTap(ticket),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyColumn(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.status.icon,
              size: 32,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "No tasks in ${widget.status.label}",
              style: TextStyle(
                fontSize: 12.5,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Drag tasks here to update status",
              style: TextStyle(
                fontSize: 10.5,
                color: theme.hintColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

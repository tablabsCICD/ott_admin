import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import '../models/kanban_status.dart';
import '../services/ai_task_assistant_service.dart';

class AiDailyFocusBanner extends StatefulWidget {
  final ValueChanged<TicketRaised> onTicketSelected;

  const AiDailyFocusBanner({super.key, required this.onTicketSelected});

  @override
  State<AiDailyFocusBanner> createState() => _AiDailyFocusBannerState();
}

class _AiDailyFocusBannerState extends State<AiDailyFocusBanner> {
  bool _isPlannerExpanded = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final provider = context.watch<TicketProvider>();
    final isDesktop = ResponsiveWidget.isDesktop(context);

    final urgentCount = provider.urgentTicketsCount;
    final agingCount = provider.agingTicketsCount;
    final inReviewCount = provider.inReviewTicketsCount;
    final resolvedCount = provider.resolvedTodayCount;
    final dailyPlannerList = provider.dailyFocusPlannerList;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Summary Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_getGreeting()}, Admin",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.canvasColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      urgentCount > 0
                          ? "You have $urgentCount high-priority support tasks requiring immediate attention."
                          : "All high-priority tasks are in order. Keep up the great work!",
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (dailyPlannerList.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _isPlannerExpanded = !_isPlannerExpanded),
                  icon: Icon(
                    _isPlannerExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _isPlannerExpanded ? "Hide Planner" : "Today's AI Planner",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Metric Focus Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isDesktop
                  ? ((constraints.maxWidth - (3 * 12)) / 4).clamp(140.0, 300.0)
                  : ((constraints.maxWidth - 12) / 2);

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _metricCard(
                    theme: theme,
                    title: "Urgent Attention",
                    count: urgentCount,
                    accentColor: const Color(0xFFEF4444),
                    icon: Icons.error_outline_rounded,
                    width: cardWidth,
                    isSelected: provider.priorityFilter == TicketPriority.high,
                    onTap: () {
                      provider.setPriorityFilter(
                        provider.priorityFilter == TicketPriority.high ? null : TicketPriority.high,
                      );
                    },
                  ),
                  _metricCard(
                    theme: theme,
                    title: "Aging Tasks (> 3d)",
                    count: agingCount,
                    accentColor: const Color(0xFFF59E0B),
                    icon: Icons.history_toggle_off_rounded,
                    width: cardWidth,
                    isSelected: provider.onlyAgingFilter,
                    onTap: () {
                      provider.setOnlyAgingFilter(!provider.onlyAgingFilter);
                    },
                  ),
                  _metricCard(
                    theme: theme,
                    title: "In Review",
                    count: inReviewCount,
                    accentColor: const Color(0xFF3B82F6),
                    icon: Icons.rate_review_outlined,
                    width: cardWidth,
                    isSelected: provider.statusFilter == KanbanStatus.inReview,
                    onTap: () {
                      provider.setStatusFilter(
                        provider.statusFilter == KanbanStatus.inReview ? null : KanbanStatus.inReview,
                      );
                    },
                  ),
                  _metricCard(
                    theme: theme,
                    title: "Resolved / Done",
                    count: resolvedCount,
                    accentColor: const Color(0xFF10B981),
                    icon: Icons.check_circle_outline_rounded,
                    width: cardWidth,
                    isSelected: provider.statusFilter == KanbanStatus.done,
                    onTap: () {
                      provider.setStatusFilter(
                        provider.statusFilter == KanbanStatus.done ? null : KanbanStatus.done,
                      );
                    },
                  ),
                ],
              );
            },
          ),

          // Collapsible Daily Focus Planner List
          if (_isPlannerExpanded && dailyPlannerList.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              "Recommended Execution Sequence",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: dailyPlannerList.length.clamp(0, 5),
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final ticket = dailyPlannerList[index];
                  final risk = AiTaskAssistantService.instance.calculateRisk(ticket);
                  final age = AiTaskAssistantService.instance.calculateAgeInDays(ticket.date);

                  return InkWell(
                    onTap: () => widget.onTicketSelected(ticket),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: risk.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "#${index + 1}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: risk.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ticket.topic ?? 'Support Ticket #${ticket.tickedId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: theme.canvasColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (age >= 3) ...[
                            Text(
                              "Aging ${age}d",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: risk.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              risk.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: risk.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricCard({
    required ThemeData theme,
    required String title,
    required int count,
    required Color accentColor,
    required IconData icon,
    required double width,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.canvasColor,
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

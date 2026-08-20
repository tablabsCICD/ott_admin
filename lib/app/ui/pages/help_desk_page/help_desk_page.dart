import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'components/ai_command_bar.dart';
import 'components/ai_daily_focus_banner.dart';
import 'components/kanban_column.dart';
import 'components/ticket_details_dialog.dart';
import 'components/ticket_filter_bar.dart';
import 'models/kanban_status.dart';

class HelpDeskPage extends StatefulWidget {
  const HelpDeskPage({super.key});

  @override
  State<HelpDeskPage> createState() => _HelpDeskPageState();
}

class _HelpDeskPageState extends State<HelpDeskPage> with SingleTickerProviderStateMixin {
  TabController? _mobileTabController;

  @override
  void initState() {
    super.initState();
    _mobileTabController = TabController(length: KanbanStatus.values.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  @override
  void dispose() {
    _mobileTabController?.dispose();
    super.dispose();
  }

  void _loadTickets() {
    final provider = context.read<TicketProvider>();
    provider.initCurrentUser();
    provider.getAllRaisedTicket();
  }

  Future<void> _handleTicketDrop(TicketRaised ticket, KanbanStatus newStatus) async {
    final provider = context.read<TicketProvider>();
    final result = await provider.updateTicketStatus(ticket, newStatus);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
          content: Text("Moved #${ticket.tickedId ?? ''} to ${newStatus.label}"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(result['message']?.toString() ?? "Failed to update status"),
        ),
      );
    }
  }

  void _openDetails(TicketRaised ticket) {
    showTicketDetailsDialog(context, ticket);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final provider = context.watch<TicketProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // AI Command Input Bar
          const AiCommandBar(),

          // AI Daily Focus & Urgent Insights Banner
          AiDailyFocusBanner(onTicketSelected: _openDetails),

          // Search & Filter Header Bar
          TicketFilterBar(
            onRefresh: _loadTickets,
          ),

          // Main Kanban Content Area
          Expanded(
            child: provider.isLoading && provider.tickets.isEmpty
                ? const Center(child: AppSpinner())
                : provider.error != null && provider.tickets.isEmpty
                    ? _buildErrorState(theme, provider)
                    : isDesktop
                        ? _buildDesktopKanban(provider)
                        : _buildMobileKanban(theme, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopKanban(TicketProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: KanbanStatus.values.map((status) {
                  final columnTickets = provider.getTicketsForStatus(status);
                  final count = provider.getCountForStatus(status);

                  return KanbanColumn(
                    key: ValueKey(status),
                    status: status,
                    tickets: columnTickets,
                    totalCount: count,
                    onTicketDropped: _handleTicketDrop,
                    onTicketTap: _openDetails,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileKanban(ThemeData theme, TicketProvider provider) {
    return Column(
      children: [
        Container(
          color: theme.cardColor,
          child: TabBar(
            controller: _mobileTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.hintColor,
            indicatorColor: theme.primaryColor,
            tabs: KanbanStatus.values.map((s) {
              final count = provider.getCountForStatus(s);
              return Tab(
                child: Row(
                  children: [
                    Icon(s.icon, size: 14, color: s.color),
                    const SizedBox(width: 6),
                    Text(s.label),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$count",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: s.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _mobileTabController,
            children: KanbanStatus.values.map((status) {
              final columnTickets = provider.getTicketsForStatus(status);
              final count = provider.getCountForStatus(status);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: KanbanColumn(
                  key: ValueKey(status),
                  status: status,
                  tickets: columnTickets,
                  totalCount: count,
                  onTicketDropped: _handleTicketDrop,
                  onTicketTap: _openDetails,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, TicketProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(
              "Unable to load tickets",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              provider.error ?? "An unexpected error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.hintColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTickets,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

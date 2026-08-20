import 'package:flutter_test/flutter_test.dart';

import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/services/ai_task_assistant_service.dart';
import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';

void main() {
  group('AiTaskAssistantService Tests', () {
    final aiService = AiTaskAssistantService.instance;

    test('parses natural language queries accurately', () {
      // Promoter and Level queries
      final nationalIntent = aiService.parseNaturalLanguageQuery("Show national level promoter tickets");
      expect(nationalIntent.userRole, 'PROMOTER');
      expect(nationalIntent.promoterLevel, 'National');

      final stateIntent = aiService.parseNaturalLanguageQuery("Show state level promoter problems");
      expect(stateIntent.userRole, 'PROMOTER');
      expect(stateIntent.promoterLevel, 'State');

      final promoterIntent = aiService.parseNaturalLanguageQuery("Show promoter issues");
      expect(promoterIntent.userRole, 'PROMOTER');

      final userIntent = aiService.parseNaturalLanguageQuery("Show user complaints");
      expect(userIntent.userRole, 'USER');

      // Payment queries
      final paymentIntent = aiService.parseNaturalLanguageQuery("Show me high priority payment issues");
      expect(paymentIntent.searchQuery, 'payment');
      expect(paymentIntent.priority, TicketPriority.high);

      // Overdue queries
      final overdueIntent = aiService.parseNaturalLanguageQuery("Show overdue tasks");
      expect(overdueIntent.onlyAging, true);

      // In Review queries
      final reviewIntent = aiService.parseNaturalLanguageQuery("What is in review?");
      expect(reviewIntent.status, KanbanStatus.inReview);

      // Done queries
      final doneIntent = aiService.parseNaturalLanguageQuery("Show resolved tickets");
      expect(doneIntent.status, KanbanStatus.done);

      // Urgent queries
      final urgentIntent = aiService.parseNaturalLanguageQuery("Show urgent tasks");
      expect(urgentIntent.priority, TicketPriority.high);

      // Video queries
      final videoIntent = aiService.parseNaturalLanguageQuery("Playback stream buffering");
      expect(videoIntent.searchQuery, 'playback');
    });

    test('calculates risk score and generates grounded suggestions', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch;

      final highRiskTicket = TicketRaised(
        tickedId: 101,
        topic: "Payment Failure for Annual Plan",
        description: "User charged but subscription not activated",
        email: "alice@test.com",
        date: fourDaysAgo,
        isResolved: false,
        priority: "HIGH",
      );

      final risk = aiService.calculateRisk(highRiskTicket);
      expect(risk, TaskRiskLevel.high);

      final summary = aiService.generateTaskSummary(highRiskTicket);
      expect(summary.contains("Payment Failure"), true);
      expect(summary.contains("alice@test.com"), true);

      final nextAction = aiService.getSuggestedNextAction(highRiskTicket);
      expect(nextAction.toLowerCase().contains("payment"), true);

      final steps = aiService.decomposeTask(highRiskTicket);
      expect(steps.isNotEmpty, true);
      expect(steps.any((s) => s.toLowerCase().contains("webhook") || s.toLowerCase().contains("gateway")), true);
    });
  });

  group('TicketProvider AI Integration Tests', () {
    test('computes AI focus metrics and executes AI intents', () {
      final provider = TicketProvider();
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4)).millisecondsSinceEpoch;

      final t1 = TicketRaised(
        tickedId: 1,
        topic: "Critical Payment Bug",
        date: fourDaysAgo,
        isResolved: false,
        priority: "HIGH",
        status: "TODO",
      );

      final t2 = TicketRaised(
        tickedId: 2,
        topic: "Subtitle Alignment",
        date: DateTime.now().millisecondsSinceEpoch,
        isResolved: false,
        priority: "LOW",
        status: "IN_REVIEW",
      );

      final t3 = TicketRaised(
        tickedId: 3,
        topic: "Login Error",
        date: DateTime.now().millisecondsSinceEpoch,
        isResolved: true,
        status: "DONE",
      );

      provider.tickets.addAll([t1, t2, t3]);

      // Metrics
      expect(provider.urgentTicketsCount, 1);
      expect(provider.agingTicketsCount, 1);
      expect(provider.inReviewTicketsCount, 1);
      expect(provider.resolvedTodayCount, 1);

      // AI Intent Application
      final intent = AiTaskAssistantService.instance.parseNaturalLanguageQuery("Show overdue tasks");
      provider.applyAiIntent(intent);

      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 1);
      expect(provider.activeAiExplanation != null, true);

      // Daily Focus Planner List
      final plannerList = provider.dailyFocusPlannerList;
      expect(plannerList.length, 2); // 2 unresolved tasks
      expect(plannerList.first.tickedId, 1); // High risk/older ticket first
    });
  });
}

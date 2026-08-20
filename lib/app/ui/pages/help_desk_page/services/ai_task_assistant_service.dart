import 'package:flutter/material.dart';

import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';

enum TaskRiskLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskRiskLevel.low:
        return 'Low Risk';
      case TaskRiskLevel.medium:
        return 'Medium Risk';
      case TaskRiskLevel.high:
        return 'High Risk';
    }
  }

  Color get color {
    switch (this) {
      case TaskRiskLevel.low:
        return const Color(0xFF10B981);
      case TaskRiskLevel.medium:
        return const Color(0xFFF59E0B);
      case TaskRiskLevel.high:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskRiskLevel.low:
        return Icons.shield_outlined;
      case TaskRiskLevel.medium:
        return Icons.warning_amber_rounded;
      case TaskRiskLevel.high:
        return Icons.gpp_bad_outlined;
    }
  }
}

class AiFilterIntent {
  final String? searchQuery;
  final TicketPriority? priority;
  final KanbanStatus? status;
  final bool? onlyAging;
  final String? userRole;
  final String? promoterLevel;
  final String explanation;

  const AiFilterIntent({
    this.searchQuery,
    this.priority,
    this.status,
    this.onlyAging,
    this.userRole,
    this.promoterLevel,
    required this.explanation,
  });
}

class AiTaskAssistantService {
  AiTaskAssistantService._();
  static final AiTaskAssistantService instance = AiTaskAssistantService._();

  /// Parse natural language admin queries into structured filter parameters
  AiFilterIntent parseNaturalLanguageQuery(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return const AiFilterIntent(explanation: "Showing all tasks");
    }

    // 0. Promoter & Level queries
    if (q.contains('national') || q.contains('country level') || q.contains('national level')) {
      return const AiFilterIntent(
        userRole: 'PROMOTER',
        promoterLevel: 'National',
        explanation: "Filtered to National Level Promoter tickets",
      );
    }
    if (q.contains('state level') || (q.contains('state') && q.contains('promoter'))) {
      return const AiFilterIntent(
        userRole: 'PROMOTER',
        promoterLevel: 'State',
        explanation: "Filtered to State Level Promoter tickets",
      );
    }
    if (q.contains('district level') || (q.contains('district') && q.contains('promoter'))) {
      return const AiFilterIntent(
        userRole: 'PROMOTER',
        promoterLevel: 'District',
        explanation: "Filtered to District Level Promoter tickets",
      );
    }
    if (q.contains('taluka level') || (q.contains('taluka') && q.contains('promoter'))) {
      return const AiFilterIntent(
        userRole: 'PROMOTER',
        promoterLevel: 'Taluka',
        explanation: "Filtered to Taluka Level Promoter tickets",
      );
    }
    if (q.contains('promoter')) {
      return const AiFilterIntent(
        userRole: 'PROMOTER',
        explanation: "Filtered to all Promoter tickets",
      );
    }
    if (q.contains('user ticket') || q.contains('user complaint') || q.contains('customer')) {
      return const AiFilterIntent(
        userRole: 'USER',
        explanation: "Filtered to User / Customer support tickets",
      );
    }
    if (q.contains('admin ticket') || q.contains('admin request')) {
      return const AiFilterIntent(
        userRole: 'ADMIN',
        explanation: "Filtered to Admin tickets",
      );
    }

    // 1. High priority + payment issues
    if (q.contains('payment') || q.contains('billing') || q.contains('refund') || q.contains('subscription')) {
      final isHigh = q.contains('high') || q.contains('urgent') || q.contains('critical');
      return AiFilterIntent(
        searchQuery: 'payment',
        priority: isHigh ? TicketPriority.high : null,
        status: q.contains('done') || q.contains('resolved') ? KanbanStatus.done : null,
        explanation: isHigh
            ? "Filtered to High-Priority Payment & Billing issues"
            : "Filtered to Payment & Billing queries",
      );
    }

    // 2. Playback / Video / Streaming issues
    if (q.contains('video') || q.contains('stream') || q.contains('playback') || q.contains('audio') || q.contains('lag') || q.contains('buffer')) {
      final isHigh = q.contains('high') || q.contains('urgent');
      return AiFilterIntent(
        searchQuery: 'playback',
        priority: isHigh ? TicketPriority.high : null,
        explanation: "Filtered to Video & Playback stream issues",
      );
    }

    // 3. Urgent / High Priority
    if (q.contains('high priority') || q.contains('urgent') || q.contains('critical') || q.contains('immediate')) {
      return const AiFilterIntent(
        priority: TicketPriority.high,
        explanation: "Showing all High Priority & Urgent tasks",
      );
    }

    // 4. Overdue / Aging tasks
    if (q.contains('overdue') || q.contains('aging') || q.contains('old') || q.contains('stale') || q.contains('delayed')) {
      return const AiFilterIntent(
        onlyAging: true,
        explanation: "Showing Aging & Overdue support tasks (> 3 days)",
      );
    }

    // 5. In Review tasks
    if (q.contains('review') || q.contains('pending approval') || q.contains('in review')) {
      return const AiFilterIntent(
        status: KanbanStatus.inReview,
        explanation: "Showing tasks currently In Review",
      );
    }

    // 6. To Do / Open tasks
    if (q.contains('to do') || q.contains('todo') || q.contains('open') || q.contains('new')) {
      return const AiFilterIntent(
        status: KanbanStatus.todo,
        explanation: "Showing open To-Do tasks",
      );
    }

    // 7. Done / Resolved tasks
    if (q.contains('done') || q.contains('resolved') || q.contains('solved') || q.contains('closed')) {
      return const AiFilterIntent(
        status: KanbanStatus.done,
        explanation: "Showing Resolved & Closed tasks",
      );
    }

    // 8. "What needs my attention today?" / Daily Priorities
    if (q.contains('today') || q.contains('attention') || q.contains('focus') || q.contains('priority')) {
      return const AiFilterIntent(
        priority: TicketPriority.high,
        explanation: "Showing high-urgency tasks requiring attention today",
      );
    }

    // Default: Generic search query
    return AiFilterIntent(
      searchQuery: query.trim(),
      explanation: "Searching for \"$query\"",
    );
  }

  /// Calculates task age in days based on timestamp
  int calculateAgeInDays(int? timestamp) {
    if (timestamp == null || timestamp == 0) return 0;
    try {
      final created = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final difference = DateTime.now().difference(created);
      return difference.inDays.clamp(0, 999);
    } catch (_) {
      return 0;
    }
  }

  /// Evaluates risk score based on age, priority, topic, and status
  TaskRiskLevel calculateRisk(TicketRaised ticket) {
    if (ticket.isResolved == true) return TaskRiskLevel.low;

    final age = calculateAgeInDays(ticket.date);
    final priority = TicketPriority.fromString(ticket.priority ?? ticket.topic);
    final text = "${ticket.topic ?? ''} ${ticket.description ?? ''}".toLowerCase();

    final isCriticalTopic = text.contains('payment') ||
        text.contains('refund') ||
        text.contains('cannot play') ||
        text.contains('charged') ||
        text.contains('crash') ||
        text.contains('blocked');

    if (priority == TicketPriority.high || age >= 5 || (isCriticalTopic && age >= 2)) {
      return TaskRiskLevel.high;
    }
    if (priority == TicketPriority.medium || age >= 3 || isCriticalTopic) {
      return TaskRiskLevel.medium;
    }
    return TaskRiskLevel.low;
  }

  /// Generates a factual 1-2 sentence AI summary based on actual ticket data
  String generateTaskSummary(TicketRaised ticket) {
    final age = calculateAgeInDays(ticket.date);
    final topic = ticket.topic?.trim() ?? 'Support Request';
    final user = ticket.email ?? ticket.mobileNumber ?? 'User';
    final status = KanbanStatus.fromString(ticket.status, isResolved: ticket.isResolved).label;

    final ageText = age == 0 ? "today" : "$age days ago";
    final descSnippet = (ticket.description ?? '').trim();

    if (ticket.isResolved == true) {
      return "Ticket #$topic raised by $user was resolved. Resolution: ${ticket.feedback?.isNotEmpty == true ? ticket.feedback : 'Standard resolution complete'}.";
    }

    if (descSnippet.isNotEmpty) {
      return "$topic reported by $user ($ageText). Current Status: $status. Note: $descSnippet";
    }

    return "$topic reported by $user ($ageText). Currently awaiting action in $status.";
  }

  /// Generates domain-aware suggested next action
  String getSuggestedNextAction(TicketRaised ticket) {
    if (ticket.isResolved == true) {
      return "No action required. Task is resolved.";
    }

    final text = "${ticket.topic ?? ''} ${ticket.description ?? ''}".toLowerCase();

    if (text.contains('payment') || text.contains('billing') || text.contains('charge') || text.contains('subscription')) {
      return "Inspect payment gateway transaction webhook and verify user subscription entitlement in the database.";
    }
    if (text.contains('stream') || text.contains('play') || text.contains('buffer') || text.contains('lag') || text.contains('video')) {
      return "Verify CDN media delivery URL, HLS manifest availability, and DRM token validity for the content.";
    }
    if (text.contains('login') || text.contains('auth') || text.contains('password') || text.contains('otp')) {
      return "Check user authentication status, verification logs, and send a direct password/OTP reset assistance.";
    }
    if (text.contains('subtitle') || text.contains('audio') || text.contains('language')) {
      return "Inspect the content's subtitle/audio track configuration in Admin Content Management.";
    }

    return "Review ticket query details, diagnose root cause, and reply with resolution guidance to ${ticket.email ?? 'the customer'}.";
  }

  /// Generates actionable breakdown steps for complex support tickets
  List<String> decomposeTask(TicketRaised ticket) {
    final text = "${ticket.topic ?? ''} ${ticket.description ?? ''}".toLowerCase();

    if (text.contains('payment') || text.contains('billing') || text.contains('refund') || text.contains('subscription')) {
      return [
        "1. Check payment gateway logs & transaction ID",
        "2. Verify bank response & webhook status",
        "3. Check user wallet/subscription record in DB",
        "4. Manually activate entitlement or issue refund",
        "5. Notify customer & confirm resolution",
      ];
    }

    if (text.contains('play') || text.contains('stream') || text.contains('video') || text.contains('buffer')) {
      return [
        "1. Reproduce video playback on target platform/device",
        "2. Check HLS stream manifest and CDN edge cache",
        "3. Validate DRM licensing and signed cookie token",
        "4. Apply stream encoding or CDN purge fix",
        "5. Verify playback & close ticket",
      ];
    }

    if (text.contains('login') || text.contains('auth') || text.contains('account') || text.contains('otp')) {
      return [
        "1. Check user account active status & roles",
        "2. Inspect authentication & SMS/Email gateway logs",
        "3. Send password/session reset or verify phone number",
        "4. Confirm user can log in successfully",
      ];
    }

    // Default General Breakdown
    return [
      "1. Review customer request and error details",
      "2. Diagnose backend or content configuration root cause",
      "3. Apply required system or account adjustment",
      "4. Send resolution response to customer",
      "5. Mark ticket as Resolved",
    ];
  }

  /// Smart follow-up recommendation when resolving or reviewing
  String getFollowUpRecommendation(TicketRaised ticket, KanbanStatus newStatus) {
    if (newStatus == KanbanStatus.done) {
      return "Resolution note: Issue diagnosed and resolved. Confirmation sent to ${ticket.email ?? 'customer'}.";
    }
    if (newStatus == KanbanStatus.inReview) {
      return "Status note: Initial diagnosis completed. Awaiting user/qa verification.";
    }
    return "Status note: Task placed in To-Do queue.";
  }
}

import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/ui/pages/help_desk_page/models/kanban_status.dart';
import 'package:admin_ott/data/models/response/getRaisedTicketListResponse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KanbanStatus & Priority Tests', () {
    test('maps resolved flag and string statuses correctly', () {
      expect(KanbanStatus.fromString(null, isResolved: true), KanbanStatus.done);
      expect(KanbanStatus.fromString('RESOLVED', isResolved: false), KanbanStatus.done);
      expect(KanbanStatus.fromString('DONE', isResolved: false), KanbanStatus.done);
      expect(KanbanStatus.fromString('IN_REVIEW', isResolved: false), KanbanStatus.inReview);
      expect(KanbanStatus.fromString('TODO', isResolved: false), KanbanStatus.todo);
      expect(KanbanStatus.fromString('IN_PROGRESS', isResolved: false), KanbanStatus.todo);
      expect(KanbanStatus.fromString('RANDOM_STATUS', isResolved: false), KanbanStatus.todo);
      expect(KanbanStatus.fromString(null, isResolved: false), KanbanStatus.todo);
    });

    test('maps ticket priorities', () {
      expect(TicketPriority.fromString('HIGH'), TicketPriority.high);
      expect(TicketPriority.fromString('URGENT'), TicketPriority.high);
      expect(TicketPriority.fromString('LOW'), TicketPriority.low);
      expect(TicketPriority.fromString('MEDIUM'), TicketPriority.medium);
      expect(TicketPriority.fromString(null), TicketPriority.medium);
    });
  });

  group('TicketRaised Parsing & copyWith Tests', () {
    test('parses json with various field types safely', () {
      final json = {
        "tickedId": 101,
        "topic": "Streaming Lag",
        "description": "Video pauses every few seconds",
        "email": "user@example.com",
        "mobileNumber": "9876543210",
        "isResolved": false,
        "status": "TODO",
        "priority": "HIGH",
        "date": 1700000000000,
        "feedback": "Investigating server logs",
        "image": "https://example.com/screenshot.png",
      };

      final ticket = TicketRaised.fromJson(json);
      expect(ticket.tickedId, 101);
      expect(ticket.topic, "Streaming Lag");
      expect(ticket.isResolved, false);
      expect(ticket.status, "TODO");
      expect(ticket.priority, "HIGH");

      final updated = ticket.copyWith(
        isResolved: true,
        status: "DONE",
        feedback: "Resolved via CDN cache purge",
      );

      expect(updated.tickedId, 101);
      expect(updated.isResolved, true);
      expect(updated.status, "DONE");
      expect(updated.feedback, "Resolved via CDN cache purge");
    });
  });

  group('TicketProvider Filtering & Kanban State Tests', () {
    test('filters tickets by search query, priority, and status counts', () {
      final provider = TicketProvider();

      final t1 = TicketRaised(
        tickedId: 1,
        topic: "Audio Out of Sync",
        description: "Movie audio is delayed by 2 seconds",
        email: "alice@example.com",
        mobileNumber: "1111111111",
        isResolved: false,
        status: "TODO",
        priority: "HIGH",
      );

      final t2 = TicketRaised(
        tickedId: 2,
        topic: "Subscription Billing Failed",
        description: "Card charged but account not upgraded",
        email: "bob@example.com",
        mobileNumber: "2222222222",
        isResolved: false,
        status: "TODO",
        priority: "MEDIUM",
      );

      final t3 = TicketRaised(
        tickedId: 3,
        topic: "Subtitle Typography Request",
        description: "Need larger yellow font for subtitles",
        email: "charlie@example.com",
        mobileNumber: "3333333333",
        isResolved: false,
        status: "IN_REVIEW",
        priority: "LOW",
      );

      final t4 = TicketRaised(
        tickedId: 4,
        topic: "Password Reset Request",
        description: "Reset link expired",
        email: "david@example.com",
        mobileNumber: "4444444444",
        isResolved: true,
        status: "DONE",
        priority: "LOW",
      );

      provider.tickets.addAll([t1, t2, t3, t4]);

      // Verify Column Counts
      expect(provider.getCountForStatus(KanbanStatus.todo), 2);
      expect(provider.getCountForStatus(KanbanStatus.inReview), 1);
      expect(provider.getCountForStatus(KanbanStatus.done), 1);

      // Verify Search Filter
      provider.setSearchQuery("Billing");
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 2);

      // Clear Filters
      provider.clearFilters();
      expect(provider.filteredTickets.length, 4);

      // Verify Priority Filter
      provider.setPriorityFilter(TicketPriority.high);
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 1);
    });

    test('filters tickets by user role and promoter level correctly', () {
      final provider = TicketProvider();

      final tUser = TicketRaised(
        tickedId: 10,
        topic: "User Subscription Issue",
        email: "user@example.com",
        isResolved: false,
        status: "TODO",
        priority: "MEDIUM",
      );

      final tPromoterNational = TicketRaised(
        tickedId: 11,
        topic: "National Level Payout Delay",
        category: "Promoter",
        description: "National Level Promoter commission not credited",
        email: "national_promoter@example.com",
        isResolved: false,
        status: "TODO",
        priority: "HIGH",
      );

      final tPromoterState = TicketRaised(
        tickedId: 12,
        topic: "State Level Registration Error",
        category: "Promoter",
        description: "State Level promoter onboarding link broken",
        email: "state_promoter@example.com",
        isResolved: false,
        status: "IN_REVIEW",
        priority: "MEDIUM",
      );

      final tPromoterDistrict = TicketRaised(
        tickedId: 13,
        topic: "District Promoter Referral Tracking",
        category: "Promoter",
        description: "District level referral code stats missing",
        email: "district_promoter@example.com",
        isResolved: false,
        status: "TODO",
        priority: "LOW",
      );

      final tAdmin = TicketRaised(
        tickedId: 14,
        topic: "Admin Server Alert",
        category: "Admin",
        description: "Admin panel high load alert",
        email: "admin@example.com",
        isResolved: true,
        status: "DONE",
        priority: "HIGH",
      );

      provider.tickets.addAll([
        tUser,
        tPromoterNational,
        tPromoterState,
        tPromoterDistrict,
        tAdmin,
      ]);

      // 1. Filter by PROMOTER role
      provider.setUserRoleFilter('PROMOTER');
      expect(provider.filteredTickets.length, 3);
      expect(provider.filteredTickets.map((t) => t.tickedId).toList(), [11, 12, 13]);

      // 2. Filter by Promoter Level: National
      provider.setPromoterLevelFilter('National');
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 11);

      // 3. Filter by Promoter Level: State
      provider.setPromoterLevelFilter('State');
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 12);

      // 4. Filter by Promoter Level: District
      provider.setPromoterLevelFilter('District');
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 13);

      // 5. Switching role to USER should reset promoter level filter
      provider.setUserRoleFilter('USER');
      expect(provider.promoterLevelFilter, null);
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 10);

      // 6. Filter by ADMIN role
      provider.setUserRoleFilter('ADMIN');
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 14);

      // 7. Clear all filters
      provider.clearFilters();
      expect(provider.userRoleFilter, null);
      expect(provider.promoterLevelFilter, null);
      expect(provider.filteredTickets.length, 5);
    });

    test('filters tickets datewise and combines with keyword search', () {
      final provider = TicketProvider();

      final day1 = DateTime(2026, 8, 1).millisecondsSinceEpoch;
      final day10 = DateTime(2026, 8, 10).millisecondsSinceEpoch;
      final day20 = DateTime(2026, 8, 20).millisecondsSinceEpoch;

      final t1 = TicketRaised(
        tickedId: 101,
        topic: "Early August Ticket",
        description: "Playback error on Episode 1",
        email: "user1@example.com",
        date: day1,
      );

      final t2 = TicketRaised(
        tickedId: 102,
        topic: "Mid August Ticket",
        description: "Promoter payment query",
        email: "promoter@example.com",
        date: day10,
      );

      final t3 = TicketRaised(
        tickedId: 103,
        topic: "Late August Ticket",
        description: "Playback buffer issue",
        email: "user3@example.com",
        date: day20,
      );

      provider.tickets.addAll([t1, t2, t3]);

      // 1. Date range: 5 Aug to 15 Aug -> should only match t2
      provider.setDateRange(DateTime(2026, 8, 5), DateTime(2026, 8, 15));
      expect(provider.filteredTickets.length, 1);
      expect(provider.filteredTickets.first.tickedId, 102);

      // 2. Date range: 1 Aug to 20 Aug + Keyword search: "Playback" -> should match t1 and t3
      provider.setDateRange(DateTime(2026, 8, 1), DateTime(2026, 8, 20));
      provider.setSearchQuery("Playback");
      expect(provider.filteredTickets.length, 2);
      expect(provider.filteredTickets.map((t) => t.tickedId).toList(), [101, 103]);

      // 3. Clear filters
      provider.clearFilters();
      expect(provider.startDate, null);
      expect(provider.endDate, null);
      expect(provider.searchQuery, '');
      expect(provider.filteredTickets.length, 3);
    });

    test('sendReplyToTicket validates against empty reply', () async {
      final provider = TicketProvider();
      final ticket = TicketRaised(tickedId: 5, topic: "Help needed", isResolved: false);

      final emptyResult = await provider.sendReplyToTicket(ticket, "   ");
      expect(emptyResult['success'], false);
      expect(emptyResult['message'], 'Reply message cannot be empty');
    });
  });
}

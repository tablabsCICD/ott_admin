import 'package:flutter/material.dart';

enum KanbanStatus {
  todo,
  inReview,
  done;

  String get label {
    switch (this) {
      case KanbanStatus.todo:
        return 'To Do';
      case KanbanStatus.inReview:
        return 'In Review';
      case KanbanStatus.done:
        return 'Done';
    }
  }

  String get code {
    switch (this) {
      case KanbanStatus.todo:
        return 'TODO';
      case KanbanStatus.inReview:
        return 'IN_REVIEW';
      case KanbanStatus.done:
        return 'DONE';
    }
  }

  Color get color {
    switch (this) {
      case KanbanStatus.todo:
        return const Color(0xFF64748B); // Slate Blue/Grey
      case KanbanStatus.inReview:
        return const Color(0xFFF59E0B); // Amber / Orange
      case KanbanStatus.done:
        return const Color(0xFF10B981); // Green
    }
  }

  IconData get icon {
    switch (this) {
      case KanbanStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case KanbanStatus.inReview:
        return Icons.rate_review_outlined;
      case KanbanStatus.done:
        return Icons.check_circle_rounded;
    }
  }

  static KanbanStatus fromString(dynamic value, {bool? isResolved}) {
    if (isResolved == true) {
      return KanbanStatus.done;
    }
    if (value == null) {
      return KanbanStatus.todo;
    }
    final str = value.toString().trim().toUpperCase().replaceAll(' ', '_');
    if (str == 'DONE' || str == 'RESOLVED' || str == 'SOLVED' || str == 'CLOSED') {
      return KanbanStatus.done;
    }
    if (str == 'IN_REVIEW' || str == 'INREVIEW' || str == 'UNDER_REVIEW' || str == 'REVIEW') {
      return KanbanStatus.inReview;
    }
    return KanbanStatus.todo;
  }
}

enum TicketPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.low:
        return const Color(0xFF10B981);
      case TicketPriority.medium:
        return const Color(0xFFF59E0B);
      case TicketPriority.high:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case TicketPriority.low:
        return Icons.arrow_downward_rounded;
      case TicketPriority.medium:
        return Icons.drag_handle_rounded;
      case TicketPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }

  static TicketPriority fromString(dynamic value) {
    if (value == null) return TicketPriority.medium;
    final str = value.toString().trim().toUpperCase();
    if (str.contains('HIGH') || str.contains('URGENT') || str.contains('CRITICAL')) {
      return TicketPriority.high;
    }
    if (str.contains('LOW')) {
      return TicketPriority.low;
    }
    return TicketPriority.medium;
  }
}

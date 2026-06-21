class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetAudience,
    required this.sentBy,
    required this.createdAt,
    required this.status,
    required this.recipientCount,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final String targetAudience;
  final String sentBy;
  final DateTime? createdAt;
  final String status;
  final int recipientCount;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _stringValue(json['id'] ??
          json['notificationId'] ??
          json['notification_id'] ??
          json['_id']),
      title: _stringValue(json['title'] ?? json['notificationTitle']),
      message: _stringValue(json['message'] ??
          json['body'] ??
          json['description'] ??
          json['messageDescription'] ??
          json['notificationMessage']),
      type: _stringValue(
          json['type'] ?? json['notificationType'] ?? json['category'],
          fallback: 'General'),
      targetAudience: _stringValue(
          json['targetAudience'] ??
              json['audience'] ??
              json['target'] ??
              json['recipientType'] ??
              json['sentTo'],
          fallback: 'All Users'),
      sentBy: _stringValue(
          json['sentBy'] ??
              json['createdBy'] ??
              json['senderName'] ??
              json['adminName'],
          fallback: 'Admin'),
      createdAt: _dateValue(json['createdAt'] ??
          json['createdDate'] ??
          json['createdDateTime'] ??
          json['sentDateTime'] ??
          json['sentAt']),
      status: _normalizeStatus(json['status'] ?? json['deliveryStatus']),
      recipientCount: _intValue(json['recipientCount'] ??
          json['totalRecipients'] ??
          json['userCount'] ??
          json['deliveredCount']),
    );
  }

  bool matchesSearch(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return true;
    return title.toLowerCase().contains(value) ||
        message.toLowerCase().contains(value);
  }

  bool isWithin(DateTime? start, DateTime? end) {
    if (createdAt == null) return start == null && end == null;
    final created = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    if (start != null) {
      final startDate = DateTime(start.year, start.month, start.day);
      if (created.isBefore(startDate)) return false;
    }
    if (end != null) {
      final endDate = DateTime(end.year, end.month, end.day);
      if (created.isAfter(endDate)) return false;
    }
    return true;
  }

  String get messagePreview {
    final clean = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= 90) return clean;
    return '${clean.substring(0, 90)}...';
  }
}

class NotificationPageResult {
  const NotificationPageResult({
    required this.notifications,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<NotificationModel> notifications;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final int pageSize;

  factory NotificationPageResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final page = data is Map<String, dynamic> ? data : json;
    final notifications = extractNotificationList(json)
        .map(NotificationModel.fromJson)
        .toList(growable: false);

    return NotificationPageResult(
      notifications: notifications,
      totalElements: _intValue(page['totalElements'] ?? notifications.length),
      totalPages: _intValue(page['totalPages'] ?? 1),
      pageNumber: _intValue(page['number'] ?? page['pageNumber']),
      pageSize: _intValue(page['size'] ?? page['pageSize']),
    );
  }
}

List<Map<String, dynamic>> extractNotificationList(Map<String, dynamic> json) {
  final dynamic raw = json['data'] ??
      json['notifications'] ??
      json['notificationList'] ??
      json['content'] ??
      json['items'] ??
      json;

  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  if (raw is Map) {
    final nested = raw['notifications'] ??
        raw['notificationList'] ??
        raw['content'] ??
        raw['items'] ??
        raw['data'];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }

  return const [];
}

String notificationResponseMessage(Map<String, dynamic> json, String fallback) {
  return json['message']?.toString() ?? fallback;
}

bool notificationResponseSuccess(Map<String, dynamic> json) {
  final value = json['success'] ?? json['status'];
  if (value == null) return true;
  if (value is bool) return value;
  return value.toString().toLowerCase() == 'true';
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _dateValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return DateTime.tryParse(value.toString());
}

String _normalizeStatus(dynamic value) {
  final status = value?.toString().trim();
  if (status == null || status.isEmpty) return 'Pending';
  final lower = status.toLowerCase();
  if (lower == 'sent' ||
      lower == 'success' ||
      lower == 'delivered' ||
      lower == 'delivery_success') {
    return 'Sent';
  }
  if (lower == 'failed' || lower == 'failure') return 'Failed';
  if (lower == 'pending' || lower == 'queued') return 'Pending';
  return status;
}

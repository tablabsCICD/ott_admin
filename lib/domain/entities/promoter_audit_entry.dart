class PromoterAuditEntry {
  final String id;
  final int promoterId;
  final String promoterName;
  final String actionType; // 'CREATE', 'EDIT_PROFILE', 'CHANGE_LEVEL', 'ASSIGN_PARENT', 'CHANGE_STATUS'
  final String description;
  final String? previousValue;
  final String? newValue;
  final String performedBy;
  final DateTime timestamp;

  PromoterAuditEntry({
    required this.id,
    required this.promoterId,
    required this.promoterName,
    required this.actionType,
    required this.description,
    this.previousValue,
    this.newValue,
    this.performedBy = 'Admin',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'promoterId': promoterId,
        'promoterName': promoterName,
        'actionType': actionType,
        'description': description,
        'previousValue': previousValue,
        'newValue': newValue,
        'performedBy': performedBy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PromoterAuditEntry.fromJson(Map<String, dynamic> json) =>
      PromoterAuditEntry(
        id: json['id'] ?? '',
        promoterId: json['promoterId'] ?? 0,
        promoterName: json['promoterName'] ?? '',
        actionType: json['actionType'] ?? 'UPDATE',
        description: json['description'] ?? '',
        previousValue: json['previousValue'],
        newValue: json['newValue'],
        performedBy: json['performedBy'] ?? 'Admin',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
      );
}

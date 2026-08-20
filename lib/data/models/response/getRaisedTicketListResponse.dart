

import '../../../domain/entities/user.dart';

class GetRaiseTicketListResponse {
  Data? data;
  String? message;
  int? status;

  GetRaiseTicketListResponse({
    this.data,
    this.message,
    this.status,
  });

  factory GetRaiseTicketListResponse.fromJson(Map<String, dynamic> json) => GetRaiseTicketListResponse(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "message": message,
    "status": status,
  };
}

class Data {
  List<TicketRaised>? ticketRaised;

  Data({
    this.ticketRaised,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ticketRaised: json["TicketRaised"] == null ? [] : List<TicketRaised>.from(json["TicketRaised"]!.map((x) => TicketRaised.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "TicketRaised": ticketRaised == null ? [] : List<dynamic>.from(ticketRaised!.map((x) => x.toJson())),
  };
}

class TicketRaised {
  int? tickedId;
  String? topic;
  String? mobileNumber;
  String? email;
  User? user;
  int? userId;
  int? date;
  String? feedback;
  String? image;
  String? description;
  bool? isResolved;
  String? status;
  String? priority;
  String? category;
  String? assignedTo;

  TicketRaised({
    this.tickedId,
    this.topic,
    this.mobileNumber,
    this.email,
    this.user,
    this.userId,
    this.date,
    this.feedback,
    this.image,
    this.description,
    this.isResolved,
    this.status,
    this.priority,
    this.category,
    this.assignedTo,
  });

  TicketRaised copyWith({
    int? tickedId,
    String? topic,
    String? mobileNumber,
    String? email,
    User? user,
    int? userId,
    int? date,
    String? feedback,
    String? image,
    String? description,
    bool? isResolved,
    String? status,
    String? priority,
    String? category,
    String? assignedTo,
  }) {
    return TicketRaised(
      tickedId: tickedId ?? this.tickedId,
      topic: topic ?? this.topic,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      user: user ?? this.user,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      feedback: feedback ?? this.feedback,
      image: image ?? this.image,
      description: description ?? this.description,
      isResolved: isResolved ?? this.isResolved,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  factory TicketRaised.fromJson(Map<String, dynamic> json) {
    int? parsedDate;
    final rawDate = json["date"] ?? json["createdAt"] ?? json["createdDate"];
    if (rawDate is int) {
      parsedDate = rawDate;
    } else if (rawDate != null) {
      final asInt = int.tryParse(rawDate.toString());
      if (asInt != null) {
        parsedDate = asInt;
      } else {
        parsedDate = DateTime.tryParse(rawDate.toString())?.millisecondsSinceEpoch;
      }
    }

    final rawId = json["tickedId"] ?? json["ticketId"] ?? json["id"];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    final rawResolved = json["isResolved"] ?? json["resolved"] ?? json["isSolved"];
    final parsedResolved = rawResolved is bool
        ? rawResolved
        : (rawResolved?.toString().toLowerCase() == 'true' || rawResolved == 1);

    return TicketRaised(
      tickedId: parsedId,
      topic: json["topic"] ?? json["title"] ?? json["subject"],
      mobileNumber: json["mobileNumber"] ?? json["phone"] ?? json["mobile"],
      email: json["email"] ?? json["emailId"] ?? json["userEmail"],
      user: json["user"] == null
          ? null
          : (json["user"] is Map<String, dynamic>
              ? User.fromJson(json["user"])
              : (json["user"] is Map ? User.fromJson(Map<String, dynamic>.from(json["user"])) : null)),
      userId: json["userId"] is int ? json["userId"] : int.tryParse(json["userId"]?.toString() ?? ''),
      date: parsedDate,
      feedback: json["feedback"] ?? json["resolution"] ?? json["response"] ?? json["adminFeedback"],
      image: json["image"] ?? json["imageUrl"] ?? json["attachment"],
      description: json["description"] ?? json["query"] ?? json["message"],
      isResolved: parsedResolved,
      status: json["status"]?.toString(),
      priority: json["priority"]?.toString(),
      category: json["category"]?.toString(),
      assignedTo: json["assignedTo"]?.toString() ?? json["assignedUser"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "tickedId": tickedId,
    "topic": topic,
    "mobileNumber": mobileNumber,
    "email": email,
    "user": user?.toJson(),
    "userId": userId,
    "date": date,
    "feedback": feedback,
    "image": image,
    "description": description,
    "isResolved": isResolved,
    if (status != null) "status": status,
    if (priority != null) "priority": priority,
    if (category != null) "category": category,
    if (assignedTo != null) "assignedTo": assignedTo,
  };
}

class RaiseTicketRequest {
  String? date;
  String? description;
  String? email;
  String? feedback;
  String? image;
  bool? isResolved;
  String? mobileNumber;
  int? tickedId;
  String? topic;
  int? userId;

  RaiseTicketRequest({
    this.date,
    this.description,
    this.email,
    this.feedback,
    this.image,
    this.isResolved,
    this.mobileNumber,
    this.tickedId,
    this.topic,
    this.userId,
  });

  factory RaiseTicketRequest.fromJson(Map<String, dynamic> json) => RaiseTicketRequest(
    date: json["date"],
    description: json["description"],
    email: json["email"],
    feedback: json["feedback"],
    image: json["image"],
    isResolved: json["isResolved"],
    mobileNumber: json["mobileNumber"],
    tickedId: json["tickedId"],
    topic: json["topic"],
    userId: json["userId"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "description": description,
    "email": email,
    "feedback": feedback,
    "image": image,
    "isResolved": isResolved,
    "mobileNumber": mobileNumber,
    "tickedId": tickedId,
    "topic": topic,
    "userId": userId,
  };
}

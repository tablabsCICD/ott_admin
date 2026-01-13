class PercentageRequest {
  int? contentList;
  String? date;
  int? id;
  bool? isActive;
  int? mediaHouse;
  double? percentageAdmin;
  double? percentageMediaHouse;
  double? ticketRate;

  PercentageRequest({
    this.contentList,
    this.date,
    this.id,
    this.isActive,
    this.mediaHouse,
    this.percentageAdmin,
    this.percentageMediaHouse,
    this.ticketRate,
  });

  factory PercentageRequest.fromJson(Map<String, dynamic> json) => PercentageRequest(
    contentList: json["contentList"],
    date: json["date"],
    id: json["id"],
    isActive: json["isActive"],
    mediaHouse: json["mediaHouse"],
    percentageAdmin: json["percentageAdmin"],
    percentageMediaHouse: json["percentageMediaHouse"],
    ticketRate: json["ticketRate"],
  );

  Map<String, dynamic> toJson() => {
    "contentList": contentList,
    "date": date,
    "id": id,
    "isActive": isActive,
    "mediaHouse": mediaHouse,
    "percentageAdmin": percentageAdmin,
    "percentageMediaHouse": percentageMediaHouse,
    "ticketRate": ticketRate,
  };
}

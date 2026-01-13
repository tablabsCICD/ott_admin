class SaveAccessControlRequest {
  bool? helpDesk;
  int? id;
  bool? manageContent;
  bool? manageMediaHouse;
  bool? manageTrasaction;
  bool? manageUser;
  String? promoterLevel;

  SaveAccessControlRequest({
    this.helpDesk,
    this.id,
    this.manageContent,
    this.manageMediaHouse,
    this.manageTrasaction,
    this.manageUser,
    this.promoterLevel,
  });

  factory SaveAccessControlRequest.fromJson(Map<String, dynamic> json) => SaveAccessControlRequest(
    helpDesk: json["helpDesk"],
    id: json["id"],
    manageContent: json["manageContent"],
    manageMediaHouse: json["manageMediaHouse"],
    manageTrasaction: json["manageTrasaction"],
    manageUser: json["manageUser"],
    promoterLevel: json["promoterLevel"],
  );

  Map<String, dynamic> toJson() => {
    "helpDesk": helpDesk,
    "id": id,
    "manageContent": manageContent,
    "manageMediaHouse": manageMediaHouse,
    "manageTrasaction": manageTrasaction,
    "manageUser": manageUser,
    "promoterLevel": promoterLevel,
  };
}

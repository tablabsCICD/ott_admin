class UserOnboardAndRevenueGraph {
  List<PromoterUserRevenueGraph>? data;
  String? message;
  int? statusCode;
  bool? isSuccess;

  UserOnboardAndRevenueGraph({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
  });

  factory UserOnboardAndRevenueGraph.fromJson(Map<String, dynamic> json) => UserOnboardAndRevenueGraph(
    data: json["data"] == null ? [] : List<PromoterUserRevenueGraph>.from(json["data"]!.map((x) => PromoterUserRevenueGraph.fromJson(x))),
    message: json["message"],
    statusCode: json["statusCode"],
    isSuccess: json["isSuccess"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "statusCode": statusCode,
    "isSuccess": isSuccess,
  };
}

class PromoterUserRevenueGraph {
  String? date;
  double? revenue;
  int? usersOnboarded;

  PromoterUserRevenueGraph({
    this.date,
    this.revenue,
    this.usersOnboarded,
  });

  factory PromoterUserRevenueGraph.fromJson(Map<String, dynamic> json) => PromoterUserRevenueGraph(
    date: json["date"]??'',
    revenue: json["revenue"],
    usersOnboarded: json["users_onboarded"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "revenue": revenue,
    "users_onboarded": usersOnboarded,
  };
}

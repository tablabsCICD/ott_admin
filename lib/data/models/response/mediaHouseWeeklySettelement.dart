class MediaHouseWeeklySattelment {
  String? message;
  List<WeeklySettelementData>? data;
  bool? success;

  MediaHouseWeeklySattelment({
    this.message,
    this.data,
    this.success,
  });

  factory MediaHouseWeeklySattelment.fromJson(Map<String, dynamic> json) => MediaHouseWeeklySattelment(
    message: json["message"],
    data: json["data"] == null ? [] : List<WeeklySettelementData>.from(json["data"]!.map((x) => WeeklySettelementData.fromJson(x))),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "success": success,
  };
}

class WeeklySettelementData {
  dynamic transactionId;
  int? startDate;
  int? endDate;
  int? grossRevenue;
  int? taxDeduction;
  int? netRevenue;
  int? ottPlatformSharePercentage;
  int? ottPlatformRevenueShare;
  int? mediaHouseSharePercentage;
  int? mediaHouseRevenueShare;
  int? totalPurchases;
  int? totalUniqueMoviesSold;
  ListOfMoviesSold? listOfMoviesSold;
  String? mostPurchasedMovie;

  WeeklySettelementData({
    this.transactionId,
    this.startDate,
    this.endDate,
    this.grossRevenue,
    this.taxDeduction,
    this.netRevenue,
    this.ottPlatformSharePercentage,
    this.ottPlatformRevenueShare,
    this.mediaHouseSharePercentage,
    this.mediaHouseRevenueShare,
    this.totalPurchases,
    this.totalUniqueMoviesSold,
    this.listOfMoviesSold,
    this.mostPurchasedMovie,
  });

  factory WeeklySettelementData.fromJson(Map<String, dynamic> json) => WeeklySettelementData(
    transactionId: json["transactionId"],
    startDate: json["startDate"],
    endDate: json["endDate"],
    grossRevenue: json["grossRevenue"],
    taxDeduction: json["taxDeduction"],
    netRevenue: json["netRevenue"],
    ottPlatformSharePercentage: json["ottPlatformSharePercentage"],
    ottPlatformRevenueShare: json["ottPlatformRevenueShare"],
    mediaHouseSharePercentage: json["mediaHouseSharePercentage"],
    mediaHouseRevenueShare: json["mediaHouseRevenueShare"],
    totalPurchases: json["totalPurchases"],
    totalUniqueMoviesSold: json["totalUniqueMoviesSold"],
    listOfMoviesSold: json["listOfMoviesSold"] == null ? null : ListOfMoviesSold.fromJson(json["listOfMoviesSold"]),
    mostPurchasedMovie: json["mostPurchasedMovie"],
  );

  Map<String, dynamic> toJson() => {
    "transactionId": transactionId,
    "startDate": startDate,
    "endDate": endDate,
    "grossRevenue": grossRevenue,
    "taxDeduction": taxDeduction,
    "netRevenue": netRevenue,
    "ottPlatformSharePercentage": ottPlatformSharePercentage,
    "ottPlatformRevenueShare": ottPlatformRevenueShare,
    "mediaHouseSharePercentage": mediaHouseSharePercentage,
    "mediaHouseRevenueShare": mediaHouseRevenueShare,
    "totalPurchases": totalPurchases,
    "totalUniqueMoviesSold": totalUniqueMoviesSold,
    "listOfMoviesSold": listOfMoviesSold?.toJson(),
    "mostPurchasedMovie": mostPurchasedMovie,
  };
}

class ListOfMoviesSold {
  int? movie1;
  int? movie2;
  int? movie3;
  int? movie4;

  ListOfMoviesSold({
    this.movie1,
    this.movie2,
    this.movie3,
    this.movie4,
  });

  factory ListOfMoviesSold.fromJson(Map<String, dynamic> json) => ListOfMoviesSold(
    movie1: json["Movie1"],
    movie2: json["Movie2"],
    movie3: json["Movie3"],
    movie4: json["Movie4"],
  );

  Map<String, dynamic> toJson() => {
    "Movie1": movie1,
    "Movie2": movie2,
    "Movie3": movie3,
    "Movie4": movie4,
  };

  // Add this getter to expose the properties as entries
  Map<String, int?> get entries => {
    "Movie1": movie1,
    "Movie2": movie2,
    "Movie3": movie3,
    "Movie4": movie4,
  };
}

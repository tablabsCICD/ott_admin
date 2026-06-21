class MediaHouseWeeklySattelment {
  String? message;
  List<WeeklySettelementData>? data;
  bool? success;

  MediaHouseWeeklySattelment({
    this.message,
    this.data,
    this.success,
  });

  factory MediaHouseWeeklySattelment.fromJson(Map<String, dynamic> json) =>
      MediaHouseWeeklySattelment(
        message: json["message"],
        data: _readSettlementList(json),
        success: json["success"] == true ||
            json["status"]?.toString().toLowerCase() == "success",
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
      };
}

List<WeeklySettelementData> _readSettlementList(Map<String, dynamic> json) {
  final rawData = json["data"] ?? json["settlementsList"] ?? json["content"];
  if (rawData is List) {
    return rawData
        .whereType<Map<String, dynamic>>()
        .map(WeeklySettelementData.fromJson)
        .toList();
  }
  if (rawData is Map<String, dynamic>) {
    final nested =
        rawData["content"] ?? rawData["settlementsList"] ?? rawData["data"];
    if (nested is List) {
      return nested
          .whereType<Map<String, dynamic>>()
          .map(WeeklySettelementData.fromJson)
          .toList();
    }
  }
  return [];
}

class WeeklySettelementData {
  dynamic transactionId;
  int? startDate;
  int? endDate;
  double? grossRevenue;
  double? taxDeduction;
  double? netRevenue;
  double? ottPlatformSharePercentage;
  double? ottPlatformRevenueShare;
  double? mediaHouseSharePercentage;
  double? mediaHouseRevenueShare;
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

  factory WeeklySettelementData.fromJson(Map<String, dynamic> json) =>
      WeeklySettelementData(
        transactionId: json["transactionId"] ?? json["TransactionId"],
        startDate: _readEpoch(json["startDate"] ?? json["StartDate"]),
        endDate: _readEpoch(json["endDate"] ?? json["EndDate"]),
        grossRevenue: _readDouble(json["grossRevenue"] ?? json["GrossRevenue"]),
        taxDeduction: _readDouble(json["taxDeduction"] ?? json["TaxDeduction"]),
        netRevenue: _readDouble(json["netRevenue"] ?? json["NetRevenue"]),
        ottPlatformSharePercentage: _readDouble(
          json["ottPlatformSharePercentage"] ?? json["OTTPlatformShare%"],
        ),
        ottPlatformRevenueShare: _readDouble(
          json["ottPlatformRevenueShare"] ?? json["OTTPlatformRevenueShare"],
        ),
        mediaHouseSharePercentage: _readDouble(
          json["mediaHouseSharePercentage"] ?? json["MediaHouseShare%"],
        ),
        mediaHouseRevenueShare: _readDouble(
          json["mediaHouseRevenueShare"] ?? json["MediaHouseRevenueShare"],
        ),
        totalPurchases:
            _readInt(json["totalPurchases"] ?? json["TotalPurchases"]),
        totalUniqueMoviesSold: _readInt(
          json["totalUniqueMoviesSold"] ?? json["TotalUniqueMoviesSold"],
        ),
        listOfMoviesSold: (json["listOfMoviesSold"] ??
                    json["ListOfMoviesSold"] ??
                    json["MoviesSold"]) ==
                null
            ? null
            : ListOfMoviesSold.fromJson(
                json["listOfMoviesSold"] ??
                    json["ListOfMoviesSold"] ??
                    json["MoviesSold"],
              ),
        mostPurchasedMovie:
            json["mostPurchasedMovie"] ?? json["MostPurchasedMovie"],
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
  final Map<String, int?> entries;

  ListOfMoviesSold({
    Map<String, int?>? entries,
  }) : entries = entries ?? {};

  factory ListOfMoviesSold.fromJson(Map<String, dynamic> json) {
    return ListOfMoviesSold(
      entries: json.map(
        (key, value) => MapEntry(key, _readInt(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() => entries;
}

int? _readEpoch(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value?.toString();
  if (text == null || text.trim().isEmpty) return null;
  final parsedInt = int.tryParse(text);
  if (parsedInt != null) return parsedInt;
  final parsedDate = DateTime.tryParse(text);
  return parsedDate?.millisecondsSinceEpoch;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

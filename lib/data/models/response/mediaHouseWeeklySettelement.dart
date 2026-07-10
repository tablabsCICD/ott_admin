class MediaHouseWeeklySattelment {
  String? message;
  List<WeeklySettelementData>? data;
  bool? success;

  MediaHouseWeeklySattelment({
    this.message,
    this.data,
    this.success,
  });

  factory MediaHouseWeeklySattelment.fromJson(Map<String, dynamic> json) {
    final settlements = _readSettlementList(json);
    return MediaHouseWeeklySattelment(
      message: json["message"],
      data: settlements,
      success: json["success"] == true ||
          json["status"]?.toString().toLowerCase() == "success" ||
          settlements.isNotEmpty,
    );
  }

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
        .whereType<Map>()
        .map((entry) => WeeklySettelementData.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList();
  }
  if (rawData is Map<String, dynamic>) {
    final nested =
        rawData["content"] ?? rawData["settlementsList"] ?? rawData["data"];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((entry) => WeeklySettelementData.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList();
    }
  }
  return [];
}

class WeeklySettelementData {
  int? id;
  int? userId;
  dynamic transactionId;
  String? typeOfIncentive;
  double? earnedIncentive;
  bool? isDone;
  String? description;
  int? createdDate;
  int? startDate;
  int? endDate;
  String? scheduledSettlementDay;
  String? scheduledSettlementTime;
  String? scheduledSettlementTimezone;
  double? grossRevenue;
  double? taxDeduction;
  double? netRevenue;
  double? gstAmount;
  double? gstRate;
  double? ottPlatformSharePercentage;
  double? ottPlatformRevenueShare;
  double? mediaHouseSharePercentage;
  double? mediaHouseRevenueShare;
  int? totalPurchases;
  int? totalUniqueMoviesSold;
  ListOfMoviesSold? listOfMoviesSold;
  String? mostPurchasedMovie;

  WeeklySettelementData({
    this.id,
    this.userId,
    this.transactionId,
    this.typeOfIncentive,
    this.earnedIncentive,
    this.isDone,
    this.description,
    this.createdDate,
    this.startDate,
    this.endDate,
    this.scheduledSettlementDay,
    this.scheduledSettlementTime,
    this.scheduledSettlementTimezone,
    this.grossRevenue,
    this.taxDeduction,
    this.netRevenue,
    this.gstAmount,
    this.gstRate,
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
        id: _readInt(json["id"] ?? json["Id"]),
        userId: _readInt(json["userId"] ?? json["UserId"]),
        transactionId: json["transactionId"] ?? json["TransactionId"],
        typeOfIncentive: json["typeOfIncentive"] ?? json["TypeOfIncentive"],
        earnedIncentive:
            _readDouble(json["earnedIncentive"] ?? json["EarnedIncentive"]),
        isDone: _readBool(json["isDone"] ?? json["IsDone"]),
        description: json["description"] ?? json["Description"],
        createdDate: _readEpoch(json["createdDate"] ?? json["CreatedDate"]),
        startDate: _readEpoch(json["startDate"] ?? json["StartDate"]),
        endDate: _readEpoch(json["endDate"] ?? json["EndDate"]),
        scheduledSettlementDay:
            json["scheduledSettlementDay"] ?? json["ScheduledSettlementDay"],
        scheduledSettlementTime:
            json["scheduledSettlementTime"] ?? json["ScheduledSettlementTime"],
        scheduledSettlementTimezone: json["scheduledSettlementTimezone"] ??
            json["ScheduledSettlementTimezone"],
        grossRevenue: _readDouble(json["grossRevenue"] ?? json["GrossRevenue"]),
        taxDeduction: _readDouble(json["taxDeduction"] ?? json["TaxDeduction"]),
        netRevenue: _readDouble(json["netRevenue"] ?? json["NetRevenue"]),
        gstAmount: _readDouble(json["gstAmount"] ?? json["GstAmount"]),
        gstRate: _readDouble(json["gstRate"] ?? json["GstRate"]),
        ottPlatformSharePercentage: _readDouble(
          json["ottPlatformSharePercentage"] ??
              json["OTTPlatformSharePercentage"] ??
              json["OTTPlatformShare%"],
        ),
        ottPlatformRevenueShare: _readDouble(
          json["ottPlatformRevenueShare"] ?? json["OTTPlatformRevenueShare"],
        ),
        mediaHouseSharePercentage: _readDouble(
          json["mediaHouseSharePercentage"] ??
              json["MediaHouseSharePercentage"] ??
              json["MediaHouseShare%"],
        ),
        mediaHouseRevenueShare: _readDouble(
          json["mediaHouseRevenueShare"] ?? json["MediaHouseRevenueShare"],
        ),
        totalPurchases:
            _readInt(json["totalPurchases"] ?? json["TotalPurchases"]),
        totalUniqueMoviesSold: _readInt(
          json["totalUniqueMoviesSold"] ?? json["TotalUniqueMoviesSold"],
        ),
        listOfMoviesSold: _readMoviesSold(
          json["listOfMoviesSold"] ??
              json["ListOfMoviesSold"] ??
              json["moviesSold"] ??
              json["MoviesSold"],
        ),
        mostPurchasedMovie:
            json["mostPurchasedMovie"] ?? json["MostPurchasedMovie"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "transactionId": transactionId,
        "typeOfIncentive": typeOfIncentive,
        "earnedIncentive": earnedIncentive,
        "isDone": isDone,
        "description": description,
        "createdDate": createdDate,
        "startDate": startDate,
        "endDate": endDate,
        "scheduledSettlementDay": scheduledSettlementDay,
        "scheduledSettlementTime": scheduledSettlementTime,
        "scheduledSettlementTimezone": scheduledSettlementTimezone,
        "grossRevenue": grossRevenue,
        "taxDeduction": taxDeduction,
        "netRevenue": netRevenue,
        "gstAmount": gstAmount,
        "gstRate": gstRate,
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

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase().trim();
  if (text == "true" || text == "1") return true;
  if (text == "false" || text == "0") return false;
  return null;
}

ListOfMoviesSold? _readMoviesSold(dynamic value) {
  if (value == null) return null;
  if (value is ListOfMoviesSold) return value;
  if (value is Map) {
    return ListOfMoviesSold.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

class MediaHouseDashboardCount {
  MediaHouseDashboardData? data;
  String? message;
  int? statusCode;
  bool? isSuccess;
  dynamic total;
  dynamic totalViews;
  dynamic totalLikes;
  dynamic totalRevenue;

  MediaHouseDashboardCount({
    this.data,
    this.message,
    this.statusCode,
    this.isSuccess,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
  });

  factory MediaHouseDashboardCount.fromJson(Map<String, dynamic> json) =>
      MediaHouseDashboardCount(
        data: json["data"] == null
            ? null
            : MediaHouseDashboardData.fromJson(json["data"]),
        message: json["message"]?.toString(),
        statusCode: json["statusCode"] is int
            ? json["statusCode"]
            : int.tryParse(json["statusCode"]?.toString() ?? ''),
        isSuccess: json["isSuccess"] ??
            (json["statusCode"] == 200 ||
                json["status"] == 200 ||
                json["success"] == true),
        total: json["total"],
        totalViews: json["totalViews"],
        totalLikes: json["totalLikes"],
        totalRevenue: json["totalRevenue"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "message": message,
        "statusCode": statusCode,
        "isSuccess": isSuccess,
        "total": total,
        "totalViews": totalViews,
        "totalLikes": totalLikes,
        "totalRevenue": totalRevenue,
      };
}

class MediaHouseDashboardData {
  int? liveContent;
  double? walletAmount;
  int? upcomingContent;
  int? pendingContent;
  int? totalViews;
  String? productionHouseName;
  int? purchaseCount;
  double? customerPayment;
  double? gstCharges;
  double? baseAmountAfterGST;
  double? paymentGatewayFees;
  double? netRevenue;
  double? platformRevenue;
  double? productionHouseRevenue;
  double? tax;
  double? paymentGatewayFee;
  double? finalProductionHouseRevenue;
  double? promoterRevenue;
  int? totalContentCount;
  int? rejectedContentCount;
  double? viewRevenue;

  MediaHouseDashboardData({
    this.liveContent,
    this.walletAmount,
    this.upcomingContent,
    this.pendingContent,
    this.totalViews,
    this.productionHouseName,
    this.purchaseCount,
    this.customerPayment,
    this.gstCharges,
    this.baseAmountAfterGST,
    this.paymentGatewayFees,
    this.netRevenue,
    this.platformRevenue,
    this.productionHouseRevenue,
    this.tax,
    this.paymentGatewayFee,
    this.finalProductionHouseRevenue,
    this.promoterRevenue,
    this.totalContentCount,
    this.rejectedContentCount,
    this.viewRevenue,
  });

  // Backwards-compatible aliases
  int? get approvedContent => liveContent;
  int? get upcomingContentCount => upcomingContent;
  int? get pendingContentCount => pendingContent;

  factory MediaHouseDashboardData.fromJson(Map<String, dynamic> json) =>
      MediaHouseDashboardData(
        liveContent: _asInt(json["liveContent"] ??
            json["Approved Content"] ??
            json["approvedContent"]),
        walletAmount: _asDouble(json["walletAmount"] ?? json["wallet"]),
        upcomingContent: _asInt(json["upcomingContent"] ??
            json["Upcoming Content Count"] ??
            json["upcomingContentCount"]),
        pendingContent: _asInt(json["pendingContent"] ??
            json["Pending Content Count"] ??
            json["pendingContentCount"]),
        totalViews: _asInt(json["totalViews"] ?? json["Total Views"]),
        productionHouseName: _asString(json["Production House Name"] ??
            json["productionHouseName"] ??
            json["mediaHouseName"] ??
            json["MediaHouseName"]),
        purchaseCount: _asInt(json["purchaseCount"] ??
            json["Purchase Count"] ??
            json["totalPurchase"]),
        customerPayment: _asDouble(json["customerPayment"] ??
            json["Customer Payment"] ??
            json["totalCustomerPayment"]),
        gstCharges:
            _asDouble(json["gstCharges"] ?? json["GST Charges"] ?? json["gst"]),
        baseAmountAfterGST: _asDouble(json["baseAmountAfterGST"] ??
            json["Base Amount After GST"] ??
            json["baseAmount"]),
        paymentGatewayFees: _asDouble(
            json["paymentGatewayFees"] ?? json["Payment Gateway Fees"]),
        netRevenue: _asDouble(json["netRevenue"] ?? json["Net Revenue"]),
        platformRevenue: _asDouble(json["platformRevenue"] ??
            json["Platform Revenue"] ??
            json["adminRevenue"]),
        productionHouseRevenue: _asDouble(json["productionHouseRevenue"] ??
            json["Production House Revenue"] ??
            json["mediaHouseRevenue"]),
        tax: _asDouble(json["tax"] ?? json["Tax"] ?? json["tds"]),
        paymentGatewayFee: _asDouble(
            json["paymentGatewayFee"] ?? json["Payment Gateway Fee"]),
        finalProductionHouseRevenue: _asDouble(
            json["finalProductionHouseRevenue"] ??
                json["Final Production House Revenue"]),
        promoterRevenue:
            _asDouble(json["promoterRevenue"] ?? json["Promoter Revenue"]),
        totalContentCount: _asInt(json["totalContentCount"] ??
            json["Total Content Count"] ??
            json["totalContent"]),
        rejectedContentCount: _asInt(json["Rejected Content Count"] ??
            json["rejectedContentCount"]),
        viewRevenue: _asDouble(json["viewRevenue"]),
      );

  Map<String, dynamic> toJson() => {
        "liveContent": liveContent,
        "walletAmount": walletAmount,
        "upcomingContent": upcomingContent,
        "pendingContent": pendingContent,
        "totalViews": totalViews,
        "Production House Name": productionHouseName,
        "purchaseCount": purchaseCount,
        "customerPayment": customerPayment,
        "gstCharges": gstCharges,
        "baseAmountAfterGST": baseAmountAfterGST,
        "paymentGatewayFees": paymentGatewayFees,
        "netRevenue": netRevenue,
        "platformRevenue": platformRevenue,
        "productionHouseRevenue": productionHouseRevenue,
        "tax": tax,
        "paymentGatewayFee": paymentGatewayFee,
        "finalProductionHouseRevenue": finalProductionHouseRevenue,
        "promoterRevenue": promoterRevenue,
        "totalContentCount": totalContentCount,
        "Rejected Content Count": rejectedContentCount,
        "viewRevenue": viewRevenue,
      };
}

int? _asInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val.replaceAll(',', '').trim());
  return null;
}

double? _asDouble(dynamic val) {
  if (val == null) return null;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val.replaceAll(',', '').trim());
  return null;
}

String? _asString(dynamic val) {
  if (val == null) return null;
  return val.toString().trim();
}

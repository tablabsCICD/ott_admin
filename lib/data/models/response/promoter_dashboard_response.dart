class PromoterDashboardResponse {
  String? message;
  PromoterDashboardData? data;
  int? statusCode;
  bool? success;
  dynamic total;
  dynamic totalViews;
  dynamic totalLikes;
  dynamic totalRevenue;

  PromoterDashboardResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
    this.total,
    this.totalViews,
    this.totalLikes,
    this.totalRevenue,
  });

  factory PromoterDashboardResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json["data"];
    PromoterDashboardData? parsedData;

    if (rawData is Map<String, dynamic>) {
      parsedData = PromoterDashboardData.fromJson(rawData);
    } else if (rawData is Map) {
      parsedData =
          PromoterDashboardData.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData == null) {
      // If data is null, check if root json has the dashboard fields
      if (json.containsKey("customerPayment") ||
          json.containsKey("baseAmountAfterGST") ||
          json.containsKey("baseAmount") ||
          json.containsKey("baseRevenue") ||
          json.containsKey("promoterRevenue") ||
          json.containsKey("grossRevenue") ||
          json.containsKey("totalRevenue") ||
          json.containsKey("dashboard") ||
          json.containsKey("promoter") ||
          json.containsKey("totalUsers")) {
        parsedData = PromoterDashboardData.fromJson(json);
      }
    }

    return PromoterDashboardResponse(
      message: json["message"]?.toString(),
      data: parsedData,
      statusCode: json["statusCode"] is int
          ? json["statusCode"]
          : int.tryParse(json["statusCode"]?.toString() ?? ''),
      success: json["success"] ??
          (json["statusCode"] == 200 || json["status"] == 200),
      total: json["total"],
      totalViews: json["totalViews"],
      totalLikes: json["totalLikes"],
      totalRevenue: json["totalRevenue"],
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "success": success,
        "total": total,
        "totalViews": totalViews,
        "totalLikes": totalLikes,
        "totalRevenue": totalRevenue,
      };
}

class PromoterDashboardData {
  PromoterDashboardPromoter? promoter;
  PromoterDashboardStats? dashboard;
  PromoterDashboardUsers? users;
  PromoterDashboardPromoters? promoters;

  PromoterDashboardData({
    this.promoter,
    this.dashboard,
    this.users,
    this.promoters,
  });

  factory PromoterDashboardData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dashboardMap;
    if (json["dashboard"] is Map<String, dynamic>) {
      dashboardMap = json["dashboard"];
    } else if (json["dashboard"] is Map) {
      dashboardMap = Map<String, dynamic>.from(json["dashboard"]);
    } else if (json["dashboard"] == null) {
      // Check if stats are flattened directly under json
      if (json.containsKey("customerPayment") ||
          json.containsKey("baseAmountAfterGST") ||
          json.containsKey("baseAmount") ||
          json.containsKey("baseRevenue") ||
          json.containsKey("grossRevenue") ||
          json.containsKey("totalRevenue") ||
          json.containsKey("promoterRevenue") ||
          json.containsKey("promoterPercentage") ||
          json.containsKey("finalPromoterRevenue") ||
          json.containsKey("walletBalance") ||
          json.containsKey("gstCharges") ||
          json.containsKey("gst") ||
          json.containsKey("tax") ||
          json.containsKey("totalUsers") ||
          json.containsKey("totalPurchases") ||
          json.containsKey("totalViews") ||
          json.containsKey("totalContent")) {
        dashboardMap = json;
      }
    }

    Map<String, dynamic>? promoterMap;
    if (json["promoter"] is Map<String, dynamic>) {
      promoterMap = json["promoter"];
    } else if (json["promoter"] is Map) {
      promoterMap = Map<String, dynamic>.from(json["promoter"]);
    } else if (json.containsKey("promoterName") ||
        json.containsKey("promoterId")) {
      promoterMap = json;
    }

    Map<String, dynamic>? usersMap;
    if (json["users"] is Map<String, dynamic>) {
      usersMap = json["users"];
    } else if (json["users"] is Map) {
      usersMap = Map<String, dynamic>.from(json["users"]);
    } else if (json.containsKey("activeUsers") ||
        json.containsKey("inactiveUsers") ||
        json.containsKey("newUsers")) {
      usersMap = json;
    }

    Map<String, dynamic>? promotersMap;
    if (json["promoters"] is Map<String, dynamic>) {
      promotersMap = json["promoters"];
    } else if (json["promoters"] is Map) {
      promotersMap = Map<String, dynamic>.from(json["promoters"]);
    } else if (json.containsKey("activePromoters") ||
        json.containsKey("inactivePromoters")) {
      promotersMap = json;
    }

    return PromoterDashboardData(
      promoter: promoterMap == null
          ? null
          : PromoterDashboardPromoter.fromJson(promoterMap),
      dashboard: dashboardMap == null
          ? null
          : PromoterDashboardStats.fromJson(dashboardMap),
      users:
          usersMap == null ? null : PromoterDashboardUsers.fromJson(usersMap),
      promoters: promotersMap == null
          ? null
          : PromoterDashboardPromoters.fromJson(promotersMap),
    );
  }

  Map<String, dynamic> toJson() => {
        "promoter": promoter?.toJson(),
        "dashboard": dashboard?.toJson(),
        "users": users?.toJson(),
        "promoters": promoters?.toJson(),
      };
}

class PromoterDashboardPromoter {
  int? promoterId;
  String? promoterName;
  String? mobileNumber;
  String? designation;
  String? level;

  PromoterDashboardPromoter({
    this.promoterId,
    this.promoterName,
    this.mobileNumber,
    this.designation,
    this.level,
  });

  factory PromoterDashboardPromoter.fromJson(Map<String, dynamic> json) =>
      PromoterDashboardPromoter(
        promoterId: _asInt(json["promoterId"] ?? json["id"]),
        promoterName: _asString(json["promoterName"] ?? json["name"]),
        mobileNumber: _asString(json["mobileNumber"] ?? json["contactNumber"]),
        designation: _asString(json["designation"]),
        level: _asString(json["level"]),
      );

  int? get id => promoterId;

  String get normalizedLevel {
    final raw = (level ?? designation ?? '').trim();
    if (raw.isEmpty) return 'Taluka';
    final l = raw.toLowerCase();
    if (l.contains('national')) return 'National';
    if (l.contains('state')) return 'State';
    if (l.contains('district')) return 'District';
    if (l.contains('taluka')) return 'Taluka';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Map<String, dynamic> toJson() => {
        "promoterId": promoterId,
        "promoterName": promoterName,
        "mobileNumber": mobileNumber,
        "designation": designation,
        "level": level,
      };
}

class PromoterDashboardStats {
  int? totalUsers;
  int? totalPromoters;
  int? totalPurchases;
  int? totalViews;
  int? totalLikes;
  int? totalContent;
  double? customerPayment;
  double? gstCharges;
  double? baseAmountAfterGST;
  double? platformCharges;
  double? platformChargesPercentage;
  double? platformPayoutCharges;
  double? finalRevenue;
  double? paymentGatewayFees;
  double? grossRevenue;
  double? platformRevenue;
  double? productionHouseRevenue;
  double? promoterPercentage;
  double? promoterRevenue;
  double? taxPercentage;
  double? tax;
  double? paymentGatewayFeePercentage;
  double? paymentGatewayFee;
  double? finalPromoterRevenue;
  double? walletBalance;
  double? totalWithdrawn;
  double? pendingAmount;

  PromoterDashboardStats({
    this.totalUsers,
    this.totalPromoters,
    this.totalPurchases,
    this.totalViews,
    this.totalLikes,
    this.totalContent,
    this.customerPayment,
    this.gstCharges,
    this.baseAmountAfterGST,
    this.platformCharges,
    this.platformChargesPercentage,
    this.platformPayoutCharges,
    this.finalRevenue,
    this.paymentGatewayFees,
    this.grossRevenue,
    this.platformRevenue,
    this.productionHouseRevenue,
    this.promoterPercentage,
    this.promoterRevenue,
    this.taxPercentage,
    this.tax,
    this.paymentGatewayFeePercentage,
    this.paymentGatewayFee,
    this.finalPromoterRevenue,
    this.walletBalance,
    this.totalWithdrawn,
    this.pendingAmount,
  });

  factory PromoterDashboardStats.fromJson(Map<String, dynamic> json) {
    final custPayment = _asDouble(json["customerPayment"] ??
        json["totalCustomerPayment"] ??
        json["totalPayment"] ??
        json["payment"] ??
        json["grossRevenue"] ??
        json["totalRevenue"] ??
        json["total"]);
    final gst = _asDouble(json["gstCharges"] ??
        json["gst"] ??
        json["gstAmount"] ??
        json["taxGST"]);
    final baseAmt = _asDouble(json["baseAmountAfterGST"] ??
        json["baseRevenue"] ??
        json["baseAmount"] ??
        json["baseAmt"] ??
        json["netBaseAmount"]);
    final pltCharges = _asDouble(json["platformCharges"] ??
        json["platformFee"] ??
        json["platformGatewayCharges"] ??
        json["platformCharge"] ??
        json["paymentGatewayFees"]);
    final pltChargesPct = _asDouble(json["platformChargesPercentage"] ??
        json["platformFeePercentage"] ??
        json["platformRate"] ??
        2.0);
    final pltPayoutCharges = _asDouble(json["platformPayoutCharges"] ??
        json["platformPayoutChargesDeduction"] ??
        json["payoutCharges"] ??
        json["payoutDeduction"] ??
        json["platformPayoutDeduction"] ??
        json["paymentGatewayFee"] ??
        json["transferCharges"]);
    final finalRev = _asDouble(json["finalRevenue"] ??
        json["netRevenue"] ??
        json["revenueAfterPlatformDeductions"] ??
        json["netBaseRevenue"]);
    final pgFees = _asDouble(json["paymentGatewayFees"] ??
        json["paymentGatewayFee"] ??
        json["pgCharges"] ??
        json["gatewayFee"] ??
        json["transferCharges"] ??
        json["charges"] ??
        pltCharges);
    final gross = _asDouble(json["grossRevenue"] ??
        json["grossAmount"] ??
        json["totalRevenue"] ??
        custPayment);
    final platform = _asDouble(json["platformRevenue"] ??
        json["platformShare"] ??
        json["adminRevenue"] ??
        json["adminShare"]);
    final prodHouse = _asDouble(json["productionHouseRevenue"] ??
        json["productionHouseShare"] ??
        json["mediaHouseRevenue"] ??
        json["mediaHouseShare"]);
    final promPct = _asDouble(json["promoterPercentage"] ??
        json["promoterRate"] ??
        json["commissionPercentage"] ??
        json["commissionRate"] ??
        json["percentage"]);
    final promRev = _asDouble(json["promoterRevenue"] ??
        json["promoterCommission"] ??
        json["promoterShare"] ??
        json["commissionEarned"] ??
        json["commission"] ??
        json["incentive"] ??
        json["revenue"]);
    final taxPct = _asDouble(json["taxPercentage"] ??
        json["tdsPercentage"] ??
        json["tdsRate"] ??
        json["taxRate"]);
    final taxAmt = _asDouble(json["tax"] ??
        json["taxDeduction"] ??
        json["tdsDeduction"] ??
        json["tds"] ??
        json["tdsAmount"] ??
        json["taxAmount"]);
    final pgFeePct = _asDouble(json["paymentGatewayFeePercentage"] ??
        json["paymentGatewayFeeRate"] ??
        json["chargesPercentage"] ??
        json["pgChargesPercentage"] ??
        json["pgPercentage"]);
    final finalPromRev = _asDouble(json["finalPromoterRevenue"] ??
        json["finalSettlementWallet"] ??
        json["netPayable"] ??
        json["netSettlement"] ??
        json["netAmount"] ??
        json["netPromoterRevenue"]);
    final wallet = _asDouble(json["walletBalance"] ??
        json["wallet"] ??
        json["currentBalance"] ??
        json["availableBalance"] ??
        json["balance"]);
    final withdrawn = _asDouble(json["totalWithdrawn"] ??
        json["totalPaid"] ??
        json["withdrawnAmount"] ??
        json["paidAmount"] ??
        json["disbursedAmount"]);
    final pending = _asDouble(json["pendingAmount"] ??
        json["pendingBalance"] ??
        json["unsettledAmount"] ??
        json["pendingSettlement"]);

    return PromoterDashboardStats(
      totalUsers: _asInt(json["totalUsers"] ??
          json["userCount"] ??
          json["usersCount"] ??
          json["totalUser"]),
      totalPromoters: _asInt(json["totalPromoters"] ??
          json["promoterCount"] ??
          json["promotersCount"] ??
          json["totalPromoter"]),
      totalPurchases: _asInt(json["totalPurchases"] ??
          json["purchases"] ??
          json["purchasesCount"] ??
          json["purchaseCount"] ??
          json["totalPurchase"]),
      totalViews: _asInt(json["totalViews"] ??
          json["views"] ??
          json["viewsCount"] ??
          json["viewCount"]),
      totalLikes:
          _asInt(json["totalLikes"] ?? json["likesCount"] ?? json["likes"]),
      totalContent: _asInt(json["totalContent"] ??
          json["contentCount"] ??
          json["contentsCount"] ??
          json["totalMovies"] ??
          json["totalVideos"]),
      customerPayment: custPayment,
      gstCharges: gst,
      baseAmountAfterGST: baseAmt,
      platformCharges: pltCharges,
      platformChargesPercentage: pltChargesPct,
      platformPayoutCharges: pltPayoutCharges,
      finalRevenue: finalRev,
      paymentGatewayFees: pgFees,
      grossRevenue: gross,
      platformRevenue: platform,
      productionHouseRevenue: prodHouse,
      promoterPercentage: promPct,
      promoterRevenue: promRev,
      taxPercentage: taxPct,
      tax: taxAmt,
      paymentGatewayFeePercentage: pgFeePct,
      paymentGatewayFee: pgFees,
      finalPromoterRevenue: finalPromRev,
      walletBalance: wallet,
      totalWithdrawn: withdrawn,
      pendingAmount: pending,
    );
  }

  // Convenience Aliases
  double? get gst => gstCharges;
  double? get baseRevenue => baseAmountAfterGST;
  double? get baseAmount => baseAmountAfterGST;
  double? get promoterShare => promoterRevenue;
  double? get tdsPercentage => taxPercentage;
  double? get tdsDeduction => tax;
  double? get tds => tax;
  double? get revenueAfterTDS => (promoterRevenue != null && tax != null)
      ? (promoterRevenue! - tax!)
      : null;
  double? get revenueAfterTds => revenueAfterTDS;
  double? get chargesPercentage => paymentGatewayFeePercentage;
  double? get transferCharges => paymentGatewayFee ?? paymentGatewayFees;
  double? get finalSettlementWallet => finalPromoterRevenue;
  double? get netRevenue => finalPromoterRevenue;
  String? get calculatedLevel => null;

  Map<String, dynamic> toJson() => {
        "totalUsers": totalUsers,
        "totalPromoters": totalPromoters,
        "totalPurchases": totalPurchases,
        "totalViews": totalViews,
        "totalContent": totalContent,
        "customerPayment": customerPayment,
        "gstCharges": gstCharges,
        "baseAmountAfterGST": baseAmountAfterGST,
        "platformCharges": platformCharges,
        "platformChargesPercentage": platformChargesPercentage,
        "platformPayoutCharges": platformPayoutCharges,
        "finalRevenue": finalRevenue,
        "paymentGatewayFees": paymentGatewayFees,
        "grossRevenue": grossRevenue,
        "platformRevenue": platformRevenue,
        "productionHouseRevenue": productionHouseRevenue,
        "promoterPercentage": promoterPercentage,
        "promoterRevenue": promoterRevenue,
        "taxPercentage": taxPercentage,
        "tax": tax,
        "paymentGatewayFeePercentage": paymentGatewayFeePercentage,
        "paymentGatewayFee": paymentGatewayFee,
        "finalPromoterRevenue": finalPromoterRevenue,
        "walletBalance": walletBalance,
        "totalWithdrawn": totalWithdrawn,
        "pendingAmount": pendingAmount,
      };
}

class PromoterDashboardUsers {
  int? totalUsers;
  int? activeUsers;
  int? inactiveUsers;
  int? newUsers;

  PromoterDashboardUsers({
    this.totalUsers,
    this.activeUsers,
    this.inactiveUsers,
    this.newUsers,
  });

  factory PromoterDashboardUsers.fromJson(Map<String, dynamic> json) =>
      PromoterDashboardUsers(
        totalUsers: _asInt(json["totalUsers"]),
        activeUsers: _asInt(json["activeUsers"]),
        inactiveUsers: _asInt(json["inactiveUsers"]),
        newUsers: _asInt(json["newUsers"]),
      );

  Map<String, dynamic> toJson() => {
        "totalUsers": totalUsers,
        "activeUsers": activeUsers,
        "inactiveUsers": inactiveUsers,
        "newUsers": newUsers,
      };
}

class PromoterDashboardPromoters {
  int? totalPromoters;
  int? activePromoters;
  int? inactivePromoters;

  PromoterDashboardPromoters({
    this.totalPromoters,
    this.activePromoters,
    this.inactivePromoters,
  });

  factory PromoterDashboardPromoters.fromJson(Map<String, dynamic> json) =>
      PromoterDashboardPromoters(
        totalPromoters: _asInt(json["totalPromoters"]),
        activePromoters: _asInt(json["activePromoters"]),
        inactivePromoters: _asInt(json["inactivePromoters"]),
      );

  Map<String, dynamic> toJson() => {
        "totalPromoters": totalPromoters,
        "activePromoters": activePromoters,
        "inactivePromoters": inactivePromoters,
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

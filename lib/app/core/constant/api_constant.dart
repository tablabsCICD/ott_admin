class ApiConstant {
  static const String baseUrl = "https://filmytell.com/ott/";

  /*  static const String baseUrl =
      "http://ec2-13-201-27-141.ap-south-1.compute.amazonaws.com:8080/ott/"; */

  //loginPage
  static String login = "${baseUrl}userNew/admin/login";
  static String forgotPassword(mobileNumber) =>
      "${baseUrl}user/forgotPassword/findUserAndSendOTP?mobileNumber=$mobileNumber";
  static String verifyOtp(mobileNumber, otp) =>
      "${baseUrl}user/verifyOTP?mobileNumber=$mobileNumber&otp=$otp";
  static String resetPassword(mobileNumber, otp) =>
      "${baseUrl}user/resetPassword?mobileNumber=$mobileNumber&password=$otp";
  static String registration = '${baseUrl}user/RegisterUser';

  //DashboardPage
  static String dashboardCount = "${baseUrl}api/admin/dashboardCounts";
  static String allRevenue(startDate, endDate, {String type = "ALL"}) =>
      "${baseUrl}api/admin/graph?startDate=$startDate&endDate=$endDate&type=$type";
  static String userCountGraph(startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/userCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String purchaseCountGraph(startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/userContentPurchaseChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String mediaHouseCountGraph(
          startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/mediaHouseCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String promoterCountGraph(startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/promoterCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String approvedContentCountGraph(
          startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/contentApprovalCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String movieTypeChartData =
      "${baseUrl}api/adminLineCharts/totalContentChart";
  static String movieTypeChartDataWithType({String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/totalContentChart?type=$type";
  static String revenueChartData =
      "${baseUrl}api/adminLineCharts/revenueByContentCategory";
  static String revenueChartDataWithType({String type = "ALL"}) =>
      "${baseUrl}api/adminLineCharts/revenueByContentCategory?type=$type";
  static String analyticsSummary = "${baseUrl}api/admin/analytics/summary";
  static String locationWiseAnalytics =
      "${baseUrl}ott/admin/analytics/location-wise";
  static String ageWiseRevenueAnalytics =
      "${baseUrl}ott/admin/analytics/age-wise-revenue";
  static String ageWiseViewsAnalytics =
      "${baseUrl}ott/admin/analytics/age-wise-views";
  static String contentPerformanceAnalytics =
      "${baseUrl}ott/admin/analytics/content-performance";
  static String deviceAnalytics = "${baseUrl}ott/admin/analytics/device";
  static String engagementAnalytics =
      "${baseUrl}ott/admin/analytics/engagement";
  static String watchTimeAnalytics = "${baseUrl}ott/admin/analytics/watch-time";
  static String dateWiseAnalytics(String fromDate, String toDate) =>
      "${baseUrl}ott/admin/analytics/date-wise?fromDate=$fromDate&toDate=$toDate";
  static String getMediaHouseByStatus(status) =>
      "${baseUrl}api/MediaHouse/getByStatus?status=$status";
  static String getVideoByStatusAndMediaHouse(status, id) =>
      "${baseUrl}api/Approvalstatus/mediahouseid2?approvalStatus=$status&mediaHouseId=$id";
  static String getPromoterByStatus(status) =>
      "${baseUrl}api/Promoters/getByStatus?status=$status";
  static String videoEditRequest(id, reason) =>
      "${baseUrl}api/contentList/updateContentReason/$id?reason=$reason";
  static String changeContentStatus(status, id) =>
      "${baseUrl}api/ApprovecontentListBy?contentListId=$id&status=$status";
  static String changeMediaHouseStatus(status, id) =>
      "${baseUrl}api/ApproveMediaHouseBy?mediaHouseId=$id&status=$status";
  static String changePromoterStatus(status, id) =>
      "${baseUrl}api/saveStatus/$id/$status";

  //ManageUserPage
  static String getAllUser = "${baseUrl}user/getAllActiveUsers";
  static String getAllUsersPaged({int page = 0, int size = 20}) =>
      "${baseUrl}user/getAllActiveUsers?page=$page&size=$size";
  static String editUserById = "${baseUrl}user/updateUserBy/%7Bid%7D";
  static String getUserById(id) => "${baseUrl}user/getUser/$id";
  static String deleteUserById(id) => "${baseUrl}user/deleteUserBy/$id";
  static String searchUser(dynamic char) {
    final query = Uri.encodeQueryComponent(char.toString().trim());
    return "${baseUrl}userNew/search?search=$query";
  }
  static String changeUserActiveStatus(mobileNumber) {
    final encodedMobileNumber = Uri.encodeComponent(mobileNumber.toString());
    return "${baseUrl}userNew/user/change-active-status/$encodedMobileNumber";
  }

  //ManageMediaHouse
  static String getAllMediaHouseForAdmin =
      "${baseUrl}api/MediaHouse/getAllActive";
  static String saveMediaHouse = '${baseUrl}api/saveMediaHouse';
  static String editMediaHouseById = "${baseUrl}api/MediaHouse/Update";
  static String getMediaHouseById(id) =>
      "${baseUrl}api/MediaHouse/getById?id=$id";
  static String deleteMediaHouseById(id) =>
      "${baseUrl}api/deleteMediaHouseBy/$id";
  static String searchMediaHouse(char) =>
      "${baseUrl}api/searchByanyKey%20?search=$char";
  static String getMediaHouseDashboardCountForAdmin(id) =>
      "${baseUrl}api/admin/mediaHouseDashboardApi?mediaHouseId=$id";
  static String getVideoByMediaHouseId(id) =>
      "${baseUrl}api/content/byMediaHouse?mediaHouseId=$id";

  // Production House V2 APIs
  static String mediaHouseProfileV2(dynamic id) =>
      "${baseUrl}api/v2/mediaHouse/getMediaHouseById/$id";
  static String mediaHouseProfileV2Alias(dynamic id) =>
      "${baseUrl}api/MediaHouse/getById?id=$id";

  static String videoByMediaHouseV2(dynamic mediaHouseId) =>
      "${baseUrl}api/v2/video/getVideoByMediaHouseId/$mediaHouseId";
  static String videoByMediaHouseV2Alias(dynamic mediaHouseId) =>
      "${baseUrl}api/content/byMediaHouse?mediaHouseId=$mediaHouseId";

  static String shortsByMediaHouseV2(dynamic mediaHouseId,
      {int page = 0, int size = 10, String? keyword}) {
    final query = keyword != null && keyword.trim().isNotEmpty
        ? "&keyword=${Uri.encodeQueryComponent(keyword.trim())}"
        : "";
    return "${baseUrl}api/v2/shorts/by-media-house/$mediaHouseId?page=$page&size=$size$query";
  }

  static String shortsByMediaHouseV2Alias(dynamic mediaHouseId,
      {int page = 0, int size = 10, String? keyword}) {
    final query = keyword != null && keyword.trim().isNotEmpty
        ? "&keyword=${Uri.encodeQueryComponent(keyword.trim())}"
        : "";
    return "${baseUrl}api/shortsMaster/by-mediahouse/$mediaHouseId?page=$page&size=$size$query";
  }

  static String mediaHouseDashboardCountV2(dynamic mediaHouseId) =>
      "${baseUrl}api/v2/mediaHouse/getMediaHouseDashboardCountForAdmin/$mediaHouseId";
  static String mediaHouseDashboardCountV2Alias(dynamic mediaHouseId) =>
      "${baseUrl}api/admin/mediaHouseDashboardApi?mediaHouseId=$mediaHouseId";

  static String mediaHouseRevenueGraphV2Clean(dynamic mediaId) =>
      "${baseUrl}api/v2/mediaHouse/revenueGraphByMediaHouse?mediaId=$mediaId";

  static String mediaHouseRevenueGraphV2(dynamic mediaId,
      {String? startDate, String? endDate, String? type}) {
    final query = <String, String>{
      'mediaId': mediaId.toString(),
    };
    if (type != null && type.trim().isNotEmpty && type != "ALL") {
      query['type'] = type.trim();
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      query['startDate'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      query['endDate'] = endDate.trim();
    }
    return Uri.parse("${baseUrl}api/v2/mediaHouse/revenueGraphByMediaHouse")
        .replace(queryParameters: query)
        .toString();
  }

  static String mediaHouseRevenueGraphV2Alias(dynamic mediaId,
          {String? startDate, String? endDate, String type = "ALL"}) =>
      "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?mediaHouseId=$mediaId&startDate=${startDate ?? ''}&endDate=${endDate ?? ''}&isYear=false&isMonth=true&isWeek=false&type=$type";

  static String mediaHouseTransactionsV2(dynamic mediaHouseId,
      {String? startDate, String? endDate, int? page, int? size}) {
    final query = <String, String>{};
    if (startDate != null && startDate.trim().isNotEmpty) {
      query['startDate'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      query['endDate'] = endDate.trim();
    }
    if (page != null) query['page'] = page.toString();
    if (size != null) query['size'] = size.toString();
    final uri = Uri.parse(
        "${baseUrl}api/v2/user/movie-transactions-by-media-house/$mediaHouseId");
    return query.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: query).toString();
  }

  static String mediaHouseTransactionsV2Alias(dynamic mediaHouseId) =>
      "${baseUrl}userNew/user/movie-transactions-by-media-house/$mediaHouseId";

  static String mediaHouseWeeklySettlementsV2(dynamic userId) =>
      "${baseUrl}api/v2/settlement/weeklySettelementDataForMediaHouse/$userId";
  static String mediaHouseWeeklySettlementsV2Alias(dynamic userId) =>
      "${baseUrl}api/settelment/mediaHouse/$userId";

  //ManageVideoPage
  static String saveVideo = '${baseUrl}api/addContent';
  static String editVideoById(id) => "${baseUrl}api/contentList/update/$id";
  static String getAllVideo = "${baseUrl}api/ContentList/getAll";
  static String getVideoById(id) => "${baseUrl}api/ContentList/getById?id=$id";
  static String seriesDetails(id) => "${baseUrl}series/$id/details";
  static String seriesAnalyticsBase(id) => "${baseUrl}series/$id/analytics";
  static String seriesAnalytics(id) => seriesAnalyticsBase(id);
  static String seriesAnalyticsSummary(id) =>
      "${seriesAnalyticsBase(id)}/summary";
  static String seriesRevenueAnalytics(id) =>
      "${seriesAnalyticsBase(id)}/revenue";
  static String seriesAudienceAnalytics(id) =>
      "${seriesAnalyticsBase(id)}/audience";
  static String seriesLocationAnalytics(id) =>
      "${seriesAnalyticsBase(id)}/location";
  static String seriesDatewiseAnalytics(id) =>
      "${seriesAnalyticsBase(id)}/datewise";
  static String seriesEngagementAnalytics(id) =>
      "${seriesAnalyticsBase(id)}/engagement";
  static String seriesSeasonsAnalyticsDashboard(id) =>
      "${seriesAnalyticsBase(id)}/seasons";
  static String seriesEpisodesAnalyticsDashboard(id) =>
      "${seriesAnalyticsBase(id)}/episodes";
  static String seriesFilterMetadata(id) =>
      "${seriesAnalyticsBase(id)}/filters";
  static String seriesFilterAnalytics(id) =>
      "${seriesAnalyticsBase(id)}/filter";
  static String changeSeriesSeasonStatus(seasonId, status) =>
      "${baseUrl}series/ApproveSeasonBy?seasonId=$seasonId&status=$status";
  static String seriesSeasonAnalytics(seriesId, seasonId) =>
      "${seriesAnalyticsBase(seriesId)}/seasons";
  static String seriesEpisodeAnalytics(seriesId, episodeId) =>
      "${baseUrl}series/$seriesId/episode/$episodeId/analytics";
  static String searchContent(char) =>
      "${baseUrl}api/searchByanyKey%20?search=$char";
  static String deleteVideoById(id) => "${baseUrl}api/deleteContentBy/$id";

  static String savePromoter = '${baseUrl}api/savePromotersWithBankDetails';
  static String editPromoterById = "${baseUrl}user/updateUserBy/%7Bid%7D";
  static String getAllPromoter = "${baseUrl}api/Promoters/getAllActive";
  static String getPromoterById(id) => "${baseUrl}user/getUser/$id";
  static String deletePromoterById(id) => "${baseUrl}api/deletePromotersBy/$id";
  static String getUsersByPromoterCode(code) =>
      "${baseUrl}user/getUsersByPromoterReferralCode2?refferedBy=$code";
  static String getPromotersByPromoterCode(code) =>
      "${baseUrl}user/getPromotersByPromoterReferralCode2?refferedBy=$code";
  static String getUserAndRevenueGraph(startDate, endEnd, promoterId) =>
      "${baseUrl}api/admin/userOnboardedGraphByPromoterId2?start_date=$startDate&end_date=$endEnd&promoterId=$promoterId";
  static String reportingPromoterApi(level, location) =>
      "${baseUrl}api/getByLevelAndLocation?level=$level&location=$location";
  static String getPromotersByLevel(dynamic level) =>
      "${baseUrl}api/getPromotersByLevel/$level";
  static String promoterByPromoterId(dynamic promoterId) =>
      "${baseUrl}api/promotersLineCharts/promoterByPromoterId?promoterId=$promoterId";

  // Promoter V2 APIs
  static String promoterDashboardV2(dynamic promoterId) =>
      "${baseUrl}api/v2/promoters/$promoterId/dashboard";
  static String promoterDashboardV2Alias(dynamic promoterId) =>
      "${baseUrl}api/promoter/dashboard/$promoterId";
  static String promoterDashboardV2Alias2(dynamic promoterId) =>
      "${baseUrl}api/v2/promoter/dashboard?promoterId=$promoterId";
  static String promoterDashboardV2Alias3(dynamic promoterId) =>
      "${baseUrl}userNew/promoter/dashboard/$promoterId";
  static String promoterProfileV2(dynamic promoterId) =>
      "${baseUrl}api/v2/promoters/$promoterId/profile";
  static String promoterProfileV2Alias(dynamic promoterId) =>
      "${baseUrl}user/getUser/$promoterId";

  static String promoterUsersV2(dynamic promoterId,
      {int? page, int? size, String? search}) {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    if (size != null) query['size'] = size.toString();
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final uri = Uri.parse("${baseUrl}api/v2/promoters/$promoterId/users");
    return query.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: query).toString();
  }

  static String promoterUsersV2Alias(dynamic promoterId) =>
      "${baseUrl}api/v2/user/getUsersByPromoterId/$promoterId";

  static String childPromotersV2(dynamic promoterId, {int? page, int? size}) {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    if (size != null) query['size'] = size.toString();
    final uri =
        Uri.parse("${baseUrl}api/v2/promoters/$promoterId/child-promoters");
    return query.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: query).toString();
  }

  static String childPromotersV2Alias(dynamic promoterId) =>
      "${baseUrl}api/v2/Promoters/getPromotersByPromoterId/$promoterId";

  static String promoterOnboardRevenueGraphV2(dynamic promoterId,
      {String? startDate, String? endDate, String? type}) {
    final query = <String, String>{};
    if (type != null && type.trim().isNotEmpty && type != "ALL") {
      query['type'] = type.trim();
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      query['start_date'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      query['end_date'] = endDate.trim();
    }
    final uri = Uri.parse(
        "${baseUrl}api/v2/promoters/$promoterId/onboard-revenue-graph");
    return query.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: query).toString();
  }

  static String promoterOnboardRevenueGraphV2Alias(dynamic promoterId,
      {String? startDate, String? endDate, String? type}) {
    final query = <String, String>{'promoterId': promoterId.toString()};
    if (type != null && type.trim().isNotEmpty && type != "ALL") {
      query['type'] = type.trim();
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      query['start_date'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      query['end_date'] = endDate.trim();
    }
    return Uri.parse("${baseUrl}api/v2/user/getUserOnboardAndRevenueGraph")
        .replace(queryParameters: query)
        .toString();
  }

  static String promoterUserMovieTransactionsV2(dynamic promoterId,
      {int? page, int? size, String? search}) {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    if (size != null) query['size'] = size.toString();
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final uri = Uri.parse(
        "${baseUrl}api/v2/promoters/$promoterId/user-movie-transactions");
    return query.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: query).toString();
  }

  static String promoterUserMovieTransactionsV2Alias(dynamic promoterId) =>
      "${baseUrl}api/v2/user/user_movie_transaction?promoterId=$promoterId";

  static String updatePromoterLevelV2(dynamic promoterId) =>
      "${baseUrl}api/v2/promoters/$promoterId/level";
  static String updatePromoterLevelV2Alias(dynamic promoterId) =>
      "${baseUrl}api/v2/Promoters/updateLevel/$promoterId";

  static String assignParentPromoterV2(dynamic promoterId) =>
      "${baseUrl}api/v2/Promoters/assignParent/$promoterId";
  static String assignParentPromoterV2Alias(dynamic promoterId) =>
      "${baseUrl}api/v2/promoters/$promoterId/parent";

  static String promoterSettlementsV2(dynamic promoterId,
      {int? page, int? size}) {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    if (size != null) query['size'] = size.toString();
    final uri = Uri.parse("${baseUrl}api/v2/promoters/$promoterId/settlements");
    return query.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: query).toString();
  }

  static String promoterSettlementsV2Alias(dynamic promoterId) =>
      "${baseUrl}api/v2/settlement/promoter?promoterId=$promoterId";

  //ManageAccessPage
  static String savePromoterAccess = "${baseUrl}AccessControl/save";
  static String getPromoterAccess = "${baseUrl}AccessControl/getAll";
  static String editPromoterAccess = "${baseUrl}AccessControl/update";

  static String uploadImg = "${baseUrl}api/other/upload-file";
  static String uploadVideo = "${baseUrl}api/video/upload-raw?videoId=20";
  static String fetchLang = "${baseUrl}api/Languages/getAll";

  //ManagePromoterPercentage
  static String getPromoterPercentage =
      "${baseUrl}api/PromotersPercentageRate/getAll/pages";
  static String setPromoterPercentage =
      "${baseUrl}api/savePromotersPercentageRate";

  static String allPromoterRevenueGraph(
          startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/settelmentGraph/AllPromotersRevenueForAdmin?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String topRevenueContentGraph(
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String contentType = "ALL",
    String country = "",
    String state = "",
    String district = "",
    String taluka = "",
    String city = "",
    String type = "ALL",
  }) {
    final effectiveType = type != "ALL" ? type : contentType;
    final params = {
      "startDate": startDate.toString(),
      "endDate": endDate.toString(),
      "isYear": isYear.toString(),
      "isMonth": isMonth.toString(),
      "isWeek": isWeek.toString(),
      "contentType": effectiveType,
      "type": effectiveType,
      "country": country,
      "state": state,
      "district": district,
      "taluka": taluka,
      "city": city,
    };
    return Uri.parse("${baseUrl}api/adminLineCharts/top-revenue-content")
        .replace(queryParameters: params)
        .toString();
  }

  static String contentRevenueGraph(
          id, startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/contentList/graph?contentListId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String topRevenueContentGraphForMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String topRatedContentGraph(
          id, startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/mediaHouseLineCharts/top-rated-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String transactionRevenueGraph(
          startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/admin/graph?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String releaseMovieCountGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/promotersLineCharts/releaseMovieCountChart?mediaHouseid=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String viewCountGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/viewCountChartByMediaHouseId?mediahouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String revenueGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek,
          {String type = "ALL"}) =>
      "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek&type=$type";
  static String reportAndDataForMediaHouse(id, {String type = "ALL"}) =>
      "${baseUrl}api/mediaHouseLineCharts/getDetailsOfMovieByMediaHouseId?mediaHouseId=$id&type=$type";

  static String weeklySettelementData = "${baseUrl}api/settelment/admin";
  static String manualSettlement =
      "${baseUrl}api/settelmentCalculation/manualSettelment";
  static String weeklySettelementDataForMediaHouse(mediaHouseId) =>
      "${baseUrl}api/settelment/mediaHouse/$mediaHouseId";
  static String weeklySettlementReport(settelementId) =>
      "${baseUrl}api/admin/weekly-settlement-report/$settelementId";
  static String transactionSettlementReport(transactionId) =>
      "${baseUrl}api/admin/transaction-settlement-report/$transactionId";
  static String reportAndData =
      "${baseUrl}api/adminLineCharts/getDetailsOfMovie";
  static String reportAndDataMediaHouseBase =
      "${baseUrl}api/adminLineCharts/reportAndDataMediaHouse/getById";
  static String reportAndDataMediaHouse({
    required String contentType,
    required String country,
    required String state,
    required String district,
    required String taluka,
    required String city,
    required String startDate,
    required String endDate,
    required String ageGroup,
    required String gender,
  }) {
    return Uri.parse(
      "${baseUrl}api/adminLineCharts/reportAndDataMediaHouse/getById",
    ).replace(
      queryParameters: {
        "contentType": contentType,
        "country": country,
        "state": state,
        "district": district,
        "taluka": taluka,
        "city": city,
        "startDate": startDate,
        "endDate": endDate,
        "ageGroup": ageGroup,
        "gender": gender,
      },
    ).toString();
  }

  static String setPercentage = "${baseUrl}api/admin/saveMoviePercentAndRate";

  // Promoter settlement
  static String promoterSettlementExcel =
      "${baseUrl}api/admin/promoter-wallet/payment-excel";
  static String revenueSettlementAnalytics =
      "${baseUrl}api/admin/revenue-settlement-analytics";
  static String generateMonthlyIosSettlement =
      "${baseUrl}api/admin/monthly-ios-settlement/generate";
  static String monthlyIosSettlementList =
      "${baseUrl}api/admin/monthly-ios-settlement/list";
  static String monthlyIosSettlementDetail(settlementId) =>
      "${baseUrl}api/admin/monthly-ios-settlement/$settlementId";
  static String monthlyIosSettlementDownload(settlementId) =>
      "${baseUrl}api/admin/monthly-ios-settlement/$settlementId/download";

  // Admin Settings
  static String saveRevenueShareRule =
      "${baseUrl}api/admin/revenue-share-rule/save";
  static String getAllRevenueShareRules =
      "${baseUrl}api/admin/revenue-share-rule/getAll";
  static String updateRevenueShareRule(id) =>
      "${baseUrl}api/admin/revenue-share-rule/update/$id";
  static String saveRegistrationFeeRule =
      "${baseUrl}api/admin/registration-fee-rule/save";
  static String getAllRegistrationFeeRules =
      "${baseUrl}api/admin/registration-fee-rule/getAll";
  static String updateRegistrationFeeRule(id) =>
      "${baseUrl}api/admin/registration-fee-rule/update/$id";

  // Notifications
  static String notifications({
    int pageNo = 0,
    int pageSize = 20,
    String sortBy = "sentDateTime",
    String sortOrder = "DESC",
  }) {
    return Uri.parse("${baseUrl}api/notifications").replace(queryParameters: {
      "pageNo": pageNo.toString(),
      "pageSize": pageSize.toString(),
      "sortBy": sortBy,
      "sortOrder": sortOrder,
    }).toString();
  }

  static String deleteNotification(id) =>
      "${baseUrl}api/admin/notifications/$id";
  static String resendNotification(id) =>
      "${baseUrl}api/admin/notifications/$id/resend";
  static String sendNotification = "${baseUrl}api/notifications/send";

  // Shorts
  static String shortsMaster = "${baseUrl}api/shortsMaster";
  static String shortParts = "${baseUrl}api/short-parts";
  static String shortDetail(shortMasterId) =>
      "${baseUrl}api/shortsMaster/forAdmin/$shortMasterId";
  static String deleteShortMaster(shortId) =>
      "${baseUrl}api/shortsMaster/$shortId";
  static String updateShortMaster(shortId) =>
      "${baseUrl}api/shortsMaster/$shortId";
  static String deleteShortPart(partId) => "${baseUrl}api/short-parts/$partId";
  static String updateShortPart(partId) => "${baseUrl}api/short-parts/$partId";
  static String shortsByMediaHouse(mediaHouseId,
      {int page = 0, int size = 10, String? keyword}) {
    final query = keyword != null && keyword.trim().isNotEmpty
        ? "&keyword=${Uri.encodeQueryComponent(keyword.trim())}"
        : "";
    return "${baseUrl}api/shortsMaster/by-mediahouse/$mediaHouseId?page=$page&size=$size$query";
  }

  static String shortsByStatusPage(String status,
          {int page = 0, int size = 10}) =>
      "${baseUrl}api/shortsMaster/by-status-page?status=$status&page=$page&size=$size";
  static String approveShortStatus(int shortId, String status) =>
      "${baseUrl}api/shortsMaster/ApproveShort?shortId=$shortId&status=$status";

  static String userTransactionApi(searchKey) =>
      "${baseUrl}api/admin/list?search=$searchKey";
  static String getPurchaseMovieByUser(userId) =>
      "${baseUrl}api/filter/%7BuserId%7D?userId=$userId";

  static String raiseTicket = "${baseUrl}api/TicketRaised/add";
  static String deleteTicket(id) =>
      "${baseUrl}api/TicketRaised/deleteTicketRaisedBy/$id";
  static String updateTicket(id) => "${baseUrl}api/TicketRaised/update/$id";
  static String getRaisedTicket =
      "${baseUrl}api/TicketRaised/getAllTicketRaised";
  static String getRaisedTicketByFlag(isResolved) =>
      "${baseUrl}api/TicketRaised/getTicketRaisedForAdmin?isResolved=$isResolved";
  static String searchAndFilterTickets({
    String? keyword,
    String? startDate,
    String? endDate,
    String? role,
    String? level,
    bool? isResolved,
    String? status,
    String? priority,
  }) {
    final queryParams = <String, String>{};
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParams['keyword'] = keyword.trim();
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      queryParams['startDate'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      queryParams['endDate'] = endDate.trim();
    }
    if (role != null && role.trim().isNotEmpty) {
      queryParams['role'] = role.trim();
    }
    if (level != null && level.trim().isNotEmpty) {
      queryParams['level'] = level.trim();
    }
    if (isResolved != null) {
      queryParams['isResolved'] = isResolved.toString();
    }
    if (status != null && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }
    if (priority != null && priority.trim().isNotEmpty) {
      queryParams['priority'] = priority.trim();
    }

    final uri = Uri.parse("${baseUrl}api/TicketRaised/searchAndFilter");
    return queryParams.isEmpty
        ? uri.toString()
        : uri.replace(queryParameters: queryParams).toString();
  }

  static String getUsersByContentId({
    required dynamic contentId,
    String? keyword,
    String? startDate,
    String? endDate,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
    String? pincode,
    String? gender,
    int page = 0,
    int size = 20,
  }) {
    final queryParams = <String, String>{
      'contentId': contentId.toString(),
      'page': page.toString(),
      'size': size.toString(),
    };
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParams['keyword'] = keyword.trim();
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      queryParams['startDate'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      queryParams['endDate'] = endDate.trim();
    }
    if (country != null && country.trim().isNotEmpty) {
      queryParams['country'] = country.trim();
    }
    if (state != null && state.trim().isNotEmpty) {
      queryParams['state'] = state.trim();
    }
    if (district != null && district.trim().isNotEmpty) {
      queryParams['district'] = district.trim();
    }
    if (taluka != null && taluka.trim().isNotEmpty) {
      queryParams['taluka'] = taluka.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      queryParams['city'] = city.trim();
    }
    if (pincode != null && pincode.trim().isNotEmpty) {
      queryParams['pincode'] = pincode.trim();
    }
    if (gender != null && gender.trim().isNotEmpty) {
      queryParams['gender'] = gender.trim();
    }

    final uri = Uri.parse("${baseUrl}api/contentList/getUsersByContentId");
    return uri.replace(queryParameters: queryParams).toString();
  }

  // Ratings & Reviews API
  static String getContentRatingAndReviews(dynamic contentId) =>
      "${baseUrl}api/content/$contentId";

  // Cast APIs
  static String getCastByContentId(dynamic contentId) =>
      "${baseUrl}api/Cast/getByContentId?contentId=$contentId";
  static String getCastByContentIdAndSeasonId(
          dynamic contentId, dynamic seasonId) =>
      "${baseUrl}api/Cast/getByContentIdAndSeasonId?contentId=$contentId&seasonId=$seasonId";
  static String getCastByShortId(dynamic shortId) =>
      "${baseUrl}api/Cast/getByShortId?shortId=$shortId";
}

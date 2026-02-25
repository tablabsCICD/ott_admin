class ApiConstant {
  static const String baseUrl =
      "http://ec2-13-201-5-93.ap-south-1.compute.amazonaws.com:8080/ott/";

  //loginPage
  static String login = "${baseUrl}user/email/login2";
  static String forgotPassword(mobileNumber) =>
      "${baseUrl}user/forgotPassword/findUserAndSendOTP?mobileNumber=$mobileNumber";
  static String verifyOtp(mobileNumber, otp) =>
      "${baseUrl}user/verifyOTP?mobileNumber=$mobileNumber&otp=$otp";
  static String resetPassword(mobileNumber, otp) =>
      "${baseUrl}user/resetPassword?mobileNumber=$mobileNumber&password=$otp";

  static String registration = '${baseUrl}user/RegisterUser';

  //DashboardPage
  static String dashboardCount = "${baseUrl}api/admin/dashboardCounts";
  static String allRevenue(startDate, endDate) =>
      "${baseUrl}api/admin/graph?startDate=$startDate&endDate=$endDate";
  static String userCountGraph(startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/adminLineCharts/userCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String purchaseCountGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/adminLineCharts/userContentPurchaseChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String mediaHouseCountGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/adminLineCharts/mediaHouseCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String promoterCountGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/adminLineCharts/promoterCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String approvedContentCountGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/adminLineCharts/contentApprovalCountChart?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String movieTypeChartData = "${baseUrl}api/admin/contentTypePieChart";
  static String revenueChartData =
      "${baseUrl}api/adminLineCharts/revenueSummary";
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
  static String editUserById = "${baseUrl}user/updateUserBy/%7Bid%7D";
  static String getUserById(id) => "${baseUrl}user/getUser/$id";
  static String deleteUserById(id) => "${baseUrl}user/deleteUserBy/$id";
  static String searchUser(char) => "${baseUrl}user/search?search=$char";

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

  //ManageVideoPage
  static String saveVideo = '${baseUrl}api/addContent';
  static String editVideoById(id) => "${baseUrl}api/contentList/update/$id";
  static String getAllVideo = "${baseUrl}api/ContentList/getAll";
  static String getVideoById(id) => "${baseUrl}api/ContentList/getById?id=$id";
  static String searchContent(char) =>
      "${baseUrl}api/searchByanyKey%20?search=$char";
  static String deleteVideoById(id) => "${baseUrl}api/deleteContentBy/$id";

  static String savePromoter = '${baseUrl}api/savePromoters';
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

  //ManageAccessPage
  static String savePromoterAccess = "${baseUrl}AccessControl/save";
  static String getPromoterAccess = "${baseUrl}AccessControl/getAll";
  static String editPromoterAccess = "${baseUrl}access-control/update";

  static String uploadImg = "${baseUrl}api/other/upload-file";
  static String uploadVideo = "${baseUrl}api/video/upload-raw?videoId=20";
  static String fetchLang = "${baseUrl}api/Languages/getAll";

  //ManagePromoterPercentage
  static String getPromoterPercentage =
      "${baseUrl}api/PromotersPercentageRate/getAll/pages";
  static String setPromoterPercentage =
      "${baseUrl}api/savePromotersPercentageRate";

  static String allPromoterRevenueGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/settelmentGraph/AllPromotersRevenueForAdmin?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isYear";
  static String topRevenueContentGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/adminLineCharts/top-revenue-content?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String contentRevenueGraph(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/contentList/graph?contentListId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String topRevenueContentGraphForMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String topRatedContentGraph(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/mediaHouseLineCharts/top-rated-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String transactionRevenueGraph(
          startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/admin/graph?startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String releaseMovieCountGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/promotersLineCharts/releaseMovieCountChart?mediaHouseid=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String viewCountGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/viewCountChartByMediaHouseId?mediahouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String revenueGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String reportAndDataForMediaHouse(id) =>
      "${baseUrl}api/mediaHouseLineCharts/getDetailsOfMovieByMediaHouseId?mediaHouseId=$id";

  static String weeklySettelementData = "${baseUrl}api/settelment/admin";
  static String weeklySettelementDataForMediaHouse(mediaHouseId) =>
      "${baseUrl}api/settelment/user/$mediaHouseId";
  static String reportAndData =
      "${baseUrl}api/adminLineCharts/getDetailsOfMovie";
  static String setPercentage = "${baseUrl}api/admin/saveMoviePercentAndRate";

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
}

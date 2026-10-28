import '../../../domain/entities/user.dart';

class UserPagination {
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const UserPagination({
    this.page = 0,
    this.size = 20,
    this.totalItems = 0,
    this.totalPages = 1,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory UserPagination.fromJson(Map<String, dynamic> json) {
    final pMap = json["pagination"] is Map<String, dynamic>
        ? json["pagination"] as Map<String, dynamic>
        : (json["data"] is Map<String, dynamic> &&
                json["data"]["pagination"] is Map<String, dynamic>)
            ? json["data"]["pagination"] as Map<String, dynamic>
            : (json["data"] is Map<String, dynamic>
                ? json["data"] as Map<String, dynamic>
                : json);

    final page = _parseInt(pMap["page"] ??
            pMap["currentPage"] ??
            pMap["pageNumber"] ??
            json["page"] ??
            json["currentPage"]) ??
        0;

    final size = _parseInt(pMap["size"] ??
            pMap["pageSize"] ??
            pMap["limit"] ??
            json["size"] ??
            json["pageSize"]) ??
        20;

    final totalItems = _parseInt(pMap["totalItems"] ??
            pMap["totalUsers"] ??
            pMap["totalCount"] ??
            pMap["total"] ??
            json["totalItems"] ??
            json["totalUsers"] ??
            json["totalCount"]) ??
        0;

    final totalPages = _parseInt(pMap["totalPages"] ??
            pMap["pages"] ??
            pMap["totalPage"] ??
            json["totalPages"] ??
            json["pages"]) ??
        (totalItems > 0 && size > 0 ? (totalItems / size).ceil() : 1);

    final hasNext = _parseBool(pMap["hasNext"] ?? json["hasNext"]) ??
        (page < (totalPages > 0 ? totalPages : 1) - 1);

    final hasPrevious = _parseBool(pMap["hasPrevious"] ?? json["hasPrevious"]) ??
        (page > 0);

    return UserPagination(
      page: page,
      size: size,
      totalItems: totalItems,
      totalPages: totalPages > 0 ? totalPages : 1,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final str = value.toString().toLowerCase();
    if (str == 'true' || str == '1') return true;
    if (str == 'false' || str == '0') return false;
    return null;
  }

  Map<String, dynamic> toJson() => {
        "page": page,
        "size": size,
        "totalItems": totalItems,
        "totalPages": totalPages,
        "hasNext": hasNext,
        "hasPrevious": hasPrevious,
      };
}

class GetAllUserResponse {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;
  UserPagination? pagination;

  GetAllUserResponse({
    this.message,
    this.data,
    this.statusCode,
    this.success,
    this.pagination,
  });

  factory GetAllUserResponse.fromJson(Map<String, dynamic> json) {
    Data? parsedData;
    if (json["data"] is Map<String, dynamic>) {
      parsedData = Data.fromJson(json["data"]);
    } else if (json["data"] is List) {
      parsedData = Data(
        users: (json["data"] as List)
            .whereType<Map<String, dynamic>>()
            .map((x) => User.fromJson(x))
            .toList(),
      );
    } else if (json["users"] is List || json["user"] is List) {
      parsedData = Data.fromJson(json);
    }

    UserPagination? parsedPagination;
    if (parsedData?.pagination != null) {
      parsedPagination = parsedData!.pagination;
    } else if (json["pagination"] != null) {
      parsedPagination = UserPagination.fromJson(json);
    } else if (json["data"] is Map<String, dynamic>) {
      parsedPagination =
          UserPagination.fromJson(json["data"] as Map<String, dynamic>);
    } else {
      parsedPagination = UserPagination.fromJson(json);
    }

    return GetAllUserResponse(
      message: json["message"]?.toString(),
      data: parsedData,
      statusCode: json["statusCode"] is int
          ? json["statusCode"]
          : int.tryParse(json["statusCode"]?.toString() ?? ''),
      success: json["success"] is bool
          ? json["success"]
          : (json["success"]?.toString() == 'true'),
      pagination: parsedPagination,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "statusCode": statusCode,
        "success": success,
        if (pagination != null) "pagination": pagination!.toJson(),
      };
}

class Data {
  List<User>? users;
  UserPagination? pagination;

  List<User>? get user => users;

  Data({
    this.users,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    List<User> userList = [];
    final rawUsers =
        json["users"] ?? json["user"] ?? json["items"] ?? json["content"];
    if (rawUsers is List) {
      userList = rawUsers
          .whereType<Map<String, dynamic>>()
          .map((x) => User.fromJson(x))
          .toList();
    }

    UserPagination? p;
    if (json.containsKey("pagination") ||
        json.containsKey("totalPages") ||
        json.containsKey("totalItems") ||
        json.containsKey("page") ||
        json.containsKey("hasNext") ||
        json.containsKey("hasPrevious")) {
      p = UserPagination.fromJson(json);
    }

    return Data(
      users: userList,
      pagination: p,
    );
  }

  Map<String, dynamic> toJson() => {
        "users": users == null
            ? []
            : List<dynamic>.from(users!.map((x) => x.toJson())),
        if (pagination != null) "pagination": pagination!.toJson(),
      };
}
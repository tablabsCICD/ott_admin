class PercentagePromoterResponse {
  String? message;
  Data? data;
  int? statusCode;
  dynamic total;
  bool? success;

  PercentagePromoterResponse({
    this.message,
    this.data,
    this.statusCode,
    this.total,
    this.success,
  });

  factory PercentagePromoterResponse.fromJson(Map<String, dynamic> json) => PercentagePromoterResponse(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    statusCode: json["statusCode"],
    total: json["total"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "total": total,
    "success": success,
  };
}

class Data {
  Genres? genres;

  Data({
    this.genres,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    genres: json["Genres"] == null ? null : Genres.fromJson(json["Genres"]),
  );

  Map<String, dynamic> toJson() => {
    "Genres": genres?.toJson(),
  };
}

class Genres {
  List<PromoterPercentage>? content;
  Pageable? pageable;
  bool? last;
  int? totalElements;
  int? totalPages;
  int? numberOfElements;
  bool? first;
  Sort? sort;
  int? size;
  int? number;
  bool? empty;

  Genres({
    this.content,
    this.pageable,
    this.last,
    this.totalElements,
    this.totalPages,
    this.numberOfElements,
    this.first,
    this.sort,
    this.size,
    this.number,
    this.empty,
  });

  factory Genres.fromJson(Map<String, dynamic> json) => Genres(
    content: json["content"] == null ? [] : List<PromoterPercentage>.from(json["content"]!.map((x) => PromoterPercentage.fromJson(x))),
    pageable: json["pageable"] == null ? null : Pageable.fromJson(json["pageable"]),
    last: json["last"],
    totalElements: json["totalElements"],
    totalPages: json["totalPages"],
    numberOfElements: json["numberOfElements"],
    first: json["first"],
    sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
    size: json["size"],
    number: json["number"],
    empty: json["empty"],
  );

  Map<String, dynamic> toJson() => {
    "content": content == null ? [] : List<dynamic>.from(content!.map((x) => x.toJson())),
    "pageable": pageable?.toJson(),
    "last": last,
    "totalElements": totalElements,
    "totalPages": totalPages,
    "numberOfElements": numberOfElements,
    "first": first,
    "sort": sort?.toJson(),
    "size": size,
    "number": number,
    "empty": empty,
  };
}

class PromoterPercentage {
  int? id;
  String? typeOfPromoters;
  double? viewsPercentage;
  double? newUserPercentage;
  int? date;
  bool? active;

  PromoterPercentage({
    this.id,
    this.typeOfPromoters,
    this.viewsPercentage,
    this.newUserPercentage,
    this.date,
    this.active,
  });

  factory PromoterPercentage.fromJson(Map<String, dynamic> json) => PromoterPercentage(
    id: json["id"],
    typeOfPromoters: json["typeOfPromoters"],
    viewsPercentage: json["viewsPercentage"]?.toDouble(),
    newUserPercentage: json["newUserPercentage"]?.toDouble(),
    date: json["date"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "typeOfPromoters": typeOfPromoters,
    "viewsPercentage": viewsPercentage,
    "newUserPercentage": newUserPercentage,
    "date": date,
    "active": active,
  };
}

class Pageable {
  Sort? sort;
  int? pageNumber;
  int? pageSize;
  int? offset;
  bool? paged;
  bool? unpaged;

  Pageable({
    this.sort,
    this.pageNumber,
    this.pageSize,
    this.offset,
    this.paged,
    this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
    sort: json["sort"] == null ? null : Sort.fromJson(json["sort"]),
    pageNumber: json["pageNumber"],
    pageSize: json["pageSize"],
    offset: json["offset"],
    paged: json["paged"],
    unpaged: json["unpaged"],
  );

  Map<String, dynamic> toJson() => {
    "sort": sort?.toJson(),
    "pageNumber": pageNumber,
    "pageSize": pageSize,
    "offset": offset,
    "paged": paged,
    "unpaged": unpaged,
  };
}

class Sort {
  bool? sorted;
  bool? unsorted;
  bool? empty;

  Sort({
    this.sorted,
    this.unsorted,
    this.empty,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
    sorted: json["sorted"],
    unsorted: json["unsorted"],
    empty: json["empty"],
  );

  Map<String, dynamic> toJson() => {
    "sorted": sorted,
    "unsorted": unsorted,
    "empty": empty,
  };
}

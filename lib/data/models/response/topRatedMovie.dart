class TopRatedMovie {
  String? message;
  Data? data;
  int? statusCode;
  bool? success;

  TopRatedMovie({
    this.message,
    this.data,
    this.statusCode,
    this.success,
  });

  factory TopRatedMovie.fromJson(Map<String, dynamic> json) => TopRatedMovie(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    statusCode: json["statusCode"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "statusCode": statusCode,
    "success": success,
  };
}

class Data {
  List<ContentWithRating>? contentWithRatings;

  Data({
    this.contentWithRatings,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    contentWithRatings: json["contentWithRatings"] == null ? [] : List<ContentWithRating>.from(json["contentWithRatings"]!.map((x) => ContentWithRating.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "contentWithRatings": contentWithRatings == null ? [] : List<dynamic>.from(contentWithRatings!.map((x) => x.toJson())),
  };
}

class ContentWithRating {
  double? avgRating;
  String? name;

  ContentWithRating({
    this.avgRating,
    this.name,
  });

  factory ContentWithRating.fromJson(Map<String, dynamic> json) => ContentWithRating(
    avgRating: json["avgRating"]??0.0,
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "avgRating": avgRating,
    "Name": name,
  };
}

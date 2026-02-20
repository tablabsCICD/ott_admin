class LanguageFile {
  String language;
  String fileUrl;

  LanguageFile({
    required this.language,
    required this.fileUrl,
  });

  factory LanguageFile.fromJson(Map<String, dynamic> json) {
    return LanguageFile(
      language: (json['language'] ?? '').toString(),
      fileUrl: (json['fileUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'fileUrl': fileUrl,
    };
  }
}

class ShortMaster {
  int? id;
  String? title;
  String? description;
  String? posterUrl;
  int? totalParts;
  int? coinsPerPart;
  String? creatorName;
  int? viewCount;
  int? likeCount;
  bool? isTrending;
  String? category;
  int? mediaHouseId;
  String? rentlDuration;
  dynamic uploadDateTime;
  dynamic createdAt;
  dynamic createdDate;
  List<LanguageFile> languageList;

  ShortMaster({
    this.id,
    this.title,
    this.description,
    this.posterUrl,
    this.totalParts,
    this.coinsPerPart,
    this.creatorName,
    this.viewCount,
    this.likeCount,
    this.isTrending,
    this.category,
    this.mediaHouseId,
    this.rentlDuration,
    this.uploadDateTime,
    this.createdAt,
    this.createdDate,
    this.languageList = const [],
  });

  factory ShortMaster.fromJson(Map<String, dynamic> json) {
    final rawLang = json['languageList'];
    return ShortMaster(
      id: _asInt(json['id']),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      posterUrl: json['posterUrl']?.toString(),
      totalParts: _asInt(json['totalParts']),
      coinsPerPart: _asInt(json['coinsPerPart']),
      creatorName: json['creatorName']?.toString(),
      viewCount: _asInt(json['viewCount']),
      likeCount: _asInt(json['likeCount']),
      isTrending: _asBool(json['isTrending']),
      category: json['category']?.toString(),
      mediaHouseId: _asInt(json['mediaHouseId']),
      rentlDuration: json['rentlDuration']?.toString(),
      uploadDateTime: json['uploadDateTime'],
      createdAt: json['createdAt'],
      createdDate: json['createdDate'],
      languageList: rawLang is List
          ? rawLang
              .map((e) => LanguageFile.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <LanguageFile>[],
    );
  }
}

class ShortPart {
  int? id;
  int? shortId;
  int? partNumber;
  String? title;
  int? coins;
  bool? isFreePreview;
  String? videoUrl;
  String? thumbnail;
  int? durationSec;
  int? views;
  int? likes;

  ShortPart({
    this.id,
    this.shortId,
    this.partNumber,
    this.title,
    this.coins,
    this.isFreePreview,
    this.videoUrl,
    this.thumbnail,
    this.durationSec,
    this.views,
    this.likes,
  });

  factory ShortPart.fromJson(Map<String, dynamic> json) {
    return ShortPart(
      id: _asInt(json['id']),
      shortId: _asInt(json['shortId']),
      partNumber: _asInt(json['partNumber']),
      title: json['title']?.toString(),
      coins: _asInt(json['coins']),
      isFreePreview: _asBool(json['isFreePreview']),
      videoUrl: json['videoUrl']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      durationSec: _asInt(json['durationSec']),
      views: _asInt(json['views']),
      likes: _asInt(json['likes']),
    );
  }
}

class ShortDetailPart {
  String? partId;
  int? partNumber;
  String? title;
  int? coins;
  bool? isLocked;
  bool? isPurchased;
  String? videoUrl;
  String? thumbnail;
  int? durationSec;
  int? views;
  int? likes;
  String? nextPartId;
  bool? autoPlayNext;
  bool? isFreePreview;
  bool? isLiked;

  ShortDetailPart({
    this.partId,
    this.partNumber,
    this.title,
    this.coins,
    this.isLocked,
    this.isPurchased,
    this.videoUrl,
    this.thumbnail,
    this.durationSec,
    this.views,
    this.likes,
    this.nextPartId,
    this.autoPlayNext,
    this.isFreePreview,
    this.isLiked,
  });

  factory ShortDetailPart.fromJson(Map<String, dynamic> json) {
    return ShortDetailPart(
      partId: json['partId']?.toString(),
      partNumber: _asInt(json['partNumber']),
      title: json['title']?.toString(),
      coins: _asInt(json['coins']),
      isLocked: _asBool(json['isLocked']) ?? _asBool(json['locked']),
      isPurchased: _asBool(json['isPurchased']) ?? _asBool(json['purchased']),
      videoUrl: json['videoUrl']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      durationSec: _asInt(json['durationSec']),
      views: _asInt(json['views']),
      likes: _asInt(json['likes']),
      nextPartId: json['nextPartId']?.toString(),
      autoPlayNext: _asBool(json['autoPlayNext']),
      isFreePreview:
          _asBool(json['isFreePreview']) ?? _asBool(json['freePreview']),
      isLiked: _asBool(json['isLiked']) ?? _asBool(json['liked']),
    );
  }
}

class ShortDetailData {
  int? id;
  String? title;
  String? description;
  String? poster;
  int? totalParts;
  int? coinsPerPart;
  String? creatorName;
  int? viewCount;
  int? likeCount;
  bool? isTrending;
  String? category;
  List<LanguageFile> languageList;
  List<ShortDetailPart> parts;
  String? rentlDuration;

  ShortDetailData({
    this.id,
    this.title,
    this.description,
    this.poster,
    this.totalParts,
    this.coinsPerPart,
    this.creatorName,
    this.viewCount,
    this.likeCount,
    this.isTrending,
    this.category,
    this.languageList = const [],
    this.parts = const [],
    this.rentlDuration,
  });

  factory ShortDetailData.fromJson(Map<String, dynamic> json) {
    final rawLang = json['languageList'];
    final rawParts = json['parts'];
    return ShortDetailData(
      id: _asInt(json['id']),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      poster: json['poster']?.toString() ?? json['posterUrl']?.toString(),
      totalParts: _asInt(json['totalParts']),
      coinsPerPart: _asInt(json['coinsPerPart']),
      creatorName: json['creatorName']?.toString(),
      viewCount: _asInt(json['viewCount']),
      likeCount: _asInt(json['likeCount']),
      isTrending: _asBool(json['isTrending']) ?? _asBool(json['trending']),
      category: json['category']?.toString(),
      languageList: rawLang is List
          ? rawLang
              .map((e) => LanguageFile.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <LanguageFile>[],
      parts: rawParts is List
          ? rawParts
              .map((e) => ShortDetailPart.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ShortDetailPart>[],
      rentlDuration: json['rentlDuration']?.toString(),
    );
  }
}

class ShortMastersResponse {
  String? message;
  List<ShortMaster> data;
  bool? success;

  ShortMastersResponse({this.message, this.data = const [], this.success});

  factory ShortMastersResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return ShortMastersResponse(
      message: json['message']?.toString(),
      success: _asBool(json['success']),
      data: rawData is List
          ? rawData
              .map((e) => ShortMaster.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ShortMaster>[],
    );
  }
}

class ShortMasterCreateResponse {
  String? message;
  ShortMaster? data;
  bool? success;

  ShortMasterCreateResponse({this.message, this.data, this.success});

  factory ShortMasterCreateResponse.fromJson(Map<String, dynamic> json) {
    return ShortMasterCreateResponse(
      message: json['message']?.toString(),
      success: _asBool(json['success']),
      data: json['data'] is Map<String, dynamic>
          ? ShortMaster.fromJson(json['data'])
          : null,
    );
  }
}

class ShortPartCreateResponse {
  String? message;
  ShortPart? data;
  bool? success;

  ShortPartCreateResponse({this.message, this.data, this.success});

  factory ShortPartCreateResponse.fromJson(Map<String, dynamic> json) {
    return ShortPartCreateResponse(
      message: json['message']?.toString(),
      success: _asBool(json['success']),
      data: json['data'] is Map<String, dynamic>
          ? ShortPart.fromJson(json['data'])
          : null,
    );
  }
}

class ShortDetailResponse {
  String? message;
  ShortDetailData? data;
  bool? success;

  ShortDetailResponse({this.message, this.data, this.success});

  factory ShortDetailResponse.fromJson(Map<String, dynamic> json) {
    return ShortDetailResponse(
      message: json['message']?.toString(),
      success: _asBool(json['success']),
      data: json['data'] is Map<String, dynamic>
          ? ShortDetailData.fromJson(json['data'])
          : null,
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

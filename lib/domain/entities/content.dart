import 'dart:convert';

class Content {
  int? id;
  String? title;
  String? description;
  int? runtime;
  dynamic releaseDate;
  double? ratings;
  double? price;
  List<String>? languageList;
  List<String>? castList;
  List<String>? genreList;
  List<String>? directorList;
  int? views;
  int? totalPurchase;
  double? totalRevenue;
  double? adminRevnue;
  double? mediaHouseRevenue;
  String? ageRating;
  List<String>? posterUrlList;
  String? teaserUrl;
  String? trailerUrl;
  String? contentUrl;
  String? approvalStatus;
  String? type;
  String? sensorCertificate;
  bool? isFeatured;
  Availability? availability;
  List<String>? audioFormatList;
  List<String>? subtitleLanguageList;
  Map<String, String>? languageAudioUrls;
  Map<String, String>? subtitleLanguageUrls;
  bool? isDownloadable;
  String? uploadDateTime;
  String? approvedDateTime;
  String? mediaHouseName;
  int? mediaHouseId;
  int? ratingCount;
  String? rentlDuration;
  double? adminIncentivePecentage;
  double? mediaHouseIncentivePecentage;
  String? reason;
  String? agreementUrl;
  String? aggrementDocument;
  bool? isAggrement;
  String? registrationFeeDetails;

  String? get resolvedAgreementUrl {
    if (agreementUrl != null && agreementUrl!.trim().isNotEmpty) {
      return agreementUrl!.trim();
    }
    if (aggrementDocument != null && aggrementDocument!.trim().isNotEmpty) {
      return aggrementDocument!.trim();
    }
    if (registrationFeeDetails != null && registrationFeeDetails!.trim().isNotEmpty) {
      final regExp = RegExp(r'Agreement Upload URL:\s*([^;]+)', caseSensitive: false);
      final match = regExp.firstMatch(registrationFeeDetails!);
      if (match != null) {
        final url = match.group(1)?.trim();
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
    }
    if (sensorCertificate != null && sensorCertificate!.trim().isNotEmpty) {
      final cert = sensorCertificate!.trim().toLowerCase();
      if (cert.endsWith('.pdf') ||
          cert.endsWith('.doc') ||
          cert.endsWith('.docx') ||
          cert.contains('agreement') ||
          cert.contains('contract') ||
          cert.contains('mou')) {
        return sensorCertificate!.trim();
      }
      if (!cert.contains('censor') && !cert.contains('certificate')) {
        return sensorCertificate!.trim();
      }
    }
    return null;
  }

  Content(
      {this.id,
      this.title,
      this.description,
      this.runtime,
      this.releaseDate,
      this.ratings,
      this.price,
      this.languageList,
      this.castList,
      this.genreList,
      this.directorList,
      this.views,
      this.totalPurchase,
      this.totalRevenue,
      this.adminRevnue,
      this.mediaHouseRevenue,
      this.ageRating,
      this.posterUrlList,
      this.teaserUrl,
      this.trailerUrl,
      this.contentUrl,
      this.approvalStatus,
      this.type,
      this.sensorCertificate,
      this.isFeatured,
      this.availability,
      this.audioFormatList,
      this.subtitleLanguageList,
      this.languageAudioUrls,
      this.subtitleLanguageUrls,
      this.isDownloadable,
      this.uploadDateTime,
      this.approvedDateTime,
      this.mediaHouseName,
      this.mediaHouseId,
      this.ratingCount,
      this.rentlDuration,
      this.adminIncentivePecentage,
      this.mediaHouseIncentivePecentage,
      this.reason,
      this.agreementUrl,
      this.aggrementDocument,
      this.isAggrement,
      this.registrationFeeDetails});

  Content copyWith({
    int? id,
    String? title,
    String? description,
    int? runtime,
    dynamic releaseDate,
    double? ratings,
    double? price,
    List<String>? languageList,
    List<String>? castList,
    List<String>? genreList,
    List<String>? directorList,
    int? views,
    int? totalPurchase,
    double? totalRevenue,
    double? adminRevnue,
    double? mediaHouseRevenue,
    String? ageRating,
    List<String>? posterUrlList,
    String? teaserUrl,
    String? trailerUrl,
    String? contentUrl,
    String? approvalStatus,
    String? type,
    String? sensorCertificate,
    bool? isFeatured,
    Availability? availability,
    List<String>? audioFormatList,
    List<String>? subtitleLanguageList,
    Map<String, String>? languageAudioUrls,
    Map<String, String>? subtitleLanguageUrls,
    bool? isDownloadable,
    String? uploadDateTime,
    String? approvedDateTime,
    String? mediaHouseName,
    int? mediaHouseId,
    int? ratingCount,
    String? rentlDuration,
    double? adminIncentivePecentage,
    double? mediaHouseIncentivePecentage,
    String? reason,
    String? agreementUrl,
    String? aggrementDocument,
    bool? isAggrement,
    String? registrationFeeDetails,
  }) {
    return Content(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      runtime: runtime ?? this.runtime,
      releaseDate: releaseDate ?? this.releaseDate,
      ratings: ratings ?? this.ratings,
      price: price ?? this.price,
      languageList: languageList ?? this.languageList,
      castList: castList ?? this.castList,
      genreList: genreList ?? this.genreList,
      directorList: directorList ?? this.directorList,
      views: views ?? this.views,
      totalPurchase: totalPurchase ?? this.totalPurchase,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      adminRevnue: adminRevnue ?? this.adminRevnue,
      mediaHouseRevenue: mediaHouseRevenue ?? this.mediaHouseRevenue,
      ageRating: ageRating ?? this.ageRating,
      posterUrlList: posterUrlList ?? this.posterUrlList,
      teaserUrl: teaserUrl ?? this.teaserUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      type: type ?? this.type,
      sensorCertificate: sensorCertificate ?? this.sensorCertificate,
      isFeatured: isFeatured ?? this.isFeatured,
      availability: availability ?? this.availability,
      audioFormatList: audioFormatList ?? this.audioFormatList,
      subtitleLanguageList: subtitleLanguageList ?? this.subtitleLanguageList,
      languageAudioUrls: languageAudioUrls ?? this.languageAudioUrls,
      subtitleLanguageUrls: subtitleLanguageUrls ?? this.subtitleLanguageUrls,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      uploadDateTime: uploadDateTime ?? this.uploadDateTime,
      approvedDateTime: approvedDateTime ?? this.approvedDateTime,
      mediaHouseName: mediaHouseName ?? this.mediaHouseName,
      mediaHouseId: mediaHouseId ?? this.mediaHouseId,
      ratingCount: ratingCount ?? this.ratingCount,
      rentlDuration: rentlDuration ?? this.rentlDuration,
      adminIncentivePecentage:
          adminIncentivePecentage ?? this.adminIncentivePecentage,
      mediaHouseIncentivePecentage:
          mediaHouseIncentivePecentage ?? this.mediaHouseIncentivePecentage,
      reason: reason ?? this.reason,
      agreementUrl: agreementUrl ?? this.agreementUrl,
      aggrementDocument: aggrementDocument ?? this.aggrementDocument,
      isAggrement: isAggrement ?? this.isAggrement,
      registrationFeeDetails: registrationFeeDetails ?? this.registrationFeeDetails,
    );
  }

  Content mergeWith(Content? full) {
    if (full == null) return this;
    return copyWith(
      title: (full.title != null && full.title!.trim().isNotEmpty) ? full.title : title,
      description: (full.description != null && full.description!.trim().isNotEmpty) ? full.description : description,
      runtime: (full.runtime != null && full.runtime! > 0) ? full.runtime : runtime,
      releaseDate: full.releaseDate ?? releaseDate,
      ratings: full.ratings ?? ratings,
      price: full.price ?? price,
      totalPurchase: full.totalPurchase ?? totalPurchase,
      totalRevenue: full.totalRevenue ?? totalRevenue,
      adminRevnue: full.adminRevnue ?? adminRevnue,
      mediaHouseRevenue: full.mediaHouseRevenue ?? mediaHouseRevenue,
      views: (full.views != null && full.views! > 0) ? full.views : views,
      ageRating: (full.ageRating != null && full.ageRating!.trim().isNotEmpty) ? full.ageRating : ageRating,
      type: (full.type != null && full.type!.trim().isNotEmpty) ? full.type : type,
      approvalStatus: (full.approvalStatus != null && full.approvalStatus!.trim().isNotEmpty) ? full.approvalStatus : approvalStatus,
      rentlDuration: (full.rentlDuration != null && full.rentlDuration!.trim().isNotEmpty) ? full.rentlDuration : rentlDuration,
      languageList: (full.languageList != null && full.languageList!.isNotEmpty) ? full.languageList : languageList,
      genreList: (full.genreList != null && full.genreList!.isNotEmpty) ? full.genreList : genreList,
      castList: (full.castList != null && full.castList!.isNotEmpty) ? full.castList : castList,
      directorList: (full.directorList != null && full.directorList!.isNotEmpty) ? full.directorList : directorList,
      posterUrlList: (full.posterUrlList != null && full.posterUrlList!.isNotEmpty) ? full.posterUrlList : posterUrlList,
      teaserUrl: (full.teaserUrl != null && full.teaserUrl!.trim().isNotEmpty) ? full.teaserUrl : teaserUrl,
      trailerUrl: (full.trailerUrl != null && full.trailerUrl!.trim().isNotEmpty) ? full.trailerUrl : trailerUrl,
      contentUrl: (full.contentUrl != null && full.contentUrl!.trim().isNotEmpty) ? full.contentUrl : contentUrl,
      sensorCertificate: (full.sensorCertificate != null && full.sensorCertificate!.trim().isNotEmpty) ? full.sensorCertificate : sensorCertificate,
      agreementUrl: (full.agreementUrl != null && full.agreementUrl!.trim().isNotEmpty)
          ? full.agreementUrl
          : (full.aggrementDocument != null && full.aggrementDocument!.trim().isNotEmpty)
              ? full.aggrementDocument
              : (full.resolvedAgreementUrl != null && full.resolvedAgreementUrl!.trim().isNotEmpty)
                  ? full.resolvedAgreementUrl
                  : (agreementUrl != null && agreementUrl!.trim().isNotEmpty)
                      ? agreementUrl
                      : (aggrementDocument != null && aggrementDocument!.trim().isNotEmpty)
                          ? aggrementDocument
                          : resolvedAgreementUrl,
      aggrementDocument: (full.aggrementDocument != null && full.aggrementDocument!.trim().isNotEmpty)
          ? full.aggrementDocument
          : aggrementDocument,
      isAggrement: full.isAggrement ?? isAggrement,
      registrationFeeDetails: (full.registrationFeeDetails != null && full.registrationFeeDetails!.trim().isNotEmpty)
          ? full.registrationFeeDetails
          : registrationFeeDetails,
      mediaHouseId: full.mediaHouseId ?? mediaHouseId,
      mediaHouseName: (full.mediaHouseName != null && full.mediaHouseName!.trim().isNotEmpty) ? full.mediaHouseName : mediaHouseName,
      ratingCount: full.ratingCount ?? ratingCount,
      adminIncentivePecentage: full.adminIncentivePecentage ?? adminIncentivePecentage,
      mediaHouseIncentivePecentage: full.mediaHouseIncentivePecentage ?? mediaHouseIncentivePecentage,
      reason: (full.reason != null && full.reason!.trim().isNotEmpty) ? full.reason : reason,
      isDownloadable: full.isDownloadable ?? isDownloadable,
      isFeatured: full.isFeatured ?? isFeatured,
      availability: full.availability ?? availability,
      audioFormatList: (full.audioFormatList != null && full.audioFormatList!.isNotEmpty) ? full.audioFormatList : audioFormatList,
      subtitleLanguageList: (full.subtitleLanguageList != null && full.subtitleLanguageList!.isNotEmpty) ? full.subtitleLanguageList : subtitleLanguageList,
      languageAudioUrls: (full.languageAudioUrls != null && full.languageAudioUrls!.isNotEmpty) ? full.languageAudioUrls : languageAudioUrls,
      subtitleLanguageUrls: (full.subtitleLanguageUrls != null && full.subtitleLanguageUrls!.isNotEmpty) ? full.subtitleLanguageUrls : subtitleLanguageUrls,
      uploadDateTime: (full.uploadDateTime != null && full.uploadDateTime!.trim().isNotEmpty) ? full.uploadDateTime : uploadDateTime,
      approvedDateTime: (full.approvedDateTime != null && full.approvedDateTime!.trim().isNotEmpty) ? full.approvedDateTime : approvedDateTime,
    );
  }

  factory Content.fromJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> json = rawJson;
    if (json.containsKey("data") && json["data"] is Map<String, dynamic>) {
      json = json["data"] as Map<String, dynamic>;
    } else if (json.containsKey("data") && json["data"] is Map) {
      json = Map<String, dynamic>.from(json["data"] as Map);
    }

    for (final wrapperKey in [
      "ContentList",
      "contentList",
      "content",
      "Content",
      "movie",
      "Movie",
      "shortFilm",
      "ShortFilm",
      "short_film",
      "short",
      "Short",
      "video",
      "Video",
      "film",
      "Film",
      "series",
      "Series",
    ]) {
      if (json.containsKey(wrapperKey)) {
        final val = json[wrapperKey];
        if (val is Map<String, dynamic>) {
          final merged = Map<String, dynamic>.from(val);
          for (final e in json.entries) {
            if (e.key != wrapperKey && !merged.containsKey(e.key)) {
              merged[e.key] = e.value;
            }
          }
          json = merged;
          break;
        } else if (val is Map) {
          final merged = Map<String, dynamic>.from(val);
          for (final e in json.entries) {
            if (e.key != wrapperKey && !merged.containsKey(e.key)) {
              merged[e.key] = e.value;
            }
          }
          json = merged;
          break;
        } else if (val is List && val.isNotEmpty && val.first is Map) {
          final merged = Map<String, dynamic>.from(val.first as Map);
          for (final e in json.entries) {
            if (e.key != wrapperKey && !merged.containsKey(e.key)) {
              merged[e.key] = e.value;
            }
          }
          json = merged;
          break;
        }
      }
    }

    return Content(
      id: _asInt(json["id"] ?? json["Id"] ?? json["contentId"] ?? json["ContentId"] ?? json["seriesId"] ?? json["movieId"]),
      title: _asString(json["title"] ?? json["Title"] ?? json["name"] ?? json["Name"] ?? json["seriesName"] ?? json["movieName"]),
      description: _asString(json["description"] ?? json["Description"] ?? json["desc"] ?? json["Desc"] ?? json["synopsis"] ?? json["overview"]),
      runtime: _asInt(json["runtime"] ?? json["Runtime"] ?? json["runTime"] ?? json["RunTime"] ?? json["duration"] ?? json["Duration"]),
      releaseDate: json["releaseDate"] ?? json["ReleaseDate"] ?? json["release_date"] ?? json["releasedDate"] ?? json["publishDate"],
      ratings: _asDouble(json["ratings"] ?? json["Ratings"] ?? json["rating"] ?? json["Rating"] ?? json["avgRating"]),
      price: _asDouble(json["price"] ?? json["Price"] ?? json["amount"] ?? json["coins"]),
      languageList: _asStringList(json["languageList"] ?? json["LanguageList"] ?? json["languages"] ?? json["Languages"] ?? json["language"] ?? json["Language"]),
      castList: _asStringList(json["castList"] ?? json["CastList"] ?? json["cast"] ?? json["Cast"] ?? json["casts"] ?? json["Casts"] ?? json["actors"] ?? json["castCrew"]),
      genreList: _asStringList(json["genreList"] ?? json["GenreList"] ?? json["genres"] ?? json["Genres"] ?? json["genre"] ?? json["Genre"]),
      directorList: _asStringList(json["directorList"] ?? json["DirectorList"] ?? json["directors"] ?? json["Directors"] ?? json["director"] ?? json["Director"]),
      views: _asInt(json["views"] ?? json["Views"] ?? json["viewCount"] ?? json["totalViews"]),
      totalPurchase: _asInt(json["totalPurchase"] ?? json["TotalPurchase"] ?? json["purchases"] ?? json["Purchases"] ?? json["totalPurchases"] ?? json["purchasedCount"]),
      totalRevenue: _asDouble(json["totalRevenue"] ?? json["TotalRevenue"] ?? json["revenue"] ?? json["Revenue"]),
      adminRevnue: _asDouble(json["AdminRevnue"] ?? json["adminRevenue"] ?? json["adminRevnue"] ?? json["AdminRevenue"] ?? json["AdminRevenue"]),
      mediaHouseRevenue: _asDouble(json["mediaHouseRevenue"] ?? json["MediaHouseRevenue"] ?? json["productionHouseRevenue"] ?? json["ProductionHouseRevenue"]),
      ageRating: _asString(json["ageRating"] ?? json["AgeRating"] ?? json["age_rating"] ?? json["censorRating"] ?? json["ratingCertificate"]),
      posterUrlList: _asStringList(json["posterUrlList"] ?? json["PosterUrlList"] ?? json["posters"] ?? json["Posters"] ?? json["posterList"] ?? json["PosterList"] ?? json["posterUrls"] ?? json["PosterUrls"] ?? json["posterUrl"] ?? json["poster"] ?? json["bannerUrl"] ?? json["thumbnailUrl"]),
      teaserUrl: _asString(json["teaserUrl"] ?? json["TeaserUrl"] ?? json["teaser"] ?? json["Teaser"] ?? json["teaserURL"]),
      trailerUrl: _asString(json["trailerUrl"] ?? json["TrailerUrl"] ?? json["trailer"] ?? json["Trailer"] ?? json["trailerURL"] ?? json["teaserUrl"] ?? json["TeaserUrl"]),
      contentUrl: _asString(json["contentUrl"] ?? json["ContentUrl"] ?? json["videoUrl"] ?? json["VideoUrl"] ?? json["movieUrl"] ?? json["MovieUrl"] ?? json["url"] ?? json["Url"] ?? json["episodeUrl"]),
      approvalStatus: _asString(json["approvalStatus"] ?? json["ApprovalStatus"] ?? json["status"] ?? json["Status"] ?? json["approval"]),
      type: _asString(json["type"] ?? json["Type"] ?? json["contentType"] ?? json["ContentType"] ?? json["content_type"]),
      sensorCertificate: _asString(json["sensorCertificate"] ?? json["SensorCertificate"] ?? json["censorCertificate"] ?? json["CensorCertificate"] ?? json["certificate"] ?? json["Certificate"] ?? json["censor_certificate"] ?? json["sensor_certificate"]),
      isFeatured: _asBool(json["isFeatured"] ?? json["IsFeatured"]),
      availability: _parseAvailability(json["availability"] ?? json["Availability"]),
      audioFormatList: _asStringList(json["audioFormatList"] ?? json["AudioFormatList"] ?? json["audioFormats"] ?? json["AudioFormats"]),
      subtitleLanguageList: _asStringList(json["subtitleLanguageList"] ?? json["SubtitleLanguageList"] ?? json["subtitles"] ?? json["Subtitles"] ?? json["subtitleLanguages"] ?? json["SubtitleLanguages"]),
      languageAudioUrls: _extractAudioUrls(json["languageList"] ?? json["LanguageList"] ?? json["languageAudioUrls"]),
      subtitleLanguageUrls: _extractSubtitleUrls(json["subtitleLanguageList"] ?? json["SubtitleLanguageList"] ?? json["subtitleLanguageUrls"] ?? json["subtitles"]),
      isDownloadable: _asBool(json["isDownloadable"] ?? json["IsDownloadable"]),
      uploadDateTime: _asString(json["uploadDateTime"] ?? json["UploadDateTime"] ?? json["createdDate"] ?? json["createdAt"]),
      approvedDateTime: _asString(json["approvedDateTime"] ?? json["ApprovedDateTime"] ?? json["approvalDate"]),
      mediaHouseName: _parseMediaHouseName(json["mediaHouseName"] ?? json["MediaHouseName"] ?? json["productionHouse"] ?? json["ProductionHouse"] ?? json["productionHouseName"] ?? json["mediaHouse"]),
      mediaHouseId: _asInt(json["mediaHouseId"] ?? json["MediaHouseId"] ?? json["productionHouseId"] ?? (json["mediaHouse"] is Map ? json["mediaHouse"]["id"] : null)),
      ratingCount: _asInt(json["ratingCount"] ?? json["RatingCount"] ?? json["ratingsCount"] ?? json["reviewsCount"]),
      rentlDuration: _asString(json["rentlDuration"] ?? json["RentlDuration"] ?? json["rentalDuration"] ?? json["RentalDuration"]),
      adminIncentivePecentage: _asDouble(json["adminIncentivePecentage"] ?? json["AdminIncentivePecentage"] ?? json["adminPercentage"] ?? json["adminShare"]),
      mediaHouseIncentivePecentage:
          _asDouble(json["mediaHouseIncentivePecentage"] ?? json["MediaHouseIncentivePecentage"] ?? json["mediaHousePercentage"] ?? json["mediaHouseShare"] ?? json["productionHousePercentage"]),
      reason: _asString(json["reason"] ?? json["Reason"] ?? json["rejectReason"]),
      aggrementDocument: _asString(json["aggrementDocument"] ??
          json["AggrementDocument"] ??
          json["aggrement_document"] ??
          json["aggrementUrl"] ??
          json["aggrement_url"] ??
          json["aggrementDoc"] ??
          json["aggrement_doc"]),
      isAggrement: _asBool(json["isAggrement"] ?? json["IsAggrement"] ?? json["is_aggrement"]),
      registrationFeeDetails: _asString(json["registrationFeeDetails"] ??
          json["RegistrationFeeDetails"] ??
          json["registration_fee_details"]),
      agreementUrl: _extractAgreementUrl(rawJson) ?? _extractAgreementUrl(json),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "runtime": runtime,
        "releaseDate": releaseDate,
        "ratings": ratings,
        "price": price,
        "languageList": languageList == null
            ? []
            : languageList!
                .map((lang) => lang.trim())
                .where((lang) => lang.isNotEmpty)
                .map((lang) {
                  final url = languageAudioUrls?[lang]?.trim();
                  return {
                    "language": lang,
                    if (url != null && url.isNotEmpty) "fileUrl": url,
                  };
                })
                .toList(),
        "castList":
            castList == null ? [] : List<dynamic>.from(castList!.map((x) => x)),
        "genreList": genreList == null
            ? []
            : List<dynamic>.from(genreList!.map((x) => x)),
        "directorList": directorList == null
            ? []
            : List<dynamic>.from(directorList!.map((x) => x)),
        "views": views,
        "totalPurchase": totalPurchase,
        "totalRevenue": totalRevenue,
        "AdminRevnue": adminRevnue,
        "mediaHouseRevenue": mediaHouseRevenue,
        "ageRating": ageRating,
        "posterUrlList": posterUrlList == null
            ? []
            : List<dynamic>.from(posterUrlList!.map((x) => x)),
        "teaserUrl": teaserUrl,
        "trailerUrl": trailerUrl,
        "contentUrl": contentUrl,
        "approvalStatus": approvalStatus,
        "type": type,
        "sensorCertificate": sensorCertificate,
        "isFeatured": isFeatured,
        "availability": availability?.toJson(),
        "audioFormatList": audioFormatList == null
            ? []
            : List<dynamic>.from(audioFormatList!.map((x) => x)),
        "subtitleLanguageList": subtitleLanguageList == null
            ? []
            : List<String>.from(subtitleLanguageList!.map((sub) => sub.trim()).where((sub) => sub.isNotEmpty)),
        "isDownloadable": isDownloadable,
        "uploadDateTime": uploadDateTime,
        "approvedDateTime": approvedDateTime,
        "mediaHouseName": mediaHouseName,
        "mediaHouseId": mediaHouseId,
        "ratingCount": ratingCount,
        "rentlDuration": rentlDuration,
        "adminIncentivePecentage": adminIncentivePecentage,
        "mediaHouseIncentivePecentage": mediaHouseIncentivePecentage,
        "reason": reason,
        if (aggrementDocument != null && aggrementDocument!.isNotEmpty)
          "aggrementDocument": aggrementDocument,
        if (isAggrement != null) "isAggrement": isAggrement,
        if (registrationFeeDetails != null && registrationFeeDetails!.isNotEmpty)
          "registrationFeeDetails": registrationFeeDetails,
        if (resolvedAgreementUrl != null && resolvedAgreementUrl!.isNotEmpty)
          "agreementUrl": resolvedAgreementUrl,
      };
}

String? _extractAgreementUrl(Map<String, dynamic> json) {
  final directKeys = [
    "agreementUrl",
    "AgreementUrl",
    "agreement_url",
    "Agreement_Url",
    "agreement",
    "Agreement",
    "aggrementDocument",
    "AggrementDocument",
    "aggrement_document",
    "aggrementDoc",
    "aggrement_doc",
    "aggrementUrl",
    "aggrement_url",
    "AggrementUrl",
    "aggrement",
    "Aggrement",
    "aggrementFile",
    "aggrement_file",
    "agreementFile",
    "AgreementFile",
    "agreement_file",
    "Agreement_File",
    "agreementDoc",
    "agreement_doc",
    "agreementDocument",
    "agreement_document",
    "agreementPath",
    "agreement_path",
    "productionHouseAgreement",
    "production_house_agreement",
    "ProductionHouseAgreement",
    "mediaHouseAgreement",
    "media_house_agreement",
    "phAgreement",
    "ph_agreement",
    "phAgreementUrl",
    "ph_agreement_url",
    "movieAgreement",
    "movie_agreement",
    "shortFilmAgreement",
    "short_film_agreement",
    "shortAgreement",
    "short_agreement",
    "signedAgreement",
    "signed_agreement",
    "signedAgreementUrl",
    "signed_agreement_url",
    "contractUrl",
    "contract_url",
    "contract",
    "Contract",
    "contractFile",
    "contract_file",
    "documentUrl",
    "document_url",
    "docUrl",
    "doc_url",
    "document",
    "Document",
    "pdfUrl",
    "pdf_url",
  ];

  for (final key in directKeys) {
    if (json.containsKey(key)) {
      final val = _asString(json[key]);
      if (val != null && val.isNotEmpty) return val;
    }
  }

  // Check registrationFeeDetails for Agreement Upload URL
  final feeDetails = _asString(
    json["registrationFeeDetails"] ??
    json["RegistrationFeeDetails"] ??
    json["registration_fee_details"] ??
    json["feeDetails"] ??
    json["FeeDetails"],
  );
  if (feeDetails != null && feeDetails.isNotEmpty) {
    final regExp = RegExp(r'Agreement Upload URL:\s*([^;]+)', caseSensitive: false);
    final match = regExp.firstMatch(feeDetails);
    if (match != null) {
      final url = match.group(1)?.trim();
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }
  }

  // Nested in content wrappers: ContentList, contentList, shortFilm, movie, content, video
  for (final wrapper in [
    "ContentList",
    "contentList",
    "shortFilm",
    "short_film",
    "ShortFilm",
    "movie",
    "content",
    "video",
    "data"
  ]) {
    if (json.containsKey(wrapper)) {
      final val = json[wrapper];
      if (val is Map) {
        final nested = val.map((k, v) => MapEntry(k.toString(), v));
        final url = _extractAgreementUrl(nested);
        if (url != null && url.isNotEmpty) return url;
      } else if (val is List && val.isNotEmpty && val.first is Map) {
        final nested = (val.first as Map).map((k, v) => MapEntry(k.toString(), v));
        final url = _extractAgreementUrl(nested);
        if (url != null && url.isNotEmpty) return url;
      }
    }
  }

  // Nested in mediaHouse / productionHouse objects
  final nestedEntities = [
    json["mediaHouse"],
    json["MediaHouse"],
    json["productionHouse"],
    json["ProductionHouse"],
  ];
  for (final entity in nestedEntities) {
    if (entity is Map) {
      final map = entity.map((k, v) => MapEntry(k.toString(), v));
      for (final key in directKeys) {
        if (map.containsKey(key)) {
          final val = _asString(map[key]);
          if (val != null && val.isNotEmpty) return val;
        }
      }
    }
  }

  // Nested in documents / files lists
  final documents = json["documents"] ?? json["Documents"] ?? json["files"] ?? json["Files"];
  if (documents is List) {
    for (final doc in documents) {
      if (doc is Map) {
        final type = (doc["type"] ?? doc["name"] ?? doc["title"] ?? "").toString().toLowerCase();
        final url = _asString(doc["url"] ?? doc["fileUrl"] ?? doc["path"] ?? doc["documentUrl"]);
        if ((type.contains("agreement") || type.contains("contract")) && url != null) {
          return url;
        }
      }
    }
  }

  // Check if sensorCertificate has an agreement document
  final sensorCert = _asString(
    json["sensorCertificate"] ??
    json["SensorCertificate"] ??
    json["censorCertificate"] ??
    json["CensorCertificate"]
  );
  if (sensorCert != null && sensorCert.isNotEmpty) {
    final lower = sensorCert.toLowerCase();
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.contains('agreement') ||
        lower.contains('contract') ||
        lower.contains('mou')) {
      return sensorCert;
    }
  }

  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final str = value.toString().trim().replaceAll(',', '');
  final asDouble = double.tryParse(str);
  return asDouble?.toInt() ?? int.tryParse(str);
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final str = value.toString().trim().replaceAll(',', '');
  return double.tryParse(str);
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == "true" || normalized == "1") return true;
  if (normalized == "false" || normalized == "0") return false;
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}

String? _parseMediaHouseName(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return _asString(value["mediaHouseName"] ??
        value["MediaHouseName"] ??
        value["name"] ??
        value["Name"] ??
        value["productionHouse"] ??
        value["productionHouseName"] ??
        value["title"]);
  }
  if (value is String) {
    final str = value.trim();
    if (str.isEmpty || str == 'null' || str == 'undefined') return null;
    if (str.startsWith('{') && str.endsWith('}')) {
      try {
        final decoded = json.decode(str);
        if (decoded is Map) {
          return _asString(decoded["mediaHouseName"] ??
              decoded["MediaHouseName"] ??
              decoded["name"] ??
              decoded["Name"] ??
              decoded["productionHouse"] ??
              decoded["productionHouseName"] ??
              decoded["title"]);
        }
      } catch (_) {}
      final match = RegExp(r'mediaHouseName:\s*([^,}]+)').firstMatch(str);
      if (match != null && match.group(1)?.trim().isNotEmpty == true) {
        return match.group(1)!.trim();
      }
      final nameMatch = RegExp(r'name:\s*([^,}]+)').firstMatch(str);
      if (nameMatch != null && nameMatch.group(1)?.trim().isNotEmpty == true) {
        return nameMatch.group(1)!.trim();
      }
    }
    return str;
  }
  return value.toString().trim();
}

List<String> _asStringList(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    final str = value.trim();
    if (str.isEmpty) return [];
    if (str.startsWith('[') && str.endsWith(']')) {
      try {
        final decoded = json.decode(str);
        if (decoded is List) return _asStringList(decoded);
      } catch (_) {}
    }
    if (str.contains(',')) {
      return str.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [str];
  }
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            return (item["language"] ??
                    item["name"] ??
                    item["value"] ??
                    item["title"] ??
                    item["genreName"] ??
                    item["genre"] ??
                    item["castName"] ??
                    item["actorName"] ??
                    "")
                .toString();
          }
          return item.toString();
        })
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return [];
}

Map<String, String>? _extractAudioUrls(dynamic value) {
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
  if (value is List) {
    final map = <String, String>{};
    for (final item in value) {
      if (item is Map) {
        final lang = (item["language"] ?? item["name"] ?? item["value"] ?? "").toString().trim();
        final url = (item["fileUrl"] ?? item["audioUrl"] ?? item["url"] ?? "").toString().trim();
        if (lang.isNotEmpty && url.isNotEmpty) {
          map[lang] = url;
        }
      }
    }
    return map.isNotEmpty ? map : null;
  }
  return null;
}

Map<String, String>? _extractSubtitleUrls(dynamic value) {
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
  if (value is List) {
    final map = <String, String>{};
    for (final item in value) {
      if (item is Map) {
        final lang = (item["language"] ?? item["name"] ?? item["value"] ?? "").toString().trim();
        final url = (item["fileUrl"] ?? item["subtitleUrl"] ?? item["url"] ?? "").toString().trim();
        if (lang.isNotEmpty && url.isNotEmpty) {
          map[lang] = url;
        }
      }
    }
    return map.isNotEmpty ? map : null;
  }
  return null;
}

Availability? _parseAvailability(dynamic value) {
  if (value == null) return null;
  if (value is Availability) return value;
  if (value is Map<String, dynamic>) {
    return Availability.fromJson(value);
  }
  if (value is Map) {
    return Availability.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

class Availability {
  List<String>? regions;
  List<String>? platforms;

  Availability({
    this.regions,
    this.platforms,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
        regions: json["regions"] == null
            ? []
            : List<String>.from(json["regions"]!.map((x) => x)),
        platforms: json["platforms"] == null
            ? []
            : List<String>.from(json["platforms"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "regions":
            regions == null ? [] : List<dynamic>.from(regions!.map((x) => x)),
        "platforms": platforms == null
            ? []
            : List<dynamic>.from(platforms!.map((x) => x)),
      };
}

bool isMovieLike(String? contentType) {
  final upper = contentType?.trim().toUpperCase();
  return upper == 'MOVIE' || upper == 'SHORT_FILM';
}

String formatContentTypeLabel(String? contentType) {
  switch (contentType?.trim().toUpperCase()) {
    case 'SHORT_FILM':
    case 'SHORT FILM':
      return 'Short Film';
    case 'MOVIE':
      return 'Movie';
    case 'SERIES':
      return 'Series';
    case 'MINI_SERIES':
    case 'MINI SERIES':
    case 'SHORTS':
      return 'Mini Series';
    default:
      return contentType ?? '-';
  }
}


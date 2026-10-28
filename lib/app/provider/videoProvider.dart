import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'package:admin_ott/data/models/response/getAllMediaHouseByStatus.dart';
import 'package:admin_ott/data/models/response/video_upload_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/loading/app_loading_controller.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image_picker/image_picker.dart';
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/data/models/request/content_request.dart';
import 'package:admin_ott/data/models/response/addVideoResponse.dart';
import 'package:admin_ott/data/models/response/getAllVideoResponse.dart';
import 'package:admin_ott/data/models/response/searchResponse.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../data/models/request/moviePrcentageRequest.dart';
import '../../data/models/response/getAllUserResponse.dart';
import '../../data/models/response/graphResponse.dart';
import '../../domain/entities/mediaHouse.dart';
import '../../domain/entities/user.dart';
import '../widgets/show_toast.dart';

class VideoProvider extends ChangeNotifier {
  VideoProvider() : super() {
    searchContentController.addListener(filterContent);
  }

  TextEditingController searchContentController = TextEditingController();
  final TextEditingController videoController = TextEditingController();
  final TextEditingController ageRatingController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController movieUrlController = TextEditingController();
  final TextEditingController teaserUrlController = TextEditingController();
  final TextEditingController trailerUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController releaseDateController = TextEditingController();
  final TextEditingController rentlDurationController = TextEditingController();
  final TextEditingController censorCertificateController =
      TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController runTimeController = TextEditingController();
  final TextEditingController poster1Controller = TextEditingController();
  final TextEditingController poster2Controller = TextEditingController();
  final TextEditingController poster3Controller = TextEditingController();
  final TextEditingController castController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController rentalDurationController =
      TextEditingController();

  bool isEnbale = false;

  List<Content> _contentList = [];
  List<Content> _filteredContentList = [];
  Content _content = Content();
  Content _selectedContent = Content();

  List<Content> get contentList => _contentList;

  List<Content> get filteredContentList => _filteredContentList;

  Content get content => _content;

  Content get selectedContent => _selectedContent;

  List<Content> _contentListByMediaHouse = [];
  final List<Content> _filteredContentListByMediaHouse = [];
  final Content _mediaHouseContent = Content();
  final Content _selectedMediaHouseContent = Content();

  List<Content> get contentListByMediaHouse => _contentListByMediaHouse;

  List<Content> get filteredContentListByMediaHouse =>
      _filteredContentListByMediaHouse;

  Content get mediaHouseContent => _mediaHouseContent;

  Content get selectedMediaHouseContent => _selectedMediaHouseContent;

  final List<String> _selectedItems = [];

  List<String> get selectedItems => _selectedItems;

  final List<String> _selectedGeners = [];

  List<String> get selectedGeners => _selectedGeners;

  final List<String> _selectedAudioFormat = [];

  List<String> get selectedAudioFormat => _selectedAudioFormat;

  final List<String> _selectedLanguages = [];

  List<String> get selectedLanguages => _selectedLanguages;

  final List<String> _selectedSubLanguages = [];

  List<String> get selectedSubLanguages => _selectedSubLanguages;

  final List<String> _castList = [];
  final List<String> _directorList = [];

  List<String> get castList => _castList;

  List<String> get directorList => _directorList;

  // Progress tracking for all upload types
  double teaserUploadProgress = 0.0;
  double trailerUploadProgress = 0.0;
  double movieUploadProgress = 0.0;
  double censorUploadProgress = 0.0;
  double poster1UploadProgress = 0.0;
  double poster2UploadProgress = 0.0;
  double poster3UploadProgress = 0.0;

  // Individual uploading status for each file type
  bool _isTeaserUploading = false;
  bool _isTrailerUploading = false;
  bool _isMovieUploading = false;
  bool _isCensorUploading = false;
  bool _isPoster1Uploading = false;
  bool _isPoster2Uploading = false;
  bool _isPoster3Uploading = false;

  // Getters for uploading status
  bool get isTeaserUploading => _isTeaserUploading;
  bool get isTrailerUploading => _isTrailerUploading;
  bool get isMovieUploading => _isMovieUploading;
  bool get isCensorUploading => _isCensorUploading;
  bool get isPoster1Uploading => _isPoster1Uploading;
  bool get isPoster2Uploading => _isPoster2Uploading;
  bool get isPoster3Uploading => _isPoster3Uploading;

  String? teaserFileName;
  String? trailerFileName;
  String? movieFileName;

  void addValuesToList(String label) {
    if (label == "Cast") {
      print("Cast Input: ${castController.text}");
      if (castController.text.trim().isNotEmpty) {
        _castList.addAll(
          castController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
        castController.clear();
      }
    } else if (label == "Director") {
      print("Director Input: ${directorController.text}");
      if (directorController.text.trim().isNotEmpty) {
        _directorList.addAll(
          directorController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
        directorController.clear();
      }
    }
    print("Cast List: $castList");
    print("Director List: $directorList");
    notifyListeners();
  }

  void removeValue(String value) {
    _castList.remove(value);
  }

  void toggleSelection(String item, String label) {
    if (label == "Genres") {
      if (selectedGeners.contains(item)) {
        selectedGeners.remove(item);
      } else {
        selectedGeners.add(item);
      }
    } else if (label == "Audio Formats") {
      if (selectedAudioFormat.contains(item)) {
        selectedAudioFormat.remove(item);
      } else {
        selectedAudioFormat.add(item);
      }
    } else if (label == "Subtitle Languages") {
      if (selectedSubLanguages.contains(item)) {
        selectedSubLanguages.remove(item);
      } else {
        selectedSubLanguages.add(item);
      }
    } else {
      if (selectedLanguages.contains(item)) {
        selectedLanguages.remove(item);
      } else {
        selectedLanguages.add(item);
      }
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  void dropDownSelection(String item, String label) {
    if (label == "Age Rating") {
      ageRatingController.text = item;
    } else if (label == "Type") {
      typeController.text = item;
    } else if (label == "Rental Duration") {
      rentalDurationController.text = item;
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  void clearSelections() {
    _selectedItems.clear();
    notifyListeners();
  }

  bool _isDownloadable = false;

  bool get isDownloadable => _isDownloadable;

  void toggleDownloadable(bool value) {
    _isDownloadable = value;
    notifyListeners(); // Notify listeners about the change
  }

  bool _isFeatured = false;

  bool get isFeatured => _isFeatured;

  void toggleFeatured(bool value) {
    _isFeatured = value;
    notifyListeners(); // Notify listeners about the change
  }

  // Fetch all content
  Future<void> fetchContent() async {
    String apiUrl = ApiConstant.getAllVideo;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            _contentList.clear();
            _filteredContentList.clear();
            _contentList = getAllContentResponse.data!.contentList!;
            _filteredContentList.addAll(_contentList);
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching content.');
    }
  }

  // search all content
  Future<void> searchContent() async {
    String apiUrl = ApiConstant.searchContent(searchContentController.text);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        SearchResponse searchResponse = SearchResponse.fromJson(responseBody);
        if (searchResponse.success == true) {
          if (searchResponse.data != null) {
            _filteredContentList.clear();
            _filteredContentList = searchResponse.data!
                .map((item) => Content.fromJson(item as Map<String, dynamic>))
                .toList();
            notifyListeners();
          } else {
            _filteredContentList.clear();
            debugPrint("empty list: ${searchResponse.message}");
          }
        } else {
          _filteredContentList.clear();
          debugPrint("Error: ${searchResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching content.');
    }
  }

  void filterContent() {
    _filteredContentList = _contentList.where((content) {
      final query = searchContentController.text.toLowerCase();
      return content.title!.toLowerCase().contains(query) ||
          content.ageRating!.toLowerCase().contains(query) ||
          (content.description!.toLowerCase().contains(query)) ||
          (content.description!.toLowerCase().contains(query)) ||
          (content.type!.toLowerCase().contains(query)) ||
          (content.ageRating!.toLowerCase().contains(query));
    }).toList();
    notifyListeners();
  }

  setSelectedContent(Content content) {
    _selectedContent = content;

    searchContentController.clear();
    notifyListeners();
  }

  Map<String, dynamic>? _decodeResponseMap(dynamic rawBody) {
    if (rawBody == null) return null;
    if (rawBody is Map<String, dynamic>) return rawBody;
    if (rawBody is Map) {
      return rawBody.map((key, value) => MapEntry(key.toString(), value));
    }
    if (rawBody is List) {
      return {'success': true, 'data': {'ContentList': rawBody}};
    }
    if (rawBody is String && rawBody.trim().isNotEmpty) {
      try {
        final decoded = json.decode(rawBody);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
        if (decoded is List) {
          return {'success': true, 'data': {'ContentList': decoded}};
        }
      } catch (e) {
        debugPrint("Error decoding JSON: $e");
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractContentJson(Map<String, dynamic>? map) {
    if (map == null) return null;

    // Check for nested 'data' key
    if (map.containsKey('data') && map['data'] != null) {
      final rawData = map['data'];
      if (rawData is Map) {
        final dataMap = rawData.map((k, v) => MapEntry(k.toString(), v));
        if (dataMap.containsKey('content') && dataMap['content'] is Map) {
          return (dataMap['content'] as Map).map((k, v) => MapEntry(k.toString(), v));
        }
        if (dataMap.containsKey('movie') && dataMap['movie'] is Map) {
          return (dataMap['movie'] as Map).map((k, v) => MapEntry(k.toString(), v));
        }
        if (dataMap.containsKey('series') && dataMap['series'] is Map) {
          return (dataMap['series'] as Map).map((k, v) => MapEntry(k.toString(), v));
        }
        return dataMap;
      }
    }

    if (map.containsKey('content') && map['content'] is Map) {
      return (map['content'] as Map).map((k, v) => MapEntry(k.toString(), v));
    }
    if (map.containsKey('movie') && map['movie'] is Map) {
      return (map['movie'] as Map).map((k, v) => MapEntry(k.toString(), v));
    }
    if (map.containsKey('series') && map['series'] is Map) {
      return (map['series'] as Map).map((k, v) => MapEntry(k.toString(), v));
    }

    final rawList = map['ContentList'] ?? map['contentList'] ?? map['contents'] ?? map['videos'] ?? map['items'];
    if (rawList is List && rawList.isNotEmpty) {
      final first = rawList.first;
      if (first is Map) {
        return first.map((k, v) => MapEntry(k.toString(), v));
      }
    }

    if (map.containsKey('title') || map.containsKey('id') || map.containsKey('contentUrl') || map.containsKey('posterUrlList')) {
      return map;
    }
    return null;
  }

  String? _extractApiMessage(Map<String, dynamic>? map) {
    if (map == null) return null;
    return map['message']?.toString() ?? map['msg']?.toString() ?? map['error']?.toString();
  }

  Future<Content?> getContentById(int id) async {
    final apiUrl = ApiConstant.getVideoById(id);
    final apiHelper = ApiHelper();

    try {
      final response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final responseBody = _decodeResponseMap(response.body);
      final contentJson = _extractContentJson(responseBody);
      if (contentJson == null) return null;

      _content = Content.fromJson(contentJson);
      notifyListeners();
      return _content;
    } catch (error) {
      debugPrint("Error fetching content by id: $error");
      return null;
    }
  }

  // Fetch all moviesByMediaHouseId
  Future<void> fetchMoviesByMediaHouseId(int mediaHouseId) async {
    String apiUrl = ApiConstant.getVideoByMediaHouseId(mediaHouseId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            _contentListByMediaHouse.clear();
            _filteredContentListByMediaHouse.clear();
            _contentListByMediaHouse = getAllContentResponse.data!.contentList!;
            _filteredContentListByMediaHouse.addAll(_contentListByMediaHouse);
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  // Fetch all moviesByStatusAndMediaHouseId
  Future<void> fetchMoviesByStatusAndMediaHouseId(
      String status, int mediaHouseId) async {
    String apiUrl =
        ApiConstant.getVideoByStatusAndMediaHouse(status, mediaHouseId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      //log("get movie response by status::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            if (status == "PENDING") {
              _contentListByMediaHouse.clear();
              _filteredContentListByMediaHouse.clear();
              _contentListByMediaHouse =
                  getAllContentResponse.data!.contentList!;
              _filteredContentListByMediaHouse.addAll(_contentListByMediaHouse);
              //log("filtered content list by production house size: ${_filteredContentListByMediaHouse.length}");
              _filteredContentList.clear();
              _filteredContentList = getAllContentResponse.data!.contentList!;
            } else {
              _filteredContentList.clear();
              _filteredContentList = getAllContentResponse.data!.contentList!;
              if (status.toUpperCase() == "ALL") {
                _contentList = List<Content>.from(_filteredContentList);
              }
            }
            notifyListeners();
          } else {
            _filteredContentList.clear();
            //log("empty list: ${getAllContentResponse.message}");
            notifyListeners();
          }
        } else {
          _filteredContentList.clear();
          //log("Error: ${getAllContentResponse.message}");
          notifyListeners();
        }
      } else if (response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == false) {
          _filteredContentList.clear();
          notifyListeners();
        }
      } else {
        if (status == "ALL") {
          filteredContentList.clear();
          _filteredContentList.addAll(_contentList);
          notifyListeners();
        }
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  // Fetch all moviesByStatusAndMediaHouseId
  Future<bool> changeContentStatus(
      BuildContext context, String status, int id) async {
    String apiUrl = ApiConstant.changeContentStatus(status, id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.putApi(apiUrl);
      debugPrint("response::: " + response.body);
      final responseBody = _decodeResponseMap(response.body);
      final apiMessage = _extractApiMessage(responseBody);
      final isSuccess = _extractApiSuccess(responseBody);

      if (response.statusCode == 200 && isSuccess != false) {
        final contentJson = _extractContentJson(responseBody);
        if (contentJson != null) {
          _content = Content.fromJson(contentJson);
        } else {
          await getContentById(id);
        }
        CustomToast.show(
          apiMessage ?? _contentStatusSuccessMessage(status),
          isSuccess: true,
        );
        await fetchMoviesByStatusAndMediaHouseId("PENDING", 0);
        notifyListeners();
        return true;
      } else if (_isAlreadyMarkedMessage(apiMessage)) {
        await getContentById(id);
        CustomToast.show(
          apiMessage ?? _contentStatusSuccessMessage(status),
          isSuccess: false,
        );
        await fetchMoviesByStatusAndMediaHouseId("PENDING", 0);
        notifyListeners();
        return true;
      } else {
        CustomToast.show(
          apiMessage ?? _contentStatusErrorMessage(status, response.statusCode),
          isSuccess: false,
        );
        return false;
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show(
        'An error occurred while updating content status.',
        isSuccess: false,
      );
      return false;
    }
  }

  bool? _extractApiSuccess(Map<String, dynamic>? body) {
    final value = body?['success'] ?? body?['isSuccess'] ?? body?['status'];
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == 'success' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'failed' || normalized == '0') {
      return false;
    }
    return null;
  }

  bool _isAlreadyMarkedMessage(String? message) {
    final normalized = message?.toLowerCase() ?? '';
    return normalized.contains('already') && normalized.contains('marked');
  }

  String _contentStatusSuccessMessage(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Content approved successfully';
      case 'REJECTED':
        return 'Content rejected successfully';
      case 'PENDING':
        return 'Content moved to pending successfully';
      default:
        return 'Content status updated successfully';
    }
  }

  String _contentStatusErrorMessage(String status, int statusCode) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Failed to approve content ($statusCode)';
      case 'REJECTED':
        return 'Failed to reject content ($statusCode)';
      case 'PENDING':
        return 'Failed to move content to pending ($statusCode)';
      default:
        return 'Failed to update content status ($statusCode)';
    }
  }

  // Create a new content
  Future<Content?> uploadContent(
      MediaHouse mediaHouse, BuildContext context) async {
    Availability availability = Availability();
    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.saveVideo;

    SaveContentRequest saveContent = SaveContentRequest();
    saveContent.ageRating = ageRatingController.text;
    saveContent.approvalStatus = "PENDING";
    saveContent.approvedDateTime = '';
    saveContent.audioFormatList = selectedAudioFormat;
    saveContent.availability = availability;
    saveContent.castList = castList;
    saveContent.contentUrl = movieUrlController.text;
    saveContent.directorList = directorList;
    saveContent.description = descriptionController.text;
    saveContent.genersList = selectedGeners;
    saveContent.isDownloadable = isDownloadable;
    saveContent.isFeatured = isFeatured;
    saveContent.languageList = selectedLanguages;
    saveContent.mediaHouseId = mediaHouse.id;
    saveContent.price = double.tryParse(priceController.text.trim()) ?? 0.0;
    saveContent.posterUrlList = [
      poster1Controller.text,
      poster2Controller.text,
      poster3Controller.text,
    ].where((url) => url.isNotEmpty).toList();
    saveContent.ratings = 0;
    saveContent.ratingCount = 0;
    saveContent.reason = '';
    saveContent.releaseDate = releaseDateController.text;
    saveContent.rentlDuration = rentalDurationController.text;
    saveContent.totalRevenue = 0;
    saveContent.runtime = double.tryParse(runTimeController.text.trim()) ?? 0.0;
    saveContent.subtitleLanguageList = selectedSubLanguages;
    saveContent.subtitleLanguageUrls = _subtitleLanguageUrls;
    saveContent.sensorCertificate = censorCertificateController.text;
    saveContent.type = typeController.text;
    saveContent.title = titleController.text;
    saveContent.teaserUrl = teaserUrlController.text;
    saveContent.trailerUrl = trailerUrlController.text;
    saveContent.uploadDateTime = isoDate;
    saveContent.views = 0;

    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = saveContent.toJson();
      debugPrint("Payload: ${json.encode(payload)}");

      var response = await apiHelper.postApiWithBody(apiUrl, payload);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);

        if (addVideoResponse.isSuccess == true && addVideoResponse.data != null) {
          CustomToast.show("Video added successfully", isSuccess: true);
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          notifyListeners();
          if (context.mounted) Navigator.of(context).pop();
          return addVideoResponse.data; // Return the content object
        } else {
          final msg = addVideoResponse.message ?? "Failed to add video. Record not saved.";
          debugPrint("Add content failed: $msg");
          CustomToast.show(msg, isSuccess: false);
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        final responseBody = _decodeResponseMap(response.body);
        final msg = _extractApiMessage(responseBody) ?? "Failed to upload content (${response.statusCode})";
        CustomToast.show(msg, isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("Error adding content: $error", isSuccess: false);
    }
    return null; // Return null if the upload fails
  }

  final Map<String, String> _languageAudioUrls = {};
  Map<String, String> get languageAudioUrls => _languageAudioUrls;

  final Map<String, String> _subtitleLanguageUrls = {};
  Map<String, String> get subtitleLanguageUrls => _subtitleLanguageUrls;

  void setAudioTrackUrl(String language, String url) {
    _languageAudioUrls[language] = url;
    notifyListeners();
  }

  void setSubtitleTrackUrl(String language, String url) {
    _subtitleLanguageUrls[language] = url;
    notifyListeners();
  }

  /// Resets the form controllers and selections for a fresh create flow.
  void resetContentForm() {
    titleController.clear();
    descriptionController.clear();
    releaseDateController.clear();
    runTimeController.clear();
    priceController.clear();
    ageRatingController.clear();
    typeController.clear();
    rentalDurationController.clear();
    movieUrlController.clear();
    teaserUrlController.clear();
    trailerUrlController.clear();
    censorCertificateController.clear();
    poster1Controller.clear();
    poster2Controller.clear();
    poster3Controller.clear();
    castController.clear();
    directorController.clear();
    _previewImageBytes.clear();
    _selectedGeners.clear();
    _selectedLanguages.clear();
    _selectedAudioFormat.clear();
    _selectedSubLanguages.clear();
    _castList.clear();
    _directorList.clear();
    _languageAudioUrls.clear();
    _subtitleLanguageUrls.clear();
    _isDownloadable = false;
    _isFeatured = false;
    notifyListeners();
  }

  /// Loads an existing content record into the shared content form without
  /// changing create-flow defaults or uploaded file references.
  void populateContentForm(Content content) {
    _previewImageBytes.clear();
    titleController.text = content.title ?? '';
    descriptionController.text = content.description ?? '';
    releaseDateController.text = content.releaseDate?.toString() ?? '';
    runTimeController.text = content.runtime?.toString() ?? '';
    priceController.text = content.price != null
        ? (content.price! % 1 == 0
            ? content.price!.toInt().toString()
            : content.price!.toString())
        : '';
    ageRatingController.text = content.ageRating ?? '';
    typeController.text = content.type ?? 'MOVIE';
    rentalDurationController.text = content.rentlDuration ?? 'Lifetime';
    movieUrlController.text = content.contentUrl ?? '';
    teaserUrlController.text = content.teaserUrl ?? '';
    trailerUrlController.text = content.trailerUrl ?? '';
    censorCertificateController.text = content.sensorCertificate ?? '';

    final posters = content.posterUrlList ?? const <String>[];
    poster1Controller.text = posters.isNotEmpty ? posters[0] : '';
    poster2Controller.text = posters.length > 1 ? posters[1] : '';
    poster3Controller.text = posters.length > 2 ? posters[2] : '';

    _selectedGeners
      ..clear()
      ..addAll(content.genreList ?? const <String>[]);
    _selectedLanguages
      ..clear()
      ..addAll(content.languageList ?? const <String>[]);
    _selectedAudioFormat
      ..clear()
      ..addAll(content.audioFormatList ?? const <String>[]);
    _selectedSubLanguages
      ..clear()
      ..addAll(content.subtitleLanguageList ?? const <String>[]);
    _castList
      ..clear()
      ..addAll(content.castList ?? const <String>[]);
    _directorList
      ..clear()
      ..addAll(content.directorList ?? const <String>[]);
    _languageAudioUrls.clear();
    _subtitleLanguageUrls.clear();
    if (content.languageAudioUrls != null) {
      _languageAudioUrls.addAll(content.languageAudioUrls!);
    }
    if (content.subtitleLanguageUrls != null) {
      _subtitleLanguageUrls.addAll(content.subtitleLanguageUrls!);
    }
    _isDownloadable = content.isDownloadable ?? false;
    _isFeatured = content.isFeatured ?? false;
    notifyListeners();
  }

  Future<void> pickAndUploadSubtitleFile(String language) async {
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()..accept = '.vtt,.srt,.sub,.txt,text/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files!.first;
          _isUploading = true;
          notifyListeners();
          try {
            final url = Uri.parse(ApiConstant.uploadImg);
            final request = http.MultipartRequest('POST', url);
            request.headers.addAll(await ApiHelper().multipartHeaders());
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            await reader.onLoad.first;
            final byteData = reader.result as List<int>;
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              byteData,
              filename: file.name,
            ));
            final response =
                await AppLoadingController.trackFuture(() => request.send());
            if (response.statusCode == 200) {
              final body = await response.stream.bytesToString();
              final uploadedUrl = _parseUploadedUrl(body);
              if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                _subtitleLanguageUrls[language] = uploadedUrl;
                notifyListeners();
                CustomToast.show('$language subtitle uploaded successfully',
                    isSuccess: true);
              }
            }
          } catch (e) {
            debugPrint('Error uploading subtitle: $e');
            CustomToast.show('Failed to upload subtitle', isSuccess: false);
          } finally {
            _isUploading = false;
            notifyListeners();
          }
        }
      });
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickMedia();
      if (picked != null) {
        _isUploading = true;
        notifyListeners();
        try {
          final url = Uri.parse(ApiConstant.uploadImg);
          final request = http.MultipartRequest('POST', url);
          request.headers.addAll(await ApiHelper().multipartHeaders());
          request.files.add(
              await http.MultipartFile.fromPath('file', picked.path));
          final response =
              await AppLoadingController.trackFuture(() => request.send());
          if (response.statusCode == 200) {
            final body = await response.stream.bytesToString();
            final uploadedUrl = _parseUploadedUrl(body);
            if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
              _subtitleLanguageUrls[language] = uploadedUrl;
              notifyListeners();
              CustomToast.show('$language subtitle uploaded successfully',
                  isSuccess: true);
            }
          }
        } catch (e) {
          debugPrint('Error uploading subtitle: $e');
          CustomToast.show('Failed to upload subtitle', isSuccess: false);
        } finally {
          _isUploading = false;
          notifyListeners();
        }
      }
    }
  }

  Future<void> pickAndUploadAudioTrack(String language) async {
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()..accept = 'audio/*,video/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files!.first;
          _isUploading = true;
          notifyListeners();
          try {
            final url = Uri.parse(ApiConstant.uploadImg);
            final request = http.MultipartRequest('POST', url);
            request.headers.addAll(await ApiHelper().multipartHeaders());
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            await reader.onLoad.first;
            final byteData = reader.result as List<int>;
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              byteData,
              filename: file.name,
            ));
            final response =
                await AppLoadingController.trackFuture(() => request.send());
            if (response.statusCode == 200) {
              final body = await response.stream.bytesToString();
              final uploadedUrl = _parseUploadedUrl(body);
              if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                _languageAudioUrls[language] = uploadedUrl;
                notifyListeners();
                CustomToast.show('$language audio track uploaded successfully',
                    isSuccess: true);
              }
            }
          } catch (e) {
            debugPrint('Error uploading audio track: $e');
            CustomToast.show('Failed to upload audio track', isSuccess: false);
          } finally {
            _isUploading = false;
            notifyListeners();
          }
        }
      });
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        _isUploading = true;
        notifyListeners();
        try {
          final url = Uri.parse(ApiConstant.uploadImg);
          final request = http.MultipartRequest('POST', url);
          request.headers.addAll(await ApiHelper().multipartHeaders());
          request.files.add(
              await http.MultipartFile.fromPath('file', picked.path));
          final response =
              await AppLoadingController.trackFuture(() => request.send());
          if (response.statusCode == 200) {
            final body = await response.stream.bytesToString();
            final uploadedUrl = _parseUploadedUrl(body);
            if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
              _languageAudioUrls[language] = uploadedUrl;
              notifyListeners();
              CustomToast.show('$language audio track uploaded successfully',
                  isSuccess: true);
            }
          }
        } catch (e) {
          debugPrint('Error uploading audio track: $e');
          CustomToast.show('Failed to upload audio track', isSuccess: false);
        } finally {
          _isUploading = false;
          notifyListeners();
        }
      }
    }
  }

  /// Updates an existing content record through the already configured update
  /// endpoint, retaining backend-managed fields from [existing].
  Future<Content?> updateContent(BuildContext context, Content existing) async {
    final id = existing.id;
    final parsedPrice = double.tryParse(priceController.text.trim());
    final price = parsedPrice ?? existing.price;
    if (id == null) {
      CustomToast.show('Unable to update content. Content ID is missing.',
          isSuccess: false);
      return null;
    }

    // Preserve existing media files if unchanged in form
    final teaserUrl = teaserUrlController.text.trim().isNotEmpty
        ? teaserUrlController.text.trim()
        : (existing.teaserUrl ?? '');

    final trailerUrl = trailerUrlController.text.trim().isNotEmpty
        ? trailerUrlController.text.trim()
        : (existing.trailerUrl ?? '');

    final contentUrl = movieUrlController.text.trim().isNotEmpty
        ? movieUrlController.text.trim()
        : (existing.contentUrl ?? '');

    final censorCertificate = censorCertificateController.text.trim().isNotEmpty
        ? censorCertificateController.text.trim()
        : (existing.sensorCertificate ?? existing.agreementUrl ?? '');

    final agreementUrl = censorCertificate.isNotEmpty
        ? censorCertificate
        : (existing.agreementUrl ?? '');

    List<String> posterUrls = [
      poster1Controller.text.trim(),
      poster2Controller.text.trim(),
      poster3Controller.text.trim(),
    ].where((url) => url.isNotEmpty).toList();

    if (posterUrls.isEmpty &&
        existing.posterUrlList != null &&
        existing.posterUrlList!.isNotEmpty) {
      posterUrls = List<String>.from(existing.posterUrlList!);
    }

    final title = titleController.text.trim().isNotEmpty
        ? titleController.text.trim()
        : (existing.title ?? '');

    final description = descriptionController.text.trim().isNotEmpty
        ? descriptionController.text.trim()
        : (existing.description ?? '');

    final releaseDate = releaseDateController.text.trim().isNotEmpty
        ? releaseDateController.text.trim()
        : (existing.releaseDate?.toString() ?? '');

    final runtime = double.tryParse(runTimeController.text.trim()) ??
        (existing.runtime?.toDouble() ?? 0);

    final ageRating = ageRatingController.text.trim().isNotEmpty
        ? ageRatingController.text.trim()
        : (existing.ageRating ?? '');

    final type = typeController.text.trim().isNotEmpty
        ? typeController.text.trim()
        : (existing.type ?? 'MOVIE');

    final rentlDuration = rentalDurationController.text.trim().isNotEmpty
        ? rentalDurationController.text.trim()
        : (existing.rentlDuration ?? 'Lifetime');

    final genersList = _selectedGeners.isNotEmpty
        ? List<String>.from(_selectedGeners)
        : (existing.genreList ?? const <String>[]);

    final languageList = _selectedLanguages.isNotEmpty
        ? List<String>.from(_selectedLanguages)
        : (existing.languageList ?? const <String>[]);

    final audioFormatList = _selectedAudioFormat.isNotEmpty
        ? List<String>.from(_selectedAudioFormat)
        : (existing.audioFormatList ?? const <String>[]);

    final subtitleLanguageList = _selectedSubLanguages.isNotEmpty
        ? List<String>.from(_selectedSubLanguages)
        : (existing.subtitleLanguageList ?? const <String>[]);

    final castList = _castList.isNotEmpty
        ? List<String>.from(_castList)
        : (existing.castList ?? const <String>[]);

    final directorList = _directorList.isNotEmpty
        ? List<String>.from(_directorList)
        : (existing.directorList ?? const <String>[]);

    final request = SaveContentRequest(
      id: id,
      title: title,
      description: description,
      releaseDate: releaseDate,
      runtime: runtime,
      price: price ?? 0.0,
      ageRating: ageRating,
      type: type,
      rentlDuration: rentlDuration,
      teaserUrl: teaserUrl,
      trailerUrl: trailerUrl,
      contentUrl: contentUrl,
      sensorCertificate: censorCertificate,
      agreementUrl: agreementUrl,
      posterUrlList: posterUrls,
      genersList: genersList,
      genreList: genersList,
      languageList: languageList,
      languageAudioUrls: _languageAudioUrls,
      audioFormatList: audioFormatList,
      subtitleLanguageList: subtitleLanguageList,
      subtitleLanguageUrls: _subtitleLanguageUrls,
      castList: castList,
      directorList: directorList,
      isDownloadable: _isDownloadable,
      isFeatured: _isFeatured,
      availability: existing.availability,
      approvalStatus: existing.approvalStatus ?? 'APPROVED',
      approvedDateTime: existing.approvedDateTime ?? '',
      uploadDateTime: existing.uploadDateTime ?? '',
      mediaHouseId: existing.mediaHouseId,
      mediaHouseName: existing.mediaHouseName,
      ratings: existing.ratings ?? 0.0,
      ratingCount: existing.ratingCount ?? 0,
      views: existing.views ?? 0,
      totalPurchase: existing.totalPurchase ?? 0,
      totalRevenue: existing.totalRevenue ?? 0.0,
      adminRevnue: existing.adminRevnue ?? 0.0,
      mediaHouseRevenue: existing.mediaHouseRevenue ?? 0.0,
      adminIncentivePecentage: existing.adminIncentivePecentage,
      mediaHouseIncentivePecentage: existing.mediaHouseIncentivePecentage,
      reason: existing.reason ?? '',
    );

    try {
      final response = await ApiHelper().putApiWithBody(
        ApiConstant.editVideoById(id),
        request.toJson(),
      );
      final responseBody = _decodeResponseMap(response.body);
      final success =
          responseBody?['isSuccess'] ?? responseBody?['success'];
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          success != false) {
        final contentJson = _extractContentJson(responseBody);
        final updated = contentJson == null
            ? Content.fromJson({
                ...existing.toJson(),
                ...request.toJson(),
                'genreList': request.genersList,
              })
            : Content.fromJson(contentJson);
        _content = updated;
        await fetchMoviesByStatusAndMediaHouseId('ALL', 0);
        notifyListeners();
        CustomToast.show('Content updated successfully', isSuccess: true);
        return updated;
      }
      CustomToast.show(
        _extractApiMessage(responseBody) ?? 'Failed to update content.',
        isSuccess: false,
      );
    } catch (error) {
      debugPrint('Error updating content: $error');
      CustomToast.show('Failed to update content. Please try again.',
          isSuccess: false);
    }
    return null;
  }

  /// Updates trailer and/or teaser URLs of a content item while preserving all other existing fields exactly as they are.
  Future<Content?> updateContentTrailer(
      BuildContext context, Content existing, String newTrailerUrl,
      {String? newTeaserUrl}) async {
    return updateContentTrailerAndTeaser(
      context,
      existing,
      newTrailerUrl: newTrailerUrl,
      newTeaserUrl: newTeaserUrl,
    );
  }

  /// Dedicated method to update trailer and teaser URLs independently or together.
  Future<Content?> updateContentTrailerAndTeaser(
      BuildContext context,
      Content existing, {
      String? newTrailerUrl,
      String? newTeaserUrl,
  }) async {
    final id = existing.id;
    if (id == null) {
      CustomToast.show('Unable to update video files. Content ID is missing.',
          isSuccess: false);
      return null;
    }

    final effectiveTrailerUrl = newTrailerUrl != null
        ? newTrailerUrl.trim()
        : (existing.trailerUrl ?? '');
    final effectiveTeaserUrl = newTeaserUrl != null
        ? newTeaserUrl.trim()
        : (existing.teaserUrl ?? '');

    final request = SaveContentRequest(
      id: id,
      title: existing.title ?? '',
      description: existing.description ?? '',
      releaseDate: existing.releaseDate?.toString() ?? '',
      runtime: existing.runtime?.toDouble() ?? 0,
      price: existing.price ?? 0.0,
      ageRating: existing.ageRating ?? '',
      type: existing.type ?? 'MOVIE',
      rentlDuration: existing.rentlDuration ?? 'Lifetime',
      teaserUrl: effectiveTeaserUrl,
      trailerUrl: effectiveTrailerUrl,
      contentUrl: existing.contentUrl ?? '',
      sensorCertificate: existing.sensorCertificate ?? existing.agreementUrl ?? '',
      agreementUrl: existing.agreementUrl ?? '',
      posterUrlList: existing.posterUrlList ?? const <String>[],
      genersList: existing.genreList ?? const <String>[],
      genreList: existing.genreList ?? const <String>[],
      languageList: existing.languageList ?? const <String>[],
      languageAudioUrls: _languageAudioUrls.isNotEmpty ? _languageAudioUrls : existing.languageAudioUrls,
      audioFormatList: existing.audioFormatList ?? const <String>[],
      subtitleLanguageList: existing.subtitleLanguageList ?? const <String>[],
      subtitleLanguageUrls: _subtitleLanguageUrls.isNotEmpty ? _subtitleLanguageUrls : existing.subtitleLanguageUrls,
      castList: existing.castList ?? const <String>[],
      directorList: existing.directorList ?? const <String>[],
      isDownloadable: existing.isDownloadable ?? false,
      isFeatured: existing.isFeatured ?? false,
      availability: existing.availability,
      approvalStatus: existing.approvalStatus ?? 'APPROVED',
      approvedDateTime: existing.approvedDateTime ?? '',
      uploadDateTime: existing.uploadDateTime ?? '',
      mediaHouseId: existing.mediaHouseId,
      mediaHouseName: existing.mediaHouseName,
      ratings: existing.ratings ?? 0.0,
      ratingCount: existing.ratingCount ?? 0,
      views: existing.views ?? 0,
      totalPurchase: existing.totalPurchase ?? 0,
      totalRevenue: existing.totalRevenue ?? 0.0,
      adminRevnue: existing.adminRevnue ?? 0.0,
      mediaHouseRevenue: existing.mediaHouseRevenue ?? 0.0,
      adminIncentivePecentage: existing.adminIncentivePecentage,
      mediaHouseIncentivePecentage: existing.mediaHouseIncentivePecentage,
      reason: existing.reason ?? '',
    );

    try {
      final response = await ApiHelper().putApiWithBody(
        ApiConstant.editVideoById(id),
        request.toJson(),
      );
      final responseBody = _decodeResponseMap(response.body);
      final success = responseBody?['isSuccess'] ?? responseBody?['success'];
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          success != false) {
        final contentJson = _extractContentJson(responseBody);
        final updated = contentJson == null
            ? Content.fromJson({
                ...existing.toJson(),
                ...request.toJson(),
                'teaserUrl': effectiveTeaserUrl,
                'trailerUrl': effectiveTrailerUrl,
                'genreList': request.genersList,
              })
            : Content.fromJson(contentJson);
        _content = updated;
        await fetchMoviesByStatusAndMediaHouseId('ALL', 0);
        notifyListeners();
        CustomToast.show('Teaser & Trailer updated successfully', isSuccess: true);
        return updated;
      }
      CustomToast.show(
        _extractApiMessage(responseBody) ?? 'Failed to update video files.',
        isSuccess: false,
      );
    } catch (error) {
      debugPrint('Error updating teaser/trailer: $error');
      CustomToast.show('Error updating teaser/trailer: $error', isSuccess: false);
    }
    return null;
  }

  File? selectedImage;

  void setImage(XFile pickedFile) {
    selectedImage = File(pickedFile.path);
    notifyListeners();
  }

  List<User> users = [];

  List<User> get userList => users;

  // Fetch all users
  Future<void> fetchUsers() async {
    String apiUrl = ApiConstant.getAllUser;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllUserResponse getAllUserResponse =
            GetAllUserResponse.fromJson(responseBody);
        if (getAllUserResponse.success == true) {
          if (getAllUserResponse.data != null) {
            users = getAllUserResponse.data!.users!;
            print("User list:::::::" + users.length.toString());
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllUserResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching users.');
    }
  }

  io.File? _imageFile; // For mobile platforms
  html.File? _webFile; // For web platform
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final Map<String, Uint8List> _previewImageBytes = {};

  // Getters
  io.File? get imageFile => _imageFile;

  html.File? get webFile => _webFile;

  String? get uploadedImageUrl => _uploadedImageUrl;

  bool get isUploading => _isUploading;

  Uint8List? getPreviewBytes(String label) => _previewImageBytes[label];

  void clearUploadedFile(String label) {
    _previewImageBytes.remove(label);
    if ("Trailer File" == label) {
      trailerUrlController.clear();
    } else if ("Movie File" == label) {
      movieUrlController.clear();
    } else if ("Teaser File" == label) {
      teaserUrlController.clear();
    } else if ("Censor Certificate" == label) {
      censorCertificateController.clear();
    } else if ("Poster 1" == label) {
      poster1Controller.clear();
    } else if ("Poster 2" == label) {
      poster2Controller.clear();
    } else if ("Poster 3" == label) {
      poster3Controller.clear();
    }
    notifyListeners();
  }

  // Pick Image
  Future<void> pickImage(String label) async {
    if (kIsWeb) {
      // Web file picker
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          _webFile = uploadInput.files!.first;
          try {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(_webFile!);
            await reader.onLoad.first;
            final byteData = reader.result as List<int>;
            _previewImageBytes[label] = Uint8List.fromList(byteData);
            notifyListeners();
          } catch (_) {}
          await uploadImage(label);
          notifyListeners();
        }
      });
    } else {
      // Mobile/desktop file picker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageFile = io.File(pickedFile.path);
        try {
          final bytes = await pickedFile.readAsBytes();
          _previewImageBytes[label] = bytes;
          notifyListeners();
        } catch (_) {}
        await uploadImage(label);
        notifyListeners();
      }
    }
  }

  // Upload Image
  Future<void> uploadImage(String lable) async {
    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webFile == null)) {
      return; // No file selected
    }

    final url = Uri.parse(ApiConstant.uploadImg);
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb && _webFile != null) {
        // Web upload logic
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final byteData = reader.result as List<int>;
        _previewImageBytes[lable] = Uint8List.fromList(byteData);
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          byteData,
          filename: _webFile!.name,
        );

        request.files.add(multipartFile);
        final response =
            await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = _parseUploadedUrl(responseBody);
          if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
            if ("Trailer File" == lable) {
              trailerUrlController.text = _uploadedImageUrl!;
            } else if ("Movie File" == lable) {
              movieUrlController.text = _uploadedImageUrl!;
            } else if ("Teaser File" == lable) {
              teaserUrlController.text = _uploadedImageUrl!;
            } else if ("Censor Certificate" == lable) {
              censorCertificateController.text = _uploadedImageUrl!;
            } else if ("Poster 1" == lable) {
              poster1Controller.text = _uploadedImageUrl!;
            } else if ("Poster 2" == lable) {
              poster2Controller.text = _uploadedImageUrl!;
            } else {
              poster3Controller.text = _uploadedImageUrl!;
            }
            CustomToast.show('$lable uploaded successfully', isSuccess: true);
          }
        } else {
          CustomToast.show('Failed to upload $lable', isSuccess: false);
        }
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile/desktop upload logic
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imageFile!.path,
        ));
        final response =
            await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = _parseUploadedUrl(responseBody);
          if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
            if ("Trailer File" == lable) {
              trailerUrlController.text = _uploadedImageUrl!;
            } else if ("Movie File" == lable) {
              movieUrlController.text = _uploadedImageUrl!;
            } else if ("Teaser File" == lable) {
              teaserUrlController.text = _uploadedImageUrl!;
            } else if ("Censor Certificate" == lable) {
              censorCertificateController.text = _uploadedImageUrl!;
            } else if ("Poster 1" == lable) {
              poster1Controller.text = _uploadedImageUrl!;
            } else if ("Poster 2" == lable) {
              poster2Controller.text = _uploadedImageUrl!;
            } else {
              poster3Controller.text = _uploadedImageUrl!;
            }
            CustomToast.show('$lable uploaded successfully', isSuccess: true);
          }
        } else {
          CustomToast.show('Failed to upload $lable', isSuccess: false);
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      CustomToast.show('Failed to upload $lable', isSuccess: false);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  String? _parseUploadedUrl(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is String) return decoded;
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return data['fileUrl']?.toString() ??
              data['url']?.toString() ??
              data['thumbnailUrl']?.toString();
        }
        if (data is String) return data;
        return decoded['fileUrl']?.toString() ??
            decoded['url']?.toString() ??
            decoded['thumbnailUrl']?.toString() ??
            decoded['message']?.toString();
      }
    } catch (e) {
      debugPrint('Error parsing uploaded URL: $e');
    }
    return responseBody;
  }

  List<MediaHouse> _mediaHouseList = [];
  List<MediaHouse> get mediaHouseList => _mediaHouseList;

  // Fetch all mediaHouse
  Future<void> fetchMediaHouse() async {
    String apiUrl = ApiConstant.getMediaHouseByStatus("APPROVED");
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllMediaHouseByStatus getAllMediaHouseByStatus =
            GetAllMediaHouseByStatus.fromJson(responseBody);
        if (getAllMediaHouseByStatus.success == true) {
          if (getAllMediaHouseByStatus.data != null) {
            _mediaHouseList.clear();
            _mediaHouseList = getAllMediaHouseByStatus.data!.mediaHouse!;
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllMediaHouseByStatus.message}");
          }
        } else {
          debugPrint("Error: ${getAllMediaHouseByStatus.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch mediaHouse. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }

  deleteVideo(int id, context) async {
    String apiUrl = ApiConstant.deleteVideoById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200 || response.statusCode == 500) {
        CustomToast.show("Deleted Successfully");
        notifyListeners();
        fetchMoviesByStatusAndMediaHouseId("All", 0);
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to fetch mediaHouse. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateNameController = TextEditingController();
  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  List<GraphData> chartData = [];

  falseAllFilter() {
    isYear = false;
    isMonth = false;
    isWeek = false;
  }

  Future<void> contentRevenueGraph(int selectedTimeRange, int id,
      String startDateString, String endDateString,
      {String type = "ALL"}) async {
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else if (selectedTimeRange == 2) {
      isWeek = false;
      isMonth = false;
      isYear = true;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = false;
    }
    String apiUrl = ApiConstant.contentRevenueGraph(
      id,
      startDateString,
      endDateString,
      isYear,
      isMonth,
      isWeek,
      type: type,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = _decodeResponseMap(response.body);
        if (responseBody != null) {
          GraphResponse chartResponse = GraphResponse.fromJson(responseBody);
          if (chartResponse.success == true && chartResponse.data != null) {
            chartData.clear();
            chartData = chartResponse.data!;
            notifyListeners();
          }
        }
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
    }
  }

  Future<bool> setMoviePercentage(
      BuildContext context,
      Content content,
      double adminPercentage,
      double mediaHousePercentage,
      MediaHouse mediaHouse,
      {bool shouldPop = true}) async {
    if (content.id == null) {
      CustomToast.show(
        "Unable to set percentage: invalid content id.",
        isSuccess: false,
      );
      return false;
    }
    if (mediaHouse.id == null || mediaHouse.id! <= 0) {
      CustomToast.show(
        "Unable to set percentage: production house not found.",
        isSuccess: false,
      );
      return false;
    }

    final safeAdminPercentage = adminPercentage.clamp(0, 100).toDouble();
    final safeMediaHousePercentage =
        mediaHousePercentage.clamp(0, 100).toDouble();

    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.setPercentage;
    print(apiUrl);
    PercentageRequest percentageRequest = PercentageRequest();
    percentageRequest.contentList = content.id!;
    percentageRequest.date = isoDate;
    percentageRequest.isActive = true;
    percentageRequest.mediaHouse = mediaHouse.id!;
    percentageRequest.percentageAdmin = safeAdminPercentage;
    percentageRequest.percentageMediaHouse = safeMediaHousePercentage;
    percentageRequest.ticketRate = content.price ?? 0;

    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = percentageRequest.toJson();
      debugPrint("Payload: ${json.encode(payload)}");

      var response = await apiHelper.postApiWithBody(
        apiUrl,
        payload,
      );

      Map<String, dynamic> responseBody = {};
      if (response.body.isNotEmpty) {
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            responseBody = decoded;
          }
        } catch (_) {}
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bool isSuccess = responseBody["success"] == true ||
            responseBody["isSuccess"] == true;
        if (isSuccess) {
          CustomToast.show(
            responseBody["message"]?.toString() ??
                "Movie percentage set successfully",
            isSuccess: true,
          );
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          notifyListeners();
          if (shouldPop && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          return true;
        } else {
          final addVideoResponse = AddVideoResponse.fromJson(responseBody);
          CustomToast.show(
            responseBody["message"]?.toString() ??
                addVideoResponse.message ??
                "Failed to set movie percentage",
            isSuccess: false,
          );
          debugPrint("Empty data: Record not added");
          return false;
        }
      } else {
        CustomToast.show(
          responseBody["message"]?.toString() ??
              "Failed to set percentage (${response.statusCode})",
          isSuccess: false,
        );
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (error) {
      CustomToast.show(
        "Unable to set percentage. Please try again.",
        isSuccess: false,
      );
      debugPrint("Error: $error");
      return false;
    }
  }

  Future<void> uploadVideoWeb(bool isTrailer, {bool isTeaser = false}) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final xhr = html.HttpRequest();
      final formData = html.FormData();

      formData.appendBlob('video', file, file.name);

      xhr.upload.onProgress.listen((e) {
        if (e.lengthComputable == true &&
            e.loaded != null &&
            e.total != null &&
            e.total! > 0) {
          final progress = e.loaded! / e.total!;
          if (isTeaser) {
            teaserUploadProgress = progress;
          } else if (isTrailer) {
            trailerUploadProgress = progress;
          } else {
            movieUploadProgress = progress;
          }
          notifyListeners();
        }
      });

      xhr.onLoad.listen((_) {
        AppLoadingController.end();
        if (xhr.status == 200) {
          final response = json.decode(xhr.responseText!);
          VideoUploadResponse contentImageUploadResponse =
              VideoUploadResponse.fromJson(response);
          final encryptedUrl = contentImageUploadResponse.data!.videoUrl;

          if (isTeaser) {
            teaserUrlController.text = encryptedUrl!;
            teaserFileName = file.name;
            teaserUploadProgress = 1.0;
            _isTeaserUploading = false;
          } else if (isTrailer) {
            trailerUrlController.text = encryptedUrl!;
            trailerFileName = file.name;
            trailerUploadProgress = 1.0;
            _isTrailerUploading = false;
          } else {
            movieUrlController.text = encryptedUrl!;
            movieFileName = file.name;
            movieUploadProgress = 1.0;
            _isMovieUploading = false;
          }
          notifyListeners();
        }
      });

      xhr.onError.listen((_) {
        AppLoadingController.end();
        if (isTeaser) {
          teaserUploadProgress = 0.0;
          _isTeaserUploading = false;
        } else if (isTrailer) {
          trailerUploadProgress = 0.0;
          _isTrailerUploading = false;
        } else {
          movieUploadProgress = 0.0;
          _isMovieUploading = false;
        }
        notifyListeners();
      });

      xhr.open('POST', ApiConstant.uploadVideo);
      final headers = await ApiHelper().multipartHeaders();
      headers.forEach(xhr.setRequestHeader);
      AppLoadingController.begin();
      xhr.send(formData);

      if (isTeaser) {
        _isTeaserUploading = true;
      } else if (isTrailer) {
        _isTrailerUploading = true;
      } else {
        _isMovieUploading = true;
      }
      notifyListeners();
    });
  }

  Future<void> uploadVideo(bool isTrailer, {bool isTeaser = false}) async {
    final Uri uploadUri = Uri.parse(ApiConstant.uploadVideo);

    if (isTeaser) {
      teaserUploadProgress = 0.0;
      _isTeaserUploading = true;
    } else if (isTrailer) {
      trailerUploadProgress = 0.0;
      _isTrailerUploading = true;
    } else {
      movieUploadProgress = 0.0;
      _isMovieUploading = true;
    }
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        uploadVideoWeb(isTrailer, isTeaser: isTeaser);
        return;
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

        if (pickedFile != null) {
          final File file = File(pickedFile.path);
          final totalBytes = await file.length();

          print(
              "Starting upload for ${isTeaser ? 'teaser' : (isTrailer ? 'trailer' : 'movie')}, file size: $totalBytes bytes");

          final StreamController<List<int>> streamController =
              StreamController<List<int>>();
          int bytesSent = 0;

          final progressStream = file.openRead().transform(
                StreamTransformer.fromHandlers(
                  handleData: (List<int> data, EventSink<List<int>> sink) {
                    bytesSent += data.length;
                    final progress = bytesSent / totalBytes;

                    if (isTeaser) {
                      teaserUploadProgress = progress;
                    } else if (isTrailer) {
                      trailerUploadProgress = progress;
                    } else {
                      movieUploadProgress = progress;
                    }

                    print(
                        "Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
                    notifyListeners();

                    sink.add(data);
                  },
                  handleError: (error, stackTrace, sink) {
                    print("Stream error: $error");
                    sink.addError(error, stackTrace);
                  },
                  handleDone: (sink) {
                    print("Stream done");
                    sink.close();
                  },
                ),
              );

          final request = http.MultipartRequest('POST', uploadUri);
          request.headers.addAll(await ApiHelper().multipartHeaders());

          request.files.add(http.MultipartFile(
            'video',
            progressStream,
            totalBytes,
            filename: pickedFile.name,
          ));

          print("Sending request...");
          final response =
              await AppLoadingController.trackFuture(() => request.send());

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final responseJson = json.decode(responseBody);
            VideoUploadResponse contentImageUploadResponse =
                VideoUploadResponse.fromJson(responseJson);
            final encryptedUrl = contentImageUploadResponse.data!.videoUrl;

            if (isTeaser) {
              teaserUrlController.text = encryptedUrl!;
              teaserUploadProgress = 1.0;
            } else if (isTrailer) {
              trailerUrlController.text = encryptedUrl!;
              trailerUploadProgress = 1.0;
            } else {
              movieUrlController.text = encryptedUrl!;
              movieUploadProgress = 1.0;
            }

            print("Video uploaded successfully: $encryptedUrl");
          } else {
            print("Video upload failed with status: ${response.statusCode}");
            final responseBody = await response.stream.bytesToString();
            print("Error response: $responseBody");

            if (isTeaser) {
              teaserUploadProgress = 0.0;
            } else if (isTrailer) {
              trailerUploadProgress = 0.0;
            } else {
              movieUploadProgress = 0.0;
            }
          }
          if (isTeaser) {
            _isTeaserUploading = false;
          } else if (isTrailer) {
            _isTrailerUploading = false;
          } else {
            _isMovieUploading = false;
          }
          _isUploading = false;
          notifyListeners();
        } else {
          print("No video selected");
          if (isTeaser) {
            teaserUploadProgress = 0.0;
          } else if (isTrailer) {
            trailerUploadProgress = 0.0;
          } else {
            movieUploadProgress = 0.0;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error uploading video: $e');
      if (isTeaser) {
        teaserUploadProgress = 0.0;
      } else if (isTrailer) {
        trailerUploadProgress = 0.0;
      } else {
        movieUploadProgress = 0.0;
      }
      notifyListeners();
    } finally {
      if (!kIsWeb) {
        if (isTeaser) {
          _isTeaserUploading = false;
        } else if (isTrailer) {
          _isTrailerUploading = false;
        } else {
          _isMovieUploading = false;
        }
        _isUploading = false;
        notifyListeners();
      }
    }
  }

  bool get isVideoUploading =>
      _isTeaserUploading || _isTrailerUploading || _isMovieUploading;

  bool isSpecificVideoUploading(bool isTrailer, {bool isTeaser = false}) {
    if (isTeaser) return _isTeaserUploading;
    return isTrailer ? _isTrailerUploading : _isMovieUploading;
  }

  double getVideoUploadProgress(bool isTrailer, {bool isTeaser = false}) {
    if (isTeaser) return teaserUploadProgress;
    return isTrailer ? trailerUploadProgress : movieUploadProgress;
  }

  void resetVideoUploadProgress(bool isTrailer, {bool isTeaser = false}) {
    if (isTeaser) {
      teaserUploadProgress = 0.0;
      _isTeaserUploading = false;
    } else if (isTrailer) {
      trailerUploadProgress = 0.0;
      _isTrailerUploading = false;
    } else {
      movieUploadProgress = 0.0;
      _isMovieUploading = false;
    }
    notifyListeners();
  }

  Future<Content?> editContent(BuildContext context, Content movie) async {
    String apiUrl =
        ApiConstant.videoEditRequest(movie.id, reasonController.text);

    try {
      ApiHelper apiHelper = ApiHelper();

      debugPrint("Edit Url: ${apiUrl}");

      var response = await apiHelper.putApi(apiUrl);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        debugPrint("Edit Response: ${response.body}");
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);

        if (addVideoResponse.isSuccess == true) {
          debugPrint("Response: ${addVideoResponse.data}");
          CustomToast.show("Video edited successfully", isSuccess: true);
          notifyListeners();
          return addVideoResponse.data; // Return the content object
        } else {
          debugPrint(
              "Edit failed: ${addVideoResponse.message ?? 'Unknown error'}");
          CustomToast.show(addVideoResponse.message ?? "Edit failed.",
              isSuccess: false);
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        CustomToast.show("Failed to edit content. Please try again.",
            isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An unexpected error occurred. Please try again.",
          isSuccess: false);
    }
    return null; // Return null if the edit fails
  }
}

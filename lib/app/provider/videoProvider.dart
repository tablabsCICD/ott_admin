import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:io' as io;
import 'package:admin_ott/data/models/response/getAllMediaHouseByStatus.dart';
import 'package:admin_ott/data/models/response/video_upload_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
    fetchContent();
    fetchMoviesByStatusAndMediaHouseId("PENDING", 0);
    searchContentController.addListener(filterContent);
  }

  TextEditingController searchContentController = TextEditingController();
  final TextEditingController videoController = TextEditingController();
  final TextEditingController ageRatingController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController movieUrlController = TextEditingController();
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
  double trailerUploadProgress = 0.0;
  double movieUploadProgress = 0.0;
  double censorUploadProgress = 0.0;
  double poster1UploadProgress = 0.0;
  double poster2UploadProgress = 0.0;
  double poster3UploadProgress = 0.0;

  // Individual uploading status for each file type
  bool _isTrailerUploading = false;
  bool _isMovieUploading = false;
  bool _isCensorUploading = false;
  bool _isPoster1Uploading = false;
  bool _isPoster2Uploading = false;
  bool _isPoster3Uploading = false;

  // Getters for uploading status
  bool get isTrailerUploading => _isTrailerUploading;
  bool get isMovieUploading => _isMovieUploading;
  bool get isCensorUploading => _isCensorUploading;
  bool get isPoster1Uploading => _isPoster1Uploading;
  bool get isPoster2Uploading => _isPoster2Uploading;
  bool get isPoster3Uploading => _isPoster3Uploading;

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
      log("get movie response by status::: " + response.body);
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
              log("filtered content list by media house size: ${_filteredContentListByMediaHouse.length}");
              _filteredContentList.clear();
              _filteredContentList = getAllContentResponse.data!.contentList!;
            } else {
              _filteredContentList.clear();
              _filteredContentList = getAllContentResponse.data!.contentList!;
            }
            notifyListeners();
          } else {
            _filteredContentList.clear();
            log("empty list: ${getAllContentResponse.message}");
            notifyListeners();
          }
        } else {
          _filteredContentList.clear();
          log("Error: ${getAllContentResponse.message}");
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
  Future<void> changeContentStatus(
      BuildContext context, String status, int id) async {
    String apiUrl = ApiConstant.changeContentStatus(status, id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.putApi(apiUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        _content = Content.fromJson(responseBody);
        CustomToast.show("Content Approved successfully");
        fetchMoviesByStatusAndMediaHouseId("PENDING", 0);
        notifyListeners();
        // Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
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
    saveContent.price = double.parse(priceController.text);
    saveContent.posterUrlList = [
      poster1Controller.text,
      poster2Controller.text,
      poster3Controller.text,
    ];
    saveContent.ratings = 0;
    saveContent.ratingCount = 0;
    saveContent.reason = '';
    saveContent.releaseDate = releaseDateController.text;
    saveContent.rentlDuration = rentalDurationController.text;
    saveContent.totalRevenue = 0;
    saveContent.runtime = 0;
    saveContent.subtitleLanguageList = selectedSubLanguages;
    saveContent.sensorCertificate = censorCertificateController.text;
    saveContent.type = typeController.text;
    saveContent.title = titleController.text;
    saveContent.trailerUrl = trailerUrlController.text;
    saveContent.uploadDateTime = isoDate;
    saveContent.views = 0;

    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = saveContent.toJson();
      debugPrint("Payload: ${json.encode(payload)}");

      var response = await apiHelper.postApiWithBody(apiUrl, payload);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);

        if (addVideoResponse.isSuccess == true) {
          CustomToast.show("Video added successfully");
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          notifyListeners();
          Navigator.of(context).pop();
          return addVideoResponse.data; // Return the content object
        } else {
          debugPrint("Empty data: Record not added");
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (error) {
      debugPrint("Error: $error");
    }
    return null; // Return null if the upload fails
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

  // Getters
  io.File? get imageFile => _imageFile;

  html.File? get webFile => _webFile;

  String? get uploadedImageUrl => _uploadedImageUrl;

  bool get isUploading => _isUploading;

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
        if (kIsWeb && _webFile != null) {
          await uploadImage(label);
        }
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
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final byteData = reader.result as List<int>;
        final multipartFile = http.MultipartFile.fromBytes(
          'profilePicture',
          byteData,
          filename: _webFile!.name,
        );

        request.files.add(multipartFile);
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          print(lable);
          if ("Trailer File" == lable) {
            trailerUrlController.text = _uploadedImageUrl!;
          } else if ("Movie File" == lable) {
            movieUrlController.text = _uploadedImageUrl!;
          } else if ("Censor Certificate" == lable) {
            censorCertificateController.text = _uploadedImageUrl!;
          } else if ("Poster 1" == lable) {
            poster1Controller.text = _uploadedImageUrl!;
          } else if ("Poster 2" == lable) {
            poster2Controller.text = _uploadedImageUrl!;
          } else {
            poster3Controller.text = _uploadedImageUrl!;
          }
        }
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile/desktop upload logic
        final request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          _imageFile!.path,
          //  contentType: MediaType('image', 'jpeg'),
        ));
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          print(lable);
          if ("Trailer File" == lable) {
            trailerUrlController.text = _uploadedImageUrl!;
            print(lable + trailerUrlController.text);
          } else if ("Movie File" == lable) {
            movieUrlController.text = _uploadedImageUrl!;
            print(lable + movieUrlController.text);
          } else if ("Censor Certificate" == lable) {
            censorCertificateController.text = _uploadedImageUrl!;
            print(lable + censorCertificateController.text);
          } else if ("Poster 1" == lable) {
            poster1Controller.text = _uploadedImageUrl!;
            print(lable + poster1Controller.text);
          } else if ("Poster 2" == lable) {
            poster2Controller.text = _uploadedImageUrl!;
            print(lable + poster2Controller.text);
          } else {
            poster3Controller.text = _uploadedImageUrl!;
            print(lable + selectedImage.toString());
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
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
      String startDateString, String endDateString) async {
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
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      GraphResponse chartResponse = GraphResponse.fromJson(responseBody);
      if (chartResponse.success == true) {
        chartData.clear();
        chartData = chartResponse.data!;
        // Debug print to verify
        for (var item in chartData) {
          print('Label: ${item.label}, Value: ${item.value}');
        }
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString(),
            isSuccess: chartResponse.success!);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
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
        "Unable to set percentage: media house not found.",
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

  Future<void> uploadVideoWeb(bool isTrailer) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
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
          if (isTrailer) {
            trailerUploadProgress = progress;
          } else {
            movieUploadProgress = progress;
          }
          notifyListeners();
        }
      });

      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          final response = json.decode(xhr.responseText!);
          VideoUploadResponse contentImageUploadResponse =
              VideoUploadResponse.fromJson(response);
          final encryptedUrl = contentImageUploadResponse.data!.videoUrl;

          if (isTrailer) {
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
        if (isTrailer) {
          trailerUploadProgress = 0.0;
          _isTrailerUploading = false;
        } else {
          movieUploadProgress = 0.0;
          _isMovieUploading = false;
        }
        notifyListeners();
      });

      xhr.open('POST', ApiConstant.uploadVideo);
      xhr.send(formData);

      if (isTrailer) {
        _isTrailerUploading = true;
      } else {
        _isMovieUploading = true;
      }
      notifyListeners();
    });
  }

  Future<void> uploadVideo(bool isTrailer) async {
    final Uri uploadUri = Uri.parse(ApiConstant.uploadVideo);

    if (isTrailer) {
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
        uploadVideoWeb(isTrailer);
        return;
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

        if (pickedFile != null) {
          final File file = File(pickedFile.path);
          final totalBytes = await file.length();

          print(
              "Starting upload for ${isTrailer ? 'trailer' : 'movie'}, file size: $totalBytes bytes");

          final StreamController<List<int>> streamController =
              StreamController<List<int>>();
          int bytesSent = 0;

          final progressStream = file.openRead().transform(
                StreamTransformer.fromHandlers(
                  handleData: (List<int> data, EventSink<List<int>> sink) {
                    bytesSent += data.length;
                    final progress = bytesSent / totalBytes;

                    if (isTrailer) {
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

          request.files.add(http.MultipartFile(
            'video',
            progressStream,
            totalBytes,
            filename: pickedFile.name,
          ));

          print("Sending request...");
          final response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final responseJson = json.decode(responseBody);
            VideoUploadResponse contentImageUploadResponse =
                VideoUploadResponse.fromJson(responseJson);
            final encryptedUrl = contentImageUploadResponse.data!.videoUrl;

            if (isTrailer) {
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

            if (isTrailer) {
              trailerUploadProgress = 0.0;
            } else {
              movieUploadProgress = 0.0;
            }
          }
          if (isTrailer) {
            _isTrailerUploading = false;
          } else {
            _isMovieUploading = false;
          }
          _isUploading = false;
          notifyListeners();
        } else {
          print("No video selected");
          if (isTrailer) {
            trailerUploadProgress = 0.0;
          } else {
            movieUploadProgress = 0.0;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error uploading video: $e');
      if (isTrailer) {
        trailerUploadProgress = 0.0;
      } else {
        movieUploadProgress = 0.0;
      }
      notifyListeners();
    } finally {
      if (!kIsWeb) {
        if (isTrailer) {
          _isTrailerUploading = false;
        } else {
          _isMovieUploading = false;
        }
        _isUploading = false;
        notifyListeners();
      }
    }
  }

  bool get isVideoUploading => _isTrailerUploading || _isMovieUploading;

  bool isSpecificVideoUploading(bool isTrailer) {
    return isTrailer ? _isTrailerUploading : _isMovieUploading;
  }

  double getVideoUploadProgress(bool isTrailer) {
    return isTrailer ? trailerUploadProgress : movieUploadProgress;
  }

  void resetVideoUploadProgress(bool isTrailer) {
    if (isTrailer) {
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

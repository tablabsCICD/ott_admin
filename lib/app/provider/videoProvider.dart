import 'dart:io';
import 'dart:io' as io;
import 'package:admin_ott/data/models/response/getAllMediaHouseByStatus.dart';
import 'package:admin_ott/data/models/response/getAllMediaHouseResponse.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:image_picker/image_picker.dart';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/widgets/get_date_time.dart';
import 'package:admin_ott/data/models/request/content_request.dart';
import 'package:admin_ott/data/models/response/addVideoResponse.dart';
import 'package:admin_ott/data/models/response/contentListByMediaHouse.dart';
import 'package:admin_ott/data/models/response/getAllVideoResponse.dart';
import 'package:admin_ott/data/models/response/searchResponse.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../data/models/request/moviePrcentageRequest.dart';
import '../../data/models/response/getAllUserResponse.dart';
import '../../data/models/response/graphResponse.dart';
import '../../domain/entities/mediaHouse.dart';
import '../../domain/entities/user.dart';
import '../core/utils/sharepreferences.dart';
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
  final TextEditingController rentalDurationController = TextEditingController();


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
  List<Content> _filteredContentListByMediaHouse = [];
  Content _mediaHouseContent = Content();
  Content _selectedMediaHouseContent = Content();

  List<Content> get contentListByMediaHouse => _contentListByMediaHouse;

  List<Content> get filteredContentListByMediaHouse =>
      _filteredContentListByMediaHouse;

  Content get mediaHouseContent => _mediaHouseContent;

  Content get selectedMediaHouseContent => _selectedMediaHouseContent;

  List<String> _selectedItems = [];

  List<String> get selectedItems => _selectedItems;

  List<String> _selectedGeners = [];

  List<String> get selectedGeners => _selectedGeners;

  List<String> _selectedAudioFormat = [];

  List<String> get selectedAudioFormat => _selectedAudioFormat;



  List<String> _selectedLanguages = [];

  List<String> get selectedLanguages => _selectedLanguages;

  List<String> _selectedSubLanguages = [];

  List<String> get selectedSubLanguages => _selectedSubLanguages;

  List<String> _castList = [];
  List<String> _directorList = [];

  List<String> get castList => _castList;

  List<String> get directorList => _directorList;

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
      return
          content.title!.toLowerCase().contains(query) ||
          content.ageRating!.toLowerCase().contains(query) ||
          (content.description!.toLowerCase().contains(query) ?? false) ||
          (content.description!.toLowerCase().contains(query) ?? false) ||
          (content.type!.toLowerCase().contains(query) ?? false) ||
          (content.ageRating!.toLowerCase().contains(query) ?? false);
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
      debugPrint("get movie response by status::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
        GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            if(status=="PENDING"){
              _contentListByMediaHouse.clear();
              _filteredContentListByMediaHouse.clear();
              _contentListByMediaHouse = getAllContentResponse.data!.contentList!;
              _filteredContentListByMediaHouse.addAll(_contentListByMediaHouse);
              _filteredContentList.clear();
              _filteredContentList = getAllContentResponse.data!.contentList!;
            }else{
              _filteredContentList.clear();
              _filteredContentList = getAllContentResponse.data!.contentList!;
            }
            notifyListeners();
          } else {
            _filteredContentList.clear();
            debugPrint("empty list: ${getAllContentResponse.message}");
            notifyListeners();
          }
        } else {
          _filteredContentList.clear();
          debugPrint("Error: ${getAllContentResponse.message}");
          notifyListeners();
        }
      } else if(response.statusCode == 404){
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
        GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == false) {
          _filteredContentList.clear();
          notifyListeners();
        }
      }else{
        if(status=="ALL"){
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
  Future<void> changeContentStatus(BuildContext context,String status, int id) async {
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
  Future<Content?> uploadContent(MediaHouse mediaHouse,BuildContext context) async {

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

    final url = Uri.parse(
        ApiConstant.uploadImg);
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
        GetAllMediaHouseByStatus getAllMediaHouseByStatus = GetAllMediaHouseByStatus.fromJson(responseBody);
        if (getAllMediaHouseByStatus.success == true) {
          if(getAllMediaHouseByStatus.data != null){
            _mediaHouseList.clear();
            _mediaHouseList = getAllMediaHouseByStatus.data!.mediaHouse!;
            notifyListeners();
          }else {
            debugPrint("empty list: ${getAllMediaHouseByStatus.message}");
          }
        } else {
          debugPrint("Error: ${getAllMediaHouseByStatus.message}");
        }
      } else {
        throw Exception('Failed to fetch mediaHouse. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }

  deleteVideo(int id,context) async {
    String apiUrl = ApiConstant.deleteVideoById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200 || response.statusCode == 500) {
          CustomToast.show("Deleted Successfully");
          notifyListeners();
         fetchMoviesByStatusAndMediaHouseId("All",0);
          Navigator.pop(context);
      } else {
        throw Exception('Failed to fetch mediaHouse. Status code: ${response.statusCode}');
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


  falseAllFilter(){
    isYear = false;isMonth = false;isWeek = false;
  }

  Future<void> contentRevenueGraph(int selectedTimeRange,int id, String startDateString, String endDateString) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else if(selectedTimeRange==2){
      isWeek=false;
      isMonth=false;
      isYear=true;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=false;
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
      if(chartResponse.success==true){
        chartData.clear();
        chartData = chartResponse.data!;
        // Debug print to verify
        for (var item in chartData) {
          print('Label: ${item.label}, Value: ${item.value}');
        }
        notifyListeners();
      }else{
        CustomToast.show(chartResponse.message.toString(), isSuccess: chartResponse.success!);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  setMoviePercentage(BuildContext context,Content content,double adminPercentage,double mediaHousePercentage, MediaHouse mediaHouse) async {
   

    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.setPercentage;
    print(apiUrl);
    PercentageRequest percentageRequest = PercentageRequest();
    percentageRequest.contentList = content.id;
    percentageRequest.date = isoDate;
    percentageRequest.isActive = true;
    percentageRequest.mediaHouse = mediaHouse!.id!;
    percentageRequest.percentageAdmin = adminPercentage;
    percentageRequest.percentageMediaHouse =mediaHousePercentage;
    percentageRequest.ticketRate = content.price;

    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = percentageRequest.toJson();
      debugPrint("Payload: ${json.encode(payload)}");

      var response = await apiHelper.postApiWithBody(
        apiUrl,
        payload,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);

        if (addVideoResponse.isSuccess == true) {
          CustomToast.show("Video added successfully");
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          notifyListeners();
          Navigator.of(context).pop();
        } else {
          debugPrint("Empty data: Record not added");
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

  Future<void> uploadVideo(bool isTrailer) async {
    final Uri uploadUri = Uri.parse(ApiConstant.uploadVideo);

    if (kIsWeb) {
      // Web implementation
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'video/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(files[0]);

          reader.onLoadEnd.listen((e) async {
            final data = reader.result as Uint8List;

            // Prepare and send the request
            final request = http.MultipartRequest('POST', uploadUri)
              ..files.add(http.MultipartFile.fromBytes(
                'profilePicture',
                data,
                filename: files[0].name,
              ));
            print(request);
            final response = await request.send();
            print(response.statusCode);
            if (response.statusCode == 200) {
              final responseBody = await response.stream.bytesToString();
              final responseJson = json.decode(responseBody);
              final encryptedUrl = responseJson['data']['encryptedUrl'];
              isTrailer?trailerUrlController.text = encryptedUrl:movieUrlController.text = encryptedUrl;
              print("Video uploaded successfully: $encryptedUrl");
            } else {
              print("Video upload failed with status: ${response.statusCode}");
            }
            notifyListeners();
          });
        }
      });
    } else {
      // Android/iOS implementation
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        // Prepare and send the request
        final request = http.MultipartRequest('POST', uploadUri)
          ..files.add(await http.MultipartFile.fromPath('profilePicture', file.path));

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseJson = json.decode(responseBody);
          final encryptedUrl = responseJson['data']['encryptedUrl'];
          isTrailer?trailerUrlController.text = encryptedUrl:movieUrlController.text = encryptedUrl;
          print("Video uploaded successfully: $encryptedUrl");
        } else {
          print("Video upload failed with status: ${response.statusCode}");
        }
        notifyListeners();
      } else {
        print("No video selected");
      }
    }
  }


  Future<Content?> editContent(BuildContext context, Content movie) async {


    String apiUrl = ApiConstant.videoEditRequest(movie.id,reasonController.text);


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
          debugPrint("Edit failed: ${addVideoResponse.message ?? 'Unknown error'}");
          CustomToast.show(addVideoResponse.message ?? "Edit failed.", isSuccess: false);
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        CustomToast.show("Failed to edit content. Please try again.", isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An unexpected error occurred. Please try again.", isSuccess: false);
    }
    return null; // Return null if the edit fails
  }
}

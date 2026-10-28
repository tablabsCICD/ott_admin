import 'dart:convert';
import 'dart:io' as io;
import 'package:admin_ott/data/models/response/getAllMediaHouseByStatus.dart';
import 'package:admin_ott/data/models/response/getMediaHouseResponse.dart';
import 'package:admin_ott/data/models/response/userTransactionResponse.dart';
import 'package:admin_ott/domain/entities/shorts_models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/loading/app_loading_controller.dart';
import 'package:universal_html/html.dart' as html;

import 'package:image_picker/image_picker.dart'; // For web-specific file handling

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/widgets/get_date_time.dart';
import 'package:admin_ott/data/models/request/mediaHouse_request.dart';
import 'package:admin_ott/data/models/response/addMediaHouseResponse.dart';
import 'package:admin_ott/data/models/response/getAllVideoResponse.dart'
    hide Data;
import 'package:admin_ott/data/models/response/searchResponse.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:admin_ott/domain/entities/content.dart';

//import 'package:cross_file/src/types/interface.dart';
import 'package:flutter/material.dart';
import '../../data/models/response/chartResponse.dart';
import '../../data/models/response/topRevenueMovie.dart';
import '../../data/models/response/getAllMediaHouseResponse.dart';
import '../../data/models/response/getAllUserResponse.dart';
import '../../data/models/response/mediaHouseDashboardCount.dart';
import '../../domain/entities/mediaHouse.dart';
import '../../domain/entities/user.dart';

import '../ui/pages/dashboard page/component/users_onboarded_graph.dart';
import '../widgets/show_toast.dart';

class MediaHouseProvider extends ChangeNotifier {
  MediaHouseProvider() : super() {
    searchMediaHouseController.addListener(filterMediaHouse);
  }

  TextEditingController searchMediaHouseController = TextEditingController();
  TextEditingController mediaHouseNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController adharCardController = TextEditingController();
  TextEditingController panCardController = TextEditingController();
  TextEditingController shopActController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController registrationCertificateController =
      TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController officeBuildingController = TextEditingController();
  TextEditingController registrationDateController = TextEditingController();
  TextEditingController profileController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController refferedByController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController talukaController = TextEditingController();
  bool isEnbale = false;

  List<MediaHouse> _mediaHouseList = [];
  List<MediaHouse> _filteredMediaHouseList = [];
  List<MediaHouse> _filteredMediaHouseListByStatus = [];
  MediaHouse _mediaHouse = MediaHouse();
  MediaHouse? _selectedMediaHouse = MediaHouse();
  List<UserTransactionData> _mediaHouseTransactions = [];
  bool _isTransactionsLoading = false;

  List<MediaHouse> get mediaHouseList => _mediaHouseList;

  List<MediaHouse> get filteredMediaHouseList => _filteredMediaHouseList;

  List<MediaHouse> get filteredMediaHouseListByStatus =>
      _filteredMediaHouseListByStatus;

  MediaHouse get mediaHouse => _mediaHouse;

  MediaHouse? get selectedMediaHouse => _selectedMediaHouse;
  List<UserTransactionData> get mediaHouseTransactions =>
      _mediaHouseTransactions;
  bool get isTransactionsLoading => _isTransactionsLoading;

  // Fetch all mediaHouse
  Future<void> fetchMediaHouse() async {
    String apiUrl = ApiConstant.getAllMediaHouseForAdmin;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("=== [Manage Media House API] ===");
      debugPrint("API URL: $apiUrl");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      debugPrint("================================");
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllMediaHouseResponse getAllMediaHouseResponse =
            GetAllMediaHouseResponse.fromJson(responseBody);
        if (getAllMediaHouseResponse.success == true) {
          if (getAllMediaHouseResponse.data != null) {
            _mediaHouseList.clear();
            _filteredMediaHouseList.clear();
            _mediaHouseList = getAllMediaHouseResponse.data!.mediaHouses!;
            _filteredMediaHouseList.addAll(_mediaHouseList);
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllMediaHouseResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllMediaHouseResponse.message}");
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

  // search all users
  Future<void> searchMediaHouse() async {
    String apiUrl =
        ApiConstant.searchMediaHouse(searchMediaHouseController.text);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        SearchResponse searchResponse = SearchResponse.fromJson(responseBody);
        if (searchResponse.success == true) {
          if (searchResponse.data != null) {
            _filteredMediaHouseList.clear();
            _filteredMediaHouseList = searchResponse.data!
                .map(
                    (item) => MediaHouse.fromJson(item as Map<String, dynamic>))
                .toList();
            notifyListeners();
          } else {
            debugPrint("empty list: ${searchResponse.message}");
          }
        } else {
          debugPrint("Error: ${searchResponse.message}");
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

  void filterMediaHouse() {
    final query = searchMediaHouseController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredMediaHouseList = List.from(_mediaHouseList);
    } else {
      _filteredMediaHouseList = _mediaHouseList.where((mediaHouse) {
        final name = (mediaHouse.mediaHouseName ?? '').toLowerCase();
        final contact = (mediaHouse.contactNumber ?? '').toLowerCase();
        final email = (mediaHouse.email ?? '').toLowerCase();
        final desc = (mediaHouse.discription?.toString() ?? '').toLowerCase();
        final state = (mediaHouse.location?.state ?? '').toLowerCase();
        final district = (mediaHouse.location?.district ?? '').toLowerCase();
        final taluka = (mediaHouse.location?.taluka ?? '').toLowerCase();
        final address = (mediaHouse.address ?? '').toLowerCase();

        return name.contains(query) ||
            contact.contains(query) ||
            email.contains(query) ||
            desc.contains(query) ||
            state.contains(query) ||
            district.contains(query) ||
            taluka.contains(query) ||
            address.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  setSelectedMediaHouse(MediaHouse house) {
    _selectedMediaHouse = house;
    searchMediaHouseController.clear();
    notifyListeners();
  }

  checkValidation() {
    if (mediaHouseNameController.text.isNotEmpty &&
        gstController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        shopActController.text.isNotEmpty &&
        panCardController.text.isNotEmpty &&
        adharCardController.text.isNotEmpty &&
        registrationCertificateController.text.isNotEmpty) {
      print(gstController.text +
          panCardController.text +
          adharCardController.text);
      isEnbale = true;
    } else {
      isEnbale = false;
    }
    notifyListeners();
  }

  // Create a new Production house
  Future<Map<String, Object>> createMediaHouse(
      int userId, BuildContext context) async {
    print(
        gstController.text + panCardController.text + adharCardController.text);
    String apiUrl = ApiConstant.saveMediaHouse;
    SaveMediaHouse saveMediaHouse = SaveMediaHouse();
    saveMediaHouse.address = addressController.text;
    saveMediaHouse.adharCard = adharCardController.text;
    saveMediaHouse.area = addressController.text;
    saveMediaHouse.officeBuilding = addressController.text;
    saveMediaHouse.contactNumber = mobileController.text;
    saveMediaHouse.createdDate = '';
    saveMediaHouse.discription = descriptionController.text;
    saveMediaHouse.email = emailController.text;
    saveMediaHouse.gstCertificates = gstController.text;
    saveMediaHouse.joinDate = GetDateFormat.getCurrentDate();
    saveMediaHouse.city = addressController.text;
    saveMediaHouse.country = countryController.text;
    saveMediaHouse.state = stateController.text;
    saveMediaHouse.district = districtController.text;
    saveMediaHouse.taluka = talukaController.text;
    saveMediaHouse.logo = profileController.text;
    saveMediaHouse.mediaHouseName = mediaHouseNameController.text;
    saveMediaHouse.otp = otpController.text;
    saveMediaHouse.password = passwordController.text;
    saveMediaHouse.panCard = panCardController.text;
    saveMediaHouse.postCount = "0";
    saveMediaHouse.profileImage = profileController.text;
    saveMediaHouse.pincode = '';
    saveMediaHouse.registrationCertificate =
        registrationCertificateController.text;
    saveMediaHouse.status = "PENDING";
    saveMediaHouse.shopAct = shopActController.text;
    saveMediaHouse.totalReveneu = "0";
    saveMediaHouse.totalViews = "0";
    saveMediaHouse.updatedDate = '';
    saveMediaHouse.userId = userId;

    ApiHelper apiHelper = ApiHelper();
    try {
      var response =
          await apiHelper.postApiWithBody(apiUrl, saveMediaHouse.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print("Add production house response:::" + response.body.toString());
        AddMediaHouseResponse addMediaHouseResponse =
            AddMediaHouseResponse.fromJson(responseBody);
        if (addMediaHouseResponse.success == true) {
          if (addMediaHouseResponse.data != null) {
            _mediaHouseList.add(addMediaHouseResponse.data!.mediaHouse!);
            _filteredMediaHouseList = _mediaHouseList;
            fetchMediaHouse();
            notifyListeners();
            return {
              'success': true,
              'message': 'production house created successfully'
            };
          } else {
            return {
              'success': false,
              'message': addMediaHouseResponse.message ?? 'Record not added'
            };
          }
        } else {
          return {
            'success': false,
            'message': addMediaHouseResponse.message ?? 'Record not added'
          };
        }
      } else {
        return {
          'failure': true,
          'message':
              'Failed to add production house. Status code: ${response.statusCode}'
        };
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while adding production house: $error'
      };
    }
  }

  Future<Map<String, Object>> createMediaHouseWithModel(
      SaveMediaHouse saveMediaHouse, BuildContext context) async {
    String apiUrl = ApiConstant.saveMediaHouse;
    saveMediaHouse.createdDate ??= '';
    saveMediaHouse.updatedDate ??= '';
    saveMediaHouse.status ??= "PENDING";
    saveMediaHouse.postCount ??= "0";
    saveMediaHouse.totalReveneu ??= "0";
    saveMediaHouse.totalViews ??= "0";

    ApiHelper apiHelper = ApiHelper();
    try {
      var response =
          await apiHelper.postApiWithBody(apiUrl, saveMediaHouse.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddMediaHouseResponse addMediaHouseResponse =
            AddMediaHouseResponse.fromJson(responseBody);
        if (addMediaHouseResponse.success == true) {
          if (addMediaHouseResponse.data?.mediaHouse != null) {
            _mediaHouseList.add(addMediaHouseResponse.data!.mediaHouse!);
            _filteredMediaHouseList = _mediaHouseList;
          }
          fetchMediaHouse();
          notifyListeners();
          return {
            'success': true,
            'message': addMediaHouseResponse.message ??
                'Production house created successfully'
          };
        } else {
          return {
            'success': false,
            'message': addMediaHouseResponse.message ?? 'Record not added'
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Failed to add production house. Status code: ${response.statusCode}'
        };
      }
    } catch (error) {
      debugPrint("Error creating media house: $error");
      return {
        'success': false,
        'message': 'An error occurred while adding production house: $error'
      };
    }
  }

  String? selectedImage;

  List<Content> _contentListByMediaHouseAndStatus = [];
  List<Content> _filteredContentListByMediaHouse = [];
  List<ShortMaster> _shortsByMediaHouse = [];
  bool _isShortsLoading = false;
  Content _mediaHouseContent = Content();
  Content _selectedMediaHouseContent = Content();

  List<Content> get contentListByMediaHouseAndStatus =>
      _contentListByMediaHouseAndStatus;

  List<Content> get filteredContentListByMediaHouse =>
      _filteredContentListByMediaHouse;
  List<ShortMaster> get shortsByMediaHouse => _shortsByMediaHouse;
  bool get isShortsLoading => _isShortsLoading;

  Content get mediaHouseContent => _mediaHouseContent;

  Content get selectedMediaHouseContent => _selectedMediaHouseContent;

  // Fetch all moviesByMediaHouseId
  Future<void> fetchMoviesByMediaHouseId(int mediaHouseId) async {
    final urls = [
      ApiConstant.videoByMediaHouseV2(mediaHouseId),
      ApiConstant.videoByMediaHouseV2Alias(mediaHouseId),
      ApiConstant.getVideoByMediaHouseId(mediaHouseId),
    ];
    final apiHelper = ApiHelper();
    for (final apiUrl in urls) {
      try {
        var response = await apiHelper.getApi(apiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = json.decode(response.body);
          GetAllVideoResponse getAllContentResponse =
              GetAllVideoResponse.fromJson(responseBody);
          if (getAllContentResponse.success == true) {
            if (getAllContentResponse.data != null) {
              _filteredContentListByMediaHouse.clear();
              _filteredContentListByMediaHouse =
                  getAllContentResponse.data!.contentList ?? [];
              notifyListeners();
              return;
            }
          }
        }
      } catch (error) {
        debugPrint("Error fetching Content from $apiUrl: $error");
      }
    }
  }

  Future<void> fetchShortsByMediaHouse(
    int mediaHouseId, {
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {
    final urls = [
      ApiConstant.shortsByMediaHouseV2(
        mediaHouseId,
        page: page,
        size: size,
        keyword: keyword,
      ),
      ApiConstant.shortsByMediaHouseV2Alias(
        mediaHouseId,
        page: page,
        size: size,
        keyword: keyword,
      ),
      ApiConstant.shortsByMediaHouse(
        mediaHouseId,
        page: page,
        size: size,
        keyword: keyword,
      ),
    ];
    final apiHelper = ApiHelper();
    _isShortsLoading = true;
    notifyListeners();

    for (final apiUrl in urls) {
      try {
        final response = await apiHelper.getApi(apiUrl);
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          final success = responseBody['success'] == true;
          if (success) {
            final data = responseBody['data'];
            final shortsRaw = (data is Map<String, dynamic>)
                ? data['miniSeries'] ?? data['shorts']
                : null;
            if (shortsRaw is List) {
              _shortsByMediaHouse = shortsRaw
                  .map((e) =>
                      ShortMaster.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
            } else {
              _shortsByMediaHouse = [];
            }
            _isShortsLoading = false;
            notifyListeners();
            return;
          }
        } else if (response.statusCode == 404) {
          _shortsByMediaHouse = [];
        }
      } catch (error) {
        debugPrint("Error while fetching shorts from $apiUrl: $error");
      }
    }
    _shortsByMediaHouse = [];
    _isShortsLoading = false;
    notifyListeners();
  }

  // Fetch all moviesByStatusAndMediaHouseId
  Future<void> fetchMediaHouseByStatus(String status) async {
    String apiUrl = ApiConstant.getMediaHouseByStatus(status);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("production house by status response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllMediaHouseByStatus getAllMediaHouseResponse =
            GetAllMediaHouseByStatus.fromJson(responseBody);
        if (getAllMediaHouseResponse.success == true) {
          if (getAllMediaHouseResponse.data != null &&
              getAllMediaHouseResponse.data!.mediaHouse != null) {
            _filteredMediaHouseListByStatus.clear();
            _filteredMediaHouseListByStatus =
                getAllMediaHouseResponse.data!.mediaHouse!;
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllMediaHouseResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllMediaHouseResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch production House. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching production House.');
    }
  }

  Future<void> fetchMediaHouseProfile(dynamic id) async {
    if (id == null) return;
    final urls = [
      ApiConstant.mediaHouseProfileV2(id),
      ApiConstant.mediaHouseProfileV2Alias(id),
      ApiConstant.getMediaHouseById(id),
    ];
    final apiHelper = ApiHelper();
    for (final url in urls) {
      try {
        final response = await apiHelper.getApi(url);
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          if (responseBody['success'] == true ||
              responseBody['statusCode'] == 200) {
            final data = responseBody['data'];
            if (data != null) {
              if (data is Map<String, dynamic>) {
                final houseJson =
                    data['MediaHouse'] ?? data['mediaHouse'] ?? data;
                if (houseJson is Map<String, dynamic>) {
                  _mediaHouse = MediaHouse.fromJson(houseJson);
                  _selectedMediaHouse = _mediaHouse;
                  notifyListeners();
                  return;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching media house profile from $url: $e");
      }
    }
  }

  Future<void> fetchMediaHouseTransactions(
    dynamic mediaHouseId, {
    String? startDate,
    String? endDate,
    int? page,
    int? size,
  }) async {
    if (mediaHouseId == null) return;
    _isTransactionsLoading = true;
    notifyListeners();
    final urls = [
      ApiConstant.mediaHouseTransactionsV2(
        mediaHouseId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        size: size,
      ),
      ApiConstant.mediaHouseTransactionsV2Alias(mediaHouseId),
    ];
    final apiHelper = ApiHelper();
    for (final url in urls) {
      try {
        final response = await apiHelper.getApi(url);
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          final res = UserTransactionResponse.fromJson(responseBody);
          if (res.success == true && res.data != null) {
            _mediaHouseTransactions = res.data!;
            _isTransactionsLoading = false;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint("Error fetching media house transactions from $url: $e");
      }
    }
    _isTransactionsLoading = false;
    notifyListeners();
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
        request.headers.addAll(await ApiHelper().multipartHeaders());
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final byteData = reader.result as List<int>;
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
            if ("Aadhaar Card" == lable) {
              adharCardController.text = _uploadedImageUrl!;
            } else if ("Pan Card" == lable) {
              panCardController.text = _uploadedImageUrl!;
            } else if ("Shop Act" == lable) {
              shopActController.text = _uploadedImageUrl!;
            } else if ("GST Certificate" == lable) {
              gstController.text = _uploadedImageUrl!;
            } else if ("Registration Certificate" == lable) {
              registrationCertificateController.text = _uploadedImageUrl!;
            } else {
              selectedImage = _uploadedImageUrl;
              profileController.text = _uploadedImageUrl!;
            }
          }
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
            if ("Aadhaar Card" == lable) {
              adharCardController.text = _uploadedImageUrl!;
            } else if ("Pan Card" == lable) {
              panCardController.text = _uploadedImageUrl!;
            } else if ("Shop Act" == lable) {
              shopActController.text = _uploadedImageUrl!;
            } else if ("GST Certificate" == lable) {
              gstController.text = _uploadedImageUrl!;
            } else if ("Registration Certificate" == lable) {
              registrationCertificateController.text = _uploadedImageUrl!;
            } else {
              selectedImage = _uploadedImageUrl;
              profileController.text = _uploadedImageUrl!;
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  String? _parseUploadedUrl(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is String) return _cleanUrl(decoded);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is String && data.isNotEmpty) return _cleanUrl(data);
        if (data is Map<String, dynamic>) {
          final candidate = data['fileUrl'] ??
              data['url'] ??
              data['imageUrl'] ??
              data['path'] ??
              data['filePath'];
          if (candidate != null) return _cleanUrl(candidate.toString());
        }
        final topCandidate = decoded['fileUrl'] ??
            decoded['url'] ??
            decoded['imageUrl'] ??
            decoded['path'] ??
            decoded['filePath'] ??
            decoded['message'];
        if (topCandidate != null) return _cleanUrl(topCandidate.toString());
      }
    } catch (e) {
      debugPrint('Error parsing uploaded URL: $e');
    }
    return _cleanUrl(responseBody);
  }

  String _cleanUrl(String raw) {
    var trimmed = raw.trim();
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      trimmed = trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
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
            if (status == "PENDING") {
              _contentListByMediaHouseAndStatus.clear();
              _contentListByMediaHouseAndStatus =
                  getAllContentResponse.data!.contentList!;
            } else {
              _filteredContentListByMediaHouse.clear();
              _filteredContentListByMediaHouse =
                  getAllContentResponse.data!.contentList!;
            }
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else if (response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == false) {
          _contentListByMediaHouseAndStatus.clear();

          notifyListeners();
        }
      } else {
        if (status == "ALL") {
          fetchMoviesByMediaHouseId(mediaHouseId);
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

  Future<void> changeMediaHouseStatus(String status, int id) async {
    String apiUrl = ApiConstant.changeMediaHouseStatus(status, id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.putApi(apiUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print(responseBody);
        MediaHouse mediaHouse = MediaHouse.fromJson(responseBody);
        _mediaHouse = mediaHouse;
        print("responseBody\n\n\n${mediaHouse.status}");
        CustomToast.show("MediaHouse '${status.toLowerCase()}' successfully",
            isSuccess: true);
        fetchMediaHouseByStatus("PENDING");
        notifyListeners();
      } else {
        throw Exception(
            'Failed to $status. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while changing status.');
    }
  }

  deleteMediaHouse(int id, context) async {
    String apiUrl = ApiConstant.deleteMediaHouseById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200 || response.statusCode == 500) {
        CustomToast.show("Deleted Successfully", isSuccess: true);
        notifyListeners();
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

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  Future<bool> updateMediaHouse(MediaHouse updatedHouse) async {
    _isUpdating = true;
    notifyListeners();

    final String apiUrl = ApiConstant.editMediaHouseById;
    final ApiHelper apiHelper = ApiHelper();
    final Map<String, dynamic> updatePayload = updatedHouse.toUpdateJson();

    debugPrint("Calling Update MediaHouse: $apiUrl -> Payload: $updatePayload");

    try {
      // Primary: PUT request with full payload
      var response = await apiHelper.putApiWithBody(apiUrl, updatePayload);

      // Graceful fallback to POST if method not allowed
      if (response.statusCode == 405) {
        debugPrint("PUT returned 405, attempting POST for $apiUrl");
        response = await apiHelper.postApiWithBody(apiUrl, updatePayload);
      }

      _isUpdating = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          if (responseBody.containsKey('data') && responseBody['data'] != null) {
            final dataMap = responseBody['data'];
            final houseMap = dataMap is Map<String, dynamic>
                ? (dataMap['MediaHouse'] ?? dataMap['mediaHouse'] ?? dataMap)
                : null;
            if (houseMap is Map<String, dynamic>) {
              final returnedHouse = MediaHouse.fromJson(houseMap);
              _syncUpdatedMediaHouse(returnedHouse);
            } else {
              _syncUpdatedMediaHouse(updatedHouse);
            }
          } else {
            _syncUpdatedMediaHouse(updatedHouse);
          }
        } catch (_) {
          _syncUpdatedMediaHouse(updatedHouse);
        }

        CustomToast.show("Production House updated successfully", isSuccess: true);
        
        // Refresh full media house list and profile in background to ensure 100% sync
        fetchMediaHouse();
        if (updatedHouse.id != null) {
          fetchMediaHouseProfile(updatedHouse.id);
        }

        notifyListeners();
        return true;
      } else {
        String errorMsg = "Failed to update Production House (HTTP ${response.statusCode})";
        try {
          final Map<String, dynamic> errMap = json.decode(response.body);
          if (errMap['message'] != null && errMap['message'].toString().isNotEmpty) {
            errorMsg = errMap['message'].toString();
          }
        } catch (_) {}
        CustomToast.show(errorMsg, isSuccess: false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isUpdating = false;
      debugPrint("Error updating MediaHouse: $e");
      CustomToast.show("An error occurred: $e", isSuccess: false);
      notifyListeners();
      return false;
    }
  }

  void _syncUpdatedMediaHouse(MediaHouse updated) {
    if (_mediaHouse.id == updated.id) {
      _mediaHouse = updated;
    }
    if (_selectedMediaHouse?.id == updated.id) {
      _selectedMediaHouse = updated;
    }
    final listIndex = _mediaHouseList.indexWhere((h) => h.id == updated.id);
    if (listIndex != -1) {
      _mediaHouseList[listIndex] = updated;
    }
    final filteredIndex =
        _filteredMediaHouseList.indexWhere((h) => h.id == updated.id);
    if (filteredIndex != -1) {
      _filteredMediaHouseList[filteredIndex] = updated;
    }
    final statusIndex =
        _filteredMediaHouseListByStatus.indexWhere((h) => h.id == updated.id);
    if (statusIndex != -1) {
      _filteredMediaHouseListByStatus[statusIndex] = updated;
    }
  }

  void setMediaHouse(MediaHouse? mediaHouse) {
    this._mediaHouse = mediaHouse!;
    notifyListeners();
  }

  MediaHouseDashboardData _mediaHouseDashboardData = MediaHouseDashboardData();
  bool _isDashboardDataLoading = false;
  String? _dashboardDataError;
  int? _loadedDashboardMediaHouseId;

  MediaHouseDashboardData get mediaHouseDashboardData =>
      _mediaHouseDashboardData;
  bool get isDashboardDataLoading => _isDashboardDataLoading;
  String? get dashboardDataError => _dashboardDataError;

  Future<void> fetchMediaHouseDashboardData(int mediaHouseId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _loadedDashboardMediaHouseId == mediaHouseId &&
        !_isDashboardDataLoading &&
        _mediaHouseDashboardData.productionHouseName != null) {
      return;
    }

    _isDashboardDataLoading = true;
    _dashboardDataError = null;
    if (_loadedDashboardMediaHouseId != mediaHouseId) {
      _mediaHouseDashboardData = MediaHouseDashboardData();
    }
    notifyListeners();

    final urls = [
      ApiConstant.mediaHouseDashboardCountV2(mediaHouseId),
      ApiConstant.mediaHouseDashboardCountV2Alias(mediaHouseId),
      ApiConstant.getMediaHouseDashboardCountForAdmin(mediaHouseId),
    ];

    final apiHelper = ApiHelper();
    for (final apiUrl in urls) {
      try {
        var response = await apiHelper.getApi(apiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = json.decode(response.body);
          MediaHouseDashboardCount mediaHouseDashboardCount =
              MediaHouseDashboardCount.fromJson(responseBody);
          if (mediaHouseDashboardCount.data != null) {
            _mediaHouseDashboardData = mediaHouseDashboardCount.data!;
            _loadedDashboardMediaHouseId = mediaHouseId;
            _isDashboardDataLoading = false;
            _dashboardDataError = null;
            notifyListeners();
            return;
          }
        }
      } catch (error) {
        debugPrint("Error fetching dashboard count from $apiUrl: $error");
      }
    }

    _isDashboardDataLoading = false;
    _dashboardDataError =
        "Failed to load dashboard data for media house #$mediaHouseId";
    notifyListeners();
  }

  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;
  List<LineChartData> chartData = [];

  Future<void> fetchMediaHouseCountGraph(int selectedTimeRange) async {
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = true;
    }
    String apiUrl = ApiConstant.mediaHouseCountGraph(
      '',
      '',
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if (chartResponse.success == true) {
        chartData.clear();
        for (var data in chartResponse.data!) {
          chartData.add(
            LineChartData(
              data.label as String,
              (data.value as num).toDouble(),
            ),
          );
        }

        // Debug print to verify
        for (var item in chartData) {
          print('Label: ${item.label}, Value: ${item.value}');
        }
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  List<LineChartData> graphData = [];
  Future<void> releaseMovieCountGraph(int selectedTimeRange, String startDate,
      String endDate, int mediaId,
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
    String apiUrl = ApiConstant.releaseMovieCountGraphByMediaHouse(
      mediaId,
      startDate,
      endDate,
      isYear,
      isMonth,
      isWeek,
      type: type,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if (chartResponse.success == true) {
        graphData.clear();
        for (var data in chartResponse.data!) {
          graphData.add(
            LineChartData(
              data.label as String,
              (data.value as num).toDouble(),
            ),
          );
        }
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  Future<void> viewsCountGraph(int selectedTimeRange, String startDate,
      String endDate, int mediaId,
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
    String apiUrl = ApiConstant.viewCountGraphByMediaHouse(
      mediaId,
      startDate,
      endDate,
      isYear,
      isMonth,
      isWeek,
      type: type,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);

      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if (chartResponse.success == true) {
        graphData.clear();
        for (var data in chartResponse.data!) {
          graphData.add(
            LineChartData(
              data.label as String,
              (data.value as num).toDouble(),
            ),
          );
        }
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  // List<Map<String, dynamic>>? revenueCountList = [];
  Future<void> revenueGraphByMediaHouse(int selectedTimeRange, String startDate,
      String endDate, int mediaId,
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
    final urls = [
      ApiConstant.mediaHouseRevenueGraphV2Clean(mediaId),
      ApiConstant.mediaHouseRevenueGraphV2(
        mediaId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      ),
      ApiConstant.mediaHouseRevenueGraphV2Alias(
        mediaId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      ),
      ApiConstant.revenueGraphByMediaHouse(
        mediaId,
        startDate,
        endDate,
        isYear,
        isMonth,
        isWeek,
        type: type,
      ),
    ];
    final apiHelper = ApiHelper();

    for (final apiUrl in urls) {
      try {
        var response = await apiHelper.getApi(apiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = json.decode(response.body);

          // 1. Try TopRevenueMovie (V2 revenue by content)
          try {
            TopRevenueMovie topRevenue = TopRevenueMovie.fromJson(responseBody);
            final items = topRevenue.data?.contentWithRevenue ?? [];
            if (items.isNotEmpty) {
              graphData.clear();
              for (var item in items) {
                graphData.add(
                  LineChartData(
                    item.name ?? 'Content',
                    item.mediaHouseNetRevenue ?? item.totalRevenue ?? 0.0,
                  ),
                );
              }
              notifyListeners();
              return;
            }
          } catch (_) {}

          // 2. Try legacy ChartResponse
          try {
            ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
            if (chartResponse.success == true && chartResponse.data != null) {
              graphData.clear();
              for (var data in chartResponse.data!) {
                graphData.add(
                  LineChartData(
                    data.label as String,
                    (data.value as num).toDouble(),
                  ),
                );
              }
              notifyListeners();
              return;
            }
          } catch (_) {}
        }
      } catch (error) {
        debugPrint("Error fetching revenue graph data from $apiUrl: $error");
      }
    }
  }

  // search all users
  Future<void> getMediaHouseById(int id) async {
    final urls = [
      ApiConstant.mediaHouseProfileV2(id),
      ApiConstant.mediaHouseProfileV2Alias(id),
      ApiConstant.getMediaHouseById(id),
    ];
    final apiHelper = ApiHelper();
    for (final apiUrl in urls) {
      try {
        var response = await apiHelper.getApi(apiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = json.decode(response.body);
          GetMediaHouseResponse searchResponse =
              GetMediaHouseResponse.fromJson(responseBody);
          if (searchResponse.success == true) {
            if (searchResponse.data?.mediaHouse != null) {
              _mediaHouse = searchResponse.data!.mediaHouse!;
              _selectedMediaHouse = _mediaHouse;
              notifyListeners();
              return;
            }
          }
        }
      } catch (error) {
        debugPrint("Error fetching mediaHouse from $apiUrl: $error");
      }
    }
  }
}

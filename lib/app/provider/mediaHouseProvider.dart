import 'dart:convert';
import 'dart:io' as io;
import 'package:admin_ott/data/models/response/getAllMediaHouseByStatus.dart';
import 'package:admin_ott/data/models/response/getMediaHouseResponse.dart';
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

  List<MediaHouse> get mediaHouseList => _mediaHouseList;

  List<MediaHouse> get filteredMediaHouseList => _filteredMediaHouseList;

  List<MediaHouse> get filteredMediaHouseListByStatus =>
      _filteredMediaHouseListByStatus;

  MediaHouse get mediaHouse => _mediaHouse;

  MediaHouse? get selectedMediaHouse => _selectedMediaHouse;

  // Fetch all mediaHouse
  Future<void> fetchMediaHouse() async {
    String apiUrl = ApiConstant.getAllMediaHouseForAdmin;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
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
    _filteredMediaHouseList = _mediaHouseList.where((mediaHouse) {
      final query = searchMediaHouseController.text.toLowerCase();
      return mediaHouse.mediaHouseName!.toLowerCase().contains(query) ||
          mediaHouse.contactNumber!.toLowerCase().contains(query) ||
          mediaHouse.email!.toLowerCase().contains(query) ||
          mediaHouse.discription!.toLowerCase().contains(query) ||
          mediaHouse.location!.state!.toLowerCase().contains(query) ||
          mediaHouse.location!.district!.toLowerCase().contains(query) ||
          mediaHouse.location!.taluka!.toLowerCase().contains(query);
    }).toList();
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
        /*throw Exception(
            'Failed to add production house. Status code: ${response.statusCode}');
*/
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while adding production house: $error'
      };
      // throw Exception('An error occurred while adding production house.');
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
    String apiUrl = ApiConstant.getVideoByMediaHouseId(mediaHouseId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: " + responseBody.toString());
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);

        debugPrint("data::: " + getAllContentResponse.data.toString());
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data != null) {
            _filteredContentListByMediaHouse.clear();
            _filteredContentListByMediaHouse =
                getAllContentResponse.data!.contentList!;
            debugPrint("length::: " +
                _filteredContentListByMediaHouse.length.toString());

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

  Future<void> fetchShortsByMediaHouse(
    int mediaHouseId, {
    String? keyword,
    int page = 0,
    int size = 10,
  }) async {
    final apiUrl = ApiConstant.shortsByMediaHouse(
      mediaHouseId,
      page: page,
      size: size,
      keyword: keyword,
    );
    final apiHelper = ApiHelper();
    _isShortsLoading = true;
    notifyListeners();

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
                .map((e) => ShortMaster.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            _shortsByMediaHouse = [];
          }
        } else {
          _shortsByMediaHouse = [];
          debugPrint("shorts fetch failed: ${responseBody['message']}");
        }
      } else if (response.statusCode == 404) {
        _shortsByMediaHouse = [];
      } else {
        throw Exception(
            'Failed to fetch shorts. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error while fetching shorts: $error");
      _shortsByMediaHouse = [];
    } finally {
      _isShortsLoading = false;
      notifyListeners();
    }
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
          if (getAllMediaHouseResponse.data != null ||
              getAllMediaHouseResponse.data != "") {
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
          'profilePicture',
          byteData,
          filename: _webFile!.name,
        );

        request.files.add(multipartFile);
        final response =
            await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          print(lable);
          if ("Aadhaar Card" == lable) {
            adharCardController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("Pan Card" == lable) {
            panCardController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("Shop Act" == lable) {
            shopActController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("GST Certificate" == lable) {
            gstController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("Registration Certificate" == lable) {
            registrationCertificateController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else {
            selectedImage = _uploadedImageUrl;
            profileController.text = _uploadedImageUrl!;
            print(lable + selectedImage.toString());
          }
        }
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile/desktop upload logic
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          _imageFile!.path,
          //  contentType: MediaType('image', 'jpeg'),
        ));
        final response =
            await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          print(lable);
          if ("Aadhaar Card" == lable) {
            adharCardController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("Pan Card" == lable) {
            panCardController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("Shop Act" == lable) {
            shopActController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("GST Certificate" == lable) {
            gstController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else if ("Registration Certificate" == lable) {
            registrationCertificateController.text = _uploadedImageUrl!;
            print(lable + adharCardController.text);
          } else {
            selectedImage = _uploadedImageUrl;
            profileController.text = _uploadedImageUrl!;
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

  void setMediaHouse(MediaHouse? mediaHouse) {
    this._mediaHouse = mediaHouse!;
    notifyListeners();
  }

  MediaHouseDashboardData _mediaHouseDashboardData = MediaHouseDashboardData();

  MediaHouseDashboardData get mediaHouseDashboardData =>
      _mediaHouseDashboardData;

  Future<void> fetchMediaHouseDashboardData(int mediaHouseId) async {
    String apiUrl =
        ApiConstant.getMediaHouseDashboardCountForAdmin(mediaHouseId);

    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: " + responseBody.toString());
        MediaHouseDashboardCount mediaHouseDashboardCount =
            MediaHouseDashboardCount.fromJson(responseBody);
        debugPrint("data::: " + mediaHouseDashboardCount.data.toString());
        if (mediaHouseDashboardCount.isSuccess == true) {
          if (mediaHouseDashboardCount.data != null) {
            _mediaHouseDashboardData = mediaHouseDashboardCount.data!;
            debugPrint("message : ${mediaHouseDashboardCount.message}");
            notifyListeners();
          } else {
            debugPrint("empty list: ${mediaHouseDashboardCount.message}");
          }
        } else {
          debugPrint("Error: ${mediaHouseDashboardCount.message}");
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
      String endDate, int mediaId) async {
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
      String endDate, int mediaId) async {
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
      String endDate, int mediaId) async {
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
    String apiUrl = ApiConstant.revenueGraphByMediaHouse(
      mediaId,
      startDate,
      endDate,
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
        CustomToast.show(chartResponse.message.toString(),
            isSuccess: chartResponse.success!);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  // search all users
  Future<void> getMediaHouseById(int id) async {
    String apiUrl = ApiConstant.getMediaHouseById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        print("responseBody\n\n\n");
        print(responseBody);
        GetMediaHouseResponse searchResponse =
            GetMediaHouseResponse.fromJson(responseBody);
        if (searchResponse.success == true) {
          if (searchResponse.data != null) {
            _mediaHouse = searchResponse.data!.mediaHouse!;
            print(
                "responseBody\n\n\n${searchResponse.data!.mediaHouse!.status}");
            notifyListeners();
          } else {
            debugPrint("empty object: ${searchResponse.message}");
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
}

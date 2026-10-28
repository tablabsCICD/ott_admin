import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

import 'package:admin_ott/data/models/response/getAllUserResponse.dart';
import 'package:admin_ott/data/models/response/getUserResponse.dart';
import 'package:admin_ott/data/models/response/loginUser.dart';
import 'package:admin_ott/data/models/response/updateUserResponse.dart';
import 'package:admin_ott/domain/entities/user.dart';

import '../../data/models/request/user_request.dart';
import '../../data/models/response/addUserResponse.dart';
import '../../data/models/response/errorResponse.dart';
import '../../data/models/response/moviePurchaseByUserResponse.dart';
import '../core/constant/api_constant.dart';
import '../core/constant/prefrense_constant.dart';
import '../core/loading/app_loading_controller.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';
import '../widgets/show_toast.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() : super() {
    searchController.addListener(_onSearchChanged);
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController talukaController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController officeBuildingController = TextEditingController();
  TextEditingController registrationDateController = TextEditingController();
  TextEditingController profileController = TextEditingController();
  TextEditingController pinCodeDateController = TextEditingController();
  TextEditingController refferedByController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController referedByController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  TextEditingController joinDateController = TextEditingController();

  String? selectedGender;
  List<String> selectedLanguages = [];
  File? image;

  bool isEnbale = false;
  Timer? _searchDebounce;
  bool _isSearching = false;

  bool get isSearching => _isSearching;

  void _onSearchChanged() {
    searchUsers(searchController.text);
  }

  void searchUsers(String? rawQuery, {bool immediate = false}) {
    final query = (rawQuery ?? searchController.text).trim();

    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _isSearching = false;
      _filteredUsers = List<User>.from(_users);
      notifyListeners();
      return;
    }

    _currentPage = 0;

    if (immediate) {
      _executeSearchApi(query);
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 350), () {
        _executeSearchApi(query);
      });
    }
  }

  Future<void> _executeSearchApi(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _filteredUsers = List<User>.from(_users);
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    String apiUrl = ApiConstant.searchUser(trimmedQuery);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("=== [Search User API] ===");
      debugPrint("API URL: $apiUrl");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      debugPrint("=========================");

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final decoded = json.decode(response.body);
          List<User> resultUsers = [];

          if (decoded is List) {
            resultUsers = decoded
                .whereType<Map<String, dynamic>>()
                .map((x) => User.fromJson(x))
                .toList();
          } else if (decoded is Map<String, dynamic>) {
            final data = decoded['data'];
            if (data is List) {
              resultUsers = data
                  .whereType<Map<String, dynamic>>()
                  .map((x) => User.fromJson(x))
                  .toList();
            } else if (data is Map<String, dynamic>) {
              if (data['users'] is List) {
                resultUsers = (data['users'] as List)
                    .whereType<Map<String, dynamic>>()
                    .map((x) => User.fromJson(x))
                    .toList();
              } else if (data['user'] is Map<String, dynamic>) {
                resultUsers = [
                  User.fromJson(data['user'] as Map<String, dynamic>)
                ];
              }
            } else if (decoded['users'] is List) {
              resultUsers = (decoded['users'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((x) => User.fromJson(x))
                  .toList();
            }
          }

          _filteredUsers = resultUsers;
        } else {
          _filteredUsers = [];
        }
      } else {
        debugPrint("Search user API returned status code: ${response.statusCode}");
        _applyLocalSearch(trimmedQuery);
      }
    } catch (error) {
      debugPrint("Error searching users via API: $error");
      _applyLocalSearch(trimmedQuery);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void _applyLocalSearch(String query) {
    final lowerQuery = query.toLowerCase();
    _filteredUsers = _users.where((user) {
      final values = [
        user.firstName,
        user.lastName,
        user.mobileNumber,
        user.emailId,
        user.refferedBy,
        user.location?.city,
        user.location?.state,
        user.location?.district,
        user.location?.taluka,
      ];

      return values
          .any((value) => value?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void applySearch([String? rawQuery]) {
    searchUsers(rawQuery);
  }

  void clearUserSearch() {
    _searchDebounce?.cancel();
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    }
    _isSearching = false;
    _currentPage = 0;
    _filteredUsers = List<User>.from(_users);
    notifyListeners();
    fetchUsers(page: 0);
  }

  void filterUsers() {
    searchUsers(searchController.text);
  }

  setValue(User? user) async {
    print("SEtData${user!.firstName}");
    firstNameController.text = user.firstName ?? "";
    lastNameController.text = user.lastName ?? "";
    mobileController.text = user.mobileNumber ?? "";
    emailController.text = user.emailId ?? "";
    dobController.text = user.dob ?? "";
    profileController.text = user.profilePhoto ?? "";
    notifyListeners();
  }

  checkValidation() {
    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        dobController.text.isNotEmpty) {
      isEnbale = true;
    } else {
      isEnbale = false;
    }
    notifyListeners();
  }

  List<User> _users = [];
  List<User> _filteredUsers = [];
  final Set<String> _updatingUserStatusMobiles = {};
  User user = User();

  int _currentPage = 0;
  int _pageSize = 20;
  int _totalUsers = 0;
  int _totalPages = 1;
  bool _hasNext = false;
  bool _hasPrevious = false;
  bool _isLoadingUsers = false;

  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  bool isUpdatingUserStatus(String? mobileNumber) =>
      mobileNumber != null && _updatingUserStatusMobiles.contains(mobileNumber);
  User get userObj => user;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalUsers => _totalUsers;
  int get totalPages => _totalPages;
  bool get hasNext => _hasNext;
  bool get hasPrevious => _hasPrevious;
  bool get isLoadingUsers => _isLoadingUsers;

  // Update user data
  Future<Map<String, Object>> updateUser() async {
    User? user = await LocalSharePreferences.localSharePreferences.getUser();
    String apiUrl = ApiConstant.editUserById;
    ApiHelper apiHelper = ApiHelper();
    Map<String, dynamic> data = {
      "admin": true,
      "emailId": emailController.text,
      "firstName": firstNameController.text,
      "id": user!.id,
      "lastName": lastNameController.text,
      "mobileNumber": mobileController.text,
      "profilePhoto": profileController.text
    };

    try {
      var response = await apiHelper.putApiWithBody(apiUrl, data);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        UpdateUserResponse updateUserResponse =
            UpdateUserResponse.fromJson(responseBody);

        debugPrint("data: ${updateUserResponse.message}");
        if (updateUserResponse.success == true) {
          if (updateUserResponse.data != null) {
            this.user = updateUserResponse.data!;
            print("before SEtData ${user.firstName}");
            LocalSharePreferences localSharePreferences =
                LocalSharePreferences();
            localSharePreferences.setString(
                SharedPreferencesConstant.currentAdmin,
                jsonEncode(updateUserResponse.data!));
            print(
                "after SEtData ${await localSharePreferences.getString(SharedPreferencesConstant.currentAdmin)}");
            notifyListeners();
            return {
              'success': true,
              'message': updateUserResponse.message ?? ""
            };
          } else {
            debugPrint("Empty data: ${updateUserResponse.message}");
            return {
              'success': false,
              'message': updateUserResponse.message ?? 'No data returned'
            };
          }
        } else {
          debugPrint("Error: ${updateUserResponse.message}");
          return {
            'success': false,
            'message': updateUserResponse.message ?? 'Error in response'
          };
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse addUserResponse =
            AddUserResponse.fromJson(responseBody);
        debugPrint("Error: ${addUserResponse.message}");
        return {
          'success': false,
          'message': addUserResponse.message ?? 'Error in response'
        };
      } else {
        return {'failure': true, 'message': 'Something went wrong!'};
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Login request timed out. Please try again.'
      };
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while update user: $error'
      };
    }
  }

  // Delete a user
  Future<bool> deleteUser(int id) async {
    String apiUrl = ApiConstant.deleteUserById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse deleteUserResponse =
            AddUserResponse.fromJson(responseBody);
        if (deleteUserResponse.success == true) {
          _users.removeWhere((u) => u.id == id);
          _filteredUsers.removeWhere((u) => u.id == id);
          CustomToast.show(
            deleteUserResponse.message ?? "User deleted successfully!",
            isSuccess: true,
          );
          notifyListeners();
          return true;
        } else {
          debugPrint("Error: ${deleteUserResponse.message}");
          CustomToast.show(
            deleteUserResponse.message ?? "Failed to delete user.",
            isSuccess: false,
          );
          return false;
        }
      } else {
        CustomToast.show(
          "Failed to delete user. Status code: ${response.statusCode}",
          isSuccess: false,
        );
        return false;
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An error occurred while deleting user.",
          isSuccess: false);
      return false;
    }
  }

  Future<void> changeUserActiveStatus(User selectedUser, bool active) async {
    final mobileNumber = selectedUser.mobileNumber?.trim();

    if (mobileNumber == null || mobileNumber.trim().isEmpty) {
      CustomToast.show("Mobile number not found for this user.",
          isSuccess: false);
      return;
    }

    if (_updatingUserStatusMobiles.contains(mobileNumber)) {
      return;
    }

    final previousStatus = selectedUser.active ?? false;
    final apiUrl = ApiConstant.changeUserActiveStatus(mobileNumber);
    final apiHelper = ApiHelper();

    _updatingUserStatusMobiles.add(mobileNumber);
    _setUserActiveStatus(mobileNumber, active);
    notifyListeners();

    try {
      final response = await apiHelper.putApiWithBody(
        apiUrl,
        {"active": active},
      );

      final Map<String, dynamic> responseBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        final updatedStatus =
            responseBody["isActive"] ?? responseBody["active"] ?? active;
        _setUserActiveStatus(mobileNumber, updatedStatus == true);
        CustomToast.show(
          responseBody["message"] ??
              "User ${active ? "activated" : "deactivated"} successfully.",
          isSuccess: true,
        );
      } else {
        _setUserActiveStatus(mobileNumber, previousStatus);
        CustomToast.show(
          responseBody["message"] ??
              "Failed to update user status. Status code: ${response.statusCode}",
          isSuccess: false,
        );
      }
    } catch (error) {
      _setUserActiveStatus(mobileNumber, previousStatus);
      debugPrint("Error: $error");
      CustomToast.show("An error occurred while updating user status.",
          isSuccess: false);
    } finally {
      _updatingUserStatusMobiles.remove(mobileNumber);
      applySearch();
    }
  }

  void _setUserActiveStatus(String mobileNumber, bool active) {
    for (final user in _users) {
      if (user.mobileNumber?.trim() == mobileNumber) {
        user.active = active;
      }
    }

    for (final user in _filteredUsers) {
      if (user.mobileNumber?.trim() == mobileNumber) {
        user.active = active;
      }
    }
  }

  Future<void> getUserById(int id) async {
    String apiUrl = ApiConstant.getUserById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetUserResponse addUserResponse =
            GetUserResponse.fromJson(responseBody);
        if (addUserResponse.success == true) {
          if (addUserResponse.data != null &&
              addUserResponse.data!.user != null) {
            user = addUserResponse.data!.user!;
            setValue(user);
            notifyListeners();
          } else {
            CustomToast.show("empty data: ${addUserResponse.message}",
                isSuccess: false);
            debugPrint("empty data: ${addUserResponse.message}");
          }
        } else {
          CustomToast.show("Error: ${addUserResponse.message}",
              isSuccess: false);
          debugPrint("Error: ${addUserResponse.message}");
        }
      } else {
        CustomToast.show(
            "Failed to delete user. Status code: ${response.statusCode}",
            isSuccess: false);
        throw Exception(
            'Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An error occurred while get user.", isSuccess: false);
      throw Exception('An error occurred while get user.');
    }
  }

  setImage(XFile pickedFile) {
    image = null;
    image = File(pickedFile.path);
    notifyListeners();
  }

  setDate(DateTime pickedDate, bool isDob) {
    if (isDob) {
      dobController.text = pickedDate.toLocal().toString().split(' ')[0];
    } else {
      joinDateController.text = pickedDate.toLocal().toString().split(' ')[0];
    }

    notifyListeners();
  }

  login(String email, String password) async {
    String apiUrl = ApiConstant.login;
    Map<String, dynamic> data = {"emailId": email, "password": password};
    ApiHelper apiHelper = ApiHelper();

    try {
      var response =
          await apiHelper.postApiWithBody(apiUrl, data, includeAuth: false);
      if (response.statusCode == 200) {
        //log("user login response: ${response.body}");
        Map<String, dynamic> responseBody = json.decode(response.body);
        LoginUserResponse addUserResponse =
            LoginUserResponse.fromJson(responseBody);

        debugPrint("data: ${addUserResponse.message}");
        if (addUserResponse.success == true) {
          if (addUserResponse.data?.user != null) {
            final loggedInUser = addUserResponse.data!.user!;
            final hasAdminRole = (loggedInUser.role ?? [])
                .any((role) => role.toLowerCase() == 'admin');

            if (loggedInUser.admin == true || hasAdminRole) {
              user = loggedInUser;
              final authToken =
                  addUserResponse.data!.jwt ?? addUserResponse.data!.token;
              final tokenType = addUserResponse.data!.tokenType ?? "Bearer";
              //log("before SEtData ${user.firstName}");
              LocalSharePreferences localSharePreferences =
                  LocalSharePreferences();
              await localSharePreferences.setBool(
                  SharedPreferencesConstant.isAdminLoggedIn, true);
              if (authToken != null && authToken.isNotEmpty) {
                await localSharePreferences.setString(
                    SharedPreferencesConstant.authToken, authToken);
                await localSharePreferences.setString(
                    SharedPreferencesConstant.authTokenType, tokenType);
              }
              if (addUserResponse.data!.sessionId != null) {
                await localSharePreferences.setString(
                    SharedPreferencesConstant.sessionId,
                    addUserResponse.data!.sessionId!);
              }
              //log("check  SEtLogin ${await localSharePreferences.getBool(SharedPreferencesConstant.isAdminLoggedIn)}");
              await localSharePreferences.setString(
                  SharedPreferencesConstant.currentAdmin,
                  jsonEncode(addUserResponse.data!.user));
              //log("after SEtData ${await localSharePreferences.getString(SharedPreferencesConstant.currentAdmin)}");
              notifyListeners();
              return {
                'success': true,
                'message': addUserResponse.message ??
                    'User logged in successfully'
              };
            } else {
              CustomToast.show(
                  "You are not admin..try with admin credentials...");
              notifyListeners();
              return {
                'success': false,
                'message': "You are not admin..try with admin credentials..."
              };
            }
          } else {
            debugPrint("Empty data: ${addUserResponse.message}");
            return {
              'success': false,
              'message': addUserResponse.message ?? 'No data returned'
            };
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
          return {
            'success': false,
            'message': addUserResponse.message ?? 'Error in response'
          };
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse addUserResponse =
            AddUserResponse.fromJson(responseBody);
        debugPrint("Error: ${addUserResponse.message}");
        return {
          'success': false,
          'message': addUserResponse.message ?? 'Error in response'
        };
      } else {
        return {'failure': true, 'message': 'Something went wrong!'};
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while logging user: $error'
      };
    }
  }

  // Fetch all users with pagination
  Future<void> fetchUsers({int? page, int? size}) async {
    if (_isLoadingUsers) return;

    final targetPage = page ?? _currentPage;
    final targetSize = size ?? _pageSize;

    _isLoadingUsers = true;
    notifyListeners();

    String apiUrl = ApiConstant.getAllUsersPaged(page: targetPage, size: targetSize);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllUserResponse getAllUserResponse =
            GetAllUserResponse.fromJson(responseBody);
        if (getAllUserResponse.success == true) {
          final pagination = getAllUserResponse.pagination ??
              getAllUserResponse.data?.pagination ??
              UserPagination.fromJson(responseBody);

          _currentPage = pagination.page;
          _pageSize = pagination.size;
          _totalUsers = pagination.totalItems;
          _totalPages = pagination.totalPages > 0 ? pagination.totalPages : 1;
          _hasNext = pagination.hasNext;
          _hasPrevious = pagination.hasPrevious;

          if (getAllUserResponse.data != null &&
              getAllUserResponse.data!.users != null) {
            _users = getAllUserResponse.data!.users!;
          } else {
            _users = [];
          }

          if (searchController.text.trim().isNotEmpty) {
            searchUsers(searchController.text);
          } else {
            _filteredUsers = List<User>.from(_users);
          }
        } else {
          debugPrint("Error: ${getAllUserResponse.message}");
        }
      } else {
        debugPrint(
            'Failed to fetch users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error fetching users: $error");
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (!_hasNext || _isLoadingUsers) return;
    await fetchUsers(page: _currentPage + 1);
  }

  Future<void> previousPage() async {
    if (!_hasPrevious || _isLoadingUsers || _currentPage <= 0) return;
    await fetchUsers(page: _currentPage - 1);
  }

  Future<void> goToPage(int page) async {
    if (page < 0 || page >= _totalPages || page == _currentPage || _isLoadingUsers) {
      return;
    }
    await fetchUsers(page: page);
  }

  Future<Map<String, dynamic>> createUser() async {
    String apiUrl = ApiConstant.registration;
    UserRequest userRequest = UserRequest();
    userRequest.admin = false;
    userRequest.age = '';
    userRequest.area = officeBuildingController.text;
    userRequest.city = talukaController.text;
    userRequest.country = countryController.text;
    userRequest.deviceId = '';
    userRequest.deviceName = '';
    userRequest.deviceToken = '';
    userRequest.district = districtController.text;
    userRequest.dob = dobController.text;
    userRequest.emailId = emailController.text;
    userRequest.firstName = firstNameController.text;
    userRequest.gender = selectedGender;
    userRequest.joinDate = joinDateController.text;
    userRequest.mobileNumber = mobileController.text;
    userRequest.lastName = lastNameController.text;
    userRequest.locationId = 0;
    userRequest.officeBuilding = officeBuildingController.text;
    userRequest.osName = "Web";
    userRequest.password = passwordController.text;
    userRequest.pincode = "411017";
    userRequest.profilePhoto = profileController.text;
    userRequest.refferedBy = refferedByController.text;
    userRequest.taluka = talukaController.text;
    userRequest.state = stateController.text;
    userRequest.verified = true;

    ApiHelper apiHelper = ApiHelper();

    try {
      var response =
          await apiHelper.postApiWithBody(apiUrl, userRequest.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetUserResponse addUserResponse =
            GetUserResponse.fromJson(responseBody);

        if (addUserResponse.success == true) {
          if (addUserResponse.data != null) {
            user = addUserResponse.data!.user!;
            users.add(user);
            notifyListeners();
            return {'success': true, 'message': 'User created successfully'};
          } else {
            debugPrint("Empty data: ${addUserResponse.message}");
            return {
              'success': false,
              'message': addUserResponse.message ?? 'No data returned'
            };
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
          return {
            'success': false,
            'message': addUserResponse.message ?? 'Error in response'
          };
        }
      } else if (response.statusCode == 500) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        ErrorResposne addUserResponse = ErrorResposne.fromJson(responseBody);
        return {'success': false, 'message': addUserResponse.message};
      } else {
        return {'success': false, 'message': 'Something went wrong!'};
      }
      // throw Exception('Failed to add user. Status code: ${response.statusCode}');
    } catch (error) {
      debugPrint("Error: $error");
      return {
        'success': false,
        'message': 'An error occurred while adding user: $error'
      };
    }
  }

  io.File? _imageFile; // Mobile/Desktop
  html.File? _webFile; // Web
  String? _uploadedImageUrl;
  bool _isUploading = false;

  io.File? get imageFile => _imageFile;
  html.File? get webFile => _webFile;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get isUploading => _isUploading;

  // Pick Image
  Future<void> pickImage() async {
    try {
      if (kIsWeb) {
        final uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        uploadInput.onChange.listen((event) async {
          if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
            _webFile = uploadInput.files!.first;
            notifyListeners();
            await uploadImage();
          }
        });
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          _imageFile = io.File(pickedFile.path);
          notifyListeners();
          await uploadImage();
        } else {
          CustomToast.show('No image selected', isWarning: true);
        }
      }
    } on PlatformException catch (e) {
      //log('Image picker permission error: $e');
      CustomToast.show(
        'Permission denied. Please allow photo/gallery access in app settings.',
        isSuccess: false,
      );
    } catch (e) {
      //log('Error picking image: $e');
      CustomToast.show(
        'Unable to select image. Please try again.',
        isSuccess: false,
      );
    }
  }

  // Upload Image
  Future<void> uploadImage() async {
    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webFile == null)) {
      _isUploading = false;
      notifyListeners();
      return;
    }

    _isUploading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        ApiConstant.uploadImg,
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await ApiHelper().multipartHeaders());
      if (kIsWeb && _webFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final bytes = reader.result as List<int>;
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: _webFile!.name,
          ),
        );
      } else if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _imageFile!.path,
          ),
        );
      }

      final streamedResponse =
          await AppLoadingController.trackFuture(() => request.send());
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final decoded = jsonDecode(responseBody);

        final fileUrl = decoded['data']?['fileUrl'];
        if (fileUrl != null && fileUrl is String) {
          _uploadedImageUrl = fileUrl;
          profileController.text = _uploadedImageUrl!;
          //log('Image uploaded: $_uploadedImageUrl');
          CustomToast.show('Image uploaded successfully', isSuccess: true);
        } else {
          //log('Upload success but fileUrl missing');
          CustomToast.show(
            'Upload succeeded but image URL was not returned.',
            isSuccess: false,
          );
        }
      } else {
        //log(
        //   'Upload failed: ${streamedResponse.statusCode} -> $responseBody',
        // );
        CustomToast.show(
          'Upload failed (${streamedResponse.statusCode}). Please try again.',
          isSuccess: false,
        );
      }
    } catch (e) {
      //log('Error uploading image: $e');
      CustomToast.show(
        'Image upload failed. Please check network and permissions.',
        isSuccess: false,
      );
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  List<UserContent> _userContentList = [];
  List<UserContent> get userContentList => _userContentList;

  List<UserContent> _filtteredUserContentList = [];
  List<UserContent> get filtteredUserContentList => _filtteredUserContentList;

  bool _isUserContentLoading = false;
  bool get isUserContentLoading => _isUserContentLoading;

  String? _userContentErrorMessage;
  String? get userContentErrorMessage => _userContentErrorMessage;

  String _userContentFilterStatus = 'All';
  String get userContentFilterStatus => _userContentFilterStatus;

  String _userContentSearchQuery = '';
  String get userContentSearchQuery => _userContentSearchQuery;

  Future<void> fetchUserContent(int userId) async {
    _isUserContentLoading = true;
    _userContentErrorMessage = null;
    notifyListeners();

    String apiUrl = ApiConstant.getPurchaseMovieByUser(userId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("=== [User Purchased Content API] ===");
      debugPrint("API URL: $apiUrl");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      debugPrint("====================================");

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        MoviePurchaseByUserResponse moviePurchaseByUserResponse =
            MoviePurchaseByUserResponse.fromJson(responseBody);
        if (moviePurchaseByUserResponse.success == true) {
          _userContentList.clear();
          if (moviePurchaseByUserResponse.data?.userContent != null) {
            _userContentList =
                moviePurchaseByUserResponse.data!.userContent!;
          }
          _applyUserContentFilter();
        } else {
          _userContentList.clear();
          _filtteredUserContentList.clear();
          _userContentErrorMessage =
              moviePurchaseByUserResponse.message ?? 'No content found';
        }
      } else {
        _userContentList.clear();
        _filtteredUserContentList.clear();
        _userContentErrorMessage =
            "Failed to fetch content. Status code: ${response.statusCode}";
      }
    } catch (error) {
      debugPrint("Error fetching user content: $error");
      _userContentList.clear();
      _filtteredUserContentList.clear();
      _userContentErrorMessage =
          "An error occurred while fetching user content.";
    } finally {
      _isUserContentLoading = false;
      notifyListeners();
    }
  }

  void setUserContentFilter(String status) {
    _userContentFilterStatus = status;
    _applyUserContentFilter();
  }

  void setUserContentSearch(String query) {
    _userContentSearchQuery = query;
    _applyUserContentFilter();
  }

  void _applyUserContentFilter() {
    List<UserContent> list = List.from(_userContentList);

    if (_userContentFilterStatus.toLowerCase() == 'available') {
      list = list.where((item) => item.active == true).toList();
    } else if (_userContentFilterStatus.toLowerCase() == 'expired') {
      list = list.where((item) => item.active == false).toList();
    }

    if (_userContentSearchQuery.trim().isNotEmpty) {
      final q = _userContentSearchQuery.trim().toLowerCase();
      list = list.where((item) {
        final title = item.movie?.title?.toLowerCase() ?? '';
        final idStr = item.id?.toString() ?? '';
        final movieType = item.movie?.type?.toLowerCase() ?? '';
        final desc = item.movie?.description?.toLowerCase() ?? '';
        return title.contains(q) ||
            idStr.contains(q) ||
            movieType.contains(q) ||
            desc.contains(q);
      }).toList();
    }

    _filtteredUserContentList = list;
    notifyListeners();
  }
}


import 'dart:convert';
import 'dart:io' as io;
import 'package:admin_ott/data/models/response/getUserResponse.dart';
import 'package:admin_ott/data/models/response/loginUser.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

import 'package:image_picker/image_picker.dart'; // For web-specific file handling


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:admin_ott/data/models/response/getAllUserResponse.dart';
import 'package:admin_ott/data/models/response/updateUserResponse.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/request/user_request.dart';
import '../../data/models/response/addUserResponse.dart';
import '../../data/models/response/errorResponse.dart';
import '../../data/models/response/moviePurchaseByUserResponse.dart';
import '../core/constant/api_constant.dart';
import '../core/constant/prefrense_constant.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';
import '../widgets/show_toast.dart';

class UserProvider extends ChangeNotifier {

  UserProvider() : super(){
    searchController.addListener(filterUsers);
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

  void filterUsers() {
    _filteredUsers = _users.where((user) {
      final query = searchController.text.toLowerCase();
      return user.firstName!.toLowerCase().contains(query) ||
          user.lastName!.toLowerCase().contains(query) ||
          user.mobileNumber!.toLowerCase().contains(query) ||
          (user.emailId!.toLowerCase().contains(query) ??
              false) ||
          (user.location!.state!.toLowerCase().contains(query) ??
              false) ||
          (user.location!.district!.toLowerCase().contains(query) ??
              false) ||
          (user.location!.taluka!.toLowerCase().contains(query) ??
              false);
    }).toList();
    notifyListeners();
  }

  setValue(User? user) async {
    print("SEtData${user!.firstName}");
    firstNameController.text = user.firstName??"";
    lastNameController.text = user.lastName??"";
    mobileController.text = user.mobileNumber??"";
    emailController.text = user.emailId??"";
    dobController.text = user.dob??"";
    profileController.text = user.profilePhoto??"";
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
  User user = User();

  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  User get userObj => user;






  // Update user data
  Future<Map<String, Object>> updateUser() async {
    User? user = await LocalSharePreferences.localSharePreferences.getUser();
    String apiUrl = ApiConstant.editUserById;
    ApiHelper apiHelper = ApiHelper();
    Map<String,dynamic> data ={
      "admin": true,
      "emailId": emailController.text,
      "firstName": firstNameController.text,
      "id": user!.id,
      "lastName": lastNameController.text,
      "mobileNumber": mobileController.text
    };

    try {
      var response = await apiHelper.putApiWithBody(apiUrl,data);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        UpdateUserResponse updateUserResponse = UpdateUserResponse.fromJson(responseBody);

        debugPrint("data: ${updateUserResponse.message}");
        if (updateUserResponse.success == true) {
          if (updateUserResponse.data != null) {
            this.user = updateUserResponse.data!;
            print("before SEtData ${user.firstName}");
            LocalSharePreferences localSharePreferences=LocalSharePreferences();
            localSharePreferences.setString(SharedPreferencesConstant.currentAdmin, jsonEncode(updateUserResponse.data!));
            print("after SEtData ${ await localSharePreferences.getString(SharedPreferencesConstant.currentAdmin)}");
            notifyListeners();
            return {'success': true, 'message':updateUserResponse.message ??""};
          } else {
            debugPrint("Empty data: ${updateUserResponse.message}");
            return {'success': false, 'message': updateUserResponse.message ?? 'No data returned'};
          }
        } else {
          debugPrint("Error: ${updateUserResponse.message}");
          return {'success': false, 'message': updateUserResponse.message ?? 'Error in response'};
        }
      } else if(response.statusCode == 401 || response.statusCode == 404){
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse addUserResponse = AddUserResponse.fromJson(responseBody);
        debugPrint("Error: ${addUserResponse.message}");
        return {'success': false, 'message': addUserResponse.message ?? 'Error in response'};
      }else{
        return {'failure': true, 'message': 'Something went wrong!'};
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {'success': false, 'message': 'An error occurred while update user: $error'};
    }
  }


  // Delete a user
  Future<void> deleteUser(int id) async {
    String apiUrl = ApiConstant.deleteUserById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse deleteUserResponse = AddUserResponse.fromJson(responseBody);
        if (deleteUserResponse.success == true) {
          CustomToast.show("Profile updated successfully!",isSuccess:true);
          notifyListeners();
        } else {
          debugPrint("Error: ${deleteUserResponse.message}");
          CustomToast.show("Error: ${deleteUserResponse.message}",isSuccess:false);
        }
      } else {
        CustomToast.show("Failed to delete user. Status code: ${response.statusCode}",isSuccess:false);
        throw Exception('Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An error occurred while delete user.",isSuccess:false);
      throw Exception('An error occurred while delete user.');
    }
  }

  Future<void> getUserById(int id) async {
    String apiUrl = ApiConstant.getUserById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetUserResponse addUserResponse = GetUserResponse.fromJson(responseBody);
        if (addUserResponse.success == true) {
          if(addUserResponse.data != null && addUserResponse.data!.user != null){
            user = addUserResponse.data!.user!;
            setValue(user);
            notifyListeners();
          }else {
            CustomToast.show("empty data: ${addUserResponse.message}",isSuccess:false);
            debugPrint("empty data: ${addUserResponse.message}");
          }
        } else {
          CustomToast.show("Error: ${addUserResponse.message}",isSuccess:false);
          debugPrint("Error: ${addUserResponse.message}");
        }
      } else {
        CustomToast.show("Failed to delete user. Status code: ${response.statusCode}",isSuccess:false);
        throw Exception('Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An error occurred while get user.",isSuccess:false);
      throw Exception('An error occurred while get user.');
    }
  }

  setImage(XFile pickedFile){
    image = null;
    image = File(pickedFile.path);
    notifyListeners();
  }

  setDate(DateTime pickedDate, bool isDob){
    if(isDob){
    dobController.text = pickedDate.toLocal().toString().split(' ')[0];}
    else{
      joinDateController.text = pickedDate.toLocal().toString().split(' ')[0];}


    notifyListeners();
  }

  login(String email, String password) async {
    String apiUrl = ApiConstant.login;
    Map<String,dynamic> data = {
      "emailId": email,
      "password": password
    };
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.postApiWithBody(apiUrl,data);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        LoginUserResponse addUserResponse = LoginUserResponse.fromJson(responseBody);

        debugPrint("data: ${addUserResponse.message}");
        if (addUserResponse.success == true) {
          if (addUserResponse.data != null) {
            if(addUserResponse.data!.user!.admin==true){
              user = addUserResponse.data!.user!;
              print("before SEtData ${user.firstName}");
              LocalSharePreferences localSharePreferences=LocalSharePreferences();
              localSharePreferences.setBool(SharedPreferencesConstant.isAdminLoggedIn, true);
              print("check  SEtLogin ${await localSharePreferences.getBool(SharedPreferencesConstant.isAdminLoggedIn)}");
              localSharePreferences.setString(SharedPreferencesConstant.currentAdmin, jsonEncode(addUserResponse.data!.user));
              print("after SEtData ${ await localSharePreferences.getString(SharedPreferencesConstant.currentAdmin)}");
              notifyListeners();
              return {'success': true, 'message': 'User logged in successfully'};
            }else{
              CustomToast.show("You are not admin..try with admin credentials...");
              notifyListeners();
              return {'success': false, 'message': "You are not admin..try with admin credentials..."};
            }

          } else {
            debugPrint("Empty data: ${addUserResponse.message}");
            return {'success': false, 'message': addUserResponse.message ?? 'No data returned'};
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
          return {'success': false, 'message': addUserResponse.message ?? 'Error in response'};
        }
      } else if(response.statusCode == 401 || response.statusCode == 404){
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse addUserResponse = AddUserResponse.fromJson(responseBody);
        debugPrint("Error: ${addUserResponse.message}");
        return {'success': false, 'message': addUserResponse.message ?? 'Error in response'};
      }else{
        return {'failure': true, 'message': 'Something went wrong!'};
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {'success': false, 'message': 'An error occurred while logging user: $error'};
    }
  }

  // Fetch all users
  Future<void> fetchUsers() async {
    String apiUrl = ApiConstant.getAllUser;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllUserResponse getAllUserResponse = GetAllUserResponse.fromJson(responseBody);
        if (getAllUserResponse.success == true) {
          if(getAllUserResponse.data != null){
            _users = getAllUserResponse.data!.users!;
            _filteredUsers=_users;
            notifyListeners();
          }else {
            debugPrint("empty list: ${getAllUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllUserResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching users.');
    }
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
      var response = await apiHelper.postApiWithBody(apiUrl,userRequest.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetUserResponse addUserResponse = GetUserResponse.fromJson(responseBody);

        if (addUserResponse.success == true) {
          if (addUserResponse.data != null) {
            user = addUserResponse.data!.user!;
            users.add(user);
            notifyListeners();
            return {'success': true, 'message': 'User created successfully'};
          } else {
            debugPrint("Empty data: ${addUserResponse.message}");
            return {'success': false, 'message': addUserResponse.message ?? 'No data returned'};
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
          return {'success': false, 'message': addUserResponse.message ?? 'Error in response'};
        }
      } else if (response.statusCode == 500) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        ErrorResposne addUserResponse = ErrorResposne.fromJson(responseBody);
        return {'success': false, 'message': addUserResponse.message};
        }else
          {
            return {'success': false, 'message': 'Something went wrong!'};
          }
        // throw Exception('Failed to add user. Status code: ${response.statusCode}');

    } catch (error) {
      debugPrint("Error: $error");
      return {'success': false, 'message': 'An error occurred while adding user: $error'};
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
  Future<void> pickImage() async {
    if (kIsWeb) {
      // Web file picker
      final html.FileUploadInputElement uploadInput =
      html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          _webFile = uploadInput.files!.first;
          await uploadImage();
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
          await uploadImage();}
        notifyListeners();
      }
    }
  }

  // Upload Image
  Future<void> uploadImage( ) async {
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
          profileController.text = _uploadedImageUrl!;

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
            profileController.text = _uploadedImageUrl!;
          }
          notifyListeners();
        }
      } }catch (e) {
      CustomToast.show('Error uploading image: $e',isSuccess: false);

    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


  List<UserContent> _userContentList =[];
  List<UserContent> get userContentList => _userContentList;

  List<UserContent> _filtteredUserContentList =[];
  List<UserContent> get filtteredUserContentList => _filtteredUserContentList;

  Future<void> fetchUserContent(int userId) async {
    String apiUrl = ApiConstant.getPurchaseMovieByUser(userId);
    print(apiUrl);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: "+response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint("response::: "+responseBody.toString());
        MoviePurchaseByUserResponse moviePurchaseByUserResponse = MoviePurchaseByUserResponse.fromJson(responseBody);
        debugPrint("data::: "+moviePurchaseByUserResponse.data.toString());
        if (moviePurchaseByUserResponse.success == true) {
          if(moviePurchaseByUserResponse.data != null){
            _userContentList.clear();
            _filtteredUserContentList.clear();
            _userContentList = moviePurchaseByUserResponse.data!.userContent!;
            _filtteredUserContentList = _userContentList;
            debugPrint("message : ${moviePurchaseByUserResponse.message}");
            notifyListeners();
          }else {
            _userContentList.clear();
            _filtteredUserContentList.clear();
            CustomToast.show("empty list: ${moviePurchaseByUserResponse.message}",isSuccess: true);

            debugPrint("empty list: ${moviePurchaseByUserResponse.message}");
            notifyListeners();
          }
        } else {
          _userContentList.clear();
          _filtteredUserContentList.clear();
          debugPrint("Error: ${moviePurchaseByUserResponse.message}");
          CustomToast.show("Error: ${moviePurchaseByUserResponse.message}",isSuccess:false);
          notifyListeners();
        }
      } else {
        CustomToast.show("Failed to fetch Content. Status code: ${response.statusCode}",isSuccess:false);
        throw Exception('Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An error occurred while fetching user content.",isSuccess:false);
      throw Exception('An error occurred while fetching Content.');
    }
  }


}


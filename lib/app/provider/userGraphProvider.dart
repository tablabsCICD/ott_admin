/*
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/provider/baseProvider.dart';
import 'package:admin_ott/app/widgets/get_date_time.dart';
import 'package:admin_ott/data/models/api_response.dart';
import 'package:admin_ott/data/models/request/user_request.dart';
import 'package:admin_ott/data/models/response/addUserResponse.dart';
import 'package:admin_ott/data/models/response/getAllUserResponse.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider extends BaseProvider {

  UserProvider(BuildContext context) : super('Ideal'){
   fetchUsers();
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
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController officeBuildingController = TextEditingController();
  TextEditingController registrationDateController = TextEditingController();
  TextEditingController profileController = TextEditingController();
  TextEditingController pinCodeDateController = TextEditingController();
  TextEditingController refferedByController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool isEnbale = false;

  checkValidation() {
    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        genderController.text.isNotEmpty &&
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

  // Create a new user
  Future<void> createUser() async {
    String apiUrl = ApiConstant.registration;
    UserRequest userRequest = UserRequest();
    userRequest.active = true;
    userRequest.admin = false;
    userRequest.age = '';
    userRequest.area = '';
    userRequest.city = cityController.text;
    userRequest.country = countryController.text;
    userRequest.deviceId = '';
    userRequest.deviceName = '';
    userRequest.deviceToken = '';
    userRequest.district = districtController.text;
    userRequest.dob = dobController.text;
    userRequest.emailId = emailController.text;
    userRequest.firstName = firstNameController.text;
    userRequest.gender = genderController.text;
    userRequest.joinDate = GetDateFormat.getCurrentDate();
    userRequest.mobileNumber = mobileController.text;
    userRequest.lastName = lastNameController.text;
    userRequest.locationId = 0;
    userRequest.officeBuilding = officeBuildingController.text;
    userRequest.osName = "Web";
    userRequest.password = passwordController.text;
    userRequest.pincode = pinCodeDateController.text;
    userRequest.profilePhoto = profileController.text;
    userRequest.refferedBy = [refferedByController.text];
    userRequest.registrationDate = GetDateFormat.getCurrentDate();
    userRequest.role = [roleController.text];
    userRequest.state = stateController.text;
    userRequest.verified = true;

    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse addUserResponse = AddUserResponse.fromJson(
            responseBody);
        if (addUserResponse.success == true) {
          if (addUserResponse.data != null) {
            _users.add(addUserResponse.data!.user!);
            _filteredUsers = _users;
            notifyListeners();
          } else {
            debugPrint("empty data: ${addUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to add user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while adding user.');
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
            _users = getAllUserResponse.data!.user!;
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




  // Update user data
  Future<void> updateUser(User user) async {
    String apiUrl = ApiConstant.editUserById;
    ApiHelper apiHelper = ApiHelper();
    UserRequest userRequest=UserRequest();
    userRequest.active=true;
    userRequest.admin=false;
    userRequest.age='';
    userRequest.area='';
    userRequest.city=cityController.text;
    userRequest.country=countryController.text;
    userRequest.deviceId='';
    userRequest.deviceName='';
    userRequest.deviceToken='';
    userRequest.district=districtController.text;
    userRequest.dob=dobController.text;
    userRequest.emailId=emailController.text;
    userRequest.firstName=firstNameController.text;
    userRequest.gender=genderController.text;
    userRequest.joinDate=GetDateFormat.getCurrentDate();
    userRequest.mobileNumber=mobileController.text;
    userRequest.lastName=lastNameController.text;
    userRequest.locationId=0;
    userRequest.officeBuilding=officeBuildingController.text;
    userRequest.osName="Web";
    userRequest.password=passwordController.text;
    userRequest.pincode=pinCodeDateController.text;
    userRequest.profilePhoto=profileController.text;
    userRequest.refferedBy=[refferedByController.text];
    userRequest.registrationDate=GetDateFormat.getCurrentDate();
    userRequest.role=[roleController.text];
    userRequest.state=stateController.text;
    userRequest.verified=true;

    try {
      var response = await apiHelper.putApiWithBody(apiUrl,userRequest.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse addUserResponse = AddUserResponse.fromJson(
            responseBody);
        if (addUserResponse.success == true) {
          if (addUserResponse.data != null) {
            final index = _users.indexWhere((u) => u.id == user.id);
            if (index != -1) {
              _users[index] = user;
              notifyListeners();
            }
            notifyListeners();
          } else {
            debugPrint("empty data: ${addUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to update user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while updating user.');
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
          _users.removeWhere((user) => user.id == id);
          notifyListeners();
        } else {
          debugPrint("Error: ${deleteUserResponse.message}");
        }
      } else {
        throw Exception('Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
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
        AddUserResponse addUserResponse = AddUserResponse.fromJson(responseBody);
        if (addUserResponse.success == true) {
          if(addUserResponse.data != null && addUserResponse.data!.user != null){
            user = addUserResponse.data!.user!;
            notifyListeners();
          }else {
            debugPrint("empty data: ${addUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
        }
      } else {
        throw Exception('Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while delete user.');
    }
  }

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
}
*/
import 'dart:convert';
import 'dart:io' as io;
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/users_onboarded_graph.dart';
import 'package:admin_ott/data/models/response/chartResponse.dart';
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
import '../core/constant/api_constant.dart';
import '../core/constant/prefrense_constant.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';
import '../widgets/show_toast.dart';


class UserGraphProvider extends ChangeNotifier {



  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateNameController = TextEditingController();
  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;

  List<LineChartData> chartData = [];


  falseAllFilter(){
    isYear = false;isMonth = false;isWeek = false;
  }

  Future<void> fetchUserGraph(int selectedTimeRange) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=true;
    }
    String apiUrl = ApiConstant.userCountGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
       var response = await apiHelper.getApi(apiUrl);


       Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
    if(chartResponse.success==true){
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
    }else{
      CustomToast.show(chartResponse.message.toString());
    }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }


  Future<void> fetchPurchaseGraph(int selectedTimeRange) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=true;
    }
    String apiUrl = ApiConstant.purchaseCountGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);


      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if(chartResponse.success==true){
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
      }else{
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }


  Future<void> fetchPromoterCountGraph(int selectedTimeRange) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=true;
    }
    String apiUrl = ApiConstant.promoterCountGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);


      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if(chartResponse.success==true){
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
      }else{
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  Future<void> fetchMediaHouseCountGraph(int selectedTimeRange) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=true;
    }
    String apiUrl = ApiConstant.mediaHouseCountGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);


      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if(chartResponse.success==true){
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
      }else{
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

  Future<void> fetchApprovedContentGraph(int selectedTimeRange) async {
    if(selectedTimeRange==0){
      isWeek=true;
      isMonth=false;
      isYear=false;
    }else  if(selectedTimeRange==1){
      isWeek=false;
      isMonth=true;
      isYear=false;
    }else{
      isWeek=false;
      isMonth=false;
      isYear=true;
    }
    String apiUrl = ApiConstant.approvedContentCountGraph(
      startDateController.text,
      endDateNameController.text,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);


      Map<String, dynamic> responseBody = json.decode(response.body);

      ChartResponse chartResponse = ChartResponse.fromJson(responseBody);
      if(chartResponse.success==true){
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
      }else{
        CustomToast.show(chartResponse.message.toString());
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }
}


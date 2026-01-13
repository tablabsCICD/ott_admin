import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoterList.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/request/save_promoter_request.dart';
import 'package:admin_ott/data/models/response/addPromoterResponse.dart';
import 'package:admin_ott/data/models/response/getAllPromoterResponse.dart';
import 'package:admin_ott/data/models/response/getPromotersByreferalCode.dart';
import 'package:admin_ott/data/models/response/getUsersByReferalCode.dart';
import 'package:admin_ott/data/models/response/promoters_by_status.dart';
import 'package:admin_ott/data/models/response/reportingPromoterResponse.dart';
import 'package:admin_ott/data/models/response/userOnboardAndRevenueGraph.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';


import '../../data/models/response/getAllUserResponse.dart';
import '../core/network/api_helper.dart';

class PromoterProvider extends ChangeNotifier {

  PromoterProvider() : super(){
    fetchPromoters();
    searchController.addListener(onSearchChanged);
    }

  void onSearchChanged() {
      _filteredPromoters = _promoters
          .where((promoter) => promoter.promoterName
          .toString()
          .toLowerCase()
          .contains(searchController.text.toLowerCase()))
          .toList();
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

  List<Promoters> _promoters = [];
  List<Promoters> _filteredPromoters = [];
  List<Promoters> _filteredPromotersByStatus = [];
  Promoters promoter = Promoters();
  Promoters _selectedPromoter = Promoters();

  List<Promoters> get promoterList => _promoters;
  List<Promoters> get filteredPromoters => _filteredPromoters;
  List<Promoters> get filteredPromotersByStatus => _filteredPromotersByStatus;
  Promoters? get promoterObj => promoter;
  Promoters? get selectedPromoter => _selectedPromoter;

  setSelectedPromoter(Promoters promoter){
    _selectedPromoter = promoter;
    searchController.clear();
    notifyListeners();
  }

  // Create a new user
  Future<void> createPromoters(SavePromoterRequest promoter) async {
    String apiUrl = ApiConstant.savePromoter;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.postApiWithBody(apiUrl,promoter.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddPromoterResponse addUserResponse = AddPromoterResponse.fromJson(
            responseBody);
        if (addUserResponse.success == true) {
          if (addUserResponse.data != null) {
            _promoters.add(addUserResponse.data!.promoters!);
            _filteredPromoters = _promoters;
            CustomToast.show(addUserResponse.message!);
            await fetchPromoters();
            notifyListeners();

          } else {
            debugPrint("empty data: ${addUserResponse.message}");
            CustomToast.show(addUserResponse.message!);
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
          CustomToast.show(addUserResponse.message!);
        }
      } else if(response.statusCode == 400){
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddPromoterResponse addUserResponse = AddPromoterResponse.fromJson(
            responseBody);
        CustomToast.show(addUserResponse.message!);
      }else{
        throw Exception(
            'Failed to add promoter. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while adding promoter.');
    }
  }

  String stateCount = '0', countryCount = '0', districtCount = '0', talukaCount = '0';

  Future<void> fetchPromoters() async {
    String apiUrl = ApiConstant.getAllPromoter;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllPromoterResponse getAllPromotersResponse = GetAllPromoterResponse.fromJson(responseBody);

        if (getAllPromotersResponse.success == true) {
          if (getAllPromotersResponse.data != null) {
            print(getAllPromotersResponse.data);
            _promoters.clear();
            _filteredPromoters.clear();
            _promoters = getAllPromotersResponse.data!.promoters!;
            print(_promoters);
            _filteredPromoters.addAll(_promoters);

            // Count promoters by level
            int state = 0, country = 0, taluka = 0,district=0;

            for (var promoter in _promoters) {
              switch (promoter.level) {
                case 'State':
                  state++;
                  break;
                case 'National':
                  country++;
                  break;
                case 'Taluka':
                  taluka++;
                  break;
                case 'District':
                  district++;
                  break;
                default:
                  break;
              }
            }

            // Convert counts to string
            stateCount = state.toString();
            countryCount = country.toString();
            talukaCount = taluka.toString();
            districtCount = district.toString();
            print("FilterdPromoter List"+_filteredPromoters.length.toString());
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllPromotersResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllPromotersResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch promoters. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching promoters.');
    }
  }


  Future<void> fetchPromotersByStatus(String status) async {
    String apiUrl = ApiConstant.getPromoterByStatus(status);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        PromotersByStatus getAllPromotersResponse = PromotersByStatus.fromJson(responseBody);
        if (getAllPromotersResponse.success == true) {
          if(getAllPromotersResponse.data!.cast != null){
            if(status=="PENDING"){
              filteredPromotersByStatus.clear();
            _filteredPromotersByStatus = getAllPromotersResponse.data!.cast!;
              _filteredPromoters.clear();
              _filteredPromoters = getAllPromotersResponse.data!.cast!;
            notifyListeners();}else{
              _filteredPromoters.clear();
              _filteredPromoters = getAllPromotersResponse.data!.cast!;
              notifyListeners();
            }
          }else {
            debugPrint("empty list: ${getAllPromotersResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllPromotersResponse.message}");
        }
      } else {
        throw Exception('Failed to fetch promoters. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching promoters.');
    }
  }

  String selectedLevel = 'All';

 List<Promoters> filterPromotersByLevel(String level) {
    if (level == 'All') {
      _filteredPromoters = List.from(promoterList);
      notifyListeners();
      return _filteredPromoters;
    }
    _filteredPromoters = promoterList.where((promoter) => promoter.level == level).toList();
    selectedLevel = level;
    notifyListeners();
    return _filteredPromoters;
  }

  void onSearchValueChange(String value) {
    final query = value.toLowerCase();
    _filteredPromoters = filterPromotersByLevel(selectedLevel).where((promoter) {
      return promoter.promoterName!.toLowerCase().contains(query);    }).toList();
    notifyListeners();
  }

  // Delete a user
  Future<void> deletePromoters(int id,context) async {
    String apiUrl = ApiConstant.deletePromoterById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          _filteredPromoters.removeWhere((user) => user.id == id);
          notifyListeners();
        } else {
          debugPrint("Error: ${responseBody['message']}");
        }
      } else {
        throw Exception('Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while delete user.');
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
        GetAllUserResponse getAllUserResponse = GetAllUserResponse.fromJson(responseBody);
        if (getAllUserResponse.success == true) {
          if(getAllUserResponse.data != null){
            users = getAllUserResponse.data!.users!;
            print("User list:::::::"+users.length.toString());
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

  Future<void> changePromoterStatus(String status, int id, BuildContext context) async {
    String apiUrl = ApiConstant.changePromoterStatus(status, id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.putApi(apiUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        CustomToast.show("Promoter status updated successfully");
        fetchPromotersByStatus("PENDING");
        notifyListeners();
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to $status. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while changing status.');
    }
  }


  List<User> _usersByPromoterCode = [];
  List<User> get usersByPromoterCode => _usersByPromoterCode;
  String? refer,revenue,incentive;

  Future<void> getUsersByUserReferalCode(String code)async {
      String myUrl = ApiConstant.getUsersByPromoterCode(code);
      ApiHelper apiHelper = ApiHelper();
      try {
        var response = await apiHelper.getApi(myUrl);
        debugPrint("response::: " + response.body);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = json.decode(response.body);
          UsersByReferalCode usersByReferalCode = UsersByReferalCode.fromJson(responseBody);
          if(usersByReferalCode.success==true){
            if(usersByReferalCode.data!.users != null){
              _usersByPromoterCode.clear();
              _usersByPromoterCode = usersByReferalCode.data!.users!;
              refer= usersByReferalCode.data!.userCount!.toString();
              incentive= usersByReferalCode.data!.totalRevenueOfPromoter!.toString();
              revenue= usersByReferalCode.data!.totalViewRevenueEarned!.toString();
            }
          }else{
            CustomToast.show("Something went wrong!!!${usersByReferalCode.message}");
          }
          notifyListeners();
        } else {
          throw Exception(
              'Failed to fetch users by referral code. Status code: ${response.statusCode}');
        }
      } catch (error) {
        debugPrint("Error: $error");
        throw Exception('An error occurred while fetching users status.');
      }
  }


  List<Promoters> _promotersByPromoterCode = [];
  List<Promoters> get promotersByPromoterCode => _promotersByPromoterCode;

  Future<void> getPromotersByUserReferalCode(String code)async {
    String myUrl = ApiConstant.getPromotersByPromoterCode(code);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(myUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        PrometrsByReferalCode promotersByReferalCode = PrometrsByReferalCode.fromJson(responseBody);
        if(promotersByReferalCode.success==true){
          if(promotersByReferalCode.data!.promoter != null){
            _promotersByPromoterCode.clear();
            _promotersByPromoterCode = promotersByReferalCode.data!.promoter!;
          }
        }else{
          CustomToast.show("Something went wrong!!!${promotersByReferalCode.message}");
        }
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch promoters by referral code. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching promoters.');
    }
  }


  List<PromoterUserRevenueGraph> _promoterUserRevenueGraph = [];
  List<PromoterUserRevenueGraph> get promoterUserRevenueGraph => _promoterUserRevenueGraph;
  Future<void> getUsersAndRevenue(int id)async {
    String myUrl = ApiConstant.getUserAndRevenueGraph('2025-04-01','2025-04-10',id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(myUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        UserOnboardAndRevenueGraph usersByReferalCode = UserOnboardAndRevenueGraph.fromJson(responseBody);
        if(usersByReferalCode.isSuccess==true){
          if(usersByReferalCode.data != null){
            _promoterUserRevenueGraph.clear();
            _promoterUserRevenueGraph = usersByReferalCode.data!;
          }
        }else{
          CustomToast.show("Something went wrong!!!${usersByReferalCode.message}");
        }
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch users by referral code. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching users status.');
    }
  }


  List<PromotersList> _reportingPromoters = [];
  List<PromotersList> get reportingPromoters => _reportingPromoters;
  Future<void> getReportingPromoters(String level,String location)async {
    String PromoterLevel= level;
    if(level=="State"){
      PromoterLevel= "National";
    }else if(level=="District"){
      PromoterLevel = "State";
    }else if(level == "Taluka"){
      PromoterLevel = "District";
    }else{
      PromoterLevel = level;
    }
    String myUrl = ApiConstant.reportingPromoterApi(PromoterLevel,location);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(myUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        ReportingPromotersResponse reportingPromotersResponse = ReportingPromotersResponse.fromJson(responseBody);
        if(reportingPromotersResponse.success==true){
          if(reportingPromotersResponse.data!.promotersList != null){
            _reportingPromoters.clear();
            _reportingPromoters = reportingPromotersResponse.data!.promotersList!;

          }
        }else{
          CustomToast.show("Something went wrong!!!${reportingPromotersResponse.message}");
        }
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch users by referral code. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching users status.');
    }
  }
}

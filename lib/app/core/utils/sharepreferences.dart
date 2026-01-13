import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/mediaHouse.dart';
import '../../../domain/entities/user.dart';
import '../constant/prefrense_constant.dart';

class LocalSharePreferences{
  static final LocalSharePreferences localSharePreferences = LocalSharePreferences._internal();
  factory LocalSharePreferences() {
    return localSharePreferences;
  }
  LocalSharePreferences._internal();
  setString(String key,String val)async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(key,val);
  }
  setBool(String key,bool val)async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(key,val);
  }
  Future<String> getString(String key)async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(key)!;
  }

  Future<bool> getBool(String key)async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool val =false;
    if(_prefs.getBool(key)!=null){
      val=_prefs.getBool(key)!;
    }
    return val;
  }


  Future<User> getLoginData() async{
    String data  = await getString(SharedPreferencesConstant.currentAdmin);
    User user=User.fromJson(jsonDecode(data));
    return user;
  }



  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(SharedPreferencesConstant.currentAdmin);
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return
        User.fromJson(userMap);
    }
    return null;
  }

  Future<MediaHouse?> getMediaHouse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(SharedPreferencesConstant.currentMediaHouseId);
    if (data != null) {
      Map<String, dynamic> jsonMap = jsonDecode(data);
      return
        MediaHouse.fromJson(jsonMap);
    }
    return null;
  }

  Future<bool> logOut()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(SharedPreferencesConstant.isAdminLoggedIn, false);
    await _prefs.remove(SharedPreferencesConstant.currentAdmin);
    await _prefs.clear();
    return true;
  }


}
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/mediaHouse.dart';
import '../../../domain/entities/user.dart';
import '../constant/prefrense_constant.dart';

class LocalSharePreferences {
  static final LocalSharePreferences localSharePreferences =
      LocalSharePreferences._internal();

  factory LocalSharePreferences() {
    return localSharePreferences;
  }

  LocalSharePreferences._internal();

  Future<void> setString(String key, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, val);
  }

  Future<void> setBool(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key)!;
  }

  Future<bool> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool val = false;
    if (prefs.getBool(key) != null) {
      val = prefs.getBool(key)!;
    }
    return val;
  }

  Future<User> getLoginData() async {
    String data = await getString(SharedPreferencesConstant.currentAdmin);
    User user = User.fromJson(jsonDecode(data));
    return user;
  }

  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(SharedPreferencesConstant.currentAdmin);
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<MediaHouse?> getMediaHouse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data =
        prefs.getString(SharedPreferencesConstant.currentMediaHouseId);
    if (data != null) {
      Map<String, dynamic> jsonMap = jsonDecode(data);
      return MediaHouse.fromJson(jsonMap);
    }
    return null;
  }

  Future<bool> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPreferencesConstant.isAdminLoggedIn, false);
    await prefs.remove(SharedPreferencesConstant.currentAdmin);
    await prefs.remove(SharedPreferencesConstant.authToken);
    await prefs.remove(SharedPreferencesConstant.authTokenType);
    await prefs.remove(SharedPreferencesConstant.sessionId);
    await prefs.clear();
    return true;
  }
}

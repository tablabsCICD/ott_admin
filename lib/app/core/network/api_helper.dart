import 'dart:convert';

import 'package:admin_ott/data/models/api_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/prefrense_constant.dart';
import '../loading/app_loading_controller.dart';

class ApiHelper {
  Future<Map<String, String>> _headers({bool includeAuth = true}) async {
    final headers = {
      "accept": "*/*",
      "Content-Type": "application/json",
    };

    if (includeAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPreferencesConstant.authToken);
      final tokenType =
          prefs.getString(SharedPreferencesConstant.authTokenType) ?? "Bearer";

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "$tokenType $token";
      }
    }

    return headers;
  }

  Future<Map<String, String>> multipartHeaders({
    bool includeAuth = true,
  }) async {
    final headers = await _headers(includeAuth: includeAuth);
    headers.remove("Content-Type");
    return headers;
  }

  Future<dynamic> getApi(String URL) async {
    debugPrint("API GET: $URL");
    final url = Uri.parse(URL);
    final headers = await _headers();
    var request = await AppLoadingController.trackFuture(
      () => http.get(url, headers: headers).timeout(const Duration(seconds: 10)),
    );
    debugPrint("API RESPONSE: ${request.body}");
    return request;
  }

  Future<dynamic> deleteApi(String URL) async {
    debugPrint("API DELETE: $URL");
    final headers = await _headers();
    var request = await AppLoadingController.trackFuture(
      () => http.delete(Uri.parse(URL), headers: headers),
    );
    debugPrint("API RESPONSE: ${request.body}");
    return request;
  }

  Future<dynamic> postApi(String URL) async {
    debugPrint("API POST: $URL");
    final headers = await _headers();
    var request = await AppLoadingController.trackFuture(
      () => http.post(Uri.parse(URL), headers: headers),
    );
    debugPrint("API RESPONSE: ${request.body}");
    return request;
  }

  Future<dynamic> postApiWithBody(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    debugPrint("API POST: $url");
    var body = json.encode(data);
    debugPrint("API BODY: $body");
    final headers = await _headers(includeAuth: includeAuth);
    final response = await AppLoadingController.trackFuture(
      () => http.post(Uri.parse(url), headers: headers, body: body),
    );
    debugPrint("API RESPONSE: ${response.body}");
    return response;
  }

  Future<dynamic> putApi(String URL) async {
    debugPrint("API PUT: $URL");
    final headers = await _headers();
    var request = await AppLoadingController.trackFuture(
      () => http.put(Uri.parse(URL), headers: headers),
    );
    debugPrint("API RESPONSE: ${request.body}");
    return request;
  }

  Future<dynamic> putApiWithBody(String url, Map<String, dynamic> data) async {
    debugPrint("API PUT: $url");
    var body = json.encode(data);
    debugPrint("API BODY: $body");
    final headers = await _headers();
    final response = await AppLoadingController.trackFuture(
      () => http.put(Uri.parse(url), headers: headers, body: body),
    );
    debugPrint("API RESPONSE: ${response.body}");
    return response;
  }

  Future<dynamic> postApiWithoutAuthToken(String URL) async {
    debugPrint("API POST: $URL");
    var request = await AppLoadingController.trackFuture(
      () => http.post(Uri.parse(URL)),
    );
    debugPrint("API RESPONSE: ${request.body}");
    return request;
  }

  Future<dynamic> postApiWithoutBodyAndToken(
      String url, Map<String, dynamic> data) async {
    debugPrint("API POST: $url");
    var body = json.encode(data);
    debugPrint("API BODY: $body");
    final response = await AppLoadingController.trackFuture(
      () => http.post(
        Uri.parse(url),
        headers: {"accept": "*/*", "Content-Type": "application/json"},
        body: body,
      ),
    );
    debugPrint("API RESPONSE: ${response.body}");
    return response;
  }

  ApiResponse returnResponse<T>(Response request) {
    if (request.statusCode == 200 ||
        request.statusCode == 400 ||
        request.statusCode == 201) {
      var response1 = request.body;
      print("**************************************$response1");
      var response = jsonDecode(request.body);
      ApiResponse apiResponseHelper = ApiResponse(request.statusCode, response);
      return apiResponseHelper;
    } else {
      ApiResponse apiResponseHelper = ApiResponse(request.statusCode, null);
      return apiResponseHelper;
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/response/allAccessResponse.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';

class AccessFields {
  static const manageContent      = 'manageContent';
  static const manageMediaHouse   = 'manageMediaHouse';
  static const manageUser         = 'manageUser';
  static const manageTransaction  = 'manageTrasaction'; // ← API’s misspelling
  static const helpDesk           = 'helpDesk';
  static const promoterLevel      = 'promoterLevel';
  static const id                 = 'id';
}

class AccesscontroleProvider extends ChangeNotifier {
  final ApiHelper _api = ApiHelper();

  final List<AccessControl> _allEntries                 = [];
  final Map<String, AccessControl> _latestByLevel       = {};
  final Map<String, List<AccessControl>> _historyByLevel = {};

  List<AccessControl>              get allEntries   => _allEntries;
  Map<String, AccessControl>       get latestByLevel => _latestByLevel;
  Map<String, List<AccessControl>> get historyByLevel => _historyByLevel;

  Future<void> getAllPromoterAccess() async {
    try {
      final resp = await _api.getApi(ApiConstant.getPromoterAccess);
      if (resp.statusCode != 200) {
        throw Exception('GET failed (${resp.statusCode})');
      }

      final Map<String, dynamic> responseBody = json.decode(resp.body);
      final AllAccessResponse parsed =
      AllAccessResponse.fromJson(responseBody);


      // Master list
      _allEntries
        ..clear()
        ..addAll(parsed.data!.accessControl!);


      print(_allEntries.length);
      print("-----------------------------------");

      // Latest by promoter level
      _latestByLevel
        ..clear()
        ..addAll({for (final e in parsed.data!.accessControl!) e.promoterLevel!: e});

      print(_latestByLevel.length);
      print("-----------------------------------");
      // History grouped by level
      _historyByLevel.clear();
      for (final e in parsed.data!.accessControl!) {
        final lvl = e.promoterLevel ?? 'Unknown';
        _historyByLevel.putIfAbsent(lvl, () => []).add(e);
      }

      notifyListeners();
    } catch (err, st) {
      debugPrint('getAllPromoterAccess error → $err\n$st');
      rethrow;
    }
  }

  Future<void> setPromoterAccess(
      String level,
      bool isHelpDesk,
      bool isContent,
      bool isMediaHouse,
      bool isTransaction,
      bool isUser,
      ) async {
    final payload = _buildPayload(
      id: 0,
      level: level,
      isHelpDesk: isHelpDesk,
      isContent: isContent,
      isMediaHouse: isMediaHouse,
      isTransaction: isTransaction,
      isUser: isUser,
    );

    await _saveOrEdit(
      url: ApiConstant.savePromoterAccess,
      payload: payload,
      isNew: true,
    );
  }

  Future<void> editPromoterAccess(
      String level,
      bool isHelpDesk,
      bool isContent,
      bool isMediaHouse,
      bool isTransaction,
      bool isUser,
      int id,
      ) async {
    final payload = _buildPayload(
      id: id,
      level: level,
      isHelpDesk: isHelpDesk,
      isContent: isContent,
      isMediaHouse: isMediaHouse,
      isTransaction: isTransaction,
      isUser: isUser,
    );

    await _saveOrEdit(
      url: ApiConstant.editPromoterAccess,
      payload: payload,
      isNew: false,
    );
  }

  Map<String, dynamic> _buildPayload({
    required int    id,
    required String level,
    required bool   isHelpDesk,
    required bool   isContent,
    required bool   isMediaHouse,
    required bool   isTransaction,
    required bool   isUser,
  }) {
    return {
      AccessFields.id                : id,
      AccessFields.promoterLevel     : level,
      AccessFields.helpDesk          : isHelpDesk,
      AccessFields.manageContent     : isContent,
      AccessFields.manageMediaHouse  : isMediaHouse,
      AccessFields.manageTransaction : isTransaction,
      AccessFields.manageUser        : isUser,
    };
  }

  Future<void> _saveOrEdit({
    required String url,
    required Map<String, dynamic> payload,
    required bool isNew,
  }) async {
    try {
      final resp = isNew
          ? await _api.postApiWithBody(url, payload)
          : await _api.putApiWithBody(url, payload);

      if (resp.statusCode != 200) {
        throw Exception(
            '${isNew ? "POST" : "PUT"} failed (${resp.statusCode})');
      }

      final body = json.decode(resp.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Unknown save error');
      }

      await getAllPromoterAccess(); // refresh caches → UI updates automatically
    } catch (err, st) {
      debugPrint('_saveOrEdit error → $err\n$st');
      rethrow;
    }
  }
}

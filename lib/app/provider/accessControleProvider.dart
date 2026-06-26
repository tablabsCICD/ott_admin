import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/response/allAccessResponse.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';

class AccessFields {
  static const manageContent = 'manageContent';
  static const manageMediaHouse = 'manageMediaHouse';
  static const manageUser = 'manageUser';
  static const manageTransaction = 'manageTrasaction'; // ← API’s misspelling
  static const helpDesk = 'helpDesk';
  static const promoterLevel = 'promoterLevel';
  static const id = 'id';
}

class AccesscontroleProvider extends ChangeNotifier {
  final ApiHelper _api = ApiHelper();

  final List<AccessControl> _allEntries = [];
  final Map<String, AccessControl> _latestByLevel = {};
  final Map<String, List<AccessControl>> _historyByLevel = {};
  bool _isSaving = false;

  List<AccessControl> get allEntries => _allEntries;
  Map<String, AccessControl> get latestByLevel => _latestByLevel;
  Map<String, List<AccessControl>> get historyByLevel => _historyByLevel;
  bool get isSaving => _isSaving;

  Future<void> getAllPromoterAccess() async {
    try {
      final resp = await _api.getApi(ApiConstant.getPromoterAccess);
      if (!_isSuccessStatus(resp.statusCode)) {
        throw Exception('GET failed (${resp.statusCode})');
      }

      final Map<String, dynamic> responseBody = json.decode(resp.body);
      final AllAccessResponse parsed = AllAccessResponse.fromJson(responseBody);
      final accessControls = parsed.data?.accessControl ?? <AccessControl>[];

      // Master list
      _allEntries
        ..clear()
        ..addAll(accessControls);

      // Latest by promoter level
      _latestByLevel
        ..clear()
        ..addAll({
          for (final e in accessControls)
            if (e.promoterLevel != null) e.promoterLevel!: e,
        });

      // History grouped by level
      _historyByLevel.clear();
      for (final e in accessControls) {
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
    required int id,
    required String level,
    required bool isHelpDesk,
    required bool isContent,
    required bool isMediaHouse,
    required bool isTransaction,
    required bool isUser,
  }) {
    return {
      AccessFields.id: id,
      AccessFields.promoterLevel: level,
      AccessFields.helpDesk: isHelpDesk,
      AccessFields.manageContent: isContent,
      AccessFields.manageMediaHouse: isMediaHouse,
      AccessFields.manageTransaction: isTransaction,
      AccessFields.manageUser: isUser,
    };
  }

  Future<void> _saveOrEdit({
    required String url,
    required Map<String, dynamic> payload,
    required bool isNew,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final resp = isNew
          ? await _api.postApiWithBody(url, payload)
          : await _api.putApiWithBody(url, payload);

      if (!_isSuccessStatus(resp.statusCode)) {
        throw Exception(
            '${isNew ? "POST" : "PUT"} failed (${resp.statusCode})');
      }

      final body = resp.body.toString().trim().isEmpty
          ? <String, dynamic>{'success': true}
          : json.decode(resp.body) as Map<String, dynamic>;
      if (body['success'] == false) {
        throw Exception(body['message'] ?? 'Unknown save error');
      }

      _upsertLocalAccess(payload);
      notifyListeners();
      await getAllPromoterAccess();
    } catch (err, st) {
      debugPrint('_saveOrEdit error -> $err\n$st');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  bool _isSuccessStatus(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  void _upsertLocalAccess(Map<String, dynamic> payload) {
    final access = AccessControl.fromJson(payload);
    final level = access.promoterLevel;
    if (level == null || level.isEmpty) {
      return;
    }

    final index = _allEntries.indexWhere((entry) =>
        entry.id == access.id ||
        (entry.id == null && entry.promoterLevel == access.promoterLevel));

    if (index == -1) {
      _allEntries.add(access);
    } else {
      _allEntries[index] = access;
    }

    _latestByLevel[level] = access;
    _historyByLevel[level] = [
      access,
      ...(_historyByLevel[level] ?? <AccessControl>[])
          .where((entry) => entry.id != access.id),
    ];
  }
}

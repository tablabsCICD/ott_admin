import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/response/admin_settings_models.dart';
import 'package:admin_ott/data/repositories/admin_settings_repository.dart';
import 'package:flutter/material.dart';

class AdminSettingsProvider extends ChangeNotifier {
  AdminSettingsProvider({AdminSettingsRepository? repository})
      : _repository = repository ?? AdminSettingsRepository();

  final AdminSettingsRepository _repository;

  final List<RevenueShareRule> _revenueRules = [];
  final List<RegistrationFeeRule> _registrationFeeRules = [];

  bool isLoading = false;
  bool isSaving = false;
  String? error;
  String _searchQuery = '';

  List<RevenueShareRule> get revenueRules {
    if (_searchQuery.trim().isEmpty) return List.unmodifiable(_revenueRules);
    return _revenueRules.where((rule) => rule.matches(_searchQuery)).toList();
  }

  List<RegistrationFeeRule> get registrationFeeRules {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_registrationFeeRules);
    }
    return _registrationFeeRules
        .where((rule) => rule.matches(_searchQuery))
        .toList();
  }

  String get searchQuery => _searchQuery;

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final errors = <String>[];

      try {
        final revenueRules = await _repository.getRevenueShareRules();
        _revenueRules
          ..clear()
          ..addAll(revenueRules);
      } catch (e) {
        errors.add(
          'Revenue share: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }

      try {
        final feeRules = await _repository.getRegistrationFeeRules();
        _registrationFeeRules
          ..clear()
          ..addAll(feeRules);
      } catch (e) {
        errors.add(
          'Registration fee: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }

      if (errors.isNotEmpty) {
        error = errors.join('\n');
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRevenueRule(RevenueShareRule rule) async {
    return _runSave(() async {
      final message = await _repository.saveRevenueShareRule(rule);
      CustomToast.show(message);
      await loadSettings();
    });
  }

  Future<bool> updateRevenueRule(RevenueShareRule rule) async {
    return _runSave(() async {
      final message = await _repository.updateRevenueShareRule(rule);
      CustomToast.show(message);
      await loadSettings();
    });
  }

  Future<bool> saveRegistrationFeeRule(RegistrationFeeRule rule) async {
    return _runSave(() async {
      final message = await _repository.saveRegistrationFeeRule(rule);
      CustomToast.show(message);
      await loadSettings();
    });
  }

  Future<bool> updateRegistrationFeeRule(RegistrationFeeRule rule) async {
    return _runSave(() async {
      final message = await _repository.updateRegistrationFeeRule(rule);
      CustomToast.show(message);
      await loadSettings();
    });
  }

  Future<bool> _runSave(Future<void> Function() operation) async {
    try {
      isSaving = true;
      notifyListeners();
      await operation();
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      CustomToast.show(message, isSuccess: false);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

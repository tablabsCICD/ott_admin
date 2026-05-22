import 'package:admin_ott/data/models/response/admin_settings_models.dart';
import 'package:admin_ott/data/services/admin_settings_api_service.dart';

class AdminSettingsRepository {
  AdminSettingsRepository({AdminSettingsApiService? service})
      : _service = service ?? AdminSettingsApiService();

  final AdminSettingsApiService _service;

  Future<List<RevenueShareRule>> getRevenueShareRules() async {
    final response = await _service.getRevenueShareRules();
    return extractListPayload(response)
        .map(RevenueShareRule.fromJson)
        .toList(growable: false);
  }

  Future<String> saveRevenueShareRule(RevenueShareRule rule) async {
    final response = await _service.saveRevenueShareRule(rule.toRequestJson());
    if (!responseSuccess(response)) {
      throw Exception(responseMessage(response, 'Failed to save rule'));
    }
    return responseMessage(response, 'Revenue share rule saved successfully');
  }

  Future<String> updateRevenueShareRule(RevenueShareRule rule) async {
    final id = rule.id;
    if (id == null) throw Exception('Rule id is missing');

    final response =
        await _service.updateRevenueShareRule(id, rule.toRequestJson());
    if (!responseSuccess(response)) {
      throw Exception(responseMessage(response, 'Failed to update rule'));
    }
    return responseMessage(response, 'Revenue share rule updated successfully');
  }

  Future<List<RegistrationFeeRule>> getRegistrationFeeRules() async {
    final response = await _service.getRegistrationFeeRules();
    return extractListPayload(response)
        .map(RegistrationFeeRule.fromJson)
        .toList(growable: false);
  }

  Future<String> saveRegistrationFeeRule(RegistrationFeeRule rule) async {
    final response =
        await _service.saveRegistrationFeeRule(rule.toRequestJson());
    if (!responseSuccess(response)) {
      throw Exception(responseMessage(response, 'Failed to save fee rule'));
    }
    return responseMessage(
        response, 'Registration fee rule saved successfully');
  }

  Future<String> updateRegistrationFeeRule(RegistrationFeeRule rule) async {
    final id = rule.id;
    if (id == null) throw Exception('Rule id is missing');

    final response =
        await _service.updateRegistrationFeeRule(id, rule.toRequestJson());
    if (!responseSuccess(response)) {
      throw Exception(responseMessage(response, 'Failed to update fee rule'));
    }
    return responseMessage(
      response,
      'Registration fee rule updated successfully',
    );
  }
}

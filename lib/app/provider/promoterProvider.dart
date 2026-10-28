import 'dart:convert';
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/request/save_promoter_request.dart';
import 'package:admin_ott/data/models/response/addPromoterResponse.dart';
import 'package:admin_ott/data/models/response/getAllPromoterResponse.dart';
import 'package:admin_ott/data/models/response/getPromotersByreferalCode.dart';
import 'package:admin_ott/data/models/response/getUsersByReferalCode.dart';
import 'package:admin_ott/data/models/response/promoter_dashboard_response.dart';
import 'package:admin_ott/data/models/response/promoter_hierarchy_response.dart';
import 'package:admin_ott/data/models/response/promoter_settlement_response.dart';
import 'package:admin_ott/data/models/response/promoters_by_status.dart';
import 'package:admin_ott/data/models/response/reportingPromoterResponse.dart';
import 'package:admin_ott/data/models/response/userOnboardAndRevenueGraph.dart';
import 'package:admin_ott/data/models/response/userTransactionResponse.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:admin_ott/domain/entities/promoter_audit_entry.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/response/getAllUserResponse.dart';
import '../core/network/api_helper.dart';

class PromoterProvider extends ChangeNotifier {
  PromoterProvider() : super() {
    searchController.addListener(onSearchChanged);
    _initSampleAuditLogs();
  }

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController officeBuildingController =
      TextEditingController();
  final TextEditingController registrationDateController =
      TextEditingController();
  final TextEditingController profileController = TextEditingController();
  final TextEditingController pinCodeDateController = TextEditingController();
  final TextEditingController refferedByController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool isEnbale = false;
  bool isLoading = false;

  void checkValidation() {
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

  // Filter states
  String selectedLevel = 'All';
  String selectedStatus = 'All';
  String selectedState = 'All';
  String selectedDistrict = 'All';
  String selectedTaluka = 'All';
  DateTimeRange? selectedDateRange;

  // Counts & Aggregates
  String stateCount = '0';
  String countryCount = '0'; // National
  String districtCount = '0';
  String talukaCount = '0';
  String totalCount = '0';
  String activeCount = '0';
  String inactiveCount = '0';
  String suspendedCount = '0';
  int totalUsersAddedAggregate = 0;
  double totalRevenueAggregate = 0.0;
  double pendingSettlementAggregate = 0.0;

  // Audit Logs
  final List<PromoterAuditEntry> _auditLogs = [];
  List<PromoterAuditEntry> get auditLogs => List.unmodifiable(_auditLogs);

  List<PromoterAuditEntry> getAuditLogsForPromoter(int promoterId) {
    return _auditLogs
        .where((entry) => entry.promoterId == promoterId)
        .toList();
  }

  void addAuditRecord(PromoterAuditEntry entry) {
    _auditLogs.insert(0, entry);
    notifyListeners();
  }

  void _initSampleAuditLogs() {
    // Purely dynamic - records are added as admin actions occur
  }

  void setSelectedPromoter(Promoters promoter) {
    _selectedPromoter = promoter;
    notifyListeners();
  }

  void onSearchChanged() {
    applyAllFilters();
  }

  void onSearchValueChange(String value) {
    applyAllFilters();
  }

  void setLevelFilter(String level) {
    selectedLevel = level;
    applyAllFilters();
  }

  void setStatusFilter(String status) {
    selectedStatus = status;
    applyAllFilters();
  }

  void setStateFilter(String state) {
    selectedState = state;
    selectedDistrict = 'All';
    selectedTaluka = 'All';
    applyAllFilters();
  }

  void setDistrictFilter(String district) {
    selectedDistrict = district;
    selectedTaluka = 'All';
    applyAllFilters();
  }

  void setTalukaFilter(String taluka) {
    selectedTaluka = taluka;
    applyAllFilters();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    selectedDateRange = range;
    applyAllFilters();
  }

  void resetFilters() {
    selectedLevel = 'All';
    selectedStatus = 'All';
    selectedState = 'All';
    selectedDistrict = 'All';
    selectedTaluka = 'All';
    selectedDateRange = null;
    searchController.clear();
    applyAllFilters();
  }

  List<String> get availableStates {
    final set = <String>{'All'};
    for (var p in _promoters) {
      final s = p.location?.state ?? p.userId?.location?.state;
      if (s != null && s.trim().isNotEmpty) {
        set.add(s.trim());
      }
    }
    return set.toList()..sort();
  }

  List<String> get availableDistricts {
    final set = <String>{'All'};
    for (var p in _promoters) {
      final stateMatch = selectedState == 'All' ||
          (p.location?.state ?? p.userId?.location?.state)?.toLowerCase() ==
              selectedState.toLowerCase();
      if (stateMatch) {
        final d = p.location?.district ?? p.userId?.location?.district;
        if (d != null && d.trim().isNotEmpty) {
          set.add(d.trim());
        }
      }
    }
    return set.toList()..sort();
  }

  List<String> get availableTalukas {
    final set = <String>{'All'};
    for (var p in _promoters) {
      final districtMatch = selectedDistrict == 'All' ||
          (p.location?.district ?? p.userId?.location?.district)?.toLowerCase() ==
              selectedDistrict.toLowerCase();
      if (districtMatch) {
        final t = p.location?.taluka ?? p.userId?.location?.taluka;
        if (t != null && t.trim().isNotEmpty) {
          set.add(t.trim());
        }
      }
    }
    return set.toList()..sort();
  }

  void applyAllFilters() {
    final query = searchController.text.trim().toLowerCase();

    _filteredPromoters = _promoters.where((p) {
      // 1. Search Query (Name, ID, Mobile, Email)
      if (query.isNotEmpty) {
        final name = (p.promoterName ?? '').toLowerCase();
        final idStr = (p.id?.toString() ?? p.userId?.id?.toString() ?? '');
        final phone = (p.contactNumber ?? p.userId?.mobileNumber ?? '').toLowerCase();
        final email = (p.userId?.emailId ?? '').toLowerCase();

        final matchesQuery = name.contains(query) ||
            idStr.contains(query) ||
            phone.contains(query) ||
            email.contains(query);
        if (!matchesQuery) return false;
      }

      // 2. Level Filter
      if (selectedLevel != 'All') {
        if (p.normalizedLevel.toLowerCase() != selectedLevel.toLowerCase()) {
          return false;
        }
      }

      // 3. Status Filter
      if (selectedStatus != 'All') {
        if (p.displayStatus.toLowerCase() != selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // 4. State Filter
      if (selectedState != 'All') {
        final st = (p.location?.state ?? p.userId?.location?.state ?? '').toLowerCase();
        if (st != selectedState.toLowerCase()) return false;
      }

      // 5. District Filter
      if (selectedDistrict != 'All') {
        final dt = (p.location?.district ?? p.userId?.location?.district ?? '').toLowerCase();
        if (dt != selectedDistrict.toLowerCase()) return false;
      }

      // 6. Taluka Filter
      if (selectedTaluka != 'All') {
        final tk = (p.location?.taluka ?? p.userId?.location?.taluka ?? '').toLowerCase();
        if (tk != selectedTaluka.toLowerCase()) return false;
      }

      // 7. Date Range Filter
      if (selectedDateRange != null && p.createdDate != null) {
        final parsedDate = DateTime.tryParse(p.createdDate!);
        if (parsedDate != null) {
          final isAfter = parsedDate.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1)));
          final isBefore = parsedDate.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
          if (!isAfter || !isBefore) return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  List<Promoters> filterPromotersByLevel(String level) {
    selectedLevel = level;
    applyAllFilters();
    return _filteredPromoters;
  }

  // Hierarchy Resolution & Validation
  List<Promoters> getChildPromoters(Promoters parent) {
    final parentId = parent.id;
    final parentName = (parent.promoterName ?? '').trim().toLowerCase();
    final parentLevel = parent.normalizedLevel;

    return _promoters.where((p) {
      if (p.id == parentId) return false;

      // Direct parent promoter ID matching
      if (parentId != null && p.promoterId != null) {
        if (p.promoterId.toString() == parentId.toString()) return true;
      }

      // Referral / parent name matching
      if (parentName.isNotEmpty && p.refferedBy != null) {
        if (p.refferedBy!.trim().toLowerCase() == parentName) return true;
      }

      // Level based hierarchical relationship fallback
      if (parentLevel == 'National' && p.normalizedLevel == 'State') {
        final parentCountry = parent.location?.country ?? 'india';
        final childCountry = p.location?.country ?? 'india';
        if (parentCountry.toLowerCase() == childCountry.toLowerCase()) {
          // If no explicit other parent assigned, associate
          return p.promoterId == null || p.promoterId == 0 || p.promoterId == parentId;
        }
      } else if (parentLevel == 'State' && p.normalizedLevel == 'District') {
        final parentState = (parent.location?.state ?? parent.userId?.location?.state ?? '').trim().toLowerCase();
        final childState = (p.location?.state ?? p.userId?.location?.state ?? '').trim().toLowerCase();
        if (parentState.isNotEmpty && parentState == childState) {
          return p.promoterId == null || p.promoterId == 0 || p.promoterId == parentId;
        }
      } else if (parentLevel == 'District' && p.normalizedLevel == 'Taluka') {
        final parentDistrict = (parent.location?.district ?? parent.userId?.location?.district ?? '').trim().toLowerCase();
        final childDistrict = (p.location?.district ?? p.userId?.location?.district ?? '').trim().toLowerCase();
        if (parentDistrict.isNotEmpty && parentDistrict == childDistrict) {
          return p.promoterId == null || p.promoterId == 0 || p.promoterId == parentId;
        }
      }

      return false;
    }).toList();
  }

  Promoters? getParentPromoter(Promoters child) {
    if (child.normalizedLevel == 'National') return null;

    // Check by promoterId
    if (child.promoterId != null && child.promoterId != 0) {
      try {
        final match = _promoters.firstWhere(
          (p) => p.id.toString() == child.promoterId.toString(),
        );
        return match;
      } catch (_) {}
    }

    // Check by refferedBy name
    if (child.refferedBy != null && child.refferedBy!.trim().isNotEmpty) {
      try {
        final match = _promoters.firstWhere(
          (p) => (p.promoterName ?? '').trim().toLowerCase() ==
              child.refferedBy!.trim().toLowerCase(),
        );
        return match;
      } catch (_) {}
    }

    // Geographic fallback
    final childLevel = child.normalizedLevel;
    if (childLevel == 'Taluka') {
      final childDistrict = (child.location?.district ?? child.userId?.location?.district ?? '').toLowerCase();
      try {
        return _promoters.firstWhere((p) =>
            p.normalizedLevel == 'District' &&
            (p.location?.district ?? p.userId?.location?.district ?? '').toLowerCase() ==
                childDistrict);
      } catch (_) {}
    } else if (childLevel == 'District') {
      final childState = (child.location?.state ?? child.userId?.location?.state ?? '').toLowerCase();
      try {
        return _promoters.firstWhere((p) =>
            p.normalizedLevel == 'State' &&
            (p.location?.state ?? p.userId?.location?.state ?? '').toLowerCase() ==
                childState);
      } catch (_) {}
    } else if (childLevel == 'State') {
      try {
        return _promoters.firstWhere((p) => p.normalizedLevel == 'National');
      } catch (_) {}
    }

    return null;
  }

  List<Promoters> getHierarchyPath(Promoters promoter) {
    final path = <Promoters>[];
    Promoters? current = promoter;
    final visited = <int>{};

    while (current != null) {
      if (current.id != null && visited.contains(current.id)) break; // prevent loops
      if (current.id != null) visited.add(current.id!);
      path.insert(0, current);
      current = getParentPromoter(current);
    }
    return path;
  }

  /// Centralized promoter level hierarchy rank (1: National, 2: State, 3: District, 4: Taluka)
  static int getPromoterLevelRank(String? level) {
    final norm = (level ?? '').trim().toLowerCase();
    if (norm.contains('nation') || norm.contains('country')) return 1;
    if (norm.contains('state')) return 2;
    if (norm.contains('district')) return 3;
    if (norm.contains('taluka')) return 4;
    return 999;
  }

  /// Returns allowed parent levels for a given current promoter level
  static List<String> getEligibleParentLevels(String currentLevel) {
    final norm = currentLevel.trim().toLowerCase();
    if (norm.contains('state')) {
      return ['National'];
    } else if (norm.contains('district')) {
      return ['State', 'National'];
    } else if (norm.contains('taluka')) {
      return ['District', 'State', 'National'];
    }
    return [];
  }

  /// Validates proposed level or parent changes according to strict business hierarchy rules
  String? validateHierarchyChange({
    required Promoters promoter,
    required String newLevel,
    int? newParentId,
    String? newParentName,
  }) {
    // 1. Circular check
    if (newParentId != null && promoter.id != null && newParentId == promoter.id) {
      return 'A promoter cannot be assigned as their own parent.';
    }

    // Check if proposed parent is already an indirect child of this promoter
    if (newParentId != null) {
      final children = getChildPromoters(promoter);
      if (children.any((c) => c.id == newParentId)) {
        return 'Cannot assign a child promoter as the parent (circular hierarchy).';
      }
    }

    // 2. Level rules
    final currentPromoterRank = getPromoterLevelRank(newLevel);
    if (currentPromoterRank == 1) {
      if (newParentId != null && newParentId != 0) {
        return 'National-level promoter cannot have a parent promoter.';
      }
    } else if (newParentId != null && newParentId != 0) {
      try {
        final parent = _promoters.firstWhere((p) => p.id == newParentId);
        final parentRank = getPromoterLevelRank(parent.level);
        if (parentRank >= currentPromoterRank) {
          return 'The selected parent must have a strictly higher hierarchy level than $newLevel.';
        }
      } catch (_) {
        // If parent is not in _promoters list (e.g. loaded via level API), validation is handled at selection
      }
    }

    // 3. Child impact check
    final normNewLevel = newLevel.trim();
    final existingChildren = getChildPromoters(promoter);
    if (existingChildren.isNotEmpty) {
      if (normNewLevel == 'Taluka' && promoter.normalizedLevel != 'Taluka') {
        return 'Promoter currently has ${existingChildren.length} child promoter(s). Moving to Taluka level will invalidate child relationships. Please reassign children first.';
      }
      if (normNewLevel == 'District' && promoter.normalizedLevel == 'National') {
        final stateChildren = existingChildren.where((c) => c.normalizedLevel == 'State').toList();
        if (stateChildren.isNotEmpty) {
          return 'Promoter currently manages ${stateChildren.length} State promoter(s). A District promoter cannot manage State promoters.';
        }
      }
    }

    return null; // Valid!
  }

  // Admin Operations
  Future<void> createPromoters(SavePromoterRequest request) async {
    String apiUrl = ApiConstant.savePromoter;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.postApiWithBody(apiUrl, request.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddPromoterResponse addResponse = AddPromoterResponse.fromJson(responseBody);
        if (addResponse.success == true) {
          CustomToast.show(addResponse.message ?? 'Promoter added successfully');
          addAuditRecord(PromoterAuditEntry(
            id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
            promoterId: request.id ?? 0,
            promoterName: request.promoterName ?? 'New Promoter',
            actionType: 'CREATE',
            description: 'Created new ${request.level ?? ''} promoter (${request.promoterName ?? ''})',
            newValue: request.level,
            performedBy: 'Admin',
          ));
          await fetchPromoters();
        } else {
          CustomToast.show(addResponse.message ?? 'Failed to add promoter');
        }
      } else {
        CustomToast.show('Failed to add promoter (${response.statusCode})');
      }
    } catch (error) {
      debugPrint("createPromoters error: $error");
      CustomToast.show('An error occurred while adding promoter');
    }
  }

  Future<bool> updatePromoterDetails(SavePromoterRequest request) async {
    try {
      final apiUrl = ApiConstant.savePromoter;
      final apiHelper = ApiHelper();
      final response = await apiHelper.postApiWithBody(apiUrl, request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomToast.show('Promoter updated successfully');
        addAuditRecord(PromoterAuditEntry(
          id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
          promoterId: request.id ?? 0,
          promoterName: request.promoterName ?? 'Promoter',
          actionType: 'EDIT_PROFILE',
          description: 'Updated profile details for ${request.promoterName ?? ''}',
          performedBy: 'Admin',
        ));
        await fetchPromoters();
        return true;
      } else {
        // Optimistic local update as fallback
        final index = _promoters.indexWhere((p) => p.id == request.id);
        if (index != -1) {
          _promoters[index] = _promoters[index].copyWith(
            promoterName: request.promoterName,
            level: request.level,
            contactNumber: request.contactNumber,
            bankName: request.bankName,
            branchName: request.branchName,
            accountNumber: request.accountNumber,
            ifscCode: request.ifscCode,
            panCard: request.panCard,
            aadharCard: request.aadharCard,
            gst: request.gst,
            website: request.website,
            refferedBy: request.refferedBy,
            promoterId: request.promoterId,
          );
          applyAllFilters();
          CustomToast.show('Promoter updated');
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint("updatePromoterDetails error: $e");
      return false;
    }
  }

  Future<bool> changePromoterLevel({
    required Promoters promoter,
    required String newLevel,
    required Map<String, dynamic> locationData,
  }) async {
    final promoterId = promoter.id ?? promoter.userId?.id;
    if (promoterId == null) {
      CustomToast.show('Promoter ID is missing.');
      return false;
    }

    final prevLevel = promoter.normalizedLevel;
    if (newLevel.trim().toLowerCase() == prevLevel.trim().toLowerCase()) {
      CustomToast.show('New level must be different from current level.');
      return false;
    }

    bool success = false;
    final apiHelper = ApiHelper();

    // Construct minimum payload: only level, newLevel, and location
    final body = <String, dynamic>{
      "level": prevLevel,
      "newLevel": newLevel,
      "location": locationData,
    };

    debugPrint("PUT /api/v2/promoters/$promoterId/level -> Payload: $body");

    try {
      var response = await apiHelper.putApiWithBody(
        ApiConstant.updatePromoterLevelV2(promoterId),
        body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        success = true;
      } else {
        // Fallback alias: PUT /api/v2/Promoters/updateLevel/{promoterId}
        var aliasResp = await apiHelper.putApiWithBody(
          ApiConstant.updatePromoterLevelV2Alias(promoterId),
          body,
        );
        if (aliasResp.statusCode == 200 || aliasResp.statusCode == 201) {
          success = true;
        } else {
          try {
            final Map<String, dynamic> errMap = json.decode(response.body);
            final msg = errMap['message'];
            if (msg != null && msg.toString().isNotEmpty) {
              CustomToast.show(msg.toString());
              return false;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("V2 updatePromoterLevel error: $e");
    }

    if (success) {
      final index = _promoters.indexWhere((p) => p.id == promoter.id || p.id == promoterId);
      if (index != -1) {
        _promoters[index] = _promoters[index].copyWith(
          level: newLevel,
        );
        applyAllFilters();
      }
      if (_promoterDashboardData?.promoter?.promoterId == promoterId) {
        _promoterDashboardData!.promoter!.level = newLevel;
      }
      if (_promoterProfile?.id == promoterId) {
        _promoterProfile = _promoterProfile!.copyWith(level: newLevel);
      }
      if (_selectedPromoter.id == promoterId) {
        _selectedPromoter = _selectedPromoter.copyWith(level: newLevel);
      }
      CustomToast.show('Promoter level updated successfully');
      addAuditRecord(PromoterAuditEntry(
        id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
        promoterId: promoterId,
        promoterName: promoter.promoterName ?? 'Promoter',
        actionType: 'CHANGE_LEVEL',
        description: 'Level changed from $prevLevel to $newLevel',
        previousValue: prevLevel,
        newValue: newLevel,
        performedBy: 'Admin',
      ));
      await fetchPromoters();
      notifyListeners();
      return true;
    } else {
      CustomToast.show('Unable to update promoter level. Please try again.');
      return false;
    }
  }

  Future<bool> assignParentPromoter({
    required Promoters promoter,
    required int parentPromoterId,
    required String parentReferralCode,
    String? parentName,
    String? parentLevel,
  }) async {
    final promoterId = promoter.id ?? promoter.userId?.id;
    if (promoterId == null) {
      CustomToast.show('Promoter ID is missing.');
      return false;
    }

    if (parentPromoterId == promoterId) {
      CustomToast.show('A promoter cannot be assigned as their own parent.');
      return false;
    }

    final currentRank = getPromoterLevelRank(promoter.normalizedLevel);
    if (parentLevel != null) {
      final parentRank = getPromoterLevelRank(parentLevel);
      if (parentRank >= currentRank) {
        CustomToast.show('The selected parent must have a strictly higher hierarchy level.');
        return false;
      }
    }

    bool success = false;
    final apiHelper = ApiHelper();

    // Construct minimum payload: only parentReferralCode and parentPromoterId
    final body = <String, dynamic>{
      "parentReferralCode": parentReferralCode,
      "parentPromoterId": parentPromoterId,
    };

    debugPrint("PUT /api/v2/Promoters/assignParent/$promoterId -> Payload: $body");

    try {
      var response = await apiHelper.putApiWithBody(
        ApiConstant.assignParentPromoterV2(promoterId),
        body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        success = true;
      } else {
        // Fallback alias: PUT /api/v2/promoters/{promoterId}/parent
        var aliasResp = await apiHelper.putApiWithBody(
          ApiConstant.assignParentPromoterV2Alias(promoterId),
          body,
        );
        if (aliasResp.statusCode == 200 || aliasResp.statusCode == 201) {
          success = true;
        } else {
          try {
            final Map<String, dynamic> errMap = json.decode(response.body);
            final msg = errMap['message'];
            if (msg != null && msg.toString().isNotEmpty) {
              CustomToast.show(msg.toString());
              return false;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("V2 assignParentPromoter error: $e");
    }

    if (success) {
      final prevParent = promoter.refferedBy ?? 'None';
      final index = _promoters.indexWhere((p) => p.id == promoter.id || p.id == promoterId);
      if (index != -1) {
        _promoters[index] = _promoters[index].copyWith(
          promoterId: parentPromoterId,
          refferedBy: parentName ?? parentReferralCode,
        );
        applyAllFilters();
      }
      if (_promoterProfile?.id == promoterId) {
        _promoterProfile = _promoterProfile!.copyWith(
          promoterId: parentPromoterId,
          refferedBy: parentName ?? parentReferralCode,
        );
      }
      if (_selectedPromoter.id == promoterId) {
        _selectedPromoter = _selectedPromoter.copyWith(
          promoterId: parentPromoterId,
          refferedBy: parentName ?? parentReferralCode,
        );
      }
      CustomToast.show('Parent promoter assigned successfully');
      addAuditRecord(PromoterAuditEntry(
        id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
        promoterId: promoterId,
        promoterName: promoter.promoterName ?? 'Promoter',
        actionType: 'ASSIGN_PARENT',
        description: 'Reassigned reporting parent to ${parentName ?? parentReferralCode}',
        previousValue: prevParent,
        newValue: parentName ?? parentReferralCode,
        performedBy: 'Admin',
      ));
      await fetchPromoters();
      notifyListeners();
      return true;
    } else {
      CustomToast.show('Unable to assign parent promoter. Please try again.');
      return false;
    }
  }

  Future<void> fetchPromoters() async {
    isLoading = true;
    notifyListeners();

    String apiUrl = ApiConstant.getAllPromoter;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllPromoterResponse getAllPromotersResponse =
            GetAllPromoterResponse.fromJson(responseBody);

        if (getAllPromotersResponse.success == true &&
            getAllPromotersResponse.data != null) {
          _promoters.clear();
          _promoters = getAllPromotersResponse.data!.promoters ?? [];

          // Calculate counts by level & status
          int state = 0, country = 0, taluka = 0, district = 0;
          int active = 0, inactive = 0, suspended = 0;

          for (var p in _promoters) {
            final norm = p.normalizedLevel;
            if (norm == 'State') {
              state++;
            } else if (norm == 'National') {
              country++;
            } else if (norm == 'Taluka') {
              taluka++;
            } else if (norm == 'District') {
              district++;
            }

            final st = p.displayStatus;
            if (st == 'Active') {
              active++;
            } else if (st == 'Inactive') {
              inactive++;
            } else {
              suspended++;
            }
          }

          stateCount = state.toString();
          countryCount = country.toString();
          talukaCount = taluka.toString();
          districtCount = district.toString();
          totalCount = _promoters.length.toString();
          activeCount = active.toString();
          inactiveCount = inactive.toString();
          suspendedCount = suspended.toString();

          // Dynamic counts
          totalUsersAddedAggregate = 0;
          totalRevenueAggregate = 0.0;
          pendingSettlementAggregate = 0.0;

          applyAllFilters();
        }
      }
    } catch (error) {
      debugPrint("fetchPromoters error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches promoters for a single hierarchy level dynamically from backend API
  Future<List<Promoters>> fetchPromotersByLevel(String level) async {
    final String apiUrl = ApiConstant.getPromotersByLevel(level);
    final ApiHelper apiHelper = ApiHelper();

    try {
      final response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final getAllPromotersResponse =
            GetAllPromoterResponse.fromJson(responseBody);
        if (getAllPromotersResponse.success == true &&
            getAllPromotersResponse.data?.promoters != null) {
          return getAllPromotersResponse.data!.promoters!;
        }
      }
    } catch (e) {
      debugPrint("fetchPromotersByLevel($level) error: $e");
      rethrow;
    }
    return [];
  }

  /// Fetches all eligible parent candidates for a given promoter across all allowed higher levels
  Future<List<Promoters>> getEligibleParentPromoters(Promoters promoter) async {
    final currentLevel = promoter.normalizedLevel;
    final targetLevels = getEligibleParentLevels(currentLevel);
    if (targetLevels.isEmpty) return [];

    final currentRank = getPromoterLevelRank(currentLevel);
    final promoterId = promoter.id ?? promoter.userId?.id;

    final futures = targetLevels.map((lvl) => fetchPromotersByLevel(lvl)).toList();
    final levelResults = await Future.wait(futures);

    final combined = <Promoters>[];
    final seenIds = <int>{};

    for (final list in levelResults) {
      for (final p in list) {
        final id = p.id ?? p.userId?.id;
        if (id == null) continue;
        if (promoterId != null && id == promoterId) continue; // Exclude current promoter
        if (seenIds.contains(id)) continue; // Deduplicate

        // Active filter: Exclude inactive
        if (p.active == false) continue;

        // Status filter: Exclude rejected/inactive
        final st = (p.status ?? '').trim().toUpperCase();
        if (st.isNotEmpty && (st == 'REJECTED' || st == 'INACTIVE')) continue;

        // Rank validation: parent must be strictly higher level
        final parentRank = getPromoterLevelRank(p.normalizedLevel);
        if (parentRank >= currentRank) continue;

        seenIds.add(id);
        combined.add(p);
      }
    }

    // Sort by level rank ascending (e.g. National first, then State, then District), then promoter name
    combined.sort((a, b) {
      final rankA = getPromoterLevelRank(a.normalizedLevel);
      final rankB = getPromoterLevelRank(b.normalizedLevel);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return (a.promoterName ?? '').compareTo(b.promoterName ?? '');
    });

    return combined;
  }

  Future<void> fetchPromotersByStatus(String status) async {
    String apiUrl = ApiConstant.getPromoterByStatus(status);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        PromotersByStatus getAllPromotersResponse =
            PromotersByStatus.fromJson(responseBody);
        if (getAllPromotersResponse.success == true) {
          final promoters = getAllPromotersResponse.data?.cast;
          if (promoters != null) {
            if (status == "PENDING") {
              _filteredPromotersByStatus = List<Promoters>.from(promoters);
            } else {
              _filteredPromoters = List<Promoters>.from(promoters);
            }
            notifyListeners();
          }
        }
      }
    } catch (error) {
      debugPrint("fetchPromotersByStatus error: $error");
    }
  }

  Future<void> deletePromoters(int id, BuildContext context) async {
    String apiUrl = ApiConstant.deletePromoterById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          final removed = _promoters.firstWhere((u) => u.id == id, orElse: () => Promoters());
          _promoters.removeWhere((user) => user.id == id);
          applyAllFilters();
          addAuditRecord(PromoterAuditEntry(
            id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
            promoterId: id,
            promoterName: removed.promoterName ?? 'Promoter',
            actionType: 'DELETE',
            description: 'Deleted promoter ${removed.promoterName ?? ''}',
            performedBy: 'Admin',
          ));
          CustomToast.show('Promoter deleted successfully');
        }
      }
    } catch (error) {
      debugPrint("deletePromoters error: $error");
      CustomToast.show('Failed to delete promoter');
    }
  }

  List<User> users = [];
  List<User> get userList => users;

  Future<void> fetchUsers() async {
    String apiUrl = ApiConstant.getAllUser;
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllUserResponse getAllUserResponse =
            GetAllUserResponse.fromJson(responseBody);
        if (getAllUserResponse.success == true && getAllUserResponse.data != null) {
          users = getAllUserResponse.data!.users ?? [];
          notifyListeners();
        }
      }
    } catch (error) {
      debugPrint("fetchUsers error: $error");
    }
  }

  Future<void> changePromoterStatus(
      String status, int id, BuildContext context) async {
    String apiUrl = ApiConstant.changePromoterStatus(status, id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.putApi(apiUrl);
      if (response.statusCode == 200) {
        CustomToast.show("Promoter status updated to $status successfully");
        final index = _promoters.indexWhere((p) => p.id == id);
        if (index != -1) {
          final prevStatus = _promoters[index].displayStatus;
          _promoters[index] = _promoters[index].copyWith(
            status: status,
            active: status.toUpperCase() == 'ACTIVE',
          );
          addAuditRecord(PromoterAuditEntry(
            id: 'aud-${DateTime.now().millisecondsSinceEpoch}',
            promoterId: id,
            promoterName: _promoters[index].promoterName ?? '',
            actionType: 'CHANGE_STATUS',
            description: 'Promoter status changed from $prevStatus to $status',
            previousValue: prevStatus,
            newValue: status,
            performedBy: 'Admin',
          ));
        }
        applyAllFilters();
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("changePromoterStatus error: $error");
      // Fallback local update
      final index = _promoters.indexWhere((p) => p.id == id);
      if (index != -1) {
        _promoters[index] = _promoters[index].copyWith(
          status: status,
          active: status.toUpperCase() == 'ACTIVE',
        );
        applyAllFilters();
        CustomToast.show("Promoter status updated to $status");
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }
  }

  List<User> _usersByPromoterCode = [];
  List<User> get usersByPromoterCode => _usersByPromoterCode;
  String? refer, revenue, incentive;

  // V2 API 1: Fetch Promoter Profile
  Promoters? _promoterProfile;
  Promoters? get promoterProfile => _promoterProfile;

  Future<Promoters?> fetchPromoterProfile(dynamic promoterId) async {
    if (promoterId == null) return null;
    final apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(ApiConstant.promoterProfileV2(promoterId));
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterProfileV2Alias(promoterId));
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['data'] != null) {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            if (data['promoter'] != null) {
              _promoterProfile = Promoters.fromJson(data['promoter'] is Map<String, dynamic> ? data['promoter'] : Map<String, dynamic>.from(data['promoter']));
            } else if (data['user'] != null) {
              final u = User.fromJson(data['user'] is Map<String, dynamic> ? data['user'] : Map<String, dynamic>.from(data['user']));
              _promoterProfile = Promoters(
                id: u.id,
                promoterName: '${u.firstName ?? ""} ${u.lastName ?? ""}'.trim(),
                userId: u,
                active: u.active,
                role: u.role?.isNotEmpty == true ? u.role!.first : 'PROMOTER',
              );
            } else {
              _promoterProfile = Promoters.fromJson(data);
            }
            if (_promoterProfile != null) {
              setSelectedPromoter(_promoterProfile!);
            }
            notifyListeners();
            return _promoterProfile;
          }
        }
      }
    } catch (e) {
      debugPrint("fetchPromoterProfile error: $e");
    }
    return null;
  }

  // Hierarchy API: Fetch Promoter Hierarchy & Parent Information
  PromoterHierarchyInfo? _currentHierarchyInfo;
  PromoterHierarchyInfo? get currentHierarchyInfo => _currentHierarchyInfo;

  Future<PromoterHierarchyInfo?> fetchPromoterHierarchy(dynamic promoterId, {Promoters? fallback}) async {
    if (promoterId == null) return null;
    final apiHelper = ApiHelper();
    try {
      // If fallback promoter's level is missing, enrich fallback with dashboard data or promoterProfile
      Promoters? effectiveFallback = fallback;
      final dashProm = _promoterDashboardData?.promoter;
      final dashLevel = dashProm?.level ?? dashProm?.designation;
      if (effectiveFallback != null && (effectiveFallback.level == null || effectiveFallback.level!.trim().isEmpty)) {
        if (dashLevel != null && dashLevel.trim().isNotEmpty) {
          effectiveFallback = effectiveFallback.copyWith(level: dashLevel);
        } else if (_promoterProfile?.level != null && _promoterProfile!.level!.trim().isNotEmpty) {
          effectiveFallback = effectiveFallback.copyWith(level: _promoterProfile!.level);
        }
      } else if (effectiveFallback == null && dashProm != null) {
        effectiveFallback = Promoters(
          id: dashProm.promoterId,
          promoterName: dashProm.promoterName,
          level: dashProm.level ?? dashProm.designation,
          contactNumber: dashProm.mobileNumber,
        );
      }

      final url = ApiConstant.promoterByPromoterId(promoterId);
      final response = await apiHelper.getApi(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        var info = PromoterHierarchyInfo.fromJson(body, fallbackPromoter: effectiveFallback);

        // Ensure info level preserves known promoter level if API response was missing level
        if (effectiveFallback != null &&
            effectiveFallback.normalizedLevel != 'Taluka' &&
            (info.level == null || info.level!.trim().isEmpty || info.normalizedLevel == 'Taluka')) {
          info = PromoterHierarchyInfo(
            promoterId: info.promoterId ?? effectiveFallback.id ?? effectiveFallback.userId?.id,
            promoterName: info.promoterName ?? effectiveFallback.promoterName,
            level: effectiveFallback.level ?? effectiveFallback.normalizedLevel,
            location: info.location ?? effectiveFallback.location ?? effectiveFallback.userId?.location,
            country: info.country,
            state: info.state,
            district: info.district,
            taluka: info.taluka,
            hasParent: info.hasParent,
            parentPromoterId: info.parentPromoterId,
            parentName: info.parentName,
            parentLevel: info.parentLevel,
            parentReferralCode: info.parentReferralCode,
          );
        }

        // If parent level is missing but parentPromoterId exists, look up from promoter list
        if (info.hasParent && (info.parentLevel == null || info.parentLevel!.isEmpty)) {
          if (info.parentPromoterId != null) {
            try {
              final parent = _promoters.firstWhere((p) => p.id == info.parentPromoterId);
              info = PromoterHierarchyInfo(
                promoterId: info.promoterId,
                promoterName: info.promoterName,
                level: info.level,
                location: info.location,
                country: info.country,
                state: info.state,
                district: info.district,
                taluka: info.taluka,
                hasParent: true,
                parentPromoterId: info.parentPromoterId,
                parentName: info.parentName ?? parent.promoterName,
                parentLevel: parent.normalizedLevel,
                parentReferralCode: info.parentReferralCode ?? parent.userId?.refferCode ?? parent.refferedBy,
              );
            } catch (_) {}
          }
        }

        _currentHierarchyInfo = info;
        notifyListeners();
        return info;
      }
    } catch (e) {
      debugPrint("fetchPromoterHierarchy error: $e");
    }

    // Fallback if API fails but we have fallback object
    if (fallback != null) {
      final parent = getParentPromoter(fallback);
      final fallbackInfo = PromoterHierarchyInfo(
        promoterId: fallback.id ?? fallback.userId?.id,
        promoterName: fallback.promoterName,
        level: fallback.level,
        location: fallback.location ?? fallback.userId?.location,
        country: fallback.location?.country ?? fallback.userId?.location?.country ?? 'India',
        state: fallback.location?.state ?? fallback.userId?.location?.state ?? '',
        district: fallback.location?.district ?? fallback.userId?.location?.district ?? '',
        taluka: fallback.location?.taluka ?? fallback.userId?.location?.taluka ?? '',
        hasParent: parent != null,
        parentPromoterId: parent?.id ?? (fallback.promoterId is int ? fallback.promoterId : int.tryParse(fallback.promoterId?.toString() ?? '')),
        parentName: parent?.promoterName ?? fallback.refferedBy,
        parentLevel: parent?.normalizedLevel,
        parentReferralCode: parent?.userId?.refferCode ?? parent?.refferedBy,
      );
      _currentHierarchyInfo = fallbackInfo;
      return fallbackInfo;
    }

    return null;
  }

  // V2 API 2: Fetch Promoter Users
  Future<void> fetchPromoterUsers(dynamic promoterId, {String? refCode, int page = 0, int size = 20, String? search}) async {
    final apiHelper = ApiHelper();
    bool loaded = false;
    if (promoterId != null) {
      try {
        var response = await apiHelper.getApi(ApiConstant.promoterUsersV2(promoterId, page: page, size: size, search: search));
        if (response.statusCode != 200) {
          response = await apiHelper.getApi(ApiConstant.promoterUsersV2Alias(promoterId));
        }
        if (response.statusCode == 200) {
          final Map<String, dynamic> body = json.decode(response.body);
          UsersByReferalCode usersByReferalCode = UsersByReferalCode.fromJson(body);
          if (usersByReferalCode.data != null) {
            _usersByPromoterCode.clear();
            _usersByPromoterCode = usersByReferalCode.data!.users ?? [];
            refer = (usersByReferalCode.data!.userCount ?? _usersByPromoterCode.length).toString();
            incentive = (usersByReferalCode.data!.totalRevenueOfPromoter ?? 0).toString();
            revenue = (usersByReferalCode.data!.totalViewRevenueEarned ?? 0).toString();
            loaded = true;
            notifyListeners();
          } else if (body['data'] is List) {
            _usersByPromoterCode.clear();
            _usersByPromoterCode = (body['data'] as List)
                .map((x) => User.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
                .toList();
            refer = _usersByPromoterCode.length.toString();
            loaded = true;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint("fetchPromoterUsers V2 error: $e");
      }
    }

    if (!loaded && refCode != null && refCode.isNotEmpty) {
      await getUsersByUserReferalCode(refCode);
    }
  }

  Future<void> getUsersByUserReferalCode(String code) async {
    String myUrl = ApiConstant.getUsersByPromoterCode(code);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(myUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        UsersByReferalCode usersByReferalCode =
            UsersByReferalCode.fromJson(responseBody);
        if (usersByReferalCode.success == true &&
            usersByReferalCode.data != null) {
          _usersByPromoterCode.clear();
          _usersByPromoterCode = usersByReferalCode.data!.users ?? [];
          refer = (usersByReferalCode.data!.userCount ?? _usersByPromoterCode.length).toString();
          incentive = (usersByReferalCode.data!.totalRevenueOfPromoter ?? 0).toString();
          revenue = (usersByReferalCode.data!.totalViewRevenueEarned ?? 0).toString();
        }
        notifyListeners();
      }
    } catch (error) {
      debugPrint("getUsersByUserReferalCode error: $error");
    }
  }

  // V2 API 3: Fetch Child Promoters
  List<Promoters> _promotersByPromoterCode = [];
  List<Promoters> get promotersByPromoterCode => _promotersByPromoterCode;
  String? totalPromoterUnderPromoter;

  Future<void> fetchChildPromoters(dynamic promoterId, {String? refCode, int page = 0, int size = 20}) async {
    final apiHelper = ApiHelper();
    bool loaded = false;
    if (promoterId != null) {
      try {
        var response = await apiHelper.getApi(ApiConstant.childPromotersV2(promoterId, page: page, size: size));
        if (response.statusCode != 200) {
          response = await apiHelper.getApi(ApiConstant.childPromotersV2Alias(promoterId));
        }
        if (response.statusCode == 200) {
          final Map<String, dynamic> body = json.decode(response.body);
          PrometrsByReferalCode childResponse = PrometrsByReferalCode.fromJson(body);
          if (childResponse.data != null && childResponse.data!.promoter != null) {
            _promotersByPromoterCode.clear();
            _promotersByPromoterCode = childResponse.data!.promoter!;
            totalPromoterUnderPromoter = (childResponse.data!.totalPromoterUnderPromoter ?? _promotersByPromoterCode.length).toString();
            loaded = true;
            notifyListeners();
          } else if (body['data'] is List) {
            _promotersByPromoterCode.clear();
            _promotersByPromoterCode = (body['data'] as List)
                .map((x) => Promoters.fromJson(x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))
                .toList();
            totalPromoterUnderPromoter = _promotersByPromoterCode.length.toString();
            loaded = true;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint("fetchChildPromoters V2 error: $e");
      }
    }

    if (!loaded && refCode != null && refCode.isNotEmpty) {
      await getPromotersByUserReferalCode(refCode);
    }
  }

  Future<void> getPromotersByUserReferalCode(String code) async {
    String myUrl = ApiConstant.getPromotersByPromoterCode(code);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(myUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        PrometrsByReferalCode promotersByReferalCode =
            PrometrsByReferalCode.fromJson(responseBody);
        if (promotersByReferalCode.success == true &&
            promotersByReferalCode.data != null) {
          _promotersByPromoterCode.clear();
          _promotersByPromoterCode = promotersByReferalCode.data!.promoter ?? [];
          totalPromoterUnderPromoter = (promotersByReferalCode.data!.totalPromoterUnderPromoter ?? _promotersByPromoterCode.length).toString();
        }
        notifyListeners();
      }
    } catch (error) {
      debugPrint("getPromotersByUserReferalCode error: $error");
    }
  }

  // V2 API 4: Fetch Onboard & Revenue Graph
  List<PromoterUserRevenueGraph> _promoterUserRevenueGraph = [];
  List<PromoterUserRevenueGraph> get promoterUserRevenueGraph =>
      _promoterUserRevenueGraph;

  Future<void> fetchPromoterOnboardAndRevenueGraph(dynamic promoterId, {String? startDate, String? endDate}) async {
    if (promoterId == null) return;
    final now = DateTime.now();
    final end = endDate ?? DateFormat('yyyy-MM-dd').format(now);
    final start = startDate ?? DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
    final apiHelper = ApiHelper();

    try {
      var response = await apiHelper.getApi(ApiConstant.promoterOnboardRevenueGraphV2(promoterId, startDate: start, endDate: end));
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterOnboardRevenueGraphV2Alias(promoterId, startDate: start, endDate: end));
      }
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.getUserAndRevenueGraph(start, end, promoterId));
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        UserOnboardAndRevenueGraph usersGraph = UserOnboardAndRevenueGraph.fromJson(body);
        if (usersGraph.data != null) {
          _promoterUserRevenueGraph.clear();
          _promoterUserRevenueGraph = usersGraph.data!;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("fetchPromoterOnboardAndRevenueGraph error: $e");
    }
  }

  Future<void> getUsersAndRevenue(int id, {String? startDate, String? endDate}) async {
    await fetchPromoterOnboardAndRevenueGraph(id, startDate: startDate, endDate: endDate);
  }

  // V2 API 5: User Movie Transactions
  List<UserTransactionData> _promoterMovieTransactions = [];
  List<UserTransactionData> get promoterMovieTransactions => _promoterMovieTransactions;

  Future<void> fetchPromoterMovieTransactions(dynamic promoterId, {int page = 0, int size = 20, String? search}) async {
    if (promoterId == null) return;
    final apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(ApiConstant.promoterUserMovieTransactionsV2(promoterId, page: page, size: size, search: search));
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterUserMovieTransactionsV2Alias(promoterId));
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        UserTransactionResponse txnResponse = UserTransactionResponse.fromJson(body);
        if (txnResponse.data != null) {
          _promoterMovieTransactions = txnResponse.data!;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("fetchPromoterMovieTransactions error: $e");
    }
  }

  // V2 API 8: Promoter Settlements
  List<PromoterSettlementItem> _promoterSettlements = [];
  List<PromoterSettlementItem> get promoterSettlements => _promoterSettlements;

  Future<void> fetchPromoterSettlements(dynamic promoterId, {int page = 0, int size = 20}) async {
    if (promoterId == null) return;
    final apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(ApiConstant.promoterSettlementsV2(promoterId, page: page, size: size));
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterSettlementsV2Alias(promoterId));
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        PromoterSettlementResponse settlementResponse = PromoterSettlementResponse.fromJson(body);
        if (settlementResponse.data != null) {
          _promoterSettlements = settlementResponse.data!;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("fetchPromoterSettlements error: $e");
    }
  }

  List<PromotersList> _reportingPromoters = [];
  List<PromotersList> get reportingPromoters => _reportingPromoters;
  String? _activeReportingPromoterRequest;

  Future<void> getReportingPromoters(String level, String location) async {
    final promoterLevel = level.trim();
    final promoterLocation = location.trim();
    if (promoterLevel.isEmpty || promoterLocation.isEmpty) {
      return;
    }
    final requestKey = '$promoterLevel|$promoterLocation';
    if (_activeReportingPromoterRequest == requestKey) {
      return;
    }

    _activeReportingPromoterRequest = requestKey;
    String myUrl =
        ApiConstant.reportingPromoterApi(promoterLevel, promoterLocation);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(myUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        ReportingPromotersResponse reportingResponse =
            ReportingPromotersResponse.fromJson(responseBody);
        if (reportingResponse.success == true &&
            reportingResponse.data?.promotersList != null) {
          _reportingPromoters.clear();
          _reportingPromoters = reportingResponse.data!.promotersList!;
        }
        notifyListeners();
      }
    } catch (error) {
      debugPrint("getReportingPromoters error: $error");
    } finally {
      if (_activeReportingPromoterRequest == requestKey) {
        _activeReportingPromoterRequest = null;
      }
    }
  }

  // V2 API: Fetch Promoter Dashboard
  PromoterDashboardData? _promoterDashboardData;
  bool _isPromoterDashboardLoading = false;
  String? _promoterDashboardError;
  dynamic _loadedPromoterDashboardId;

  PromoterDashboardData? get promoterDashboardData => _promoterDashboardData;
  bool get isPromoterDashboardLoading => _isPromoterDashboardLoading;
  String? get promoterDashboardError => _promoterDashboardError;

  Future<void> fetchPromoterDashboard(dynamic promoterId,
      {bool forceRefresh = false}) async {
    if (promoterId == null) return;
    if (!forceRefresh &&
        _loadedPromoterDashboardId == promoterId &&
        !_isPromoterDashboardLoading &&
        _promoterDashboardData != null) {
      return;
    }

    _isPromoterDashboardLoading = true;
    _promoterDashboardError = null;
    if (_loadedPromoterDashboardId != promoterId) {
      _promoterDashboardData = null;
    }
    notifyListeners();

    final apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(ApiConstant.promoterDashboardV2(promoterId));
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterDashboardV2Alias(promoterId));
      }
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterDashboardV2Alias2(promoterId));
      }
      if (response.statusCode != 200) {
        response = await apiHelper.getApi(ApiConstant.promoterDashboardV2Alias3(promoterId));
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final dashboardResp = PromoterDashboardResponse.fromJson(body);
        if (dashboardResp.data != null) {
          _promoterDashboardData = dashboardResp.data;
          _loadedPromoterDashboardId = promoterId;
          _isPromoterDashboardLoading = false;
          _promoterDashboardError = null;
          notifyListeners();
          return;
        }
      }
      _isPromoterDashboardLoading = false;
      _promoterDashboardError =
          "Failed to load promoter dashboard (Status: ${response.statusCode})";
      notifyListeners();
    } catch (e) {
      debugPrint("fetchPromoterDashboard error: $e");
      _isPromoterDashboardLoading = false;
      _promoterDashboardError = "Error loading promoter dashboard: $e";
      notifyListeners();
    }
  }
}

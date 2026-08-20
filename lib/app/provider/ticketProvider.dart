import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

import '../../data/models/request/raiseTicketRequest.dart';
import '../../data/models/response/getRaisedTicketListResponse.dart';
import '../../data/models/response/raiseTicketResponse.dart';
import '../../domain/entities/user.dart';
import '../core/constant/api_constant.dart';
import '../core/loading/app_loading_controller.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';
import '../ui/pages/help_desk_page/models/kanban_status.dart';

import '../ui/pages/help_desk_page/services/ai_task_assistant_service.dart';

class TicketProvider extends ChangeNotifier {
  List<TicketRaised> _ticketList = [];
  List<TicketRaised> get tickets => _ticketList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final Set<int> _updatingTicketIds = {};
  bool isTicketUpdating(int? ticketId) =>
      ticketId != null && _updatingTicketIds.contains(ticketId);

  // Search & Filter State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String query) {
    _searchQuery = query;
    _activeAiExplanation = null;
    notifyListeners();
  }

  TicketPriority? _priorityFilter;
  TicketPriority? get priorityFilter => _priorityFilter;
  void setPriorityFilter(TicketPriority? priority) {
    _priorityFilter = priority;
    _activeAiExplanation = null;
    notifyListeners();
  }

  KanbanStatus? _statusFilter;
  KanbanStatus? get statusFilter => _statusFilter;
  void setStatusFilter(KanbanStatus? status) {
    _statusFilter = status;
    _activeAiExplanation = null;
    notifyListeners();
  }

  String? _categoryFilter;
  String? get categoryFilter => _categoryFilter;
  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _activeAiExplanation = null;
    notifyListeners();
  }

  bool _onlyAgingFilter = false;
  bool get onlyAgingFilter => _onlyAgingFilter;
  void setOnlyAgingFilter(bool onlyAging) {
    _onlyAgingFilter = onlyAging;
    _activeAiExplanation = null;
    notifyListeners();
  }

  // User Role & Promoter Level Filter State
  String? _userRoleFilter;
  String? get userRoleFilter => _userRoleFilter;
  void setUserRoleFilter(String? role) {
    _userRoleFilter = role;
    if (role != 'PROMOTER') {
      _promoterLevelFilter = null;
    }
    _activeAiExplanation = null;
    notifyListeners();
  }

  String? _promoterLevelFilter;
  String? get promoterLevelFilter => _promoterLevelFilter;
  void setPromoterLevelFilter(String? level) {
    _promoterLevelFilter = level;
    _activeAiExplanation = null;
    notifyListeners();
  }

  // Date Range Filter State
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _activeAiExplanation = null;
    notifyListeners();
  }

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool _isCurrentUserPromoter = false;
  bool get isCurrentUserPromoter => _isCurrentUserPromoter;
  String? _currentUserPromoterLevel;
  String? get currentUserPromoterLevel => _currentUserPromoterLevel;

  Future<void> initCurrentUser() async {
    try {
      _currentUser = await LocalSharePreferences.localSharePreferences.getUser();
      if (_currentUser != null) {
        final roles = _currentUser!.role ?? [];
        _isCurrentUserPromoter = roles.any((r) => r.toLowerCase().contains('promoter'));
        if (_isCurrentUserPromoter) {
          _userRoleFilter = 'PROMOTER';
          for (final r in roles) {
            final lower = r.toLowerCase();
            if (lower.contains('national') || lower.contains('country')) {
              _currentUserPromoterLevel = 'National';
              break;
            } else if (lower.contains('state')) {
              _currentUserPromoterLevel = 'State';
              break;
            } else if (lower.contains('district')) {
              _currentUserPromoterLevel = 'District';
              break;
            } else if (lower.contains('taluka')) {
              _currentUserPromoterLevel = 'Taluka';
              break;
            }
          }
          if (_currentUserPromoterLevel != null) {
            _promoterLevelFilter = _currentUserPromoterLevel;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing user in TicketProvider: $e");
    }
  }

  String? _activeAiExplanation;
  String? get activeAiExplanation => _activeAiExplanation;

  void applyAiIntent(AiFilterIntent intent) {
    _searchQuery = intent.searchQuery ?? '';
    _priorityFilter = intent.priority;
    _statusFilter = intent.status;
    _onlyAgingFilter = intent.onlyAging ?? false;
    _userRoleFilter = intent.userRole;
    _promoterLevelFilter = intent.promoterLevel;
    _categoryFilter = null;
    _activeAiExplanation = intent.explanation;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _priorityFilter = null;
    _statusFilter = null;
    _categoryFilter = null;
    _onlyAgingFilter = false;
    _userRoleFilter = null;
    _promoterLevelFilter = null;
    _startDate = null;
    _endDate = null;
    _activeAiExplanation = null;
    notifyListeners();
  }

  // AI Focus Metrics
  int get urgentTicketsCount {
    return _ticketList.where((t) {
      if (t.isResolved == true) return false;
      final p = TicketPriority.fromString(t.priority ?? t.topic);
      return p == TicketPriority.high;
    }).length;
  }

  int get agingTicketsCount {
    return _ticketList.where((t) {
      if (t.isResolved == true) return false;
      return AiTaskAssistantService.instance.calculateAgeInDays(t.date) >= 3;
    }).length;
  }

  int get inReviewTicketsCount {
    return _ticketList.where((t) {
      if (t.isResolved == true) return false;
      final s = KanbanStatus.fromString(t.status, isResolved: t.isResolved);
      return s == KanbanStatus.inReview;
    }).length;
  }

  int get resolvedTodayCount {
    return _ticketList.where((t) {
      return t.isResolved == true;
    }).length;
  }

  List<TicketRaised> get dailyFocusPlannerList {
    final unresolved = _ticketList.where((t) => t.isResolved != true).toList();
    unresolved.sort((a, b) {
      final riskA = AiTaskAssistantService.instance.calculateRisk(a).index;
      final riskB = AiTaskAssistantService.instance.calculateRisk(b).index;
      if (riskA != riskB) {
        return riskB.compareTo(riskA); // High risk first
      }
      final ageA = AiTaskAssistantService.instance.calculateAgeInDays(a.date);
      final ageB = AiTaskAssistantService.instance.calculateAgeInDays(b.date);
      return ageB.compareTo(ageA); // Older tickets first
    });
    return unresolved;
  }

  TextEditingController topicController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String imgUrl = '';

  io.File? _imageFile;
  html.File? _webFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  io.File? get imageFile => _imageFile;
  html.File? get webFile => _webFile;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get isUploading => _isUploading;

  List<TicketRaised> get filteredTickets {
    return _ticketList.where((ticket) {
      // 1. Status Filter
      if (_statusFilter != null) {
        final s = KanbanStatus.fromString(ticket.status, isResolved: ticket.isResolved);
        if (s != _statusFilter) return false;
      }

      // 2. Only Aging Filter (> 3 days)
      if (_onlyAgingFilter) {
        if (ticket.isResolved == true) return false;
        final age = AiTaskAssistantService.instance.calculateAgeInDays(ticket.date);
        if (age < 3) return false;
      }

      // 3. Search Query Filter (Ticket ID, Topic, Description, Email, Mobile, Feedback)
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final idMatch = ticket.tickedId?.toString().contains(q) ?? false;
        final topicMatch = (ticket.topic ?? '').toLowerCase().contains(q);
        final descMatch = (ticket.description ?? '').toLowerCase().contains(q);
        final emailMatch = (ticket.email ?? '').toLowerCase().contains(q);
        final phoneMatch = (ticket.mobileNumber ?? '').toLowerCase().contains(q);
        final feedbackMatch = (ticket.feedback ?? '').toLowerCase().contains(q);
        if (!idMatch && !topicMatch && !descMatch && !emailMatch && !phoneMatch && !feedbackMatch) {
          return false;
        }
      }

      // 4. Priority Filter
      if (_priorityFilter != null) {
        final ticketPriority = TicketPriority.fromString(ticket.priority ?? ticket.topic);
        if (ticketPriority != _priorityFilter) {
          return false;
        }
      }

      // 6. User Role Filter
      if (_userRoleFilter != null && _userRoleFilter!.isNotEmpty && _userRoleFilter != 'ALL') {
        final ticketRole = resolveTicketRole(ticket);
        if (ticketRole != _userRoleFilter!.toUpperCase()) {
          return false;
        }
      }

      // 7. Promoter Level Filter
      if (_promoterLevelFilter != null && _promoterLevelFilter!.isNotEmpty && _promoterLevelFilter != 'ALL') {
        final ticketLevel = resolveTicketPromoterLevel(ticket);
        if (ticketLevel == null || ticketLevel.toLowerCase() != _promoterLevelFilter!.toLowerCase()) {
          return false;
        }
      }

      // 8. Date Range Filter
      if (_startDate != null || _endDate != null) {
        if (ticket.date == null || ticket.date == 0) {
          return false;
        }
        final ticketDate = DateTime.fromMillisecondsSinceEpoch(ticket.date!).toLocal();
        if (_startDate != null) {
          final startOfStartDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0, 0);
          if (ticketDate.isBefore(startOfStartDay)) {
            return false;
          }
        }
        if (_endDate != null) {
          final endOfEndDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59, 999);
          if (ticketDate.isAfter(endOfEndDay)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  /// Resolves the user role for a ticket (PROMOTER, ADMIN, MEDIA_HOUSE, USER)
  static String resolveTicketRole(TicketRaised ticket) {
    final roles = ticket.user?.role ?? [];
    for (final r in roles) {
      final upper = r.toUpperCase();
      if (upper.contains('PROMOTER')) return 'PROMOTER';
      if (upper.contains('ADMIN')) return 'ADMIN';
      if (upper.contains('MEDIA') || upper.contains('HOUSE') || upper.contains('CREATOR')) return 'MEDIA_HOUSE';
    }
    if ((ticket.category ?? '').toUpperCase().contains('PROMOTER') ||
        (ticket.topic ?? '').toUpperCase().contains('PROMOTER') ||
        (ticket.assignedTo ?? '').toUpperCase().contains('PROMOTER')) {
      return 'PROMOTER';
    }
    if ((ticket.category ?? '').toUpperCase().contains('ADMIN') ||
        (ticket.topic ?? '').toUpperCase().contains('ADMIN')) {
      return 'ADMIN';
    }
    if ((ticket.category ?? '').toUpperCase().contains('MEDIA') ||
        (ticket.topic ?? '').toUpperCase().contains('MEDIA')) {
      return 'MEDIA_HOUSE';
    }
    return 'USER';
  }

  /// Resolves promoter level for a ticket if applicable (National, State, District, Taluka)
  static String? resolveTicketPromoterLevel(TicketRaised ticket) {
    final roles = ticket.user?.role ?? [];
    for (final r in roles) {
      final lower = r.toLowerCase();
      if (lower.contains('national') || lower.contains('country')) return 'National';
      if (lower.contains('state')) return 'State';
      if (lower.contains('district')) return 'District';
      if (lower.contains('taluka')) return 'Taluka';
    }

    final searchScope = [
      ticket.category ?? '',
      ticket.topic ?? '',
      ticket.description ?? '',
      ticket.feedback ?? '',
      ticket.user?.location?.state ?? '',
      ticket.user?.location?.district ?? '',
      ticket.user?.location?.taluka ?? '',
    ].join(' ').toLowerCase();

    if (searchScope.contains('national level') || searchScope.contains('country level') || searchScope.contains('national promoter') || searchScope.contains('national')) {
      return 'National';
    }
    if (searchScope.contains('state level') || searchScope.contains('state promoter') || searchScope.contains('state')) {
      return 'State';
    }
    if (searchScope.contains('district level') || searchScope.contains('district promoter') || searchScope.contains('district')) {
      return 'District';
    }
    if (searchScope.contains('taluka level') || searchScope.contains('taluka promoter') || searchScope.contains('taluka')) {
      return 'Taluka';
    }

    return null;
  }

  List<TicketRaised> getTicketsForStatus(KanbanStatus status) {
    return filteredTickets.where((ticket) {
      final ticketStatus = KanbanStatus.fromString(ticket.status, isResolved: ticket.isResolved);
      return ticketStatus == status;
    }).toList();
  }

  int getCountForStatus(KanbanStatus status) {
    return _ticketList.where((ticket) {
      final ticketStatus = KanbanStatus.fromString(ticket.status, isResolved: ticket.isResolved);
      return ticketStatus == status;
    }).length;
  }

  Future<Map<String, Object>> raiseTicket() async {
    User? user = await LocalSharePreferences.localSharePreferences.getUser();
    DateTime now = DateTime.now().toUtc();
    String formattedDate = now.toIso8601String();
    String apiUrl = ApiConstant.raiseTicket;
    RaiseTicketRequest raiseTicketRequest = RaiseTicketRequest();
    raiseTicketRequest.userId = user?.id ?? 0;
    raiseTicketRequest.description = descController.text;
    raiseTicketRequest.isResolved = false;
    raiseTicketRequest.mobileNumber = user?.mobileNumber ?? '';
    raiseTicketRequest.email = user?.emailId ?? '';
    raiseTicketRequest.image = imgUrl;
    raiseTicketRequest.date = formattedDate;
    raiseTicketRequest.feedback = feedbackController.text;
    raiseTicketRequest.tickedId = 0;
    raiseTicketRequest.topic = topicController.text;

    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.postApiWithBody(apiUrl, raiseTicketRequest.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        RaiseTicketResponse raiseTicketResponse = RaiseTicketResponse.fromJson(responseBody);
        if (raiseTicketResponse.data != null) {
          if (raiseTicketResponse.data?.ticketRaised != null) {
            _ticketList.insert(0, raiseTicketResponse.data!.ticketRaised!);
            imgUrl = '';
            _uploadedImageUrl = '';
            topicController.clear();
            descController.clear();
            feedbackController.clear();
            notifyListeners();
            return {'success': true, 'message': raiseTicketResponse.message ?? 'Ticket raised successfully'};
          } else {
            debugPrint("Empty data: ${raiseTicketResponse.message}");
            return {'success': false, 'message': raiseTicketResponse.message ?? 'No data returned'};
          }
        } else {
          debugPrint("Error: ${raiseTicketResponse.message}");
          return {'success': false, 'message': raiseTicketResponse.message ?? 'Error in response'};
        }
      } else {
        return {'success': false, 'message': 'Failed to add ticket. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {'success': false, 'message': 'An error occurred while adding ticket: $error'};
    }
  }

  Future<Map<String, Object>> updateTicketStatus(
    TicketRaised ticket,
    KanbanStatus newStatus, {
    String? resolutionNotes,
  }) async {
    final ticketId = ticket.tickedId;
    if (ticketId == null) {
      return {'success': false, 'message': 'Invalid ticket ID'};
    }

    if (_updatingTicketIds.contains(ticketId)) {
      return {'success': false, 'message': 'Update already in progress for this ticket'};
    }

    final originalIndex = _ticketList.indexWhere((t) => t.tickedId == ticketId);
    if (originalIndex == -1) {
      return {'success': false, 'message': 'Ticket not found'};
    }
    final previousTicket = _ticketList[originalIndex];

    final isResolved = newStatus == KanbanStatus.done;
    final updatedFeedback = resolutionNotes ?? ticket.feedback ?? '';

    final optimisticallyUpdated = previousTicket.copyWith(
      isResolved: isResolved,
      status: newStatus.code,
      feedback: updatedFeedback,
    );

    _updatingTicketIds.add(ticketId);
    _ticketList[originalIndex] = optimisticallyUpdated;
    notifyListeners();

    final result = await updateRaiseTicket(
      optimisticallyUpdated,
      isResolved,
      updatedFeedback,
      skipFetch: true,
    );

    _updatingTicketIds.remove(ticketId);

    if (result['success'] == true) {
      notifyListeners();
      return result;
    } else {
      final currentIndex = _ticketList.indexWhere((t) => t.tickedId == ticketId);
      if (currentIndex != -1) {
        _ticketList[currentIndex] = previousTicket;
      }
      notifyListeners();
      return result;
    }
  }

  Future<Map<String, Object>> sendReplyToTicket(
    TicketRaised ticket,
    String replyMessage, {
    bool? markResolved,
  }) async {
    final trimmed = replyMessage.trim();
    if (trimmed.isEmpty) {
      return {'success': false, 'message': 'Reply message cannot be empty'};
    }

    final isResolved = markResolved ?? ticket.isResolved ?? false;
    final newStatus = isResolved ? KanbanStatus.done : (ticket.status != null ? KanbanStatus.fromString(ticket.status) : KanbanStatus.todo);

    return updateTicketStatus(
      ticket,
      newStatus,
      resolutionNotes: trimmed,
    );
  }

  Future<Map<String, Object>> reopenTicket(
    TicketRaised ticket, {
    String? reopenReason,
  }) async {
    final note = reopenReason?.trim().isNotEmpty == true
        ? reopenReason!.trim()
        : (ticket.feedback ?? 'Reopened by Admin');

    return updateTicketStatus(
      ticket,
      KanbanStatus.todo,
      resolutionNotes: note,
    );
  }

  Future<Map<String, Object>> updateRaiseTicket(
    TicketRaised ticketRaised,
    bool isResolved,
    String feedback, {
    bool skipFetch = false,
  }) async {
    final ticketId = ticketRaised.tickedId;
    if (ticketId == null) {
      return {'success': false, 'message': 'Ticket ID is required'};
    }

    DateTime now = DateTime.now().toUtc();
    String formattedDate = now.toIso8601String();
    String apiUrl = ApiConstant.updateTicket(ticketId);

    RaiseTicketRequest raiseTicketRequest = RaiseTicketRequest();
    raiseTicketRequest.userId = ticketRaised.userId ?? 0;
    raiseTicketRequest.description = ticketRaised.description;
    raiseTicketRequest.isResolved = isResolved;
    raiseTicketRequest.mobileNumber = ticketRaised.mobileNumber;
    raiseTicketRequest.email = ticketRaised.email;
    raiseTicketRequest.image = ticketRaised.image;
    raiseTicketRequest.date = formattedDate;
    raiseTicketRequest.feedback = feedback;
    raiseTicketRequest.tickedId = ticketId;
    raiseTicketRequest.topic = ticketRaised.topic;

    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.putApiWithBody(apiUrl, raiseTicketRequest.toJson());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        RaiseTicketResponse raiseTicketResponse = RaiseTicketResponse.fromJson(responseBody);
        if (raiseTicketResponse.data != null) {
          if (!skipFetch) {
            await getAllRaisedTicket();
          }
          return {'success': true, 'message': raiseTicketResponse.message ?? 'Ticket updated successfully'};
        } else {
          return {'success': false, 'message': raiseTicketResponse.message ?? 'Error in response'};
        }
      } else {
        return {'success': false, 'message': 'Update failed with status: ${response.statusCode}'};
      }
    } catch (error) {
      debugPrint("Error updating ticket: $error");
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<Map<String, Object>> getAllRaisedTicket() async {
    String apiUrl = ApiConstant.getRaisedTicket;
    ApiHelper apiHelper = ApiHelper();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var response = await apiHelper.getApi(apiUrl);
      _isLoading = false;
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetRaiseTicketListResponse getRaiseTicketListResponse = GetRaiseTicketListResponse.fromJson(responseBody);
        if (getRaiseTicketListResponse.data != null) {
          _ticketList.clear();
          if (getRaiseTicketListResponse.data!.ticketRaised != null) {
            _ticketList.addAll(getRaiseTicketListResponse.data!.ticketRaised!);
          }
          notifyListeners();
          return {'success': true, 'message': getRaiseTicketListResponse.message ?? 'Success'};
        } else {
          _error = getRaiseTicketListResponse.message ?? 'No data returned';
          notifyListeners();
          return {'success': false, 'message': _error!};
        }
      } else {
        _error = 'Failed to load tickets (Status: ${response.statusCode})';
        notifyListeners();
        return {'success': false, 'message': _error!};
      }
    } catch (error) {
      _isLoading = false;
      _error = '$error';
      debugPrint("Error fetching tickets: $error");
      notifyListeners();
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<Map<String, Object>> getAllRaisedTicketByFlag(bool isResolved) async {
    String apiUrl = ApiConstant.getRaisedTicketByFlag(isResolved);
    ApiHelper apiHelper = ApiHelper();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var response = await apiHelper.getApi(apiUrl);
      _isLoading = false;
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetRaiseTicketListResponse getRaiseTicketListResponse = GetRaiseTicketListResponse.fromJson(responseBody);
        if (getRaiseTicketListResponse.data != null) {
          _ticketList.clear();
          if (getRaiseTicketListResponse.data!.ticketRaised != null) {
            _ticketList.addAll(getRaiseTicketListResponse.data!.ticketRaised!);
          }
          notifyListeners();
          return {'success': true, 'message': getRaiseTicketListResponse.message ?? 'Success'};
        } else {
          _error = getRaiseTicketListResponse.message ?? 'No data returned';
          notifyListeners();
          return {'success': false, 'message': _error!};
        }
      } else {
        _error = 'Failed to load tickets (Status: ${response.statusCode})';
        notifyListeners();
        return {'success': false, 'message': _error!};
      }
    } catch (error) {
      _isLoading = false;
      _error = '$error';
      debugPrint("Error fetching tickets by flag: $error");
      notifyListeners();
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  /// Searches and filters tickets using the backend API endpoint when available,
  /// with automatic fallback to full ticket fetch and client-side filtering.
  Future<Map<String, Object>> searchAndFilterTicketsFromApi({
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    String? role,
    String? level,
    bool? isResolved,
    String? status,
    String? priority,
  }) async {
    final start = startDate ?? _startDate;
    final end = endDate ?? _endDate;

    final startStr = start != null
        ? "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}"
        : null;
    final endStr = end != null
        ? "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}"
        : null;

    final apiUrl = ApiConstant.searchAndFilterTickets(
      keyword: keyword ?? _searchQuery,
      startDate: startStr,
      endDate: endStr,
      role: role ?? _userRoleFilter,
      level: level ?? _promoterLevelFilter,
      isResolved: isResolved,
      status: status ?? _statusFilter?.code,
      priority: priority ?? _priorityFilter?.label.toUpperCase(),
    );

    ApiHelper apiHelper = ApiHelper();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var response = await apiHelper.getApi(apiUrl);
      _isLoading = false;
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetRaiseTicketListResponse getRaiseTicketListResponse =
            GetRaiseTicketListResponse.fromJson(responseBody);
        if (getRaiseTicketListResponse.data != null) {
          _ticketList.clear();
          if (getRaiseTicketListResponse.data!.ticketRaised != null) {
            _ticketList.addAll(getRaiseTicketListResponse.data!.ticketRaised!);
          }
          notifyListeners();
          return {'success': true, 'message': getRaiseTicketListResponse.message ?? 'Success'};
        }
      }
      // If endpoint returns 404 or non-200 (backend API not yet deployed), gracefully load all tickets
      debugPrint("searchAndFilter API returned ${response.statusCode}, falling back to getAllRaisedTicket");
      return await getAllRaisedTicket();
    } catch (error) {
      debugPrint("API search endpoint not available ($error), falling back to getAllRaisedTicket");
      return await getAllRaisedTicket();
    }
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          _webFile = uploadInput.files!.first;
          await uploadImage();
          notifyListeners();
        }
      });
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageFile = io.File(pickedFile.path);
        if (kIsWeb && _webFile != null) {
          await uploadImage();
        }
        notifyListeners();
      }
    }
  }

  Future<void> uploadImage() async {
    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webFile == null)) {
      return;
    }

    final url = Uri.parse(ApiConstant.uploadImg);
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb && _webFile != null) {
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final byteData = reader.result as List<int>;
        final multipartFile = http.MultipartFile.fromBytes(
          'profilePicture',
          byteData,
          filename: _webFile!.name,
        );

        request.files.add(multipartFile);
        final response = await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          imgUrl = _uploadedImageUrl!;
          notifyListeners();
        }
      } else if (!kIsWeb && _imageFile != null) {
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          _imageFile!.path,
        ));
        final response = await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          imgUrl = _uploadedImageUrl!;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<Map<String, Object>> deleteQuery(TicketRaised ticketList) async {
    final ticketId = ticketList.tickedId;
    if (ticketId == null) {
      return {'success': false, 'message': 'Invalid ticket ID'};
    }
    String apiUrl = ApiConstant.deleteTicket(ticketId);
    ApiHelper apiHelper = ApiHelper();

    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200) {
        _ticketList.removeWhere((t) => t.tickedId == ticketId);
        notifyListeners();
        return {'success': true, 'message': "Ticket Deleted Successfully"};
      } else {
        return {'success': false, 'message': "Failed to delete ticket (Status: ${response.statusCode})"};
      }
    } catch (error) {
      debugPrint("Error: $error");
      return {'success': false, 'message': 'An error occurred while removing ticket: $error'};
    }
  }

  Future<Map<String, Object>> toggleResolvedStatus(TicketRaised ticketRaised, bool newStatus) {
    return updateRaiseTicket(ticketRaised, newStatus, ticketRaised.feedback ?? '');
  }
}

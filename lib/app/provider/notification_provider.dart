import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/loading/app_loading_controller.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/response/notification_model.dart';
import 'package:admin_ott/data/repositories/notification_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  final List<NotificationModel> _notifications = [];

  bool isLoading = false;
  bool isActionLoading = false;
  bool isSending = false;
  bool isUploadingAttachment = false;
  String? error;
  String searchQuery = '';
  String selectedType = 'All';
  String selectedStatus = 'All';
  DateTime? startDate;
  DateTime? endDate;
  int currentPage = 0;
  int rowsPerPage = 20;
  int _serverTotalElements = 0;
  int _serverTotalPages = 1;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  List<String> get notificationTypes {
    final values = _notifications.map((item) => item.type).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<String> get statuses => const ['All', 'Sent', 'Pending', 'Failed'];

  List<NotificationModel> get filteredNotifications {
    final list = _notifications.where((item) {
      final matchesType = selectedType == 'All' || item.type == selectedType;
      final matchesStatus =
          selectedStatus == 'All' || item.status == selectedStatus;
      return item.matchesSearch(searchQuery) &&
          matchesType &&
          matchesStatus &&
          item.isWithin(startDate, endDate);
    }).toList()
      ..sort((a, b) {
        final first = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final second = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return second.compareTo(first);
      });

    return list;
  }

  List<NotificationModel> get paginatedNotifications {
    final filtered = filteredNotifications;
    if (!_hasClientFilters) {
      return filtered;
    }

    final start = currentPage * rowsPerPage;
    if (start >= filtered.length) return const [];
    final end = (start + rowsPerPage).clamp(0, filtered.length).toInt();
    return filtered.sublist(start, end);
  }

  int get totalPages {
    if (!_hasClientFilters) {
      return _serverTotalPages <= 0 ? 1 : _serverTotalPages;
    }

    final total = filteredNotifications.length;
    if (total == 0) {
      return 1;
    }
    return (total / rowsPerPage).ceil();
  }

  int get totalElements =>
      _hasClientFilters ? filteredNotifications.length : _serverTotalElements;

  bool get _hasClientFilters =>
      searchQuery.trim().isNotEmpty ||
      selectedType != 'All' ||
      selectedStatus != 'All' ||
      startDate != null ||
      endDate != null;

  Future<void> fetchNotifications() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final data = await _repository.getNotifications(
        pageNo: currentPage,
        pageSize: rowsPerPage,
      );
      _notifications
        ..clear()
        ..addAll(data.notifications);
      _serverTotalElements = data.totalElements;
      _serverTotalPages = data.totalPages;
      _normalizePage();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() => fetchNotifications();

  void setSearchQuery(String value) {
    searchQuery = value;
    currentPage = 0;
    notifyListeners();
  }

  void setType(String value) {
    selectedType = value;
    currentPage = 0;
    notifyListeners();
  }

  void setStatus(String value) {
    selectedStatus = value;
    currentPage = 0;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    startDate = range?.start;
    endDate = range?.end;
    currentPage = 0;
    notifyListeners();
  }

  void clearFilters() {
    searchQuery = '';
    selectedType = 'All';
    selectedStatus = 'All';
    startDate = null;
    endDate = null;
    currentPage = 0;
    notifyListeners();
  }

  void setRowsPerPage(int value) {
    rowsPerPage = value;
    currentPage = 0;
    notifyListeners();
    fetchNotifications();
  }

  void goToPage(int page) {
    currentPage = page.clamp(0, totalPages - 1).toInt();
    notifyListeners();
    if (!_hasClientFilters) {
      fetchNotifications();
    }
  }

  Future<bool> deleteNotification(String id) async {
    return _runAction(() async {
      final message = await _repository.deleteNotification(id);
      CustomToast.show(message);
      await fetchNotifications();
    });
  }

  Future<bool> resendNotification(String id) async {
    return _runAction(() async {
      final message = await _repository.resendNotification(id);
      CustomToast.show(message);
      await fetchNotifications();
    });
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    required String recipientType,
    required Set<String> notificationTypes,
    required String priority,
    String? emailSubject,
    String? attachmentUrl,
    DateTime? scheduledDateTime,
  }) async {
    if (title.trim().isEmpty || message.trim().isEmpty) {
      CustomToast.show('Title and message are required.', isSuccess: false);
      return false;
    }
    if (notificationTypes.isEmpty) {
      CustomToast.show('Select at least one delivery channel.',
          isSuccess: false);
      return false;
    }

    final body = {
      'notificationTitle': title.trim(),
      'messageDescription': message.trim(),
      'emailSubject': emailSubject == null || emailSubject.trim().isEmpty
          ? null
          : emailSubject.trim(),
      'attachmentUrl': attachmentUrl == null || attachmentUrl.trim().isEmpty
          ? null
          : attachmentUrl.trim(),
      'recipientType': recipientType,
      'notificationType': notificationTypes.join(','),
      'priority': priority,
      'sentBy': 'admin',
      'scheduledDateTime': scheduledDateTime?.toUtc().toIso8601String(),
    };

    try {
      isSending = true;
      notifyListeners();
      final resultMessage = await _repository.sendNotification(body);
      CustomToast.show(resultMessage);
      await fetchNotifications();
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      CustomToast.show(errorMessage, isSuccess: false);
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<String?> uploadAttachment(PlatformFile file) async {
    try {
      isUploadingAttachment = true;
      notifyListeners();

      final request =
          http.MultipartRequest('POST', Uri.parse(ApiConstant.uploadImg));
      request.headers.addAll(await ApiHelper().multipartHeaders());

      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        request.files
            .add(await http.MultipartFile.fromPath('file', file.path!));
      } else {
        CustomToast.show('Unable to read selected file.', isSuccess: false);
        return null;
      }

      final response =
          await AppLoadingController.trackFuture(() => request.send());
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        CustomToast.show('Failed to upload attachment.', isSuccess: false);
        return null;
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is String) return decoded;
      if (decoded is Map<String, dynamic>) {
        return (decoded['url'] ??
                decoded['fileUrl'] ??
                decoded['data'] ??
                decoded['message'])
            ?.toString();
      }
      return responseBody;
    } catch (e) {
      CustomToast.show('Failed to upload attachment.', isSuccess: false);
      return null;
    } finally {
      isUploadingAttachment = false;
      notifyListeners();
    }
  }

  Future<bool> _runAction(Future<void> Function() operation) async {
    try {
      isActionLoading = true;
      notifyListeners();
      await operation();
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      CustomToast.show(message, isSuccess: false);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  void _normalizePage() {
    if (currentPage > totalPages - 1) {
      currentPage = totalPages - 1;
    }
  }
}

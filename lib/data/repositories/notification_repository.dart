import 'package:admin_ott/data/models/response/notification_model.dart';
import 'package:admin_ott/data/services/notification_api_service.dart';

class NotificationRepository {
  NotificationRepository({NotificationApiService? service})
      : _service = service ?? NotificationApiService();

  final NotificationApiService _service;

  Future<NotificationPageResult> getNotifications({
    required int pageNo,
    required int pageSize,
  }) async {
    final response = await _service.getNotifications(
      pageNo: pageNo,
      pageSize: pageSize,
    );
    return NotificationPageResult.fromJson(response);
  }

  Future<String> deleteNotification(String id) async {
    final response = await _service.deleteNotification(id);
    if (!notificationResponseSuccess(response)) {
      throw Exception(
        notificationResponseMessage(response, 'Failed to delete notification'),
      );
    }
    return notificationResponseMessage(
      response,
      'Notification deleted successfully',
    );
  }

  Future<String> resendNotification(String id) async {
    final response = await _service.resendNotification(id);
    if (!notificationResponseSuccess(response)) {
      throw Exception(
        notificationResponseMessage(response, 'Failed to resend notification'),
      );
    }
    return notificationResponseMessage(
      response,
      'Notification resent successfully',
    );
  }

  Future<String> sendNotification(Map<String, dynamic> body) async {
    final response = await _service.sendNotification(body);
    if (!notificationResponseSuccess(response)) {
      throw Exception(
        notificationResponseMessage(response, 'Failed to send notification'),
      );
    }
    return notificationResponseMessage(
      response,
      'Notification sent successfully',
    );
  }
}

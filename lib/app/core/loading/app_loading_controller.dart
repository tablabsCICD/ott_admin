import 'package:flutter/foundation.dart';

class AppLoadingController {
  AppLoadingController._();

  static final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  static int _pendingRequests = 0;

  static Future<T> trackFuture<T>(Future<T> Function() operation) async {
    begin();
    try {
      return await operation();
    } finally {
      end();
    }
  }

  static void begin() {
    _pendingRequests++;
    if (!isLoading.value) {
      isLoading.value = true;
    }
  }

  static void end() {
    if (_pendingRequests > 0) {
      _pendingRequests--;
    }
    if (_pendingRequests == 0 && isLoading.value) {
      isLoading.value = false;
    }
  }
}

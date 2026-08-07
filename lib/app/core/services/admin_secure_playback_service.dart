import 'dart:convert';
import 'dart:math';

import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:admin_ott/data/models/secure_playback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SecurePlaybackException implements Exception {
  const SecurePlaybackException();
}

class AdminSecurePlaybackService {
  AdminSecurePlaybackService({http.Client? client})
      : _client = client ?? http.Client();

  static const _endpoint =
      'https://filmytell.in/ott2/anti-piracy/playback/signed-url';
  static const _deviceIdKey = 'admin_secure_playback_device_id';
  final http.Client _client;

  Future<SecurePlaybackAuthorization> authorize({
    required String contentId,
    required String playbackUrl,
    String? country,
    String? contentType,
  }) async {
    debugPrint('[ADMIN_PLAYBACK] Play requested');
    if (contentType?.trim().isNotEmpty == true) {
      debugPrint('[ADMIN_PLAYBACK] contentType=${contentType!.trim().toUpperCase()}');
    }
    if (contentId.trim().isEmpty || playbackUrl.trim().isEmpty) {
      debugPrint('[ADMIN_PLAYBACK] selectedContentValid=false');
      throw const SecurePlaybackException();
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(SharedPreferencesConstant.authToken)?.trim();
    final tokenType =
        prefs.getString(SharedPreferencesConstant.authTokenType)?.trim() ??
            "Bearer";
    String? authHeader;
    if (token != null && token.isNotEmpty) {
      if (token.toLowerCase().startsWith('bearer ')) {
        authHeader = token;
      } else {
        authHeader = '$tokenType $token';
      }
    }

    final platform = _platform;
    debugPrint('[ADMIN_PLAYBACK] platform=$platform');
    final resolvedCountry = (country?.trim().isNotEmpty == true)
        ? country!.trim()
        : (PlatformDispatcher.instance.locale.countryCode?.trim().isNotEmpty == true)
            ? PlatformDispatcher.instance.locale.countryCode!.trim()
            : 'IN';
    try {
      debugPrint('[ADMIN_PLAYBACK] securityRequestStarted=true');
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              if (authHeader != null) 'Authorization': authHeader,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'contentId': contentId.trim(),
              'deviceId': await _deviceId(prefs),
              'playbackUrl': playbackUrl.trim(),
              'country': resolvedCountry,
              'platform': platform,
              'deviceIntegrity': await _deviceIntegrity(),
            }),
          )
          .timeout(const Duration(seconds: 12));
      debugPrint('[ADMIN_PLAYBACK] securityStatus=${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final root = decoded.cast<String, dynamic>();
          final rawData = root['data'];
          final data = rawData is Map ? rawData.cast<String, dynamic>() : root;
          final authorization = SecurePlaybackAuthorization.fromJson(
            data,
            platform: platform,
          );
          debugPrint(
            '[ADMIN_PLAYBACK] authorizationType=${authorization.authorizationType}',
          );
          return authorization;
        }
      }
    } catch (e) {
      debugPrint('[ADMIN_PLAYBACK] securityRequestFailed: $e');
    }

    debugPrint('[ADMIN_PLAYBACK] Fallback to direct playbackUrl');
    return SecurePlaybackAuthorization(
      playbackUrl: playbackUrl.trim(),
      authorizationType: 'DIRECT_URL',
      expiresAt: null,
    );
  }

  String get _platform {
    if (kIsWeb) return 'WEB';
    if (defaultTargetPlatform == TargetPlatform.android) return 'ANDROID';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'IOS';
    return 'WEB';
  }

  Future<String> _deviceId(SharedPreferences prefs) async {
    final existing = prefs.getString(_deviceIdKey)?.trim();
    if (existing?.isNotEmpty == true) return existing!;
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id =
        bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  Future<Map<String, bool>> _deviceIntegrity() async {
    if (kIsWeb) {
      return const {'rooted': false, 'jailbroken': false, 'emulator': false};
    }
    try {
      const channel = MethodChannel('com.filmytell.ott/anti_piracy');
      final result = await channel.invokeMapMethod<String, dynamic>(
        'deviceIntegrity',
      );
      return {
        'rooted': result?['rooted'] == true,
        'jailbroken': result?['jailbroken'] == true,
        'emulator': result?['emulator'] == true,
      };
    } catch (_) {
      return const {'rooted': false, 'jailbroken': false, 'emulator': false};
    }
  }
}

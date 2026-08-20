import 'dart:convert';

import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:admin_ott/app/core/services/admin_secure_playback_service.dart';
import 'package:admin_ott/data/models/secure_playback.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('signed playback request uses admin token and omits authorizationType',
      () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesConstant.authToken: 'admin-token',
    });
    late Map<String, dynamic> requestBody;
    final client = MockClient((request) async {
      expect(request.url.path, '/ott/anti-piracy/playback/signed-url');
      expect(request.headers['authorization'], 'Bearer admin-token');
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      final android = requestBody['platform'] == 'ANDROID';
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'playbackUrl': 'https://media.example.test/master.m3u8?redacted',
            'authorizationType':
                android ? 'CLOUDFRONT_SIGNED_COOKIES' : 'CLOUDFRONT_SIGNED_URL',
            if (android)
              'cookieHeader': 'CloudFront-Policy=x; CloudFront-Signature=y',
          },
        }),
        200,
      );
    });

    await AdminSecurePlaybackService(client: client).authorize(
      contentId: '42',
      playbackUrl: 'https://origin.example.test/master.m3u8',
    );

    expect(requestBody['contentId'], '42');
    expect(requestBody['authorizationType'], isNull);
    expect(requestBody['deviceId'], isNotEmpty);
    expect(requestBody['country'], isA<String>());
    expect(requestBody['platform'], isIn(['ANDROID', 'IOS', 'WEB']));
    expect(requestBody['deviceIntegrity'], {
      'rooted': false,
      'jailbroken': false,
      'emulator': false,
    });
  });

  test('Android cookie authorization creates a Cookie media header', () {
    final authorization = SecurePlaybackAuthorization.fromJson({
      'playbackUrl': 'https://media.example.test/master.m3u8',
      'authorizationType': 'CLOUDFRONT_SIGNED_COOKIES',
      'cookieHeader': 'CloudFront-Policy=x; CloudFront-Signature=y',
    }, platform: 'ANDROID');

    expect(authorization.headers.keys, ['Cookie']);
  });

  test('Web rejects signed-cookie authorization', () {
    expect(
      () => SecurePlaybackAuthorization.fromJson({
        'playbackUrl': 'https://media.example.test/master.m3u8',
        'authorizationType': 'CLOUDFRONT_SIGNED_COOKIES',
        'cookieHeader': 'CloudFront-Policy=x; CloudFront-Signature=y',
      }, platform: 'WEB'),
      throwsFormatException,
    );
  });

  test('supported automatic tracks are selected without selector state', () {
    final authorization = SecurePlaybackAuthorization.fromJson({
      'playbackUrl': 'https://media.example.test/master.m3u8',
      'authorizationType': 'CLOUDFRONT_SIGNED_URL',
      'audioTracks': [
        {
          'url': 'https://media.example.test/audio.m3u8',
          'type': 'hls',
          'format': 'm3u8',
        }
      ],
      'subtitleTracks': [
        {
          'url': 'https://media.example.test/subtitle.vtt',
          'format': 'vtt',
        }
      ],
    }, platform: 'WEB');

    expect(authorization.audioTrackUrl, endsWith('audio.m3u8'));
    expect(authorization.subtitleTrackUrl, endsWith('subtitle.vtt'));
  });

  test('parses sessionId and handles null audio/subtitle track lists safely',
      () {
    final authorization = SecurePlaybackAuthorization.fromJson({
      'playbackUrl': 'https://media.example.test/master.m3u8',
      'authorizationType': 'CLOUDFRONT_SIGNED_URL',
      'sessionId': 'sess-12345',
      'audioTracks': null,
      'subtitleTracks': null,
    }, platform: 'WEB');

    expect(authorization.sessionId, 'sess-12345');
    expect(authorization.audioTrackUrl, isNull);
    expect(authorization.subtitleTrackUrl, isNull);
  });

  test('authorize accepts optional contentType and resolves country code',
      () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesConstant.authToken: 'admin-token',
    });
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'playbackUrl': 'https://media.example.test/master.m3u8',
            'authorizationType': 'CLOUDFRONT_SIGNED_COOKIES',
            'cookieHeader': 'CloudFront-Policy=x; CloudFront-Signature=y',
          },
        }),
        200,
      );
    });

    final auth = await AdminSecurePlaybackService(client: client).authorize(
      contentId: 'ep-99',
      playbackUrl: 'https://origin.example.test/master.m3u8',
      contentType: 'SERIES_EPISODE',
      country: 'IN',
    );

    expect(auth.headers['Cookie'], isNotEmpty);
    expect(auth.authorizationType, 'CLOUDFRONT_SIGNED_COOKIES');
  });
}

class SecurePlaybackAuthorization {
  const SecurePlaybackAuthorization({
    required this.playbackUrl,
    required this.authorizationType,
    required this.expiresAt,
    this.cookieHeader,
    this.sessionId,
    this.audioTrackUrl,
    this.subtitleTrackUrl,
  });

  final String playbackUrl;
  final String authorizationType;
  final DateTime? expiresAt;
  final String? cookieHeader;
  final String? sessionId;
  final String? audioTrackUrl;
  final String? subtitleTrackUrl;

  Map<String, String> get headers =>
      authorizationType == 'CLOUDFRONT_SIGNED_COOKIES' &&
              cookieHeader?.isNotEmpty == true
          ? {'Cookie': cookieHeader!}
          : const {};

  factory SecurePlaybackAuthorization.fromJson(
    Map<String, dynamic> json, {
    required String platform,
  }) {
    final url = (json['playbackUrl'] ?? json['signedUrl'] ?? json['url'] ?? '')
        .toString()
        .trim();
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      throw const FormatException('Invalid playback response');
    }
    final cookie = (json['cookieHeader'] ?? '').toString().trim();
    final session = (json['sessionId'] ?? '').toString().trim();
    final type = (json['authorizationType'] ?? '').toString().trim().isNotEmpty
        ? json['authorizationType'].toString().trim().toUpperCase()
        : cookie.isNotEmpty
            ? 'CLOUDFRONT_SIGNED_COOKIES'
            : 'CLOUDFRONT_SIGNED_URL';
    if (type == 'CLOUDFRONT_SIGNED_COOKIES' &&
        (cookie.isEmpty || cookie.contains(RegExp(r'[\r\n]')))) {
      throw const FormatException('Missing playback authorization');
    }
    final rawEpoch = json['expiresAtEpochSeconds'];
    final epoch = rawEpoch is num
        ? rawEpoch.toInt()
        : int.tryParse(rawEpoch?.toString() ?? '');
    final parsedDate = DateTime.tryParse((json['expiresAt'] ?? '').toString());
    return SecurePlaybackAuthorization(
      playbackUrl: url,
      authorizationType: type,
      cookieHeader: cookie.isEmpty ? null : cookie,
      sessionId: session.isEmpty ? null : session,
      expiresAt: epoch != null && epoch > 0
          ? DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true)
          : parsedDate?.toUtc(),
      audioTrackUrl: _firstTrackUrl(json['audioTracks'], audio: true),
      subtitleTrackUrl: _firstTrackUrl(json['subtitleTracks'], audio: false),
    );
  }
}

String? _firstTrackUrl(dynamic value, {required bool audio}) {
  if (value is! List) return null;
  for (final item in value.whereType<Map>()) {
    final url = (item['url'] ?? '').toString().trim();
    final type = (item['type'] ?? '').toString().toLowerCase();
    final format = (item['format'] ?? '').toString().toLowerCase();
    final supported = audio
        ? type == 'hls' || format == 'm3u8'
        : format == 'vtt' || Uri.tryParse(url)?.path.endsWith('.vtt') == true;
    if (url.isNotEmpty && supported) return url;
  }
  return null;
}

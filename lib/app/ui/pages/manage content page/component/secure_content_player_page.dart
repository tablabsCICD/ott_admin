import 'package:admin_ott/app/core/services/admin_secure_playback_service.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/app/widgets/ott_media_player.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class SecureContentPlayerPage extends StatefulWidget {
  const SecureContentPlayerPage({
    super.key,
    required this.contentId,
    required this.playbackUrl,
    this.contentType,
  });

  final String contentId;
  final String playbackUrl;
  final String? contentType;

  @override
  State<SecureContentPlayerPage> createState() =>
      _SecureContentPlayerPageState();
}

class _SecureContentPlayerPageState extends State<SecureContentPlayerPage> {
  final _service = AdminSecurePlaybackService();
  Player? _player;
  String? _url;
  Map<String, String> _headers = const {};
  Duration _resumeAt = Duration.zero;
  bool _loading = true;
  bool _retried = false;
  bool _failed = false;
  int _authorizationGeneration = 0;
  String? _audioTrackUrl;
  String? _subtitleTrackUrl;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final auth = await _service.authorize(
        contentId: widget.contentId,
        playbackUrl: widget.playbackUrl,
        contentType: widget.contentType,
      );
      if (!mounted) return;
      setState(() {
        _url = auth.playbackUrl;
        _headers = auth.headers;
        _audioTrackUrl = auth.audioTrackUrl;
        _subtitleTrackUrl = auth.subtitleTrackUrl;
        _authorizationGeneration++;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _retryAfterPlaybackError(String _) async {
    if (_retried) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    _retried = true;
    _resumeAt = _player?.state.position ?? Duration.zero;
    await _prepare();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Player')),
      body: Center(
        child: _loading
            ? const AppSpinner()
            : _failed || _url == null
                ? Text(
                    'Unable to play this content. Please try again.',
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                : OttMediaPlayer(
                    key: ValueKey(_authorizationGeneration),
                    url: _url!,
                    httpHeaders: _headers,
                    initialPosition: _resumeAt,
                    audioTrackUrl: _audioTrackUrl,
                    subtitleTrackUrl: _subtitleTrackUrl,
                    autoPlay: true,
                    onPlayerReady: (player) => _player = player,
                    onReadyChanged: (ready) {
                      if (ready) {
                        debugPrint(
                          '[ADMIN_PLAYBACK] controllerInitialized=true',
                        );
                      }
                    },
                    onError: _retryAfterPlaybackError,
                  ),
      ),
    );
  }
}

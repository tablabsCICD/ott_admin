import 'dart:async';

import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaKitPlaybackCoordinator {
  MediaKitPlaybackCoordinator._();

  static Player? _activePlayer;

  static Future<void> setActive(Player player) async {
    final oldPlayer = _activePlayer;
    if (oldPlayer != null && oldPlayer != player) {
      await oldPlayer.pause();
    }
    _activePlayer = player;
  }

  static void release(Player player) {
    if (_activePlayer == player) {
      _activePlayer = null;
    }
  }
}

class OttMediaPlayer extends StatefulWidget {
  const OttMediaPlayer({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.fit = BoxFit.contain,
    this.controls,
    this.showDefaultControls = true,
    this.allowFullscreen = true,
    this.aspectRatio,
    this.onPlayerReady,
    this.onReadyChanged,
    this.onError,
    this.errorBuilder,
    this.httpHeaders = const {},
    this.initialPosition = Duration.zero,
    this.audioTrackUrl,
    this.subtitleTrackUrl,
  });

  final String url;
  final bool autoPlay;
  final BoxFit fit;
  final Widget Function(VideoState state)? controls;
  final bool showDefaultControls;
  final bool allowFullscreen;
  final double? aspectRatio;
  final ValueChanged<Player>? onPlayerReady;
  final ValueChanged<bool>? onReadyChanged;
  final ValueChanged<String>? onError;
  final Widget Function(BuildContext context, String message)? errorBuilder;
  final Map<String, String> httpHeaders;
  final Duration initialPosition;
  final String? audioTrackUrl;
  final String? subtitleTrackUrl;

  @override
  State<OttMediaPlayer> createState() => _OttMediaPlayerState();
}

class _OttMediaPlayerState extends State<OttMediaPlayer>
    with WidgetsBindingObserver {
  late final Player _player;
  late final VideoController _videoController;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<bool>? _playingSubscription;

  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _player = Player();
    _videoController = VideoController(_player);
    widget.onPlayerReady?.call(_player);
    _errorSubscription = _player.stream.error.listen(_handlePlayerError);
    _playingSubscription = _player.stream.playing.listen((playing) {
      if (playing) {
        MediaKitPlaybackCoordinator.setActive(_player);
      }
    });
    _open();
  }

  @override
  void didUpdateWidget(covariant OttMediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.autoPlay != widget.autoPlay ||
        !mapEquals(oldWidget.httpHeaders, widget.httpHeaders)) {
      _open();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _player.pause();
    }
  }

  Future<void> _open() async {
    final url = widget.url.trim();
    widget.onReadyChanged?.call(false);
    setState(() {
      _isReady = false;
      _errorMessage = null;
    });

    if (url.isEmpty) {
      _handlePlayerError('Video unavailable');
      return;
    }

    try {
      if (widget.autoPlay) {
        await MediaKitPlaybackCoordinator.setActive(_player);
      }
      await _player.open(
        Media(url, httpHeaders: widget.httpHeaders),
        play: false,
      );
      if (widget.initialPosition > Duration.zero) {
        await _player.seek(widget.initialPosition);
      }
      try {
        final audioTrackUrl = widget.audioTrackUrl?.trim();
        if (audioTrackUrl?.isNotEmpty == true) {
          await _player.setAudioTrack(AudioTrack.uri(audioTrackUrl!));
        }
      } catch (e) {
        debugPrint('[ADMIN_PLAYBACK] audioTrackError: $e');
      }
      try {
        final subtitleTrackUrl = widget.subtitleTrackUrl?.trim();
        if (subtitleTrackUrl?.isNotEmpty == true) {
          await _player.setSubtitleTrack(SubtitleTrack.uri(subtitleTrackUrl!));
        }
      } catch (e) {
        debugPrint('[ADMIN_PLAYBACK] subtitleTrackError: $e');
      }
      if (!mounted) return;
      debugPrint('[ADMIN_PLAYBACK] controllerInitialized=true');
      setState(() => _isReady = true);
      widget.onReadyChanged?.call(true);
      if (widget.autoPlay) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          try {
            await MediaKitPlaybackCoordinator.setActive(_player);
            await _player.play();
            debugPrint('[ADMIN_PLAYBACK] playbackStarted=true');
          } catch (e) {
            debugPrint('[ADMIN_PLAYBACK] autoPlayError: $e');
            _handlePlayerError('Failed to load media');
          }
        });
      }
    } catch (e) {
      debugPrint('[ADMIN_PLAYBACK] mediaOpenError: $e');
      _handlePlayerError('Failed to load media');
    }
  }

  void _handlePlayerError(String message) {
    if (!mounted) return;
    widget.onError?.call(message);
    widget.onReadyChanged?.call(false);
    setState(() {
      _isReady = false;
      _errorMessage = message;
    });
  }

  Future<void> _enterFullscreen() async {
    if (!widget.allowFullscreen) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _errorSubscription?.cancel();
    _playingSubscription?.cancel();
    MediaKitPlaybackCoordinator.release(_player);
    _player.dispose();
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _errorMessage;
    if (error != null) {
      return widget.errorBuilder?.call(context, error) ??
          Center(
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
    }

    if (!_isReady) {
      return const Center(child: AppSpinner());
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _aspectRatio,
      child: Video(
        controller: _videoController,
        fit: widget.fit,
        controls:
            widget.showDefaultControls ? widget.controls : NoVideoControls,
        pauseUponEnteringBackgroundMode: true,
        onEnterFullscreen: _enterFullscreen,
        onExitFullscreen: _exitFullscreen,
      ),
    );
  }

  double get _aspectRatio {
    final width = _player.state.width;
    final height = _player.state.height;
    if (width == null || height == null || width == 0 || height == 0) {
      return 16 / 9;
    }
    return width / height;
  }
}

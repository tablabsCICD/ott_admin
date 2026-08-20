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

  bool _isFullscreen = false;

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
      if (mounted) setState(() => _isFullscreen = false);
    } else {
      await _enterFullscreen();
      if (mounted) setState(() => _isFullscreen = true);
    }
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

    final videoWidget = Video(
      controller: _videoController,
      fit: widget.fit,
      controls: widget.controls ??
          (widget.showDefaultControls
              ? (state) => OttMediaControls(
                    player: _player,
                    allowFullscreen: widget.allowFullscreen,
                    isFullscreen: _isFullscreen,
                    onToggleFullscreen: _toggleFullscreen,
                  )
              : NoVideoControls),
      pauseUponEnteringBackgroundMode: true,
      onEnterFullscreen: _enterFullscreen,
      onExitFullscreen: _exitFullscreen,
    );

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: videoWidget,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _toggleFullscreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _aspectRatio,
      child: videoWidget,
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

class OttMediaControls extends StatefulWidget {
  final Player player;
  final bool allowFullscreen;
  final bool isFullscreen;
  final Future<void> Function()? onToggleFullscreen;

  const OttMediaControls({
    super.key,
    required this.player,
    this.allowFullscreen = true,
    this.isFullscreen = false,
    this.onToggleFullscreen,
  });

  @override
  State<OttMediaControls> createState() => _OttMediaControlsState();
}

class _OttMediaControlsState extends State<OttMediaControls> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.player.state.playing) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _seekRelative(Duration offset) {
    _startHideTimer();
    final current = widget.player.state.position;
    final duration = widget.player.state.duration;
    final target = current + offset;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (duration > Duration.zero && target > duration ? duration : target);
    widget.player.seek(clamped);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Container(
            color: Colors.black45,
            child: Stack(
              children: [
                // Center Playback Controls: 10s Rewind, Play/Pause, 10s Forward
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 42,
                        color: Colors.white,
                        tooltip: 'Rewind 10s',
                        icon: const Icon(Icons.replay_10_rounded),
                        onPressed: () =>
                            _seekRelative(const Duration(seconds: -10)),
                      ),
                      const SizedBox(width: 28),
                      StreamBuilder<bool>(
                        stream: widget.player.stream.playing,
                        initialData: widget.player.state.playing,
                        builder: (context, snapshot) {
                          final playing = snapshot.data ?? false;
                          return IconButton(
                            iconSize: 56,
                            color: Colors.white,
                            tooltip: playing ? 'Pause' : 'Play',
                            icon: Icon(playing
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded),
                            onPressed: () {
                              _startHideTimer();
                              if (playing) {
                                widget.player.pause();
                              } else {
                                MediaKitPlaybackCoordinator.setActive(
                                    widget.player);
                                widget.player.play();
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 28),
                      IconButton(
                        iconSize: 42,
                        color: Colors.white,
                        tooltip: 'Forward 10s',
                        icon: const Icon(Icons.forward_10_rounded),
                        onPressed: () =>
                            _seekRelative(const Duration(seconds: 10)),
                      ),
                    ],
                  ),
                ),

                // Bottom Control Bar: Time + Progress Slider + Fullscreen
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 10,
                  child: StreamBuilder<Duration>(
                    stream: widget.player.stream.position,
                    initialData: widget.player.state.position,
                    builder: (context, posSnap) {
                      return StreamBuilder<Duration>(
                        stream: widget.player.stream.duration,
                        initialData: widget.player.state.duration,
                        builder: (context, durSnap) {
                          final position = posSnap.data ?? Duration.zero;
                          final duration = durSnap.data ?? Duration.zero;
                          final maxMs = duration.inMilliseconds.toDouble();
                          final valueMs = position.inMilliseconds
                              .clamp(0, maxMs > 0 ? maxMs.toInt() : 0)
                              .toDouble();

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6),
                                        activeTrackColor:
                                            Theme.of(context).primaryColor,
                                        inactiveTrackColor: Colors.white30,
                                        thumbColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                      child: Slider(
                                        min: 0,
                                        max: maxMs > 0 ? maxMs : 1,
                                        value: valueMs.clamp(
                                            0, maxMs > 0 ? maxMs : 1),
                                        onChanged: maxMs > 0
                                            ? (val) {
                                                _startHideTimer();
                                                widget.player.seek(
                                                    Duration(milliseconds: val.round()));
                                              }
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (widget.allowFullscreen &&
                                      widget.onToggleFullscreen != null)
                                    IconButton(
                                      iconSize: 24,
                                      color: Colors.white,
                                      tooltip: widget.isFullscreen
                                          ? 'Exit Fullscreen'
                                          : 'Fullscreen',
                                      icon: Icon(widget.isFullscreen
                                          ? Icons.fullscreen_exit_rounded
                                          : Icons.fullscreen_rounded),
                                      onPressed: () {
                                        _startHideTimer();
                                        widget.onToggleFullscreen?.call();
                                      },
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

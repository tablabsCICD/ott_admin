import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/app/widgets/ott_media_player.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/short_part.dart';
import 'package:admin_ott/domain/entities/shorts_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:share_plus/share_plus.dart';

class AdminShortsPlayerPage extends StatefulWidget {
  final ShortMaster short;
  final int initialIndex;

  const AdminShortsPlayerPage({
    super.key,
    required this.short,
    this.initialIndex = 0,
  });

  @override
  State<AdminShortsPlayerPage> createState() => _AdminShortsPlayerPageState();
}

class _AdminShortsPlayerPageState extends State<AdminShortsPlayerPage>
    with WidgetsBindingObserver {
  Player? _player;
  VideoController? _videoController;
  final PageController _pageController = PageController();

  late List<ShortPartDTO> _parts;
  int _currentIndex = 0;
  bool _isMetaExpanded = false;
  bool _isVideoLoading = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parts = List<ShortPartDTO>.from(widget.short.parts);
    _currentIndex =
        widget.initialIndex.clamp(0, (_parts.length - 1).clamp(0, 999999));
    if (_parts.isNotEmpty) {
      _loadPart(_currentIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _player?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_player != null) {
      MediaKitPlaybackCoordinator.release(_player!);
    }
    _player?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPart(int index) async {
    if (index < 0 || index >= _parts.length) return;
    final part = _parts[index];
    final url = (part.videoUrl ?? '').trim();
    if (url.isEmpty) {
      setState(() {
        _currentIndex = index;
        _player = null;
        _videoController = null;
        _isVideoLoading = false;
        _hasVideoError = true;
        _videoErrorMessage = 'Video unavailable';
      });
      return;
    }

    final oldPlayer = _player;
    setState(() {
      _currentIndex = index;
      _player = null;
      _videoController = null;
      _isVideoLoading = true;
      _hasVideoError = false;
      _videoErrorMessage = null;
    });
    await oldPlayer?.pause();
    if (oldPlayer != null) {
      MediaKitPlaybackCoordinator.release(oldPlayer);
      await oldPlayer.dispose();
    }

    // media_kit replaces video_player while preserving the existing shorts UI.
    final player = Player();
    final videoController = VideoController(player);
    try {
      await MediaKitPlaybackCoordinator.setActive(player);
      await player.open(Media(url), play: true);
    } catch (_) {
      await player.dispose();
      if (!mounted) return;
      setState(() {
        _currentIndex = index;
        _isVideoLoading = false;
        _hasVideoError = true;
        _videoErrorMessage = 'Failed to load video';
      });
      return;
    }

    if (!mounted) {
      await player.dispose();
      return;
    }
    setState(() {
      _player = player;
      _videoController = videoController;
      _currentIndex = index;
      _isVideoLoading = false;
      _hasVideoError = false;
      _videoErrorMessage = null;
    });
  }

  void _togglePlayPause() {
    final player = _player;
    if (player == null) return;
    if (!player.state.playing) {
      MediaKitPlaybackCoordinator.setActive(player);
    }
    player.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: ResponsiveWidget.isMobile(context) ? double.infinity : 450,
          child: Stack(
            children: [
              _videoBackground(),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _togglePlayPause,
                onDoubleTap: () => HapticFeedback.lightImpact(),
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _parts.length,
                  onPageChanged: (i) async {
                    if (_isMetaExpanded) {
                      setState(() => _isMetaExpanded = false);
                    }
                    await _loadPart(i);
                  },
                  itemBuilder: (_, i) => _overlay(i),
                ),
              ),
              _backButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoBackground() {
    if (_hasVideoError) {
      return Positioned.fill(
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_disabled, color: Colors.white70, size: 32),
              const SizedBox(height: 8),
              Text(
                _videoErrorMessage ?? "Video unavailable",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    final videoController = _videoController;
    if (_isVideoLoading || videoController == null) {
      return const Positioned.fill(
        child: Center(child: AppSpinner()),
      );
    }
    return Positioned.fill(
      child: Video(
        controller: videoController,
        fit: BoxFit.cover,
        controls: NoVideoControls,
        pauseUponEnteringBackgroundMode: true,
      ),
    );
  }

  Widget _overlay(int index) {
    final part = _parts[index];
    final titleText = (part.title ?? '').trim().isNotEmpty
        ? part.title!.trim()
        : (widget.short.title ?? '');
    final descriptionText = (widget.short.description ?? '').trim();
    final hasDescription = descriptionText.isNotEmpty;
    final showSeeMore =
        !_isMetaExpanded && (titleText.length > 36 || hasDescription);

    return Stack(
      children: [
        Positioned(
          left: 16,
          bottom: 80,
          right: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1),
                      color: Colors.white10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        part.thumbnail ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.short.creatorName ?? 'Creator',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _isMetaExpanded = !_isMetaExpanded),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        maxLines: _isMetaExpanded ? 3 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      if (_isMetaExpanded && hasDescription) ...[
                        const SizedBox(height: 3),
                        Text(
                          descriptionText,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (showSeeMore) ...[
                        const SizedBox(height: 2),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "See more",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.expand_more,
                                size: 12, color: Colors.white),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _rightButtons(index),
        _bottomEpisodeBar(),
        _playPauseIndicator(),
      ],
    );
  }

  Widget _playPauseIndicator() {
    final player = _player;
    if (player == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: player.stream.playing,
      initialData: player.state.playing,
      builder: (context, snapshot) {
        if (snapshot.data == true) return const SizedBox.shrink();
        return const Center(
          child: Icon(
            Icons.play_arrow_sharp,
            color: Colors.white60,
            size: 50,
          ),
        );
      },
    );
  }

  Widget _rightButtons(int index) {
    final part = _parts[index];
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: [
          _actionBtn(Icons.telegram_outlined, "Share", () {
            _shareShort(part);
          }),
          const SizedBox(height: 18),
          _actionBtn(Icons.visibility_outlined, "${part.views ?? 0}", null),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black12),
            child: Icon(icon, size: 26, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _shareShort(ShortPartDTO part) async {
    final text = '''
🎬 ${part.title ?? widget.short.title ?? ''}
Creator: ${widget.short.creatorName ?? ''}
''';
    await Share.share(text.trim(), subject: part.title ?? 'Short');
  }

  Widget _bottomEpisodeBar() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: Column(
        children: [
          InkWell(
            onTap: _openEpisodes,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Episode ${_currentIndex + 1} / ${_parts.length}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.expand_less, color: Colors.white),
                ],
              ),
            ),
          ),
          _videoProgressBar(),
        ],
      ),
    );
  }

  Widget _videoProgressBar() {
    final player = _player;
    if (player == null) return const SizedBox.shrink();

    if (player.state.duration == Duration.zero) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData: player.state.position,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: player.stream.duration,
          initialData: player.state.duration,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            if (duration == Duration.zero) return const SizedBox.shrink();

            final position = positionSnapshot.data ?? Duration.zero;
            final max = duration.inMilliseconds.toDouble();
            final value =
                position.inMilliseconds.clamp(0, max.toInt()).toDouble();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 4),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 10),
                  activeTrackColor: const Color(0xFFE50914),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: const Color(0xFFE50914),
                ),
                child: Slider(
                  min: 0,
                  max: max,
                  value: value,
                  onChanged: (next) {
                    player.seek(Duration(milliseconds: next.round()));
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEpisodes() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            itemCount: _parts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) {
              final part = _parts[i];
              final active = i == _currentIndex;
              return GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  _pageController.jumpToPage(i);
                  await _loadPart(i);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? theme.primaryColor : theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: theme.canvasColor.withValues(alpha: .7)),
                  ),
                  child: Center(
                    child: Text(
                      "EP ${part.partNumber ?? '-'}",
                      style: TextStyle(
                        color: active ? Colors.white : theme.canvasColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _backButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 12,
      child: InkWell(
        onTap: () {
          _player?.pause();
          Navigator.pop(context);
        },
        child: const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.black45,
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

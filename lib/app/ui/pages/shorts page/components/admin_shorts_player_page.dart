import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class AdminShortsPlayerPage extends StatefulWidget {
  final ShortDetailData short;
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
  VideoPlayerController? _controller;
  final PageController _pageController = PageController();

  late List<ShortDetailPart> _parts;
  int _currentIndex = 0;
  bool _isMetaExpanded = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _parts = List<ShortDetailPart>.from(widget.short.parts);
    _currentIndex = widget.initialIndex.clamp(0, (_parts.length - 1).clamp(0, 999999));
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
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
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
        _controller = null;
        _hasVideoError = true;
        _videoErrorMessage = 'Video unavailable';
      });
      return;
    }

    final old = _controller;
    _controller = null;
    await old?.pause();
    await old?.dispose();

    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await ctrl.initialize();
      await ctrl.play();
    } catch (_) {
      await ctrl.dispose();
      if (!mounted) return;
      setState(() {
        _currentIndex = index;
        _hasVideoError = true;
        _videoErrorMessage = 'Failed to load video';
      });
      return;
    }

    if (!mounted) {
      await ctrl.dispose();
      return;
    }
    setState(() {
      _controller = ctrl;
      _currentIndex = index;
      _hasVideoError = false;
      _videoErrorMessage = null;
    });
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
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
    final controller = _controller;
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
    if (controller == null || !controller.value.isInitialized) {
      return const Positioned.fill(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.value.hasError ||
        controller.value.size.width == 0 ||
        controller.value.size.height == 0) {
      return const Positioned.fill(
        child: Center(
          child: Icon(Icons.play_disabled, color: Colors.white70, size: 32),
        ),
      );
    }
    final size = controller.value.size;
    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Widget _overlay(int index) {
    final part = _parts[index];
    final titleText =
        (part.title ?? '').trim().isNotEmpty ? part.title!.trim() : (widget.short.title ?? '');
    final descriptionText = (widget.short.description ?? '').trim();
    final hasDescription = descriptionText.isNotEmpty;
    final showSeeMore = !_isMetaExpanded && (titleText.length > 36 || hasDescription);

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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            Icon(Icons.expand_more, size: 12, color: Colors.white),
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
        if (_controller != null && !_controller!.value.isPlaying)
          const Center(
            child: Icon(
              Icons.play_arrow_sharp,
              color: Colors.white60,
              size: 50,
            ),
          ),
      ],
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
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
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

  Future<void> _shareShort(ShortDetailPart part) async {
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
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    final value = controller.value;
    if (!value.isInitialized || value.duration == Duration.zero || value.hasError) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Color(0xFFE50914),
            bufferedColor: Colors.white30,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
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
                    border: Border.all(color: theme.canvasColor.withValues(alpha: .7)),
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
          _controller?.pause();
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

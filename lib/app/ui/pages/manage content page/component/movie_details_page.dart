import 'dart:async';
import 'package:admin_ott/app/core/utils/amount_formatter.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/movie_sales_chart.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/add_video.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/content_rating_review_section.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/content_review_components.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/edit_teaser_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_purchased_users_section.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/secure_content_player_page.dart';
import 'package:admin_ott/data/repositories/cast_repository.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/cast_crew.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/show_toast.dart';

class MovieDetailsPage extends StatefulWidget {
  final Content content;
  final bool popOnStatusChange;

  const MovieDetailsPage({
    super.key,
    required this.content,
    this.popOnStatusChange = false,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late Content _content;
  double _adminPercentage = 50.0;
  bool _isSettingPercentage = false;
  List<Cast> _castList = [];
  bool _isLoadingCast = false;
  String? _castErrorMessage;

  @override
  void initState() {
    super.initState();
    _content = widget.content;
    _adminPercentage = _clampPercentage(_content.adminIncentivePecentage);
    final id = _content.id;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchFullMovieDetails(id);
      });
      Provider.of<VideoProvider>(context, listen: false)
          .contentRevenueGraph(0, id, '', '');
    }
    Provider.of<VideoProvider>(context, listen: false).fetchMediaHouse();
    _fetchMovieCast(id);
  }

  Future<void> _fetchFullMovieDetails(int id) async {
    try {
      final provider = Provider.of<VideoProvider>(context, listen: false);
      final fullContent = await provider.getContentById(id);
      if (fullContent != null && mounted) {
        setState(() {
          _content = _content.mergeWith(fullContent);
          _adminPercentage = _clampPercentage(_content.adminIncentivePecentage);
        });
      }
    } catch (e) {
      debugPrint("Error fetching full movie details: $e");
    }
  }

  Future<void> _fetchMovieCast(int? id) async {
    if (id == null) return;
    setState(() {
      _isLoadingCast = true;
      _castErrorMessage = null;
    });
    try {
      final castRepo = CastRepository();
      final casts = await castRepo.getCastForContent(
        contentType: _content.type ?? 'MOVIE',
        contentId: id,
        shortId: id,
      );
      if (mounted) {
        final castNames = casts
            .where((c) => (c.name ?? '').trim().isNotEmpty)
            .map((c) => c.name!.trim())
            .toList();
        final directorNames = casts
            .where((c) =>
                (c.role ?? c.designation ?? '')
                    .toLowerCase()
                    .contains('director') &&
                (c.name ?? '').trim().isNotEmpty)
            .map((c) => c.name!.trim())
            .toList();
        setState(() {
          _castList = casts;
          _isLoadingCast = false;
          _content = _content.copyWith(
            castList:
                (_content.castList != null && _content.castList!.isNotEmpty)
                    ? _content.castList
                    : castNames,
            directorList: (_content.directorList != null &&
                    _content.directorList!.isNotEmpty)
                ? _content.directorList
                : (directorNames.isNotEmpty ? directorNames : null),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching movie cast: $e");
      if (mounted) {
        setState(() {
          _isLoadingCast = false;
          _castErrorMessage = 'Unable to load cast and crew information.';
        });
      }
    }
  }

  Future<void> _openEditVideos() async {
    final id = _content.id;
    if (id == null) return;
    final provider = context.read<VideoProvider>();
    Content? fullContent;
    try {
      fullContent = await provider.getContentById(id);
    } catch (_) {}
    if (!context.mounted) return;

    final targetContent = _content.mergeWith(fullContent);

    final updated = await Navigator.push<Content>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDataWidget(editingContent: targetContent),
      ),
    );
    if (updated != null && context.mounted) {
      setState(() {
        _content = _content.mergeWith(updated);
      });
      await provider.fetchMoviesByStatusAndMediaHouseId('ALL', 0);
      if (_content.id != null) {
        _fetchFullMovieDetails(_content.id!);
        _fetchMovieCast(_content.id!);
      }
    }
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'No date';
    final date =
        rawDate is DateTime ? rawDate : DateTime.tryParse(rawDate.toString());
    if (date == null) return rawDate.toString();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final content = _content;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          content.title ?? 'Movie Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: "Refresh Details",
            onPressed: () {
              if (_content.id != null) {
                _fetchFullMovieDetails(_content.id!);
                _fetchMovieCast(_content.id!);
                Provider.of<VideoProvider>(context, listen: false)
                    .contentRevenueGraph(0, _content.id!, '', '');
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: "Edit Video Files",
            onPressed: _openEditVideos,
            icon: const Icon(Icons.video_settings_outlined),
          ),
          IconButton(
            tooltip: "Delete Movie",
            onPressed: () => _confirmDelete(context, content),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Content Header (Hero Poster, Title, Type, Status, Language, Release Date, Price)
            PosterSliderHeader(
              content: content,
              onEditVideos: _openEditVideos,
            ),
            const SizedBox(height: 16),

            // 2. Action Panel (Approve, Reject, Play Movie, Play Trailer, Play Teaser, Edit, Delete, Set Percentage)
            ActionPanel(
              content: content,
              popOnStatusChange: widget.popOnStatusChange,
              onStatusChanged: _refreshAfterStatusChange,
              onEditVideos: _openEditVideos,
            ),
            const SizedBox(height: 16),

            // 3. Content Information (Metadata Detail Section)
            DetailsSection(
              content: content,
              heading: 'Content Information',
            ),
            const SizedBox(height: 16),

            // 5. Agreement & Documents Section (Agreement & Censor Certificate)
            AgreementSection(
              agreementUrl: content.agreementUrl,
              censorCertificateUrl: content.sensorCertificate,
            ),
            const SizedBox(height: 16),

            // 6. Cast & Crew Section (Cast & Crew Cards)
            CastCrewSection(
              castList: _castList,
              isLoading: _isLoadingCast,
              errorMessage: _castErrorMessage,
              isSeries: false,
            ),
            const SizedBox(height: 16),

            // 7. Revenue Snapshot
            RevenueHighlightCard(content: content),
            const SizedBox(height: 16),

            // 8. Revenue Chart (Desktop view)
            if (isDesktop && content.id != null) ...[
              SizedBox(
                height: 350,
                child: Card(
                  color: theme.cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: MovieSalesChart(
                      title: 'Revenue Trend',
                      yAxisLabel: 'Revenue (₹)',
                      metrics: const ["revenue"],
                      graphNumber: 0,
                      contentId: content.id!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 9. Ratings & Reviews Section
            if (content.id != null) ...[
              ContentRatingReviewSection(
                contentId: content.id!,
                contentTitle: content.title,
              ),
              const SizedBox(height: 16),
            ],

            // 10. Users who bought/watched this content
            if (content.id != null) ...[
              MoviePurchasedUsersSection(
                contentId: content.id!,
                contentTitle: content.title,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _refreshAfterStatusChange(String status) {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    final updatedContent = provider.content.id == _content.id
        ? provider.content
        : Content.fromJson({
            ..._content.toJson(),
            'approvalStatus': status,
          });

    if (!mounted) return;
    setState(() {
      _content = updatedContent;
      _adminPercentage = _clampPercentage(_content.adminIncentivePecentage);
    });
  }

  void _confirmDelete(BuildContext context, Content content) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete ${content.title ?? "Movie"}?',
          style:
              TextStyle(color: theme.canvasColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This action cannot be undone. All metadata and associations will be permanently removed.',
          style: TextStyle(color: theme.hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (content.id != null) {
                Provider.of<VideoProvider>(context, listen: false)
                    .deleteVideo(content.id!, context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  double _clampPercentage(dynamic value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null) return 50.0;
    if (parsed < 0) return 0.0;
    if (parsed > 100) return 100.0;
    return parsed;
  }
}

/// Poster Slider Header with multi-image sliding, indicators, thumbnails, and quick details.
class PosterSliderHeader extends StatefulWidget {
  final Content content;
  final VoidCallback? onEditVideos;

  const PosterSliderHeader({
    super.key,
    required this.content,
    this.onEditVideos,
  });

  @override
  State<PosterSliderHeader> createState() => _PosterSliderHeaderState();
}

class _PosterSliderHeaderState extends State<PosterSliderHeader> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  bool _isHovered = false;

  List<String> get _posterUrls {
    final list = widget.content.posterUrlList ?? const <String>[];
    return list.where((p) => p.trim().isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _autoScrollTimer?.cancel();
    if (_posterUrls.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!_isHovered && _pageController.hasClients) {
          final nextIndex = (_currentIndex + 1) % _posterUrls.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant PosterSliderHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.posterUrlList != widget.content.posterUrlList) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      padding: const EdgeInsets.all(32),
                      color: Colors.black87,
                      child: const Text("Image preview not available",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final posters = _posterUrls;
    final hasPosters = posters.isNotEmpty;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final sliderWidth = isDesktop
        ? 520.0
        : screenWidth > 700
            ? 450.0
            : double.infinity;

    return Card(
      color: theme.cardColor,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final posterWidth = isWide
                ? (constraints.maxWidth * 0.42).clamp(320.0, 520.0)
                : constraints.maxWidth;
            final posterHeight =
                isWide ? (posterWidth * 9 / 16).clamp(200.0, 310.0) : 220.0;

            final posterSliderWidget = SizedBox(
              width: isWide ? posterWidth : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider Viewport
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: Stack(
                      children: [
                        Container(
                          width: isWide ? posterWidth : double.infinity,
                          height: posterHeight,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: hasPosters
                                ? PageView.builder(
                                    controller: _pageController,
                                    itemCount: posters.length,
                                    onPageChanged: (idx) {
                                      setState(() => _currentIndex = idx);
                                    },
                                    itemBuilder: (context, index) {
                                      final currentPoster = posters[index];
                                      return GestureDetector(
                                        onTap: () =>
                                            _openImagePreview(currentPoster),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              currentPoster,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _fallback(theme),
                                            ),
                                            // Gradient shadow at bottom
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              height: 60,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      Colors.black.withValues(
                                                          alpha: 0.75),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : _fallback(theme),
                          ),
                        ),

                        // Floating Badge for Poster Count
                        if (posters.length > 1)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library_outlined,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Poster ${_currentIndex + 1} / ${posters.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Navigation Arrows (Left / Right)
                        if (posters.length > 1) ...[
                          Positioned(
                            left: 6,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  final prev =
                                      (_currentIndex - 1 + posters.length) %
                                          posters.length;
                                  _goToSlide(prev);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  final next =
                                      (_currentIndex + 1) % posters.length;
                                  _goToSlide(next);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Slide Dots Indicator
                        if (posters.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(posters.length, (idx) {
                                final isActive = idx == _currentIndex;
                                return GestureDetector(
                                  onTap: () => _goToSlide(idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    height: 6,
                                    width: isActive ? 22 : 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? theme.primaryColor
                                          : Colors.white.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        if (isActive)
                                          BoxShadow(
                                            color: theme.primaryColor
                                                .withValues(alpha: 0.6),
                                            blurRadius: 4,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Thumbnails strip if multiple posters
                  if (posters.length > 1) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      width: isWide ? posterWidth : double.infinity,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: posters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final isSelected = idx == _currentIndex;
                          return GestureDetector(
                            onTap: () => _goToSlide(idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.dividerColor
                                          .withValues(alpha: 0.2),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  posters[idx],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: theme.scaffoldBackgroundColor,
                                    child: const Icon(Icons.broken_image,
                                        size: 16),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );

            final detailsInfoWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Approval Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.content.title ?? 'Untitled Movie',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.canvasColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(
                        widget.content.approvalStatus ?? 'PENDING', theme),
                  ],
                ),
                const SizedBox(height: 10),

                // Metadata Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _metaPill(
                      theme: theme,
                      icon: Icons.movie_filter_outlined,
                      label: formatContentTypeLabel(widget.content.type),
                    ),
                    if (widget.content.runtime != null &&
                        widget.content.runtime! > 0)
                      _metaPill(
                        theme: theme,
                        icon: Icons.schedule_rounded,
                        label: '${widget.content.runtime} min',
                      ),
                    if (widget.content.releaseDate != null)
                      _metaPill(
                        theme: theme,
                        icon: Icons.event_rounded,
                        label: '${widget.content.releaseDate}',
                      ),
                    if (widget.content.ageRating != null &&
                        widget.content.ageRating!.trim().isNotEmpty)
                      _metaPill(
                        theme: theme,
                        icon: Icons.explicit_rounded,
                        label: widget.content.ageRating!.trim(),
                      ),
                    if (widget.content.mediaHouseName != null &&
                        widget.content.mediaHouseName!.trim().isNotEmpty)
                      _metaPill(
                        theme: theme,
                        icon: Icons.business_rounded,
                        label: widget.content.mediaHouseName!.trim(),
                      ),
                    _metaPill(
                      theme: theme,
                      icon: Icons.visibility_outlined,
                      label: '${widget.content.views ?? 0} views',
                    ),
                    _metaPill(
                      theme: theme,
                      icon: Icons.shopping_cart_outlined,
                      label: '${widget.content.totalPurchase ?? 0} purchases',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Genres List
                if (widget.content.genreList != null &&
                    widget.content.genreList!.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.content.genreList!.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Description
                Text(
                  "Overview",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.canvasColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (widget.content.description != null &&
                          widget.content.description!.trim().isNotEmpty)
                      ? widget.content.description!
                      : 'No overview or description provided for this title.',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  posterSliderWidget,
                  const SizedBox(width: 24),
                  Expanded(child: detailsInfoWidget),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  posterSliderWidget,
                  const SizedBox(height: 16),
                  detailsInfoWidget,
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _statusBadge(String status, ThemeData theme) {
    Color bg;
    Color fg;
    final upper = status.toUpperCase();

    if (upper == 'APPROVED') {
      bg = Colors.green.withValues(alpha: 0.15);
      fg = Colors.green;
    } else if (upper == 'REJECTED') {
      bg = Colors.red.withValues(alpha: 0.15);
      fg = Colors.redAccent;
    } else {
      bg = Colors.orange.withValues(alpha: 0.15);
      fg = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _metaPill({
    required ThemeData theme,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.primaryColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.canvasColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            size: 40,
            color: theme.primaryColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 6),
          Text(
            "No Poster Available",
            style: TextStyle(
              color: theme.hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionPanel extends StatelessWidget {
  final Content content;
  final bool popOnStatusChange;
  final ValueChanged<String>? onStatusChanged;
  final VoidCallback? onEditVideos;

  const ActionPanel({
    super.key,
    required this.content,
    this.popOnStatusChange = false,
    this.onStatusChanged,
    this.onEditVideos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final status = (content.approvalStatus ?? '').toUpperCase();
    final approved = status == 'APPROVED';
    final rejected = status == 'REJECTED';

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Actions',
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _actionButton(
                  context: context,
                  label: approved ? 'Approved' : 'Approve',
                  icon: Icons.check_circle_outline,
                  backgroundColor: approved
                      ? theme.primaryColor.withValues(alpha: 0.35)
                      : Colors.green,
                  textColor: Colors.white,
                  onPressed: approved
                      ? null
                      : () => _showApproveDialog(context, content),
                ),
                _actionButton(
                  context: context,
                  label: rejected ? 'Rejected' : 'Reject',
                  icon: Icons.cancel_outlined,
                  backgroundColor: rejected
                      ? theme.primaryColor.withValues(alpha: 0.35)
                      : theme.cardColor,
                  textColor: rejected ? Colors.white : theme.canvasColor,
                  borderColor: Colors.red.withValues(alpha: 0.5),
                  onPressed: rejected
                      ? null
                      : () => _showRejectDialog(context, content),
                ),
                if (onEditVideos != null)
                  _actionButton(
                    context: context,
                    label: 'Edit Videos',
                    icon: Icons.video_settings_outlined,
                    backgroundColor: theme.cardColor,
                    textColor: theme.canvasColor,
                    borderColor: theme.primaryColor.withValues(alpha: 0.5),
                    onPressed: onEditVideos,
                  ),
                _actionButton(
                  context: context,
                  label: 'Watch Teaser',
                  icon: Icons.movie_creation_outlined,
                  backgroundColor: theme.primaryColor,
                  textColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrailerPage(
                          trailerUrl:
                              content.teaserUrl ?? content.trailerUrl ?? ''),
                    ),
                  ),
                ),
                _actionButton(
                  context: context,
                  label: 'Watch Trailer',
                  icon: Icons.ondemand_video_outlined,
                  backgroundColor: theme.primaryColor,
                  textColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TrailerPage(trailerUrl: content.trailerUrl ?? ''),
                    ),
                  ),
                ),
                _actionButton(
                  context: context,
                  label: 'Watch Content',
                  icon: Icons.play_circle_outline,
                  backgroundColor: theme.primaryColor,
                  textColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SecureContentPlayerPage(
                        contentId: content.id?.toString() ?? '',
                        playbackUrl: content.contentUrl ?? '',
                        contentType: content.type ?? 'MOVIE',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, Content content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Content'),
        content: Text(
          'Are you sure you want to approve "${content.title ?? 'this content'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final id = content.id;
              if (id == null) return;

              final success =
                  await Provider.of<VideoProvider>(context, listen: false)
                      .changeContentStatus(context, "APPROVED", id);

              if (!context.mounted || !success) return;
              onStatusChanged?.call("APPROVED");
              if (popOnStatusChange) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor ?? Colors.transparent),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Content content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Content'),
        content: const Text('Are you sure you want to reject this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final id = content.id;
              if (id == null) return;

              final success =
                  await Provider.of<VideoProvider>(context, listen: false)
                      .changeContentStatus(context, "REJECTED", id);

              if (!context.mounted || !success) return;
              onStatusChanged?.call("REJECTED");
              if (popOnStatusChange) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class DetailsSection extends StatelessWidget {
  final Content content;
  final String heading;

  const DetailsSection({
    super.key,
    required this.content,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor,
              ),
            ),
            const SizedBox(height: 10),
            _detail('Title', content.title ?? '-'),
            _detail(
                'Description',
                (content.description != null &&
                        content.description!.trim().isNotEmpty)
                    ? content.description!
                    : '-'),
            _detail('Type', formatContentTypeLabel(content.type)),
            _detail('Status', content.approvalStatus ?? '-'),
            _detail('Release Date', content.releaseDate?.toString() ?? '-'),
            _detail('Runtime', '${content.runtime ?? '-'} min'),
            _detail('Uploaded By', content.mediaHouseName ?? '-'),
            _detail('Price', _formatCurrency(content.price)),
            _detail('Views', '${content.views ?? 0}'),
            _detail('Total Purchases', '${content.totalPurchase ?? 0}'),
            _detail('Total Revenue', _formatCurrency(content.totalRevenue)),
            _detail('Admin Revenue', _formatCurrency(content.adminRevnue)),
            _detail(
              'Production House Revenue',
              _formatCurrency(content.mediaHouseRevenue),
            ),
            _detail(
                'Genres',
                (content.genreList ?? []).isNotEmpty
                    ? content.genreList!.join(', ')
                    : '-'),
            _detail(
                'Languages',
                (content.languageList ?? []).isNotEmpty
                    ? content.languageList!.join(', ')
                    : '-'),
            _detail(
                'Cast',
                (content.castList ?? []).isNotEmpty
                    ? content.castList!.join(', ')
                    : '-'),
            _detail(
                'Director',
                (content.directorList ?? []).isNotEmpty
                    ? content.directorList!.join(', ')
                    : '-'),
            _detail(
              'Admin Percentage',
              content.adminIncentivePecentage != null
                  ? '${content.adminIncentivePecentage}%'
                  : '-',
            ),
            _detail(
              'MediaHouse Percentage',
              content.mediaHouseIncentivePecentage != null
                  ? '${content.mediaHouseIncentivePecentage}%'
                  : '-',
            ),
            _detail('Edit/Reject Reason', content.reason ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _detail(String key, String value) {
    return _detailRow(key, value, highlight: false);
  }

  Widget _detailRow(
    String key,
    String value, {
    required bool highlight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Builder(builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: highlight
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              : EdgeInsets.zero,
          decoration: highlight
              ? BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.28),
                  ),
                )
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  key,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: highlight ? theme.primaryColor : null,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: highlight ? FontWeight.w900 : null,
                    color: highlight ? theme.primaryColor : null,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatCurrency(num? value) {
    if (value == null) return 'Rs. -';
    return 'Rs. ${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
  }
}

class RevenueHighlightCard extends StatelessWidget {
  const RevenueHighlightCard({super.key, required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final adminShare = content.adminIncentivePecentage;
    final mediaHouseShare = content.mediaHouseIncentivePecentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final tiles = [
            _RevenueTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Total Revenue',
              value: _formatCurrency(content.totalRevenue),
              emphasized: true,
            ),
            _RevenueTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin Revenue',
              value: _formatCurrency(content.adminRevnue),
            ),
            _RevenueTile(
              icon: Icons.business_outlined,
              label: 'Production House Revenue',
              value: _formatCurrency(content.mediaHouseRevenue),
            ),
            _RevenueTile(
              icon: Icons.sell_outlined,
              label: 'Content Price',
              value: _formatCurrency(content.price),
            ),
            _RevenueTile(
              icon: Icons.visibility_outlined,
              label: 'Views',
              value: '${content.views ?? 0}',
            ),
            _RevenueTile(
              icon: Icons.pie_chart_outline,
              label: 'Share Split',
              value:
                  'Admin ${_formatPercent(adminShare)} / PH ${_formatPercent(mediaHouseShare)}',
            ),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RevenueHeader(theme: theme),
                const SizedBox(height: 12),
                ...tiles.map(
                  (tile) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: tile,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RevenueHeader(theme: theme),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (int index = 0; index < tiles.length; index++) ...[
                    Expanded(child: tiles[index]),
                    if (index != tiles.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatCurrency(num? value) {
    if (value == null) return 'Rs. -';
    return 'Rs. ${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
  }

  static String _formatPercent(num? value) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}%';
  }
}

class _RevenueHeader extends StatelessWidget {
  const _RevenueHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.trending_up, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          'Revenue Snapshot',
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RevenueTile extends StatelessWidget {
  const _RevenueTile({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasized
            ? theme.primaryColor.withValues(alpha: 0.12)
            : theme.scaffoldBackgroundColor.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasized
              ? theme.primaryColor.withValues(alpha: 0.34)
              : theme.canvasColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.68),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: emphasized ? theme.primaryColor : theme.canvasColor,
                    fontSize: emphasized ? 18 : 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

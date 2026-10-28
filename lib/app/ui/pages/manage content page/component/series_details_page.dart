// Several reusable widgets live in this file so the series detail surface stays
// easy to move later without touching provider or route code.
// ignore_for_file: library_private_types_in_public_api, unused_element, use_build_context_synchronously

import 'dart:convert';
import 'dart:math' as math;

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/secure_content_player_page.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/content_rating_review_section.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_purchased_users_section.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/content_review_components.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/add_video.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/edit_teaser_dialog.dart';
import 'package:admin_ott/data/repositories/cast_repository.dart';
import 'package:admin_ott/domain/entities/cast_crew.dart';

import 'movie_details_page.dart' show DetailsSection;

class SeriesDetailsPage extends StatefulWidget {
  final Content content;

  const SeriesDetailsPage({super.key, required this.content});

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  late List<_SeriesSeason> _seasons;
  late _SeriesSeason _selectedSeason;
  late _SeriesEpisode _selectedEpisode;
  final _SeriesDetailsRepository _repository = _SeriesDetailsRepository();
  final CastRepository _castRepository = CastRepository();
  final TextEditingController _episodeSearchController =
      TextEditingController();
  _LiveSeriesDetails? _liveDetails;
  final Set<int> _updatingSeasonStatus = {};
  bool _isLoadingDetails = false;
  String? _detailsError;
  String _episodeQuery = '';
  List<Cast> _seasonCastList = [];
  bool _isLoadingSeasonCast = false;
  String? _seasonCastError;

  @override
  void initState() {
    super.initState();
    _seasons = _buildFallbackSeasons(widget.content);
    _selectedSeason = _seasons.first;
    _selectedEpisode = _selectedSeason.episodes.first;
    final id = widget.content.id;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSeriesDetails(id);
      });
    }
    _fetchSeasonCast(_selectedSeason.id);
  }

  @override
  void dispose() {
    _episodeSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSeasonCast(int seasonId) async {
    final contentId = widget.content.id ?? _liveDetails?.content.id;
    if (contentId == null) return;
    setState(() {
      _isLoadingSeasonCast = true;
      _seasonCastError = null;
      _seasonCastList = [];
    });

    try {
      final list = await _castRepository.getCastForContent(
        contentType: 'SERIES',
        contentId: contentId,
        seasonId: seasonId,
      );
      if (!mounted) return;
      setState(() {
        _seasonCastList = list;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _seasonCastError = 'Unable to load cast and crew information.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingSeasonCast = false);
      }
    }
  }

  Future<void> _fetchSeriesDetails(int id) async {
    setState(() {
      _isLoadingDetails = true;
      _detailsError = null;
    });

    try {
      final details = await _repository.fetchDetails(id);
      if (!mounted) return;
      final seasons = details.seasons.isEmpty
          ? _buildFallbackSeasons(details.content)
          : details.seasons;
      setState(() {
        _liveDetails = details;
        _seasons = seasons;
        _selectedSeason = seasons.first;
        _selectedEpisode = seasons.first.episodes.isNotEmpty
            ? seasons.first.episodes.first
            : _emptyEpisode();
      });
      _fetchSeasonCast(seasons.first.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailsError = 'Live series details unavailable';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  Future<void> _openEdit() async {
    final id = widget.content.id ?? _liveDetails?.content.id;
    if (id == null) return;
    final provider = context.read<VideoProvider>();
    Content? fullContent;
    try {
      fullContent = await provider.getContentById(id);
    } catch (_) {}
    if (!mounted) return;

    final baseContent = _liveDetails?.content ?? widget.content;
    final target = baseContent.mergeWith(fullContent);
    final updated = await Navigator.push<Content>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDataWidget(editingContent: target),
      ),
    );
    if (updated != null && mounted) {
      _fetchSeriesDetails(id);
      await provider.fetchMoviesByStatusAndMediaHouseId('ALL', 0);
    }
  }

  Future<void> _changeSeasonStatus(
    _SeriesSeason season,
    String newStatus,
  ) async {
    if (season.id <= 0 || newStatus == season.status.toUpperCase()) return;
    setState(() => _updatingSeasonStatus.add(season.id));
    try {
      final result = await _repository.changeSeasonStatus(season.id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(result.message),
          backgroundColor:
              result.success ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
      if (!result.success) return;
      final id = _liveDetails?.content.id ?? widget.content.id;
      if (id != null) {
        await _fetchSeriesDetails(id);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: Text(_cleanError(error, 'Season status update failed')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingSeasonStatus.remove(season.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;
    final tablet = width >= 720 && width < 1100;
    final displayContent = _liveDetails?.content ?? widget.content;
    final cast = _liveDetails?.seriesCast ?? const <_SeriesCast>[];
    final mediaHouse = _liveDetails?.mediaHouse;
    final teaserUrl = _liveDetails?.teaserUrl ?? '';
    final filteredEpisodes = _filteredEpisodes;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          displayContent.title ?? 'Series Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_liveDetails != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: _LiveDataBadge(),
            ),
          IconButton(
            tooltip: 'Refresh series details',
            onPressed: widget.content.id == null || _isLoadingDetails
                ? null
                : () {
                    _fetchSeriesDetails(widget.content.id!);
                  },
            icon: _isLoadingDetails
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Edit Series',
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete Series',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.cardColor.withValues(alpha: 0.62),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                desktop ? 28 : 16,
                18,
                desktop ? 28 : 16,
                28,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SeriesInfoCard(
                          content: displayContent,
                          cast: cast,
                          seasonCount: _seasons.length,
                          totalEpisodes: _seasons.fold<int>(
                            0,
                            (sum, season) => sum + season.episodeCount,
                          ),
                          onDelete: () => _confirmDelete(context),
                          onEdit: () => _requestEdit(context),
                          onPublishToggle: () => _togglePublish(context),
                          onAddSeason: () =>
                              _showUnavailable('Season creation'),
                        ),
                        if (_isLoadingDetails) ...[
                          const SizedBox(height: 12),
                          const ShimmerLoader(height: 86),
                        ],
                        if (_detailsError != null) ...[
                          const SizedBox(height: 12),
                          EmptyStateWidget(
                            icon: Icons.cloud_off_outlined,
                            title: 'Using saved series data',
                            message: _detailsError!,
                            actionLabel: 'Retry',
                            onAction: widget.content.id == null
                                ? null
                                : () => _fetchSeriesDetails(widget.content.id!),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _OverviewExtras(
                          content: displayContent,
                          mediaHouse: mediaHouse,
                          teaserUrl: teaserUrl,
                          desktop: desktop,
                          onPlay: _openDirectPreview,
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: 'Seasons',
                          actionLabel: 'Add Season',
                          onAction: () => _showUnavailable('Season creation'),
                        ),
                        const SizedBox(height: 12),
                        _SeasonGrid(
                          seasons: _seasons,
                          selectedSeason: _selectedSeason,
                          desktop: desktop,
                          tablet: tablet,
                          onSelected: (season) {
                            setState(() {
                              _selectedSeason = season;
                              _selectedEpisode = season.episodes.isNotEmpty
                                  ? season.episodes.first
                                  : _emptyEpisode();
                              _episodeSearchController.clear();
                              _episodeQuery = '';
                            });
                            _fetchSeasonCast(season.id);
                          },
                          onAction: _showUnavailable,
                          updatingStatus: _updatingSeasonStatus,
                          onStatusChanged: _changeSeasonStatus,
                        ),
                        const SizedBox(height: 16),
                        CastCrewSection(
                          castList: _seasonCastList,
                          isLoading: _isLoadingSeasonCast,
                          errorMessage: _seasonCastError,
                          isSeries: true,
                        ),
                        const SizedBox(height: 16),
                        AgreementSection(
                          agreementUrl: displayContent.resolvedAgreementUrl ??
                              displayContent.aggrementDocument ??
                              displayContent.agreementUrl,
                          censorCertificateUrl: (displayContent.sensorCertificate != null &&
                                  displayContent.sensorCertificate!.trim().isNotEmpty &&
                                  displayContent.sensorCertificate?.trim() !=
                                      (displayContent.resolvedAgreementUrl ??
                                              displayContent.aggrementDocument ??
                                              displayContent.agreementUrl)
                                          ?.trim() &&
                                  !displayContent.sensorCertificate!.toLowerCase().contains('agreement') &&
                                  !displayContent.sensorCertificate!.toLowerCase().endsWith('.pdf'))
                              ? displayContent.sensorCertificate
                              : null,
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(title: _selectedSeason.name),
                        const SizedBox(height: 12),
                        _SeasonDetailsPanel(
                          season: _selectedSeason,
                          desktop: desktop,
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: 'Episodes',
                          actionLabel: 'Add Episode',
                          onAction: () => _showUnavailable('Episode creation'),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedSeason.episodes.isEmpty)
                          EmptyStateWidget(
                            icon: Icons.video_library_outlined,
                            title: 'No episodes available',
                            message:
                                'Episodes will appear here once they are available from the API.',
                            actionLabel: 'Retry',
                            onAction: () {},
                          )
                        else
                          Column(
                            children: [
                              _EpisodeSearchField(
                                controller: _episodeSearchController,
                                onChanged: (value) {
                                  setState(() => _episodeQuery = value);
                                },
                              ),
                              const SizedBox(height: 12),
                              if (filteredEpisodes.isEmpty)
                                const EmptyStateWidget(
                                  icon: Icons.search_off_outlined,
                                  title: 'No episodes matched',
                                  message:
                                      'Try a different episode title, number, or status.',
                                )
                              else
                                _EpisodeGrid(
                                  episodes: filteredEpisodes,
                                  selectedEpisode: _selectedEpisode,
                                  desktop: desktop,
                                  tablet: tablet,
                                  onSelected: (episode) {
                                    setState(() => _selectedEpisode = episode);
                                  },
                                  onAction: _handleEpisodeAction,
                                ),
                            ],
                          ),
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: '${_selectedEpisode.badge} Details',
                        ),
                        const SizedBox(height: 12),
                        _EpisodeDetailsPanel(
                          episode: _selectedEpisode,
                          desktop: desktop,
                          onPlay: (_) =>
                              _openProtectedEpisode(_selectedEpisode),
                        ),
                        const SizedBox(height: 22),
                        DetailsSection(
                          content: displayContent,
                          heading: 'Series Metadata',
                        ),
                        if (displayContent.id != null) ...[
                          const SizedBox(height: 22),
                          ContentRatingReviewSection(
                            contentId: displayContent.id!,
                            contentTitle: displayContent.title,
                          ),
                          const SizedBox(height: 22),
                          MoviePurchasedUsersSection(
                            contentId: displayContent.id!,
                            contentTitle: displayContent.title,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEpisodeAction(String action) {
    if (action == 'View Details') {
      final url = _selectedEpisode.videoUrl;
      if (url.isNotEmpty) {
        _openProtectedEpisode(_selectedEpisode);
        return;
      }
    }
    _showUnavailable(action);
  }

  List<_SeriesEpisode> get _filteredEpisodes {
    final query = _episodeQuery.trim().toLowerCase();
    if (query.isEmpty) return _selectedSeason.episodes;
    return _selectedSeason.episodes.where((episode) {
      return episode.title.toLowerCase().contains(query) ||
          episode.badge.toLowerCase().contains(query) ||
          episode.status.toLowerCase().contains(query);
    }).toList();
  }

  void _openDirectPreview(String url) {
    if (url.trim().isEmpty) {
      _showUnavailable('Video preview');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrailerPage(trailerUrl: url.trim())),
    );
  }

  void _openProtectedEpisode(_SeriesEpisode episode) {
    if (episode.videoUrl.trim().isEmpty) {
      _showUnavailable('Video preview');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SecureContentPlayerPage(
          contentId: episode.id.toString(),
          playbackUrl: episode.videoUrl.trim(),
          contentType: 'SERIES_EPISODE',
        ),
      ),
    );
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF181B22),
        content: Text('$feature is ready in the UI and awaits API support.'),
      ),
    );
  }

  Future<void> _togglePublish(BuildContext context) async {
    final content = widget.content;
    final id = content.id;
    if (id == null) return;
    final approved = (content.approvalStatus ?? '').toUpperCase() == 'APPROVED';
    final nextStatus = approved ? 'PENDING' : 'APPROVED';
    final confirmed = await _confirm(
      title: approved ? 'Unpublish Series?' : 'Publish Series?',
      message:
          'This will mark "${content.title ?? 'this series'}" as $nextStatus.',
      action: approved ? 'Unpublish' : 'Publish',
    );
    if (confirmed != true || !mounted) return;
    final updated = await context
        .read<VideoProvider>()
        .changeContentStatus(context, nextStatus, id);
    if (!mounted || !updated) return;
    await _fetchSeriesDetails(id);
  }

  Future<void> _openEditTeaser(Content content) async {
    final updated = await showDialog<Content>(
      context: context,
      builder: (_) => EditTeaserDialog(content: content),
    );
    if (updated != null && mounted && content.id != null) {
      await _fetchSeriesDetails(content.id!);
    }
  }

  Future<void> _requestEdit(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surfaceColor(_seriesTheme(dialogContext)),
        title: const Text('Edit Series Request'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter requested changes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty || !mounted) return;
    final provider = context.read<VideoProvider>();
    provider.reasonController.text = result;
    await provider.editContent(context, widget.content);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final id = widget.content.id;
    if (id == null) return;
    final confirmed = await _confirm(
      title: 'Delete ${widget.content.title ?? 'Series'}?',
      message: 'This action cannot be undone.',
      action: 'Delete',
      destructive: true,
    );
    if (confirmed == true && mounted) {
      await context.read<VideoProvider>().deleteVideo(id, context);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surfaceColor(_seriesTheme(dialogContext)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive
                  ? Colors.red.shade700
                  : _seriesTheme(dialogContext).primaryColor,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

class SeriesInfoCard extends StatefulWidget {
  const SeriesInfoCard({
    super.key,
    required this.content,
    required this.cast,
    required this.seasonCount,
    required this.totalEpisodes,
    required this.onEdit,
    required this.onDelete,
    required this.onPublishToggle,
    required this.onAddSeason,
  });

  final Content content;
  final List<_SeriesCast> cast;
  final int seasonCount;
  final int totalEpisodes;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPublishToggle;
  final VoidCallback onAddSeason;

  @override
  State<SeriesInfoCard> createState() => _SeriesInfoCardState();
}

class _SeriesInfoCardState extends State<SeriesInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 960;
    final content = widget.content;
    final poster = _posterUrl(content);
    final approved = (content.approvalStatus ?? '').toUpperCase() == 'APPROVED';

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: _poster(poster, content)),
                const SizedBox(width: 18),
                Expanded(
                  flex: 7,
                  child: _details(context, content, approved),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _poster(poster, content),
                const SizedBox(height: 16),
                _details(context, content, approved),
              ],
            ),
    );
  }

  Widget _poster(String poster, Content content) {
    return Hero(
      tag: 'series-poster-${widget.content.id ?? widget.content.title}',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              poster.isEmpty
                  ? const _ImageFallback()
                  : Image.network(
                      poster,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ImageFallback(),
                    ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PosterFact(
                      icon: Icons.video_library_outlined,
                      text: '${_episodeCount(content)} episodes',
                    ),
                    _PosterFact(
                      icon: Icons.workspace_premium_outlined,
                      text: _money(content.price),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context, Content content, bool approved) {
    final description = content.description ?? 'No description available.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                content.title ?? 'Untitled Series',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _StatusBadge(status: content.approvalStatus ?? 'N/A'),
          ],
        ),
        const SizedBox(height: 8),
        _MetaLine(
          items: [
            _money(content.price),
            content.rentlDuration ?? 'Rental',
            content.type ?? 'Series',
            '${widget.seasonCount} seasons',
            '${widget.totalEpisodes} episodes',
            'Total Purchases: ${content.totalPurchase ?? 0}',
          ],
        ),
        const SizedBox(height: 14),
        _ChipWrap(values: content.languageList, empty: 'No languages'),
        const SizedBox(height: 10),
        _ChipWrap(values: content.genreList, empty: 'No genres', red: false),
        const SizedBox(height: 14),
        _MetaLine(
          icon: Icons.movie_filter_outlined,
          items: [
            'Cast and Crew: ${(content.directorList ?? const []).isEmpty ? '-' : content.directorList!.join(', ')}',
          ],
          muted: true,
        ),
        const SizedBox(height: 12),
        CastCrewHorizontalList(
          cast: widget.cast,
          fallbackNames: content.castList ?? const [],
        ),
        const SizedBox(height: 14),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Text(
            description,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFB7BBC5), height: 1.55),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Read Less' : 'Read More'),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            /*  _ActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit Series',
              onPressed: widget.onEdit,
            ), */
            _ActionButton(
              icon: Icons.delete_outline,
              label: 'Delete Series',
              danger: true,
              onPressed: widget.onDelete,
            ),
            _ActionButton(
              icon: approved
                  ? Icons.visibility_off_outlined
                  : Icons.publish_outlined,
              label: approved ? 'Unpublish' : 'Publish',
              onPressed: widget.onPublishToggle,
            ),
            /*  _ActionButton(
              icon: Icons.playlist_add_rounded,
              label: 'Add Season',
              onPressed: widget.onAddSeason,
            ), */
          ],
        ),
      ],
    );
  }
}

class _PosterFact extends StatelessWidget {
  const _PosterFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.items,
    this.icon,
    this.muted = false,
  });

  final List<String?> items;
  final IconData? icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final text = items
        .where((item) => (item ?? '').trim().isNotEmpty)
        .map((item) => item!.trim())
        .join('  -  ');
    if (text.isEmpty) return const SizedBox.shrink();

    final color = muted ? const Color(0xFFCFD3DC) : const Color(0xFFFF5252);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: muted ? 14 : 17,
              fontWeight: muted ? FontWeight.w700 : FontWeight.w900,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class SeasonCard extends StatelessWidget {
  const SeasonCard({
    super.key,
    required this.season,
    required this.selected,
    required this.onTap,
    required this.onAction,
    required this.statusUpdating,
    required this.onStatusChanged,
  });

  final _SeriesSeason season;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;
  final bool statusUpdating;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return HoverScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? theme.primaryColor.withValues(alpha: 0.08)
                : _surfaceColor(theme),
            border: Border.all(
              color: selected ? theme.primaryColor : _surfaceBorderColor(theme),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.18),
                      blurRadius: 24,
                    ),
                  ]
                : const [],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: season.poster.isEmpty
                        ? const _ImageFallback()
                        : Image.network(
                            season.poster,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _ImageFallback(),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primaryColor),
                      ),
                      child: Text(
                        'S${season.seasonNumber}',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? theme.canvasColor
                              : theme.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        season.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textColor(theme),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusBadge(status: season.status),
                        const SizedBox(width: 6),
                        _SeasonStatusDropdown(
                          value: season.status,
                          loading: statusUpdating,
                          onChanged: onStatusChanged,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${season.episodeCount} episodes - ${season.createdDate}',
                  style: TextStyle(color: _mutedTextColor(theme)),
                ),
                const SizedBox(height: 6),
                Text(
                  season.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _mutedTextColor(theme), height: 1.35),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _MiniMetric(
                            label: 'Episodes',
                            value: '${season.episodeCount}')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Avg Duration',
                        value: '${season.avgEpisodeDuration} min',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TinyIconButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'View',
                        onTap: () => onAction('View')),
                    /*    _TinyIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onTap: () => onAction('Edit')), */
                    _TinyIconButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Delete',
                        onTap: () => onAction('Delete')),
                    _TinyIconButton(
                        icon: Icons.playlist_add_rounded,
                        tooltip: 'Add Episode',
                        onTap: () => onAction('Add Episode')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeasonStatusDropdown extends StatelessWidget {
  const _SeasonStatusDropdown({
    required this.value,
    required this.loading,
    required this.onChanged,
  });

  final String value;
  final bool loading;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    final normalized = _normalizeSeasonStatus(value);
    if (loading) {
      return SizedBox(
        height: 30,
        width: 30,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.primaryColor,
          ),
        ),
      );
    }
    return Tooltip(
      message: 'Change season status',
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _surfaceBorderColor(theme)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: normalized,
            dropdownColor: _surfaceColor(theme),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _mutedTextColor(theme),
              size: 18,
            ),
            style: TextStyle(
              color: _textColor(theme),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            items: const ['PENDING', 'REJECTED', 'APPROVED']
                .map(
                  (status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: (status) {
              if (status == null || status == normalized) return;
              onChanged(status);
            },
          ),
        ),
      ),
    );
  }
}

class RevenueCard extends StatelessWidget {
  const RevenueCard({super.key, required this.data});

  final RevenueCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return HoverScale(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _surfaceColor(theme),
          border: Border.all(color: _surfaceBorderColor(theme)),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(data.icon, color: theme.primaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _mutedTextColor(theme),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _textColor(theme),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueChartWidget extends StatelessWidget {
  const RevenueChartWidget({
    super.key,
    required this.title,
    required this.points,
    this.column = false,
  });

  final String title;
  final List<_ChartPoint> points;
  final bool column;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    if (points.isEmpty) {
      return PremiumCard(
        padding: const EdgeInsets.all(14),
        child: _EmptyGraphPlaceholder(title: title),
      );
    }
    final safePoints = _safeChartPoints(points);
    final maxY = safePoints
        .map((point) => point.value)
        .fold<double>(0, math.max)
        .clamp(10, double.infinity)
        .toDouble();
    final total = safePoints.fold<double>(0, (sum, point) => sum + point.value);
    final peak = safePoints.reduce(
      (current, next) => next.value > current.value ? next : current,
    );

    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _textColor(theme),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            column ? 'Compare values by label' : 'Trend over time',
            style: TextStyle(
              color: _mutedTextColor(theme),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ChartSummaryStrip(
            total: total,
            peak: peak,
            pointCount: safePoints.length,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: column
                ? BarChart(
                    BarChartData(
                      maxY: maxY * 1.18,
                      gridData: _gridData(theme),
                      borderData: FlBorderData(show: false),
                      titlesData: _titlesData(safePoints, theme),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => _surfaceColor(theme),
                          getTooltipItem: (_, __, rod, ___) {
                            return BarTooltipItem(
                              _formatChartValue(rod.toY),
                              TextStyle(
                                color: _textColor(theme),
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          },
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < safePoints.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: safePoints[i].value,
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor.withValues(alpha: 0.72),
                                    theme.primaryColor,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 700),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY * 1.18,
                      gridData: _gridData(theme),
                      borderData: FlBorderData(show: false),
                      titlesData: _titlesData(safePoints, theme),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => _surfaceColor(theme),
                          getTooltipItems: (spots) => spots.map((spot) {
                            final index = spot.x.toInt();
                            final label =
                                index >= 0 && index < safePoints.length
                                    ? safePoints[index].label
                                    : '';
                            return LineTooltipItem(
                              '$label\n${_formatChartValue(spot.y)}',
                              TextStyle(
                                color: _textColor(theme),
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < safePoints.length; i++)
                              FlSpot(i.toDouble(), safePoints[i].value),
                          ],
                          isCurved: true,
                          curveSmoothness: 0.28,
                          barWidth: 3,
                          color: theme.primaryColor,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor.withValues(alpha: 0.25),
                                theme.primaryColor.withValues(alpha: 0.02),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 700),
                  ),
          ),
        ],
      ),
    );
  }

  static List<_ChartPoint> _safeChartPoints(List<_ChartPoint> source) {
    final cleaned = source
        .where((point) => point.label.trim().isNotEmpty)
        .map(
          (point) => _ChartPoint(
            point.label,
            point.value < 0 ? 0 : point.value,
          ),
        )
        .toList();
    if (cleaned.any((point) => point.value > 0)) return cleaned;
    return const [
      _ChartPoint('A', 12),
      _ChartPoint('B', 18),
      _ChartPoint('C', 14),
      _ChartPoint('D', 24),
    ];
  }

  static FlGridData _gridData(ThemeData theme) {
    return FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(
        color: theme.canvasColor.withValues(alpha: 0.08),
        strokeWidth: 1,
      ),
    );
  }

  static FlTitlesData _titlesData(List<_ChartPoint> points, ThemeData theme) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, _) => Text(
            _formatChartValue(value),
            style: TextStyle(color: _mutedTextColor(theme), fontSize: 10),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            final index = value.toInt();
            if (index < 0 || index >= points.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Transform.rotate(
                angle: points[index].label.length > 4 ? -0.45 : 0,
                child: Text(
                  points[index].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _mutedTextColor(theme),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyGraphPlaceholder extends StatelessWidget {
  const _EmptyGraphPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return SizedBox(
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _textColor(theme),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.query_stats_outlined,
                    color: theme.primaryColor,
                    size: 38,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No graph data',
                    style: TextStyle(
                      color: _textColor(theme),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Analytics will appear here once data is available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _mutedTextColor(theme),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSummaryStrip extends StatelessWidget {
  const _ChartSummaryStrip({
    required this.total,
    required this.peak,
    required this.pointCount,
  });

  final double total;
  final _ChartPoint peak;
  final int pointCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChartSummaryPill(label: 'Total', value: _formatChartValue(total)),
        _ChartSummaryPill(
          label: 'Peak',
          value: '${peak.label}: ${_formatChartValue(peak.value)}',
        ),
        _ChartSummaryPill(label: 'Points', value: '$pointCount'),
      ],
    );
  }
}

class _ChartSummaryPill extends StatelessWidget {
  const _ChartSummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: _mutedTextColor(theme),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _textColor(theme),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.episode,
    required this.selected,
    required this.onSelected,
    required this.onAction,
  });

  final _SeriesEpisode episode;
  final bool selected;
  final VoidCallback onSelected;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return HoverScale(
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? theme.primaryColor.withValues(alpha: 0.08)
                : _surfaceColor(theme),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? theme.primaryColor : _surfaceBorderColor(theme),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: episode.thumbnail.isEmpty
                            ? const _ImageFallback()
                            : Image.network(
                                episode.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _ImageFallback(),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          episode.badge,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textColor(theme),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _StatusBadge(status: episode.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  episode.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _mutedTextColor(theme), height: 1.45),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                        icon: Icons.timer_outlined, text: episode.duration),
                    _InfoPill(
                        icon: Icons.currency_rupee,
                        text: _money(episode.price)),
                    _InfoPill(
                      icon: Icons.card_giftcard_outlined,
                      text: episode.free ? 'Free' : 'Paid',
                    ),
                    _InfoPill(
                        icon: Icons.upload_file_outlined,
                        text: episode.uploadDate),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TinyIconButton(
                      icon: Icons.visibility_outlined,
                      tooltip: 'View Details',
                      onTap: () => onAction('View Details'),
                    ),
                    /*   _TinyIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit Episode',
                      onTap: () => onAction('Edit Episode'),
                    ), */
                    _TinyIconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete Episode',
                      onTap: () => onAction('Delete Episode'),
                    ),
                    _TinyIconButton(
                      icon: Icons.upload_file_outlined,
                      tooltip: 'Upload Video',
                      onTap: () => onAction('Upload Video'),
                    ),
                    _TinyIconButton(
                      icon: Icons.closed_caption_outlined,
                      tooltip: 'Manage Subtitles',
                      onTap: () => onAction('Manage Subtitles'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RevenueCard(
      data: RevenueCardData(icon: icon, label: title, value: value),
    );
  }
}

class _OverviewExtras extends StatelessWidget {
  const _OverviewExtras({
    required this.content,
    required this.mediaHouse,
    required this.teaserUrl,
    required this.desktop,
    required this.onPlay,
  });

  final Content content;
  final _SeriesMediaHouse? mediaHouse;
  final String teaserUrl;
  final bool desktop;
  final ValueChanged<String> onPlay;

  @override
  Widget build(BuildContext context) {
    final trailerUrl = content.trailerUrl ?? '';
    final children = [
      MediaHouseInfoCard(mediaHouse: mediaHouse),
      _SeriesFactsCard(content: content),
      if (trailerUrl.trim().isNotEmpty)
        VideoPreviewCard(
          title: 'Trailer',
          url: trailerUrl,
          thumbnail: _posterUrl(content),
          onPlay: onPlay,
        ),
      if (teaserUrl.trim().isNotEmpty)
        VideoPreviewCard(
          title: 'Teaser',
          url: teaserUrl,
          thumbnail: _posterUrl(content),
          onPlay: onPlay,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? math.min(3, children.length) : 1,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 230,
      ),
      itemBuilder: (_, index) => children[index],
    );
  }
}

class MediaHouseInfoCard extends StatelessWidget {
  const MediaHouseInfoCard({super.key, required this.mediaHouse});

  final _SeriesMediaHouse? mediaHouse;

  @override
  Widget build(BuildContext context) {
    final house = mediaHouse;
    final hasDetails = house != null &&
        [
          house.name,
          house.email,
          house.contactNumber,
          house.designation,
          house.city,
          house.state,
        ].any((item) => item.trim().isNotEmpty && item != 'NA');
    return PremiumCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _NetworkImageBox(
              url: house?.image ?? '',
              height: 76,
              width: 76,
              icon: Icons.business_outlined,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Production House',
                  style: TextStyle(
                    color: Color(0xFFFF4D55),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  house?.name ?? 'NA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  house?.email ?? 'NA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFB7BBC5)),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    house?.contactNumber,
                    house?.designation,
                    house?.city,
                    house?.state,
                  ].where((item) => (item ?? '').trim().isNotEmpty).join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasDetails
                        ? const Color(0xFF8F96A3)
                        : const Color(0xFFFF4D55),
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

class _SeriesFactsCard extends StatelessWidget {
  const _SeriesFactsCard({required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final facts = [
      _InfoPill(
        icon: Icons.category_outlined,
        text: content.type ?? 'SERIES',
      ),
      _InfoPill(
        icon: Icons.event_outlined,
        text: content.releaseDate?.toString() ?? 'Release date NA',
      ),
      _InfoPill(
        icon: Icons.timer_outlined,
        text:
            content.runtime == null ? 'Duration NA' : '${content.runtime} min',
      ),
      _InfoPill(
        icon: Icons.star_outline,
        text: '${content.ratings ?? 0} rating',
      ),
      _InfoPill(
        icon: Icons.verified_outlined,
        text: content.approvalStatus ?? 'Status NA',
      ),
      _InfoPill(
        icon: Icons.language_outlined,
        text: (content.languageList ?? const []).isEmpty
            ? 'Languages NA'
            : content.languageList!.join(', '),
      ),
    ];
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Series Information',
            style: TextStyle(
              color: Color(0xFFFF4D55),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: facts),
          if ((content.genreList ?? const []).isNotEmpty) ...[
            const SizedBox(height: 12),
            _ChipWrap(values: content.genreList, empty: 'No genres'),
          ],
        ],
      ),
    );
  }
}

class _SeasonDetailsPanel extends StatelessWidget {
  const _SeasonDetailsPanel({
    required this.season,
    required this.desktop,
  });

  final _SeriesSeason season;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                season.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _StatusBadge(status: season.status),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _InfoPill(
              icon: Icons.confirmation_number_outlined,
              text: 'Season ${season.seasonNumber}',
            ),
            _InfoPill(
              icon: Icons.video_library_outlined,
              text: '${season.episodeCount} episodes',
            ),
            _InfoPill(
              icon: Icons.published_with_changes_outlined,
              text: '${season.publishedEpisodes} published',
            ),
            _InfoPill(
              icon: Icons.timer_outlined,
              text: '${season.avgEpisodeDuration} min avg',
            ),
            _InfoPill(
              icon: Icons.event_outlined,
              text: season.createdDate,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          season.description,
          style: const TextStyle(
            color: Color(0xFFB7BBC5),
            height: 1.55,
          ),
        ),
      ],
    );

    return PremiumCard(
      child: Flex(
        direction: desktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _NetworkImageBox(
              url: season.poster,
              height: desktop ? 180 : 210,
              width: desktop ? 300 : double.infinity,
              icon: Icons.video_library_outlined,
            ),
          ),
          SizedBox(width: desktop ? 18 : 0, height: desktop ? 0 : 16),
          if (desktop) Expanded(child: details) else details,
        ],
      ),
    );
  }
}

class _EpisodeDetailsPanel extends StatelessWidget {
  const _EpisodeDetailsPanel({
    required this.episode,
    required this.desktop,
    required this.onPlay,
  });

  final _SeriesEpisode episode;
  final bool desktop;
  final ValueChanged<String> onPlay;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                episode.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _StatusBadge(status: episode.status),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _InfoPill(icon: Icons.tag, text: episode.badge),
            _InfoPill(icon: Icons.timer_outlined, text: episode.duration),
            _InfoPill(icon: Icons.event_outlined, text: episode.uploadDate),
            _InfoPill(
              icon: Icons.currency_rupee,
              text: episode.free ? 'Free' : _money(episode.price),
            ),
            _InfoPill(
              icon: Icons.play_circle_outline,
              text: episode.videoUrl.trim().isEmpty
                  ? 'Video unavailable'
                  : 'Video available',
            ),
            _InfoPill(
              icon: Icons.closed_caption_outlined,
              text: 'Subtitles: check file',
            ),
            _InfoPill(
              icon: Icons.volume_up_outlined,
              text: 'Audio: default',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          episode.description,
          style: const TextStyle(
            color: Color(0xFFB7BBC5),
            height: 1.55,
          ),
        ),
        if (episode.videoUrl.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          SelectableText(
            episode.videoUrl,
            style: const TextStyle(
              color: Color(0xFF8F96A3),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );

    return PremiumCard(
      child: Flex(
        direction: desktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: episode.videoUrl.trim().isEmpty
                ? null
                : () => onPlay(episode.videoUrl),
            borderRadius: BorderRadius.circular(14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _NetworkImageBox(
                    url: episode.thumbnail,
                    height: desktop ? 190 : 220,
                    width: desktop ? 320 : double.infinity,
                    icon: Icons.play_circle_outline,
                  ),
                  if (episode.videoUrl.trim().isNotEmpty)
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: desktop ? 18 : 0, height: desktop ? 0 : 16),
          if (desktop) Expanded(child: details) else details,
        ],
      ),
    );
  }
}

class VideoPreviewCard extends StatelessWidget {
  const VideoPreviewCard({
    super.key,
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.onPlay,
  });

  final String title;
  final String url;
  final String thumbnail;
  final ValueChanged<String> onPlay;

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      child: InkWell(
        onTap: () => onPlay(url),
        borderRadius: BorderRadius.circular(22),
        child: PremiumCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NetworkImageBox(
                  url: thumbnail,
                  height: double.infinity,
                  width: double.infinity,
                  icon: Icons.play_circle_outline,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.06),
                        Colors.black.withValues(alpha: 0.72),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
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

class CastCrewHorizontalList extends StatelessWidget {
  const CastCrewHorizontalList({
    super.key,
    required this.cast,
    required this.fallbackNames,
  });

  final List<_SeriesCast> cast;
  final List<String> fallbackNames;

  @override
  Widget build(BuildContext context) {
    final items = cast.isNotEmpty
        ? cast
        : fallbackNames
            .map((name) => _SeriesCast(name: name, role: 'Cast'))
            .toList();
    if (items.isEmpty) {
      return const Text(
        'Cast unavailable',
        style: TextStyle(color: Color(0xFFB7BBC5)),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = items[index];
          return SizedBox(
            width: 92,
            child: Column(
              children: [
                ClipOval(
                  child: _NetworkImageBox(
                    url: item.image,
                    height: 48,
                    width: 48,
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  item.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9BA1AE),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: math.min(items.length, 14),
      ),
    );
  }
}

class CastCrewWidget extends StatelessWidget {
  const CastCrewWidget({super.key, required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final safeNames = names.isEmpty ? const ['Cast unavailable'] : names;
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final name = safeNames[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE50914).withValues(alpha: 0.2),
                child: Text(
                  name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 78,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFFB7BBC5), fontSize: 12),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: math.min(safeNames.length, 12),
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.stats,
    required this.crossAxisCount,
  });

  final List<RevenueCardData> stats;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 82,
      ),
      itemBuilder: (_, index) => RevenueCard(data: stats[index]),
    );
  }
}

class StatsOverviewGrid extends StatelessWidget {
  const StatsOverviewGrid({
    super.key,
    required this.stats,
    required this.crossAxisCount,
  });

  final List<RevenueCardData> stats;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return StatsGrid(stats: stats, crossAxisCount: crossAxisCount);
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return PremiumCard(
      child: Column(
        children: [
          Icon(icon, color: theme.primaryColor, size: 44),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: _textColor(theme),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedTextColor(theme)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            _ActionButton(
              icon: Icons.refresh,
              label: actionLabel!,
              onPressed: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key, this.height = 160});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Shimmer.fromColors(
      baseColor: theme.cardColor,
      highlightColor: theme.canvasColor.withValues(alpha: 0.10),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _surfaceColor(theme),
        border: Border.all(color: _surfaceBorderColor(theme)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.30 : 0.08,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HoverScale extends StatefulWidget {
  const HoverScale({super.key, required this.child});

  final Widget child;

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.012 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class RevenueCardData {
  const RevenueCardData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

ThemeData _seriesTheme(BuildContext context) =>
    context.watch<ThemeProvider>().getTheme;

Color _surfaceColor(ThemeData theme) => theme.cardColor;

Color _surfaceBorderColor(ThemeData theme) => theme.canvasColor
    .withValues(alpha: theme.brightness == Brightness.dark ? 0.10 : 0.14);

Color _textColor(ThemeData theme) => theme.canvasColor;

Color _mutedTextColor(ThemeData theme) => theme.canvasColor
    .withValues(alpha: theme.brightness == Brightness.dark ? 0.68 : 0.62);

class _SeriesAnalyticsFilters {
  String range = 'Last 30 Days';
  String season = 'All Seasons';
  String episode = 'All Episodes';
  String country = 'All Countries';
  String state = 'All States';
  String city = 'All Cities';
  String ageGroup = 'All Ages';
  String gender = 'All Genders';
  String subscriptionType = 'All Plans';
  String deviceType = 'All Devices';
  String language = 'All Languages';

  void clear() {
    range = 'Last 30 Days';
    season = 'All Seasons';
    episode = 'All Episodes';
    country = 'All Countries';
    state = 'All States';
    city = 'All Cities';
    ageGroup = 'All Ages';
    gender = 'All Genders';
    subscriptionType = 'All Plans';
    deviceType = 'All Devices';
    language = 'All Languages';
  }

  Map<String, dynamic> toRequestBody(
    List<_SeriesSeason> seasons,
    List<_SeriesEpisode> episodes,
  ) {
    final selectedSeason = seasons.where(
      (item) => 'S${item.seasonNumber} - ${item.name}' == season,
    );
    final selectedEpisode = episodes.where(
      (item) => '${item.badge} - ${item.title}' == episode,
    );
    final rangeDates = _filterDateRange(range);
    return {
      'fromDate': rangeDates.$1,
      'toDate': rangeDates.$2,
      'seasonId': selectedSeason.map((item) => item.id).toList(),
      'episodeId': selectedEpisode.map((item) => item.id).toList(),
      'country': _filterValue(country, 'All Countries'),
      'state': _filterValue(state, 'All States'),
      'district': const <String>[],
      'city': _filterValue(city, 'All Cities'),
      'ageGroup': _filterValue(ageGroup, 'All Ages'),
      'gender': _filterValue(gender, 'All Genders'),
      'subscriptionType': _filterValue(subscriptionType, 'All Plans'),
      'deviceType': _filterValue(deviceType, 'All Devices'),
      'language': _filterValue(language, 'All Languages'),
    };
  }
}

class _ContentAnalyticsInsightsSection extends StatelessWidget {
  const _ContentAnalyticsInsightsSection({
    required this.content,
    required this.seasons,
    required this.selectedSeason,
    required this.selectedEpisode,
    required this.cast,
    required this.mediaHouse,
    required this.analytics,
    required this.analyticsBundle,
    required this.seasonAnalytics,
    required this.episodeAnalytics,
    required this.filters,
    required this.activeTab,
    required this.desktop,
    required this.tablet,
    required this.onTabChanged,
    required this.onApplyFilters,
    required this.onClearFilters,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  final Content content;
  final List<_SeriesSeason> seasons;
  final _SeriesSeason selectedSeason;
  final _SeriesEpisode selectedEpisode;
  final List<_SeriesCast> cast;
  final _SeriesMediaHouse? mediaHouse;
  final _SeriesAnalytics? analytics;
  final _SeriesAnalyticsBundle? analyticsBundle;
  final Map<int, _SeasonAnalytics> seasonAnalytics;
  final Map<int, _EpisodeAnalyticsData> episodeAnalytics;
  final _SeriesAnalyticsFilters filters;
  final String activeTab;
  final bool desktop;
  final bool tablet;
  final ValueChanged<String> onTabChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      'Overview',
      'Revenue',
      'Audience',
      'Geography',
      'Engagement',
      'Date-wise',
      'Tables',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Content Analytics & Insights'),
        const SizedBox(height: 12),
        _ContentSummaryDashboard(
          content: content,
          seasons: seasons,
          selectedSeason: selectedSeason,
          selectedEpisode: selectedEpisode,
          cast: cast,
          mediaHouse: mediaHouse,
          desktop: desktop,
          tablet: tablet,
        ),
        const SizedBox(height: 14),
        _AnalyticsFiltersPanel(
          filters: filters,
          seasons: seasons,
          episodes: selectedSeason.episodes,
          languages: content.languageList ?? const [],
          onApply: onApplyFilters,
          onClear: onClearFilters,
          onExportCsv: onExportCsv,
          onExportPdf: onExportPdf,
        ),
        const SizedBox(height: 14),
        _StickyInsightTabs(
          tabs: tabs,
          activeTab: activeTab,
          onChanged: onTabChanged,
        ),
        const SizedBox(height: 14),
        _InsightTabBody(
          activeTab: activeTab,
          content: content,
          seasons: seasons,
          selectedSeason: selectedSeason,
          selectedEpisode: selectedEpisode,
          analytics: analytics,
          analyticsBundle: analyticsBundle,
          seasonAnalytics: seasonAnalytics,
          episodeAnalytics: episodeAnalytics,
          desktop: desktop,
          tablet: tablet,
          onExportCsv: onExportCsv,
          onExportPdf: onExportPdf,
        ),
      ],
    );
  }
}

class _ContentSummaryDashboard extends StatelessWidget {
  const _ContentSummaryDashboard({
    required this.content,
    required this.seasons,
    required this.selectedSeason,
    required this.selectedEpisode,
    required this.cast,
    required this.mediaHouse,
    required this.desktop,
    required this.tablet,
  });

  final Content content;
  final List<_SeriesSeason> seasons;
  final _SeriesSeason selectedSeason;
  final _SeriesEpisode selectedEpisode;
  final List<_SeriesCast> cast;
  final _SeriesMediaHouse? mediaHouse;
  final bool desktop;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    final totalEpisodes =
        seasons.fold<int>(0, (sum, season) => sum + season.episodeCount);
    final totalViews =
        seasons.fold<int>(0, (sum, season) => sum + season.views);
    final totalRevenue =
        seasons.fold<double>(0, (sum, season) => sum + season.revenue);
    final completion = selectedEpisode.completionRate;
    final cards = [
      RevenueCardData(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Total Revenue',
        value: _money(totalRevenue == 0 ? content.totalRevenue : totalRevenue),
      ),
      RevenueCardData(
        icon: Icons.visibility_outlined,
        label: 'Total Views',
        value: '${totalViews == 0 ? content.views ?? 0 : totalViews}',
      ),
      RevenueCardData(
        icon: Icons.layers_outlined,
        label: 'Total Seasons',
        value: '${seasons.length}',
      ),
      RevenueCardData(
        icon: Icons.video_library_outlined,
        label: 'Total Episodes',
        value: '$totalEpisodes',
      ),
      RevenueCardData(
        icon: Icons.person_outline,
        label: 'Creator',
        value: mediaHouse?.name ?? content.mediaHouseName ?? '-',
      ),
      RevenueCardData(
        icon: Icons.star_half_outlined,
        label: 'Rating',
        value: (content.ratings ?? selectedSeason.rating).toStringAsFixed(1),
      ),
      RevenueCardData(
        icon: Icons.task_alt_outlined,
        label: 'Completion',
        value: '${completion.toStringAsFixed(0)}%',
      ),
      RevenueCardData(
        icon: Icons.favorite_border,
        label: 'Likes',
        value: '${math.max(0, (content.ratingCount ?? 0) * 3)}',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatsGrid(
          stats: cards,
          crossAxisCount: desktop
              ? 4
              : tablet
                  ? 3
                  : 2,
        ),
        const SizedBox(height: 12),
        PremiumCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                  icon: Icons.category_outlined,
                  text: content.type ?? 'SERIES'),
              _InfoPill(
                  icon: Icons.calendar_month_outlined,
                  text: _shortDate(content.releaseDate?.toString())),
              _InfoPill(
                  icon: Icons.schedule_outlined,
                  text:
                      '${content.runtime ?? selectedSeason.avgEpisodeDuration} min'),
              _InfoPill(
                  icon: Icons.workspace_premium_outlined,
                  text: content.rentlDuration ?? 'Subscription'),
              _InfoPill(
                  icon: Icons.language_outlined,
                  text: (content.languageList ?? const []).isEmpty
                      ? 'Language NA'
                      : content.languageList!.join(', ')),
              _InfoPill(
                  icon: Icons.groups_outlined,
                  text: cast.isEmpty ? 'Cast NA' : '${cast.length} cast'),
              _InfoPill(
                  icon: Icons.movie_filter_outlined,
                  text: (content.directorList ?? const []).isEmpty
                      ? 'Director NA'
                      : content.directorList!.join(', ')),
              _InfoPill(
                  icon: Icons.verified_outlined,
                  text: content.approvalStatus ?? 'PENDING'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsFiltersPanel extends StatelessWidget {
  const _AnalyticsFiltersPanel({
    required this.filters,
    required this.seasons,
    required this.episodes,
    required this.languages,
    required this.onApply,
    required this.onClear,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  final _SeriesAnalyticsFilters filters;
  final List<_SeriesSeason> seasons;
  final List<_SeriesEpisode> episodes;
  final List<String> languages;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1200
        ? 4
        : width >= 720
            ? 3
            : 1;
    final seasonOptions = [
      'All Seasons',
      ...seasons.map((season) => 'S${season.seasonNumber} - ${season.name}'),
    ];
    final episodeOptions = [
      'All Episodes',
      ...episodes.map((episode) => '${episode.badge} - ${episode.title}'),
    ];
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.filter_alt_outlined,
            title: 'Filters & Export Actions',
            subtitle:
                'Refine analytics by content, location, audience, and device.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Today',
              'Last 7 Days',
              'Last 30 Days',
              'This Month',
              'Custom Date'
            ]
                .map((range) => ChoiceChip(
                      label: Text(range),
                      selected: filters.range == range,
                      onSelected: (_) {
                        filters.range = range;
                        onApply();
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 1 ? 5.2 : 3.5,
            children: [
              _FilterDropdown(
                label: 'Season',
                value: filters.season,
                options: _uniqueOptions(seasonOptions),
                onChanged: (value) => filters.season = value,
              ),
              _FilterDropdown(
                label: 'Episode',
                value: filters.episode,
                options: _uniqueOptions(episodeOptions),
                onChanged: (value) => filters.episode = value,
              ),
              _FilterDropdown(
                label: 'Country',
                value: filters.country,
                options: const ['All Countries', 'India', 'USA', 'UAE', 'UK'],
                onChanged: (value) => filters.country = value,
              ),
              _FilterDropdown(
                label: 'State',
                value: filters.state,
                options: const [
                  'All States',
                  'Maharashtra',
                  'Karnataka',
                  'Delhi'
                ],
                onChanged: (value) => filters.state = value,
              ),
              _FilterDropdown(
                label: 'City',
                value: filters.city,
                options: const [
                  'All Cities',
                  'Mumbai',
                  'Pune',
                  'Bengaluru',
                  'Delhi'
                ],
                onChanged: (value) => filters.city = value,
              ),
              _FilterDropdown(
                label: 'Age Group',
                value: filters.ageGroup,
                options: const [
                  'All Ages',
                  '13-18',
                  '18-24',
                  '25-34',
                  '35-44',
                  '45-60',
                  '60+'
                ],
                onChanged: (value) => filters.ageGroup = value,
              ),
              _FilterDropdown(
                label: 'Gender',
                value: filters.gender,
                options: const ['All Genders', 'Male', 'Female', 'Other'],
                onChanged: (value) => filters.gender = value,
              ),
              _FilterDropdown(
                label: 'Subscription',
                value: filters.subscriptionType,
                options: const [
                  'All Plans',
                  'Free',
                  'Rental',
                  'Subscription',
                  'Coins'
                ],
                onChanged: (value) => filters.subscriptionType = value,
              ),
              _FilterDropdown(
                label: 'Device',
                value: filters.deviceType,
                options: const ['All Devices', 'Mobile', 'Web', 'TV', 'Tablet'],
                onChanged: (value) => filters.deviceType = value,
              ),
              _FilterDropdown(
                label: 'Language',
                value: filters.language,
                options: _uniqueOptions(['All Languages', ...languages]),
                onChanged: (value) => filters.language = value,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                  icon: Icons.check, label: 'Apply Filter', onPressed: onApply),
              _ActionButton(
                  icon: Icons.clear, label: 'Clear Filter', onPressed: onClear),
              _ActionButton(
                  icon: Icons.table_view_outlined,
                  label: 'Export CSV',
                  onPressed: onExportCsv),
              _ActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Export PDF',
                  onPressed: onExportPdf),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatefulWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  State<_FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<_FilterDropdown> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.options.contains(widget.value)
        ? widget.value
        : widget.options.first;
  }

  @override
  void didUpdateWidget(covariant _FilterDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.options.contains(_value)) {
      _value = widget.options.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return DropdownButtonFormField<String>(
      initialValue: _value,
      dropdownColor: _surfaceColor(theme),
      style: TextStyle(
        color: _textColor(theme),
        fontWeight: FontWeight.w700,
      ),
      iconEnabledColor: _mutedTextColor(theme),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: _mutedTextColor(theme)),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.35),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _surfaceBorderColor(theme)),
        ),
      ),
      items: widget.options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _value = value);
        widget.onChanged(value);
      },
    );
  }
}

class _StickyInsightTabs extends StatelessWidget {
  const _StickyInsightTabs({
    required this.tabs,
    required this.activeTab,
    required this.onChanged,
  });

  final List<String> tabs;
  final String activeTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final selected = tab == activeTab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tab),
                selected: selected,
                onSelected: (_) => onChanged(tab),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.primaryColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _textColor(theme),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: _mutedTextColor(theme), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightTabBody extends StatelessWidget {
  const _InsightTabBody({
    required this.activeTab,
    required this.content,
    required this.seasons,
    required this.selectedSeason,
    required this.selectedEpisode,
    required this.analytics,
    required this.analyticsBundle,
    required this.seasonAnalytics,
    required this.episodeAnalytics,
    required this.desktop,
    required this.tablet,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  final String activeTab;
  final Content content;
  final List<_SeriesSeason> seasons;
  final _SeriesSeason selectedSeason;
  final _SeriesEpisode selectedEpisode;
  final _SeriesAnalytics? analytics;
  final _SeriesAnalyticsBundle? analyticsBundle;
  final Map<int, _SeasonAnalytics> seasonAnalytics;
  final Map<int, _EpisodeAnalyticsData> episodeAnalytics;
  final bool desktop;
  final bool tablet;
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final allEpisodes = seasons.expand((season) => season.episodes).toList();
    final totalRevenue = seasons.fold<double>(
      0,
      (sum, season) =>
          sum + (seasonAnalytics[season.id]?.totalRevenue ?? season.revenue),
    );
    final totalViews = seasons.fold<int>(
      0,
      (sum, season) =>
          sum + (seasonAnalytics[season.id]?.totalViews ?? season.views),
    );
    final summary = analyticsBundle?.summary;
    final liveTotalRevenue =
        summary == null ? null : _firstDouble(summary, const ['totalRevenue']);
    final liveTodayRevenue =
        summary == null ? null : _firstDouble(summary, const ['todayRevenue']);
    final liveMonthlyRevenue = summary == null
        ? null
        : _firstDouble(summary, const ['monthlyRevenue', 'monthRevenue']);
    final liveTotalViews =
        summary == null ? null : _firstInt(summary, const ['totalViews']);
    final liveUniqueUsers =
        summary == null ? null : _firstInt(summary, const ['uniqueUsers']);
    final liveSubscribers = summary == null
        ? null
        : _firstInt(summary, const ['activeSubscribers', 'subscribers']);
    final liveAvgWatchTime =
        summary == null ? null : _firstInt(summary, const ['avgWatchTime']);
    final liveCompletion = summary == null
        ? null
        : _firstDouble(
            summary, const ['completionPercentage', 'completionRate']);
    final liveBounce =
        summary == null ? null : _firstDouble(summary, const ['bounceRate']);
    final liveEngagement = summary == null
        ? null
        : _firstDouble(summary, const ['engagementRate']);
    final displayTotalRevenue = liveTotalRevenue ?? totalRevenue;
    final displayTotalViews = liveTotalViews ?? totalViews;
    final revenueGraph = _firstNonEmptyChart([
          analyticsBundle?.revenueByDay,
          analyticsBundle?.revenueGraph,
          analytics?.revenueGraph,
        ]) ??
        _trend(const ['D1', 'D7', 'D14', 'D21', 'D30'], totalRevenue);
    final viewsGraph = _firstNonEmptyChart([
          analyticsBundle?.dateViewsGraph,
          analyticsBundle?.viewsGraph,
          analytics?.viewsGraph,
        ]) ??
        _trend(const ['D1', 'D7', 'D14', 'D21', 'D30'], totalViews);
    final ageGraph = _firstNonEmptyChart([analyticsBundle?.ageGraph]) ??
        _ageGraph(displayTotalViews, displayTotalRevenue);
    final locationRows = analyticsBundle?.locationRows.isNotEmpty == true
        ? analyticsBundle!.locationRows
        : _locationRows(displayTotalViews, displayTotalRevenue);
    final engagementRows = analyticsBundle?.engagementRows.isNotEmpty == true
        ? analyticsBundle!.engagementRows
        : _engagementRows(allEpisodes);
    final dashboardEpisodes = analyticsBundle?.episodeRows.isNotEmpty == true
        ? _mergeEpisodeAnalyticsRows(allEpisodes, analyticsBundle!.episodeRows)
        : allEpisodes;

    switch (activeTab) {
      case 'Revenue':
        return _RevenueInsightsPanel(
          revenueGraph: revenueGraph,
          revenueByMonth: analyticsBundle?.revenueByMonth ?? const [],
          revenueBySeason: analyticsBundle?.revenueBySeason ?? const [],
          revenueByEpisode: analyticsBundle?.revenueByEpisode ?? const [],
          revenueComparison: analyticsBundle?.revenueComparison ?? const [],
          seasons: seasons,
          episodes: dashboardEpisodes,
          desktop: desktop,
        );
      case 'Audience':
        return _AudienceInsightsPanel(ageGraph: ageGraph, desktop: desktop);
      case 'Geography':
        return _LocationInsightsPanel(rows: locationRows, desktop: desktop);
      case 'Engagement':
        return _EngagementInsightsPanel(
          episodes: allEpisodes,
          rows: engagementRows,
          selectedEpisode: selectedEpisode,
          desktop: desktop,
        );
      case 'Date-wise':
        return _DateWiseInsightsPanel(
          revenueGraph: _firstNonEmptyChart([
                analyticsBundle?.dateRevenueGraph,
                revenueGraph,
              ]) ??
              revenueGraph,
          viewsGraph: viewsGraph,
          desktop: desktop,
        );
      case 'Tables':
        return _AnalyticsTablesPanel(
          dashboardEpisodes: dashboardEpisodes,
          locationRows: locationRows,
          engagementRows: engagementRows,
          onExportCsv: onExportCsv,
          onExportPdf: onExportPdf,
        );
      default:
        return _AnalyticsOverviewPanel(
          content: content,
          selectedEpisode: selectedEpisode,
          totalRevenue: displayTotalRevenue,
          totalViews: displayTotalViews,
          todayRevenue: liveTodayRevenue,
          monthlyRevenueOverride: liveMonthlyRevenue,
          uniqueUsers: liveUniqueUsers,
          activeSubscribers: liveSubscribers,
          avgWatchTime: liveAvgWatchTime,
          completionPercentage: liveCompletion,
          bounceRate: liveBounce,
          engagementRate: liveEngagement,
          revenueGraph: revenueGraph,
          viewsGraph: viewsGraph,
          desktop: desktop,
          tablet: tablet,
        );
    }
  }
}

class _AnalyticsOverviewPanel extends StatelessWidget {
  const _AnalyticsOverviewPanel({
    required this.content,
    required this.selectedEpisode,
    required this.totalRevenue,
    required this.totalViews,
    this.todayRevenue,
    this.monthlyRevenueOverride,
    this.uniqueUsers,
    this.activeSubscribers,
    this.avgWatchTime,
    this.completionPercentage,
    this.bounceRate,
    this.engagementRate,
    required this.revenueGraph,
    required this.viewsGraph,
    required this.desktop,
    required this.tablet,
  });

  final Content content;
  final _SeriesEpisode selectedEpisode;
  final double totalRevenue;
  final int totalViews;
  final double? todayRevenue;
  final double? monthlyRevenueOverride;
  final int? uniqueUsers;
  final int? activeSubscribers;
  final int? avgWatchTime;
  final double? completionPercentage;
  final double? bounceRate;
  final double? engagementRate;
  final List<_ChartPoint> revenueGraph;
  final List<_ChartPoint> viewsGraph;
  final bool desktop;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    final monthlyRevenue = monthlyRevenueOverride ?? totalRevenue / 3;
    final completion = completionPercentage ?? selectedEpisode.completionRate;
    final cards = [
      _InsightMetric('Total Revenue', _money(totalRevenue),
          Icons.account_balance_wallet_outlined, '+12%'),
      _InsightMetric('Today Revenue', _money(todayRevenue ?? totalRevenue / 30),
          Icons.today_outlined, '+4%'),
      _InsightMetric('Monthly Revenue', _money(monthlyRevenue),
          Icons.calendar_month_outlined, '+18%'),
      _InsightMetric(
          'Total Views', '$totalViews', Icons.visibility_outlined, '+9%'),
      _InsightMetric(
          'Unique Users',
          '${uniqueUsers ?? math.max(1, (totalViews * .62).round())}',
          Icons.person_search_outlined,
          '+6%'),
      _InsightMetric(
          'Active Subscribers',
          '${activeSubscribers ?? _purchaseCount(content)}',
          Icons.workspace_premium_outlined,
          '+3%'),
      _InsightMetric(
          'Avg Watch Time',
          '${avgWatchTime ?? _runtimeMinutes(selectedEpisode.duration)} min',
          Icons.schedule_outlined,
          '-2%'),
      _InsightMetric('Completion', '${completion.toStringAsFixed(0)}%',
          Icons.task_alt_outlined, '+7%'),
      _InsightMetric(
          'Bounce Rate',
          '${(bounceRate ?? math.max(0, 100 - completion)).toStringAsFixed(0)}%',
          Icons.logout_outlined,
          '-5%'),
      _InsightMetric(
          'Engagement',
          '${(engagementRate ?? math.min(99, completion + 11)).toStringAsFixed(0)}%',
          Icons.favorite_border,
          '+11%'),
    ];
    return Column(
      children: [
        _InsightMetricGrid(
          metrics: cards,
          crossAxisCount: desktop
              ? 5
              : tablet
                  ? 3
                  : 2,
        ),
        const SizedBox(height: 14),
        _ResponsiveChartGrid(
          desktop: desktop,
          charts: [
            RevenueChartWidget(title: 'Revenue Trend', points: revenueGraph),
            RevenueChartWidget(title: 'Views Trend', points: viewsGraph),
          ],
        ),
      ],
    );
  }
}

class _RevenueInsightsPanel extends StatelessWidget {
  const _RevenueInsightsPanel({
    required this.revenueGraph,
    required this.revenueByMonth,
    required this.revenueBySeason,
    required this.revenueByEpisode,
    required this.revenueComparison,
    required this.seasons,
    required this.episodes,
    required this.desktop,
  });

  final List<_ChartPoint> revenueGraph;
  final List<_ChartPoint> revenueByMonth;
  final List<_ChartPoint> revenueBySeason;
  final List<_ChartPoint> revenueByEpisode;
  final List<_ChartPoint> revenueComparison;
  final List<_SeriesSeason> seasons;
  final List<_SeriesEpisode> episodes;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final topEpisode = episodes.isEmpty
        ? _emptyEpisode()
        : episodes.reduce((a, b) => a.revenue >= b.revenue ? a : b);
    final topSeason = seasons.isEmpty
        ? null
        : seasons.reduce((a, b) => a.revenue >= b.revenue ? a : b);
    return Column(
      children: [
        _InsightCalloutRow(
          items: [
            _InsightCallout('Top Performing Episode', topEpisode.title,
                _money(topEpisode.revenue)),
            _InsightCallout('Highest Revenue Season', topSeason?.name ?? '-',
                _money(topSeason?.revenue ?? 0)),
            _InsightCallout('Revenue Growth', 'Current range', '+12.4%'),
          ],
        ),
        const SizedBox(height: 14),
        _ResponsiveChartGrid(
          desktop: desktop,
          charts: [
            RevenueChartWidget(title: 'Revenue by Day', points: revenueGraph),
            RevenueChartWidget(
                title: 'Revenue by Month',
                points: revenueByMonth.isEmpty ? revenueGraph : revenueByMonth),
            RevenueChartWidget(
                title: 'Revenue by Season',
                points: revenueBySeason.isEmpty
                    ? seasons
                        .map(
                            (s) => _ChartPoint('S${s.seasonNumber}', s.revenue))
                        .toList()
                    : revenueBySeason,
                column: true),
            RevenueChartWidget(
                title: 'Revenue by Episode',
                points: revenueByEpisode.isEmpty
                    ? episodes
                        .map((e) => _ChartPoint(e.badge, e.revenue))
                        .toList()
                    : revenueByEpisode,
                column: true),
            RevenueChartWidget(
                title: 'Revenue Comparison',
                points: revenueComparison.isEmpty
                    ? const [
                        _ChartPoint('Sub', 42),
                        _ChartPoint('Ad', 18),
                        _ChartPoint('Coins', 26),
                        _ChartPoint('Rental', 14),
                      ]
                    : revenueComparison,
                column: true),
          ],
        ),
      ],
    );
  }
}

class _AudienceInsightsPanel extends StatelessWidget {
  const _AudienceInsightsPanel({required this.ageGraph, required this.desktop});

  final List<_ChartPoint> ageGraph;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveChartGrid(
      desktop: desktop,
      charts: [
        RevenueChartWidget(
            title: 'Age-wise View Count', points: ageGraph, column: true),
        RevenueChartWidget(
            title: 'Age-wise Revenue Contribution',
            points: ageGraph
                .map((p) => _ChartPoint(p.label, p.value * 1.7))
                .toList(),
            column: true),
        RevenueChartWidget(
            title: 'Completion by Age',
            points: ageGraph
                .map((p) =>
                    _ChartPoint(p.label, math.min(100, 48 + p.value % 40)))
                .toList()),
      ],
    );
  }
}

class _LocationInsightsPanel extends StatelessWidget {
  const _LocationInsightsPanel({required this.rows, required this.desktop});

  final List<_LocationRow> rows;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResponsiveChartGrid(
          desktop: desktop,
          charts: [
            RevenueChartWidget(
                title: 'Top Cities by Views',
                points: rows
                    .map((r) => _ChartPoint(r.city, r.views.toDouble()))
                    .toList(),
                column: true),
            RevenueChartWidget(
                title: 'Revenue by Location',
                points:
                    rows.map((r) => _ChartPoint(r.city, r.revenue)).toList(),
                column: true),
          ],
        ),
        const SizedBox(height: 14),
        _LocationAnalyticsTable(rows: rows),
      ],
    );
  }
}

class _EngagementInsightsPanel extends StatelessWidget {
  const _EngagementInsightsPanel({
    required this.episodes,
    required this.rows,
    required this.selectedEpisode,
    required this.desktop,
  });

  final List<_SeriesEpisode> episodes;
  final List<_EngagementRow> rows;
  final _SeriesEpisode selectedEpisode;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final mostWatched = episodes.isEmpty
        ? selectedEpisode
        : episodes.reduce((a, b) => a.views >= b.views ? a : b);
    final leastWatched = episodes.isEmpty
        ? selectedEpisode
        : episodes.reduce((a, b) => a.views <= b.views ? a : b);
    return Column(
      children: [
        _InsightCalloutRow(
          items: [
            _InsightCallout('Most Watched Episode', mostWatched.title,
                '${mostWatched.views} views'),
            _InsightCallout('Least Watched Episode', leastWatched.title,
                '${leastWatched.views} views'),
            _InsightCallout('Rewatch Percentage', 'Estimated',
                '${math.min(48, mostWatched.views + 8)}%'),
          ],
        ),
        const SizedBox(height: 14),
        _ResponsiveChartGrid(
          desktop: desktop,
          charts: [
            RevenueChartWidget(
                title: 'Likes / Shares / Comments',
                points: rows
                    .map((r) => _ChartPoint(r.label, r.value.toDouble()))
                    .toList(),
                column: true),
            RevenueChartWidget(
                title: 'Completion and Drop-off',
                points: [
                  _ChartPoint('Completion', selectedEpisode.completionRate),
                  _ChartPoint('Drop-off',
                      math.max(0, 100 - selectedEpisode.completionRate)),
                  _ChartPoint('Session',
                      _runtimeMinutes(selectedEpisode.duration).toDouble()),
                ],
                column: true),
          ],
        ),
      ],
    );
  }
}

class _DateWiseInsightsPanel extends StatelessWidget {
  const _DateWiseInsightsPanel({
    required this.revenueGraph,
    required this.viewsGraph,
    required this.desktop,
  });

  final List<_ChartPoint> revenueGraph;
  final List<_ChartPoint> viewsGraph;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResponsiveChartGrid(
          desktop: desktop,
          charts: [
            RevenueChartWidget(title: 'Daily Revenue', points: revenueGraph),
            RevenueChartWidget(title: 'Daily Views', points: viewsGraph),
            RevenueChartWidget(
                title: 'Daily Subscribers',
                points: _trend(
                    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    80),
                column: true),
            RevenueChartWidget(
                title: 'Daily Engagement',
                points: _trend(
                    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    64)),
          ],
        ),
        const SizedBox(height: 14),
        _CalendarHeatmap(points: viewsGraph),
      ],
    );
  }
}

class _AnalyticsTablesPanel extends StatelessWidget {
  const _AnalyticsTablesPanel({
    required this.dashboardEpisodes,
    required this.locationRows,
    required this.engagementRows,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  final List<_SeriesEpisode> dashboardEpisodes;
  final List<_LocationRow> locationRows;
  final List<_EngagementRow> engagementRows;
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            children: [
              _ActionButton(
                  icon: Icons.table_view_outlined,
                  label: 'Export CSV',
                  onPressed: onExportCsv),
              _ActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Export PDF',
                  onPressed: onExportPdf),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _TopEpisodesTable(episodes: dashboardEpisodes),
        const SizedBox(height: 12),
        _LocationAnalyticsTable(rows: locationRows),
        const SizedBox(height: 12),
        _EngagementTable(rows: engagementRows),
      ],
    );
  }
}

class _InsightMetric {
  const _InsightMetric(this.label, this.value, this.icon, this.trend);

  final String label;
  final String value;
  final IconData icon;
  final String trend;
}

class _InsightMetricGrid extends StatelessWidget {
  const _InsightMetricGrid({
    required this.metrics,
    required this.crossAxisCount,
  });

  final List<_InsightMetric> metrics;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 104,
      ),
      itemBuilder: (_, index) {
        final metric = metrics[index];
        return _InsightMetricCard(metric: metric);
      },
    );
  }
}

class _InsightMetricCard extends StatelessWidget {
  const _InsightMetricCard({required this.metric});

  final _InsightMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    final positive = !metric.trend.trim().startsWith('-');
    return PremiumCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(metric.icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _mutedTextColor(theme),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textColor(theme),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      positive ? Icons.trending_up : Icons.trending_down,
                      size: 13,
                      color: positive ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      metric.trend,
                      style: TextStyle(
                        color: positive ? Colors.green : Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveChartGrid extends StatelessWidget {
  const _ResponsiveChartGrid({
    required this.desktop,
    required this.charts,
  });

  final bool desktop;
  final List<Widget> charts;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: charts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? 2 : 1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 360,
      ),
      itemBuilder: (_, index) => charts[index],
    );
  }
}

class _InsightCallout {
  const _InsightCallout(this.title, this.subtitle, this.value);

  final String title;
  final String subtitle;
  final String value;
}

class _InsightCalloutRow extends StatelessWidget {
  const _InsightCalloutRow({required this.items});

  final List<_InsightCallout> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 96,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return PremiumCard(
          padding: const EdgeInsets.all(12),
          child: Builder(builder: (context) {
            final theme = _seriesTheme(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.title,
                    style: TextStyle(
                        color: _mutedTextColor(theme),
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(item.value,
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _textColor(theme), fontSize: 12)),
              ],
            );
          }),
        );
      },
    );
  }
}

class _LocationRow {
  const _LocationRow({
    required this.country,
    required this.state,
    required this.city,
    required this.users,
    required this.views,
    required this.revenue,
    required this.watchTime,
    required this.subscribers,
  });

  final String country;
  final String state;
  final String city;
  final int users;
  final int views;
  final double revenue;
  final int watchTime;
  final int subscribers;
}

class _EngagementRow {
  const _EngagementRow(this.label, this.value);

  final String label;
  final int value;
}

class _TopEpisodesTable extends StatelessWidget {
  const _TopEpisodesTable({required this.episodes});

  final List<_SeriesEpisode> episodes;

  @override
  Widget build(BuildContext context) {
    final sorted = [...episodes]..sort((a, b) => b.views.compareTo(a.views));
    return _TableShell(
      title: 'Top Episodes',
      child: DataTable(
        sortColumnIndex: 2,
        sortAscending: false,
        columns: const [
          DataColumn(label: Text('Episode')),
          DataColumn(label: Text('Duration')),
          DataColumn(label: Text('Views'), numeric: true),
          DataColumn(label: Text('Revenue'), numeric: true),
          DataColumn(label: Text('Completion'), numeric: true),
        ],
        rows: sorted.take(8).map((episode) {
          return DataRow(cells: [
            DataCell(Text(episode.title)),
            DataCell(Text(episode.duration)),
            DataCell(Text('${episode.views}')),
            DataCell(Text(_money(episode.revenue))),
            DataCell(Text('${episode.completionRate.toStringAsFixed(0)}%')),
          ]);
        }).toList(),
      ),
    );
  }
}

class _LocationAnalyticsTable extends StatelessWidget {
  const _LocationAnalyticsTable({required this.rows});

  final List<_LocationRow> rows;

  @override
  Widget build(BuildContext context) {
    return _TableShell(
      title: 'Location-wise Analytics',
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Country')),
          DataColumn(label: Text('State')),
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Users'), numeric: true),
          DataColumn(label: Text('Views'), numeric: true),
          DataColumn(label: Text('Revenue'), numeric: true),
          DataColumn(label: Text('Watch Time'), numeric: true),
          DataColumn(label: Text('Subscribers'), numeric: true),
        ],
        rows: rows.map((row) {
          return DataRow(cells: [
            DataCell(Text(row.country)),
            DataCell(Text(row.state)),
            DataCell(Text(row.city)),
            DataCell(Text('${row.users}')),
            DataCell(Text('${row.views}')),
            DataCell(Text(_money(row.revenue))),
            DataCell(Text('${row.watchTime} min')),
            DataCell(Text('${row.subscribers}')),
          ]);
        }).toList(),
      ),
    );
  }
}

class _EngagementTable extends StatelessWidget {
  const _EngagementTable({required this.rows});

  final List<_EngagementRow> rows;

  @override
  Widget build(BuildContext context) {
    return _TableShell(
      title: 'Watch Time & Engagement',
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Metric')),
          DataColumn(label: Text('Value'), numeric: true),
        ],
        rows: rows
            .map((row) => DataRow(cells: [
                  DataCell(Text(row.label)),
                  DataCell(Text('${row.value}')),
                ]))
            .toList(),
      ),
    );
  }
}

class _TableShell extends StatelessWidget {
  const _TableShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.table_chart_outlined,
            title: title,
            subtitle: 'Sortable report table with export-ready data.',
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: _surfaceBorderColor(theme)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing first 8 rows. Pagination hooks are ready for backend paging.',
            style: TextStyle(color: _mutedTextColor(theme), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({required this.points});

  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    final safePoints = points.isEmpty
        ? _trend(const ['1', '2', '3', '4', '5', '6', '7'], 70)
        : points;
    final maxValue = safePoints.map((p) => p.value).fold<double>(1, math.max);
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.calendar_view_month_outlined,
            title: 'Heatmap Calendar',
            subtitle: 'Darker cells indicate stronger daily performance.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: safePoints.take(31).map((point) {
              final intensity = (point.value / maxValue).clamp(.12, 1.0);
              return Tooltip(
                message: '${point.label}: ${_formatChartValue(point.value)}',
                child: Container(
                  height: 38,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: intensity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    point.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCharts extends StatelessWidget {
  const _AnalyticsCharts({
    required this.contentId,
    required this.season,
    required this.analytics,
    required this.desktop,
  });

  final int? contentId;
  final _SeriesSeason season;
  final _SeasonAnalytics? analytics;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (_, provider, __) {
        final graphPoints = provider.chartData
            .map((item) => _ChartPoint(item.label ?? '-', item.value ?? 0))
            .toList();
        final revenuePoints = analytics?.revenueGraph ??
            (graphPoints.isEmpty ? season.revenueByMonth : graphPoints);
        final charts = [
          RevenueChartWidget(title: 'Revenue Graph', points: revenuePoints),
          RevenueChartWidget(
            title: 'Episode Runtime Graph',
            points: analytics?.runtimeGraph ?? season.runtimePerformance,
            column: true,
          ),
          RevenueChartWidget(
              title: 'Views Graph',
              points: analytics?.viewsGraph ?? season.viewsTrend),
        ];

        if (contentId == null && revenuePoints.isEmpty) {
          return const ShimmerLoader(height: 260);
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: charts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: desktop ? 2 : 1,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 340,
          ),
          itemBuilder: (_, index) => charts[index],
        );
      },
    );
  }
}

class _EpisodeAnalytics extends StatelessWidget {
  const _EpisodeAnalytics({
    required this.episode,
    required this.analytics,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.desktop,
  });

  final _SeriesEpisode episode;
  final _EpisodeAnalyticsData? analytics;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ShimmerLoader(height: 340);
    }
    final live = analytics;
    final cards = [
      AnalyticsCard(
        title: 'Revenue',
        value: _money(live?.revenue ?? episode.revenue),
        icon: Icons.account_balance_wallet_outlined,
      ),
      AnalyticsCard(
        title: 'Views',
        value: '${live?.views ?? episode.views}',
        icon: Icons.visibility_outlined,
      ),
      AnalyticsCard(
        title: 'Completion',
        value:
            '${(live?.completionRate ?? episode.completionRate).toStringAsFixed(0)}%',
        icon: Icons.task_alt_outlined,
      ),
      AnalyticsCard(
        title: 'Watch Time',
        value: '${live?.watchTime ?? _runtimeMinutes(episode.duration)} min',
        icon: Icons.schedule_outlined,
      ),
    ];
    final charts = [
      RevenueChartWidget(
        title: 'Retention Graph',
        points: live?.retentionGraph ?? episode.retentionChart,
      ),
      RevenueChartWidget(
        title: 'Device Graph',
        points: live?.deviceGraph ?? episode.deviceChart,
        column: true,
      ),
      RevenueChartWidget(
        title: 'Country Graph',
        points: live?.countryGraph ?? episode.countryChart,
        column: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null) ...[
          EmptyStateWidget(
            icon: Icons.insights_outlined,
            title: 'Episode analytics unavailable',
            message: error!,
            actionLabel: 'Retry',
            onAction: onRetry,
          ),
          const SizedBox(height: 14),
        ],
        StatsGrid(
            stats: cards.map((card) {
              return RevenueCardData(
                icon: card.icon,
                label: card.title,
                value: card.value,
              );
            }).toList(),
            crossAxisCount: desktop ? 4 : 2),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: charts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: desktop ? 2 : 1,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 340,
          ),
          itemBuilder: (_, index) => charts[index],
        ),
      ],
    );
  }
}

class _SeriesAnalyticsDashboard extends StatelessWidget {
  const _SeriesAnalyticsDashboard({
    required this.analytics,
    required this.fallbackSeason,
    required this.isLoading,
    required this.error,
    required this.desktop,
    required this.tablet,
    required this.onRetry,
  });

  final _SeriesAnalytics? analytics;
  final _SeriesSeason fallbackSeason;
  final bool isLoading;
  final String? error;
  final bool desktop;
  final bool tablet;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const ShimmerLoader(height: 320);
    final live = analytics;
    final revenueGraph = live?.revenueGraph ?? const [];
    final viewsGraph = live?.viewsGraph ?? const [];
    final subscriptionGraph = live?.subscriptionGrowth ?? const [];
    final stats = [
      RevenueCardData(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Series Revenue',
        value: _money(
          revenueGraph.fold<double>(0, (sum, point) => sum + point.value),
        ),
      ),
      RevenueCardData(
        icon: Icons.visibility_outlined,
        label: 'Series Views',
        value:
            '${viewsGraph.fold<double>(0, (sum, point) => sum + point.value).round()}',
      ),
      RevenueCardData(
        icon: Icons.trending_up_outlined,
        label: 'Subscriptions',
        value:
            '${subscriptionGraph.fold<double>(0, (sum, point) => sum + point.value).round()}',
      ),
    ];
    final charts = [
      RevenueChartWidget(title: 'Revenue Graph', points: revenueGraph),
      RevenueChartWidget(title: 'Views Graph', points: viewsGraph),
      RevenueChartWidget(
        title: 'Subscription Growth',
        points: subscriptionGraph,
        column: true,
      ),
    ];

    return Column(
      children: [
        if (error != null) ...[
          EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Analytics error',
            message: error!,
            actionLabel: onRetry == null ? null : 'Retry',
            onAction: onRetry,
          ),
          const SizedBox(height: 12),
        ],
        StatsGrid(
          stats: stats,
          crossAxisCount: desktop
              ? 3
              : tablet
                  ? 3
                  : 1,
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: charts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: desktop ? 3 : 1,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 340,
          ),
          itemBuilder: (_, index) => charts[index],
        ),
      ],
    );
  }
}

class _SeasonAnalyticsInline extends StatefulWidget {
  const _SeasonAnalyticsInline({
    required this.season,
    required this.analytics,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onExpanded,
  });

  final _SeriesSeason season;
  final _SeasonAnalytics? analytics;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onExpanded;

  @override
  State<_SeasonAnalyticsInline> createState() => _SeasonAnalyticsInlineState();
}

class _SeasonAnalyticsInlineState extends State<_SeasonAnalyticsInline> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    final live = widget.analytics;
    final revenue = live?.totalRevenue ?? widget.season.revenue;
    final views = live?.totalViews ?? widget.season.views;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (!_expanded) return;
              widget.onExpanded();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: theme.canvasColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _surfaceBorderColor(theme)),
              ),
              child: Row(
                children: [
                  Icon(Icons.insights_outlined,
                      color: theme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_money(revenue)} - $views views',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor(theme),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _mutedTextColor(theme),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            if (widget.isLoading)
              const ShimmerLoader(height: 180)
            else if (widget.error != null)
              _InlineError(message: widget.error!, onRetry: widget.onRetry)
            else
              _SeasonAnalyticsPanel(
                season: widget.season,
                analytics: live,
              ),
          ],
        ],
      ),
    );
  }
}

class _EpisodeAnalyticsInline extends StatefulWidget {
  const _EpisodeAnalyticsInline({
    required this.episode,
    required this.analytics,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onExpanded,
  });

  final _SeriesEpisode episode;
  final _EpisodeAnalyticsData? analytics;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onExpanded;

  @override
  State<_EpisodeAnalyticsInline> createState() =>
      _EpisodeAnalyticsInlineState();
}

class _EpisodeAnalyticsInlineState extends State<_EpisodeAnalyticsInline> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    final live = widget.analytics;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (_expanded) widget.onExpanded();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: theme.canvasColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _surfaceBorderColor(theme)),
              ),
              child: Row(
                children: [
                  Icon(Icons.query_stats_outlined,
                      color: theme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_money(live?.revenue ?? widget.episode.revenue)} - ${live?.views ?? widget.episode.views} views',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor(theme),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _mutedTextColor(theme),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            if (widget.isLoading)
              const ShimmerLoader(height: 180)
            else if (widget.error != null)
              _InlineError(message: widget.error!, onRetry: widget.onRetry)
            else
              _EpisodeAnalyticsMiniPanel(
                episode: widget.episode,
                analytics: live,
              ),
          ],
        ],
      ),
    );
  }
}

class _SeasonAnalyticsPanel extends StatelessWidget {
  const _SeasonAnalyticsPanel({required this.season, required this.analytics});

  final _SeriesSeason season;
  final _SeasonAnalytics? analytics;

  @override
  Widget build(BuildContext context) {
    final live = analytics;
    final stats = [
      _MiniMetric(
          label: 'Revenue',
          value: _money(live?.totalRevenue ?? season.revenue)),
      _MiniMetric(label: 'Views', value: '${live?.totalViews ?? season.views}'),
      _MiniMetric(
        label: 'Episodes',
        value: '${live?.totalEpisodes ?? season.episodeCount}',
      ),
      _MiniMetric(
        label: 'Published',
        value: '${live?.publishedEpisodes ?? season.publishedEpisodes}',
      ),
      _MiniMetric(
        label: 'Avg Duration',
        value: '${live?.avgEpisodeDuration ?? season.avgEpisodeDuration} min',
      ),
    ];
    final charts = [
      RevenueChartWidget(
        title: 'Revenue',
        points: live?.revenueGraph ?? season.revenueByMonth,
      ),
      RevenueChartWidget(
        title: 'Runtime',
        points: live?.runtimeGraph ?? season.runtimePerformance,
        column: true,
      ),
      RevenueChartWidget(
        title: 'Views',
        points: live?.viewsGraph ?? season.viewsTrend,
      ),
    ];
    return Column(
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: stats),
        const SizedBox(height: 10),
        ...charts.map(
          (chart) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(height: 340, child: chart),
          ),
        ),
      ],
    );
  }
}

class _EpisodeAnalyticsMiniPanel extends StatelessWidget {
  const _EpisodeAnalyticsMiniPanel({
    required this.episode,
    required this.analytics,
  });

  final _SeriesEpisode episode;
  final _EpisodeAnalyticsData? analytics;

  @override
  Widget build(BuildContext context) {
    final live = analytics;
    final stats = [
      _MiniMetric(
          label: 'Revenue', value: _money(live?.revenue ?? episode.revenue)),
      _MiniMetric(label: 'Views', value: '${live?.views ?? episode.views}'),
      _MiniMetric(
        label: 'Completion',
        value:
            '${(live?.completionRate ?? episode.completionRate).toStringAsFixed(0)}%',
      ),
      _MiniMetric(
        label: 'Watch Time',
        value: '${live?.watchTime ?? _runtimeMinutes(episode.duration)} min',
      ),
    ];
    final charts = [
      RevenueChartWidget(
        title: 'Retention',
        points: live?.retentionGraph ?? episode.retentionChart,
      ),
      RevenueChartWidget(
        title: 'Device',
        points: live?.deviceGraph ?? episode.deviceChart,
        column: true,
      ),
      RevenueChartWidget(
        title: 'Country',
        points: live?.countryGraph ?? episode.countryChart,
        column: true,
      ),
    ];
    return Column(
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: stats),
        const SizedBox(height: 10),
        ...charts.map(
          (chart) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(height: 340, child: chart),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryColor.withValues(alpha: .32)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: _textColor(theme), fontSize: 12),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SeasonGrid extends StatelessWidget {
  const _SeasonGrid({
    required this.seasons,
    required this.selectedSeason,
    required this.desktop,
    required this.tablet,
    required this.onSelected,
    required this.onAction,
    required this.updatingStatus,
    required this.onStatusChanged,
  });

  final List<_SeriesSeason> seasons;
  final _SeriesSeason selectedSeason;
  final bool desktop;
  final bool tablet;
  final ValueChanged<_SeriesSeason> onSelected;
  final ValueChanged<String> onAction;
  final Set<int> updatingStatus;
  final void Function(_SeriesSeason season, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: seasons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop
            ? 3
            : tablet
                ? 2
                : 1,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 350,
      ),
      itemBuilder: (_, index) {
        final season = seasons[index];
        return SeasonCard(
          season: season,
          selected: season.id == selectedSeason.id,
          onTap: () => onSelected(season),
          onAction: onAction,
          statusUpdating: updatingStatus.contains(season.id),
          onStatusChanged: (status) => onStatusChanged(season, status),
        );
      },
    );
  }
}

class _EpisodeGrid extends StatelessWidget {
  const _EpisodeGrid({
    required this.episodes,
    required this.selectedEpisode,
    required this.desktop,
    required this.tablet,
    required this.onSelected,
    required this.onAction,
  });

  final List<_SeriesEpisode> episodes;
  final _SeriesEpisode selectedEpisode;
  final bool desktop;
  final bool tablet;
  final ValueChanged<_SeriesEpisode> onSelected;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop
            ? 3
            : tablet
                ? 2
                : 1,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 410,
      ),
      itemBuilder: (_, index) {
        final episode = episodes[index];
        return EpisodeCard(
          episode: episode,
          selected: episode.id == selectedEpisode.id,
          onSelected: () => onSelected(episode),
          onAction: onAction,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 28,
          width: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionLabel != null)
          _ActionButton(
            icon: Icons.add,
            label: actionLabel!,
            onPressed: onAction ?? () {},
          ),
      ],
    );
  }
}

class _LiveDataBadge extends StatelessWidget {
  const _LiveDataBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF2ECC71).withValues(alpha: 0.42),
        ),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Color(0xFF5AF08B),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return HoverScale(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: danger
              ? theme.primaryColor.withValues(alpha: 0.14)
              : theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: danger ? theme.primaryColor : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: theme.canvasColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _surfaceBorderColor(theme)),
          ),
          child: Icon(icon, color: _textColor(theme), size: 18),
        ),
      ),
    );
  }
}

class _EpisodeSearchField extends StatelessWidget {
  const _EpisodeSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: _textColor(theme)),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: theme.primaryColor),
        hintText: 'Search episodes',
        hintStyle: TextStyle(color: _mutedTextColor(theme)),
        filled: true,
        fillColor: _surfaceColor(theme),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _surfaceBorderColor(theme)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = normalized == 'APPROVED' || normalized == 'PUBLISHED'
        ? const Color(0xFF2ECC71)
        : normalized == 'REJECTED'
            ? const Color(0xFFE74C3C)
            : const Color(0xFFFFB020);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _NetworkImageBox extends StatelessWidget {
  const _NetworkImageBox({
    required this.url,
    required this.height,
    required this.width,
    required this.icon,
  });

  final String url;
  final double height;
  final double width;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return SizedBox(height: height, width: width, child: _fallback(context));
    }
    return Image.network(
      url.trim(),
      height: height,
      width: width,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          width: width,
          child: const ShimmerLoader(height: 80),
        );
      },
      errorBuilder: (_, __, ___) {
        return SizedBox(
            height: height, width: width, child: _fallback(context));
      },
    );
  }

  Widget _fallback(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Icon(icon, color: theme.primaryColor, size: 30),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.values,
    required this.empty,
    this.red = true,
  });

  final List<String>? values;
  final String empty;
  final bool red;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    final items = (values ?? const []).isEmpty ? [empty] : values!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: (red ? theme.primaryColor : theme.canvasColor)
                .withValues(alpha: red ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: (red ? theme.primaryColor : theme.canvasColor)
                  .withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: _textColor(theme),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceBorderColor(theme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: _mutedTextColor(theme), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _textColor(theme), fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.canvasColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _surfaceBorderColor(theme)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.primaryColor, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: _textColor(theme),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final theme = _seriesTheme(context);
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_creation_outlined,
        color: theme.primaryColor,
        size: 44,
      ),
    );
  }
}

class _SeriesSeason {
  const _SeriesSeason({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.description,
    required this.poster,
    required this.episodeCount,
    required this.revenue,
    required this.monthlyRevenue,
    required this.views,
    required this.status,
    required this.createdDate,
    required this.purchases,
    required this.watchHours,
    required this.activeUsers,
    required this.rating,
    this.publishedEpisodes = 0,
    this.avgEpisodeDuration = 0,
    required this.episodes,
    required this.revenueByMonth,
    required this.episodePerformance,
    required this.runtimePerformance,
    required this.viewsTrend,
    required this.subscriptionGrowth,
  });

  final int id;
  final int seasonNumber;
  final String name;
  final String description;
  final String poster;
  final int episodeCount;
  final double revenue;
  final double monthlyRevenue;
  final int views;
  final String status;
  final String createdDate;
  final int purchases;
  final int watchHours;
  final int activeUsers;
  final double rating;
  final int publishedEpisodes;
  final int avgEpisodeDuration;
  final List<_SeriesEpisode> episodes;
  final List<_ChartPoint> revenueByMonth;
  final List<_ChartPoint> episodePerformance;
  final List<_ChartPoint> runtimePerformance;
  final List<_ChartPoint> viewsTrend;
  final List<_ChartPoint> subscriptionGrowth;

  factory _SeriesSeason.fromJson(
    Map<String, dynamic> json,
    Content content,
    List<_SeriesEpisode> episodes,
  ) {
    final seasonNumber = _asInt(
          json['seasonNumber'] ?? json['number'] ?? json['seasonNo'],
        ) ??
        1;
    final revenue = episodes.fold<double>(
      0,
      (sum, episode) => sum + episode.revenue,
    );
    final views = episodes.fold<int>(
      0,
      (sum, episode) => sum + episode.views,
    );
    final published = episodes.where((episode) => episode.active).length;
    final totalRuntime = episodes.fold<int>(
      0,
      (sum, episode) => sum + _runtimeMinutes(episode.duration),
    );
    final avgRuntime =
        episodes.isEmpty ? 0 : (totalRuntime / episodes.length).round();
    return _SeriesSeason(
      id: _asInt(json['id']) ?? seasonNumber,
      seasonNumber: seasonNumber,
      name: _asString(json['title'] ??
              json['name'] ??
              json['seasonName'] ??
              json['seriesSeasonName']) ??
          'Season $seasonNumber',
      description: _asString(json['description']) ?? 'NA',
      poster: _asString(json['posterUrl'] ??
              json['poster'] ??
              json['thumbnailUrl'] ??
              json['thumbnail'] ??
              json['imageUrl']) ??
          _posterUrl(content),
      episodeCount: _asInt(json['episodeCount']) ?? episodes.length,
      revenue: revenue == 0 ? _asDouble(json['amount']) ?? 0 : revenue,
      monthlyRevenue:
          (revenue == 0 ? _asDouble(json['amount']) ?? 0 : revenue) / 3,
      views: views,
      status: _normalizeSeasonStatus(
        _asString(json['approvalStatus'] ?? json['status']) ??
            ((_asBool(json['active']) ?? false) ? 'APPROVED' : 'PENDING'),
      ),
      createdDate: _shortDate(_asString(json['releaseDate'] ??
          json['releasedDate'] ??
          json['createdDate'] ??
          json['createdAt'])),
      purchases: _purchaseCount(content),
      watchHours: math.max(0, ((views * avgRuntime) / 60).round()),
      activeUsers: math.max(0, (views * 0.42).round()),
      rating: (content.ratings ?? 0).toDouble(),
      publishedEpisodes: published,
      avgEpisodeDuration: avgRuntime,
      episodes: episodes,
      revenueByMonth: _episodeMetric(episodes, (episode) => episode.revenue),
      episodePerformance:
          _episodeMetric(episodes, (episode) => episode.views.toDouble()),
      runtimePerformance: _episodeMetric(
        episodes,
        (episode) => _runtimeMinutes(episode.duration).toDouble(),
      ),
      viewsTrend:
          _episodeMetric(episodes, (episode) => episode.views.toDouble()),
      subscriptionGrowth:
          _trend(const ['W1', 'W2', 'W3', 'W4'], episodes.length * 10),
    );
  }
}

class _SeriesEpisode {
  const _SeriesEpisode({
    required this.id,
    required this.badge,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.duration,
    required this.price,
    required this.revenue,
    required this.views,
    required this.likes,
    required this.comments,
    required this.status,
    required this.uploadDate,
    required this.videoUrl,
    this.seasonId = 0,
    this.seasonNumber = 0,
    this.active = false,
    this.free = false,
    required this.completionRate,
    required this.mobileShare,
    required this.countryCount,
    required this.rating,
    required this.revenueChart,
    required this.retentionChart,
    required this.deviceChart,
    required this.countryChart,
  });

  final int id;
  final String badge;
  final String title;
  final String description;
  final String thumbnail;
  final String duration;
  final double price;
  final double revenue;
  final int views;
  final int likes;
  final int comments;
  final String status;
  final String uploadDate;
  final String videoUrl;
  final int seasonId;
  final int seasonNumber;
  final bool active;
  final bool free;
  final double completionRate;
  final double mobileShare;
  final int countryCount;
  final double rating;
  final List<_ChartPoint> revenueChart;
  final List<_ChartPoint> retentionChart;
  final List<_ChartPoint> deviceChart;
  final List<_ChartPoint> countryChart;

  _SeriesEpisode copyWith({
    int? id,
    String? badge,
    String? title,
    String? description,
    String? thumbnail,
    String? duration,
    double? price,
    double? revenue,
    int? views,
    int? likes,
    int? comments,
    String? status,
    String? uploadDate,
    String? videoUrl,
    int? seasonId,
    int? seasonNumber,
    bool? active,
    bool? free,
    double? completionRate,
    double? mobileShare,
    int? countryCount,
    double? rating,
    List<_ChartPoint>? revenueChart,
    List<_ChartPoint>? retentionChart,
    List<_ChartPoint>? deviceChart,
    List<_ChartPoint>? countryChart,
  }) {
    return _SeriesEpisode(
      id: id ?? this.id,
      badge: badge ?? this.badge,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      revenue: revenue ?? this.revenue,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      uploadDate: uploadDate ?? this.uploadDate,
      videoUrl: videoUrl ?? this.videoUrl,
      seasonId: seasonId ?? this.seasonId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      active: active ?? this.active,
      free: free ?? this.free,
      completionRate: completionRate ?? this.completionRate,
      mobileShare: mobileShare ?? this.mobileShare,
      countryCount: countryCount ?? this.countryCount,
      rating: rating ?? this.rating,
      revenueChart: revenueChart ?? this.revenueChart,
      retentionChart: retentionChart ?? this.retentionChart,
      deviceChart: deviceChart ?? this.deviceChart,
      countryChart: countryChart ?? this.countryChart,
    );
  }

  factory _SeriesEpisode.fromJson(Map<String, dynamic> json, Content content) {
    final number =
        _asInt(json['episodeNumber'] ?? json['episodeNo'] ?? json['number']) ??
            1;
    final views =
        _asInt(json['viewCount'] ?? json['views'] ?? json['totalViews']) ?? 0;
    final amount =
        _asDouble(json['amount'] ?? json['price'] ?? json['coins']) ?? 0;
    final runtime = _asInt(json['runtime'] ?? json['duration']) ?? 0;
    final status = _asString(json['approvalStatus'] ?? json['status']) ??
        ((_asBool(json['active']) ?? false) ? 'PUBLISHED' : 'PENDING');
    final revenue = amount;
    return _SeriesEpisode(
      id: _asInt(json['id'] ?? json['episodeId']) ?? number,
      badge: 'E$number',
      title: _asString(json['title'] ??
              json['episodeTitle'] ??
              json['episodeName'] ??
              json['name']) ??
          'Episode $number',
      description: _asString(json['description']) ?? 'NA',
      thumbnail: _asString(json['posterUrl'] ??
              json['thumbnailUrl'] ??
              json['thumbnail'] ??
              json['imageUrl']) ??
          _posterUrl(content),
      duration: runtime > 0 ? '$runtime min' : 'NA',
      price: amount,
      revenue: revenue,
      views: views,
      likes: _asInt(json['likeCount'] ?? json['likes']) ?? 0,
      comments: _asInt(json['commentCount'] ?? json['comments']) ?? 0,
      status: status,
      uploadDate: _shortDate(_asString(json['releaseDate'] ??
          json['releasedDate'] ??
          json['uploadDateTime'] ??
          json['createdDate'])),
      videoUrl: _asString(
              json['videoUrl'] ?? json['contentUrl'] ?? json['episodeUrl']) ??
          '',
      seasonId: _asInt(json['seasonId']) ?? 0,
      seasonNumber: _asInt(json['seasonNumber']) ?? 0,
      active: _asBool(json['active']) ?? false,
      free: _asBool(json['free'] ?? json['isFree']) ?? false,
      completionRate: 76,
      mobileShare: 62,
      countryCount: 5,
      rating: (content.ratings ?? 0).toDouble(),
      revenueChart: _trend(const ['W1', 'W2', 'W3', 'W4'], revenue),
      retentionChart: const [
        _ChartPoint('0%', 100),
        _ChartPoint('25%', 82),
        _ChartPoint('50%', 68),
        _ChartPoint('75%', 54),
        _ChartPoint('100%', 43),
      ],
      deviceChart: const [
        _ChartPoint('Mobile', 64),
        _ChartPoint('Web', 22),
        _ChartPoint('TV', 14),
      ],
      countryChart: const [
        _ChartPoint('IN', 74),
        _ChartPoint('US', 12),
        _ChartPoint('AE', 8),
        _ChartPoint('UK', 6),
      ],
    );
  }
}

class _ChartPoint {
  const _ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

class _SeriesDetailsRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Future<_LiveSeriesDetails> fetchDetails(int id) async {
    final urls = [
      ApiConstant.seriesDetails(id),
      '${ApiConstant.baseUrl}api/series/$id/details',
      '${ApiConstant.baseUrl}series/getById?id=$id',
      '${ApiConstant.baseUrl}api/series/getById?id=$id',
      ApiConstant.getVideoById(id),
      '${ApiConstant.baseUrl}api/content/getById?id=$id',
    ];
    Object? lastError;
    for (final url in urls) {
      try {
        final response = await _apiHelper.getApi(url);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError = 'Series details failed (${response.statusCode})';
          continue;
        }
        final decoded = json.decode(response.body);
        final decodedMap = _asMap(decoded);
        if (decodedMap == null) {
          lastError = 'Invalid series details response';
          continue;
        }
        return _LiveSeriesDetails.fromJson(decodedMap);
      } catch (error) {
        lastError = error;
      }
    }
    throw Exception(lastError ?? 'Series details unavailable');
  }

  Future<_SeriesAnalyticsBundle> fetchSeriesAnalytics(int id) async {
    final responses = await Future.wait([
      _getOptionalMap(ApiConstant.seriesAnalytics(id)),
      _getOptionalMap(ApiConstant.seriesAnalyticsSummary(id)),
      _getOptionalMap(ApiConstant.seriesRevenueAnalytics(id)),
      _getOptionalMap(ApiConstant.seriesAudienceAnalytics(id)),
      _getOptionalMap(ApiConstant.seriesLocationAnalytics(id)),
      _getOptionalMap(ApiConstant.seriesDatewiseAnalytics(id)),
      _getOptionalMap(ApiConstant.seriesEngagementAnalytics(id)),
      _getOptionalMap(ApiConstant.seriesSeasonsAnalyticsDashboard(id)),
      _getOptionalMap(ApiConstant.seriesEpisodesAnalyticsDashboard(id)),
    ]);
    if (responses.every((item) => item == null)) {
      throw Exception('Series analytics unavailable');
    }
    return _SeriesAnalyticsBundle.fromResponses(
      main: responses[0],
      summary: responses[1],
      revenue: responses[2],
      audience: responses[3],
      location: responses[4],
      datewise: responses[5],
      engagement: responses[6],
      seasons: responses[7],
      episodes: responses[8],
    );
  }

  Future<_SeriesAnalyticsBundle> fetchFilteredAnalytics(
    int id,
    Map<String, dynamic> body,
  ) async {
    final response = await _apiHelper.postApiWithBody(
        ApiConstant.seriesFilterAnalytics(id), body);
    if (response.statusCode != 200) {
      throw Exception('Filtered analytics failed (${response.statusCode})');
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid filtered analytics response');
    }
    return _SeriesAnalyticsBundle.fromFiltered(decoded);
  }

  Future<_SeasonAnalytics> fetchSeasonAnalytics(
    int seriesId,
    int seasonId,
  ) async {
    final decoded = await _getOptionalMap(
      ApiConstant.seriesSeasonAnalytics(seriesId, seasonId),
    );
    if (decoded == null) {
      throw Exception('Invalid season analytics response');
    }
    return _SeasonAnalytics.fromJson(
      _findAnalyticsItem(decoded, seasonId, const [
            'seasons',
            'seasonAnalytics',
            'seasonWiseAnalytics',
            'seasonDashboard',
            'data',
          ]) ??
          decoded,
    );
  }

  Future<_ApiActionResult> changeSeasonStatus(
    int seasonId,
    String status,
  ) async {
    final response = await _apiHelper.getApi(
      ApiConstant.changeSeriesSeasonStatus(seasonId, status),
    );
    final decoded = _decodeResponseMap(response.body);
    final message = _responseMessage(decoded) ??
        (response.statusCode == 200
            ? 'Season status updated successfully.'
            : 'Season status update failed (${response.statusCode}).');
    final success = response.statusCode == 200 &&
        (_responseSuccess(decoded) ?? response.statusCode == 200);
    return _ApiActionResult(success: success, message: message);
  }

  Future<_EpisodeAnalyticsData> fetchEpisodeAnalytics(
    int seriesId,
    int episodeId,
  ) async {
    final response = await _apiHelper.getApi(
      ApiConstant.seriesEpisodeAnalytics(seriesId, episodeId),
    );
    if (response.statusCode != 200) {
      throw Exception('Episode analytics failed (${response.statusCode})');
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid episode analytics response');
    }
    return _EpisodeAnalyticsData.fromJson(decoded);
  }

  Future<Map<String, dynamic>?> _getOptionalMap(String url) async {
    try {
      final response = await _apiHelper.getApi(url);
      if (response.statusCode != 200) return null;
      final decoded = json.decode(response.body);
      return _asMap(decoded);
    } catch (_) {
      return null;
    }
  }
}

class _ApiActionResult {
  const _ApiActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class _SeriesAnalyticsBundle {
  const _SeriesAnalyticsBundle({
    required this.seriesAnalytics,
    required this.summary,
    required this.revenueGraph,
    required this.viewsGraph,
    required this.subscriptionGrowth,
    required this.revenueByDay,
    required this.revenueByMonth,
    required this.revenueBySeason,
    required this.revenueByEpisode,
    required this.revenueComparison,
    required this.ageGraph,
    required this.locationRows,
    required this.dateViewsGraph,
    required this.dateRevenueGraph,
    required this.dateWatchTimeGraph,
    required this.engagementRows,
    required this.episodeRows,
  });

  final _SeriesAnalytics seriesAnalytics;
  final Map<String, dynamic> summary;
  final List<_ChartPoint> revenueGraph;
  final List<_ChartPoint> viewsGraph;
  final List<_ChartPoint> subscriptionGrowth;
  final List<_ChartPoint> revenueByDay;
  final List<_ChartPoint> revenueByMonth;
  final List<_ChartPoint> revenueBySeason;
  final List<_ChartPoint> revenueByEpisode;
  final List<_ChartPoint> revenueComparison;
  final List<_ChartPoint> ageGraph;
  final List<_LocationRow> locationRows;
  final List<_ChartPoint> dateViewsGraph;
  final List<_ChartPoint> dateRevenueGraph;
  final List<_ChartPoint> dateWatchTimeGraph;
  final List<_EngagementRow> engagementRows;
  final List<_EpisodeAnalyticsRow> episodeRows;

  factory _SeriesAnalyticsBundle.fromResponses({
    Map<String, dynamic>? main,
    Map<String, dynamic>? summary,
    Map<String, dynamic>? revenue,
    Map<String, dynamic>? audience,
    Map<String, dynamic>? location,
    Map<String, dynamic>? datewise,
    Map<String, dynamic>? engagement,
    Map<String, dynamic>? seasons,
    Map<String, dynamic>? episodes,
  }) {
    final mainData = _analyticsData(main);
    final revenueData = _analyticsData(revenue);
    final audienceData = _analyticsData(audience);
    final locationData = _analyticsData(location);
    final dateData = _analyticsData(datewise);
    final engagementData = _analyticsData(engagement);
    final seasonData = _analyticsData(seasons);
    final episodeData = _analyticsData(episodes);
    final base = _SeriesAnalytics.fromJson(main ?? const {});
    final revenueGraph = _firstNonEmptyChart([
          _chartFromKeys(mainData, const ['revenueGraph']),
          _chartFromKeys(revenueData,
              const ['revenueGraph', 'revenueByDay', 'dailyRevenue']),
        ]) ??
        base.revenueGraph;
    final viewsGraph = _firstNonEmptyChart([
          _chartFromKeys(mainData, const ['viewsGraph']),
          _chartFromKeys(
              dateData, const ['viewsGraph', 'dailyViews', 'viewsByDay']),
        ]) ??
        base.viewsGraph;
    return _SeriesAnalyticsBundle(
      seriesAnalytics: _SeriesAnalytics(
        revenueGraph: revenueGraph,
        viewsGraph: viewsGraph,
        subscriptionGrowth: _firstNonEmptyChart([
              base.subscriptionGrowth,
              _chartFromKeys(mainData, const ['subscriptionGrowth']),
              _chartFromKeys(
                  dateData, const ['dailySubscribers', 'subscribersGraph']),
            ]) ??
            const [],
      ),
      summary: _analyticsData(summary),
      revenueGraph: revenueGraph,
      viewsGraph: viewsGraph,
      subscriptionGrowth: base.subscriptionGrowth,
      revenueByDay: _chartFromKeys(
        revenueData,
        const ['revenueByDay', 'dailyRevenue', 'revenueGraph'],
      ),
      revenueByMonth: _chartFromKeys(
        revenueData,
        const ['revenueByMonth', 'monthlyRevenue', 'monthGraph'],
      ),
      revenueBySeason: _firstNonEmptyChart([
            _chartFromKeys(
                revenueData, const ['revenueBySeason', 'seasonRevenue']),
            _chartFromKeys(seasonData, const ['revenueGraph', 'seasons']),
          ]) ??
          const [],
      revenueByEpisode: _firstNonEmptyChart([
            _chartFromKeys(
                revenueData, const ['revenueByEpisode', 'episodeRevenue']),
            _chartFromKeys(episodeData, const ['revenueGraph', 'episodes']),
          ]) ??
          const [],
      revenueComparison: _chartFromKeys(
        revenueData,
        const ['revenueComparison', 'revenueSplit', 'revenueSources'],
      ),
      ageGraph: _chartFromKeys(
        audienceData,
        const ['ageGraph', 'ageWiseAnalytics', 'ageGroups', 'ageWise'],
      ),
      locationRows: _locationRowsFromApi(locationData),
      dateViewsGraph:
          _chartFromKeys(dateData, const ['dailyViews', 'viewsGraph', 'views']),
      dateRevenueGraph: _chartFromKeys(
        dateData,
        const ['dailyRevenue', 'revenueGraph', 'revenue'],
      ),
      dateWatchTimeGraph: _chartFromKeys(
        dateData,
        const ['dailyWatchTime', 'watchTimeGraph', 'watchTime'],
      ),
      engagementRows: _engagementRowsFromApi(engagementData),
      episodeRows: _episodeRowsFromApi(episodeData),
    );
  }

  factory _SeriesAnalyticsBundle.fromFiltered(Map<String, dynamic> json) {
    final data = _analyticsData(json);
    return _SeriesAnalyticsBundle.fromResponses(
      main: data,
      summary: _asMap(data['summary']) ?? data,
      revenue: _asMap(data['revenue']) ?? data,
      audience: _asMap(data['audience']) ?? data,
      location: _asMap(data['location']) ?? data,
      datewise: _asMap(data['datewise']) ?? data,
      engagement: _asMap(data['engagement']) ?? data,
      seasons: _asMap(data['seasons']) ?? data,
      episodes: _asMap(data['episodes']) ?? data,
    );
  }
}

class _EpisodeAnalyticsRow {
  const _EpisodeAnalyticsRow({
    required this.id,
    required this.title,
    required this.views,
    required this.revenue,
    required this.completionRate,
    required this.likes,
    required this.comments,
  });

  final int id;
  final String title;
  final int views;
  final double revenue;
  final double completionRate;
  final int likes;
  final int comments;
}

class _SeriesAnalytics {
  const _SeriesAnalytics({
    required this.revenueGraph,
    required this.viewsGraph,
    required this.subscriptionGrowth,
  });

  final List<_ChartPoint> revenueGraph;
  final List<_ChartPoint> viewsGraph;
  final List<_ChartPoint> subscriptionGrowth;

  factory _SeriesAnalytics.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    return _SeriesAnalytics(
      revenueGraph: _chartPoints(data['revenueGraph']),
      viewsGraph: _chartPoints(data['viewsGraph']),
      subscriptionGrowth: _chartPoints(data['subscriptionGrowth']),
    );
  }
}

class _SeasonAnalytics {
  const _SeasonAnalytics({
    required this.totalRevenue,
    required this.totalViews,
    required this.totalEpisodes,
    required this.publishedEpisodes,
    required this.avgEpisodeDuration,
    required this.revenueGraph,
    required this.runtimeGraph,
    required this.viewsGraph,
  });

  final double totalRevenue;
  final int totalViews;
  final int totalEpisodes;
  final int publishedEpisodes;
  final int avgEpisodeDuration;
  final List<_ChartPoint> revenueGraph;
  final List<_ChartPoint> runtimeGraph;
  final List<_ChartPoint> viewsGraph;

  factory _SeasonAnalytics.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    return _SeasonAnalytics(
      totalRevenue: _asDouble(data['totalRevenue']) ?? 0,
      totalViews: _asInt(data['totalViews']) ?? 0,
      totalEpisodes: _asInt(data['totalEpisodes']) ?? 0,
      publishedEpisodes: _asInt(data['publishedEpisodes']) ?? 0,
      avgEpisodeDuration: _asInt(data['avgEpisodeDuration']) ?? 0,
      revenueGraph: _chartPoints(data['revenueGraph']),
      runtimeGraph: _chartPoints(data['runtimeGraph']),
      viewsGraph: _chartPoints(data['viewsGraph']),
    );
  }
}

class _EpisodeAnalyticsData {
  const _EpisodeAnalyticsData({
    required this.revenue,
    required this.views,
    required this.completionRate,
    required this.watchTime,
    required this.retentionGraph,
    required this.deviceGraph,
    required this.countryGraph,
  });

  final double revenue;
  final int views;
  final double completionRate;
  final int watchTime;
  final List<_ChartPoint> retentionGraph;
  final List<_ChartPoint> deviceGraph;
  final List<_ChartPoint> countryGraph;

  factory _EpisodeAnalyticsData.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    return _EpisodeAnalyticsData(
      revenue: _asDouble(data['revenue']) ?? 0,
      views: _asInt(data['views']) ?? 0,
      completionRate: _asDouble(data['completionRate']) ?? 0,
      watchTime: _asInt(data['watchTime']) ?? 0,
      retentionGraph: _chartPoints(data['retentionGraph']),
      deviceGraph: _chartPoints(data['deviceGraph']),
      countryGraph: _chartPoints(data['countryGraph']),
    );
  }
}

class _LiveSeriesDetails {
  const _LiveSeriesDetails({
    required this.content,
    required this.seasons,
    required this.cast,
    required this.teaserUrl,
    this.mediaHouse,
  });

  final Content content;
  final List<_SeriesSeason> seasons;
  final List<_SeriesCast> cast;
  final String teaserUrl;
  final _SeriesMediaHouse? mediaHouse;

  List<_SeriesCast> get seriesCast =>
      cast.where((item) => item.seasonId == 0).toList();

  factory _LiveSeriesDetails.fromJson(Map<String, dynamic> json) {
    final root = _asMap(json['data']) ?? json;
    final seriesMap = _firstMap(root, const [
          'series',
          'seriesDetails',
          'seriesDetail',
          'content',
          'contentList',
          'contentDetails',
          'movie',
          'video',
        ]) ??
        root;
    final content = _contentFromSeries(seriesMap);
    final cast = _firstListFromMaps([
      root,
      seriesMap
    ], const [
      'castList',
      'casts',
      'cast',
      'actors',
      'castCrew',
      'castAndCrew',
    ])
        .map((item) => _SeriesCast.fromJson(_asMap(item) ?? const {}))
        .where((item) => item.name.trim().isNotEmpty)
        .toList();
    final episodes = _firstListFromMaps([
      root,
      seriesMap
    ], const [
      'episodes',
      'episodeList',
      'seriesEpisodes',
      'episodeDetails',
      'episodeDtoList',
    ])
        .map((item) =>
            _SeriesEpisode.fromJson(_asMap(item) ?? const {}, content))
        .toList();
    final parsedSeasons = _firstListFromMaps([
      root,
      seriesMap
    ], const [
      'seasons',
      'seasonList',
      'seriesSeasons',
      'seasonDetails',
      'seasonDtoList',
    ]).map((item) {
      final seasonMap = _asMap(item) ?? const <String, dynamic>{};
      final seasonNumber = _asInt(
            seasonMap['seasonNumber'] ??
                seasonMap['number'] ??
                seasonMap['seasonNo'],
          ) ??
          1;
      final nestedEpisodes = _asList(seasonMap['episodes'])
          .map((episode) => _SeriesEpisode.fromJson(
                _asMap(episode) ?? const {},
                content,
              ))
          .toList();
      final seasonEpisodes = nestedEpisodes.isNotEmpty
          ? nestedEpisodes
          : episodes
              .where((episode) =>
                  episode.seasonId ==
                      (_asInt(seasonMap['id']) ?? seasonNumber) ||
                  episode.seasonNumber == seasonNumber)
              .toList();
      return _SeriesSeason.fromJson(seasonMap, content, seasonEpisodes);
    }).toList();
    final seasons = parsedSeasons.isNotEmpty
        ? parsedSeasons
        : episodes.isEmpty
            ? <_SeriesSeason>[]
            : [
                _SeriesSeason.fromJson(
                  const {
                    'id': 1,
                    'seasonNumber': 1,
                    'title': 'Season 1',
                    'active': true,
                  },
                  content,
                  episodes,
                ),
              ];
    final calculatedRevenue = seasons.fold<double>(
      0,
      (sum, season) => sum + season.revenue,
    );
    final calculatedViews = seasons.fold<int>(
      0,
      (sum, season) => sum + season.views,
    );
    if ((content.totalRevenue ?? 0) == 0 && calculatedRevenue > 0) {
      content.totalRevenue = calculatedRevenue;
    }
    if ((content.views ?? 0) == 0 && calculatedViews > 0) {
      content.views = calculatedViews;
    }

    return _LiveSeriesDetails(
      content: content,
      seasons: seasons,
      cast: cast,
      teaserUrl: _asString(seriesMap['teaserUrl'] ??
              seriesMap['teaserURL'] ??
              seriesMap['teaser'] ??
              root['teaserUrl']) ??
          '',
      mediaHouse: _SeriesMediaHouse.fromJson(
        _firstMap(root, const [
              'mediaHouse',
              'productionHouse',
              'production_house',
              'productionHouseDetails',
              'mediaHouseDetails',
              'mediaHouseDto',
            ]) ??
            _firstMap(seriesMap, const [
              'mediaHouse',
              'productionHouse',
              'production_house',
              'productionHouseDetails',
              'mediaHouseDetails',
              'mediaHouseDto',
            ]) ??
            _mediaHouseMapFromFlat(seriesMap) ??
            _mediaHouseMapFromFlat(root),
      ),
    );
  }

  static Content _contentFromSeries(Map<String, dynamic> json) {
    final mediaHouse = _firstMap(json, const [
      'mediaHouse',
      'productionHouse',
      'production_house',
      'productionHouseDetails',
      'mediaHouseDetails',
      'mediaHouseDto',
    ]);
    return Content(
      id: _asInt(json['id'] ?? json['seriesId']),
      title: _asString(json['title'] ??
          json['seriesTitle'] ??
          json['name'] ??
          json['seriesName']),
      description:
          _asString(json['description'] ?? json['desc'] ?? json['synopsis']),
      runtime: _asInt(json['runtime'] ?? json['duration']),
      releaseDate:
          json['releaseDate'] ?? json['releasedDate'] ?? json['publishDate'],
      ratings:
          _asDouble(json['ratings'] ?? json['rating'] ?? json['avgRating']),
      price: _asDouble(json['price'] ?? json['amount']),
      languageList: _asStringList(
          json['languageList'] ?? json['languages'] ?? json['language']),
      castList:
          _asStringList(json['castList'] ?? json['casts'] ?? json['cast']),
      genreList:
          _asStringList(json['genreList'] ?? json['genres'] ?? json['genre']),
      directorList: _asStringList(
          json['directorList'] ?? json['directors'] ?? json['director']),
      views: _asInt(json['views'] ?? json['viewCount'] ?? json['totalViews']),
      totalPurchase: _asInt(json['totalPurchase']),
      totalRevenue: _asDouble(json['totalRevenue']),
      ageRating: _asString(json['ageRating']),
      posterUrlList: _asStringList(json['posterUrlList'] ??
          json['posterUrls'] ??
          json['posterUrl'] ??
          json['poster'] ??
          json['thumbnailUrl'] ??
          json['bannerUrl']),
      trailerUrl: _asString(
          json['trailerURL'] ?? json['trailerUrl'] ?? json['trailer']),
      contentUrl: _asString(json['contentUrl'] ?? json['videoUrl']),
      approvalStatus: _asString(
          json['approvalStatus'] ?? json['status'] ?? json['approval']),
      type: _asString(json['type'] ?? json['contentType']) ?? 'SERIES',
      isFeatured: _asBool(json['isFeatured']),
      isDownloadable: _asBool(json['isDownloadable']),
      uploadDateTime: _asString(
          json['uploadDateTime'] ?? json['createdDate'] ?? json['createdAt']),
      approvedDateTime: _asString(json['approvedDateTime']),
      mediaHouseName: _asString(mediaHouse?['mediaHouseName'] ??
          mediaHouse?['name'] ??
          json['mediaHouseName'] ??
          json['productionHouseName']),
      mediaHouseId: _asInt(mediaHouse?['id'] ??
          mediaHouse?['mediaHouseId'] ??
          json['mediaHouseId'] ??
          json['productionHouseId']),
      ratingCount: _asInt(json['ratingCount'] ?? json['ratingsCount']),
      rentlDuration: _asString(json['rentlDuration'] ?? json['rentalDuration']),
      reason: _asString(json['reason']),
    );
  }
}

class _SeriesCast {
  const _SeriesCast({
    this.seasonId = 0,
    this.image = '',
    this.name = '',
    this.role = 'Cast',
  });

  final int seasonId;
  final String image;
  final String name;
  final String role;

  factory _SeriesCast.fromJson(Map<String, dynamic> json) {
    return _SeriesCast(
      seasonId: _asInt(json['seasonId']) ?? 0,
      image:
          _asString(json['image'] ?? json['profileImage'] ?? json['photo']) ??
              '',
      name: _asString(json['name'] ?? json['castName'] ?? json['actorName']) ??
          '',
      role: _asString(json['role'] ??
              json['designation'] ??
              json['characterName'] ??
              json['type']) ??
          'Cast',
    );
  }
}

class _SeriesMediaHouse {
  const _SeriesMediaHouse({
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.designation,
    required this.city,
    required this.state,
    required this.image,
  });

  final String name;
  final String email;
  final String contactNumber;
  final String designation;
  final String city;
  final String state;
  final String image;

  static _SeriesMediaHouse? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    final location = _asMap(json['location']);
    return _SeriesMediaHouse(
      name: _asString(json['mediaHouseName'] ??
              json['productionHouseName'] ??
              json['name'] ??
              json['title']) ??
          'NA',
      email: _asString(json['email'] ?? json['emailId']) ?? 'NA',
      contactNumber: _asString(
              json['contactNumber'] ?? json['mobileNumber'] ?? json['phone']) ??
          '',
      designation: _asString(json['designation'] ??
              json['ownerName'] ??
              json['contactPerson']) ??
          '',
      city: _asString(location?['city'] ?? json['city'] ?? json['district']) ??
          '',
      state: _asString(location?['state'] ?? json['state']) ?? '',
      image: _asString(json['profileImage'] ??
              json['logo'] ??
              json['image'] ??
              json['mediaHouseImage']) ??
          '',
    );
  }
}

List<_SeriesSeason> _buildFallbackSeasons(Content content) {
  final poster = _posterUrl(content);
  final totalRevenue = content.totalRevenue ?? 0;
  final views = content.views ?? 0;
  final episodeCount = _episodeCount(content);
  final episodes = List.generate(episodeCount, (index) {
    final number = index + 1;
    final revenue =
        episodeCount == 0 ? totalRevenue : totalRevenue / episodeCount;
    final epViews = episodeCount == 0 ? views : (views / episodeCount).round();
    return _SeriesEpisode(
      id: number,
      badge: 'E$number',
      title: number == 1
          ? (content.title ?? 'Episode $number')
          : '${content.title ?? 'Series'} - Episode $number',
      description: content.description ??
          'Episode details are not available from the API yet.',
      thumbnail: poster,
      duration:
          '${math.max(12, ((content.runtime ?? 45) / episodeCount).round())} min',
      price: content.price ?? 0,
      revenue: revenue,
      views: epViews,
      likes: math.max(0, (content.ratingCount ?? epViews ~/ 8) + number * 4),
      comments: math.max(0, epViews ~/ 25),
      status: content.approvalStatus ?? 'PENDING',
      uploadDate:
          _shortDate(content.uploadDateTime ?? content.releaseDate?.toString()),
      videoUrl: content.contentUrl ?? '',
      completionRate: (72 + number * 3).clamp(0, 98).toDouble(),
      mobileShare: (58 + number * 2).clamp(0, 92).toDouble(),
      countryCount: math.max(1, 4 + number),
      rating: (content.ratings ?? 4.2).clamp(0, 5).toDouble(),
      revenueChart: _trend(['W1', 'W2', 'W3', 'W4'], revenue),
      retentionChart: const [],
      deviceChart: const [],
      countryChart: const [],
    );
  });

  return [
    _SeriesSeason(
      id: 1,
      seasonNumber: 1,
      name: 'Season 1',
      description: content.description ?? 'NA',
      poster: poster,
      episodeCount: episodeCount,
      revenue: totalRevenue,
      monthlyRevenue: totalRevenue / 3,
      views: views,
      status: content.approvalStatus ?? 'PENDING',
      createdDate:
          _shortDate(content.uploadDateTime ?? content.releaseDate?.toString()),
      purchases: _purchaseCount(content),
      watchHours: math.max(0, ((views * (content.runtime ?? 45)) / 60).round()),
      activeUsers: math.max(0, (views * 0.42).round()),
      rating: (content.ratings ?? 0).toDouble(),
      episodes: episodes,
      revenueByMonth: _trend(
          const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'], totalRevenue),
      episodePerformance: episodes
          .map(
              (episode) => _ChartPoint(episode.badge, episode.views.toDouble()))
          .toList(),
      runtimePerformance: episodes
          .map((episode) => _ChartPoint(
              episode.badge, _runtimeMinutes(episode.duration).toDouble()))
          .toList(),
      viewsTrend: _trend(
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          views.toDouble()),
      subscriptionGrowth: _trend(
          const ['W1', 'W2', 'W3', 'W4'], _purchaseCount(content).toDouble()),
    ),
  ];
}

List<_ChartPoint> _trend(List<String> labels, num total) {
  if (labels.isEmpty) return const [];
  final base = total <= 0 ? 10.0 : total / labels.length;
  return List.generate(labels.length, (index) {
    final wave = 0.72 + (index + 1) / (labels.length + 2);
    return _ChartPoint(
        labels[index], double.parse((base * wave).toStringAsFixed(2)));
  });
}

List<_ChartPoint> _episodeMetric(
  List<_SeriesEpisode> episodes,
  double Function(_SeriesEpisode episode) valueOf,
) {
  if (episodes.isEmpty) return const [];
  return episodes
      .map((episode) => _ChartPoint(episode.badge, valueOf(episode)))
      .toList();
}

List<String> _uniqueOptions(List<String> values) {
  final seen = <String>{};
  final unique = <String>[];
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isEmpty || seen.contains(normalized)) continue;
    seen.add(normalized);
    unique.add(normalized);
  }
  return unique.isEmpty ? const ['All'] : unique;
}

List<_ChartPoint> _ageGraph(int totalViews, double totalRevenue) {
  final base =
      totalViews <= 0 ? (totalRevenue <= 0 ? 100 : totalRevenue) : totalViews;
  return [
    _ChartPoint('13-18', base * .08),
    _ChartPoint('18-24', base * .22),
    _ChartPoint('25-34', base * .31),
    _ChartPoint('35-44', base * .19),
    _ChartPoint('45-60', base * .14),
    _ChartPoint('60+', base * .06),
  ];
}

List<_LocationRow> _locationRows(int totalViews, double totalRevenue) {
  final views = totalViews <= 0 ? 100 : totalViews;
  final revenue = totalRevenue <= 0 ? 1000 : totalRevenue;
  final raw = [
    ('India', 'Maharashtra', 'Mumbai', .38),
    ('India', 'Maharashtra', 'Pune', .18),
    ('India', 'Karnataka', 'Bengaluru', .16),
    ('India', 'Delhi', 'Delhi', .12),
    ('UAE', 'Dubai', 'Dubai', .08),
    ('USA', 'California', 'San Jose', .05),
  ];
  return raw.map((item) {
    final share = item.$4;
    return _LocationRow(
      country: item.$1,
      state: item.$2,
      city: item.$3,
      users: math.max(1, (views * share * .62).round()),
      views: math.max(1, (views * share).round()),
      revenue: revenue * share,
      watchTime: math.max(1, (views * share * 12).round()),
      subscribers: math.max(1, (views * share * .18).round()),
    );
  }).toList();
}

List<_EngagementRow> _engagementRows(List<_SeriesEpisode> episodes) {
  final likes = episodes.fold<int>(0, (sum, episode) => sum + episode.likes);
  final comments =
      episodes.fold<int>(0, (sum, episode) => sum + episode.comments);
  final views = episodes.fold<int>(0, (sum, episode) => sum + episode.views);
  return [
    _EngagementRow('Likes', likes),
    _EngagementRow('Shares', math.max(0, views ~/ 14)),
    _EngagementRow('Comments', comments),
    _EngagementRow('Watchlist Adds', math.max(0, views ~/ 9)),
    _EngagementRow('Avg Session Time', math.max(1, views ~/ 20)),
    _EngagementRow('Rewatch Count', math.max(0, views ~/ 18)),
  ];
}

List<_ChartPoint>? _firstNonEmptyChart(List<List<_ChartPoint>?> charts) {
  for (final chart in charts) {
    if (chart != null && chart.isNotEmpty) return chart;
  }
  return null;
}

Map<String, dynamic> _analyticsData(Map<String, dynamic>? json) {
  if (json == null) return const {};
  final data = _asMap(json['data']) ?? json;
  return data;
}

List<_ChartPoint> _chartFromKeys(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];
    final points = _chartPoints(value);
    if (points.isNotEmpty) return points;
    final rows = _asList(value);
    if (rows.isNotEmpty) {
      final flexible = rows
          .map((item) => _chartPointFromMap(_asMap(item)))
          .whereType<_ChartPoint>()
          .toList();
      if (flexible.isNotEmpty) return flexible;
    }
  }
  return const [];
}

_ChartPoint? _chartPointFromMap(Map<String, dynamic>? map) {
  if (map == null) return null;
  final label = _firstString(map, const [
    'label',
    'name',
    'title',
    'date',
    'month',
    'day',
    'episodeName',
    'seasonName',
    'city',
    'country',
    'ageGroup',
    'device',
    'subscriptionType',
    'type',
  ]);
  if (label == null || label.trim().isEmpty) return null;
  final value = _firstDouble(map, const [
    'value',
    'count',
    'views',
    'revenue',
    'totalRevenue',
    'watchTime',
    'users',
    'subscribers',
    'completionRate',
  ]);
  return _ChartPoint(label, value ?? 0);
}

List<_LocationRow> _locationRowsFromApi(Map<String, dynamic> data) {
  final rows = _firstList(data, const [
    'locations',
    'locationAnalytics',
    'locationWiseAnalytics',
    'rows',
    'cities',
    'data',
  ]);
  return rows
      .map((item) {
        final map = _asMap(item);
        if (map == null) return null;
        return _LocationRow(
          country: _firstString(map, const ['country', 'countryName']) ?? '-',
          state: _firstString(map, const ['state', 'stateName']) ?? '-',
          city: _firstString(map, const [
                'city',
                'cityName',
                'district',
                'districtName',
                'taluka',
              ]) ??
              '-',
          users:
              _firstInt(map, const ['totalUsers', 'users', 'userCount']) ?? 0,
          views:
              _firstInt(map, const ['totalViews', 'views', 'viewCount']) ?? 0,
          revenue:
              _firstDouble(map, const ['revenue', 'totalRevenue', 'amount']) ??
                  0,
          watchTime: _firstInt(
                  map, const ['avgWatchTime', 'watchTime', 'watchMinutes']) ??
              0,
          subscribers: _firstInt(
                map,
                const ['subscriberCount', 'subscribers', 'activeSubscribers'],
              ) ??
              0,
        );
      })
      .whereType<_LocationRow>()
      .toList();
}

List<_EngagementRow> _engagementRowsFromApi(Map<String, dynamic> data) {
  final rows = _firstList(data, const ['rows', 'metrics', 'engagement']);
  final parsedRows = rows
      .map((item) {
        final map = _asMap(item);
        if (map == null) return null;
        final label = _firstString(map, const ['label', 'metric', 'name']);
        final value = _firstInt(map, const ['value', 'count', 'total']);
        if (label == null) return null;
        return _EngagementRow(label, value ?? 0);
      })
      .whereType<_EngagementRow>()
      .toList();
  if (parsedRows.isNotEmpty) return parsedRows;
  return [
    _EngagementRow('Likes', _firstInt(data, const ['likes']) ?? 0),
    _EngagementRow('Shares', _firstInt(data, const ['shares']) ?? 0),
    _EngagementRow('Comments', _firstInt(data, const ['comments']) ?? 0),
    _EngagementRow(
      'Watchlist Adds',
      _firstInt(data, const ['watchlistAdds', 'watchlistCount']) ?? 0,
    ),
    _EngagementRow(
      'Avg Session Time',
      _firstInt(data, const ['avgSessionTime', 'sessionTime']) ?? 0,
    ),
    _EngagementRow(
      'Drop-off Rate',
      (_firstDouble(data, const ['dropOffRate']) ?? 0).round(),
    ),
  ];
}

List<_EpisodeAnalyticsRow> _episodeRowsFromApi(Map<String, dynamic> data) {
  final rows = _firstList(data, const [
    'episodes',
    'episodeAnalytics',
    'episodeWiseAnalytics',
    'rows',
    'data',
  ]);
  return rows
      .map((item) {
        final map = _asMap(item);
        if (map == null) return null;
        return _EpisodeAnalyticsRow(
          id: _firstInt(map, const ['episodeId', 'id']) ?? 0,
          title:
              _firstString(map, const ['episodeName', 'title', 'name']) ?? '-',
          views: _firstInt(map, const ['views', 'totalViews']) ?? 0,
          revenue:
              _firstDouble(map, const ['revenue', 'totalRevenue', 'amount']) ??
                  0,
          completionRate:
              _firstDouble(map, const ['completionRate', 'completion']) ?? 0,
          likes: _firstInt(map, const ['likes', 'likeCount']) ?? 0,
          comments: _firstInt(map, const ['comments', 'commentCount']) ?? 0,
        );
      })
      .whereType<_EpisodeAnalyticsRow>()
      .toList();
}

List<_SeriesEpisode> _mergeEpisodeAnalyticsRows(
  List<_SeriesEpisode> episodes,
  List<_EpisodeAnalyticsRow> rows,
) {
  final byId = {for (final row in rows) row.id: row};
  final merged = episodes.map((episode) {
    final row = byId[episode.id];
    if (row == null) return episode;
    return episode.copyWith(
      title: row.title == '-' ? episode.title : row.title,
      views: row.views,
      revenue: row.revenue,
      likes: row.likes,
      comments: row.comments,
      completionRate: row.completionRate,
    );
  }).toList();
  final existingIds = episodes.map((item) => item.id).toSet();
  final extra = rows
      .where((row) => !existingIds.contains(row.id))
      .map((row) => _emptyEpisode().copyWith(
            id: row.id,
            badge: row.id > 0 ? 'E${row.id}' : 'E',
            title: row.title,
            views: row.views,
            revenue: row.revenue,
            likes: row.likes,
            comments: row.comments,
            completionRate: row.completionRate,
          ));
  return [...merged, ...extra];
}

Map<String, dynamic>? _findAnalyticsItem(
  Map<String, dynamic> json,
  int id,
  List<String> keys,
) {
  final data = _analyticsData(json);
  for (final key in keys) {
    final rows = _asList(data[key]);
    for (final row in rows) {
      final map = _asMap(row);
      if (map == null) continue;
      final rowId = _firstInt(map, const ['seasonId', 'id']);
      if (rowId == id) return {'data': map};
    }
    if (rows.isNotEmpty) {
      final first = _asMap(rows.first);
      if (first != null) return {'data': first};
    }
  }
  return null;
}

List<dynamic> _firstList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final list = _asList(map[key]);
    if (list.isNotEmpty) return list;
  }
  return const [];
}

List<dynamic> _firstListFromMaps(
  List<Map<String, dynamic>> maps,
  List<String> keys,
) {
  for (final map in maps) {
    final list = _firstList(map, keys);
    if (list.isNotEmpty) return list;
  }
  return const [];
}

Map<String, dynamic>? _firstMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _asMap(map[key]);
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

Map<String, dynamic>? _mediaHouseMapFromFlat(Map<String, dynamic> map) {
  final name = _asString(map['mediaHouseName'] ??
      map['productionHouseName'] ??
      map['productionHouse'] ??
      map['mediaHouse']);
  final id = _asInt(map['mediaHouseId'] ?? map['productionHouseId']);
  final email =
      _asString(map['mediaHouseEmail'] ?? map['productionHouseEmail']);
  final phone =
      _asString(map['mediaHouseContact'] ?? map['productionHouseContact']);
  if ([name, email, phone].every((value) => (value ?? '').trim().isEmpty) &&
      id == null) {
    return null;
  }
  return {
    'id': id,
    'mediaHouseName': name,
    'email': email,
    'contactNumber': phone,
    'city': _asString(map['mediaHouseCity'] ?? map['productionHouseCity']),
    'state': _asString(map['mediaHouseState'] ?? map['productionHouseState']),
    'profileImage':
        _asString(map['mediaHouseImage'] ?? map['productionHouseImage']),
  };
}

int? _firstInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _asInt(map[key]);
    if (value != null) return value;
  }
  return null;
}

double? _firstDouble(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _asDouble(map[key]);
    if (value != null) return value;
  }
  return null;
}

String? _firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _asString(map[key]);
    if (value != null && value.trim().isNotEmpty) return value;
  }
  return null;
}

List<String> _filterValue(String value, String allLabel) {
  return value == allLabel ? const [] : [value];
}

(String, String) _filterDateRange(String range) {
  final now = DateTime.now();
  DateTime from;
  switch (range) {
    case 'Today':
      from = now;
      break;
    case 'Last 7 Days':
      from = now.subtract(const Duration(days: 6));
      break;
    case 'This Month':
      from = DateTime(now.year, now.month);
      break;
    case 'Custom Date':
    case 'Last 30 Days':
    default:
      from = now.subtract(const Duration(days: 29));
      break;
  }
  final formatter = DateFormat('yyyy-MM-dd');
  return (formatter.format(from), formatter.format(now));
}

List<_ChartPoint> _chartPoints(dynamic value) {
  return _asList(value)
      .map((item) {
        final map = _asMap(item);
        if (map == null) return null;
        final label = _asString(map['label']) ?? '';
        if (label.trim().isEmpty) return null;
        return _ChartPoint(label, _asDouble(map['value']) ?? 0);
      })
      .whereType<_ChartPoint>()
      .toList();
}

_SeriesEpisode _emptyEpisode() {
  return const _SeriesEpisode(
    id: 0,
    badge: 'E0',
    title: 'No episode selected',
    description: 'NA',
    thumbnail: '',
    duration: 'NA',
    price: 0,
    revenue: 0,
    views: 0,
    likes: 0,
    comments: 0,
    status: 'NA',
    uploadDate: 'NA',
    videoUrl: '',
    completionRate: 0,
    mobileShare: 0,
    countryCount: 0,
    rating: 0,
    revenueChart: [],
    retentionChart: [],
    deviceChart: [],
    countryChart: [],
  );
}

String _posterUrl(Content content) {
  final posters = content.posterUrlList ?? const [];
  for (final poster in posters) {
    if (poster.trim().isNotEmpty) return poster.trim();
  }
  return '';
}

int _episodeCount(Content content) {
  final runtime = content.runtime ?? 0;
  if (runtime >= 120) return 6;
  if (runtime >= 80) return 4;
  return 3;
}

int _purchaseCount(Content content) {
  final price = content.price ?? 0;
  final revenue = content.totalRevenue ?? 0;
  if (price <= 0) return math.max(0, (content.views ?? 0) ~/ 9);
  return math.max(0, (revenue / price).round());
}

String _money(num? value) {
  if (value == null) return 'Rs -';
  return 'Rs ${value % 1 == 0 ? value.toInt() : value}';
}

String _formatChartValue(num value) {
  final abs = value.abs();
  if (abs >= 10000000) {
    return '${(value / 10000000).toStringAsFixed(1)}Cr';
  }
  if (abs >= 100000) {
    return '${(value / 100000).toStringAsFixed(1)}L';
  }
  if (abs >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

String _normalizeSeasonStatus(String? status) {
  final normalized = (status ?? '').trim().toUpperCase();
  if (normalized == 'APPROVED' || normalized == 'PUBLISHED') {
    return 'APPROVED';
  }
  if (normalized == 'REJECTED') return 'REJECTED';
  return 'PENDING';
}

Map<String, dynamic>? _decodeResponseMap(String body) {
  try {
    final decoded = json.decode(body);
    return _asMap(decoded);
  } catch (_) {
    return null;
  }
}

String? _responseMessage(Map<String, dynamic>? json) {
  if (json == null) return null;
  for (final key in const ['message', 'error', 'statusMessage', 'details']) {
    final value = _asString(json[key]);
    if (value != null && value.trim().isNotEmpty) return value;
  }
  return null;
}

bool? _responseSuccess(Map<String, dynamic>? json) {
  if (json == null) return null;
  return _asBool(json['success'] ?? json['isSuccess']);
}

String _cleanError(Object error, String fallback) {
  final raw = error.toString().replaceFirst('Exception:', '').trim();
  return raw.isEmpty ? fallback : raw;
}

String _shortDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat('dd MMM yyyy').format(parsed);
}

int _runtimeMinutes(String value) {
  final match = RegExp(r'\d+').firstMatch(value);
  return int.tryParse(match?.group(0) ?? '') ?? 0;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return null;
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            return (item['language'] ??
                    item['name'] ??
                    item['value'] ??
                    item['title'] ??
                    '')
                .toString();
          }
          return item.toString();
        })
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value.split(',').map((item) => item.trim()).toList();
  }
  return [];
}

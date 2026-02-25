import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:admin_ott/app/core/utils/sharepreferences.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/mediaHouse_profile_page.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/buildSummaryCard.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/mediaHouse_content_approval.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_details_dialog.dart.dart';
import 'package:admin_ott/app/ui/pages/media%20house%20detail%20page/component/TopMoviesLineGraph.dart';
import 'package:admin_ott/app/ui/pages/media%20house%20detail%20page/component/settlementCards.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/short_master_page.dart';
import 'package:admin_ott/app/widgets/CustomLineGraph.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaHouseDetailPage extends StatefulWidget {
  final MediaHouse mediaHouse;
  const MediaHouseDetailPage({super.key, required this.mediaHouse});

  @override
  State<MediaHouseDetailPage> createState() => _MediaHouseDetailPageState();
}

class _MediaHouseDetailPageState extends State<MediaHouseDetailPage> {
  _ContentMode _selectedContentMode = _ContentMode.movie;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final id = widget.mediaHouse.id;
    if (id == null) return;
    final provider = Provider.of<MediaHouseProvider>(context, listen: false);
    final localSharePreferences = LocalSharePreferences();
    await localSharePreferences.setString(
      SharedPreferencesConstant.currentMediaHouseId,
      id.toString(),
    );
    await provider.fetchMoviesByMediaHouseId(id);
    await provider.fetchMoviesByStatusAndMediaHouseId("PENDING", id);
    await provider.fetchMediaHouseDashboardData(id);
    await provider.fetchShortsByMediaHouse(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          forceMaterialTransparency: true,
          title: Text(widget.mediaHouse.mediaHouseName ?? 'Media House'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: theme.canvasColor),
              onPressed: _loadData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSection(context, provider, theme),
                const SizedBox(height: 16),
                _buildContentModeSelector(theme),
                const SizedBox(height: 12),
                _buildCurrentContentSection(context, provider, theme),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopSection(
    BuildContext context,
    MediaHouseProvider provider,
    ThemeData theme,
  ) {
    final profileCard = _buildProfileCard(context, theme);
    final dashboardCard = _buildDashboardCard(context, provider, theme);

    if (ResponsiveWidget.isMobile(context)) {
      return Column(
        children: [
          profileCard,
          const SizedBox(height: 12),
          dashboardCard,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: profileCard),
        const SizedBox(width: 12),
        Expanded(flex: 6, child: dashboardCard),
      ],
    );
  }

  Widget _buildContentModeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _buildModeChip(theme, _ContentMode.movie, 'Movie'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.series, 'Series'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.shorts, 'Shorts'),
        ],
      ),
    );
  }

  Widget _buildModeChip(ThemeData theme, _ContentMode mode, String label) {
    final selected = _selectedContentMode == mode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _selectedContentMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : theme.canvasColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContentSection(
    BuildContext context,
    MediaHouseProvider provider,
    ThemeData theme,
  ) {
    if (_selectedContentMode == _ContentMode.shorts) {
      return _buildContentSection(
        context: context,
        theme: theme,
        title: 'Shorts',
        emptyText: provider.isShortsLoading
            ? 'Loading shorts...'
            : 'No shorts available.',
        items: provider.shortsByMediaHouse,
        child: _buildShortsGrid(context, provider.shortsByMediaHouse, theme),
      );
    }

    final filtered = provider.filteredContentListByMediaHouse.where((item) {
      final type = (item.type ?? '').trim().toLowerCase();
      if (_selectedContentMode == _ContentMode.series) {
        return type.contains('series');
      }
      return type.contains('movie') || type.isEmpty;
    }).toList();

    return _buildContentSection(
      context: context,
      theme: theme,
      title: _selectedContentMode == _ContentMode.movie ? 'Movies' : 'Series',
      emptyText: _selectedContentMode == _ContentMode.movie
          ? 'No movies available.'
          : 'No series available.',
      items: filtered,
      child: _buildMovieSeriesGrid(context, filtered, theme),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: widget.mediaHouse.logo != null
                ? NetworkImage(widget.mediaHouse.logo!)
                : null,
            child: widget.mediaHouse.logo == null
                ? const Icon(Icons.business, size: 34)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            widget.mediaHouse.mediaHouseName ?? 'Unknown Name',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.canvasColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.mediaHouse.discription ?? 'No description available.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: theme.canvasColor.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.mediaHouse.contactNumber ?? 'N/A',
            style: TextStyle(
              fontSize: 13,
              color: theme.canvasColor.withValues(alpha: 0.75),
            ),
          ),
          Text(
            widget.mediaHouse.email ?? 'N/A',
            style: TextStyle(
              fontSize: 13,
              color: theme.canvasColor.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MediaHouseProfilePage(mediaHouse: widget.mediaHouse),
                ),
              );
            },
            child: const Text('View Full Detail'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: _buildCardContainer(
              theme: theme,
              title: 'Content Approvals',
              child: MediahouseContentApprovalWidget(widget.mediaHouse.id ?? 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    MediaHouseProvider provider,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            BuildSummaryCard(
              icon: Icons.currency_rupee_sharp,
              title: "Revenue",
              value: provider.mediaHouseDashboardData.viewRevenue.toString(),
              onTap: () =>
                  _openGraphDialog(context, 'Revenue Graph', 'sales', 0),
            ),
            BuildSummaryCard(
              icon: Icons.visibility_outlined,
              title: "Views",
              value: provider.mediaHouseDashboardData.totalViews.toString(),
              onTap: () => _openGraphDialog(context, 'Views Graph', 'views', 1),
            ),
            BuildSummaryCard(
              icon: Icons.play_circle_outline_sharp,
              title: "Live Content",
              value:
                  provider.mediaHouseDashboardData.approvedContent.toString(),
              onTap: () => _openGraphDialog(context, 'Live Content', 'live', 2),
            ),
            BuildSummaryCard(
              icon: Icons.hourglass_top_outlined,
              title: "Pending Content",
              value: provider.mediaHouseDashboardData.pendingContentCount
                  .toString(),
              onTap: () {},
            ),
            BuildSummaryCard(
              icon: Icons.schedule,
              title: "Upcoming Content",
              value: provider.mediaHouseDashboardData.upcomingContentCount
                  .toString(),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildCardContainer(
          theme: theme,
          title: 'Top Revenue Content',
          child: SizedBox(
            height: 270,
            child: TopMoviesLineGraph(
              isRevenue: true,
              mediaHouseId: widget.mediaHouse.id ?? 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SettlementCard(widget.mediaHouse),
      ],
    );
  }

  void _openGraphDialog(
    BuildContext context,
    String title,
    String yAxisLabel,
    int graphNumber,
  ) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: theme.cardColor,
        child: CustomLineGraph(
          title: title,
          yAxisLabel: yAxisLabel,
          canPop: true,
          mediaHouseId: widget.mediaHouse.id ?? 0,
          graphNumber: graphNumber,
          metrics: [yAxisLabel],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String emptyText,
    required List<dynamic> items,
    required Widget child,
  }) {
    return _buildCardContainer(
      theme: theme,
      title: title,
      child: items.isEmpty
          ? SizedBox(
              height: 130,
              child: Center(
                child: Text(
                  emptyText,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.75),
                  ),
                ),
              ),
            )
          : child,
    );
  }

  Widget _buildCardContainer({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildMovieSeriesGrid(
    BuildContext context,
    List<Content> items,
    ThemeData theme,
  ) {
    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 5
        : ResponsiveWidget.isTablet(context)
            ? 3
            : 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 16 / 9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final content = items[index];
        final poster =
            (content.posterUrlList != null && content.posterUrlList!.isNotEmpty)
                ? content.posterUrlList!.first
                : '';
        return _buildPosterCard(
          theme: theme,
          title: content.title ?? 'Untitled',
          subtitle: content.type ?? 'Movie',
          imageUrl: poster,
          viewsText: '${content.views ?? 0}',
          onTap: () => showMovieDetailsDialog(context, content),
          aspectRatio: 16 / 9,
        );
      },
    );
  }

  Widget _buildShortsGrid(
    BuildContext context,
    List<ShortMaster> items,
    ThemeData theme,
  ) {
    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 6
        : ResponsiveWidget.isTablet(context)
            ? 4
            : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 9 / 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final short = items[index];
        return _buildPosterCard(
          theme: theme,
          title: short.title ?? 'Untitled Short',
          subtitle: short.category ?? 'Shorts',
          imageUrl: short.posterUrl ?? '',
          viewsText: '${short.viewCount ?? 0}',
          onTap: () => _openShortMasterPage(short),
          aspectRatio: 9 / 16,
        );
      },
    );
  }

  Future<void> _openShortMasterPage(ShortMaster short) async {
    final shortId = short.id;
    if (shortId == null) return;
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ShortMasterPage(shortId: shortId),
      ),
    );
    if (!mounted) return;
    if (deleted == true) {
      await Provider.of<MediaHouseProvider>(context, listen: false)
          .fetchShortsByMediaHouse(widget.mediaHouse.id ?? 0);
    }
  }

  Widget _buildPosterCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String viewsText,
    required VoidCallback onTap,
    required double aspectRatio,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackPoster(theme),
                    )
                  : _fallbackPoster(theme),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        viewsText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11,
                      ),
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

  Widget _fallbackPoster(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
      child: Icon(Icons.movie_creation_outlined, color: theme.primaryColor),
    );
  }
}

enum _ContentMode { movie, series, shorts }

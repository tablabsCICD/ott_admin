import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:admin_ott/app/core/utils/sharepreferences.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/settelementProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/mediaHouse_profile_page.dart';
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
    final settelementProvider =
        Provider.of<SettelementProvider>(context, listen: false);
    final localSharePreferences = LocalSharePreferences();
    await localSharePreferences.setString(
      SharedPreferencesConstant.currentMediaHouseId,
      id.toString(),
    );
    await provider.fetchMoviesByMediaHouseId(id);
    await provider.fetchMoviesByStatusAndMediaHouseId("PENDING", id);
    await provider.fetchMediaHouseDashboardData(id);
    await provider.fetchShortsByMediaHouse(id);
    await settelementProvider
        .fetchWeeklySettelementDataByMediaHouseId(widget.mediaHouse.id!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      return Scaffold(
        // backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          // forceMaterialTransparency: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.mediaHouse.mediaHouseName ??
                  'Production House Overview'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                EdgeInsets.all(ResponsiveWidget.isMobile(context) ? 12 : 18),
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
          const SizedBox(height: 14),
          dashboardCard,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 450, child: profileCard),
        const SizedBox(width: 16),
        Expanded(child: dashboardCard),
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
          _buildModeChip(theme, _ContentMode.shortFilm, 'Short Film'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.series, 'Series'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.shorts, 'Mini Series'),
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
        title: 'Mini Series',
        emptyText: provider.isShortsLoading
            ? 'Loading Mini Series...'
            : 'No Mini Series available.',
        items: provider.shortsByMediaHouse,
        child: _buildShortsGrid(context, provider.shortsByMediaHouse, theme),
      );
    }

    final filtered = provider.filteredContentListByMediaHouse.where((item) {
      final type = (item.type ?? '').trim().toUpperCase();
      if (_selectedContentMode == _ContentMode.series) {
        return type == 'SERIES';
      }
      if (_selectedContentMode == _ContentMode.shortFilm) {
        return type == 'SHORT_FILM';
      }
      return type == 'MOVIE' || type.isEmpty;
    }).toList();

    final sectionTitle = switch (_selectedContentMode) {
      _ContentMode.movie => 'Movies',
      _ContentMode.shortFilm => 'Short Films',
      _ContentMode.series => 'Series',
      _ContentMode.shorts => 'Mini Series',
    };

    return _buildContentSection(
      context: context,
      theme: theme,
      title: sectionTitle,
      emptyText: 'No ${sectionTitle.toLowerCase()} available.',
      items: filtered,
      child: _buildMovieSeriesGrid(context, filtered, theme),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.canvasColor.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 31,
                      backgroundColor:
                          theme.primaryColor.withValues(alpha: 0.16),
                      backgroundImage: (widget.mediaHouse.logo ?? '').isNotEmpty
                          ? NetworkImage(widget.mediaHouse.logo!)
                          : null,
                      child: (widget.mediaHouse.logo ?? '').isEmpty
                          ? Icon(Icons.business,
                              size: 23, color: theme.primaryColor)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mediaHouse.mediaHouseName ?? 'Unknown Name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.canvasColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.mediaHouse.discription ??
                                'No description available.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: theme.canvasColor.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildProfilePill(
                      theme,
                      Icons.phone_outlined,
                      widget.mediaHouse.contactNumber ?? 'N/A',
                    ),
                    _buildProfilePill(
                      theme,
                      Icons.mail_outline,
                      widget.mediaHouse.email ?? 'N/A',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaHouseProfilePage(
                              mediaHouse: widget.mediaHouse),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 15),
                    label: const Text('View Full Detail'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: ResponsiveWidget.isMobile(context) ? 244 : 450,
            child: SingleChildScrollView(
              child: _buildCardContainer(
                theme: theme,
                title: 'Content Approvals',
                child:
                    MediahouseContentApprovalWidget(widget.mediaHouse.id ?? 0),
              ),
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
    final adminRevenue = widget.mediaHouse.adminRevnue;
    final mediaHouseRevenue = widget.mediaHouse.mediaHouseRevenue;
    final totalRevenue = widget.mediaHouse.displayTotalRevenue;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width > 900
                ? 7
                : width > 640
                    ? 4
                    : width > 420
                        ? 2
                        : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.8 : 1.9,
              children: [
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.currency_rupee_sharp,
                  title: "Total Revenue",
                  value: _formatRevenue(totalRevenue),
                  onTap: () =>
                      _openGraphDialog(context, 'Revenue Graph', 'sales', 0),
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.admin_panel_settings_outlined,
                  title: "Admin Revenue",
                  value: _formatRevenue(adminRevenue),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.business_outlined,
                  title: "Production House Revenue",
                  value: _formatRevenue(mediaHouseRevenue),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.visibility_outlined,
                  title: "Views",
                  value: provider.mediaHouseDashboardData.totalViews.toString(),
                  onTap: () =>
                      _openGraphDialog(context, 'Views Graph', 'views', 1),
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.play_circle_outline_sharp,
                  title: "Live Content",
                  value: provider.mediaHouseDashboardData.approvedContent
                      .toString(),
                  onTap: () =>
                      _openGraphDialog(context, 'Live Content', 'live', 2),
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.hourglass_top_outlined,
                  title: "Pending Content",
                  value: provider.mediaHouseDashboardData.pendingContentCount
                      .toString(),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.schedule,
                  title: "Upcoming Content",
                  value: provider.mediaHouseDashboardData.upcomingContentCount
                      .toString(),
                  onTap: () {},
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _buildCardContainer(
          theme: theme,
          title: '',
          child: SizedBox(
            height: 270,
            child: TopMoviesLineGraph(
              isRevenue: true,
              mediaHouseId: widget.mediaHouse.id ?? 0,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SettlementCard(widget.mediaHouse),
      ],
    );
  }

  Widget _buildProfilePill(ThemeData theme, IconData icon, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 292),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.78),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 23),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetricAmountHover(value: value, theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
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
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
          ],
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
        childAspectRatio: crossAxisCount == 1 ? 1.95 : 1.35,
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
          revenueStats: [
            _PosterRevenueStat('Total Revenue', content.totalRevenue),
            _PosterRevenueStat('Admin Revenue', content.adminRevnue),
            _PosterRevenueStat(
              'Production House Revenue',
              content.mediaHouseRevenue,
            ),
          ],
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
          revenueStats: [
            _PosterRevenueStat('Total Revenue', short.totalRevenue),
            _PosterRevenueStat('Admin Revenue', short.adminRevenue),
            _PosterRevenueStat(
              'Production House Revenue',
              short.mediaHouseRevenue,
            ),
          ],
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
    List<_PosterRevenueStat> revenueStats = const [],
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
                    if (revenueStats.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: revenueStats
                            .map((stat) => _buildRevenueBadge(stat))
                            .toList(),
                      ),
                    ],
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

  Widget _buildRevenueBadge(_PosterRevenueStat stat) {
    final text = '${stat.label}: ${_formatRevenue(stat.value)}';
    return Tooltip(
      message: text,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 190),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatRevenue(dynamic value) {
    if (value == null) return 'Rs. -';

    final amount = value is num ? value : num.tryParse(value.toString());
    if (amount == null) return 'Rs. -';

    return 'Rs. ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  }
}

enum _ContentMode { movie, shortFilm, series, shorts }

class _MetricAmountHover extends StatefulWidget {
  const _MetricAmountHover({
    required this.value,
    required this.theme,
  });

  final String value;
  final ThemeData theme;

  @override
  State<_MetricAmountHover> createState() => _MetricAmountHoverState();
}

class _MetricAmountHoverState extends State<_MetricAmountHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.value,
        waitDuration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: _hovered ? 7 : 0,
            vertical: _hovered ? 3 : 0,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.theme.primaryColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: _hovered
                  ? widget.theme.primaryColor.withValues(alpha: 0.28)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.value,
            maxLines: _hovered ? 2 : 1,
            overflow: _hovered ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: _hovered,
            style: TextStyle(
              color: widget.theme.primaryColor,
              fontSize: _hovered ? 14 : 17,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterRevenueStat {
  const _PosterRevenueStat(this.label, this.value);

  final String label;
  final num? value;
}

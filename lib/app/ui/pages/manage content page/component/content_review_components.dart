import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/app/widgets/ott_media_player.dart';
import 'package:admin_ott/domain/entities/cast_crew.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

/// Teaser Section Widget
/// Displays inline video preview using [OttMediaPlayer] for Teaser and Trailer files.
class TeaserSection extends StatefulWidget {
  final String? teaserUrl;
  final String? trailerUrl;
  final VoidCallback? onEdit;

  const TeaserSection({
    super.key,
    this.teaserUrl,
    this.trailerUrl,
    this.onEdit,
  });

  @override
  State<TeaserSection> createState() => _TeaserSectionState();
}

class _TeaserSectionState extends State<TeaserSection> {
  int _selectedTab = 0; // 0: Teaser, 1: Trailer

  @override
  void initState() {
    super.initState();
    final hasTeaser = widget.teaserUrl != null && widget.teaserUrl!.trim().isNotEmpty;
    final hasTrailer = widget.trailerUrl != null && widget.trailerUrl!.trim().isNotEmpty;
    if (!hasTeaser && hasTrailer) {
      _selectedTab = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final teaser = widget.teaserUrl?.trim() ?? '';
    final trailer = widget.trailerUrl?.trim() ?? '';

    final hasTeaser = teaser.isNotEmpty;
    final hasTrailer = trailer.isNotEmpty;

    final activeUrl = _selectedTab == 0 ? teaser : trailer;
    final hasActiveVideo = activeUrl.isNotEmpty;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.ondemand_video_outlined,
                    color: theme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Teaser & Trailer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.canvasColor,
                  ),
                ),
                const Spacer(),
                if (hasTeaser || hasTrailer)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabButton(
                          label: "Teaser",
                          isSelected: _selectedTab == 0,
                          hasFile: hasTeaser,
                          theme: theme,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: 4),
                        _buildTabButton(
                          label: "Trailer",
                          isSelected: _selectedTab == 1,
                          hasFile: hasTrailer,
                          theme: theme,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                if (widget.onEdit != null)
                  OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text(
                      'Edit Video Files',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(
                        color: theme.primaryColor.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasActiveVideo)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: OttMediaPlayer(
                    key: ValueKey(activeUrl),
                    url: activeUrl,
                    autoPlay: false,
                    fit: BoxFit.contain,
                    errorBuilder: (_, message) => Center(
                      child: Text(
                        message,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.canvasColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off_outlined,
                        color: theme.hintColor, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      _selectedTab == 0
                          ? 'No Teaser Video Available'
                          : 'No Trailer Video Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.hintColor,
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

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required bool hasFile,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : theme.hintColor,
              ),
            ),
            if (hasFile) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Agreement & Censor Certificate Section Widget
/// Displays [View Agreement] and [View Censor Certificate] buttons with previews,
/// or appropriate "Not Available" indicators.
class AgreementSection extends StatelessWidget {
  final String? agreementUrl;
  final String? censorCertificateUrl;

  const AgreementSection({
    super.key,
    this.agreementUrl,
    this.censorCertificateUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final agrUrl = agreementUrl?.trim() ?? '';
    final censorUrl = censorCertificateUrl?.trim() ?? '';

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined,
                    color: theme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Agreement & Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.canvasColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDocCard(
                          context: context,
                          theme: theme,
                          title: 'Production House Agreement',
                          icon: Icons.description_outlined,
                          url: agrUrl,
                          emptyLabel: 'Agreement Not Available',
                          buttonLabel: 'View Agreement',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildDocCard(
                          context: context,
                          theme: theme,
                          title: 'Censor Certificate',
                          icon: Icons.verified_user_outlined,
                          url: censorUrl,
                          emptyLabel: 'Censor Certificate Not Available',
                          buttonLabel: 'View Certificate',
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDocCard(
                        context: context,
                        theme: theme,
                        title: 'Production House Agreement',
                        icon: Icons.description_outlined,
                        url: agrUrl,
                        emptyLabel: 'Agreement Not Available',
                        buttonLabel: 'View Agreement',
                      ),
                      const SizedBox(height: 12),
                      _buildDocCard(
                        context: context,
                        theme: theme,
                        title: 'Censor Certificate',
                        icon: Icons.verified_user_outlined,
                        url: censorUrl,
                        emptyLabel: 'Censor Certificate Not Available',
                        buttonLabel: 'View Certificate',
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required IconData icon,
    required String url,
    required String emptyLabel,
    required String buttonLabel,
  }) {
    final hasUrl = url.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasUrl
              ? theme.primaryColor.withValues(alpha: 0.25)
              : theme.canvasColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: hasUrl ? theme.primaryColor : theme.hintColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasUrl ? theme.canvasColor : theme.hintColor,
                  ),
                ),
              ),
              if (hasUrl)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasUrl) ...[
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _openDocument(url),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(
                    buttonLabel,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text(
                emptyLabel,
                style: TextStyle(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openDocument(String url) {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      debugPrint("Opening document URL: $url");
    }
  }
}

/// Cast & Crew Section Widget
/// Displays a responsive grid/wrap of cast member cards or an appropriate empty/error state.
class CastCrewSection extends StatelessWidget {
  final List<Cast>? castList;
  final bool isLoading;
  final String? errorMessage;
  final bool isSeries;
  final List<dynamic>? availableSeasons;
  final dynamic selectedSeasonId;
  final ValueChanged<dynamic>? onSeasonChanged;

  const CastCrewSection({
    super.key,
    this.castList,
    this.isLoading = false,
    this.errorMessage,
    this.isSeries = false,
    this.availableSeasons,
    this.selectedSeasonId,
    this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined,
                    color: theme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Cast & Crew',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.canvasColor,
                  ),
                ),
                if (isSeries && availableSeasons != null && availableSeasons!.isNotEmpty) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        value: selectedSeasonId ?? availableSeasons!.first,
                        isDense: true,
                        dropdownColor: theme.cardColor,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        items: availableSeasons!.map((season) {
                          final label = season is Map
                              ? (season['name'] ?? 'Season ${season['seasonNumber'] ?? season['id']}')
                              : 'Season $season';
                          final val = season is Map ? (season['id'] ?? season['seasonId']) : season;
                          return DropdownMenuItem<dynamic>(
                            value: val,
                            child: Text('$label'),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null && newVal != selectedSeasonId) {
                            onSeasonChanged?.call(newVal);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: AppSpinner()),
              )
            else if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'Unable to load cast and crew information.',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else if (castList == null || castList!.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.canvasColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    isSeries
                        ? 'No cast and crew information available for this season.'
                        : 'No cast and crew information available.',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: castList!
                    .map((person) => _buildCastCard(person, theme))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastCard(Cast person, ThemeData theme) {
    final name = person.name ?? 'Unknown';
    final roleStr = [person.characterName, person.role, person.designation]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(' / ');
    final displayRole = roleStr.isEmpty ? 'Cast Member' : roleStr;
    final profileUrl = person.profileUrl ?? '';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
            backgroundImage:
                profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
            child: profileUrl.isEmpty
                ? Icon(Icons.person, color: theme.primaryColor, size: 24)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayRole,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.7),
                    fontSize: 11,
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

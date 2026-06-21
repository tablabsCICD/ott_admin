import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/approve_content_detail_page.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MediahouseContentApprovalWidget extends StatelessWidget {
  final int mediaHouseId;

  const MediahouseContentApprovalWidget(this.mediaHouseId, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Consumer<MediaHouseProvider>(
      builder: (context, provider, child) {
        final items = provider.contentListByMediaHouseAndStatus;
        if (items.isEmpty) {
          return Center(
            child: Text(
              "No content available for approval.",
              style: TextStyle(color: theme.canvasColor.withValues(alpha: 0.8)),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            return ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final content = items[index];
                return _buildContentCard(
                  context: context,
                  content: content,
                  theme: theme,
                  compact: compact,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContentCard({
    required BuildContext context,
    required Content content,
    required ThemeData theme,
    required bool compact,
  }) {
    final posterUrl =
        (content.posterUrlList != null && content.posterUrlList!.isNotEmpty)
            ? content.posterUrlList!.first
            : '';
    final genre = content.genreList?.isNotEmpty == true
        ? content.genreList!.first
        : "Unknown Genre";
    final type = content.type ?? "Unknown Type";

    return InkWell(
      onTap: () => _openContentDetailsPage(context, content),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.canvasColor.withValues(alpha: 0.14)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: compact ? 104 : 132,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackPoster(theme),
                        )
                      : _fallbackPoster(theme),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title ?? "Untitled",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.canvasColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$genre - $type',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.canvasColor.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Language: ${_languageText(content)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.canvasColor.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      _buildTag(
                        label: content.approvalStatus ?? 'Pending',
                        color: theme.primaryColor,
                        theme: theme,
                      ),
                      _buildTag(
                        label: _formatUploadDate(content.uploadDateTime),
                        color: theme.canvasColor,
                        theme: theme,
                      ),
                      _buildTag(
                        label: 'Open',
                        color: theme.primaryColor,
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color == theme.canvasColor ? theme.canvasColor : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _fallbackPoster(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
      child: Icon(
        Icons.movie_filter_outlined,
        color: theme.primaryColor,
      ),
    );
  }

  Future<void> _openContentDetailsPage(
      BuildContext context, Content content) async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ApproveContentDetailsPage(content: content),
      ),
    );
    if (!context.mounted || shouldRefresh != true) return;
    await Provider.of<MediaHouseProvider>(context, listen: false)
        .fetchMoviesByStatusAndMediaHouseId("PENDING", mediaHouseId);
  }

  String _languageText(Content content) {
    final languages = content.languageList;
    if (languages == null || languages.isEmpty) return 'Unknown';
    return languages.join(', ');
  }

  String _formatUploadDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Unknown Date';

    final rawValue = value.trim();
    final epoch = int.tryParse(rawValue);
    final date = epoch != null
        ? DateTime.fromMillisecondsSinceEpoch(epoch)
        : DateTime.tryParse(rawValue);

    if (date == null) return 'Unknown Date';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }
}

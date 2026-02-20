import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/movie_sales_chart.dart';
import 'package:admin_ott/app/ui/pages/manage%20video%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieDetailsPage extends StatefulWidget {
  final Content content;

  const MovieDetailsPage({super.key, required this.content});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.content.id != null) {
      Provider.of<VideoProvider>(context, listen: false)
          .contentRevenueGraph(0, widget.content.id!, '', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final content = widget.content;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(content.title ?? 'Movie Details'),
        backgroundColor: theme.cardColor,
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context, content),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosterHeader(content: content),
            const SizedBox(height: 12),
            _SummaryChips(content: content),
            const SizedBox(height: 12),
            ActionPanel(content: content),
            const SizedBox(height: 12),
            if (isDesktop && content.id != null)
              SizedBox(
                height: 340,
                child: Card(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MovieSalesChart(
                    title: 'Revenue Trend',
                    yAxisLabel: 'Revenue',
                    metrics: const ["revenue"],
                    graphNumber: 0,
                    contentId: content.id!,
                  ),
                ),
              ),
            if (isDesktop && content.id != null) const SizedBox(height: 12),
            DetailsSection(content: content, heading: 'Movie Metadata'),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Content content) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Delete ${content.title}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
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
}

class PosterHeader extends StatelessWidget {
  final Content content;

  const PosterHeader({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final posterUrl =
        (content.posterUrlList != null && content.posterUrlList!.isNotEmpty)
            ? content.posterUrlList!.first
            : '';
    final screenWidth = MediaQuery.of(context).size.width;
    final posterWidth = screenWidth > 1200
        ? 560.0
        : screenWidth > 800
            ? 500.0
            : screenWidth - 32;

    return Card(
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: posterWidth,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallback(theme),
                          )
                        : _fallback(theme),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content.title ?? 'Untitled Movie',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content.description ?? 'No description available.',
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_creation_outlined,
        size: 36,
        color: theme.primaryColor,
      ),
    );
  }
}

class _SummaryChips extends StatelessWidget {
  final Content content;

  const _SummaryChips({required this.content});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(context, Icons.movie_filter_outlined, content.type ?? 'CONTENT'),
        _chip(
            context, Icons.verified_outlined, content.approvalStatus ?? 'N/A'),
        _chip(context, Icons.calendar_today_outlined,
            content.releaseDate?.toString() ?? 'No release date'),
        _chip(context, Icons.star_outline, '${content.ratings ?? 0}'),
        _chip(
            context, Icons.visibility_outlined, '${content.views ?? 0} views'),
        _chip(context, Icons.currency_rupee_outlined, '${content.price ?? 0}'),
      ],
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.primaryColor),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: theme.canvasColor)),
        ],
      ),
    );
  }
}

class ActionPanel extends StatelessWidget {
  final Content content;

  const ActionPanel({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final status = (content.approvalStatus ?? '').toUpperCase();
    final approved = status == 'APPROVED';

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
                      : () {
                          if (content.id != null) {
                            Provider.of<VideoProvider>(context, listen: false)
                                .changeContentStatus(
                                    context, "APPROVED", content.id!);
                          }
                        },
                ),
                _actionButton(
                  context: context,
                  label: 'Reject',
                  icon: Icons.cancel_outlined,
                  backgroundColor: theme.cardColor,
                  textColor: theme.canvasColor,
                  borderColor: Colors.red.withValues(alpha: 0.5),
                  onPressed: () => _showRejectDialog(context, content),
                ),
                _actionButton(
                  context: context,
                  label: 'Request Edit',
                  icon: Icons.edit_outlined,
                  backgroundColor: theme.cardColor,
                  textColor: theme.canvasColor,
                  borderColor: Colors.orange.withValues(alpha: 0.5),
                  onPressed: () => _showEditDialog(context, content),
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
                      builder: (_) =>
                          TrailerPage(trailerUrl: content.contentUrl ?? ''),
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
            onPressed: () {
              Navigator.pop(context);
              if (content.id != null) {
                Provider.of<VideoProvider>(context, listen: false)
                    .changeContentStatus(context, "REJECTED", content.id!);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Content content) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Edit'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter requested changes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.canvasColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final provider =
                  Provider.of<VideoProvider>(context, listen: false);
              provider.reasonController.text = controller.text;
              Navigator.pop(context);
              provider.editContent(context, content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            child: Text(
              'Send Request',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsSection extends StatelessWidget {
  final Content content;
  final String heading;

  const DetailsSection(
      {super.key, required this.content, required this.heading});

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
            _detail('Type', content.type ?? '-'),
            _detail('Status', content.approvalStatus ?? '-'),
            _detail('Release Date', content.releaseDate?.toString() ?? '-'),
            _detail('Runtime', '${content.runtime ?? '-'} min'),
            _detail('Uploaded By', content.mediaHouseName ?? '-'),
            _detail('Price', '₹ ${content.price ?? '-'}'),
            _detail('Revenue', '₹ ${content.totalRevenue ?? '-'}'),
            _detail('Genres', content.genreList?.join(', ') ?? '-'),
            _detail('Languages', content.languageList?.join(', ') ?? '-'),
            _detail('Cast', content.castList?.join(', ') ?? '-'),
            _detail('Director', content.directorList?.join(', ') ?? '-'),
            _detail(
              'Admin Percentage',
              '${content.adminIncentivePecentage ?? '-'}',
            ),
            _detail(
              'MediaHouse Percentage',
              '${content.mediaHouseIncentivePecentage ?? '-'}',
            ),
            _detail('Edit/Reject Reason', content.reason ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _detail(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

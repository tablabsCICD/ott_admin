import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/movie_sales_chart.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/secure_content_player_page.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
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

  @override
  void initState() {
    super.initState();
    _content = widget.content;
    _adminPercentage = _clampPercentage(_content.adminIncentivePecentage);
    if (_content.id != null) {
      Provider.of<VideoProvider>(context, listen: false)
          .contentRevenueGraph(0, _content.id!, '', '');
    }
    Provider.of<VideoProvider>(context, listen: false).fetchMediaHouse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final content = _content;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(content.title ?? 'Movie Details'),
        backgroundColor: theme.primaryColor,
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
            ContentSummaryChips(content: content),
            const SizedBox(height: 12),
            RevenueHighlightCard(content: content),
            const SizedBox(height: 12),
            ActionPanel(
              content: content,
              popOnStatusChange: widget.popOnStatusChange,
              onStatusChanged: _refreshAfterStatusChange,
            ),
            /*   const SizedBox(height: 12),
            _buildSetPercentagePanel(context, content), */
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

  Widget _buildSetPercentagePanel(BuildContext context, Content content) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final mediaHousePercentage = (100 - _adminPercentage).clamp(0.0, 100.0);

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Movie Percentage',
              style: TextStyle(
                color: theme.canvasColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Admin: ${_adminPercentage.toStringAsFixed(2)}%',
                    style: TextStyle(color: theme.canvasColor),
                  ),
                ),
                Expanded(
                  child: Text(
                    'MediaHouse: ${mediaHousePercentage.toStringAsFixed(2)}%',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: theme.canvasColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSettingPercentage
                    ? null
                    : () => _openSetPercentageDialog(content),
                child: _isSettingPercentage
                    ? const AppButtonLoader(label: 'Saving')
                    : const Text('Set Percentage'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSetPercentageDialog(Content content) async {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    final mediaHouse = _resolveMediaHouse(provider, content);

    if (content.id == null) {
      CustomToast.show("Unable to set percentage: invalid content id.",
          isSuccess: false);
      return;
    }
    if (mediaHouse == null || mediaHouse.id == null || mediaHouse.id! <= 0) {
      CustomToast.show("Unable to set percentage: Production house not found.",
          isSuccess: false);
      return;
    }

    final selectedAdminPercentage =
        await _showPercentagePickerDialog(context, _adminPercentage);
    if (selectedAdminPercentage == null || !mounted) return;

    final confirmed = await _showPercentageConfirmDialog(
      context,
      selectedAdminPercentage,
      100 - selectedAdminPercentage,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSettingPercentage = true);
    try {
      final success = await provider.setMoviePercentage(
        context,
        content,
        selectedAdminPercentage,
        100 - selectedAdminPercentage,
        mediaHouse,
        shouldPop: false,
      );
      if (success && mounted) {
        setState(() {
          _adminPercentage = selectedAdminPercentage;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSettingPercentage = false);
      }
    }
  }

  Future<double?> _showPercentagePickerDialog(
      BuildContext context, double initialValue) async {
    double selectedPercentage = _clampPercentage(initialValue);
    final controller = TextEditingController(
      text: selectedPercentage.toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        final theme =
            Provider.of<ThemeProvider>(dialogContext, listen: false).getTheme;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: const Text("Set Percentage"),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      activeColor: theme.primaryColor,
                      value: selectedPercentage,
                      min: 0,
                      max: 100,
                      divisions: 10000,
                      label: "${selectedPercentage.toStringAsFixed(2)}%",
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPercentage = _clampPercentage(value);
                          controller.text =
                              selectedPercentage.toStringAsFixed(2);
                        });
                      },
                    ),
                    TextField(
                      controller: controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Admin %",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed == null) return;
                        setDialogState(() {
                          selectedPercentage = _clampPercentage(parsed);
                        });
                      },
                      onEditingComplete: () {
                        final parsed = double.tryParse(controller.text.trim());
                        setDialogState(() {
                          selectedPercentage = _clampPercentage(parsed);
                          controller.text =
                              selectedPercentage.toStringAsFixed(2);
                        });
                        FocusScope.of(dialogContext).unfocus();
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Admin: ${selectedPercentage.toStringAsFixed(2)}%",
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "MediaHouse: ${(100 - selectedPercentage).toStringAsFixed(2)}%",
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final parsed = double.tryParse(controller.text.trim());
                    Navigator.of(dialogContext).pop(_clampPercentage(parsed));
                  },
                  child: const Text("Next"),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<bool?> _showPercentageConfirmDialog(
    BuildContext context,
    double adminPercentage,
    double mediaHousePercentage,
  ) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text("Confirm Percentage"),
        content: Text(
          "Admin: ${adminPercentage.toStringAsFixed(2)}%\n"
          "MediaHouse: ${mediaHousePercentage.toStringAsFixed(2)}%\n\n"
          "Confirm this split?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  MediaHouse? _resolveMediaHouse(VideoProvider provider, Content content) {
    if (content.mediaHouseId == null) return null;
    for (final item in provider.mediaHouseList) {
      if (item.id == content.mediaHouseId) {
        return item;
      }
    }
    return null;
  }

  double _clampPercentage(dynamic value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null) return 50.0;
    if (parsed < 0) return 0.0;
    if (parsed > 100) return 100.0;
    return parsed;
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

class ContentSummaryChips extends StatelessWidget {
  final Content content;

  const ContentSummaryChips({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(context, Icons.movie_filter_outlined,
            formatContentTypeLabel(content.type)),
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
  final bool popOnStatusChange;
  final ValueChanged<String>? onStatusChanged;

  const ActionPanel({
    super.key,
    required this.content,
    this.popOnStatusChange = false,
    this.onStatusChanged,
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
                /*  _actionButton(
                  context: context,
                  label: 'Request Edit',
                  icon: Icons.edit_outlined,
                  backgroundColor: theme.cardColor,
                  textColor: theme.canvasColor,
                  borderColor: Colors.orange.withValues(alpha: 0.5),
                  onPressed: () => _showEditDialog(context, content),
                ), */
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
              if (content.id != null) {
                Provider.of<VideoProvider>(context, listen: false)
                    .changeContentStatus(context, "PENDING", content.id!);
              }
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
            _detail('Price', _formatCurrency(content.price)),
            _detail('Total Revenue', _formatCurrency(content.totalRevenue)),
            _detail('Admin Revenue', _formatCurrency(content.adminRevnue)),
            _detail(
              'Production House Revenue',
              _formatCurrency(content.mediaHouseRevenue),
            ),
            /*  _detailRow(
              'Revenue',
              _formatCurrency(content.totalRevenue),
              highlight: true,
            ), */
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

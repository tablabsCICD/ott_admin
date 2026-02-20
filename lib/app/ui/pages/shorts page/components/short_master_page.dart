import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20video%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/create_short_parts_dialog.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/edit_short_master_dialog.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/edit_short_part_dialog.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShortMasterPage extends StatefulWidget {
  final int shortId;

  const ShortMasterPage({super.key, required this.shortId});

  @override
  State<ShortMasterPage> createState() => _ShortMasterPageState();
}

class _ShortMasterPageState extends State<ShortMasterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShortsProvider>().fetchShortDetail(
            shortId: widget.shortId,
            userId: 1,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShortsProvider>();
    final theme = Theme.of(context);

    if (provider.isDetailLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }
    if (provider.detailError != null) {
      return Scaffold(
        body: Center(child: Text(provider.detailError!)),
      );
    }

    final short = provider.shortDetail;
    if (short == null) {
      return const Scaffold(
        body: Center(child: Text('Short details not available')),
      );
    }

    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 5
        : ResponsiveWidget.isTablet(context)
            ? 4
            : 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(short.title ?? ""),
        actions: [
          IconButton(
            tooltip: "Edit Short",
            icon: Icon(Icons.edit, color: theme.primaryColor),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: EditShortMasterDialog(
                    shortId: widget.shortId,
                    shortDetail: short,
                  ),
                ),
              );
              if (ok == true && mounted) {
                await context.read<ShortsProvider>().fetchShortDetail(
                      shortId: widget.shortId,
                      userId: 1,
                    );
              }
            },
          ),
          IconButton(
            tooltip: "Delete Short",
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, widget.shortId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    short.poster ?? "",
                    height: 180,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: 130,
                      color: theme.cardColor,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        short.title ?? "",
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Creator: ${short.creatorName ?? '-'}"),
                      Text("Category: ${short.category ?? '-'}"),
                      Text("Coins/Part: ${short.coinsPerPart ?? 0}"),
                      Text("Rental: ${short.rentlDuration ?? '-'}"),
                      const SizedBox(height: 10),
                      if (short.isTrending == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "TRENDING",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(short.description ?? ""),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile("Total Parts", "${short.totalParts ?? 0}"),
                  _buildInfoTile("Views", "${short.viewCount ?? 0}"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Short Videos",
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Parts"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: CreateShortPartsDialog(
                          shortId: short.id ?? 0,
                          totalParts: short.totalParts ?? 0,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      await context.read<ShortsProvider>().fetchShortDetail(
                            shortId: short.id ?? 0,
                            userId: 1,
                          );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: short.parts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 220,
              ),
              itemBuilder: (_, index) {
                final part = short.parts[index];
                return _buildPartTile(theme, part);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }

  Widget _buildPartTile(ThemeData theme, ShortDetailPart part) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            part.thumbnail ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: theme.cardColor,
              child: Center(child: Text("Part ${part.partNumber ?? '-'}")),
            ),
          ),
          if ((part.videoUrl ?? '').isNotEmpty)
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: TrailerPage(trailerUrl: part.videoUrl ?? ''),
                    ),
                  ),
                );
              },
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 46),
              ),
            ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: part.isFreePreview == true ? Colors.green : Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                part.isFreePreview == true
                    ? "FREE"
                    : "Part ${part.partNumber ?? '-'}",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Row(
              children: [
                _actionIcon(
                  icon: Icons.edit,
                  color: Colors.orange,
                  onTap: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: EditShortPartDialog(
                          shortId: widget.shortId,
                          part: part,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      await context.read<ShortsProvider>().fetchShortDetail(
                            shortId: widget.shortId,
                            userId: 1,
                          );
                    }
                  },
                ),
                const SizedBox(width: 6),
                _actionIcon(
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () => _confirmDeletePart(context, part.partId ?? '0'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statChip(icon: Icons.remove_red_eye, value: part.views ?? 0),
                _statChip(
                  icon: Icons.favorite,
                  value: part.likes ?? 0,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required int value,
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePart(BuildContext context, String partId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Part"),
        content: const Text("Are you sure you want to delete this part?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<ShortsProvider>();
              final success = await provider.deleteShortPart(partId: partId);
              if (!mounted) return;
              if (success) {
                await provider.fetchShortDetail(
                  shortId: widget.shortId,
                  userId: 1,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Part deleted successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to delete part")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int shortId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Short"),
        content: const Text("Are you sure you want to delete this short?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<ShortsProvider>()
                  .deleteShortMaster(shortId: shortId);
              if (!mounted) return;
              if (success) {
                Navigator.pop(context, true);
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

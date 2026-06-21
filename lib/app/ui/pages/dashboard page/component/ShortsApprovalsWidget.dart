import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/short_master_page.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShortsApprovalsWidget extends StatelessWidget {
  const ShortsApprovalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Consumer<ShortsProvider>(
        builder: (context, provider, child) {
          final shorts = provider.filteredShortsByStatus;

          if (provider.isStatusListLoading && shorts.isEmpty) {
            return const AppCardSkeletonList(itemCount: 3);
          }

          if (shorts.isEmpty) {
            return Center(
              child: Text(
                "No short/mini series available for approval.",
                style: TextStyle(color: theme.canvasColor),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...shorts.map((short) {
                  return _buildShortCard(context, short, theme, provider);
                }),
                if (provider.isStatusListLoading)
                  const AppPaginationLoader(label: 'Refreshing approvals'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortCard(
    BuildContext context,
    ShortMaster short,
    ThemeData theme,
    ShortsProvider provider,
  ) {
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.canvasColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                short.title ?? "Untitled Short",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("Creator: ${short.creatorName ?? '-'}"),
              Text("Parts: ${short.totalParts ?? 0}"),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ShortMasterPage(shortId: short.id ?? 0);
                      }));
                      if (!context.mounted) return;
                      await provider.fetchShortsByStatus(
                        status: provider.currentStatusFilter,
                      );
                    },
                    child: Text(
                      'Open',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

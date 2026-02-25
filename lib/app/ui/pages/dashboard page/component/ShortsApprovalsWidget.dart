import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/short_master_page.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShortsApprovalsWidget extends StatefulWidget {
  const ShortsApprovalsWidget({super.key});

  @override
  State<ShortsApprovalsWidget> createState() => _ShortsApprovalsWidgetState();
}

class _ShortsApprovalsWidgetState extends State<ShortsApprovalsWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<ShortsProvider>(context, listen: false)
        .fetchShortsByStatus(status: "PENDING");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Consumer<ShortsProvider>(
        builder: (context, provider, child) {
          final shorts = provider.filteredShortsByStatus;

          if (provider.isStatusListLoading && shorts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          }

          if (shorts.isEmpty) {
            return Center(
              child: Text(
                "No shorts available for approval.",
                style: TextStyle(color: theme.canvasColor),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: shorts.map((short) {
                return _buildShortCard(context, short, theme, provider);
              }).toList(),
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
    final status = (short.approvalStatus ?? "PENDING").toUpperCase();
    final isUpdating = provider.isUpdatingShortStatus;

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
              const SizedBox(height: 4),
              Text("Creator: ${short.creatorName ?? '-'}"),
              Text("Category: ${short.category ?? '-'}"),
              Text("Parts: ${short.totalParts ?? 0}"),
              Text("Views: ${short.viewCount ?? 0}"),
              Text("Status: $status"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ShortMasterPage(shortId: short.id ?? 0);
                      }));
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

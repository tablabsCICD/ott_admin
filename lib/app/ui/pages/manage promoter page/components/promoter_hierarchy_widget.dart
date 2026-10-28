import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoter_details_page.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromoterHierarchyWidget extends StatelessWidget {
  final Promoters promoter;
  final bool isInteractive;

  const PromoterHierarchyWidget({
    super.key,
    required this.promoter,
    this.isInteractive = true,
  });

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'national':
        return Colors.deepPurple;
      case 'state':
        return Colors.blueAccent;
      case 'district':
        return Colors.orangeAccent;
      case 'taluka':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'national':
        return Icons.public;
      case 'state':
        return Icons.map_outlined;
      case 'district':
        return Icons.location_city_outlined;
      case 'taluka':
        return Icons.place_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    final path = provider.getHierarchyPath(promoter);
    final children = provider.getChildPromoters(promoter);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_outlined, color: theme.canvasColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Promoter Hierarchy View',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.canvasColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor(promoter.normalizedLevel).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getLevelColor(promoter.normalizedLevel).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Current Level: ${promoter.normalizedLevel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(promoter.normalizedLevel),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Multi-tier parent-child relationship (National → State → District → Taluka → Users)',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Hierarchy Breadcrumb / Chain Flow
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;

              if (!isWide) {
                return Column(
                  children: [
                    ...path.asMap().entries.map((entry) {
                      final p = entry.value;
                      final isCurrent = p.id == promoter.id;
                      return Column(
                        children: [
                          _buildNodeCard(
                            context: context,
                            promoterItem: p,
                            isCurrent: isCurrent,
                            theme: theme,
                          ),
                          if (entry.key < path.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Icon(Icons.arrow_downward,
                                  color: theme.primaryColor, size: 20),
                            ),
                        ],
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(Icons.arrow_downward,
                          color: Colors.green, size: 20),
                    ),
                    _buildUsersNodeCard(theme),
                  ],
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...path.asMap().entries.map((entry) {
                      final p = entry.value;
                      final isCurrent = p.id == promoter.id;
                      return Row(
                        children: [
                          _buildNodeCard(
                            context: context,
                            promoterItem: p,
                            isCurrent: isCurrent,
                            theme: theme,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: theme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                      );
                    }),
                    _buildUsersNodeCard(theme),
                  ],
                ),
              );
            },
          ),

          if (children.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_outline, color: theme.canvasColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Direct Child Promoters (${children.length})',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.canvasColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: children.map((child) {
                return InkWell(
                  onTap: isInteractive
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PromoterDetailsPage(promoter: child),
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getLevelColor(child.normalizedLevel)
                            .withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _getLevelColor(child.normalizedLevel)
                              .withValues(alpha: 0.2),
                          child: Icon(
                            _getLevelIcon(child.normalizedLevel),
                            size: 16,
                            color: _getLevelColor(child.normalizedLevel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.promoterName ?? 'Promoter',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${child.normalizedLevel} • ${child.location?.district ?? child.location?.state ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.canvasColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right,
                            size: 16, color: theme.primaryColor),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeCard({
    required BuildContext context,
    required Promoters promoterItem,
    required bool isCurrent,
    required ThemeData theme,
  }) {
    final level = promoterItem.normalizedLevel;
    final color = _getLevelColor(level);

    return InkWell(
      onTap: isInteractive && !isCurrent
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PromoterDetailsPage(promoter: promoterItem),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? color.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? color : Colors.grey.withValues(alpha: 0.3),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(_getLevelIcon(level), size: 14, color: color),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$level Level',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              promoterItem.promoterName ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'ID: ${promoterItem.id ?? promoterItem.userId?.id ?? "N/A"}',
              style: TextStyle(
                fontSize: 11,
                color: theme.canvasColor.withValues(alpha: 0.6),
              ),
            ),
            if (promoterItem.location?.district != null ||
                promoterItem.location?.state != null)
              Text(
                promoterItem.location?.district ?? promoterItem.location?.state ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.canvasColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersNodeCard(ThemeData theme) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: Colors.green.withValues(alpha: 0.2),
                child: const Icon(Icons.people, size: 14, color: Colors.green),
              ),
              const SizedBox(width: 6),
              const Text(
                'End Users',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Assigned Users',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            'Subscribers & Viewers',
            style: TextStyle(
              fontSize: 11,
              color: theme.canvasColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

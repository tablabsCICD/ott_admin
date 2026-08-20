import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/themeProvider.dart';
import 'media_house_detail_page.dart';

class ProfilePageCard extends StatelessWidget {
  final MediaHouse mediaHouse;
  final MediaHouseProvider provider;
  const ProfilePageCard(this.mediaHouse, this.provider, {super.key});

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaHouseDetailPage(mediaHouse: mediaHouse),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: const EdgeInsets.all(6),
        color: selectedThemeData.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selectedThemeData.canvasColor.withValues(alpha: 0.10),
          ),
        ),
        child: Container(
          width: 250,
          height: 250,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedThemeData.focusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: selectedThemeData.primaryColor
                          .withValues(alpha: 0.14),
                      backgroundImage: (mediaHouse.logo ?? '').isNotEmpty
                          ? NetworkImage(mediaHouse.logo!)
                          : null,
                      child: (mediaHouse.logo ?? '').isEmpty
                          ? Icon(
                              Icons.business_outlined,
                              color: selectedThemeData.primaryColor,
                            )
                          : null,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaHouse.mediaHouseName ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selectedThemeData.canvasColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: selectedThemeData.canvasColor
                                    .withValues(alpha: 0.65),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  mediaHouse.contactNumber ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selectedThemeData.canvasColor
                                        .withValues(alpha: 0.72),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: ProfileStat(
                      title: mediaHouse.postCount ?? '',
                      subtitle: 'Total Movie',
                      emphasized: true,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: ProfileStat(
                      title: mediaHouse.totalViews ?? '',
                      subtitle: 'Views',
                      emphasized: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                'Revenue',
                style: TextStyle(
                  color: selectedThemeData.canvasColor.withValues(alpha: 0.62),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ProfileStat(
                        title: _formatRevenue(mediaHouse.displayTotalRevenue),
                        subtitle: 'Total',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ProfileStat(
                        title: _formatRevenue(mediaHouse.adminRevnue),
                        subtitle: 'Admin',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ProfileStat(
                        title: _formatRevenue(mediaHouse.mediaHouseRevenue),
                        subtitle: 'Production House',
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

  static String _formatRevenue(String? value) {
    if (value == null) return 'Rs. -';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Rs. -';
    if (trimmed.startsWith('Rs.') || trimmed.startsWith('Rs') || trimmed.startsWith('₹')) {
      return trimmed;
    }
    final amount = num.tryParse(trimmed);
    if (amount == null) return 'Rs. $trimmed';
    return 'Rs. ${amount % 1 == 0 ? amount.toInt() : amount}';
  }
}

class ProfileStat extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool emphasized;

  const ProfileStat({
    required this.title,
    required this.subtitle,
    this.emphasized = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: emphasized ? 8 : 4,
        vertical: emphasized ? 7 : 6,
      ),
      decoration: BoxDecoration(
        color: emphasized
            ? theme.primaryColor.withValues(alpha: 0.08)
            : theme.scaffoldBackgroundColor.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.isEmpty ? '-' : title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: emphasized ? theme.primaryColor : theme.canvasColor,
              fontSize: emphasized ? 13 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: emphasized ? 10 : 9,
              color: theme.canvasColor.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

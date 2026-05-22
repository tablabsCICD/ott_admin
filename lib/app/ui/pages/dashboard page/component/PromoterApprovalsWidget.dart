import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/promoter_profile_dailog.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromoterApprovalsWidget extends StatelessWidget {
  const PromoterApprovalsWidget({super.key});

  void _approvePromoter(BuildContext context, Promoters promoter) {
    showPromoterDetailsDialog(context, promoter);
    /* ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${promoter.promoterName} has been approved!')),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Theme.of(context); // Replace with your theme logic

    return Expanded(
      child: Consumer<PromoterProvider>(builder: (context, provider, child) {
        return provider.filteredPromotersByStatus.isEmpty
            ? Center(
                child: Text(
                "No Promoters available for approval.",
                style: TextStyle(color: selectedThemeData.canvasColor),
              ))
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: provider.filteredPromotersByStatus.map((promoter) {
                    return Card(
                      color: selectedThemeData.cardColor,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedThemeData.canvasColor.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promoter.promoterName ?? 'Unknown Promoter',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildPromoterLocation(
                                  promoter, selectedThemeData),
                              Text(
                                  'Mobile: ${promoter.userId?.mobileNumber ?? ''}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _approvePromoter(context, promoter);
                                    },
                                    child: Text(
                                      'Open',
                                      style: TextStyle(
                                        color: selectedThemeData.primaryColor,
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
                  }).toList(),
                ),
              );
      }),
    );
  }

  Widget _buildPromoterLocation(
      Promoters promoter, ThemeData selectedThemeData) {
    return Text(
      _promoterLocationText(promoter),
      style: TextStyle(
        color: selectedThemeData.canvasColor,
        fontSize: 14,
      ),
    );
  }

  String _promoterLocationText(Promoters promoter) {
    final level = promoter.level ?? 'Unknown';
    final location = promoter.location;
    switch (level.toLowerCase()) {
      case 'national':
        return '$level Level (${location?.country ?? '-'})';
      case 'state':
        return '$level Level (${location?.state ?? '-'})';
      case 'district':
        return '$level Level (${location?.district ?? '-'})';
      case 'taluka':
        return '$level Level (${location?.taluka ?? '-'})';
      default:
        return 'Unknown Level';
    }
  }
}

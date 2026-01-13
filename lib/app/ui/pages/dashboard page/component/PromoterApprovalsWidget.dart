import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/promoter_profile_dailog.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromoterApprovalsWidget extends StatefulWidget {
  @override
  State<PromoterApprovalsWidget> createState() => _PromoterApprovalsWidgetState();
}

class _PromoterApprovalsWidgetState extends State<PromoterApprovalsWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PromoterProvider>(context, listen: false).fetchPromotersByStatus("PENDING");
  }
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
      child:  Consumer<PromoterProvider>(
        builder: (context, provider, child) {
      return provider.filteredPromotersByStatus.isEmpty? Center(
          child: Text(
            "No Promoters available for approval.",
            style: TextStyle(color: selectedThemeData.primaryColor),
          )):SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: provider.filteredPromotersByStatus.map((promoter) {
              return Card(
                color: selectedThemeData.cardColor,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedThemeData.canvasColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promoter.promoterName as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Email: ${promoter.userId!.emailId??''}'),
                        Text('Area: ${promoter.location!.area??""}'),
                        Text('Invited by: ${promoter.userId!.refferedBy??""}'),
                        Text('Joined Date: ${promoter.userId!.joinDate??""}'),
                        Text('Status: ${promoter.status}'),
                        const SizedBox(height: 12),
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
        );}
      ),
    );
  }
}

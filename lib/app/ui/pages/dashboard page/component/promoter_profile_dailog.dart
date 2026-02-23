import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/entities/promoter.dart';
import '../../../../provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

void showPromoterDetailsDialog(BuildContext context, Promoters promoter) {
  String status = "APPROVED";

  final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width:
                    ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ⭐ important
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: theme.canvasColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: theme.primaryColor),
                          onPressed: () => deletePromoter(context, promoter),
                        ),
                      ],
                    ),
                    // Text(
                    //   promoters.promoterName ?? "Unknown",
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 16,
                    //     color: theme.canvasColor,
                    //   ),
                    // ),

                    const SizedBox(height: 6),

                    /// ROLE
                    Text(
                      promoter.promoterName ?? "-",
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      promoter.level!.toLowerCase() == 'national'
                          ? "${promoter.level ?? "Unknown"} Level (${promoter.location!.country})"
                          : promoter.level!.toLowerCase() == 'state'
                              ? "${promoter.level ?? "Unknown"} Level (${promoter.location!.state})"
                              : promoter.level!.toLowerCase() == 'district'
                                  ? "${promoter.level ?? "Unknown"} Level (${promoter.location!.district})"
                                  : promoter.level!.toLowerCase() == 'taluka'
                                      ? "${promoter.level ?? "Unknown"} Level (${promoter.location!.taluka})"
                                      : "Unknown Level",
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      promoter.userId!.mobileNumber ?? "-",
                      style: TextStyle(
                        color: theme.canvasColor,
                      ),
                    ),
                    Text(
                      promoter.userId!.emailId ?? "-",
                      style: TextStyle(
                        color: theme.canvasColor,
                      ),
                    ),
                    Text(
                      promoter.userId!.refferedBy ?? "-",
                      style: TextStyle(
                        color: theme.canvasColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// STATUS DROPDOWN
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                        color: theme.cardColor,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: status,
                          isExpanded: true,
                          dropdownColor: theme.scaffoldBackgroundColor,
                          onChanged: (v) => setState(() => status = v!),
                          items: const [
                            DropdownMenuItem(
                                value: "APPROVED", child: Text("Approve")),
                            DropdownMenuItem(
                                value: "PENDING", child: Text("Pending")),
                            DropdownMenuItem(
                                value: "REJECTED", child: Text("Reject")),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                        ),
                        onPressed: () {
                          Provider.of<PromoterProvider>(context, listen: false)
                              .changePromoterStatus(
                                  status, promoter.id!, context);
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void deletePromoter(BuildContext context, Promoters promoter) {
  Provider.of<PromoterProvider>(context, listen: false)
      .deletePromoters(promoter.id!, context);
}

import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/promoter.dart';
import '../../../../provider/promoterProvider.dart';

void showPromoterDetailsDialog(BuildContext context, Promoters promoters) {
  String status = "APPROVED";

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon,
      Color iconColor, String text, ThemeData selectedThemeData) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8.0),
          Text(text, style: TextStyle(color: selectedThemeData.canvasColor)),
        ],
      ),
    );
  }

  Widget buildDropdown(ThemeData selectedThemeData, StateSetter stateSetter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 50,
      decoration: BoxDecoration(
        color: selectedThemeData.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey, // Change to any color you want
          width: 1.0,         // Adjust thickness
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: selectedThemeData.scaffoldBackgroundColor,
          value: status,
          onChanged: (value) {
            stateSetter(() {
              status = value!;
            });
          },
          icon: Icon(Icons.arrow_drop_down,
              color: selectedThemeData.primaryColor),
          items: [
            _buildDropdownItem('APPROVED', Icons.check_circle, Colors.green,
                'APPROVED', selectedThemeData),
            _buildDropdownItem('PENDING', Icons.hourglass_empty, Colors.orange,
                'PENDING', selectedThemeData),
            _buildDropdownItem(
                'REJECTED',
                Icons.cancel,
                selectedThemeData.primaryColor,
                'REJECTED',
                selectedThemeData),
          ],
        ),
      ),
    );
  }




  Widget buildAdminControls(ThemeData theme, BuildContext context, StateSetter setState) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Controls",
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildDropdown(theme,setState),

            const SizedBox(height: 16),

            // Elevated Buttons
            ElevatedButton(
              onPressed: () {
                Provider.of<PromoterProvider>(context, listen: false).changePromoterStatus(status, promoters.id!,context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  var selectedThemeData = Provider.of<ThemeProvider>(context, listen: false).getTheme;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.4, // Set dialog width to 60% of the screen
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                // Close Button
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteMovie(context, promoters),
                                  ),
                                ),
                                // Category and Age Rating Chips
                                Text(
                                  promoters.promoterName ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Description Section
                                Text(
                                  promoters.role ?? '-',
                                ),
                                const SizedBox(height: 20),
                                buildAdminControls(selectedThemeData, context, setState),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

void deleteMovie(BuildContext context, Promoters content) {
  Provider.of<PromoterProvider>(context, listen: false).deletePromoters(content.id!, context);
}

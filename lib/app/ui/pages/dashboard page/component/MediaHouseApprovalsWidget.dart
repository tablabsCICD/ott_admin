import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/mediaHouse_profile_page.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaHouseApprovalsWidget extends StatefulWidget {
  const MediaHouseApprovalsWidget({super.key});

  @override
  State<MediaHouseApprovalsWidget> createState() =>
      _MediaHouseApprovalsWidgetState();
}

class _MediaHouseApprovalsWidgetState extends State<MediaHouseApprovalsWidget> {
  /*final List<Map<String, dynamic>> mediaHouseList = [
    {
      'id': 1,
      'name': 'Times Media Group',
      'email': 'contact@timesmedia.com',
      'location': 'New York, USA',
      'joinedDate': '2025-01-10',
      'status': 'Pending Approval',
    },
    {
      'id': 2,
      'name': 'Daily News Corp',
      'email': 'info@dailynews.com',
      'location': 'London, UK',
      'joinedDate': '2025-01-09',
      'status': 'Pending Approval',
    },
    {
      'id': 3,
      'name': 'Global Media Network',
      'email': 'hello@globalmedia.com',
      'location': 'Sydney, Australia',
      'joinedDate': '2025-01-08',
      'status': 'Pending Approval',
    },
  ];*/

  void _openMediaHouseDetails(BuildContext context, MediaHouse mediaHouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaHouseProfilePage(mediaHouse: mediaHouse),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<MediaHouseProvider>(context, listen: false)
        .fetchMediaHouseByStatus("PENDING");
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Theme.of(context); // Replace with your theme logic
    return Expanded(child:
        Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      return provider.filteredMediaHouseListByStatus.isEmpty
          ? Center(
              child: Text(
              "No Media House available for approval.",
              style: TextStyle(color: selectedThemeData.canvasColor),
            ))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    provider.filteredMediaHouseListByStatus.map((mediaHouse) {
                  return Card(
                    color: selectedThemeData.cardColor,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
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
                              mediaHouse.mediaHouseName as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Mobile: ${mediaHouse.contactNumber ?? ""}'),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _openMediaHouseDetails(context, mediaHouse);
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
    }));
  }
}

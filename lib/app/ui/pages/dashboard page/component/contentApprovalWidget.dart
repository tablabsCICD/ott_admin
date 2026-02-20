import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../provider/videoProvider.dart';
import 'approve_content_detail_page.dart';

class ContentApprovalWidget extends StatefulWidget {
  const ContentApprovalWidget({super.key});

  @override
  State<ContentApprovalWidget> createState() => _ContentApprovalWidgetState();
}

class _ContentApprovalWidgetState extends State<ContentApprovalWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<VideoProvider>(context, listen: false)
        .fetchMoviesByStatusAndMediaHouseId("PENDING", 0);
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Expanded(
      child: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          return provider.filteredContentListByMediaHouse.isEmpty
              ? Center(
                  child: Text(
                    "No content available for approval.",
                    style: TextStyle(color: selectedThemeData.canvasColor),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        provider.filteredContentListByMediaHouse.map((content) {
                      return _buildContentCard(
                          context, content, selectedThemeData);
                    }).toList(),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildContentCard(
      BuildContext context, Content content, ThemeData themeData) {
    return Card(
      color: themeData.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: themeData.canvasColor.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                content.title ?? "Untitled",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              // Genre and Type
              Text(
                '${content.genreList?.firstOrNull ?? "Unknown Genre"} - ${content.type ?? "Unknown Type"}',
                style: TextStyle(color: themeData.hintColor),
              ),
              // Media House and Language
              Text('Uploaded by: ${content.mediaHouseName ?? "Unknown"}'),
              Text(
                  'Language: ${content.languageList?.join(", ") ?? "Unknown"}'),
              // Upload Date and Status
              Text('Uploaded at: ${content.uploadDateTime ?? "Unknown"}'),
              Text('Status: ${content.approvalStatus ?? "Pending"}'),
              const SizedBox(height: 12),
              // Open Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _openContentDetailsPage(context, content),
                    child: Text(
                      'Open',
                      style: TextStyle(color: themeData.primaryColor),
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

  Future<void> _openContentDetailsPage(
      BuildContext context, Content content) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApproveContentDetailsPage(content: content),
      ),
    );
  }
}

extension ListExtension<T> on List<T>? {
  T? get firstOrNull => this != null && this!.isNotEmpty ? this!.first : null;
}

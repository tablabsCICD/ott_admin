import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/add_video.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_card.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';

import '../../../../domain/entities/content.dart';

class ShortFilmListScreen extends StatefulWidget {
  const ShortFilmListScreen({super.key});

  @override
  State<ShortFilmListScreen> createState() => _ShortFilmListScreenState();
}

class _ShortFilmListScreenState extends State<ShortFilmListScreen> {
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VideoProvider>(context, listen: false);
    provider.fetchMoviesByStatusAndMediaHouseId("All", 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, child) {
        var selectedThemeData =
            Provider.of<ThemeProvider>(context, listen: false).getTheme;
        int crossAxisCount = ResponsiveWidget.isDesktop(context)
            ? 4
            : ResponsiveWidget.isMobile(context)
                ? 2
                : 4;

        final query = provider.searchContentController.text.trim().toLowerCase();

        final shortFilms = provider.contentList.where((content) {
          final isShortFilm = (content.type ?? '').toUpperCase() == 'SHORT_FILM';
          if (!isShortFilm) return false;

          if (selectedStatus != 'All') {
            final matchesStatus =
                (content.approvalStatus ?? '').toUpperCase() ==
                    selectedStatus.toUpperCase();
            if (!matchesStatus) return false;
          }

          if (query.isNotEmpty) {
            final title = (content.title ?? '').toLowerCase();
            final desc = (content.description ?? '').toLowerCase();
            final rating = (content.ageRating ?? '').toLowerCase();
            if (!title.contains(query) &&
                !desc.contains(query) &&
                !rating.contains(query)) {
              return false;
            }
          }
          return true;
        }).toList();

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: ResponsiveWidget.isMobile(context)
                            ? double.infinity
                            : 60,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveWidget.isMobile(context)
                                  ? 8.0
                                  : 16.0),
                          child: CustomTextField(
                            controller: provider.searchContentController,
                            prefixIcon: Icon(
                              Icons.search,
                              color: selectedThemeData.canvasColor,
                            ),
                            hintText: 'Search Short Films...',
                            textInputType: TextInputType.text,
                          ),
                        ),
                      ),
                    ),
                    _buildDropdown(selectedThemeData, provider),
                  ],
                ),
              ),
              shortFilms.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "No Short Films found. Check back soon!",
                          style:
                              TextStyle(color: selectedThemeData.primaryColor),
                        ),
                      ),
                    )
                  : Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: ResponsiveWidget.isMobile(context)
                              ? 0.95
                              : ResponsiveWidget.isDesktop(context)
                                  ? 1.05
                                  : 1.0,
                        ),
                        itemCount: shortFilms.length,
                        itemBuilder: (context, index) {
                          Content content = shortFilms[index];
                          return MovieCard(movie: content);
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown(ThemeData selectedThemeData, VideoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 50,
      decoration: BoxDecoration(
        color: selectedThemeData.cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: selectedThemeData.scaffoldBackgroundColor,
          value: selectedStatus,
          onChanged: (value) {
            setState(() {
              selectedStatus = value!;
            });
            provider.fetchMoviesByStatusAndMediaHouseId(
                selectedStatus.toUpperCase(), 0);
          },
          icon: Icon(Icons.arrow_drop_down,
              color: selectedThemeData.primaryColor),
          items: [
            _buildDropdownItem('All', Icons.check_circle, Colors.amber,
                'All Short Films', selectedThemeData),
            _buildDropdownItem('Approved', Icons.check_circle, Colors.green,
                'Approved Short Films', selectedThemeData),
            _buildDropdownItem('Pending', Icons.hourglass_empty, Colors.orange,
                'Pending Short Films', selectedThemeData),
            _buildDropdownItem(
                'Rejected',
                Icons.cancel,
                selectedThemeData.primaryColor,
                'Rejected Short Films',
                selectedThemeData),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon,
      Color iconColor, String text, ThemeData selectedThemeData) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 4.0),
          Text(text, style: TextStyle(color: selectedThemeData.canvasColor)),
        ],
      ),
    );
  }
}

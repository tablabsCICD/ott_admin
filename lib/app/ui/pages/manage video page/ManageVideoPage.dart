import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20video%20page/component/add_video.dart';
import 'package:admin_ott/app/ui/pages/manage%20video%20page/component/movie_card.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';

import '../../../../domain/entities/content.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedStatus = 'All';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final provider = Provider.of<VideoProvider>(context, listen: false);
    provider.fetchMoviesByStatusAndMediaHouseId("All", 0);
    provider.searchContentController.addListener(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, provider, child) {
        var selectedThemeData =
            Provider.of<ThemeProvider>(context, listen: false).getTheme;
        int crossAxisCount = ResponsiveWidget.isDesktop(context)
            ? 6
            : ResponsiveWidget.isMobile(context)
                ? 2
                : 4;

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Expanded(
                      child: SizedBox(
                        width: ResponsiveWidget.isMobile(context)
                            ? double.infinity
                            : 600,
                        child: CustomTextField(
                          controller: provider.searchContentController,
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search...',
                          textInputType: TextInputType.text,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildDropdown(selectedThemeData, provider),
                  ],
                ),
              ),
              provider.filteredContentList.isEmpty? Center(
                  child: Text(
                    "Looks like there's no content yet. Check back soon!",
                    style: TextStyle(color: selectedThemeData.primaryColor),
                  )):Expanded(
                child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 10,
                      childAspectRatio: 27 / 40,
                    ),
                    itemCount: provider.filteredContentList.length,
                    itemBuilder: (context, index) {
                      print(provider.filteredContentList[index].title);
                      Content content = provider.filteredContentList[index];
                      return MovieCard(
                          movie: content);
                    }),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingButton(selectedThemeData),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildDropdown(ThemeData selectedThemeData, VideoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                'All Content', selectedThemeData),
            _buildDropdownItem('Approved', Icons.check_circle, Colors.green,
                'Approved Content', selectedThemeData),
            _buildDropdownItem('Pending', Icons.hourglass_empty, Colors.orange,
                'Pending Content', selectedThemeData),
            _buildDropdownItem(
                'Rejected',
                Icons.cancel,
                selectedThemeData.primaryColor,
                'Rejected Content',
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
          const SizedBox(width: 8.0),
          Text(text, style: TextStyle(color: selectedThemeData.canvasColor)),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(ThemeData selectedThemeData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddDataWidget()),
        );
      },
      child: Container(
        height: 40,
        width: 160,
        decoration: BoxDecoration(
          color: selectedThemeData.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Upload Content',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

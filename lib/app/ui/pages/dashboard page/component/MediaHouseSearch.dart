import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/media_house_detail_page.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/repositories/mediahouselist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaHouseSearch extends StatefulWidget {
  @override
  _MediaHouseSearchState createState() => _MediaHouseSearchState();
}

class _MediaHouseSearchState extends State<MediaHouseSearch> {
  OverlayEntry? _dropdownOverlay;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MediaHouseProvider>(context, listen: false);
    provider.searchMediaHouseController.addListener(() {
      if (_dropdownOverlay != null) {
        _refreshDropdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  void _showDropdown(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final mediaHouseProvider =
        Provider.of<MediaHouseProvider>(context, listen: false);
    if (mediaHouseProvider.mediaHouseList.isEmpty) {
      mediaHouseProvider.fetchMediaHouse();
    }
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height - 170,
        width: renderBox.size.width,
        child: Material(
          color: selectedThemeData.cardColor,
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child:
              Consumer<MediaHouseProvider>(builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: provider.searchMediaHouseController,
                        hintText: 'Search Production house...',
                        textInputType: TextInputType.text,
                      ),
                    ),
                    IconButton(
                      onPressed: _removeDropdown,
                      icon: Icon(
                        Icons.close,
                        color: selectedThemeData.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (provider.filteredMediaHouseList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      itemCount: provider.filteredMediaHouseList.length,
                      itemBuilder: (context, index) {
                        final house = provider.filteredMediaHouseList[index];
                        return ListTile(
                          tileColor: selectedThemeData.cardColor,
                          title: Text(house.mediaHouseName ?? ''),
                          onTap: () {
                            provider.setSelectedMediaHouse(house);
                            _removeDropdown();
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  void _refreshDropdown() {
    if (_dropdownOverlay != null) {
      _dropdownOverlay?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _removeDropdown();
    super.dispose();
  }

  Widget _buildPage(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      return Card(
        color: selectedThemeData.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Production House ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedThemeData.primaryColor,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  if (_dropdownOverlay == null) {
                    _showDropdown(context);
                  } else {
                    _removeDropdown();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedThemeData.canvasColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.selectedMediaHouse!.mediaHouseName ??
                            'Select a Production House',
                        style: TextStyle(color: selectedThemeData.canvasColor),
                      ),
                      Icon(
                        _dropdownOverlay == null
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up,
                        color: selectedThemeData.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  "(Enter the Production house's name to view their profile details, content, and performance statistics.)",
                  style: TextStyle(
                    color: selectedThemeData.canvasColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: provider.selectedMediaHouse!.mediaHouseName ==
                                null ||
                            provider.selectedMediaHouse!.mediaHouseName == ''
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MediaHouseDetailPage(
                                  mediaHouse: provider.selectedMediaHouse!,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: provider.selectedMediaHouse == null
                          ? selectedThemeData.primaryColor.withOpacity(0.5)
                          : selectedThemeData.primaryColor,
                      shadowColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text('Show Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

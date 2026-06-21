import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoter_details_page.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromoterSearch extends StatefulWidget {
  @override
  _PromoterSearchState createState() => _PromoterSearchState();
}

class _PromoterSearchState extends State<PromoterSearch> {
  OverlayEntry? _dropdownOverlay;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    provider.searchController.addListener(() {
      if (_dropdownOverlay != null) {
        _refreshDropdown();
      }
    });
  }

  void _showDropdown(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;
    final promoterProvider =
        Provider.of<PromoterProvider>(context, listen: false);
    if (promoterProvider.promoterList.isEmpty) {
      promoterProvider.fetchPromoters();
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
              Consumer<PromoterProvider>(builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: provider.searchController,
                        hintText: 'Search promoter...',
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
                if (provider.filteredPromoters.isEmpty)
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
                      itemCount: provider.filteredPromoters.length,
                      itemBuilder: (context, index) {
                        final promoter = provider.filteredPromoters[index];
                        return ListTile(
                          tileColor: selectedThemeData.cardColor,
                          title: Text(promoter.promoterName ?? ''),
                          trailing: Text(
                            'ID: ${promoter.id ?? 0}',
                          ),
                          onTap: () {
                            provider.setSelectedPromoter(promoter);
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
    //_searchController.dispose();
    _removeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Consumer<PromoterProvider>(builder: (context, provider, child) {
      return Card(
        color: selectedThemeData.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Promoter',
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
                        provider.selectedPromoter!.promoterName ??
                            'Select a Promoter',
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
                  "(Enter the promoter's name to view their profile details and performance statistics.)",
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
                    onPressed:
                        provider.selectedPromoter!.promoterName == null ||
                                provider.selectedPromoter!.promoterName == ''
                            ? null
                            : () {
                                _removeDropdown();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PromoterDetailsPage(
                                      promoter: provider.selectedPromoter!,
                                    ),
                                  ),
                                );
                              },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: provider.selectedPromoter == null
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

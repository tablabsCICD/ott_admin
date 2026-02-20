import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/add_promoter.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/all_promoter_graph.dart';
import 'package:admin_ott/app/ui/pages/manage%20promoter%20page/components/promoterList.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/models/request/save_promoter_request.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'components/promoter_details_page.dart';

class ManagePromoterPage extends StatefulWidget {
  const ManagePromoterPage({Key? key}) : super(key: key);

  @override
  State<ManagePromoterPage> createState() => _ManagePromoterPageState();
}

class _ManagePromoterPageState extends State<ManagePromoterPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    provider.fetchPromoters();
    provider.searchController.addListener(() {});
  }

  void _openAddPromoterForm() {
    showAddPromoterDialog(context, _onAddPromoter);
  }

  void _onAddPromoter(SavePromoterRequest promoter) {
    final provider = Provider.of<PromoterProvider>(context, listen: false);
    provider.createPromoters(promoter);
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveWidget.isMobile(context)
          ? _buildMobileLayout(theme)
          : _buildDesktopLayout(theme),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Consumer<PromoterProvider>(builder: (context, provider, child) {
      return Column(
        children: [
          _buildLevelDropdown(theme, provider),
          _buildSearchBar(theme, provider),
          Expanded(child: _buildPromoterList(theme)),
        ],
      );
    });
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required int index,
  }) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return SizedBox(
      // height: 90,
      width: 200,
      child: Card(
        color: selectedThemeData.cardColor,
        child: Column(
          children: [
            ListTile(
              // leading: Icon(
              //   icon,
              //   color: selectedThemeData.primaryColor,
              // ),
              title: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectedThemeData.canvasColor,
                  ),
                ),
              ),
              subtitle: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: selectedThemeData.primaryColor,
                  ),
                ),
              ),
              /*  trailing: IconButton(
                onPressed: () {
                  // _showGraphPopup(index);
                },
                icon: Icon(
                  Icons.bar_chart_rounded,
                ),
                color: selectedThemeData.primaryColor,
              ),*/
            ),
            /* IconButton(
              onPressed: () {
                // _showGraphPopup(index);
              },
              icon: Icon(
                Icons.bar_chart_rounded,
              ),
              color: selectedThemeData.primaryColor,
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Consumer<PromoterProvider>(builder: (context, provider, child) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatisticCard(
                        title: 'National Promoters',
                        value: provider.countryCount.toString(),
                        icon: Icons.people,
                        index: 0,
                      ),
                      _buildStatisticCard(
                        title: 'State Promoters',
                        value: provider.stateCount.toString(),
                        icon: Icons.people,
                        index: 0,
                      ),
                      _buildStatisticCard(
                        title: 'District Promoters',
                        value: provider.districtCount.toString(),
                        icon: Icons.people,
                        index: 0,
                      ),
                      _buildStatisticCard(
                        title: 'Taluka Promoters',
                        value: provider.talukaCount.toString(),
                        icon: Icons.people,
                        index: 0,
                      ),
                    ],
                  ),
                  // Expanded(child: _buildChart(theme,provider)),
                  Expanded(child: CustomBarGraph())
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildLevelDropdown(theme, provider),
                _buildSearchBar(theme, provider),
                Expanded(child: _buildPromoterList(theme)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: _openAddPromoterForm,
      backgroundColor: theme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildLevelDropdown(ThemeData theme, PromoterProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: 200,
        child: DropdownButtonFormField<String>(
          value: provider.selectedLevel,
          onChanged: (String? newValue) {
            provider.filterPromotersByLevel(newValue!);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: theme.cardColor,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.primaryColor),
            ),
          ),
          dropdownColor: theme.cardColor,
          items: ['All', 'National', 'State', 'District', 'Taluka']
              .map((level) => DropdownMenuItem(
                    value: level,
                    child:
                        Text(level, style: TextStyle(color: theme.canvasColor)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, PromoterProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CustomTextField(
        controller: provider.searchController,
        hintText: 'Search by name, email, or level...',
        textInputType: TextInputType.text,
        prefixIcon: const Icon(Icons.search),
        onValueChange: provider.onSearchValueChange,
      ),
    );
  }

  Widget _buildPromoterList(ThemeData theme) {
    return Consumer<PromoterProvider>(builder: (context, provider, child) {
      print(provider.filteredPromoters.length);
      return provider.filteredPromoters.isEmpty
          ? Center(
              child: Text(
              "Promoter list is empty because no promoter have been added yet.",
              style: TextStyle(color: theme.primaryColor),
            ))
          : ListView.builder(
              itemCount: provider.filteredPromoters.length,
              itemBuilder: (context, index) {
                final promoter = provider.filteredPromoters[index];
                return Card(
                  color: theme.cardColor,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.canvasColor.withOpacity(0.1),
                      child: Text(
                        promoter.promoterName != null &&
                                promoter.promoterName!.isNotEmpty
                            ? promoter.promoterName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: theme.canvasColor.withOpacity(0.5),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(promoter.promoterName ?? "",
                        style: TextStyle(color: theme.canvasColor)),
                    subtitle: Text(promoter.userId!.emailId ?? "",
                        style: TextStyle(color: theme.canvasColor)),
                    trailing: Text('ID: ${promoter.userId!.id ?? ""}',
                        style: TextStyle(color: theme.canvasColor)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PromoterDetailsPage(promoter: promoter),
                      ),
                    ),
                  ),
                );
              },
            );
    });
  }

  Widget _buildChart(ThemeData theme, PromoterProvider provider) {
    final data = {
      'National Level':
          provider.promoterList.where((p) => p.level == 'Country Level').length,
      'State Level':
          provider.promoterList.where((p) => p.level == 'State Level').length,
      'District Level': provider.promoterList
          .where((p) => p.level == 'District Level')
          .length,
      'Taluka Level':
          provider.promoterList.where((p) => p.level == 'Taluka Level').length,
    };

    final chartData = data.entries
        .map((entry) => _ChartData(entry.key, entry.value.toDouble()))
        .toList();

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: CategoryAxis(
            labelStyle: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          series: <CartesianSeries<_ChartData, String>>[
            LineSeries<_ChartData, String>(
              dataSource: chartData,
              xValueMapper: (data, _) => data.level,
              yValueMapper: (data, _) => data.value,
              color: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String level;
  final double value;

  _ChartData(this.level, this.value);
}

/*class AddPromoterDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddPromoterDialog({required this.onAdd, Key? key}) : super(key: key);

  @override
  _AddPromoterDialogState createState() => _AddPromoterDialogState();
}

class _AddPromoterDialogState extends State<AddPromoterDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController talukaController = TextEditingController();

  String selectedLevel = 'State Level';
  final List<String> levels = [
    'State Level',
    'District Level',
    'Taluka Level',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Text(
        'Add New Promoter',
        style: TextStyle(
          color: theme.canvasColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedLevel,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLevel = newValue!;
                  });
                },
                dropdownColor: theme.cardColor,
                items: levels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level,
                              style: TextStyle(color: theme.canvasColor)),
                        ))
                    .toList(),
              ),
              CustomTextField(
                controller: countryController,
                hintText: 'Country',
                textInputType: TextInputType.name,
                validator: (value) => value == null || value.isEmpty
                    ? 'Country is required'
                    : null,
              ),
              CustomTextField(
                controller: stateController,
                hintText: 'State',
                textInputType: TextInputType.name,
                validator: (value) =>
                    value == null || value.isEmpty ? 'State is required' : null,
              ),
              if (selectedLevel == 'District Level' ||
                  selectedLevel == 'Taluka Level')
                CustomTextField(
                  controller: districtController,
                  hintText: 'District',
                  textInputType: TextInputType.name,
                  validator: (value) => value == null || value.isEmpty
                      ? 'District is required'
                      : null,
                ),
              if (selectedLevel == 'Taluka Level')
                CustomTextField(
                  controller: talukaController,
                  hintText: 'Taluka',
                  textInputType: TextInputType.name,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Taluka is required'
                      : null,
                ),
              CustomTextField(
                controller: nameController,
                hintText: 'Name',
                textInputType: TextInputType.name,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              CustomTextField(
                controller: contactController,
                hintText: 'Contact',
                textInputType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Contact is required'
                    : null,
              ),
              CustomTextField(
                controller: emailController,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd({
                'id': DateTime.now().millisecondsSinceEpoch,
                'name': nameController.text,
                'contact': contactController.text,
                'email': emailController.text,
                'country': countryController.text,
                'level': selectedLevel,
                'state': stateController.text,
                'district': districtController.text,
                'taluka': talukaController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}*/

void showAddPromoterDialog(
    BuildContext context, void Function(SavePromoterRequest) onAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddPromoterDialog(onAdd: onAdd);
    },
  );
}

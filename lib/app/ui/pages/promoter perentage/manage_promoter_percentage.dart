
import 'package:admin_ott/app/provider/promoter_percentage_provider.dart';
import 'package:admin_ott/data/models/response/getPromoterPercentage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Make sure this is at the top
import '../../../provider/themeProvider.dart';

class ManagePromoterPercentagePage extends StatefulWidget {


  const ManagePromoterPercentagePage({super.key});

  @override
  State<ManagePromoterPercentagePage> createState() =>
      _ManagePromoterPercentagePageState();
}

class _ManagePromoterPercentagePageState
    extends State<ManagePromoterPercentagePage> {


  // Add‑form controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedLevel = 'National';
  final TextEditingController _viewsCtrl = TextEditingController();
  final TextEditingController _newUserCtrl = TextEditingController();

  final List<String> _levels = ['National', 'State', 'District', 'Taluka'];
  final Set<String> _expandedLevels = {};


  @override
  void initState() {
    super.initState();
    Provider.of<PromoterPercentageProvider>(context, listen: false).getAllPromoterPercentageData();
    _expandedLevels.add("National");
  }

  @override
  void dispose() {
    _viewsCtrl.dispose();
    _newUserCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: SizedBox(),
        title: const Text('Manage Promoter Percentage'),
        backgroundColor: theme.primaryColor,
      ),
      body: Consumer<PromoterPercentageProvider>(
        builder: (context, provider, child) {
          final isMobile = MediaQuery.of(context).size.width < 600;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
              children: [
                _buildAddSection(theme, provider),
                const SizedBox(height: 20),
                _buildHistoryTable(theme, provider),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildHistoryTable(theme, provider)),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: _buildAddSection(theme, provider)),
              ],
            ),
          );
        },
      ),

    );
  }

  /// Add‑Promoter‑Percentage section
  Widget _buildAddSection(ThemeData theme, PromoterPercentageProvider provider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Add Promoter Percentage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.canvasColor,
                ),
              ),
              const SizedBox(height: 16),

              // Promoter Level Dropdown
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(labelText: 'Promoter Level'),
                dropdownColor: theme.cardColor,
                items: _levels
                    .map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(
                    level,
                    style: TextStyle(color: theme.canvasColor),
                  ),
                ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedLevel = val ?? _selectedLevel),
              ),
              const SizedBox(height: 16),

              // Views %
              TextFormField(
                controller: _viewsCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Views %'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // New User %
              TextFormField(
                controller: _newUserCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'New User %'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Save button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  onPressed: _onSavePressed,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildHistoryTable(ThemeData theme, PromoterPercentageProvider provider) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800,), // Uniform width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Latest Promoter Percentage Table
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Promoter Percentages',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.canvasColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: isMobile?20:100, // already increased
                            headingRowColor:
                            MaterialStateProperty.all(theme.primaryColor.withOpacity(0.1)),
                            border: TableBorder.all(color: theme.dividerColor),
                            columns: [
                              DataColumn(label: _tableHeader('Level', theme)),
                              DataColumn(label: _tableHeader('Views %', theme), numeric: true),
                              DataColumn(label: _tableHeader('New User %', theme), numeric: true),
                              DataColumn(label: _tableHeader('Date', theme)),
                            ],
                            rows: provider.latestByLevel.values.map((entry) {
                              final date = DateTime.fromMillisecondsSinceEpoch(entry.date ?? 0);
                              return DataRow(cells: [
                                DataCell(_tableCell(entry.typeOfPromoters ?? '', theme)),
                                DataCell(_tableCell('${entry.viewsPercentage}', theme)),
                                DataCell(_tableCell('${entry.newUserPercentage}', theme)),
                                DataCell(_tableCell(DateFormat('dd MMM yyyy').format(date), theme)),
                              ]);
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Promoter Percentage History by Level
                Text(
                  'Promoter Percentage History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.canvasColor,
                  ),
                ),
                const SizedBox(height: 12),

                ...provider.historyByLevel.entries.map((entry) {
                  final level = entry.key;
                  final entries = entry.value;
                  final isExpanded = _expandedLevels.contains(level);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      color: theme.cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Header with expandable toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$level Level History',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: theme.canvasColor,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: theme.canvasColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedLevels.remove(level);
                                      } else {
                                        _expandedLevels.add(level);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),

                            /// Expandable section
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  DataTable(
                                    columnSpacing: isMobile?20:100,
                                    headingRowColor: MaterialStateProperty.all(
                                        theme.primaryColor.withOpacity(0.05)),
                                    border: TableBorder.all(color: theme.dividerColor),
                                    columns: [
                                      DataColumn(label: _tableHeader('Views %', theme), numeric: true),
                                      DataColumn(label: _tableHeader('New User %', theme), numeric: true),
                                      DataColumn(label: _tableHeader('Date', theme)),
                                    ],
                                    rows: entries.map((entry) {
                                      final date = DateTime.fromMillisecondsSinceEpoch(entry.date ?? 0);
                                      return DataRow(cells: [
                                        DataCell(_tableCell('${entry.viewsPercentage}', theme)),
                                        DataCell(_tableCell('${entry.newUserPercentage}', theme)),
                                        DataCell(_tableCell(dateFormat.format(date), theme)),
                                      ]);
                                    }).toList(),
                                  ),
                                ],
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _tableHeader(String text, ThemeData theme) => Text(
    text,
    style:
    TextStyle(fontWeight: FontWeight.bold, color: theme.canvasColor),
  );

  Widget _tableCell(String text, ThemeData theme) =>
      Text(text, style: TextStyle(color: theme.canvasColor));

  /// Save button pressed
  Future<void> _onSavePressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      await Provider.of<PromoterPercentageProvider>(context, listen: false).setPromoterPercentageData(_selectedLevel, double.parse(_newUserCtrl.text.toString()), double.parse(_viewsCtrl.text.toString()));
      // Clear fields
      _viewsCtrl.clear();
      _newUserCtrl.clear();
    }
  }
}
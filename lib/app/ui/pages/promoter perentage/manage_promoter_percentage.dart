import 'package:admin_ott/app/provider/promoter_percentage_provider.dart';
import 'package:admin_ott/data/models/response/getPromoterPercentage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../provider/themeProvider.dart';

class ManagePromoterPercentagePage extends StatefulWidget {
  const ManagePromoterPercentagePage({super.key});

  @override
  State<ManagePromoterPercentagePage> createState() =>
      _ManagePromoterPercentagePageState();
}

class _ManagePromoterPercentagePageState
    extends State<ManagePromoterPercentagePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedLevel = 'National';
  final TextEditingController _movieCtrl = TextEditingController();
  final TextEditingController _seriesCtrl = TextEditingController();
  final TextEditingController _shortCtrl = TextEditingController();
  final TextEditingController _musicCtrl = TextEditingController();

  final List<String> _levels = ['National', 'State', 'District', 'Taluka'];
  final Set<String> _expandedLevels = {};

  final Map<String, Map<String, double>> _defaultPercentages = {
    'Taluka': {
      'movie': 3,
      'series': 5,
      'short': 5,
      'music': 8,
    },
    'District': {
      'movie': 0.7,
      'series': 1.5,
      'short': 1.5,
      'music': 2,
    },
    'State': {
      'movie': 0.3,
      'series': 0.5,
      'short': 0.5,
      'music': 1,
    },
    'National': {
      'movie': 1,
      'series': 1,
      'short': 1,
      'music': 1,
    },
  };

  @override
  void initState() {
    super.initState();
    Provider.of<PromoterPercentageProvider>(context, listen: false)
        .getAllPromoterPercentageData();
    _expandedLevels.add("National");
    _setDefaultPercentageValues();
  }

  @override
  void dispose() {
    _movieCtrl.dispose();
    _seriesCtrl.dispose();
    _shortCtrl.dispose();
    _musicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<PromoterPercentageProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => _openAddPercentageDialog(theme),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Percentage'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildHistoryTable(theme, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTable(
      ThemeData theme, PromoterPercentageProvider provider) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1000,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                          columnSpacing: isMobile ? 20 : 100,
                          headingRowColor: MaterialStateProperty.all(
                              theme.primaryColor.withOpacity(0.1)),
                          border: TableBorder.all(color: theme.dividerColor),
                          columns: [
                            DataColumn(label: _tableHeader('Level', theme)),
                            DataColumn(
                                label: _tableHeader('Movie %', theme),
                                numeric: true),
                            DataColumn(
                                label: _tableHeader('Series %', theme),
                                numeric: true),
                            DataColumn(
                                label: _tableHeader('Short %', theme),
                                numeric: true),
                            DataColumn(
                                label: _tableHeader('Music %', theme),
                                numeric: true),
                            DataColumn(label: _tableHeader('Date', theme)),
                          ],
                          rows: _levels
                              .map((level) => provider.latestByLevel[level])
                              .whereType<PromoterPercentage>()
                              .map((entry) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                entry.date ?? 0);
                            return DataRow(cells: [
                              DataCell(_tableCell(
                                  entry.typeOfPromoters ?? '', theme)),
                              DataCell(_tableCell(
                                  _percentageText(entry.moviePercentage),
                                  theme)),
                              DataCell(_tableCell(
                                  _percentageText(entry.seriesPercentage),
                                  theme)),
                              DataCell(_tableCell(
                                  _percentageText(entry.shortPercentage),
                                  theme)),
                              DataCell(_tableCell(
                                  _percentageText(entry.musicPercentage),
                                  theme)),
                              DataCell(_tableCell(
                                  DateFormat('dd MMM yyyy').format(date),
                                  theme)),
                            ]);
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Promoter Percentage History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.canvasColor,
                ),
              ),
              const SizedBox(height: 12),
              ..._levels.map((level) {
                final entries = provider.historyByLevel[level] ?? [];
                final isExpanded = _expandedLevels.contains(level);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    color: theme.cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 200),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Column(
                              children: [
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: isMobile ? 20 : 100,
                                    headingRowColor: MaterialStateProperty.all(
                                        theme.primaryColor.withOpacity(0.05)),
                                    border: TableBorder.all(
                                        color: theme.dividerColor),
                                    columns: [
                                      DataColumn(
                                          label: _tableHeader('Movie %', theme),
                                          numeric: true),
                                      DataColumn(
                                          label:
                                              _tableHeader('Series %', theme),
                                          numeric: true),
                                      DataColumn(
                                          label: _tableHeader('Short %', theme),
                                          numeric: true),
                                      DataColumn(
                                          label: _tableHeader('Music %', theme),
                                          numeric: true),
                                      DataColumn(
                                          label: _tableHeader('Date', theme)),
                                    ],
                                    rows: entries.map((entry) {
                                      final date =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              entry.date ?? 0);
                                      return DataRow(cells: [
                                        DataCell(_tableCell(
                                            _percentageText(
                                                entry.moviePercentage),
                                            theme)),
                                        DataCell(_tableCell(
                                            _percentageText(
                                                entry.seriesPercentage),
                                            theme)),
                                        DataCell(_tableCell(
                                            _percentageText(
                                                entry.shortPercentage),
                                            theme)),
                                        DataCell(_tableCell(
                                            _percentageText(
                                                entry.musicPercentage),
                                            theme)),
                                        DataCell(_tableCell(
                                            dateFormat.format(date), theme)),
                                      ]);
                                    }).toList(),
                                  ),
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
    );
  }

  Widget _tableHeader(String text, ThemeData theme) => Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: theme.canvasColor),
      );

  Widget _tableCell(String text, ThemeData theme) =>
      Text(text, style: TextStyle(color: theme.canvasColor));

  Future<bool> _onSavePressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      final parsedMovie = double.tryParse(_movieCtrl.text.trim());
      final parsedSeries = double.tryParse(_seriesCtrl.text.trim());
      final parsedShort = double.tryParse(_shortCtrl.text.trim());
      final parsedMusic = double.tryParse(_musicCtrl.text.trim());
      if (parsedMovie == null ||
          parsedSeries == null ||
          parsedShort == null ||
          parsedMusic == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid numeric values')),
          );
        }
        return false;
      }
      await Provider.of<PromoterPercentageProvider>(context, listen: false)
          .setPromoterPercentageData(
        _selectedLevel,
        parsedMovie,
        parsedSeries,
        parsedShort,
        parsedMusic,
      );
      _setDefaultPercentageValues();
      return true;
    }
    return false;
  }

  Future<void> _openAddPercentageDialog(ThemeData theme) async {
    _setDefaultPercentageValues();
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Promoter Percentage',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width < 600 ? 360 : 460,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration:
                            const InputDecoration(labelText: 'Promoter Level'),
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
                        onChanged: (val) {
                          setState(
                              () => _selectedLevel = val ?? _selectedLevel);
                          _setDefaultPercentageValues();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _movieCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(labelText: 'Movie %'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _seriesCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Series %'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shortCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(labelText: 'Short %'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _musicCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(labelText: 'Music %'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                            onPressed: () async {
                              final ok = await _onSavePressed();
                              if (ok && mounted) {
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _setDefaultPercentageValues() {
    final defaults = _defaultPercentages[_selectedLevel] ?? const {};
    _movieCtrl.text = _formatNumber(defaults['movie']);
    _seriesCtrl.text = _formatNumber(defaults['series']);
    _shortCtrl.text = _formatNumber(defaults['short']);
    _musicCtrl.text = _formatNumber(defaults['music']);
  }

  String _percentageText(double? value) => _formatNumber(value);

  String _formatNumber(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

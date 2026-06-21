import 'package:admin_ott/app/provider/accessControleProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';

class AccessControlPage extends StatefulWidget {
  const AccessControlPage({Key? key}) : super(key: key);

  @override
  State<AccessControlPage> createState() => _AccessControlPageState();
}

class _AccessControlPageState extends State<AccessControlPage> {
  final List<String> modules = [
    'Manage Video',
    'Manage Production House',
    'Manage User',
    'Transaction',
    'Help Desk',
  ];

  final Map<String, String> moduleKeyMap = {
    'Manage Video': 'manageContent',
    'Manage Production House': 'manageMediaHouse',
    'Manage User': 'manageUser',
    'Transaction': 'manageTrasaction',
    'Help Desk': 'helpDesk',
  };

  final List<String> levels = [
    'National Level Promoter',
    'State Level Promoter',
    'District Level Promoter',
    'Taluka Level Promoter',
  ];

  String selectedLevel = 'National Level Promoter';
  final Map<String, Map<String, bool>> accessMap = {};

  @override
  void initState() {
    super.initState();
    for (var level in levels) {
      accessMap[level] = {for (var module in modules) module: false};
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<AccesscontroleProvider>(context, listen: false);
      await provider.getAllPromoterAccess();
      _syncAccessMapWithProvider(provider);
    });
  }

  void _syncAccessMapWithProvider(AccesscontroleProvider provider) {
    for (var level in levels) {
      final data = provider.latestByLevel[level];
      if (data != null) {
        accessMap[level] = {
          'Manage Video': data.manageContent ?? false,
          'Manage Production House': data.manageMediaHouse ?? false,
          'Manage User': data.manageUser ?? false,
          'Transaction': data.manageTrasaction ?? false,
          'Help Desk': data.helpDesk ?? false,
        };
      }
    }
    setState(() {}); // Refresh UI
  }

  bool _didSyncOnce = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: SizedBox(),
        title: const Text('Access Control'),
        backgroundColor: theme.primaryColor,
      ),
      body: Consumer<AccesscontroleProvider>(
        builder: (context, provider, child) {
          if (!_didSyncOnce) {
            _didSyncOnce = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncAccessMapWithProvider(provider);
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAccessForm(theme, provider),
                const SizedBox(height: 16),
                _buildPermissionTable(theme, provider),
                const SizedBox(height: 20),
                _buildSummarySection(theme, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccessForm(ThemeData theme, AccesscontroleProvider provider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration:
                    const InputDecoration(labelText: 'Select Promoter Level'),
                dropdownColor: theme.cardColor,
                items: levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child:
                        Text(level, style: TextStyle(color: theme.canvasColor)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedLevel = value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: _saveAccess,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTable(
      ThemeData theme, AccesscontroleProvider provider) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                'Module Permissions for $selectedLevel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: theme.canvasColor,
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: modules.length,
                  itemBuilder: (_, index) {
                    final module = modules[index];
                    return SwitchListTile(
                      title: Text(module,
                          style: TextStyle(color: theme.canvasColor)),
                      value: accessMap[selectedLevel]![module] ?? false,
                      activeColor: theme.primaryColor,
                      onChanged: (val) {
                        setState(() => accessMap[selectedLevel]![module] = val);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(
      ThemeData theme, AccesscontroleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Access Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.canvasColor,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          color: theme.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Table(
              border: TableBorder.all(color: theme.dividerColor),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(4),
              },
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: theme.primaryColor.withOpacity(0.1)),
                  children: [
                    _tableHeader('Level', theme),
                    _tableHeader('Allowed Modules', theme),
                  ],
                ),
                ...levels.map((level) {
                  final access = provider.latestByLevel[level];
                  final allowedModules = <String>[];

                  if (access != null) {
                    if (access.manageContent == true)
                      allowedModules.add('Manage Video');
                    if (access.manageMediaHouse == true)
                      allowedModules.add('Manage Production House');
                    if (access.manageUser == true)
                      allowedModules.add('Manage User');
                    if (access.manageTrasaction == true)
                      allowedModules.add('Transaction');
                    if (access.helpDesk == true)
                      allowedModules.add('Help Desk');
                  }

                  return TableRow(
                    children: [
                      _tableCell(level, theme),
                      _tableCell(
                          allowedModules.isEmpty
                              ? 'None'
                              : allowedModules.join(', '),
                          theme),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _tableHeader(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,
            style: TextStyle(
              color: theme.canvasColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center),
      );

  Widget _tableCell(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: theme.canvasColor)),
      );

  void _saveAccess() async {
    final provider =
        Provider.of<AccesscontroleProvider>(context, listen: false);
    final currentAccess = accessMap[selectedLevel]!;

    final data = {
      'helpDesk': currentAccess['Help Desk'] ?? false,
      'manageContent': currentAccess['Manage Video'] ?? false,
      'manageMediaHouse': currentAccess['Manage Production House'] ?? false,
      'manageTrasaction': currentAccess['Transaction'] ?? false,
      'manageUser': currentAccess['Manage User'] ?? false,
      'promoterLevel': selectedLevel,
      'id': provider.latestByLevel[selectedLevel]?.id ?? 0
    };

    try {
      if (data['id'] == 0) {
        await provider.setPromoterAccess(
          selectedLevel,
          data['helpDesk'] as bool,
          data['manageContent'] as bool,
          data['manageMediaHouse'] as bool,
          data['manageTrasaction'] as bool,
          data['manageUser'] as bool,
        );
      } else {
        await provider.editPromoterAccess(
          selectedLevel,
          data['helpDesk'] as bool,
          data['manageContent'] as bool,
          data['manageMediaHouse'] as bool,
          data['manageTrasaction'] as bool,
          data['manageUser'] as bool,
          data['id'] as int,
        );
      }

      _syncAccessMapWithProvider(provider); // Refresh access table

      // ✅ Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 🛑 Show error if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save access: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

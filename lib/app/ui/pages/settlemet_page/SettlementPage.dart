import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';
import '../../../widgets/app_loaders.dart';
import '../help support page/HelpSupportPage.dart';
import 'package:intl/intl.dart';

import 'adminSettelmentCard.dart';
import 'monthly_ios_settlement_section.dart';
import 'promoter_settlement_download_section.dart';

class SettlementPage extends StatefulWidget {
  @override
  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  final ScrollController _tableHorizontalController = ScrollController();
  SettlementDataSource? _settlementDataSource;
  int _selectedSettlementTab = 0;
  int _rowsPerPage = 10;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final provider = Provider.of<SettelementProvider>(context, listen: false);
    try {
      await provider.fetchWeeklySettelementData();
      if (!mounted) return;
      setState(() {
        _settlementDataSource =
            SettlementDataSource(provider.weeklySettelement);
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load admin settlement data.';
      });
    }
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _settlementDataSource?.sort(getField, ascending);
  }

  @override
  void dispose() {
    _tableHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      body: Consumer<SettelementProvider>(
        builder: (context, provider, child) {
          final settlements = provider.weeklySettelement;
          if (settlements.isNotEmpty) {
            _settlementDataSource = SettlementDataSource(settlements);
          }

          return RefreshIndicator(
            onRefresh: () => _selectedSettlementTab == 0
                ? _initData()
                : provider.fetchMonthlySettlements(refresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(selectedThemeData),
                const SizedBox(height: 16),
                _buildSettlementSwitch(selectedThemeData),
                const SizedBox(height: 24),
                if (_selectedSettlementTab == 0)
                  _buildWeeklySettlementContent(
                    selectedThemeData,
                    settlements,
                  )
                else
                  const MonthlyIosSettlementSection(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedThemeData.primaryColor,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => HelpSupportPage())),
        child: Icon(Icons.message_rounded),
      ),
    );
  }

  Widget _buildHeader(ThemeData selectedThemeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settlement",
          style: TextStyle(
            color: selectedThemeData.canvasColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage weekly settlements and monthly iOS settlements.",
          style: TextStyle(
            color: selectedThemeData.canvasColor.withValues(alpha: 0.62),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementSwitch(ThemeData selectedThemeData) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(
              value: 0,
              icon: Icon(Icons.calendar_view_week_outlined),
              label: Text("Weekly Settlement"),
            ),
            ButtonSegment<int>(
              value: 1,
              icon: Icon(Icons.phone_iphone_outlined),
              label: Text("Monthly iOS Settlement"),
            ),
          ],
          selected: {_selectedSettlementTab},
          onSelectionChanged: (selection) {
            setState(() => _selectedSettlementTab = selection.first);
          },
        ),
      ),
    );
  }

  Widget _buildWeeklySettlementContent(
    ThemeData selectedThemeData,
    List<WeeklySettelementData> settlements,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RepaintBoundary(
          child: PromoterSettlementDownloadSection(),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const SizedBox(
            height: 260,
            child: Center(child: AppSpinner()),
          )
        else if (_loadError != null)
          SizedBox(
            height: 260,
            child: Center(child: Text(_loadError!)),
          )
        else if (settlements.isEmpty)
          const SizedBox(
            height: 260,
            child: Center(child: Text("No settlement data available.")),
          )
        else ...[
          const RepaintBoundary(
            child: AdminSettlementCard(),
          ),
          const SizedBox(height: 16),
          Card(
            color: selectedThemeData.cardColor,
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildSettlementRecordsTable(
                selectedThemeData,
                settlements,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettlementRecordsTable(
    ThemeData selectedThemeData,
    List<WeeklySettelementData> settlements,
  ) {
    if (_settlementDataSource == null) {
      _settlementDataSource = SettlementDataSource(settlements);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.maxWidth < 1280 ? 1280.0 : constraints.maxWidth;

        return Scrollbar(
          controller: _tableHorizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _tableHorizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: DataTableTheme(
                data: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(
                    selectedThemeData.cardColor,
                  ),
                  dataRowColor: WidgetStateProperty.all(
                    selectedThemeData.cardColor,
                  ),
                ),
                child: PaginatedDataTable(
                  header: Text(
                    'Settlement Records',
                    style: TextStyle(
                      color: selectedThemeData.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  columns: _buildColumns(selectedThemeData, settlements),
                  source: _settlementDataSource!,
                  rowsPerPage: _rowsPerPage,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  showCheckboxColumn: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(ThemeData selectedThemeData,
      List<WeeklySettelementData> weeklySettelement) {
    return [
      _buildSortableColumn(
        'Settelment ID',
        (d) => d['transactionId'] ?? 'N/A',
        0,
        selectedThemeData,
      ),
      _buildSortableColumn(
        'Start Date',
        (d) => d['startDate'] ?? 'N/A',
        1,
        selectedThemeData,
      ),
      _buildSortableColumn(
        'End Date',
        (d) => d['endDate'] ?? 'N/A',
        2,
        selectedThemeData,
      ),
      _buildSortableColumn(
          'Gross Revenue', (d) => d['GrossRevenue'] ?? 0, 3, selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'Net Revenue', (d) => d['NetRevenue'] ?? 0, 5, selectedThemeData,
          numeric: true),
      _buildSortableColumn('Platform Share',
          (d) => d['OTTPlatformRevenueShare'] ?? 0, 6, selectedThemeData,
          numeric: true),
      _buildSortableColumn('Production House Share',
          (d) => d['MediaHouseRevenueShare'] ?? 0, 7, selectedThemeData,
          numeric: true),
      _buildSortableColumn('Total Purchases', (d) => d['TotalPurchases'] ?? 0,
          8, selectedThemeData,
          numeric: true),
    ];
  }

  DataColumn _buildSortableColumn(
      String title,
      Comparable Function(Map<String, dynamic>) getField,
      int index,
      ThemeData selectedThemeData,
      {bool numeric = false}) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selectedThemeData.primaryColor,
        ),
      ),
      numeric: numeric,
      onSort: (columnIndex, ascending) =>
          _sort(getField, columnIndex, ascending),
    );
  }
}

class SettlementDataSource extends DataTableSource {
  List<WeeklySettelementData> _sortedSettlements;

  SettlementDataSource(List<WeeklySettelementData> settlements)
      : _sortedSettlements = List.from(settlements);

  void sort<T>(
      Comparable<T> Function(Map<String, dynamic>) getField, bool ascending) {
    // Sorting logic (if applicable)
    notifyListeners();
  }

  @override
  @override
  DataRow? getRow(int index) {
    if (index >= _sortedSettlements.length) {
      // Return an empty DataRow or handle it gracefully
      return DataRow(cells: [
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
        DataCell(Text('N/A')),
      ]);
    }

    final settlement = _sortedSettlements[index];

    return DataRow(cells: [
      DataCell(Text(settlement.transactionId ?? 'N/A')),
      DataCell(Text(DateFormat('dd-MM-yyyy').format(
          DateTime.fromMillisecondsSinceEpoch(settlement.startDate ?? 0)))),
      DataCell(Text(DateFormat('dd-MM-yyyy').format(
          DateTime.fromMillisecondsSinceEpoch(settlement.endDate ?? 0)))),
      DataCell(Text('\$${settlement.grossRevenue ?? 'N/A'}')),
      DataCell(Text('\$${settlement.netRevenue ?? 'N/A'}')),
      DataCell(Text('\$${settlement.ottPlatformRevenueShare ?? 'N/A'}')),
      DataCell(Text('\$${settlement.mediaHouseRevenueShare ?? 'N/A'}')),
      DataCell(Text('${settlement.totalPurchases ?? 'N/A'}')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _sortedSettlements.length;
  @override
  int get selectedRowCount => 0;
}

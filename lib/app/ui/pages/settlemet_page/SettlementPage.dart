import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../../../../data/repositories/settlement_list.dart';
import '../../../../domain/entities/user.dart';
import '../../../core/utils/sharepreferences.dart';
import '../../../provider/settelementProvider.dart';
import '../../../provider/themeProvider.dart';
import '../help support page/HelpSupportPage.dart';
import '../media house detail page/component/settlementCards.dart';
import 'package:intl/intl.dart';

import 'adminSettelmentCard.dart';

class SettlementPage extends StatefulWidget {
  @override
  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  SettlementDataSource? _settlementDataSource;
  int _rowsPerPage = 10;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final localSharePreferences = LocalSharePreferences();
    User? user = await localSharePreferences.getUser();

    if (user == null || user.id == null) {
      debugPrint("User or User ID is null. Cannot fetch settlement data.");
      return;
    }

    await Provider.of<SettelementProvider>(context, listen: false)
        .fetchWeeklySettelementDataByMediaHouseId(user.id!);

    final settlements = Provider.of<SettelementProvider>(context, listen: false)
        .weeklySettelement;

    if (settlements != null) {
      _settlementDataSource = SettlementDataSource(settlements);
    } else {
      debugPrint("No settlements found.");
    }
  }

  void _sort<T>(
      Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _settlementDataSource?.sort(getField, ascending);
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      body: Consumer<SettelementProvider>(
        builder: (context, provider, child) {
          final settlements = provider.weeklySettelement;
          if (settlements == null || settlements.isEmpty) {
            return Center(child: Text("No settlement data available."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AdminSettlementCard(),
                SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
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
                ),
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

  List<DataColumn> _buildColumns(
      ThemeData selectedThemeData, List<WeeklySettelementData> weeklySettelement) {
    return [
      _buildSortableColumn(
        'Transaction ID',
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
          'Tax Deduction', (d) => d['TaxDeduction'] ?? 0, 4, selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'Net Revenue', (d) => d['NetRevenue'] ?? 0, 5, selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'OTT Share', (d) => d['OTTPlatformRevenueShare'] ?? 0, 6,
          selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'Media House Share', (d) => d['MediaHouseRevenueShare'] ?? 0, 7,
          selectedThemeData,
          numeric: true),
      _buildSortableColumn(
          'Total Purchases', (d) => d['TotalPurchases'] ?? 0, 8,
          selectedThemeData,
          numeric: true),
      _buildSortableColumn(
        'Most Purchased Movie',
            (d) => d['MostPurchasedMovie'] ?? 'N/A',
        9,
        selectedThemeData,
      ),
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
  List<WeeklySettelementData> _settlements;
  List<WeeklySettelementData> _sortedSettlements;

  SettlementDataSource(this._settlements)
      : _sortedSettlements = List.from(_settlements ?? []);

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
      DataCell(Text('\$${settlement.taxDeduction ?? 'N/A'}')),
      DataCell(Text('\$${settlement.netRevenue ?? 'N/A'}')),
      DataCell(Text('\$${settlement.ottPlatformRevenueShare ?? 'N/A'}')),
      DataCell(Text('\$${settlement.mediaHouseSharePercentage ?? 'N/A'}')),
      DataCell(Text('${settlement.totalPurchases ?? 'N/A'}')),
      DataCell(Text(settlement.mostPurchasedMovie ?? 'N/A')),
    ]);
  }


  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _sortedSettlements.length;
  @override
  int get selectedRowCount => 0;
}

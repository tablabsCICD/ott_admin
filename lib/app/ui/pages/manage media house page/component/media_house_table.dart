import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'edit_media_house_dialog.dart';
import 'media_house_detail_page.dart';

class MediaHouseTable extends StatefulWidget {
  final List<MediaHouse>? mediaHouseData;
  const MediaHouseTable({super.key, required this.mediaHouseData});

  @override
  State<MediaHouseTable> createState() => _MediaHouseTableState();
}

class _MediaHouseTableState extends State<MediaHouseTable> {
  bool _ascending = true;
  int _sortColumnIndex = 1; // Default sort by Production House name

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _ascending = ascending;
    });
  }

  List<MediaHouse> _getSortedData(List<MediaHouse> rawList) {
    final list = List<MediaHouse>.from(rawList);
    list.sort((a, b) {
      int result = 0;
      switch (_sortColumnIndex) {
        case 1: // Name
          final nameA = a.mediaHouseName ?? '';
          final nameB = b.mediaHouseName ?? '';
          result = nameA.toLowerCase().compareTo(nameB.toLowerCase());
          break;
        case 2: // Status
          final statusA = a.status ?? (a.active == true ? 'ACTIVE' : 'PENDING');
          final statusB = b.status ?? (b.active == true ? 'ACTIVE' : 'PENDING');
          result = statusA.toUpperCase().compareTo(statusB.toUpperCase());
          break;
        case 3: // Revenue
          final revA = _parseNumber(a.displayTotalRevenue);
          final revB = _parseNumber(b.displayTotalRevenue);
          result = revA.compareTo(revB);
          break;
        case 4: // Total Views
          final viewsA = _parseNumber(a.totalViews);
          final viewsB = _parseNumber(b.totalViews);
          result = viewsA.compareTo(viewsB);
          break;
        case 5: // Contents
          final countA = _parseNumber(a.postCount);
          final countB = _parseNumber(b.postCount);
          result = countA.compareTo(countB);
          break;
        default:
          result = 0;
      }
      return _ascending ? result : -result;
    });
    return list;
  }

  double _parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 0.0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _formatCurrency(String? value) {
    if (value == null || value.trim().isEmpty) return '₹ 0';
    final numVal = _parseNumber(value);
    final formatter = NumberFormat.currency(
      symbol: '₹ ',
      decimalDigits: numVal % 1 == 0 ? 0 : 2,
    );
    return formatter.format(numVal);
  }

  String _formatViews(String? value) {
    if (value == null || value.trim().isEmpty) return '0';
    final numVal = _parseNumber(value);
    if (numVal >= 1000000) {
      return '${(numVal / 1000000).toStringAsFixed(1)}M';
    } else if (numVal >= 1000) {
      return '${(numVal / 1000).toStringAsFixed(1)}K';
    }
    return numVal.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final rawData = widget.mediaHouseData ?? [];

    if (rawData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.canvasColor.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_outlined,
                size: 40,
                color: theme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Production Houses Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "No production house records match your current search query or filter.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.canvasColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final sortedData = _getSortedData(rawData);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: theme.canvasColor.withValues(alpha: 0.02),
                border: Border(
                  bottom: BorderSide(
                    color: theme.canvasColor.withValues(alpha: 0.07),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.table_chart_outlined,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Production Houses Directory',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.canvasColor,
                          ),
                        ),
                        Text(
                          'Detailed list of all registered media production entities',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.canvasColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${sortedData.length} Total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Data Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 700),
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _ascending,
                  headingRowHeight: 46,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 68,
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(
                    theme.canvasColor.withValues(alpha: 0.03),
                  ),
                  columns: [
                    DataColumn(
                      columnWidth: const FixedColumnWidth(60),
                      label: Text(
                        'Logo',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Production House',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                      onSort: (index, asc) => _onSort(index, asc),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                      onSort: (index, asc) => _onSort(index, asc),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Revenue',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                      onSort: (index, asc) => _onSort(index, asc),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Total Views',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                      onSort: (index, asc) => _onSort(index, asc),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Contents',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                      onSort: (index, asc) => _onSort(index, asc),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: theme.canvasColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                  rows: sortedData.map((data) {
                    final status = data.status ?? (data.active == true ? 'ACTIVE' : 'PENDING');
                    final isApproved = status.toUpperCase() == 'APPROVED' || status.toUpperCase() == 'ACTIVE';
                    final isPending = status.toUpperCase() == 'PENDING';

                    final statusColor = isApproved
                        ? Colors.green
                        : isPending
                            ? Colors.orange
                            : Colors.red;

                    final logoStr = data.logo?.toString().trim() ?? '';
                    final bool hasValidLogo = logoStr.isNotEmpty &&
                        (logoStr.startsWith('http://') || logoStr.startsWith('https://'));

                    return DataRow(
                      onSelectChanged: (_) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MediaHouseDetailPage(mediaHouse: data),
                          ),
                        );
                        if (context.mounted) {
                          await Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouse();
                          setState(() {});
                        }
                      },
                      cells: [
                        // Logo
                        DataCell(
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
                            backgroundImage: hasValidLogo ? NetworkImage(logoStr) : null,
                            child: !hasValidLogo
                                ? Text(
                                    (data.mediaHouseName != null && data.mediaHouseName!.trim().isNotEmpty)
                                        ? data.mediaHouseName!.trim()[0].toUpperCase()
                                        : 'M',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: theme.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Name & Contact
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.mediaHouseName ?? 'Unnamed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: theme.canvasColor,
                                ),
                              ),
                              if ((data.contactNumber != null && data.contactNumber!.isNotEmpty) ||
                                  (data.email != null && data.email!.isNotEmpty))
                                Text(
                                  data.contactNumber ?? data.email ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.canvasColor.withValues(alpha: 0.55),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Status Badge
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Revenue
                        DataCell(
                          Text(
                            _formatCurrency(data.displayTotalRevenue),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),

                        // Total Views
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: theme.canvasColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatViews(data.totalViews),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.canvasColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Contents
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.canvasColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.movie_outlined,
                                  size: 13,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data.postCount ?? '0',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: theme.canvasColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action Buttons
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MediaHouseDetailPage(mediaHouse: data),
                                    ),
                                  );
                                  if (context.mounted) {
                                    await Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouse();
                                    setState(() {});
                                  }
                                },
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    size: 13),
                                label: const Text('View',
                                    style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      theme.primaryColor.withValues(alpha: 0.12),
                                  foregroundColor: theme.primaryColor,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final res =
                                      await EditMediaHouseDialog.show(context, data);
                                  if (res == true && context.mounted) {
                                    await Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouse();
                                    setState(() {});
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined, size: 13),
                                label: const Text('Edit',
                                    style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.canvasColor,
                                  side: BorderSide(
                                    color: theme.canvasColor
                                        .withValues(alpha: 0.2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

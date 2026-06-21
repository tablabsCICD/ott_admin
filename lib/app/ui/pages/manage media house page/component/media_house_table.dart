import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaHouseTable extends StatefulWidget {
  List<MediaHouse>? mediaHouseData;
  MediaHouseTable({super.key, required this.mediaHouseData});

  @override
  State<MediaHouseTable> createState() => _MediaHouseTableState();
}

class _MediaHouseTableState extends State<MediaHouseTable> {
  // Sample data extracted from the provided JSON response

  // State variables for sorting
  bool ascending = true;
  int sortColumnIndex = 0;

  /*void onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      this.ascending = ascending;

      widget.mediaHouseData!.sort((a, b) {
        final valueA = a.mediaHouseName?.elementAt(columnIndex);
        final valueB = b.postCount.elementAt(columnIndex);

        if (ascending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      body: widget.mediaHouseData == null
          ? Center(
              child: Text(
              "The Production house list is empty because no Production houses have been added yet.",
              style: TextStyle(color: selectedThemeData.primaryColor),
            ))
          : SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: ascending,
                  columns: [
                    DataColumn(
                      columnWidth: FixedColumnWidth(90),
                      label: Text(
                        'Logo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedThemeData.primaryColor,
                        ),
                      ),
                      numeric: true,
                      //  onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text(
                        'Production House',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedThemeData.primaryColor,
                        ),
                      ),
                      // onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text(
                        'Revenue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedThemeData.primaryColor,
                        ),
                      ),
                      numeric: true,
                      //  onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Views',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedThemeData.primaryColor,
                        ),
                      ),
                      numeric: true,
                      // onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Text(
                        'Contents',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedThemeData.primaryColor),
                      ),
                      numeric: true,
                      //   onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
                    ),
                  ],
                  rows: widget.mediaHouseData!.map((data) {
                    return DataRow(cells: [
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(data.logo ?? ''),
                          ),
                        ),
                      ),
                      DataCell(Text(
                        data.mediaHouseName!,
                        style: TextStyle(fontSize: 16),
                      )),
                      DataCell(Text(
                        data.displayTotalRevenue ?? '0',
                        style: TextStyle(fontSize: 16),
                      )),
                      DataCell(Text(
                        data.totalViews!,
                        style: TextStyle(fontSize: 16),
                      )),
                      DataCell(Text(
                        data.postCount!,
                        style: TextStyle(fontSize: 16),
                      )),
                    ]);
                  }).toList(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
    );
  }
}

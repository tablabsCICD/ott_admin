import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PieChartClass extends StatefulWidget {
  List<Map<String, dynamic>> chartDataList;
  String title;
  PieChartClass({super.key, required this.chartDataList, required this.title});

  @override
  _PieChartClassState createState() => _PieChartClassState();
}

class _PieChartClassState extends State<PieChartClass> {
  int? hoveredIndex;
  int? tappedIndex;

  late List<Map<String, dynamic>> chartData;

  @override
  void initState() {
    super.initState();
    chartData = widget.chartDataList;
  }

  double get totalValue =>
      chartData.fold(0, (sum, item) => sum + item["value"]);

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.cardColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedThemeData.primaryColor,
                    ),
                  ),
                ],
              ),
              Spacer(),
              _buildPieChart(selectedThemeData.canvasColor),
              //_buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Pie Chart with hover & tap logic
  Widget _buildPieChart(Color textColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 300,
          width: 350,
          child: PieChart(
            PieChartData(
              sections: _generateSections(),
              sectionsSpace: 1,
              centerSpaceRadius: 70,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions) return;

                  final touchedIndex =
                      pieTouchResponse?.touchedSection?.touchedSectionIndex;
                  final isValid = touchedIndex != null &&
                      touchedIndex >= 0 &&
                      touchedIndex < chartData.length;

                  final newHovered =
                      isValid && event is! FlTapUpEvent ? touchedIndex : null;
                  final newTapped =
                      isValid && event is FlTapUpEvent ? touchedIndex : null;

                  if (hoveredIndex != newHovered ||
                      (newTapped != null && tappedIndex != newTapped)) {
                    setState(() {
                      hoveredIndex = newHovered;
                      if (newTapped != null) tappedIndex = newTapped;
                    });
                  }
                },
              ),
            ),
          ),
        ),

        // Center text displaying hovered/tapped section
        Positioned(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: Text(
              _getCenterText(),
              key: ValueKey(hoveredIndex ?? tappedIndex),
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Generates Pie Chart Sections
  List<PieChartSectionData> _generateSections() {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];
      final isHighlighted = (hoveredIndex == index || tappedIndex == index);
      return PieChartSectionData(
        value: data["value"].toDouble(),
        color: data["color"],
        radius: isHighlighted ? 85 : 75,
        title: "",
        badgeWidget:
            isHighlighted ? _buildLabel(data["title"], data["value"]) : null,
        badgePositionPercentageOffset: 1.2,
      );
    });
  }

  /// Determines center text based on hover/tap
  String _getCenterText() {
    if (hoveredIndex != null) {
      double percentage =
          (chartData[hoveredIndex!]["value"] / totalValue) * 100;
      return "${percentage.toStringAsFixed(1)}%"; // Show percentage with 1 decimal place
    } else if (tappedIndex != null) {
      return chartData[tappedIndex!]["title"];
    }
    return "";
  }

  /// Builds the custom legend
  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: chartData.map((data) {
        return _buildLegendItem(data["title"], data["color"]);
      }).toList(),
    );
  }

  /// Custom Legend Item
  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        SizedBox(width: 6),
        Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  /// Tooltip for hover/tap
  Widget _buildLabel(String title, int value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
          Text(value.toString(),
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

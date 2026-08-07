import 'package:admin_ott/app/provider/analyticsProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/themeProvider.dart';

class TopMoviesGraphForAdmin extends StatefulWidget {
  const TopMoviesGraphForAdmin({super.key});

  @override
  State<TopMoviesGraphForAdmin> createState() => _TopMoviesGraphForAdminState();
}

class _TopMoviesGraphForAdminState extends State<TopMoviesGraphForAdmin> {
  static const _contentTypes = [
    'ALL',
    'MOVIE',
    'SHORT_FILM',
    'SERIES',
    'MINI_SERIES',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    await Provider.of<AnalyticsProvider>(context, listen: false)
        .fetchTopPerformingMovieGraph(0);
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 720;
                final title = Text(
                  'Top Performing Content',
                  style: TextStyle(
                    color: selectedThemeData.primaryColor,
                    fontSize: ResponsiveWidget.isMobile(context) ? 15 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
                final controls = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: narrow ? WrapAlignment.start : WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildDateSelection(selectedThemeData, provider),
                    _buildContentTypeDropdown(selectedThemeData, provider),
                    _buildMoreButton(selectedThemeData, provider),
                    _buildIconButton(
                      selectedThemeData,
                      Icons.search,
                      'Search',
                      () => provider
                          .fetchTopPerformingMovieGraph(_rangeIndex(provider)),
                      filled: true,
                    ),
                    _buildIconButton(
                      selectedThemeData,
                      Icons.refresh,
                      'Refresh',
                      () => provider
                          .fetchTopPerformingMovieGraph(_rangeIndex(provider)),
                    ),
                  ],
                );
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 10),
                      controls,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: title),
                    controls,
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            _buildChart(selectedThemeData, provider),
            _buildFilterOptions(selectedThemeData, provider),
          ],
        );
      },
    );
  }

  Widget _buildDateSelection(ThemeData theme, AnalyticsProvider provider) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        provider.selectedDateRange == null
            ? "Select Date Range"
            : "${DateFormat.yMMMd().format(provider.selectedDateRange!.start)} - ${DateFormat.yMMMd().format(provider.selectedDateRange!.end)}",
        style: TextStyle(
          color: theme.canvasColor,
          fontSize: ResponsiveWidget.isMobile(context) ? 12 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme, AnalyticsProvider provider) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: provider.isTopContentLoading
            ? Center(
                key: const ValueKey('top-content-loader'),
                child: CircularProgressIndicator(color: theme.primaryColor),
              )
            : provider.graphData.isEmpty
                ? _emptyGraph(theme, provider)
                : RepaintBoundary(
                    key: const ValueKey('top-content-chart'),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<Map<String, dynamic>, String>>[
                        LineSeries<Map<String, dynamic>, String>(
                          dataSource: provider.graphData,
                          xValueMapper: (movie, _) => movie['label'],
                          yValueMapper: (movie, _) => movie['value'],
                          animationDuration: 0,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          color: theme.primaryColor,
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _emptyGraph(ThemeData theme, AnalyticsProvider provider) {
    return Center(
      key: const ValueKey('top-content-empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights_outlined, color: theme.primaryColor, size: 36),
          const SizedBox(height: 8),
          Text(
            provider.topContentLoadError ?? 'No graph data found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(ThemeData theme, AnalyticsProvider provider) {
    final filterOptions = [
      {'label': 'Week', 'days': 7},
      {'label': 'Month', 'days': 30},
      {'label': 'Year', 'days': 365},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...filterOptions.map((range) => _buildFilterButton(
            theme, range['label'] as String, range['days'] as int, provider)),
        _buildFilterButton(theme, 'Custom Dates', 0, provider, isCustom: true),
      ],
    );
  }

  Widget _buildFilterButton(
      ThemeData theme, String label, int days, AnalyticsProvider provider,
      {bool isCustom = false}) {
    final bool isActive = provider.activeButton == label;
    return GestureDetector(
      onTap: isCustom
          ? () =>
              provider.pickDateRange(context, true) // Pass `context` explicitly
          : () => provider.setDateRange(label, days, context, true),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryColor
              : theme.canvasColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? theme.primaryColor
                : theme.canvasColor.withValues(alpha: 0.7),
            width: 0.4,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : theme.canvasColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContentTypeDropdown(
    ThemeData theme,
    AnalyticsProvider provider,
  ) {
    return SizedBox(
      width: ResponsiveWidget.isMobile(context) ? 180 : 250,
      height: 38,
      child: DropdownButtonFormField<String>(
        initialValue: _contentTypes.contains(provider.topContentType)
            ? provider.topContentType
            : 'ALL',
        dropdownColor: theme.cardColor,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: theme.canvasColor.withValues(alpha: 0.08),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: theme.canvasColor.withValues(alpha: 0.28)),
          ),
        ),
        iconEnabledColor: theme.canvasColor,
        style: TextStyle(
          color: theme.canvasColor,
          fontWeight: FontWeight.w700,
        ),
        items: _contentTypes
            .map(
              (type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          provider.setTopContentType(value);
        },
      ),
    );
  }

  Widget _buildMoreButton(ThemeData theme, AnalyticsProvider provider) {
    return OutlinedButton.icon(
      onPressed: () => _showLocationFilterDialog(theme, provider),
      icon: const Icon(Icons.tune, size: 16),
      label: const Text('More'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(96, 38),
        foregroundColor: theme.primaryColor,
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: .36),
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.38)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        overlayColor:
            WidgetStatePropertyAll(theme.primaryColor.withValues(alpha: .08)),
      ),
    );
  }

  Widget _buildIconButton(
    ThemeData theme,
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? theme.primaryColor
                : theme.canvasColor.withValues(alpha: 0.06),
            border: Border.all(
              color: filled
                  ? theme.primaryColor
                  : theme.canvasColor.withValues(alpha: 0.34),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: filled ? Colors.white : theme.canvasColor,
          ),
        ),
      ),
    );
  }

  Future<void> _showLocationFilterDialog(
    ThemeData theme,
    AnalyticsProvider provider,
  ) async {
    final country = TextEditingController(text: provider.topContentCountry);
    final state = TextEditingController(text: provider.topContentState);
    final district = TextEditingController(text: provider.topContentDistrict);
    final taluka = TextEditingController(text: provider.topContentTaluka);
    final city = TextEditingController(text: provider.topContentCity);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme =
            Provider.of<ThemeProvider>(dialogContext, listen: true).getTheme;
        return Dialog(
          backgroundColor: dialogTheme.cardColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Location Wise Filters',
                          style: TextStyle(
                            color: dialogTheme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        icon: Icon(Icons.close, color: dialogTheme.canvasColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _locationField(dialogTheme, 'Country', country,
                      hint: 'Select Country', searchable: true),
                  const SizedBox(height: 8),
                  _locationField(dialogTheme, 'State', state,
                      hint: 'Select State', searchable: true),
                  const SizedBox(height: 8),
                  _locationField(dialogTheme, 'District', district),
                  const SizedBox(height: 8),
                  _locationField(dialogTheme, 'Taluka', taluka),
                  const SizedBox(height: 8),
                  _locationField(dialogTheme, 'City', city),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            country.clear();
                            state.clear();
                            district.clear();
                            taluka.clear();
                            city.clear();
                            provider.clearTopContentLocationFilters();
                            Navigator.pop(dialogContext, false);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            foregroundColor: dialogTheme.primaryColor,
                            side: BorderSide(
                              color: dialogTheme.canvasColor
                                  .withValues(alpha: 0.42),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            backgroundColor: dialogTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (saved == true) {
      provider.setTopContentLocationFilters(
        country: country.text,
        state: state.text,
        district: district.text,
        taluka: taluka.text,
        city: city.text,
      );
    }
    country.dispose();
    state.dispose();
    district.dispose();
    taluka.dispose();
    city.dispose();
  }

  Widget _locationField(
    ThemeData theme,
    String label,
    TextEditingController controller, {
    String? hint,
    bool searchable = false,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: theme.canvasColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? label,
        suffixIcon:
            searchable ? Icon(Icons.search, color: theme.canvasColor) : null,
        isDense: true,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.28),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide:
              BorderSide(color: theme.canvasColor.withValues(alpha: .3)),
        ),
      ),
    );
  }

  int _rangeIndex(AnalyticsProvider provider) {
    if (provider.activeButton == 'Month') return 1;
    if (provider.activeButton == 'Year') return 2;
    return 0;
  }
}

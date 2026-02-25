import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/add_short_master.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/short_master_page.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
    context.read<ShortsProvider>().fetchShorts();
  }

  DateTime? _parseDate(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is int) {
      return rawDate > 9999999999
          ? DateTime.fromMillisecondsSinceEpoch(rawDate)
          : DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
    }
    return DateTime.tryParse(rawDate.toString());
  }

  bool _inDateRange(DateTime? date) {
    if (date == null) return true;
    if (_fromDate != null && date.isBefore(_fromDate!)) return false;
    if (_toDate != null) {
      final end =
          DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
      if (date.isAfter(end)) return false;
    }
    return true;
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
    }
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _sortBy = 'newest';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 4
        : ResponsiveWidget.isTablet(context)
            ? 4
            : 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ShortsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.shorts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          }

          final filteredShorts = provider.shorts.where((short) {
            final title = (short.title ?? '').toLowerCase();
            final date = _parseDate(
                short.createdAt ?? short.createdDate ?? short.uploadDateTime);
            final matchesSearch = _query.isEmpty || title.contains(_query);
            return matchesSearch && _inDateRange(date);
          }).toList();

          filteredShorts.sort((a, b) {
            DateTime dateA =
                _parseDate(a.createdAt ?? a.createdDate ?? a.uploadDateTime) ??
                    DateTime(1970);
            DateTime dateB =
                _parseDate(b.createdAt ?? b.createdDate ?? b.uploadDateTime) ??
                    DateTime(1970);
            switch (_sortBy) {
              case 'views_high':
                return (b.viewCount ?? 0).compareTo(a.viewCount ?? 0);
              case 'likes_high':
                return (b.likeCount ?? 0).compareTo(a.likeCount ?? 0);
              case 'parts_high':
                return (b.totalParts ?? 0).compareTo(a.totalParts ?? 0);
              case 'coins_high':
                return (b.coinsPerPart ?? 0).compareTo(a.coinsPerPart ?? 0);
              case 'title_az':
                return (a.title ?? '').compareTo(b.title ?? '');
              case 'title_za':
                return (b.title ?? '').compareTo(a.title ?? '');
              case 'trending_first':
                return (b.isTrending == true ? 1 : 0)
                    .compareTo(a.isTrending == true ? 1 : 0);
              case 'oldest':
                return dateA.compareTo(dateB);
              case 'newest':
              default:
                return dateB.compareTo(dateA);
            }
          });

          final totalItems = filteredShorts.length + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 900;
                    final searchField = SizedBox(
                      width: compact ? double.infinity : 420,
                      child: CustomTextField(
                        controller: _searchCtrl,
                        hintText: "Search shorts...",
                        textInputType: TextInputType.text,
                        prefixIcon: const Icon(Icons.search),
                        onValueChange: (_) => setState(() {}),
                      ),
                    );

                    final filterBar = Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickFromDate,
                          icon: const Icon(Icons.date_range, size: 18),
                          label: Text(
                            _fromDate == null
                                ? "From"
                                : "${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}",
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickToDate,
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(
                            _toDate == null
                                ? "To"
                                : "${_toDate!.day}/${_toDate!.month}/${_toDate!.year}",
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              onChanged: (value) {
                                if (value != null)
                                  setState(() => _sortBy = value);
                              },
                              items: const [
                                DropdownMenuItem(
                                    value: 'newest', child: Text("Newest")),
                                DropdownMenuItem(
                                    value: 'oldest', child: Text("Oldest")),
                                DropdownMenuItem(
                                    value: 'views_high',
                                    child: Text("Views High")),
                                DropdownMenuItem(
                                    value: 'likes_high',
                                    child: Text("Likes High")),
                                DropdownMenuItem(
                                    value: 'parts_high',
                                    child: Text("Parts High")),
                                DropdownMenuItem(
                                    value: 'coins_high',
                                    child: Text("Coins High")),
                                DropdownMenuItem(
                                    value: 'trending_first',
                                    child: Text("Trending First")),
                                DropdownMenuItem(
                                    value: 'title_az',
                                    child: Text("Title A-Z")),
                                DropdownMenuItem(
                                    value: 'title_za',
                                    child: Text("Title Z-A")),
                              ],
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text("Reset"),
                        ),
                      ],
                    );

                    if (compact) {
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerRight,
                              child: filterBar),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: filterBar,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    itemCount: totalItems,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 9 / 16,
                    ),
                    itemBuilder: (_, index) {
                      if (index == 0) return _buildAddShortTile(theme);
                      final short = filteredShorts[index - 1];
                      return _buildShortTile(short, theme);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () => AddShortMaster.show(context),
        child: const Icon(Icons.play_circle_fill_sharp, color: Colors.white),
      ),
    );
  }

  Widget _buildAddShortTile(ThemeData theme) {
    return GestureDetector(
      onTap: () => AddShortMaster.show(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.4),
            width: 1.3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline,
                  color: theme.primaryColor, size: 46),
              const SizedBox(height: 10),
              Text(
                "Add New Short",
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortTile(dynamic short, ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        final deleted = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ShortMasterPage(shortId: short.id ?? 0),
          ),
        );
        if (deleted == true && mounted) {
          context.read<ShortsProvider>().fetchShorts();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              short.posterUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.cardColor,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (short.isTrending == true)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "TRENDING",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    short.title ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${short.totalParts ?? 0} Parts",
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

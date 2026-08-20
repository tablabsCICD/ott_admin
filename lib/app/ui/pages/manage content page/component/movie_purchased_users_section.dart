import 'dart:convert';
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieUserItem {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? emailId;
  final String? mobileNumber;
  final String? gender;
  final String? age;
  final List<String>? role;
  final String? profilePhoto;
  final String? registrationDate;
  final bool? active;
  final Location? location;
  final MoviePurchaseDetail? purchaseDetails;

  MovieUserItem({
    this.id,
    this.firstName,
    this.lastName,
    this.emailId,
    this.mobileNumber,
    this.gender,
    this.age,
    this.role,
    this.profilePhoto,
    this.registrationDate,
    this.active,
    this.location,
    this.purchaseDetails,
  });

  String get fullName {
    final parts = [firstName ?? '', lastName ?? '']
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Anonymous User';
    return parts.join(' ');
  }

  factory MovieUserItem.fromJson(Map<String, dynamic> json) {
    return MovieUserItem(
      id: json['id'] ?? json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      emailId: json['emailId'] ?? json['email'],
      mobileNumber: json['mobileNumber'] ?? json['mobile'],
      gender: json['gender'],
      age: json['age']?.toString(),
      role: json['role'] != null
          ? (json['role'] is List
              ? List<String>.from(json['role'])
              : [json['role'].toString()])
          : null,
      profilePhoto: json['profilePhoto'],
      registrationDate: json['registrationDate'] ?? json['joinDate'],
      active: json['active'] ?? true,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      purchaseDetails: json['purchaseDetails'] != null
          ? MoviePurchaseDetail.fromJson(
              json['purchaseDetails'] as Map<String, dynamic>)
          : (json['amount'] != null || json['purchaseDate'] != null
              ? MoviePurchaseDetail.fromJson(json)
              : null),
    );
  }
}

class MoviePurchaseDetail {
  final int? purchaseId;
  final dynamic purchaseDate;
  final double? amount;
  final String? paymentStatus;
  final String? transactionId;

  MoviePurchaseDetail({
    this.purchaseId,
    this.purchaseDate,
    this.amount,
    this.paymentStatus,
    this.transactionId,
  });

  factory MoviePurchaseDetail.fromJson(Map<String, dynamic> json) {
    return MoviePurchaseDetail(
      purchaseId: json['purchaseId'] ?? json['id'],
      purchaseDate: json['purchaseDate'] ?? json['date'],
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse('${json['amount']}'),
      paymentStatus: json['paymentStatus'] ?? json['status'] ?? 'SUCCESS',
      transactionId: json['transactionId'] ?? json['txnId'],
    );
  }
}

class MoviePurchasedUsersSection extends StatefulWidget {
  final int contentId;
  final String? contentTitle;

  const MoviePurchasedUsersSection({
    super.key,
    required this.contentId,
    this.contentTitle,
  });

  @override
  State<MoviePurchasedUsersSection> createState() =>
      _MoviePurchasedUsersSectionState();
}

class _MoviePurchasedUsersSectionState
    extends State<MoviePurchasedUsersSection> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<MovieUserItem> _users = [];
  int _totalUsers = 0;
  int _totalPages = 0;
  int _currentPage = 0;
  final int _pageSize = 10;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = page;
    });

    final startStr = _startDate != null
        ? "${_startDate!.year.toString().padLeft(4, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}"
        : null;
    final endStr = _endDate != null
        ? "${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}"
        : null;

    final url = ApiConstant.getUsersByContentId(
      contentId: widget.contentId,
      keyword: _searchController.text.trim().isNotEmpty
          ? _searchController.text.trim()
          : null,
      startDate: startStr,
      endDate: endStr,
      state: _stateController.text.trim().isNotEmpty
          ? _stateController.text.trim()
          : null,
      district: _districtController.text.trim().isNotEmpty
          ? _districtController.text.trim()
          : null,
      taluka: _talukaController.text.trim().isNotEmpty
          ? _talukaController.text.trim()
          : null,
      page: page,
      size: _pageSize,
    );

    try {
      final apiHelper = ApiHelper();
      final response = await apiHelper.getApi(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final data = body['data'];

        List<MovieUserItem> loadedUsers = [];
        int total = 0;
        int pages = 0;

        if (data != null) {
          if (data is Map<String, dynamic>) {
            total = data['totalUsers'] ?? 0;
            pages = data['totalPages'] ?? 0;
            final userListJson = data['users'] ?? data['userList'] ?? [];
            if (userListJson is List) {
              loadedUsers = userListJson
                  .map((u) => MovieUserItem.fromJson(u as Map<String, dynamic>))
                  .toList();
            }
          } else if (data is List) {
            loadedUsers = data
                .map((u) => MovieUserItem.fromJson(u as Map<String, dynamic>))
                .toList();
            total = loadedUsers.length;
            pages = (total / _pageSize).ceil();
          }
        }

        setState(() {
          _isLoading = false;
          _users = loadedUsers;
          _totalUsers = total;
          _totalPages = pages;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Users API not available yet (Status: ${response.statusCode}). Backend endpoint is being configured.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Could not fetch movie buyers: $e. Endpoint will be active once deployed on backend.";
      });
    }
  }

  void _clearFilters() {
    _searchController.clear();
    _stateController.clear();
    _districtController.clear();
    _talukaController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _fetchUsers(page: 0);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        final theme = context.read<ThemeProvider>().getTheme;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              surface: theme.cardColor,
              onSurface: theme.canvasColor,
            ),
            dialogBackgroundColor: theme.cardColor,
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchUsers(page: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final isDesktop = ResponsiveWidget.isDesktop(context);
    final hasFilters = _searchController.text.isNotEmpty ||
        _stateController.text.isNotEmpty ||
        _districtController.text.isNotEmpty ||
        _talukaController.text.isNotEmpty ||
        _startDate != null ||
        _endDate != null;

    final isDateActive = _startDate != null || _endDate != null;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people_alt_rounded,
                    color: theme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Movie Buyers & Viewers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.canvasColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$_totalUsers Users",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "List of all users who purchased or watched this content with location and date filters",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "Refresh Users",
                  onPressed: () => _fetchUsers(page: _currentPage),
                  icon: Icon(Icons.refresh_rounded, color: theme.canvasColor),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.15)),
            const SizedBox(height: 14),

            // Search & Filter Controls
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Keyword Search Field
                SizedBox(
                  width: isDesktop ? 240 : double.infinity,
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 13, color: theme.canvasColor),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      hintText: "Search by name, email, phone...",
                      hintStyle:
                          TextStyle(fontSize: 12, color: theme.hintColor),
                      prefixIcon: Icon(Icons.search,
                          size: 16, color: theme.hintColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                _fetchUsers(page: 0);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: theme.primaryColor, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _fetchUsers(page: 0),
                  ),
                ),

                // State Filter
                SizedBox(
                  width: isDesktop ? 150 : 160,
                  height: 38,
                  child: TextField(
                    controller: _stateController,
                    style: TextStyle(fontSize: 13, color: theme.canvasColor),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      hintText: "State (e.g. MH)",
                      hintStyle:
                          TextStyle(fontSize: 12, color: theme.hintColor),
                      prefixIcon: Icon(Icons.map_outlined,
                          size: 15, color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                    ),
                    onSubmitted: (_) => _fetchUsers(page: 0),
                  ),
                ),

                // District Filter
                SizedBox(
                  width: isDesktop ? 150 : 160,
                  height: 38,
                  child: TextField(
                    controller: _districtController,
                    style: TextStyle(fontSize: 13, color: theme.canvasColor),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      hintText: "District",
                      hintStyle:
                          TextStyle(fontSize: 12, color: theme.hintColor),
                      prefixIcon: Icon(Icons.location_city_rounded,
                          size: 15, color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                    ),
                    onSubmitted: (_) => _fetchUsers(page: 0),
                  ),
                ),

                // Taluka Filter
                SizedBox(
                  width: isDesktop ? 150 : 160,
                  height: 38,
                  child: TextField(
                    controller: _talukaController,
                    style: TextStyle(fontSize: 13, color: theme.canvasColor),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      hintText: "Taluka",
                      hintStyle:
                          TextStyle(fontSize: 12, color: theme.hintColor),
                      prefixIcon: Icon(Icons.holiday_village_rounded,
                          size: 15, color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                    ),
                    onSubmitted: (_) => _fetchUsers(page: 0),
                  ),
                ),

                // Date Range Button
                InkWell(
                  onTap: () => _selectDateRange(context),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDateActive
                          ? theme.primaryColor.withValues(alpha: 0.15)
                          : theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDateActive
                            ? theme.primaryColor
                            : theme.dividerColor.withValues(alpha: 0.2),
                        width: isDateActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 15,
                          color: isDateActive
                              ? theme.primaryColor
                              : theme.hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDateActive
                              ? "${_startDate?.day}/${_startDate?.month} - ${_endDate?.day}/${_endDate?.month}"
                              : "Date Range",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isDateActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isDateActive
                                ? theme.primaryColor
                                : theme.canvasColor.withValues(alpha: 0.8),
                          ),
                        ),
                        if (isDateActive) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                              _fetchUsers(page: 0);
                            },
                            child: Icon(
                              Icons.close,
                              size: 13,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Apply Search Button
                ElevatedButton.icon(
                  onPressed: () => _fetchUsers(page: 0),
                  icon: const Icon(Icons.search_rounded, size: 15),
                  label: const Text("Search", style: TextStyle(fontSize: 12.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                // Clear Filters Button
                if (hasFilters)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 15),
                    label: const Text("Clear",
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            // Content Area: Loading, Error, Empty, or Table
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Colors.amber, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: theme.canvasColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_users.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: theme.hintColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No buyers found for this movie yet",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.canvasColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Try adjusting search keywords or location filters",
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                    ),
                  ],
                ),
              )
            else ...[
              // Users Table
              _buildUsersTable(context, theme, isDesktop),
              const SizedBox(height: 14),

              // Pagination Controls
              _buildPaginationBar(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable(
      BuildContext context, ThemeData theme, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isDesktop ? 900 : 700,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.primaryColor.withValues(alpha: 0.06),
              ),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: theme.canvasColor,
              ),
              dataTextStyle: TextStyle(
                fontSize: 12.5,
                color: theme.canvasColor.withValues(alpha: 0.9),
              ),
              columns: const [
                DataColumn(label: Text("User")),
                DataColumn(label: Text("Contact")),
                DataColumn(label: Text("Location")),
                DataColumn(label: Text("Role")),
                DataColumn(label: Text("Purchase Amount")),
                DataColumn(label: Text("Purchase Date")),
                DataColumn(label: Text("Status")),
              ],
              rows: _users.map((user) {
                final loc = user.location;
                final locStr = [
                  loc?.city ?? loc?.taluka ?? '',
                  loc?.district ?? '',
                  loc?.state ?? '',
                ].where((s) => s.trim().isNotEmpty).join(', ');

                final roleStr = user.role?.isNotEmpty == true
                    ? user.role!.join(', ')
                    : 'USER';

                final purchase = user.purchaseDetails;
                final purchaseAmount = purchase?.amount != null
                    ? "₹${purchase!.amount!.toStringAsFixed(2)}"
                    : "—";

                String purchaseDateStr = "—";
                if (purchase?.purchaseDate != null) {
                  if (purchase!.purchaseDate is int) {
                    final dt = DateTime.fromMillisecondsSinceEpoch(
                        purchase.purchaseDate as int);
                    purchaseDateStr =
                        "${dt.day}/${dt.month}/${dt.year}";
                  } else {
                    purchaseDateStr = purchase.purchaseDate.toString();
                  }
                }

                return DataRow(
                  cells: [
                    // User cell with avatar & name
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                theme.primaryColor.withValues(alpha: 0.15),
                            backgroundImage: user.profilePhoto != null &&
                                    user.profilePhoto!.isNotEmpty
                                ? NetworkImage(user.profilePhoto!)
                                : null,
                            child: user.profilePhoto == null ||
                                    user.profilePhoto!.isEmpty
                                ? Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Contact cell
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user.emailId != null &&
                              user.emailId!.isNotEmpty)
                            Text(
                              user.emailId!,
                              style: TextStyle(
                                fontSize: 11.5,
                                color:
                                    theme.canvasColor.withValues(alpha: 0.8),
                              ),
                            ),
                          if (user.mobileNumber != null &&
                              user.mobileNumber!.isNotEmpty)
                            Text(
                              user.mobileNumber!,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.hintColor,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Location cell
                    DataCell(
                      Text(
                        locStr.isNotEmpty ? locStr : "Not Specified",
                        style: TextStyle(
                          fontSize: 11.5,
                          color: locStr.isNotEmpty
                              ? theme.canvasColor.withValues(alpha: 0.85)
                              : theme.hintColor,
                        ),
                      ),
                    ),

                    // Role cell
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: roleStr.contains('PROMOTER')
                              ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                              : Colors.blueGrey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleStr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleStr.contains('PROMOTER')
                                ? const Color(0xFF6366F1)
                                : theme.canvasColor.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ),

                    // Purchase Amount
                    DataCell(
                      Text(
                        purchaseAmount,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),

                    // Purchase Date
                    DataCell(
                      Text(
                        purchaseDateStr,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    // Payment Status
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (purchase?.paymentStatus ?? 'SUCCESS') ==
                                  'SUCCESS'
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          purchase?.paymentStatus ?? 'ACTIVE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: (purchase?.paymentStatus ?? 'SUCCESS') ==
                                    'SUCCESS'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationBar(ThemeData theme) {
    final startIdx = _currentPage * _pageSize + 1;
    final endIdx = ((_currentPage + 1) * _pageSize).clamp(0, _totalUsers);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _totalUsers > 0
              ? "Showing $startIdx-$endIdx of $_totalUsers buyers"
              : "0 buyers",
          style: TextStyle(
            fontSize: 12,
            color: theme.hintColor,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 18),
              onPressed: _currentPage > 0
                  ? () => _fetchUsers(page: _currentPage - 1)
                  : null,
            ),
            Text(
              "Page ${_currentPage + 1} of ${_totalPages > 0 ? _totalPages : 1}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 18),
              onPressed: _currentPage + 1 < _totalPages
                  ? () => _fetchUsers(page: _currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:admin_ott/app/core/constant/prefrense_constant.dart';
import 'package:admin_ott/app/core/utils/sharepreferences.dart';
import 'package:admin_ott/app/provider/graphProvider.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/settelementProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/transactionProvider.dart';
import 'package:admin_ott/app/ui/pages/dashboard%20page/component/mediaHouse_profile_page.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/edit_media_house_dialog.dart';
import 'package:admin_ott/app/ui/pages/manage%20media%20house%20page/component/mediaHouse_content_approval.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/movie_details_dialog.dart.dart';
import 'package:admin_ott/app/ui/pages/media%20house%20detail%20page/component/TopMoviesLineGraph.dart';
import 'package:admin_ott/app/ui/pages/media%20house%20detail%20page/component/settlementCards.dart';
import 'package:admin_ott/app/ui/pages/shorts%20page/components/short_master_page.dart';
import 'package:admin_ott/app/widgets/CustomLineGraph.dart';
import 'package:admin_ott/app/widgets/financial_formatter.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:admin_ott/data/models/response/userTransactionResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MediaHouseDetailPage extends StatefulWidget {
  final MediaHouse mediaHouse;
  const MediaHouseDetailPage({super.key, required this.mediaHouse});

  @override
  State<MediaHouseDetailPage> createState() => _MediaHouseDetailPageState();
}

class _MediaHouseDetailPageState extends State<MediaHouseDetailPage> {
  _ContentMode _selectedContentMode = _ContentMode.movie;
  String _revenueSearchQuery = '';
  String _txnSearchQuery = '';
  int _txnCurrentPage = 0;
  static const int _txnPageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final id = widget.mediaHouse.id;
    if (id == null) return;
    final provider = Provider.of<MediaHouseProvider>(context, listen: false);
    final graphProvider = Provider.of<GraphProvider>(context, listen: false);
    final settelementProvider =
        Provider.of<SettelementProvider>(context, listen: false);
    final txnProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final localSharePreferences = LocalSharePreferences();
    await localSharePreferences.setString(
      SharedPreferencesConstant.currentMediaHouseId,
      id.toString(),
    );

    // 1. Fetch Media House Profile V2
    await provider.fetchMediaHouseProfile(id);

    // 2. Fetch scoped Media House Transactions V2
    await provider.fetchMediaHouseTransactions(id);

    // 3. Fetch Movies and Pending content V2
    await provider.fetchMoviesByMediaHouseId(id);
    await provider.fetchMoviesByStatusAndMediaHouseId("PENDING", id);

    // 4. Fetch Dashboard Counts V2
    await provider.fetchMediaHouseDashboardData(id);

    // 5. Fetch Revenue By Content Graph V2
    final typeParam = switch (_selectedContentMode) {
      _ContentMode.movie => 'Movie',
      _ContentMode.shortFilm => 'Short Film',
      _ContentMode.series => 'Series',
      _ContentMode.shorts => 'Mini Series',
    };
    await graphProvider.fetchTopPerformingMovieGraph(0, id, type: typeParam);

    // 6. Fetch Shorts / Mini Series V2
    await provider.fetchShortsByMediaHouse(id);

    // 7. Fetch Weekly Settlements V2
    final settlementUserId = widget.mediaHouse.user?.id ?? id;
    await settelementProvider
        .fetchWeeklySettelementDataByMediaHouseId(settlementUserId);

    // 8. Fetch all transactions for fallback matching
    await txnProvider.fetchUserTransactions('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      final currentHouse = provider.selectedMediaHouse ?? widget.mediaHouse;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: Text(
            currentHouse.mediaHouseName ?? 'Production House Overview',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.primaryColor,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Edit Details',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () async {
                final result =
                    await EditMediaHouseDialog.show(context, currentHouse);
                if (result == true) {
                  await _loadData();
                  if (mounted) {
                    await Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouse();
                    setState(() {});
                  }
                }
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
              tooltip: 'Refresh Data',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                EdgeInsets.all(ResponsiveWidget.isMobile(context) ? 12 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSection(context, provider, currentHouse, theme),
                const SizedBox(height: 16),
                _buildContentModeSelector(theme),
                const SizedBox(height: 12),
                _buildCurrentContentSection(context, provider, theme),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopSection(
    BuildContext context,
    MediaHouseProvider provider,
    MediaHouse currentHouse,
    ThemeData theme,
  ) {
    final profileCard = _buildProfileCard(context, currentHouse, theme);
    final dashboardCard =
        _buildDashboardCard(context, provider, currentHouse, theme);

    if (ResponsiveWidget.isMobile(context)) {
      return Column(
        children: [
          profileCard,
          const SizedBox(height: 14),
          dashboardCard,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 440, child: profileCard),
        const SizedBox(width: 16),
        Expanded(child: dashboardCard),
      ],
    );
  }

  Widget _buildContentModeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _buildModeChip(theme, _ContentMode.movie, 'Movie'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.shortFilm, 'Short Film'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.series, 'Series'),
          const SizedBox(width: 6),
          _buildModeChip(theme, _ContentMode.shorts, 'Mini Series'),
        ],
      ),
    );
  }

  Widget _buildModeChip(ThemeData theme, _ContentMode mode, String label) {
    final selected = _selectedContentMode == mode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _selectedContentMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : theme.canvasColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContentSection(
    BuildContext context,
    MediaHouseProvider provider,
    ThemeData theme,
  ) {
    if (_selectedContentMode == _ContentMode.shorts) {
      return _buildContentSection(
        context: context,
        theme: theme,
        title: 'Mini Series',
        emptyText: provider.isShortsLoading
            ? 'Loading Mini Series...'
            : 'No Mini Series available.',
        items: provider.shortsByMediaHouse,
        child: _buildShortsGrid(context, provider.shortsByMediaHouse, theme),
      );
    }

    final filtered = provider.filteredContentListByMediaHouse.where((item) {
      final type = (item.type ?? '').trim().toUpperCase();
      if (_selectedContentMode == _ContentMode.series) {
        return type == 'SERIES';
      }
      if (_selectedContentMode == _ContentMode.shortFilm) {
        return type == 'SHORT_FILM';
      }
      return type == 'MOVIE' || type.isEmpty;
    }).toList();

    final sectionTitle = switch (_selectedContentMode) {
      _ContentMode.movie => 'Movies',
      _ContentMode.shortFilm => 'Short Films',
      _ContentMode.series => 'Series',
      _ContentMode.shorts => 'Mini Series',
    };

    return _buildContentSection(
      context: context,
      theme: theme,
      title: sectionTitle,
      emptyText: 'No ${sectionTitle.toLowerCase()} available.',
      items: filtered,
      child: _buildMovieSeriesGrid(context, filtered, theme),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    MediaHouse currentHouse,
    ThemeData theme,
  ) {
    final statusText = currentHouse.status ??
        (currentHouse.active == true ? 'ACTIVE' : 'INACTIVE');
    final isActive = statusText.toUpperCase() == 'ACTIVE';
    final loc = currentHouse.location;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.canvasColor.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          theme.primaryColor.withValues(alpha: 0.16),
                      backgroundImage: (currentHouse.logo ?? '').isNotEmpty
                          ? NetworkImage(currentHouse.logo!)
                          : null,
                      child: (currentHouse.logo ?? '').isEmpty
                          ? Icon(Icons.business,
                              size: 26, color: theme.primaryColor)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentHouse.mediaHouseName ?? 'Unknown Name',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: theme.canvasColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.withValues(alpha: 0.12)
                                      : Colors.red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        isActive ? Colors.green : Colors.red,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentHouse.discription ??
                                'No description available.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: theme.canvasColor.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (currentHouse.id != null)
                      _buildProfilePill(
                        theme,
                        Icons.tag,
                        'ID: #${currentHouse.id}',
                      ),
                    _buildProfilePill(
                      theme,
                      Icons.phone_outlined,
                      currentHouse.contactNumber ?? 'N/A',
                    ),
                    _buildProfilePill(
                      theme,
                      Icons.mail_outline,
                      currentHouse.email ?? 'N/A',
                    ),
                    if (currentHouse.user != null)
                      _buildProfilePill(
                        theme,
                        Icons.person_outline,
                        'Contact: ${[currentHouse.user!.firstName, currentHouse.user!.lastName].where((s) => s != null && s.trim().isNotEmpty).join(" ")}',
                      ),
                    if (currentHouse.firmType != null)
                      _buildProfilePill(
                        theme,
                        Icons.apartment_outlined,
                        'Firm: ${currentHouse.firmType}',
                      ),
                    if (currentHouse.designation != null)
                      _buildProfilePill(
                        theme,
                        Icons.badge_outlined,
                        'Role: ${currentHouse.designation}',
                      ),
                  ],
                ),
                const Divider(height: 18),
                // Location & Office Hierarchy
                Text(
                  'Location & Office Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoRow('Country', loc?.country ?? 'N/A', theme),
                _buildInfoRow('State', loc?.state ?? 'N/A', theme),
                _buildInfoRow('District', loc?.district ?? 'N/A', theme),
                _buildInfoRow('Taluka', loc?.taluka ?? 'N/A', theme),
                _buildInfoRow('City', loc?.city ?? 'N/A', theme),
                if (loc?.area != null && loc!.area!.trim().isNotEmpty)
                  _buildInfoRow('Area', loc.area!, theme),
                _buildInfoRow('Pincode', loc?.pincode ?? 'N/A', theme),
                _buildInfoRow(
                  'Office / Address',
                  currentHouse.address ?? loc?.officeBuilding ?? 'N/A',
                  theme,
                ),
                _buildInfoRow(
                  'Created Date',
                  _formatDate(currentHouse.createdDate),
                  theme,
                ),
                if (currentHouse.joinDate != null)
                  _buildInfoRow(
                    'Join Date',
                    _formatDate(currentHouse.joinDate),
                    theme,
                  ),
                if (currentHouse.user != null) ...[
                  const Divider(height: 18),
                  Text(
                    'Associated User Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    'Account Name',
                    [currentHouse.user!.firstName, currentHouse.user!.lastName]
                        .where((s) => s != null && s.trim().isNotEmpty)
                        .join(" "),
                    theme,
                  ),
                  _buildInfoRow(
                    'Mobile Number',
                    currentHouse.user!.mobileNumber ?? 'N/A',
                    theme,
                  ),
                  _buildInfoRow(
                    'Email Address',
                    currentHouse.user!.emailId ?? 'N/A',
                    theme,
                  ),
                  _buildInfoRow(
                    'Registered On',
                    _formatDate(currentHouse.user!.registrationDate),
                    theme,
                  ),
                  _buildInfoRow(
                    'Account Status',
                    currentHouse.user!.active == true ? 'Active' : 'Inactive',
                    theme,
                  ),
                ],
                const Divider(height: 18),
                // Statutory & Identity Documents (8 Documents)
                Text(
                  'Statutory & Identity Documents',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDocumentInfoRow(
                  label: 'Registration Cert.',
                  value: currentHouse.registrationCertificate,
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'GST Certificate',
                  value: currentHouse.gstCertificates,
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'PAN Card',
                  value: currentHouse.panCard,
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'Aadhaar Card',
                  value: currentHouse.adharCard,
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'Shop Act',
                  value: currentHouse.shopAct?.toString(),
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'Bank Proof',
                  value: currentHouse.bankProof,
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'Identity Proof',
                  value: currentHouse.identityProof,
                  context: context,
                  theme: theme,
                ),
                _buildDocumentInfoRow(
                  label: 'Address Proof',
                  value: currentHouse.addressProof,
                  context: context,
                  theme: theme,
                ),
                const Divider(height: 18),
                // Banking Details with Security Masking
                Text(
                  'Banking & Financial Credentials',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  'Bank Name',
                  currentHouse.bankName?.toString() ?? 'N/A',
                  theme,
                ),
                if (currentHouse.accountHolderName != null)
                  _buildInfoRow(
                    'A/C Holder',
                    currentHouse.accountHolderName.toString(),
                    theme,
                  ),
                _buildInfoRow(
                  'A/C Number',
                  _maskBankAccount(currentHouse.bankAccountNumber),
                  theme,
                ),
                _buildInfoRow(
                  'IFSC Code',
                  currentHouse.bankIfscNumber ?? 'N/A',
                  theme,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(
                            color: theme.primaryColor.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final result = await EditMediaHouseDialog.show(
                            context, currentHouse);
                        if (result == true) {
                          await _loadData();
                          if (mounted) {
                            await Provider.of<MediaHouseProvider>(context, listen: false).fetchMediaHouse();
                            setState(() {});
                          }
                        }
                      },
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('Edit Details'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaHouseProfilePage(
                                mediaHouse: currentHouse),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new, size: 15),
                      label: const Text('View Full Detail'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: ResponsiveWidget.isMobile(context) ? 244 : 450,
            child: SingleChildScrollView(
              child: _buildCardContainer(
                theme: theme,
                title: 'Content Approvals',
                child:
                    MediahouseContentApprovalWidget(currentHouse.id ?? 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return 'N/A';
    if (dateVal is int) {
      if (dateVal > 0) {
        try {
          final dt = DateTime.fromMillisecondsSinceEpoch(dateVal);
          return DateFormat('dd MMM yyyy').format(dt);
        } catch (_) {}
      }
    }
    final str = dateVal.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'N/A') return 'N/A';
    final parsedInt = int.tryParse(str);
    if (parsedInt != null && parsedInt > 100000000) {
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(parsedInt);
        return DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {}
    }
    try {
      final dt = DateTime.tryParse(str);
      if (dt != null) {
        return DateFormat('dd MMM yyyy').format(dt);
      }
    } catch (_) {}
    return str;
  }

  String _maskBankAccount(String? acc) {
    if (acc == null || acc.trim().isEmpty || acc == 'N/A') return 'N/A';
    final trimmed = acc.trim();
    if (trimmed.length <= 4) return trimmed;
    final last4 = trimmed.substring(trimmed.length - 4);
    return '******$last4';
  }

  Widget _buildDocumentInfoRow({
    required String label,
    required String? value,
    required BuildContext context,
    required ThemeData theme,
  }) {
    final hasValue =
        value != null && value.trim().isNotEmpty && value.trim() != 'N/A';
    final isUrl = hasValue &&
        (value.startsWith('http://') ||
            value.startsWith('https://') ||
            value.contains('/uploads/') ||
            value.contains('.jpg') ||
            value.contains('.jpeg') ||
            value.contains('.png') ||
            value.contains('.webp') ||
            value.contains('.pdf'));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.canvasColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              hasValue ? (isUrl ? 'Document Attached' : value) : 'N/A',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: hasValue
                    ? theme.canvasColor.withValues(alpha: 0.88)
                    : theme.canvasColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          if (hasValue) ...[
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () =>
                  _showDocumentViewerDialog(context, label, value, theme),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 12, color: theme.primaryColor),
                    const SizedBox(width: 3),
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDocumentViewerDialog(
    BuildContext context,
    String documentTitle,
    String docValue,
    ThemeData theme,
  ) {
    final trimmed = docValue.trim();
    final isUrl = trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.contains('/uploads/') ||
        trimmed.contains('.jpg') ||
        trimmed.contains('.jpeg') ||
        trimmed.contains('.png') ||
        trimmed.contains('.webp') ||
        trimmed.contains('.pdf');

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: theme.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        color: theme.primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        documentTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.canvasColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: theme.canvasColor,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Flexible(
                  child: Center(
                    child: isUrl
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.network(
                                trimmed,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: progress.expectedTotalBytes !=
                                                null
                                            ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.broken_image_outlined,
                                            size: 48, color: Colors.grey),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Unable to display image preview',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: theme.canvasColor),
                                        ),
                                        const SizedBox(height: 6),
                                        SelectableText(
                                          trimmed,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: theme.canvasColor
                                                  .withValues(alpha: 0.7)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.badge_outlined,
                                    size: 48, color: theme.primaryColor),
                                const SizedBox(height: 12),
                                Text(
                                  documentTitle,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: theme.canvasColor
                                          .withValues(alpha: 0.6)),
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  trimmed,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Document identifier registered with media house account.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.canvasColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.canvasColor.withValues(alpha: 0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    MediaHouseProvider provider,
    MediaHouse currentHouse,
    ThemeData theme,
  ) {
    final data = provider.mediaHouseDashboardData;
    final isLoading = provider.isDashboardDataLoading;
    final errorMessage = provider.dashboardDataError;

    final txnProvider = Provider.of<TransactionProvider>(context);
    final allTxns = txnProvider.filtteredUserTransactionList;
    final houseId = currentHouse.id;
    final houseName =
        (currentHouse.mediaHouseName ?? '').trim().toLowerCase();

    final List<UserTransactionData> houseTxns =
        provider.mediaHouseTransactions.isNotEmpty
            ? provider.mediaHouseTransactions
            : allTxns.where((t) {
                if (t.movie?.mediaHouseId != null && houseId != null) {
                  if (t.movie!.mediaHouseId == houseId) return true;
                }
                final mHouse =
                    (t.movie?.mediaHouseName ?? '').trim().toLowerCase();
                if (mHouse.isNotEmpty &&
                    houseName.isNotEmpty &&
                    mHouse == houseName) {
                  return true;
                }
                return false;
              }).toList();

    // Production House Name from API (falling back to currentHouse)
    final prodHouseName = (data.productionHouseName != null &&
            data.productionHouseName!.trim().isNotEmpty)
        ? data.productionHouseName!.trim()
        : (currentHouse.mediaHouseName ?? 'Production House');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error banner if any
        if (errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (currentHouse.id != null) {
                      provider.fetchMediaHouseDashboardData(currentHouse.id!,
                          forceRefresh: true);
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
                  label: const Text('Retry', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),

        // 1. CONTENT METRICS SECTION
        _buildSectionTitle('Content Overview', Icons.movie_outlined, theme),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width > 1100
                ? 6
                : width > 750
                    ? 3
                    : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 1 ? 3.8 : 1.9,
              children: [
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.video_collection_outlined,
                  title: "Total Content",
                  value: isLoading
                      ? "..."
                      : (data.totalContentCount != null
                          ? '${data.totalContentCount}'
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.play_circle_outline_sharp,
                  title: "Live Content",
                  value: isLoading
                      ? "..."
                      : (data.liveContent != null
                          ? '${data.liveContent}'
                          : "-"),
                  onTap: () =>
                      _openGraphDialog(context, 'Live Content', 'live', 2),
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.schedule,
                  title: "Upcoming Content",
                  value: isLoading
                      ? "..."
                      : (data.upcomingContent != null
                          ? '${data.upcomingContent}'
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.hourglass_top_outlined,
                  title: "Pending Content",
                  value: isLoading
                      ? "..."
                      : (data.pendingContent != null
                          ? '${data.pendingContent}'
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.visibility_outlined,
                  title: "Total Views",
                  value: isLoading
                      ? "..."
                      : (data.totalViews != null
                          ? NumberFormat('#,##,###').format(data.totalViews)
                          : "-"),
                  onTap: () =>
                      _openGraphDialog(context, 'Views Graph', 'views', 1),
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.shopping_cart_outlined,
                  title: "Purchase Count",
                  value: isLoading
                      ? "..."
                      : (data.purchaseCount != null
                          ? '${data.purchaseCount}'
                          : "-"),
                  onTap: () {},
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // 2. FINANCIAL & REVENUE METRICS SECTION
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
                'Financial & Revenue Details ($prodHouseName)',
                Icons.account_balance_wallet_outlined,
                theme),
            if (data.walletAmount != null || isLoading)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        size: 15, color: Colors.green),
                    const SizedBox(width: 5),
                    Text(
                      'Wallet: ${isLoading ? "..." : FinancialFormatter.format4(data.walletAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width > 1100
                ? 6
                : width > 850
                    ? 4
                    : width > 500
                        ? 2
                        : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 1 ? 3.8 : 1.9,
              children: [
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Wallet Amount",
                  value: isLoading
                      ? "..."
                      : (data.walletAmount != null
                          ? FinancialFormatter.format4(data.walletAmount)
                          : "-"),
                  isHighlighted: true,
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.payments_outlined,
                  title: "Customer Payment",
                  value: isLoading
                      ? "..."
                      : (data.customerPayment != null
                          ? FinancialFormatter.format4(data.customerPayment)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.receipt_long_outlined,
                  title: "GST Charges",
                  value: isLoading
                      ? "..."
                      : (data.gstCharges != null
                          ? FinancialFormatter.format4(data.gstCharges)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.calculate_outlined,
                  title: "Base Amount After GST",
                  value: isLoading
                      ? "..."
                      : (data.baseAmountAfterGST != null
                          ? FinancialFormatter.format4(data.baseAmountAfterGST)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.credit_card_outlined,
                  title: "Payment Gateway Fees",
                  value: isLoading
                      ? "..."
                      : (data.paymentGatewayFees != null
                          ? FinancialFormatter.format4(data.paymentGatewayFees)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.account_balance_outlined,
                  title: "Net Revenue",
                  value: isLoading
                      ? "..."
                      : (data.netRevenue != null
                          ? FinancialFormatter.format4(data.netRevenue)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.admin_panel_settings_outlined,
                  title: "Platform Revenue",
                  value: isLoading
                      ? "..."
                      : (data.platformRevenue != null
                          ? FinancialFormatter.format4(data.platformRevenue)
                          : "-"),
                  onTap: () =>
                      _openGraphDialog(context, 'Revenue Graph', 'sales', 0),
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.business_outlined,
                  title: "Production House Revenue",
                  value: isLoading
                      ? "..."
                      : (data.productionHouseRevenue != null
                          ? FinancialFormatter.format4(data.productionHouseRevenue)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.receipt_outlined,
                  title: "Tax",
                  value: isLoading
                      ? "..."
                      : (data.tax != null
                          ? FinancialFormatter.format4(data.tax)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.paid_outlined,
                  title: "Payment Gateway Fee",
                  value: isLoading
                      ? "..."
                      : (data.paymentGatewayFee != null
                          ? FinancialFormatter.format4(data.paymentGatewayFee)
                          : "-"),
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.verified_outlined,
                  title: "Final Production House Revenue",
                  value: isLoading
                      ? "..."
                      : (data.finalProductionHouseRevenue != null
                          ? FinancialFormatter.format4(
                              data.finalProductionHouseRevenue)
                          : "-"),
                  isHighlighted: true,
                  onTap: () {},
                ),
                _buildMetricTile(
                  theme: theme,
                  icon: Icons.campaign_outlined,
                  title: "Promoter Revenue",
                  value: isLoading
                      ? "..."
                      : (data.promoterRevenue != null
                          ? FinancialFormatter.format4(data.promoterRevenue)
                          : "-"),
                  onTap: () {},
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _buildCardContainer(
          theme: theme,
          title: '',
          child: SizedBox(
            height: 270,
            child: TopMoviesLineGraph(
              isRevenue: true,
              mediaHouseId: currentHouse.id ?? 0,
              type: switch (_selectedContentMode) {
                _ContentMode.movie => 'Movie',
                _ContentMode.shortFilm => 'Short Film',
                _ContentMode.series => 'Series',
                _ContentMode.shorts => 'Mini Series',
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildFinancialTransparencySection(
            context, theme, houseTxns, currentHouse, provider),
        const SizedBox(height: 14),
        _buildScopedTransactionsSection(context, theme, houseTxns),
        const SizedBox(height: 14),
        SettlementCard(currentHouse),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.canvasColor,
          ),
        ),
      ],
    );
  }

  String _sanitizeContentTitle(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Untitled Content';
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = json.decode(trimmed);
        if (decoded is Map) {
          final t = decoded['title'] ??
              decoded['Title'] ??
              decoded['name'] ??
              decoded['Name'] ??
              decoded['movieName'] ??
              decoded['seriesName'];
          if (t != null && t.toString().trim().isNotEmpty) {
            return t.toString().trim();
          }
        }
      } catch (_) {}
    }
    return trimmed;
  }

  Widget _buildFinancialTransparencySection(
    BuildContext context,
    ThemeData theme,
    List<UserTransactionData> houseTxns,
    MediaHouse currentHouse,
    MediaHouseProvider provider,
  ) {
    final houseName = currentHouse.mediaHouseName ?? 'Production House';

    // Group transactions by content title
    final Map<String, List<UserTransactionData>> contentTxnMap = {};
    for (var t in houseTxns) {
      final title = _sanitizeContentTitle(t.movie?.title);
      contentTxnMap.putIfAbsent(title, () => []).add(t);
    }

    // Build rows either from real transactions or from provider's content list
    final List<_ProductionContentRevenueRow> rows = [];

    if (contentTxnMap.isNotEmpty) {
      contentTxnMap.forEach((title, txns) {
        final count = txns.length;
        DateTime? minDate;
        DateTime? maxDate;
        double totalCustomerPayment = 0.0;

        for (var t in txns) {
          final p = (t.price ?? t.movie?.price ?? 0.0).toDouble();
          totalCustomerPayment += p;
          if (t.dateFrom != null) {
            final dt = DateTime.fromMillisecondsSinceEpoch(t.dateFrom!);
            if (minDate == null || dt.isBefore(minDate)) minDate = dt;
            if (maxDate == null || dt.isAfter(maxDate)) maxDate = dt;
          }
        }

        final gst = FinancialFormatter.calculateGst(totalCustomerPayment);
        final base =
            FinancialFormatter.calculateBaseAmount(totalCustomerPayment);
        final gateway = base * 0.02;
        final net = base - gateway;
        final platformShare =
            FinancialFormatter.calculatePlatformRevenue(net);
        final prodGross =
            FinancialFormatter.calculateProductionGrossRevenue(net);
        final tax = FinancialFormatter.calculateProductionTds(prodGross);
        final payoutFee = (prodGross - tax) * 0.02;
        final finalProdRevenue = prodGross - tax - payoutFee;
        final promoterRevenue = base * 0.05;

        rows.add(_ProductionContentRevenueRow(
          revenueName: '$houseName - $title',
          purchaseCount: count,
          firstPurchaseDate: minDate != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(minDate)
              : '-',
          lastPurchaseDate: maxDate != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(maxDate)
              : '-',
          customerPayment: totalCustomerPayment,
          gstCharges: gst,
          baseAmount: base,
          paymentGatewayFees: gateway,
          netRevenue: net,
          platformRevenue: platformShare,
          productionHouseRevenue: prodGross,
          tax: tax,
          paymentGatewayFee2Pct: payoutFee,
          finalProductionHouseRevenue: finalProdRevenue,
          promoterRevenue: promoterRevenue,
        ));
      });
    } else {
      // Fallback: build from content list
      for (var c in provider.filteredContentListByMediaHouse) {
        final title = _sanitizeContentTitle(c.title);
        final totalCustomerPayment = (c.totalRevenue ?? 0.0).toDouble();
        final gst = FinancialFormatter.calculateGst(totalCustomerPayment);
        final base =
            FinancialFormatter.calculateBaseAmount(totalCustomerPayment);
        final gateway = base * 0.02;
        final net = base - gateway;
        final platformShare = (c.adminRevnue ?? 0.0) > 0
            ? (c.adminRevnue ?? 0.0)
            : FinancialFormatter.calculatePlatformRevenue(net);
        final prodGross = (c.mediaHouseRevenue ?? 0.0) > 0
            ? (c.mediaHouseRevenue ?? 0.0)
            : FinancialFormatter.calculateProductionGrossRevenue(net);
        final tax = FinancialFormatter.calculateProductionTds(prodGross);
        final payoutFee = (prodGross - tax) * 0.02;
        final finalProdRevenue = prodGross - tax - payoutFee;
        final promoterRevenue = base * 0.05;

        rows.add(_ProductionContentRevenueRow(
          revenueName: '$houseName - $title',
          purchaseCount: c.totalPurchase ?? 0,
          firstPurchaseDate:
              c.uploadDateTime ?? c.releaseDate?.toString() ?? '-',
          lastPurchaseDate:
              c.approvedDateTime ?? c.uploadDateTime ?? '-',
          customerPayment: totalCustomerPayment,
          gstCharges: gst,
          baseAmount: base,
          paymentGatewayFees: gateway,
          netRevenue: net,
          platformRevenue: platformShare,
          productionHouseRevenue: prodGross,
          tax: tax,
          paymentGatewayFee2Pct: payoutFee,
          finalProductionHouseRevenue: finalProdRevenue,
          promoterRevenue: promoterRevenue,
        ));
      }
    }

    final filteredRows = rows.where((r) {
      if (_revenueSearchQuery.isEmpty) return true;
      return r.revenueName
          .toLowerCase()
          .contains(_revenueSearchQuery.toLowerCase());
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Production House Revenue Breakdown & Transparency Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filteredRows.length} Items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by content title...',
                      prefixIcon: Icon(Icons.search,
                          size: 18,
                          color: theme.canvasColor.withValues(alpha: 0.6)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _revenueSearchQuery = val;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filteredRows.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No revenue breakdown records found for this production house.',
                style:
                    TextStyle(color: theme.canvasColor.withValues(alpha: 0.6)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    theme.primaryColor.withValues(alpha: 0.08)),
                dataRowMinHeight: 46,
                dataRowMaxHeight: 52,
                columns: const [
                  DataColumn(
                      label: Text('Revenue (Title)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Purchase Count',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('First Purchase Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Last Purchase Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Customer Payment',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('GST Charges',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Base Amount after GST',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Payment gateway fees',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Net Revenue',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Platform Revenue(30%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Production House Revenue(70%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Tax(10%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Payment Gateway Fee(2%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Final Production House Revenue',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Promoter Revenue',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: filteredRows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text(r.revenueName,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${r.purchaseCount}')),
                      DataCell(Text(r.firstPurchaseDate)),
                      DataCell(Text(r.lastPurchaseDate)),
                      DataCell(
                          Text(FinancialFormatter.format4(r.customerPayment))),
                      DataCell(Text(FinancialFormatter.format4(r.gstCharges))),
                      DataCell(Text(FinancialFormatter.format4(r.baseAmount))),
                      DataCell(Text(
                          FinancialFormatter.format4(r.paymentGatewayFees))),
                      DataCell(Text(FinancialFormatter.format4(r.netRevenue))),
                      DataCell(
                          Text(FinancialFormatter.format4(r.platformRevenue))),
                      DataCell(Text(FinancialFormatter.format4(
                          r.productionHouseRevenue))),
                      DataCell(Text(FinancialFormatter.format4(r.tax))),
                      DataCell(Text(FinancialFormatter.format4(
                          r.paymentGatewayFee2Pct))),
                      DataCell(Text(
                          FinancialFormatter.format4(
                              r.finalProductionHouseRevenue),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green))),
                      DataCell(
                          Text(FinancialFormatter.format4(r.promoterRevenue))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScopedTransactionsSection(
    BuildContext context,
    ThemeData theme,
    List<UserTransactionData> houseTxns,
  ) {
    final filteredTxns = houseTxns.where((t) {
      if (_txnSearchQuery.isEmpty) return true;
      final q = _txnSearchQuery.toLowerCase();
      final idStr = (t.id ?? '').toString();
      final userName =
          '${t.user?.firstName ?? ""} ${t.user?.lastName ?? ""}'.trim().toLowerCase();
      final contentTitle =
          _sanitizeContentTitle(t.movie?.title).toLowerCase();
      return idStr.contains(q) ||
          userName.contains(q) ||
          contentTitle.contains(q);
    }).toList();

    final totalCount = filteredTxns.length;
    final totalPages = (totalCount / _txnPageSize).ceil();
    final startIndex = _txnCurrentPage * _txnPageSize;
    final endIndex = (startIndex + _txnPageSize < totalCount)
        ? startIndex + _txnPageSize
        : totalCount;
    final pageTxns = (startIndex < totalCount)
        ? filteredTxns.sublist(startIndex, endIndex)
        : <UserTransactionData>[];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Financial Transactions (${filteredTxns.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Search transactions by ID, customer, content...',
                      prefixIcon: Icon(Icons.search,
                          size: 18,
                          color: theme.canvasColor.withValues(alpha: 0.6)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _txnSearchQuery = val;
                        _txnCurrentPage = 0;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filteredTxns.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No transactions found for this production house.',
                style:
                    TextStyle(color: theme.canvasColor.withValues(alpha: 0.6)),
              ),
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    theme.primaryColor.withValues(alpha: 0.08)),
                dataRowMinHeight: 46,
                dataRowMaxHeight: 52,
                columns: const [
                  DataColumn(
                      label: Text('Txn ID',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Customer / User',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Content / Movie',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Customer Payment',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('GST (18%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Base Amount',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Gateway Fee (2%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Net Revenue',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Admin Revenue (30%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Prod House (70%)',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: pageTxns.map((t) {
                  final gross = (t.price ?? t.movie?.price ?? 0.0).toDouble();
                  final gst = FinancialFormatter.calculateGst(gross);
                  final base = FinancialFormatter.calculateBaseAmount(gross);
                  final gw = base * 0.02;
                  final net = base - gw;
                  final adminRev =
                      FinancialFormatter.calculatePlatformRevenue(net);
                  final prodRev =
                      FinancialFormatter.calculateProductionGrossRevenue(net);
                  final dateStr = t.dateFrom != null
                      ? DateFormat('yyyy-MM-dd HH:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(t.dateFrom!))
                      : '-';
                  final statusStr = t.status ??
                      (t.active == true ? 'SUCCESS' : 'PENDING');
                  final isSuccess = statusStr.toUpperCase() == 'SUCCESS' ||
                      statusStr.toUpperCase() == 'COMPLETED';

                  return DataRow(
                    cells: [
                      DataCell(Text('#${t.id ?? "-"}',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(
                        '${t.user?.firstName ?? ""} ${t.user?.lastName ?? ""}'.trim().isNotEmpty
                            ? '${t.user?.firstName ?? ""} ${t.user?.lastName ?? ""}'.trim()
                            : (t.user?.emailId ?? 'N/A'),
                      )),
                      DataCell(
                          Text(_sanitizeContentTitle(t.movie?.title))),
                      DataCell(
                          Text(FinancialFormatter.format4(gross))),
                      DataCell(Text(FinancialFormatter.format4(gst))),
                      DataCell(Text(FinancialFormatter.format4(base))),
                      DataCell(Text(FinancialFormatter.format4(gw))),
                      DataCell(Text(FinancialFormatter.format4(net))),
                      DataCell(
                          Text(FinancialFormatter.format4(adminRev))),
                      DataCell(Text(FinancialFormatter.format4(prodRev),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green))),
                      DataCell(Text(dateStr)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSuccess
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSuccess ? Colors.green : Colors.orange,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            statusStr,
                            style: TextStyle(
                              color: isSuccess
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (totalPages > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${startIndex + 1} - $endIndex of $totalCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.canvasColor.withValues(alpha: 0.6),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _txnCurrentPage > 0
                            ? () {
                                setState(() {
                                  _txnCurrentPage--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        'Page ${_txnCurrentPage + 1} of $totalPages',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _txnCurrentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  _txnCurrentPage++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProfilePill(ThemeData theme, IconData icon, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 292),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.canvasColor.withValues(alpha: 0.78),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlighted
              ? Colors.green.withValues(alpha: 0.08)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? Colors.green
                : theme.canvasColor.withValues(alpha: 0.08),
            width: isHighlighted ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.green.withValues(alpha: 0.15)
                    : theme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon,
                  color: isHighlighted ? Colors.green : theme.primaryColor,
                  size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isHighlighted
                          ? Colors.green.shade800
                          : theme.canvasColor.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetricAmountHover(
                    value: value,
                    theme: theme,
                    color: isHighlighted ? Colors.green : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGraphDialog(
    BuildContext context,
    String title,
    String yAxisLabel,
    int graphNumber,
  ) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).getTheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: theme.cardColor,
        child: CustomLineGraph(
          title: title,
          yAxisLabel: yAxisLabel,
          canPop: true,
          mediaHouseId: widget.mediaHouse.id ?? 0,
          graphNumber: graphNumber,
          metrics: [yAxisLabel],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String emptyText,
    required List<dynamic> items,
    required Widget child,
  }) {
    return _buildCardContainer(
      theme: theme,
      title: title,
      child: items.isEmpty
          ? SizedBox(
              height: 130,
              child: Center(
                child: Text(
                  emptyText,
                  style: TextStyle(
                    color: theme.canvasColor.withValues(alpha: 0.75),
                  ),
                ),
              ),
            )
          : child,
    );
  }

  Widget _buildCardContainer({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.canvasColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildMovieSeriesGrid(
    BuildContext context,
    List<Content> items,
    ThemeData theme,
  ) {
    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 5
        : ResponsiveWidget.isTablet(context)
            ? 3
            : 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: crossAxisCount == 1 ? 1.95 : 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final content = items[index];
        final poster = (content.posterUrlList != null &&
                content.posterUrlList!.isNotEmpty)
            ? content.posterUrlList!.first
            : '';
        return _buildPosterCard(
          theme: theme,
          title: content.title ?? 'Untitled',
          subtitle: content.type ?? 'Movie',
          imageUrl: poster,
          viewsText: '${content.views ?? 0}',
          revenueStats: [
            _PosterRevenueStat('Total Revenue', content.totalRevenue),
            _PosterRevenueStat('Admin Revenue', content.adminRevnue),
            _PosterRevenueStat(
              'Production House Revenue',
              content.mediaHouseRevenue,
            ),
          ],
          onTap: () => showMovieDetailsDialog(context, content),
          aspectRatio: 16 / 9,
        );
      },
    );
  }

  Widget _buildShortsGrid(
    BuildContext context,
    List<ShortMaster> items,
    ThemeData theme,
  ) {
    final crossAxisCount = ResponsiveWidget.isDesktop(context)
        ? 6
        : ResponsiveWidget.isTablet(context)
            ? 4
            : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 9 / 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final short = items[index];
        return _buildPosterCard(
          theme: theme,
          title: short.title ?? 'Untitled Short',
          subtitle: short.category ?? 'Shorts',
          imageUrl: short.posterUrl ?? '',
          viewsText: '${short.viewCount ?? 0}',
          revenueStats: [
            _PosterRevenueStat('Total Revenue', short.totalRevenue),
            _PosterRevenueStat('Admin Revenue', short.adminRevenue),
            _PosterRevenueStat(
              'Production House Revenue',
              short.mediaHouseRevenue,
            ),
          ],
          onTap: () => _openShortMasterPage(short),
          aspectRatio: 9 / 16,
        );
      },
    );
  }

  Future<void> _openShortMasterPage(ShortMaster short) async {
    final shortId = short.id;
    if (shortId == null) return;
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ShortMasterPage(shortId: shortId),
      ),
    );
    if (!mounted) return;
    if (deleted == true) {
      await Provider.of<MediaHouseProvider>(context, listen: false)
          .fetchShortsByMediaHouse(widget.mediaHouse.id ?? 0);
    }
  }

  Widget _buildPosterCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String viewsText,
    required VoidCallback onTap,
    required double aspectRatio,
    List<_PosterRevenueStat> revenueStats = const [],
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackPoster(theme),
                    )
                  : _fallbackPoster(theme),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        viewsText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (revenueStats.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: revenueStats
                            .map((stat) => _buildRevenueBadge(stat))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackPoster(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
      child: Icon(Icons.movie_creation_outlined, color: theme.primaryColor),
    );
  }

  Widget _buildRevenueBadge(_PosterRevenueStat stat) {
    final text = '${stat.label}: ${_formatRevenue(stat.value)}';
    return Tooltip(
      message: text,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 190),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatRevenue(dynamic value) {
    if (value == null) return FinancialFormatter.format4(0);
    if (value is num) return FinancialFormatter.format4(value);
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return FinancialFormatter.format4(0);
      final parsed = double.tryParse(trimmed
          .replaceAll(',', '')
          .replaceAll('₹', '')
          .replaceAll('Rs', '')
          .replaceAll('Rs.', '')
          .trim());
      if (parsed != null) return FinancialFormatter.format4(parsed);
      return trimmed;
    }
    return FinancialFormatter.format4(0);
  }
}

enum _ContentMode { movie, shortFilm, series, shorts }

class _MetricAmountHover extends StatefulWidget {
  const _MetricAmountHover({
    required this.value,
    required this.theme,
    this.color,
  });

  final String value;
  final ThemeData theme;
  final Color? color;

  @override
  State<_MetricAmountHover> createState() => _MetricAmountHoverState();
}

class _MetricAmountHoverState extends State<_MetricAmountHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? widget.theme.primaryColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.value,
        waitDuration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: _hovered ? 7 : 0,
            vertical: _hovered ? 3 : 0,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? activeColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: _hovered
                  ? activeColor.withValues(alpha: 0.28)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.value,
            maxLines: _hovered ? 2 : 1,
            overflow: _hovered ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: _hovered,
            style: TextStyle(
              color: activeColor,
              fontSize: _hovered ? 14 : 17,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterRevenueStat {
  const _PosterRevenueStat(this.label, this.value);

  final String label;
  final num? value;
}

class _ProductionContentRevenueRow {
  final String revenueName;
  final int purchaseCount;
  final String firstPurchaseDate;
  final String lastPurchaseDate;
  final double customerPayment;
  final double gstCharges;
  final double baseAmount;
  final double paymentGatewayFees;
  final double netRevenue;
  final double platformRevenue;
  final double productionHouseRevenue;
  final double tax;
  final double paymentGatewayFee2Pct;
  final double finalProductionHouseRevenue;
  final double promoterRevenue;

  _ProductionContentRevenueRow({
    required this.revenueName,
    required this.purchaseCount,
    required this.firstPurchaseDate,
    required this.lastPurchaseDate,
    required this.customerPayment,
    required this.gstCharges,
    required this.baseAmount,
    required this.paymentGatewayFees,
    required this.netRevenue,
    required this.platformRevenue,
    required this.productionHouseRevenue,
    required this.tax,
    required this.paymentGatewayFee2Pct,
    required this.finalProductionHouseRevenue,
    required this.promoterRevenue,
  });
}

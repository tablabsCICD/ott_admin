import 'package:admin_ott/app/core/utils/amount_formatter.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/userProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20user%20page/SignUpPage.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/request/user_request.dart';
import 'package:admin_ott/data/models/response/moviePurchaseByUserResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/user.dart';
import 'package:intl/intl.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  @override
  void initState() {
    super.initState();
    // Fetch users only once when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: _openAddUserForm,
      backgroundColor: theme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Future<void> showUserPromoterDialog(
      BuildContext context, void Function(UserRequest) onAdd) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SignUpPage(onAdd: _onUserPromoter);
      },
    );

    // Refresh the user list if a new user was added successfully
    if (result == true) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    }
  }

  void _openAddUserForm() {
    showUserPromoterDialog(context, _onUserPromoter);
  }

  void _onUserPromoter(UserRequest userRequest) {}

  Widget _buildPage(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<UserProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        // floatingActionButton: _buildFloatingActionButton(selectedThemeData),
        appBar: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          title: Column(
            children: [
              SizedBox(height: 5),
              SizedBox(
                width:
                    ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: TextField(
                  controller: provider.searchController,
                  onChanged: (value) => provider.searchUsers(value),
                  onSubmitted: (value) =>
                      provider.searchUsers(value, immediate: true),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: selectedThemeData.canvasColor,
                    ),
                    suffixIcon: provider.isSearching
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: selectedThemeData.primaryColor,
                              ),
                            ),
                          )
                        : (provider.searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: provider.clearUserSearch,
                                icon: const Icon(Icons.close),
                              )
                            : null),
                    filled: true,
                    fillColor: selectedThemeData.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: selectedThemeData.canvasColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: selectedThemeData.canvasColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: selectedThemeData.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        _getCrossAxisCount(constraints.maxWidth, context);
                    final avatarRadius = crossAxisCount >= 5 ? 46.0 : 38.0;
                    final canGrowWide = crossAxisCount <= 2;

                    if ((provider.isSearching || provider.isLoadingUsers) &&
                        provider.filteredUsers.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: selectedThemeData.primaryColor,
                        ),
                      );
                    }

                    if (provider.filteredUsers.isEmpty) {
                      return Center(
                        child: Text(
                          provider.searchController.text.trim().isEmpty
                              ? 'No users available'
                              : 'No users found',
                          style: TextStyle(
                            color:
                                selectedThemeData.canvasColor.withValues(alpha: 0.75),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        SingleChildScrollView(
                          child: StaggeredGrid.count(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children:
                                List.generate(provider.filteredUsers.length, (index) {
                              final user = provider.filteredUsers[index];
                              final tileSpan = (canGrowWide && index % 3 == 0) ? 2 : 1;
                              final isUpdating =
                                  provider.isUpdatingUserStatus(user.mobileNumber);

                              return StaggeredGridTile.fit(
                                crossAxisCellCount:
                                    tileSpan > crossAxisCount ? 1 : tileSpan,
                                child: _buildUserCard(
                                  user: user,
                                  theme: selectedThemeData,
                                  avatarRadius: avatarRadius,
                                  isUpdatingStatus: isUpdating,
                                  onStatusChanged: (active) async {
                                    final confirmed = await _confirmChangeUserStatus(
                                      user: user,
                                      active: active,
                                      theme: selectedThemeData,
                                    );

                                    if (confirmed && context.mounted) {
                                      provider.changeUserActiveStatus(user, active);
                                    }
                                  },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetailsPage(
                                          user: user,
                                          onRemoveUser: () {
                                            provider.deleteUser(user.id!);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                        if (provider.isLoadingUsers && provider.filteredUsers.isNotEmpty)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              color: selectedThemeData.primaryColor,
                              backgroundColor: selectedThemeData.primaryColor.withValues(alpha: 0.2),
                              minHeight: 3,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildPaginationBar(
                provider,
                selectedThemeData,
                ResponsiveWidget.isMobile(context),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPaginationBar(
    UserProvider provider,
    ThemeData theme,
    bool isMobile,
  ) {
    final isSearching = provider.searchController.text.trim().isNotEmpty;
    final totalItems = isSearching ? provider.filteredUsers.length : provider.totalUsers;
    final totalPages = isSearching ? 1 : provider.totalPages;
    final currentPage = isSearching ? 0 : provider.currentPage;

    final hasPrevious = isSearching ? false : (provider.hasPrevious && currentPage > 0);
    final hasNext = isSearching ? false : (provider.hasNext && currentPage < totalPages - 1);
    final isLoading = provider.isLoadingUsers;

    // Calculate items range: e.g. "Showing 1-20 of 562 users"
    final startItem = totalItems == 0 ? 0 : (currentPage * provider.pageSize) + 1;
    final endItem = isSearching
        ? totalItems
        : ((currentPage * provider.pageSize) + provider.users.length).clamp(0, totalItems);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSearching
                      ? 'Found $totalItems matching users'
                      : 'Showing $startItem-$endItem of $totalItems users',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.canvasColor.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.canvasColor,
                        side: BorderSide(
                          color: hasPrevious
                              ? theme.primaryColor.withValues(alpha: 0.5)
                              : theme.dividerColor.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (!hasPrevious || isLoading)
                          ? null
                          : () => provider.previousPage(),
                      icon: const Icon(Icons.chevron_left, size: 18),
                      label: const Text('Previous', style: TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Page ${currentPage + 1} of $totalPages',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.canvasColor,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.canvasColor,
                        side: BorderSide(
                          color: hasNext
                              ? theme.primaryColor.withValues(alpha: 0.5)
                              : theme.dividerColor.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (!hasNext || isLoading)
                          ? null
                          : () => provider.nextPage(),
                      label: const Text('Next', style: TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.chevron_right, size: 18),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Text(
                  isSearching
                      ? 'Found $totalItems matching users'
                      : 'Showing $startItem-$endItem of $totalItems users',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.canvasColor.withValues(alpha: 0.75),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
                const Spacer(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.canvasColor,
                    side: BorderSide(
                      color: hasPrevious
                          ? theme.primaryColor.withValues(alpha: 0.5)
                          : theme.dividerColor.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (!hasPrevious || isLoading)
                      ? null
                      : () => provider.previousPage(),
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Previous', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.canvasColor,
                    side: BorderSide(
                      color: hasNext
                          ? theme.primaryColor.withValues(alpha: 0.5)
                          : theme.dividerColor.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (!hasNext || isLoading)
                      ? null
                      : () => provider.nextPage(),
                  label: const Text('Next', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  icon: const Icon(Icons.chevron_right, size: 18),
                ),
              ],
            ),
    );
  }

  int _getCrossAxisCount(double width, BuildContext context) {
    if (width >= 1500) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 520) return 2;
    return 1;
  }

  Future<bool> _confirmChangeUserStatus({
    required User user,
    required bool active,
    required ThemeData theme,
  }) async {
    final userName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    final displayName =
        userName.isEmpty ? user.mobileNumber ?? 'this user' : userName;
    final action = active ? 'activate' : 'deactivate';

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              title: Text(
                '${active ? 'Activate' : 'Deactivate'} user?',
                style: TextStyle(color: theme.canvasColor),
              ),
              content: Text(
                'Are you sure you want to $action $displayName?',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.8),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: active ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(active ? 'Activate' : 'Deactivate'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildUserCard({
    required User user,
    required ThemeData theme,
    required double avatarRadius,
    required bool isUpdatingStatus,
    required ValueChanged<bool> onStatusChanged,
    required VoidCallback onTap,
  }) {
    final isActive = user.active ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.canvasColor.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: user.profilePhoto != null
                        ? NetworkImage(user.profilePhoto!)
                        : null,
                    backgroundColor: theme.canvasColor.withValues(alpha: 0.1),
                    radius: avatarRadius,
                    child: user.profilePhoto == null
                        ? Icon(
                            Icons.person,
                            size: avatarRadius,
                            color: theme.canvasColor.withValues(alpha: 0.75),
                          )
                        : null,
                  ),
                  user.verified ?? true
                      ? Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.scaffoldBackgroundColor,
                            ),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 15,
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.canvasColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              _buildUserInfoRow(
                theme: theme,
                icon: Icons.phone_rounded,
                text: user.mobileNumber ?? 'N/A',
              ),
              const SizedBox(height: 6),
              _buildUserInfoRow(
                theme: theme,
                icon: Icons.email_outlined,
                text: user.emailId ?? 'N/A',
              ),
              const SizedBox(height: 6),
              _buildUserInfoRow(
                  theme: theme,
                  icon: Icons.location_on_outlined,
                  text:
                      "${user.location?.taluka != null ? "${user.location?.taluka ?? ""}, " : ""}${user.location?.district != null ? "${user.location?.district ?? ""}, " : ""}${user.location?.state != null ? "${user.location?.state ?? ""}, " : ""}${user.location?.country != null ? "${user.location?.country ?? ""} " : "Unknown Location"}"),
              const SizedBox(height: 6),
              _buildUserInfoRow(
                theme: theme,
                icon: Icons.person_add_alt_1_outlined,
                text: user.refferedBy ?? 'N/A',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isUpdatingStatus)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor,
                      ),
                    )
                  else
                    Switch(
                      value: isActive,
                      activeColor: theme.primaryColor,
                      onChanged: onStatusChanged,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.primaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.canvasColor.withValues(alpha: 0.75),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class UserDetailsPage extends StatefulWidget {
  final User user;
  final Function onRemoveUser;

  const UserDetailsPage({
    super.key,
    required this.user,
    required this.onRemoveUser,
  });

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _contentSearchController =
      TextEditingController();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final userId = widget.user.id;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserProvider>(context, listen: false)
            .fetchUserContent(userId);
      });
    }
  }

  @override
  void dispose() {
    _contentSearchController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    try {
      if (value is int) {
        if (value <= 0) return 'N/A';
        final ms = value < 10000000000 ? value * 1000 : value;
        return DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(ms));
      }
      if (value is String && value.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(value.trim());
        if (parsed != null) {
          return DateFormat('dd MMM yyyy').format(parsed);
        }
        return value;
      }
    } catch (_) {}
    return value.toString();
  }

  void _copyToClipboard(String label, String? text) {
    if (text == null || text.trim().isEmpty || text == 'N/A') {
      CustomToast.show('No $label to copy', isWarning: true);
      return;
    }
    Clipboard.setData(ClipboardData(text: text.trim()));
    CustomToast.show('$label copied to clipboard', isSuccess: true);
  }

  Future<void> _confirmRemoveUser(BuildContext context, ThemeData theme) async {
    final userName =
        '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'.trim();
    final displayName =
        userName.isEmpty ? (widget.user.mobileNumber ?? 'this user') : userName;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delete User',
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete $displayName?',
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This action cannot be undone. All user data, permissions, and purchase records will be permanently removed.',
                    style: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.canvasColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Delete Permanently'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed && context.mounted) {
      final userId = widget.user.id;
      if (userId == null) {
        CustomToast.show('User ID missing. Unable to delete.',
            isSuccess: false);
        return;
      }

      setState(() => _isDeleting = true);
      final provider = Provider.of<UserProvider>(context, listen: false);
      final success = await provider.deleteUser(userId);
      if (mounted) {
        setState(() => _isDeleting = false);
        if (success) {
          widget.onRemoveUser();
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _confirmToggleStatus(
      BuildContext context, ThemeData theme, bool newStatus) async {
    final action = newStatus ? 'activate' : 'deactivate';
    final userName =
        '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'.trim();
    final displayName =
        userName.isEmpty ? (widget.user.mobileNumber ?? 'this user') : userName;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '${newStatus ? 'Activate' : 'Deactivate'} User',
                style: TextStyle(
                  color: theme.canvasColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to $action $displayName?',
                style: TextStyle(
                  color: theme.canvasColor.withValues(alpha: 0.8),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: newStatus ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(newStatus ? 'Activate' : 'Deactivate'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed && context.mounted) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.changeUserActiveStatus(widget.user, newStatus);
      if (mounted) {
        setState(() {
          widget.user.active = newStatus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final userName =
        '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'.trim();
    final title = userName.isEmpty ? 'User Details' : userName;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.canvasColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          title,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.canvasColor),
            tooltip: 'Refresh Data',
            onPressed: () {
              final userId = widget.user.id;
              if (userId != null) {
                Provider.of<UserProvider>(context, listen: false)
                    .fetchUserContent(userId);
              }
            },
          ),
          const SizedBox(width: 4),
          _isDeleting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                  tooltip: 'Delete User',
                  onPressed: () => _confirmRemoveUser(context, theme),
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          final isMobile = ResponsiveWidget.isMobile(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroProfileCard(context, theme, provider),
                const SizedBox(height: 16),
                if (isMobile) ...[
                  _buildUserInfoCard(context, theme),
                  const SizedBox(height: 16),
                  _buildPurchasedContentCard(context, theme, provider),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildUserInfoCard(context, theme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: _buildPurchasedContentCard(
                            context, theme, provider),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroProfileCard(
      BuildContext context, ThemeData theme, UserProvider provider) {
    final user = widget.user;
    final isActive = user.active ?? false;
    final isVerified = user.verified ?? false;
    final isAdmin = (user.role ?? [])
            .any((r) => r.toString().toLowerCase() == 'admin') ||
        (user.admin ?? false);
    final fullName =
        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    final displayName = fullName.isEmpty ? 'Unknown User' : fullName;

    final totalPurchases = provider.userContentList.length;
    final activePurchases =
        provider.userContentList.where((c) => c.active == true).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor:
                        theme.primaryColor.withValues(alpha: 0.15),
                    backgroundImage: (user.profilePhoto != null &&
                            user.profilePhoto!.trim().isNotEmpty)
                        ? NetworkImage(user.profilePhoto!.trim())
                        : null,
                    child: (user.profilePhoto == null ||
                            user.profilePhoto!.trim().isEmpty)
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.canvasColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (user.id != null)
                          _buildPillTag(
                            theme,
                            icon: Icons.tag,
                            label: 'ID: ${user.id}',
                            color: theme.primaryColor,
                          ),
                        if (user.gender != null &&
                            user.gender!.trim().isNotEmpty)
                          _buildPillTag(
                            theme,
                            icon: Icons.person_outline,
                            label: user.gender!,
                            color: Colors.teal,
                          ),
                        if (user.age != null && user.age!.trim().isNotEmpty)
                          _buildPillTag(
                            theme,
                            icon: Icons.cake_outlined,
                            label: '${user.age} yrs',
                            color: Colors.indigo,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.mobileNumber ?? 'No contact number',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.canvasColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isActive ? Colors.green : Colors.red)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Switch(
                    value: isActive,
                    activeColor: theme.primaryColor,
                    onChanged: (val) =>
                        _confirmToggleStatus(context, theme, val),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  theme,
                  icon: Icons.movie_creation_outlined,
                  title: 'Purchased Content',
                  value: '$totalPurchases',
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  theme,
                  icon: Icons.play_circle_outline,
                  title: 'Active Access',
                  value: '$activePurchases',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  theme,
                  icon: Icons.verified_user_outlined,
                  title: 'Verification',
                  value: isVerified ? 'Verified' : 'Unverified',
                  color: isVerified ? Colors.blue : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.canvasColor.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ThemeData theme) {
    final user = widget.user;
    final loc = user.location;
    final locationParts = [
      loc?.taluka,
      loc?.district,
      loc?.state,
      loc?.country,
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
    final fullLocation =
        locationParts.isEmpty ? 'Unknown Location' : locationParts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_rounded,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'User Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            icon: Icons.phone_android_rounded,
            label: 'Mobile Contact',
            value: user.mobileNumber ?? 'N/A',
            onCopy: () => _copyToClipboard('Mobile Number', user.mobileNumber),
          ),
          _buildInfoRow(
            theme,
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: user.emailId ?? 'N/A',
            onCopy: () => _copyToClipboard('Email', user.emailId),
          ),
          _buildInfoRow(
            theme,
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: fullLocation,
            onCopy: () => _copyToClipboard('Location', fullLocation),
          ),
          if (user.refferedBy != null && user.refferedBy!.trim().isNotEmpty)
            _buildInfoRow(
              theme,
              icon: Icons.share_outlined,
              label: 'Referred By',
              value: user.refferedBy!,
              onCopy: () => _copyToClipboard('Referral Code', user.refferedBy),
            ),
          if (user.refferCode != null && user.refferCode!.trim().isNotEmpty)
            _buildInfoRow(
              theme,
              icon: Icons.card_giftcard_outlined,
              label: 'User Referral Code',
              value: user.refferCode!,
              onCopy: () => _copyToClipboard('Referral Code', user.refferCode),
            ),
          _buildInfoRow(
            theme,
            icon: Icons.calendar_today_outlined,
            label: 'Date of Birth',
            value: _formatDate(user.dob),
          ),
          _buildInfoRow(
            theme,
            icon: Icons.how_to_reg_outlined,
            label: 'Registration Date',
            value: _formatDate(user.registrationDate ?? user.joinDate),
          ),
          if (user.osName != null && user.osName!.trim().isNotEmpty)
            _buildInfoRow(
              theme,
              icon: Icons.devices_outlined,
              label: 'Platform / OS',
              value: user.osName!,
            ),
          if (user.deviceName != null && user.deviceName!.trim().isNotEmpty)
            _buildInfoRow(
              theme,
              icon: Icons.smartphone_outlined,
              label: 'Device Name',
              value: user.deviceName!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.canvasColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.canvasColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.canvasColor,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: Icon(Icons.copy_rounded,
                  size: 14,
                  color: theme.canvasColor.withValues(alpha: 0.5)),
              tooltip: 'Copy $label',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }

  Widget _buildPurchasedContentCard(
      BuildContext context, ThemeData theme, UserProvider provider) {
    final list = provider.filtteredUserContentList;
    final total = provider.userContentList.length;
    final available =
        provider.userContentList.where((c) => c.active == true).length;
    final expired =
        provider.userContentList.where((c) => c.active == false).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.video_library_outlined,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Purchased Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: theme.canvasColor),
                tooltip: 'Refresh Content',
                onPressed: () {
                  final userId = widget.user.id;
                  if (userId != null) {
                    provider.fetchUserContent(userId);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search inside content
          TextField(
            controller: _contentSearchController,
            onChanged: (val) => provider.setUserContentSearch(val),
            decoration: InputDecoration(
              hintText: 'Search movies or transaction ID...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: theme.canvasColor.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(Icons.search,
                  size: 18, color: theme.canvasColor.withValues(alpha: 0.6)),
              suffixIcon: _contentSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _contentSearchController.clear();
                        provider.setUserContentSearch('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: theme.canvasColor.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: theme.canvasColor.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  theme,
                  label: 'All ($total)',
                  value: 'All',
                  isSelected: provider.userContentFilterStatus == 'All',
                  onSelected: () => provider.setUserContentFilter('All'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  theme,
                  label: 'Available ($available)',
                  value: 'available',
                  isSelected:
                      provider.userContentFilterStatus.toLowerCase() ==
                          'available',
                  onSelected: () =>
                      provider.setUserContentFilter('available'),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  theme,
                  label: 'Expired ($expired)',
                  value: 'expired',
                  isSelected: provider.userContentFilterStatus.toLowerCase() ==
                      'expired',
                  onSelected: () => provider.setUserContentFilter('expired'),
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content Area
          if (provider.isUserContentLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Loading purchased content...',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.userContentErrorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.userContentErrorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final userId = widget.user.id;
                      if (userId != null) {
                        provider.fetchUserContent(userId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (list.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.movie_filter_outlined,
                      size: 36,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Purchased Content',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.canvasColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _contentSearchController.text.isNotEmpty
                        ? 'No content matches "${_contentSearchController.text}"'
                        : 'This user has not purchased any movies or series yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.canvasColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = list[index];
                return _buildPurchasedContentTile(context, theme, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme, {
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    final activeColor = color ?? theme.primaryColor;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : theme.canvasColor.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? activeColor
                : theme.canvasColor.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasedContentTile(
      BuildContext context, ThemeData theme, UserContent item) {
    final movie = item.movie;
    final isActive = item.active ?? false;
    final title = movie?.title ?? 'Untitled Content';
    final poster = (movie?.posterUrlList != null &&
            movie!.posterUrlList!.isNotEmpty)
        ? movie.posterUrlList!.first
        : (movie?.sensorCertificate ?? movie?.agreementUrl);
    final type = movie?.type ?? 'Movie';
    final price = item.price != null
        ? formatCurrency(item.price, prefix: '₹')
        : 'Free';

    final dateFromStr = _formatDate(item.dateFrom);
    final dateToStr = _formatDate(item.dateTo);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.canvasColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 75,
              color: theme.cardColor,
              child: (poster != null && poster.trim().isNotEmpty)
                  ? Image.network(
                      poster.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.movie_outlined,
                        color: theme.canvasColor.withValues(alpha: 0.5),
                      ),
                    )
                  : Icon(
                      Icons.movie_outlined,
                      color: theme.canvasColor.withValues(alpha: 0.5),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.canvasColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isActive ? Colors.green : Colors.red)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.timer_off,
                            size: 12,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'Available' : 'Expired',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    if (item.isGifted == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'GIFTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 12,
                        color: theme.canvasColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Purchased: $dateFromStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.canvasColor.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.event_busy_outlined,
                        size: 12,
                        color: theme.canvasColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Valid Until: $dateToStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? theme.canvasColor.withValues(alpha: 0.85)
                            : Colors.red.withValues(alpha: 0.8),
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

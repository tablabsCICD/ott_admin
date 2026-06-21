import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/userProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20user%20page/SignUpPage.dart';
import 'package:admin_ott/data/models/request/user_request.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
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
                  onChanged: provider.applySearch,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: selectedThemeData.canvasColor,
                    ),
                    suffixIcon: provider.searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: provider.clearUserSearch,
                            icon: const Icon(Icons.close),
                          )
                        : null,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  _getCrossAxisCount(constraints.maxWidth, context);
              final avatarRadius = crossAxisCount >= 5 ? 46.0 : 38.0;
              final canGrowWide = crossAxisCount <= 2;

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

              return SingleChildScrollView(
                child: StaggeredGrid.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children:
                      List.generate(provider.filteredUsers.length, (index) {
                    final user = provider.filteredUsers[index];
                    final tileSpan = (canGrowWide && index % 3 == 0) ? 2 : 1;

                    return StaggeredGridTile.fit(
                      crossAxisCellCount:
                          tileSpan > crossAxisCount ? 1 : tileSpan,
                      child: _buildUserCard(
                        user: user,
                        theme: selectedThemeData,
                        avatarRadius: avatarRadius,
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
              );
            },
          ),
        ),
      );
    });
  }

  int _getCrossAxisCount(double width, BuildContext context) {
    if (width >= 1500) return 5;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    if (width >= 520) return 2;
    return 1;
  }

  Widget _buildUserCard({
    required User user,
    required ThemeData theme,
    required double avatarRadius,
    required VoidCallback onTap,
  }) {
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
  final Function onRemoveUser; // Callback for removing user

  const UserDetailsPage(
      {super.key, required this.user, required this.onRemoveUser});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String selectedFilter = 'All'; // Default filter
  List<Map<String, dynamic>> content = [];
  List<Map<String, dynamic>> filteredContent = [];

  @override
  void initState() {
    super.initState();
    final userId = widget.user.id;
    if (userId != null) {
      Provider.of<UserProvider>(context, listen: false)
          .fetchUserContent(userId);
    }

    _filterContent();
  }

  void _filterContent() {
    setState(() {
      if (selectedFilter == 'All') {
        filteredContent = content;
      } else {
        filteredContent =
            content.where((c) => c['status'] == selectedFilter).toList();
      }
    });
  }

  void _removeUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Remove'),
        content:
            Text('Are you sure you want to remove ${widget.user.firstName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveUser(); // Trigger the callback
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Navigate back
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        title: Text(widget.user.firstName ?? ""),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _removeUser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: (widget.user.profilePhoto != null &&
                        widget.user.profilePhoto!.isNotEmpty)
                    ? NetworkImage(widget.user.profilePhoto!)
                    : null,
                radius: 60,
                child: (widget.user.profilePhoto == null ||
                        widget.user.profilePhoto!.isEmpty)
                    ? const Icon(Icons.person, size: 56)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'
                      .trim()
                      .isEmpty
                  ? 'Unknown User'
                  : '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'
                      .trim(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Email: ${widget.user.emailId ?? "N/A"}'),
            SizedBox(height: 8),
            Text('Contact: ${widget.user.mobileNumber ?? "N/A"}'),
            SizedBox(height: 8),
            Text(
              'Location: ${widget.user.location?.state ?? "N/A"}, '
              '${widget.user.location?.district ?? "N/A"}, '
              '${widget.user.location?.taluka ?? "N/A"}',
            ),
            SizedBox(height: 8),
            Text('Referred By: ${widget.user.refferedBy ?? "N/A"}'),
            SizedBox(height: 8),
            Text('Join Date: ${widget.user.joinDate ?? "N/A"}'),
            Divider(),
            SizedBox(height: 8),
            // Filter Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchased Content',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(
                        value: 'available', child: Text('Available')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFilter = value;
                        _filterContent();
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            // Content List
            Consumer<UserProvider>(builder: (context, provider, child) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: provider.filtteredUserContentList.length,
                itemBuilder: (context, index) {
                  final item = provider.filtteredUserContentList[index];
                  final dateTo = item.dateTo;
                  final DateTime? dateTime = dateTo != null
                      ? DateTime.fromMillisecondsSinceEpoch(dateTo)
                      : null;

                  // Format the DateTime into a readable string
                  final String formattedDate = dateTime != null
                      ? DateFormat('EEEE, dd MMMM yyyy HH:mm:ss')
                          .format(dateTime)
                      : 'N/A';
                  final isActive = item.active ?? false;
                  return Card(
                    child: ListTile(
                      title: Text(item.movie?.title ?? "Untitled"),
                      subtitle: Text('Expiry Date: $formattedDate'),
                      trailing: Text(
                        isActive ? 'Available' : 'Expired',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _removeUser,
        backgroundColor: Colors.red,
        child: Icon(Icons.delete),
        tooltip: 'Remove User',
      ),*/
    );
  }
}

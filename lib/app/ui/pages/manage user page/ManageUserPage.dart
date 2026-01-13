import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/userProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20user%20page/SignUpPage.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/models/request/user_request.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/user.dart';
import 'package:intl/intl.dart';

class ManageUserPage extends StatefulWidget {
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
    return  _buildPage(context);
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: _openAddUserForm,
      backgroundColor: theme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Future<void> showUserPromoterDialog(BuildContext context, void Function(UserRequest) onAdd) async {
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
    var selectedThemeData = Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Consumer<UserProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        floatingActionButton: _buildFloatingActionButton(selectedThemeData),
        appBar: AppBar(
          toolbarHeight: 60,
          leading: null,
          title: Column(
            children: [
              SizedBox(height: 5),
              SizedBox(
                width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: CustomTextField(
                  controller: provider.searchController,
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  textInputType: TextInputType.text,
                ),
              ),
            ],
          ),
          backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveWidget.isMobile(context) ? 2 : ResponsiveWidget.isTablet(context) ? 3 : 5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: ResponsiveWidget.isMobile(context) ? 2 / 3 : 3 / 4,
            ),
            itemCount: provider.filteredUsers.length,
            itemBuilder: (context, index) {
              final user = provider.filteredUsers[index];
              return GestureDetector(
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
                child: Card(
                  color: selectedThemeData.cardColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                '${user.joinDate}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundImage: user.profilePhoto != null
                                  ? NetworkImage(user.profilePhoto!)
                                  : null,
                              radius: 50,
                              child: user.profilePhoto == null
                                  ? Icon(Icons.person, size: 50)
                                  : null,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${user.firstName} ${user.lastName}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 4),
                            Text(
                              user.mobileNumber ?? "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 4),
                            Text(
                              user.emailId ?? "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Location: ${user.location?.city ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              'Invited by: ${user.refferedBy ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class UserDetailsPage extends StatefulWidget {
  final User user;
  final Function onRemoveUser; // Callback for removing user

  UserDetailsPage({required this.user, required this.onRemoveUser});

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
    Provider.of<UserProvider>(context, listen: false).fetchUserContent(widget.user.id!);

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
                backgroundImage: NetworkImage(widget.user.profilePhoto ?? ""),
                radius: 60,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.user.firstName ?? "",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Email: ${widget.user.emailId ?? ""}'),
            SizedBox(height: 8),
            Text('Contact: ${widget.user.mobileNumber ?? ""}'),
            SizedBox(height: 8),
            Text(
              'Location: ${widget.user.location!.state ?? ""}, '
              '${widget.user.location!.district ?? ""}, '
              '${widget.user.location!.taluka ?? ""}',
            ),
            SizedBox(height: 8),
            Text('Referred By: ${widget.user.refferedBy ?? ""}'),
            SizedBox(height: 8),
            Text('Join Date: ${widget.user.firstName ?? ""}'),
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
    Consumer<UserProvider>(
    builder: (context, provider, child) {
    return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: provider.filtteredUserContentList.length,
                itemBuilder: (context, index) {
                  final item = provider.filtteredUserContentList[index];
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(item.dateTo!);

                  // Format the DateTime into a readable string
                  String formattedDate = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss').format(dateTime);
                  return Card(
                    child: ListTile(
                      title: Text(item.movie!.title??""),
                      subtitle: Text('Expiry Date: ${formattedDate??""}'),
                      trailing: Text(
                        item.active! ? 'Available' : 'Expired',
                        style: TextStyle(
                          color: item.active!
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              );}
            ),
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

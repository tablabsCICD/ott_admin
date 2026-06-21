import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/mediaHouse.dart';
import '../../../../provider/themeProvider.dart';

class MediaHouseProfilePage extends StatefulWidget {
  final MediaHouse? mediaHouse;

  MediaHouseProfilePage({required this.mediaHouse});

  @override
  _MediaHouseProfilePageState createState() => _MediaHouseProfilePageState();
}

class _MediaHouseProfilePageState extends State<MediaHouseProfilePage> {
  String status = "APPROVED";
  bool _isProviderInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ensure the provider is initialized only once
    if (!_isProviderInitialized) {
      Provider.of<MediaHouseProvider>(context, listen: false)
          .setMediaHouse(widget.mediaHouse);
      _isProviderInitialized = true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    await Provider.of<MediaHouseProvider>(context, listen: false)
        .getMediaHouseById(widget.mediaHouse!.id!);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context).getTheme;

    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.mediaHouse!.mediaHouseName}"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                tooltip: 'Delete MediaHouse',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: theme.cardColor,
                        title: Text(
                          'Do you want to delete ${widget.mediaHouse!.mediaHouseName}?',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        actions: [
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.cardColor,
                              foregroundColor: theme.canvasColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              deleteMediaHouse(context);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        body: Consumer<MediaHouseProvider>(builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Responsive layout for Production house details, user info, and admin controls
                ResponsiveWidget.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildMediaHouseInfo(theme, provider)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildUserInfo(theme, provider)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildAdminControls(theme, provider)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMediaHouseInfo(theme, provider),
                          const SizedBox(height: 16),
                          _buildUserInfo(theme, provider),
                          const SizedBox(height: 16),
                          _buildAdminControls(theme, provider),
                        ],
                      ),

                const SizedBox(height: 20),

                // Certificates Section
                Text(
                  "Certificates",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                _buildCertificatesGrid(context, provider),
              ],
            ),
          );
        }));
  }

  void deleteMediaHouse(BuildContext context) {
    Provider.of<MediaHouseProvider>(context, listen: false)
        .deleteMediaHouse(widget.mediaHouse!.id!, context);
  }

  // Other helper methods remain unchanged
  Widget _buildMediaHouseInfo(ThemeData theme, MediaHouseProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: provider.mediaHouse.logo != null
                  ? NetworkImage(provider.mediaHouse.logo!)
                  : const AssetImage('assets/default_profile_pic.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              provider.mediaHouse.mediaHouseName ?? 'Unknown Name',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.mediaHouse.discription ?? 'No description available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onBackground),
            ),
            const SizedBox(height: 8),
            Text(provider.mediaHouse.contactNumber ?? 'Not available.'),
            Text(provider.mediaHouse.email ?? 'Not available.'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, MediaHouseProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("More Details", style: theme.textTheme.bodyLarge),
            const Divider(),
            Text(
                "Contact Person: ${provider.mediaHouse.user?.firstName} ${provider.mediaHouse.user?.lastName}"),
            Text("Email: ${provider.mediaHouse.user?.emailId}"),
            Text("Mobile: ${provider.mediaHouse.user?.mobileNumber}"),
            Text("Country: ${provider.mediaHouse.location?.country}"),
            Text("State: ${provider.mediaHouse.location?.state}"),
            Text("District: ${provider.mediaHouse.location?.district}"),
            Text("Taluka: ${provider.mediaHouse.location?.taluka}"),
            Text("Pincode: ${provider.mediaHouse.location?.pincode}"),
            Row(
              children: [
                Text("Status: "),
                Text(
                  "${provider.mediaHouse.status}",
                  style: TextStyle(
                      color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesGrid(
      BuildContext context, MediaHouseProvider provider) {
    final certificates = [
      {
        "title": "Registration Certificate",
        "url": provider.mediaHouse.registrationCertificate
      },
      {"title": "GST Certificate", "url": provider.mediaHouse.gstCertificates},
      {"title": "Aadhar Card", "url": provider.mediaHouse.adharCard},
      {"title": "Shop Act", "url": provider.mediaHouse.shopAct},
      {"title": "PAN Card", "url": provider.mediaHouse.panCard},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveWidget.isDesktop(context) ? 5 : 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return _buildCertificateTile(
            context, cert["title"]!, cert["url"] ?? "");
      },
    );
  }

  Widget _buildCertificateTile(BuildContext context, String title, String url) {
    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: url.isNotEmpty
                  ? Image.network(url, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminControls(ThemeData theme, MediaHouseProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Controls",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDropdown(theme),
            const SizedBox(height: 16),

            // Elevated Buttons
            ElevatedButton(
              onPressed: () {
                provider.changeMediaHouseStatus(
                    status, provider.mediaHouse.id!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(ThemeData selectedThemeData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 50,
      decoration: BoxDecoration(
        color: selectedThemeData.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey, // Change to any color you want
          width: 1.0, // Adjust thickness
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: selectedThemeData.scaffoldBackgroundColor,
          value: status,
          onChanged: (value) {
            setState(() {
              status = value!;
            });
          },
          icon: Icon(Icons.arrow_drop_down,
              color: selectedThemeData.primaryColor),
          items: [
            _buildDropdownItem('APPROVED', Icons.check_circle, Colors.green,
                'APPROVED', selectedThemeData),
            _buildDropdownItem('PENDING', Icons.hourglass_empty, Colors.orange,
                'PENDING', selectedThemeData),
            _buildDropdownItem('REJECT', Icons.cancel,
                selectedThemeData.primaryColor, 'REJECT', selectedThemeData),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon,
      Color iconColor, String text, ThemeData selectedThemeData) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8.0),
          Text(text, style: TextStyle(color: selectedThemeData.canvasColor)),
        ],
      ),
    );
  }
}

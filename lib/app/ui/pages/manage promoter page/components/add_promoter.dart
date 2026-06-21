import 'dart:async';

import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/models/request/save_promoter_request.dart';
import 'package:admin_ott/data/models/response/reportingPromoterResponse.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPromoterDialog extends StatefulWidget {
  final void Function(SavePromoterRequest) onAdd;

  const AddPromoterDialog({required this.onAdd, super.key});

  @override
  _AddPromoterDialogState createState() => _AddPromoterDialogState();
}

class _AddPromoterDialogState extends State<AddPromoterDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController promoterNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController talukaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController aadharCardController = TextEditingController();
  final TextEditingController panCardController = TextEditingController();
  final TextEditingController accountNumberController =
      TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  final List<String> levels = [
    'National',
    'State',
    'District',
    'Taluka',
  ];

  String selectedLevel = 'National';
  User? _selectedUser;
  PromotersList? _selectedPromoters;
  Timer? _reportingPromoterDebounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    _reportingPromoterDebounce?.cancel();
    nameController.dispose();
    promoterNameController.dispose();
    contactController.dispose();
    emailController.dispose();
    countryController.dispose();
    stateController.dispose();
    districtController.dispose();
    talukaController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    aadharCardController.dispose();
    panCardController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    ifscCodeController.dispose();
    gstController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  void _clearSelectedReportingPromoter() {
    _selectedPromoters = null;
    promoterNameController.clear();
  }

  void _fetchReportingPromoters(PromoterProvider provider) {
    String reportingLevel = '';
    String reportingLocation = '';

    if (selectedLevel == 'State') {
      reportingLevel = 'national';
      reportingLocation = countryController.text.trim();
    } else if (selectedLevel == 'District') {
      reportingLevel = 'state';
      reportingLocation = stateController.text.trim();
    } else if (selectedLevel == 'Taluka') {
      reportingLevel = 'district';
      reportingLocation = districtController.text.trim();
    }

    if (reportingLevel.isEmpty || reportingLocation.isEmpty) {
      return;
    }
    provider.getReportingPromoters(reportingLevel, reportingLocation);
  }

  void _scheduleReportingPromoterFetch(PromoterProvider provider) {
    _reportingPromoterDebounce?.cancel();
    _reportingPromoterDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      _fetchReportingPromoters(provider);
    });
  }

  getUserData() async {
    PromoterProvider userProvider =
        Provider.of<PromoterProvider>(context, listen: false);
    await userProvider.fetchUsers();
    if (userProvider.users.isNotEmpty) {
      _selectedUser =
          userProvider.users.first; // Optional: Set default to the first user
      if (mounted) {
        setState(() {
          nameController.text =
              "${_selectedUser?.firstName ?? ''} ${_selectedUser?.lastName ?? ''}"
                  .trim();
          emailController.text = _selectedUser?.emailId ?? '';
          contactController.text = _selectedUser?.mobileNumber ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    return Consumer<PromoterProvider>(builder: (context, provider, child) {
      return AlertDialog(
        backgroundColor: selectedThemeData.cardColor,
        title: Text(
          'Add New Promoter',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLevel = newValue!;
                      _clearSelectedReportingPromoter();
                    });
                    _scheduleReportingPromoterFetch(provider);
                  },
                  decoration: InputDecoration(
                    labelText: "Select Level",
                    // Add a label for the dropdown
                    labelStyle: selectedThemeData.textTheme.bodyMedium,
                    // Apply text style from theme
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: BorderSide(
                          color: selectedThemeData
                              .dividerColor), // Normal border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: selectedThemeData
                              .dividerColor), // Enabled border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: selectedThemeData.primaryColor,
                          width: 2), // Highlight color
                    ),
                    filled: true,
                    // Enable filled background
                    fillColor: selectedThemeData
                        .cardColor, // Set dropdown background color
                  ),
                  dropdownColor: selectedThemeData.cardColor,
                  // Background color of the dropdown menu
                  items: levels.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: selectedThemeData
                            .textTheme.bodyMedium, // Apply theme's text style
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  controller: countryController,
                  hintText: 'Country',
                  textInputType: TextInputType.name,
                  onValueChange: (String value) {
                    print("Selected location :::::::::::: $value");
                    if (selectedLevel == 'State') {
                      _scheduleReportingPromoterFetch(provider);
                    }
                  },
                ),
                if (selectedLevel == 'State' ||
                    selectedLevel == 'District' ||
                    selectedLevel == 'Taluka')
                  CustomTextField(
                    controller: stateController,
                    hintText: 'State',
                    textInputType: TextInputType.name,
                    onValueChange: (String value) {
                      print("Selected location :::::::::::: $value");
                      if (selectedLevel == 'District') {
                        _scheduleReportingPromoterFetch(provider);
                      }
                    },
                  ),
                if (selectedLevel == 'District' ||
                    selectedLevel == 'Taluka')
                  CustomTextField(
                    controller: districtController,
                    hintText: 'District',
                    textInputType: TextInputType.name,
                    onValueChange: (String value) {
                      print("Selected location :::::::::::: $value");
                      if (selectedLevel == 'Taluka') {
                        _scheduleReportingPromoterFetch(provider);
                      }
                    },
                  ),
                if (selectedLevel == 'Taluka')
                  CustomTextField(
                    controller: talukaController,
                    hintText: 'Taluka',
                    textInputType: TextInputType.name,
                    onValueChange: (String value) {
                      print("Selected location :::::::::::: $value");
                    },
                  ),
                _buildUserDropdownField('Select User', context,
                    provider.users, selectedThemeData),
                CustomTextField(
                  controller: contactController,
                  hintText: 'Contact',
                  textInputType: TextInputType.number,
                ),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  textInputType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  controller: aadharCardController,
                  hintText: 'Aadhaar Card',
                  textInputType: TextInputType.number,
                  isDigits: true,
                ),
                CustomTextField(
                  controller: panCardController,
                  hintText: 'PAN Card',
                  textInputType: TextInputType.text,
                ),
                CustomTextField(
                  controller: bankNameController,
                  hintText: 'Bank Name',
                  textInputType: TextInputType.name,
                ),
                CustomTextField(
                  controller: branchNameController,
                  hintText: 'Branch Name',
                  textInputType: TextInputType.name,
                ),
                CustomTextField(
                  controller: accountNumberController,
                  hintText: 'Account Number',
                  textInputType: TextInputType.number,
                  isDigits: true,
                ),
                CustomTextField(
                  controller: ifscCodeController,
                  hintText: 'IFSC Code',
                  textInputType: TextInputType.text,
                ),
                CustomTextField(
                  controller: gstController,
                  hintText: 'GST Number',
                  textInputType: TextInputType.text,
                ),
                CustomTextField(
                  controller: websiteController,
                  hintText: 'Website',
                  textInputType: TextInputType.url,
                ),
                selectedLevel == "National"
                    ? SizedBox.shrink()
                    : _buildPromoterDropdownField(
                        'Select Reporting Promoter',
                        context,
                        provider.reportingPromoters,
                        selectedThemeData,
                      ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          GestureDetector(
            onTap: () {
              widget.onAdd(SavePromoterRequest(
                aadharCard: aadharCardController.text,
                id: 0,
                active: true,
                area: cityController.text,
                accountNumber: accountNumberController.text,
                access: '',
                bankName: bankNameController.text,
                branchName: branchNameController.text,
                city: cityController.text,
                contactNumber: contactController.text,
                district: districtController.text,
                createdDate: DateTime.now().toString().split(' ')[0],
                country: countryController.text,
                gst: gstController.text,
                ifscCode: ifscCodeController.text,
                level: selectedLevel,
                panCard: panCardController.text,
                pincode: pincodeController.text,
                promoterName: nameController.text,
                refferedBy: _selectedPromoters?.promoterName ?? '',
                registrationCertificate: '',
                role: "PROMOTER",
                state: stateController.text,
                promoterId: _selectedPromoters?.id ?? 0,
                taluka: talukaController.text,
                userId: _selectedUser?.id ?? 0,
                website: websiteController.text,
              ));
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: selectedThemeData.primaryColor,
              ),
              child: Center(
                child: Text(
                  'Add',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildUserDropdownField(
    String label,
    BuildContext context,
    List<User> users,
    ThemeData themeData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<User>(
          value: _selectedUser,
          items: users.map((User user) {
            return DropdownMenuItem<User>(
              value: user,
              child: Text(
                "${user.firstName} ${user.lastName}",
                style:
                    themeData.textTheme.bodyMedium, // Apply theme's text style
              ),
            );
          }).toList(),
          onChanged: (User? selectedUser) {
            setState(() {
              _selectedUser = selectedUser; // Update the selected user
              nameController.text =  _selectedUser!.firstName! + " "+_selectedUser!.lastName!;
              emailController.text = _selectedUser!.emailId!;
              contactController.text = _selectedUser!.mobileNumber!;
            });
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: themeData.textTheme.bodyMedium,
            // Theme's label text style
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              borderSide: BorderSide(
                  color: themeData.dividerColor), // Theme divider color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeData.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: themeData.primaryColor, width: 2), // Highlight color
            ),
          ),
          dropdownColor: themeData.cardColor,
          // Apply theme's card color
          hint: Text(
            "Select a user",
            style: themeData.textTheme.bodySmall, // Theme's hint text style
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPromoterDropdownField(
      String label,
      BuildContext context,
      List<PromotersList> promoters,
      ThemeData themeData,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<PromotersList>(
          value: _selectedPromoters,
          items: promoters.map((PromotersList user) {
            return DropdownMenuItem<PromotersList>(
              value: user,
              child: Text(
                "${user.promoterName}",
                style:
                themeData.textTheme.bodyMedium, // Apply theme's text style
              ),
            );
          }).toList(),
          onChanged: (PromotersList? selectedPromoter) {
            setState(() {
              _selectedPromoters = selectedPromoter; // Update the selected user
            promoterNameController.text = _selectedPromoters!.promoterName!;
            });
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: themeData.textTheme.bodyMedium,
            // Theme's label text style
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              borderSide: BorderSide(
                  color: themeData.dividerColor), // Theme divider color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeData.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: themeData.primaryColor, width: 2), // Highlight color
            ),
          ),
          dropdownColor: themeData.cardColor,
          // Apply theme's card color
          hint: Text(
            "Select Reporting Promoter",
            style: themeData.textTheme.bodySmall, // Theme's hint text style
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Usage example for showing the dialog
void showAddPromoterDialog(
    BuildContext context, void Function(SavePromoterRequest) onAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddPromoterDialog(onAdd: onAdd);
    },
  );
}

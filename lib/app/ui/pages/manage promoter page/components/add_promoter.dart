import 'dart:async';
import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/models/request/save_promoter_request.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:admin_ott/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPromoterDialog extends StatefulWidget {
  final void Function(SavePromoterRequest) onAdd;

  const AddPromoterDialog({required this.onAdd, super.key});

  @override
  State<AddPromoterDialog> createState() => _AddPromoterDialogState();
}

class _AddPromoterDialogState extends State<AddPromoterDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController =
      TextEditingController(text: 'India');
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
  Promoters? _selectedParentPromoter;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
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

  Future<void> getUserData() async {
    final userProvider = Provider.of<PromoterProvider>(context, listen: false);
    await userProvider.fetchUsers();
    if (userProvider.users.isNotEmpty && mounted) {
      setState(() {
        _selectedUser = userProvider.users.first;
        _populateFromUser(_selectedUser!);
      });
    }
  }

  void _populateFromUser(User user) {
    nameController.text = '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim();
    emailController.text = user.emailId ?? '';
    contactController.text = user.mobileNumber ?? '';
    if (user.location != null) {
      if (user.location!.country != null) countryController.text = user.location!.country!;
      if (user.location!.state != null) stateController.text = user.location!.state!;
      if (user.location!.district != null) districtController.text = user.location!.district!;
      if (user.location!.taluka != null) talukaController.text = user.location!.taluka!;
      if (user.location!.city != null) cityController.text = user.location!.city!;
      if (user.location!.pincode != null) pincodeController.text = user.location!.pincode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    // Filter parent promoter candidates
    final parentCandidates = provider.promoterList.where((p) {
      if (selectedLevel == 'State') {
        return p.normalizedLevel == 'National';
      } else if (selectedLevel == 'District') {
        final stateMatch = stateController.text.trim().isEmpty ||
            (p.location?.state ?? p.userId?.location?.state ?? '').toLowerCase() ==
                stateController.text.trim().toLowerCase();
        return p.normalizedLevel == 'State' && stateMatch;
      } else if (selectedLevel == 'Taluka') {
        final districtMatch = districtController.text.trim().isEmpty ||
            (p.location?.district ?? p.userId?.location?.district ?? '').toLowerCase() ==
                districtController.text.trim().toLowerCase();
        return p.normalizedLevel == 'District' && districtMatch;
      }
      return false;
    }).toList();

    return AlertDialog(
      backgroundColor: selectedThemeData.cardColor,
      title: Row(
        children: [
          Icon(Icons.person_add, color: selectedThemeData.primaryColor, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Add New Promoter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionHeader('1. Promoter Level & Hierarchy', selectedThemeData),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedLevel,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLevel = newValue;
                      _selectedParentPromoter = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Select Promoter Level',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: selectedThemeData.scaffoldBackgroundColor,
                ),
                dropdownColor: selectedThemeData.cardColor,
                items: levels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value Level Promoter'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Geography Inputs
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: countryController,
                      hintText: 'Country',
                      textInputType: TextInputType.name,
                    ),
                  ),
                  if (selectedLevel == 'State' || selectedLevel == 'District' || selectedLevel == 'Taluka') ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: stateController,
                        hintText: 'State (e.g. Maharashtra)',
                        textInputType: TextInputType.name,
                        onValueChange: (val) => setState(() {}),
                      ),
                    ),
                  ],
                ],
              ),
              if (selectedLevel == 'District' || selectedLevel == 'Taluka') ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: districtController,
                        hintText: 'District (e.g. Pune)',
                        textInputType: TextInputType.name,
                        onValueChange: (val) => setState(() {}),
                      ),
                    ),
                    if (selectedLevel == 'Taluka') ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          controller: talukaController,
                          hintText: 'Taluka (e.g. Haveli)',
                          textInputType: TextInputType.name,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: cityController,
                      hintText: 'City / Area',
                      textInputType: TextInputType.name,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: pincodeController,
                      hintText: 'Pincode',
                      textInputType: TextInputType.number,
                      isDigits: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Required Parent Selection
              if (selectedLevel != 'National') ...[
                DropdownButtonFormField<Promoters>(
                  initialValue: _selectedParentPromoter,
                  onChanged: (Promoters? p) {
                    setState(() {
                      _selectedParentPromoter = p;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Reporting Parent (${_getParentLevelName(selectedLevel)})',
                    hintText: parentCandidates.isEmpty
                        ? 'No ${_getParentLevelName(selectedLevel)} available. Add parent first or proceed.'
                        : 'Select parent promoter',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: selectedThemeData.scaffoldBackgroundColor,
                  ),
                  dropdownColor: selectedThemeData.cardColor,
                  items: parentCandidates.map((p) {
                    return DropdownMenuItem<Promoters>(
                      value: p,
                      child: Text('${p.promoterName ?? "Promoter"} (${p.normalizedLevel} - ${p.location?.state ?? "India"})'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              _buildSectionHeader('2. Link User Account & Contact Info', selectedThemeData),
              const SizedBox(height: 10),
              _buildUserDropdownField(
                'Select Registered User',
                context,
                provider.users,
                selectedThemeData,
              ),
              CustomTextField(
                controller: nameController,
                hintText: 'Promoter Display Name',
                textInputType: TextInputType.name,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: contactController,
                      hintText: 'Contact Mobile Number',
                      textInputType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: emailController,
                      hintText: 'Email Address',
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('3. Bank & KYC Verification Details', selectedThemeData),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: bankNameController,
                      hintText: 'Bank Name',
                      textInputType: TextInputType.name,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: branchNameController,
                      hintText: 'Branch Name',
                      textInputType: TextInputType.name,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: accountNumberController,
                      hintText: 'Bank Account Number',
                      textInputType: TextInputType.number,
                      isDigits: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: ifscCodeController,
                      hintText: 'IFSC Code',
                      textInputType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: panCardController,
                      hintText: 'PAN Card Number',
                      textInputType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: aadharCardController,
                      hintText: 'Aadhaar Card Number',
                      textInputType: TextInputType.number,
                      isDigits: true,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: gstController,
                      hintText: 'GST Number (Optional)',
                      textInputType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: websiteController,
                      hintText: 'Website URL (Optional)',
                      textInputType: TextInputType.url,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedThemeData.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter promoter name'), backgroundColor: Colors.red),
              );
              return;
            }

            widget.onAdd(SavePromoterRequest(
              aadharCard: aadharCardController.text.trim(),
              id: 0,
              active: true,
              area: cityController.text.trim(),
              accountNumber: accountNumberController.text.trim(),
              access: '',
              bankName: bankNameController.text.trim(),
              branchName: branchNameController.text.trim(),
              city: cityController.text.trim(),
              contactNumber: contactController.text.trim(),
              district: districtController.text.trim(),
              createdDate: DateTime.now().toString().split(' ')[0],
              country: countryController.text.trim().isNotEmpty ? countryController.text.trim() : 'India',
              gst: gstController.text.trim(),
              ifscCode: ifscCodeController.text.trim(),
              level: selectedLevel,
              panCard: panCardController.text.trim(),
              pincode: pincodeController.text.trim(),
              promoterName: nameController.text.trim(),
              refferedBy: _selectedParentPromoter?.promoterName ?? '',
              registrationCertificate: '',
              role: "PROMOTER",
              state: stateController.text.trim(),
              promoterId: _selectedParentPromoter?.id ?? 0,
              taluka: talukaController.text.trim(),
              userId: _selectedUser?.id ?? 0,
              website: websiteController.text.trim(),
            ));
            Navigator.pop(context);
          },
          child: const Text('Create Promoter'),
        ),
      ],
    );
  }

  String _getParentLevelName(String level) {
    switch (level) {
      case 'State':
        return 'National';
      case 'District':
        return 'State';
      case 'Taluka':
        return 'District';
      default:
        return 'Reporting';
    }
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const Divider(),
      ],
    );
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
        DropdownButtonFormField<User>(
          initialValue: _selectedUser,
          items: users.map((User user) {
            return DropdownMenuItem<User>(
              value: user,
              child: Text(
                "${user.firstName ?? ''} ${user.lastName ?? ''} (${user.emailId ?? user.mobileNumber ?? ''})",
                style: themeData.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (User? selectedUser) {
            if (selectedUser != null) {
              setState(() {
                _selectedUser = selectedUser;
                _populateFromUser(selectedUser);
              });
            }
          },
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: themeData.scaffoldBackgroundColor,
          ),
          dropdownColor: themeData.cardColor,
          hint: Text("Select a registered user", style: themeData.textTheme.bodySmall),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

void showAddPromoterDialog(
    BuildContext context, void Function(SavePromoterRequest) onAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddPromoterDialog(onAdd: onAdd);
    },
  );
}

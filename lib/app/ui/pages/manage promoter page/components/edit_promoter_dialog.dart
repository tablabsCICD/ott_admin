import 'package:admin_ott/app/provider/promoterProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/data/models/request/save_promoter_request.dart';
import 'package:admin_ott/domain/entities/promoter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPromoterDialog extends StatefulWidget {
  final Promoters promoter;
  final VoidCallback? onUpdated;

  const EditPromoterDialog({
    super.key,
    required this.promoter,
    this.onUpdated,
  });

  @override
  State<EditPromoterDialog> createState() => _EditPromoterDialogState();
}

class _EditPromoterDialogState extends State<EditPromoterDialog> {
  late final TextEditingController nameController;
  late final TextEditingController contactController;
  late final TextEditingController emailController;
  late final TextEditingController countryController;
  late final TextEditingController stateController;
  late final TextEditingController districtController;
  late final TextEditingController talukaController;
  late final TextEditingController cityController;
  late final TextEditingController pincodeController;
  late final TextEditingController aadharCardController;
  late final TextEditingController panCardController;
  late final TextEditingController accountNumberController;
  late final TextEditingController bankNameController;
  late final TextEditingController branchNameController;
  late final TextEditingController ifscCodeController;
  late final TextEditingController gstController;
  late final TextEditingController websiteController;
  late final TextEditingController parentNameController;

  late String selectedLevel;
  late String selectedStatus;
  Promoters? selectedParent;

  final List<String> levels = ['National', 'State', 'District', 'Taluka'];
  final List<String> statuses = ['Active', 'Inactive', 'Suspended'];

  @override
  void initState() {
    super.initState();
    final p = widget.promoter;
    final loc = p.location ?? p.userId?.location;

    nameController = TextEditingController(text: p.promoterName ?? '');
    contactController = TextEditingController(text: p.contactNumber ?? p.userId?.mobileNumber ?? '');
    emailController = TextEditingController(text: p.userId?.emailId ?? '');
    countryController = TextEditingController(text: loc?.country ?? 'India');
    stateController = TextEditingController(text: loc?.state ?? '');
    districtController = TextEditingController(text: loc?.district ?? '');
    talukaController = TextEditingController(text: loc?.taluka ?? '');
    cityController = TextEditingController(text: loc?.city ?? loc?.area ?? '');
    pincodeController = TextEditingController(text: p.pincode ?? loc?.pincode ?? '');
    aadharCardController = TextEditingController(text: p.aadharCard ?? '');
    panCardController = TextEditingController(text: p.panCard ?? '');
    accountNumberController = TextEditingController(text: p.accountNumber ?? '');
    bankNameController = TextEditingController(text: p.bankName ?? '');
    branchNameController = TextEditingController(text: p.branchName ?? '');
    ifscCodeController = TextEditingController(text: p.ifscCode ?? '');
    gstController = TextEditingController(text: p.gst ?? '');
    websiteController = TextEditingController(text: p.website ?? '');
    parentNameController = TextEditingController(text: p.refferedBy ?? '');

    selectedLevel = p.normalizedLevel;
    selectedStatus = p.displayStatus;
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
    parentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = Provider.of<PromoterProvider>(context);

    // Filter available parent candidates
    final parentCandidates = provider.promoterList.where((p) {
      if (p.id == widget.promoter.id) return false;
      if (selectedLevel == 'State') return p.normalizedLevel == 'National';
      if (selectedLevel == 'District') return p.normalizedLevel == 'State';
      if (selectedLevel == 'Taluka') return p.normalizedLevel == 'District';
      return false;
    }).toList();

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(Icons.edit_note, color: theme.primaryColor, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Edit Promoter Details',
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
              _buildSectionHeader('Promoter Level & Hierarchy', theme),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedLevel,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedLevel = newValue;
                            selectedParent = null;
                            parentNameController.clear();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Promoter Level',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                      dropdownColor: theme.cardColor,
                      items: levels.map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl))).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                      ),
                      dropdownColor: theme.cardColor,
                      items: statuses.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                    ),
                  ),
                ],
              ),
              if (selectedLevel != 'National') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<Promoters>(
                  initialValue: selectedParent,
                  onChanged: (Promoters? parent) {
                    setState(() {
                      selectedParent = parent;
                      if (parent != null) {
                        parentNameController.text = parent.promoterName ?? '';
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Reporting / Parent Promoter',
                    hintText: 'Select parent promoter',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                  dropdownColor: theme.cardColor,
                  items: parentCandidates.map((p) {
                    return DropdownMenuItem<Promoters>(
                      value: p,
                      child: Text('${p.promoterName ?? "Unknown"} (${p.normalizedLevel} - ${p.location?.state ?? "India"})'),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),

              _buildSectionHeader('Personal & Contact Details', theme),
              const SizedBox(height: 10),
              CustomTextField(controller: nameController, hintText: 'Promoter Full Name', textInputType: TextInputType.name),
              CustomTextField(controller: contactController, hintText: 'Contact Mobile Number', textInputType: TextInputType.phone),
              CustomTextField(controller: emailController, hintText: 'Email Address', textInputType: TextInputType.emailAddress),
              const SizedBox(height: 20),

              _buildSectionHeader('Geographical Location', theme),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: countryController, hintText: 'Country', textInputType: TextInputType.name)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: stateController, hintText: 'State', textInputType: TextInputType.name)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: districtController, hintText: 'District', textInputType: TextInputType.name)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: talukaController, hintText: 'Taluka', textInputType: TextInputType.name)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: cityController, hintText: 'City / Area', textInputType: TextInputType.name)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: pincodeController, hintText: 'Pincode', textInputType: TextInputType.number, isDigits: true)),
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Bank & KYC Details', theme),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: bankNameController, hintText: 'Bank Name', textInputType: TextInputType.name)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: branchNameController, hintText: 'Branch Name', textInputType: TextInputType.name)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: accountNumberController, hintText: 'Account Number', textInputType: TextInputType.number, isDigits: true)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: ifscCodeController, hintText: 'IFSC Code', textInputType: TextInputType.text)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: panCardController, hintText: 'PAN Card Number', textInputType: TextInputType.text)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: aadharCardController, hintText: 'Aadhaar Card Number', textInputType: TextInputType.number, isDigits: true)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: gstController, hintText: 'GST Number', textInputType: TextInputType.text)),
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(controller: websiteController, hintText: 'Website URL', textInputType: TextInputType.url)),
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
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () async {
            final parentId = selectedParent?.id ?? widget.promoter.promoterId;
            final parentName = selectedParent?.promoterName ?? parentNameController.text.trim();

            final error = provider.validateHierarchyChange(
              promoter: widget.promoter,
              newLevel: selectedLevel,
              newParentId: selectedLevel == 'National' ? null : (parentId is int ? parentId : int.tryParse(parentId?.toString() ?? '')),
              newParentName: parentName,
            );

            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error), backgroundColor: Colors.red),
              );
              return;
            }

            final request = SavePromoterRequest(
              id: widget.promoter.id,
              promoterName: nameController.text.trim(),
              level: selectedLevel,
              contactNumber: contactController.text.trim(),
              country: countryController.text.trim(),
              state: stateController.text.trim(),
              district: districtController.text.trim(),
              taluka: talukaController.text.trim(),
              city: cityController.text.trim(),
              area: cityController.text.trim(),
              pincode: pincodeController.text.trim(),
              bankName: bankNameController.text.trim(),
              branchName: branchNameController.text.trim(),
              accountNumber: accountNumberController.text.trim(),
              ifscCode: ifscCodeController.text.trim(),
              panCard: panCardController.text.trim(),
              aadharCard: aadharCardController.text.trim(),
              gst: gstController.text.trim(),
              website: websiteController.text.trim(),
              refferedBy: parentName,
              promoterId: selectedLevel == 'National' ? 0 : (parentId is int ? parentId : int.tryParse(parentId?.toString() ?? '') ?? 0),
              active: selectedStatus == 'Active',
              role: widget.promoter.role ?? 'PROMOTER',
              userId: widget.promoter.userId?.id,
              createdDate: widget.promoter.createdDate,
            );

            final success = await provider.updatePromoterDetails(request);
            if (success && context.mounted) {
              Navigator.pop(context);
              widget.onUpdated?.call();
            }
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
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
}

void showEditPromoterDialog(BuildContext context, Promoters promoter, {VoidCallback? onUpdated}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => EditPromoterDialog(promoter: promoter, onUpdated: onUpdated),
  );
}

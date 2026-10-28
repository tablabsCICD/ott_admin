import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/core/loading/app_loading_controller.dart';
import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';

class EditMediaHouseDialog extends StatefulWidget {
  final MediaHouse mediaHouse;

  const EditMediaHouseDialog({
    super.key,
    required this.mediaHouse,
  });

  static Future<bool?> show(BuildContext context, MediaHouse mediaHouse) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditMediaHouseDialog(mediaHouse: mediaHouse),
    );
  }

  @override
  State<EditMediaHouseDialog> createState() => _EditMediaHouseDialogState();
}

class _EditMediaHouseDialogState extends State<EditMediaHouseDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Uint8List> _localPreviewBytes = {};
  final Map<String, String> _localFileNames = {};
  final Set<String> _uploadingFields = {};

  bool _active = true;
  String _status = 'ACTIVE';
  bool _isSubmitting = false;

  static const List<String> _firmTypeOptions = [
    'Private Limited',
    'LLP',
    'Partnership',
    'Proprietory',
    'Other',
  ];

  static const List<String> _designationOptions = [
    'Owner',
    'Director',
    'CEO',
    'Manager',
    'Authorized Signatory',
    'Other',
  ];

  static const List<String> _statusOptions = [
    'ACTIVE',
    'APPROVED',
    'PENDING',
    'REJECTED',
    'INACTIVE',
  ];

  static const List<String> _countryOptions = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'United Arab Emirates',
    'Germany',
    'France',
    'Japan',
    'Singapore',
  ];

  static const List<String> _indiaStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _populateInitialData();
  }

  void _populateInitialData() {
    final h = widget.mediaHouse;
    final loc = h.location;
    final user = h.user;

    _active = h.active ?? true;
    _status = (h.status ?? (_active ? 'ACTIVE' : 'INACTIVE')).toUpperCase();

    // Tab 1: Basic Details
    _controllers['mediaHouseName'] =
        TextEditingController(text: h.mediaHouseName ?? '');
    _controllers['firmType'] =
        TextEditingController(text: h.firmType?.toString() ?? 'Private Limited');
    _controllers['designation'] =
        TextEditingController(text: h.designation ?? 'Owner');
    _controllers['discription'] =
        TextEditingController(text: h.discription?.toString() ?? '');

    // Tab 2: Address & Location
    _controllers['country'] =
        TextEditingController(text: h.country ?? loc?.country ?? 'India');
    _controllers['state'] =
        TextEditingController(text: h.state ?? loc?.state ?? 'Maharashtra');
    _controllers['district'] =
        TextEditingController(text: h.district ?? loc?.district ?? '');
    _controllers['city'] =
        TextEditingController(text: h.city ?? loc?.city ?? '');
    _controllers['taluka'] =
        TextEditingController(text: h.taluka ?? loc?.taluka ?? '');
    _controllers['officeBuilding'] =
        TextEditingController(text: h.officeBuilding ?? loc?.officeBuilding ?? '');
    _controllers['area'] =
        TextEditingController(text: h.area ?? loc?.area ?? '');
    _controllers['pincode'] =
        TextEditingController(text: h.pincode ?? loc?.pincode ?? '');
    _controllers['address'] =
        TextEditingController(text: h.address ?? '');

    // Tab 3: Bank & Documents
    _controllers['accountHolderName'] =
        TextEditingController(text: h.accountHolderName?.toString() ?? '');
    _controllers['bankName'] =
        TextEditingController(text: h.bankName?.toString() ?? '');
    _controllers['bankAccountNumber'] =
        TextEditingController(text: h.bankAccountNumber?.toString() ?? '');
    _controllers['bankIFSCNumber'] =
        TextEditingController(text: h.bankIfscNumber?.toString() ?? '');
    _controllers['adharCard'] =
        TextEditingController(text: h.adharCard ?? '');
    _controllers['panCard'] =
        TextEditingController(text: h.panCard ?? '');
    _controllers['gstCertificates'] =
        TextEditingController(text: h.gstCertificates ?? '');
    _controllers['registrationCertificate'] =
        TextEditingController(text: h.registrationCertificate ?? '');
    _controllers['shopAct'] =
        TextEditingController(text: h.shopAct?.toString() ?? '');
    _controllers['bankProof'] =
        TextEditingController(text: h.bankProof ?? '');
    _controllers['addressProof'] =
        TextEditingController(text: h.addressProof ?? '');

    // Tab 4: Contact Details
    _controllers['email'] =
        TextEditingController(text: h.email ?? user?.emailId ?? '');
    _controllers['emailId'] =
        TextEditingController(text: user?.emailId ?? h.email ?? '');
    _controllers['contactNumber'] =
        TextEditingController(text: h.contactNumber ?? user?.mobileNumber ?? '');
    _controllers['mobileNumber'] =
        TextEditingController(text: user?.mobileNumber ?? h.contactNumber ?? '');
    _controllers['refferedBy'] =
        TextEditingController(text: '');
    _controllers['directorName'] =
        TextEditingController(text: '');
    _controllers['directorEmail'] =
        TextEditingController(text: '');
    _controllers['directorMobile'] =
        TextEditingController(text: '');
    _controllers['ceoName'] =
        TextEditingController(text: '');
    _controllers['ceoEmail'] =
        TextEditingController(text: '');
    _controllers['ceoMobile'] =
        TextEditingController(text: '');

    // Tab 5: Branding
    _controllers['logo'] =
        TextEditingController(text: h.logo?.toString() ?? '');
    final posterVal = h.profileImage?.toString() ?? '';
    _controllers['profileImage'] =
        TextEditingController(text: posterVal);
    _controllers['poster'] =
        TextEditingController(text: posterVal);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in Set.from(_controllers.values)) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _c(String key) {
    if (key == 'poster') return _controllers['profileImage'] ??= TextEditingController();
    return _controllers[key] ??= TextEditingController();
  }

  Future<void> _pickAndUploadDocument(String key, String label) async {
    final isImageField = key == 'logo' || key == 'profileImage' || key == 'poster';

    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = isImageField
          ? 'image/*'
          : 'image/*,.pdf,.doc,.docx,application/pdf';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        if (uploadInput.files == null || uploadInput.files!.isEmpty) return;
        final file = uploadInput.files!.first;

        try {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoad.first;
          final bytes = Uint8List.fromList(reader.result as List<int>);

          if (!mounted) return;
          // Immediately update preview state so the selected image/document is visible right away!
          setState(() {
            _localPreviewBytes[key] = bytes;
            _localFileNames[key] = file.name;
            _uploadingFields.add(key);
          });

          // Upload specifically for this field
          final uploadedUrl = await _performUpload(
            bytes: bytes,
            fileName: file.name,
            label: label,
          );

          if (!mounted) return;
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            setState(() {
              _c(key).text = uploadedUrl;
              if (key == 'profileImage') _c('poster').text = uploadedUrl;
              if (key == 'poster') _c('profileImage').text = uploadedUrl;
            });
            CustomToast.show('$label uploaded successfully', isSuccess: true);
          }
        } catch (e) {
          debugPrint('Upload error for $label: $e');
          if (mounted) {
            CustomToast.show('Failed to upload $label: $e', isSuccess: false);
          }
        } finally {
          if (mounted) {
            setState(() => _uploadingFields.remove(key));
          }
        }
      });
    } else {
      // Mobile & Desktop platforms
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) return; // User cancelled, keep existing file intact

        final bytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        setState(() {
          _localPreviewBytes[key] = bytes;
          _localFileNames[key] = pickedFile.name;
          _uploadingFields.add(key);
        });

        final uploadedUrl = await _performUpload(
          bytes: bytes,
          fileName: pickedFile.name,
          label: label,
        );

        if (!mounted) return;
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          setState(() {
            _c(key).text = uploadedUrl;
            if (key == 'profileImage') _c('poster').text = uploadedUrl;
            if (key == 'poster') _c('profileImage').text = uploadedUrl;
          });
          CustomToast.show('$label uploaded successfully', isSuccess: true);
        }
      } catch (e) {
        debugPrint('Upload error for $label: $e');
        if (mounted) {
          CustomToast.show('Failed to upload $label: $e', isSuccess: false);
        }
      } finally {
        if (mounted) {
          setState(() => _uploadingFields.remove(key));
        }
      }
    }
  }

  Future<String?> _performUpload({
    required Uint8List bytes,
    required String fileName,
    required String label,
  }) async {
    final url = Uri.parse(ApiConstant.uploadImg);
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(await ApiHelper().multipartHeaders());
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    ));

    final streamedResponse =
        await AppLoadingController.trackFuture(() => request.send());

    if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
      final responseBody = await streamedResponse.stream.bytesToString();
      return _parseUploadedUrl(responseBody);
    } else {
      throw Exception('Server returned status ${streamedResponse.statusCode}');
    }
  }

  String? _parseUploadedUrl(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is String) return _cleanUrl(decoded);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is String && data.isNotEmpty) return _cleanUrl(data);
        if (data is Map<String, dynamic>) {
          final candidate = data['fileUrl'] ??
              data['url'] ??
              data['imageUrl'] ??
              data['path'] ??
              data['filePath'];
          if (candidate != null) return _cleanUrl(candidate.toString());
        }
        final topCandidate = decoded['fileUrl'] ??
            decoded['url'] ??
            decoded['imageUrl'] ??
            decoded['path'] ??
            decoded['filePath'] ??
            decoded['message'];
        if (topCandidate != null) return _cleanUrl(topCandidate.toString());
      }
    } catch (e) {
      debugPrint('Error parsing uploaded URL: $e');
    }
    return _cleanUrl(responseBody);
  }

  String _cleanUrl(String raw) {
    var trimmed = raw.trim();
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      trimmed = trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  Future<void> _handleSave() async {
    setState(() => _isSubmitting = true);

    final orig = widget.mediaHouse;

    // Construct the complete updated entity preserving all original and unchanged fields
    final updatedHouse = orig.copyWith(
      id: orig.id,
      userId: orig.userId ?? orig.user?.id,
      mediaHouseName: _c('mediaHouseName').text.trim().isNotEmpty
          ? _c('mediaHouseName').text.trim()
          : orig.mediaHouseName,
      firmType: _c('firmType').text.trim().isNotEmpty
          ? _c('firmType').text.trim()
          : orig.firmType,
      designation: _c('designation').text.trim().isNotEmpty
          ? _c('designation').text.trim()
          : orig.designation,
      discription: _c('discription').text.trim().isNotEmpty
          ? _c('discription').text.trim()
          : orig.discription,
      status: _status,
      active: _active,
      contactNumber: _c('contactNumber').text.trim().isNotEmpty
          ? _c('contactNumber').text.trim()
          : orig.contactNumber,
      email: _c('email').text.trim().isNotEmpty
          ? _c('email').text.trim()
          : orig.email,
      officeBuilding: _c('officeBuilding').text.trim().isNotEmpty
          ? _c('officeBuilding').text.trim()
          : orig.officeBuilding,
      address: _c('address').text.trim().isNotEmpty
          ? _c('address').text.trim()
          : orig.address,
      area: _c('area').text.trim().isNotEmpty
          ? _c('area').text.trim()
          : orig.area,
      city: _c('city').text.trim().isNotEmpty
          ? _c('city').text.trim()
          : orig.city,
      district: _c('district').text.trim().isNotEmpty
          ? _c('district').text.trim()
          : orig.district,
      taluka: _c('taluka').text.trim().isNotEmpty
          ? _c('taluka').text.trim()
          : orig.taluka,
      state: _c('state').text.trim().isNotEmpty
          ? _c('state').text.trim()
          : orig.state,
      country: _c('country').text.trim().isNotEmpty
          ? _c('country').text.trim()
          : orig.country,
      pincode: _c('pincode').text.trim().isNotEmpty
          ? _c('pincode').text.trim()
          : orig.pincode,
      accountHolderName: _c('accountHolderName').text.trim().isNotEmpty
          ? _c('accountHolderName').text.trim()
          : orig.accountHolderName,
      bankName: _c('bankName').text.trim().isNotEmpty
          ? _c('bankName').text.trim()
          : orig.bankName,
      bankAccountNumber: _c('bankAccountNumber').text.trim().isNotEmpty
          ? _c('bankAccountNumber').text.trim()
          : orig.bankAccountNumber,
      bankIfscNumber: _c('bankIFSCNumber').text.trim().isNotEmpty
          ? _c('bankIFSCNumber').text.trim()
          : orig.bankIfscNumber,
      adharCard: _c('adharCard').text.trim().isNotEmpty
          ? _c('adharCard').text.trim()
          : orig.adharCard,
      panCard: _c('panCard').text.trim().isNotEmpty
          ? _c('panCard').text.trim()
          : orig.panCard,
      gstCertificates: _c('gstCertificates').text.trim().isNotEmpty
          ? _c('gstCertificates').text.trim()
          : orig.gstCertificates,
      registrationCertificate: _c('registrationCertificate').text.trim().isNotEmpty
          ? _c('registrationCertificate').text.trim()
          : orig.registrationCertificate,
      shopAct: _c('shopAct').text.trim().isNotEmpty
          ? _c('shopAct').text.trim()
          : orig.shopAct,
      bankProof: _c('bankProof').text.trim().isNotEmpty
          ? _c('bankProof').text.trim()
          : orig.bankProof,
      addressProof: _c('addressProof').text.trim().isNotEmpty
          ? _c('addressProof').text.trim()
          : orig.addressProof,
      logo: _c('logo').text.trim().isNotEmpty
          ? _c('logo').text.trim()
          : orig.logo,
      profileImage: _c('profileImage').text.trim().isNotEmpty
          ? _c('profileImage').text.trim()
          : orig.profileImage,
      // Preserved fields
      password: orig.password,
      joinDate: orig.joinDate,
      createdDate: orig.createdDate,
      postCount: orig.postCount,
      totalReveneu: orig.totalReveneu,
      totalViews: orig.totalViews,
      adminRevnue: orig.adminRevnue,
      mediaHouseRevenue: orig.mediaHouseRevenue,
      totalRevenue: orig.totalRevenue,
      updatedDate: DateTime.now().toUtc().toIso8601String(),
    );

    final provider = Provider.of<MediaHouseProvider>(context, listen: false);
    final success = await provider.updateMediaHouse(updatedHouse);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.getTheme;
    final isMobile = ResponsiveWidget.isMobile(context);
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.96
        : 760.0;
    final dialogHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.92
        : 720.0;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.25),
        ),
      ),
      insetPadding: EdgeInsets.all(isMobile ? 10 : 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogHeight,
        ),
        child: Column(
          children: [
            // Header Card matching Onboard Media House style
            _buildHeaderCard(theme),

            // Tab Bar Navigation
            Container(
              decoration: BoxDecoration(
                color: theme.canvasColor.withValues(alpha: 0.04),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.canvasColor.withValues(alpha: 0.65),
                indicatorColor: theme.primaryColor,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Basic Details', icon: Icon(Icons.info_outline, size: 16)),
                  Tab(text: 'Address & Location', icon: Icon(Icons.location_on_outlined, size: 16)),
                  Tab(text: 'Bank & Documents', icon: Icon(Icons.description_outlined, size: 16)),
                  Tab(text: 'Contact Details', icon: Icon(Icons.contacts_outlined, size: 16)),
                  Tab(text: 'Branding & System', icon: Icon(Icons.image_outlined, size: 16)),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStepContainer(theme, 'Basic Details', _buildBasicDetailsTab(theme)),
                    _buildStepContainer(theme, 'Address & Location', _buildAddressLocationTab(theme)),
                    _buildStepContainer(theme, 'Bank & Documents', _buildBankDocumentsTab(theme)),
                    _buildStepContainer(theme, 'Contact Details', _buildContactDetailsTab(theme)),
                    _buildStepContainer(theme, 'Branding & System', _buildBrandingSystemTab(theme)),
                  ],
                ),
              ),
            ),

            // Footer Actions
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer(ThemeData theme, String title, Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.canvasColor.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Edit Production House',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.mediaHouse.mediaHouseName ?? 'Production House',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Production House ID: #${widget.mediaHouse.id ?? "N/A"}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.canvasColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
            style: IconButton.styleFrom(
              backgroundColor: theme.cardColor.withValues(alpha: 0.7),
              foregroundColor: theme.canvasColor,
            ),
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Cancel and Close',
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: theme.canvasColor.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.dividerColor),
              foregroundColor: theme.canvasColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(
              _isSubmitting ? 'Saving...' : 'Save Changes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Basic Details Tab
  Widget _buildBasicDetailsTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _c('mediaHouseName'),
          label: 'Production House Name',
          hintText: 'Enter production house name',
          textInputType: TextInputType.text,
          isValidator: false,
        ),
        _buildFirmTypeField(theme),
        _buildDesignationField(theme),
        Row(
          children: [
            Expanded(
              child: _buildStatusField(theme),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.canvasColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Active Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: theme.canvasColor,
                    ),
                  ),
                  subtitle: Text(
                    _active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      color: _active ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: _active,
                  activeThumbColor: Colors.green,
                  onChanged: (val) => setState(() => _active = val),
                ),
                ),
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _c('discription'),
          label: 'Description',
          hintText: 'Enter overview/description',
          textInputType: TextInputType.multiline,
          maxLine: 3,
          isValidator: false,
        ),
      ],
    );
  }

  // 2. Address & Location Tab
  Widget _buildAddressLocationTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCountryField(theme),
        _buildStateField(theme),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('district'),
                label: 'District',
                hintText: 'Enter district',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('city'),
                label: 'City',
                hintText: 'Enter city',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('taluka'),
                label: 'Taluka',
                hintText: 'Enter taluka',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('officeBuilding'),
                label: 'Office Building',
                hintText: 'Enter office building / premises',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('area'),
                label: 'Area / Locality',
                hintText: 'Enter area',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('pincode'),
                label: 'Pincode',
                hintText: 'Enter pincode',
                textInputType: TextInputType.number,
                isValidator: false,
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _c('address'),
          label: 'Full Street Address',
          hintText: 'Enter complete address',
          textInputType: TextInputType.text,
          isValidator: false,
        ),
      ],
    );
  }

  // 3. Bank & Documents Tab
  Widget _buildBankDocumentsTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _c('accountHolderName'),
          label: 'Account Holder Name',
          hintText: 'Enter account holder name',
          textInputType: TextInputType.text,
          isValidator: false,
        ),
        CustomTextField(
          controller: _c('bankName'),
          label: 'Bank Name',
          hintText: 'Enter bank name',
          textInputType: TextInputType.text,
          isValidator: false,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('bankAccountNumber'),
                label: 'Bank Account Number',
                hintText: 'Enter account number',
                textInputType: TextInputType.number,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('bankIFSCNumber'),
                label: 'Bank IFSC Number',
                hintText: 'Enter IFSC code',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Statutory & Compliance Documents',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildUploadCard('adharCard', 'Signing Authority Aadhaar Card', theme),
        const SizedBox(height: 12),
        _buildUploadCard('panCard', 'Firm PAN Card', theme),
        const SizedBox(height: 12),
        _buildUploadCard('gstCertificates', 'GST Certificate', theme),
        const SizedBox(height: 12),
        _buildUploadCard('registrationCertificate', 'Registration Certificate', theme),
        const SizedBox(height: 12),
        _buildUploadCard('shopAct', 'Shop Act / Udyam Aadhaar', theme),
        const SizedBox(height: 12),
        _buildUploadCard('bankProof', 'Bank Proof', theme),
        const SizedBox(height: 12),
        _buildUploadCard('addressProof', 'Address Proof', theme),
      ],
    );
  }

  // 4. Contact Details Tab
  Widget _buildContactDetailsTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Contact',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('email'),
                label: 'Authorized Email',
                hintText: 'Enter authorized email',
                textInputType: TextInputType.emailAddress,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('emailId'),
                label: 'Alternate Email',
                hintText: 'Enter alternate email',
                textInputType: TextInputType.emailAddress,
                isValidator: false,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('contactNumber'),
                label: 'Authorized Contact Number',
                hintText: 'Enter contact number',
                textInputType: TextInputType.phone,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('mobileNumber'),
                label: 'Authorized Mobile Number',
                hintText: 'Enter mobile number',
                textInputType: TextInputType.phone,
                isValidator: false,
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _c('refferedBy'),
          label: 'Referred By',
          hintText: 'Enter referral code / name',
          textInputType: TextInputType.text,
          isValidator: false,
        ),
        const SizedBox(height: 16),
        Text(
          'Director & CEO Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('directorName'),
                label: 'Firm Director Name',
                hintText: 'Enter director name',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('directorEmail'),
                label: 'Firm Director Email',
                hintText: 'Enter director email',
                textInputType: TextInputType.emailAddress,
                isValidator: false,
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _c('directorMobile'),
          label: 'Firm Director Mobile',
          hintText: 'Enter director mobile',
          textInputType: TextInputType.phone,
          isValidator: false,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _c('ceoName'),
                label: 'CEO Name',
                hintText: 'Enter CEO name',
                textInputType: TextInputType.text,
                isValidator: false,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomTextField(
                controller: _c('ceoEmail'),
                label: 'CEO Email',
                hintText: 'Enter CEO email',
                textInputType: TextInputType.emailAddress,
                isValidator: false,
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: _c('ceoMobile'),
          label: 'CEO Mobile',
          hintText: 'Enter CEO mobile',
          textInputType: TextInputType.phone,
          isValidator: false,
        ),
      ],
    );
  }

  // 5. Branding & System Tab
  Widget _buildBrandingSystemTab(ThemeData theme) {
    final orig = widget.mediaHouse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visual Branding',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildUploadCard('logo', 'Production House Logo', theme),
        const SizedBox(height: 12),
        _buildUploadCard('profileImage', 'Production House Poster', theme),
        const SizedBox(height: 20),
        Text(
          'System Identifiers (Read-Only)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.canvasColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildSystemRow('Production House ID', '#${orig.id ?? "N/A"}', theme),
              _buildSystemRow('User ID', '#${orig.userId ?? orig.user?.id ?? "N/A"}', theme),
              _buildSystemRow('Total Contents / Posts', orig.postCount ?? '0', theme),
              _buildSystemRow('Total Views', orig.totalViews ?? '0', theme),
              _buildSystemRow('Total Revenue', '₹ ${orig.displayTotalRevenue ?? "0"}', theme),
              _buildSystemRow('Join Date', orig.joinDate?.toString() ?? 'N/A', theme),
              _buildSystemRow('Created Date', orig.createdDate?.toString() ?? 'N/A', theme),
              _buildSystemRow('Approval Status', orig.status ?? 'N/A', theme),
            ],
          ),
        ),
      ],
    );
  }

  // Upload Card component with immediate local preview and dedicated field state
  Widget _buildUploadCard(String key, String label, ThemeData theme) {
    final url = _c(key).text.trim();
    final localBytes = _localPreviewBytes[key];
    final localFileName = _localFileNames[key];
    final isUploading = _uploadingFields.contains(key);
    final hasFile = localBytes != null || url.isNotEmpty;
    final isImage = key == 'logo' ||
        key == 'profileImage' ||
        key == 'poster' ||
        _isImageFile(localFileName ?? url);

    final fileName = localFileName ?? _extractFileName(url, label);
    final formatLabel = _getFileFormatLabel(localFileName ?? url, isImage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.canvasColor,
                ),
              ),
              if (hasFile) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 10, color: Colors.green),
                      const SizedBox(width: 3),
                      Text(
                        formatLabel,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        InkWell(
          onTap: isUploading ? null : () => _pickAndUploadDocument(key, label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: hasFile ? 116 : 80,
            decoration: BoxDecoration(
              color: hasFile
                  ? Colors.green.withValues(alpha: 0.06)
                  : theme.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile
                    ? Colors.green.withValues(alpha: 0.4)
                    : theme.primaryColor.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
            child: Stack(
              children: [
                if (hasFile) ...[
                  if (isImage)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: localBytes != null
                            ? Image.memory(
                                localBytes,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildFallbackDocPreview(label, fileName, theme),
                              ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: _buildDocumentPreview(label, fileName, theme),
                    ),
                  if (isImage)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.58),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                Center(
                  child: isUploading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: isImage && hasFile ? Colors.white : theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Uploading...",
                              style: TextStyle(
                                color: isImage && hasFile ? Colors.white : theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasFile ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                              color: isImage && hasFile ? Colors.white : theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                hasFile ? "Change $label" : "Upload $label",
                                style: TextStyle(
                                  color: isImage && hasFile ? Colors.white : theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
                if (hasFile && !isUploading) ...[
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (url.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 16),
                            tooltip: 'View Document',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(6),
                              minimumSize: const Size(28, 28),
                            ),
                            onPressed: () => _openDocument(url),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          tooltip: 'Clear',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(28, 28),
                          ),
                          onPressed: () {
                            setState(() {
                              _localPreviewBytes.remove(key);
                              _localFileNames.remove(key);
                              _c(key).clear();
                              if (key == 'profileImage') _c('poster').clear();
                              if (key == 'poster') _c('profileImage').clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        CustomTextField(
          controller: _c(key),
          hintText: 'Enter $label URL or upload file',
          textInputType: TextInputType.url,
          isValidator: false,
          onValueChange: (_) => setState(() {}),
        ),
      ],
    );
  }

  bool _isImageFile(String pathOrUrl) {
    final clean = pathOrUrl.split('?').first.toLowerCase();
    return clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.png') ||
        clean.endsWith('.webp') ||
        clean.endsWith('.gif');
  }

  String _getFileFormatLabel(String pathOrUrl, bool isImage) {
    if (pathOrUrl.isEmpty) return isImage ? 'IMAGE' : 'DOC';
    final clean = pathOrUrl.split('?').first.toLowerCase();
    if (clean.endsWith('.pdf')) return 'PDF';
    if (clean.endsWith('.png')) return 'PNG';
    if (clean.endsWith('.jpg') || clean.endsWith('.jpeg')) return 'JPG';
    if (clean.endsWith('.webp')) return 'WEBP';
    if (clean.endsWith('.doc') || clean.endsWith('.docx')) return 'DOC';
    return isImage ? 'IMAGE' : 'FILE';
  }

  String _extractFileName(String url, String defaultLabel) {
    if (url.trim().isEmpty) return '';
    try {
      final clean = url.split('?').first.split('#').first;
      final uri = Uri.tryParse(clean);
      final segments = uri?.pathSegments ?? clean.split('/');
      if (segments.isNotEmpty && segments.last.trim().isNotEmpty) {
        final decoded = Uri.decodeComponent(segments.last.trim());
        if (decoded.isNotEmpty && decoded != '/') {
          return decoded;
        }
      }
    } catch (_) {}
    return defaultLabel;
  }

  void _openDocument(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    String fullUrl = trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      final base = ApiConstant.baseUrl.endsWith('/')
          ? ApiConstant.baseUrl.substring(0, ApiConstant.baseUrl.length - 1)
          : ApiConstant.baseUrl;
      final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      fullUrl = '$base$path';
    }
    if (kIsWeb) {
      html.window.open(fullUrl, '_blank');
    } else {
      debugPrint("Opening document URL: $fullUrl");
    }
  }

  Widget _buildDocumentPreview(String label, String fileName, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      alignment: Alignment.center,
      color: theme.cardColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: theme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName.isNotEmpty ? fileName : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: theme.canvasColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Document attached',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackDocPreview(String label, String fileName, ThemeData theme) {
    return Container(
      color: theme.cardColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: theme.hintColor, size: 28),
          const SizedBox(height: 4),
          Text(
            fileName.isNotEmpty ? fileName : label,
            style: TextStyle(fontSize: 11, color: theme.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFirmTypeField(ThemeData theme) {
    final controller = _c('firmType');
    final selectedValue = controller.text.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Firm Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: _firmTypeOptions.contains(selectedValue) ? selectedValue : null,
            items: _firmTypeOptions
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(color: theme.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) controller.text = value;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.cardColor,
              hintText: 'Select Firm Type',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignationField(ThemeData theme) {
    final controller = _c('designation');
    final selectedValue = controller.text.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Designation / Role',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: _designationOptions.contains(selectedValue)
                ? selectedValue
                : null,
            items: _designationOptions
                .map(
                  (des) => DropdownMenuItem<String>(
                    value: des,
                    child: Text(
                      des,
                      style: TextStyle(color: theme.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) controller.text = value;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.cardColor,
              hintText: 'Select Designation',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Approval Status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: _statusOptions.contains(_status) ? _status : _statusOptions.first,
            items: _statusOptions
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(
                      s,
                      style: TextStyle(color: theme.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryField(ThemeData theme) {
    final controller = _c('country');
    final selectedValue = controller.text.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Country',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: _countryOptions.contains(selectedValue)
                ? selectedValue
                : (_countryOptions.contains('India') ? 'India' : null),
            items: _countryOptions
                .map(
                  (c) => DropdownMenuItem<String>(
                    value: c,
                    child: Text(
                      c,
                      style: TextStyle(color: theme.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) controller.text = value;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateField(ThemeData theme) {
    final controller = _c('state');
    final selectedValue = controller.text.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'State',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            value: _indiaStates.contains(selectedValue)
                ? selectedValue
                : (_indiaStates.contains('Maharashtra') ? 'Maharashtra' : null),
            items: _indiaStates
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(
                      s,
                      style: TextStyle(color: theme.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) controller.text = value;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.canvasColor.withValues(alpha: 0.65),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.canvasColor,
            ),
          ),
        ],
      ),
    );
  }
}

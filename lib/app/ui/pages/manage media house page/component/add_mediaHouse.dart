import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/get_date_time.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/request/mediaHouse_request.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMediaHouseWidget extends StatefulWidget {
  const AddMediaHouseWidget({super.key});

  @override
  State<AddMediaHouseWidget> createState() => _AddMediaHouseWidgetState();
}

class _AddMediaHouseWidgetState extends State<AddMediaHouseWidget> {
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

  int _currentStep = 0;
  final List<GlobalKey<FormState>> _stepKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final List<bool> _showStepValidation = [false, false, false, false, false];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _uploadedUrls = {};
  final Set<String> _uploadingFields = {};
  bool _isSubmitting = false;

  final Map<String, String> _labels = {
    'mediaHouseName': 'Production House Name',
    'firmType': 'Firm Type',
    'discription': 'Description',
    'email': 'Authorized Email',
    'emailId': 'Alternate Email',
    'contactNumber': 'Authorized Contact Number',
    'mobileNumber': 'Authorized Mobile Number',
    'refferedBy': 'Referred By',
    'postCount': 'Post Count',
    'totalViews': 'Total Views',
    'totalReveneu': 'Total Revenue',
    'officeBuilding': 'Office Building',
    'address': 'Address',
    'area': 'Area',
    'city': 'City',
    'district': 'District',
    'taluka': 'Taluka',
    'state': 'State',
    'country': 'Country',
    'pincode': 'Pincode',
    'dob': 'Date of Birth',
    'designation': 'Designation',
    'ceoName': 'CEO Name',
    'ceoEmail': 'CEO Email',
    'ceoMobile': 'CEO Mobile',
    'directorName': 'Firm Director Name',
    'directorEmail': 'Firm Director Email',
    'directorMobile': 'Firm Director Mobile',
    'accountHolderName': 'Account Holder Name',
    'bankName': 'Bank Name',
    'bankAccountNumber': 'Bank Account Number',
    'bankIFSCNumber': 'Bank IFSC Number',
    'logo': 'Logo',
    'profileImage': 'Profile Image',
    'addressProof': 'Address Proof',
    'adharCard': 'Signing Authority Aadhaar Card',
    'panCard': 'Firm PAN Card',
    'bankProof': 'Bank Proof',
    'gstCertificates': 'GST Certificate',
    'registrationCertificate': 'Registration Certificate',
    'shopAct': 'Shop Act/Udyam Aadhaar',
  };

  final Set<String> _requiredFields = {
    'mediaHouseName',
    'firmType',
    'email',
    'mobileNumber',
    'directorName',
    'directorEmail',
    'directorMobile',
    'city',
    'state',
    'country',
    'pincode',
    'bankName',
    'bankAccountNumber',
    'bankIFSCNumber',
  };

  final Set<String> _emailFields = {
    'email',
    'emailId',
    'ceoEmail',
    'directorEmail',
  };

  final Set<String> _contactPhoneFields = {
    'contactNumber',
    'mobileNumber',
    'ceoMobile',
    'directorMobile',
  };

  final Set<String> _uploadFields = {
    'logo',
    'addressProof',
    'adharCard',
    'panCard',
    'bankProof',
    'gstCertificates',
    'shopAct',
    'registrationCertificate',
  };

  final Set<String> _requiredUploadFields = {
    'adharCard',
    'panCard',
    'bankProof',
    'addressProof',
  };

  final List<String> _stepOneFields = [
    'mediaHouseName',
    'firmType',
    'registrationCertificate',
    'designation',
  ];

  final List<String> _stepTwoFields = [
    'country',
    'state',
    'district',
    'city',
    'taluka',
    'officeBuilding',
    'area',
    'pincode',
  ];

  final List<String> _stepThreeFields = [
    'accountHolderName',
    'bankName',
    'bankAccountNumber',
    'bankIFSCNumber',
    'logo',
    'addressProof',
    'adharCard',
    'panCard',
    'bankProof',
    'gstCertificates',
    'shopAct',
  ];

  final List<String> _stepFourFields = [
    'email',
    'emailId',
    'mobileNumber',
  ];

  final List<String> _stepFiveFields = [
    'directorName',
    'directorEmail',
    'directorMobile',
    'ceoName',
    'ceoEmail',
    'ceoMobile',
  ];

  TextEditingController _controller(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final selectedThemeData = themeProvider.getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight -
                        40 -
                        MediaQuery.of(context).viewInsets.bottom)
                    .clamp(0.0, double.infinity),
              ),
              child: Center(
                child: SizedBox(
                  width: ResponsiveWidget.isMobile(context)
                      ? double.infinity
                      : 720,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: selectedThemeData.canvasColor
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selectedThemeData.dividerColor
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildHeaderCard(selectedThemeData),
                            _buildProgressIndicator(selectedThemeData),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      selectedThemeData.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selectedThemeData.dividerColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Form(
                                  key: _stepKeys[_currentStep],
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _stepTitle,
                                        style: TextStyle(
                                          color: selectedThemeData.primaryColor,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ..._buildFields(
                                        _currentStepFields,
                                        selectedThemeData,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _buildFooter(selectedThemeData),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFields(List<String> keys, ThemeData themeData) {
    return keys.map((key) {
      final isRequired = _requiredFields.contains(key);
      final isEmail = _emailFields.contains(key);
      final isPhone = _contactPhoneFields.contains(key);
      final isDigitsOnly = key == 'pincode' || key == 'bankAccountNumber';
      final fieldLabel = (_labels[key] ?? key) + (isRequired ? ' *' : '');

      if (_uploadFields.contains(key)) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildUploadField(key, themeData),
        );
      }

      if (key == 'firmType') {
        return _buildFirmTypeField(themeData);
      }

      if (key == 'designation') {
        return _buildDesignationField(themeData);
      }

      if (key == 'country') {
        return _buildCountryField(themeData);
      }

      if (key == 'state') {
        return _buildStateField(themeData);
      }

      String? Function(String?)? validator;
      if (isEmail) {
        validator = (value) => _validateEmail(value, key, isRequired);
      } else if (isPhone) {
        validator = (value) => _validatePhone(value, key, isRequired);
      } else {
        validator =
            (value) => _validateTextField(value, key, isRequired, isDigitsOnly);
      }

      return CustomTextField(
        controller: _controller(key),
        hintText: 'Enter ${_labels[key] ?? key}',
        label: fieldLabel,
        textInputType: (isPhone || isDigitsOnly)
            ? TextInputType.phone
            : TextInputType.text,
        capitalization:
            isEmail ? TextCapitalization.none : TextCapitalization.words,
        isValidator: false,
        isEmail: isEmail,
        isDigits: isDigitsOnly,
        isPhoneNumber: isPhone,
        validator: validator,
      );
    }).toList(growable: false);
  }

  String? _validateEmail(
    String? value,
    String key,
    bool isRequired, {
    bool force = false,
  }) {
    if (!force && !_shouldValidateCurrentStep) return null;
    final text = (value ?? '').trim();
    final label = _labels[key] ?? key;
    if (text.isEmpty) {
      return isRequired ? '$label is required' : null;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid $label';
    }
    return null;
  }

  String? _validatePhone(
    String? value,
    String key,
    bool isRequired, {
    bool force = false,
  }) {
    if (!force && !_shouldValidateCurrentStep) return null;
    final text = (value ?? '').trim();
    final label = _labels[key] ?? key;
    if (text.isEmpty) {
      return isRequired ? '$label is required' : null;
    }
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return '$label must contain digits only';
    }
    if (text.length < 10 || text.length > 15) {
      return '$label must be between 10 and 15 digits';
    }
    return null;
  }

  String? _validateTextField(
    String? value,
    String key,
    bool isRequired,
    bool isDigitsOnly, {
    bool force = false,
  }) {
    if (!force && !_shouldValidateCurrentStep) return null;
    final text = (value ?? '').trim();
    final label = _labels[key] ?? key;

    if (text.isEmpty) {
      return isRequired ? '$label is required' : null;
    }

    if (isDigitsOnly && !RegExp(r'^\d+$').hasMatch(text)) {
      return '$label must contain digits only';
    }

    return null;
  }

  bool get _shouldValidateCurrentStep => _showStepValidation[_currentStep];

  List<String> get _currentStepFields {
    if (_currentStep == 0) return _stepOneFields;
    if (_currentStep == 1) return _stepTwoFields;
    if (_currentStep == 2) return _stepThreeFields;
    if (_currentStep == 3) return _stepFourFields;
    return _stepFiveFields;
  }

  String get _stepTitle {
    if (_currentStep == 0) return 'Basic Details';
    if (_currentStep == 1) return 'Address & Management';
    if (_currentStep == 2) return 'Bank & Documents';
    if (_currentStep == 3) return 'Contact Details';
    return 'Director & CEO Info';
  }

  Widget _buildHeaderCard(ThemeData themeData) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: themeData.canvasColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Production House Sign Up',
                style: TextStyle(
                  color: themeData.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _stepTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeData.canvasColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeData.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${_currentStep + 1}/5',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor:
                  themeData.scaffoldBackgroundColor.withValues(alpha: 0.35),
              foregroundColor: themeData.canvasColor,
            ),
            icon: const Icon(Icons.close, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? themeData.primaryColor
                          : themeData.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 4) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter(ThemeData themeData) {
    final isLast = _currentStep == 4;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _onBack,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: themeData.primaryColor),
                  foregroundColor: themeData.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting && isLast
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLast ? 'Sign Up' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField(String key, ThemeData themeData) {
    final label = _labels[key] ?? key;
    final url = _uploadedUrls[key] ?? _controller(key).text.trim();
    final isUploading = _uploadingFields.contains(key);
    final isUploaded = url.isNotEmpty;
    final isRequired = _requiredUploadFields.contains(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeData.canvasColor,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isUploading ? null : () => _pickAndUploadDocument(key, label),
          child: Container(
            height: isUploaded ? 120 : 84,
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withValues(alpha: 0.1)
                  : themeData.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded
                    ? Colors.green.withValues(alpha: 0.45)
                    : themeData.primaryColor.withValues(alpha: 0.35),
                width: 1.6,
              ),
            ),
            child: Stack(
              children: [
                if (isUploaded) ...[
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.description_outlined,
                              color: themeData.primaryColor,
                              size: 34,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
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
                                strokeWidth: 2.5,
                                color: themeData.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Uploading...",
                              style: TextStyle(
                                color: themeData.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isUploaded
                                  ? Icons.check_circle_outline
                                  : Icons.cloud_upload_outlined,
                              color: isUploaded
                                  ? Colors.white
                                  : themeData.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                isUploaded
                                    ? "$label Uploaded"
                                    : "Upload $label",
                                style: TextStyle(
                                  color: isUploaded
                                      ? Colors.white
                                      : themeData.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadDocument(String key, String label) async {
    setState(() => _uploadingFields.add(key));
    try {
      final mediaHouseProvider =
          Provider.of<MediaHouseProvider>(context, listen: false);
      await mediaHouseProvider.pickImage(label);
      final uploadedUrl = mediaHouseProvider.uploadedImageUrl;
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _uploadedUrls[key] = uploadedUrl;
          _controller(key).text = uploadedUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show('Failed to upload $label: $e', isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingFields.remove(key));
      }
    }
  }

  Future<void> _onContinue() async {
    setState(() => _showStepValidation[_currentStep] = true);
    final isValidStep = _stepKeys[_currentStep].currentState?.validate() ?? false;
    final missingUpload = _findMissingUploadInStep(_currentStep);

    if (!isValidStep || missingUpload != null) {
      if (missingUpload != null) {
        CustomToast.show(
          '${_labels[missingUpload] ?? missingUpload} is required',
          isSuccess: false,
        );
      }
      return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    // Full mandatory field validation pass across all 5 steps at the end of registration
    setState(() {
      for (int i = 0; i < _showStepValidation.length; i++) {
        _showStepValidation[i] = true;
      }
    });

    final invalidKey = _findFirstInvalidField();
    if (invalidKey != null) {
      final invalidStep = _stepIndexForField(invalidKey) ?? 0;
      final labelName = _labels[invalidKey] ?? invalidKey;

      setState(() {
        _currentStep = invalidStep;
      });

      _stepKeys[invalidStep].currentState?.validate();

      CustomToast.show(
        'Please fill mandatory field: $labelName',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = SaveMediaHouse(
        mediaHouseName: _controller('mediaHouseName').text.trim(),
        firmType: _controller('firmType').text.trim(),
        registrationCertificate:
            _controller('registrationCertificate').text.trim(),
        designation: _controller('designation').text.trim(),
        country: _controller('country').text.trim(),
        state: _controller('state').text.trim(),
        district: _controller('district').text.trim(),
        city: _controller('city').text.trim(),
        taluka: _controller('taluka').text.trim(),
        officeBuilding: _controller('officeBuilding').text.trim(),
        area: _controller('area').text.trim(),
        pincode: _controller('pincode').text.trim(),
        accountHolderName: _controller('accountHolderName').text.trim(),
        bankName: _controller('bankName').text.trim(),
        bankAccountNumber: _controller('bankAccountNumber').text.trim(),
        bankIFSCNumber: _controller('bankIFSCNumber').text.trim(),
        logo: _controller('logo').text.trim(),
        addressProof: _controller('addressProof').text.trim(),
        adharCard: _controller('adharCard').text.trim(),
        panCard: _controller('panCard').text.trim(),
        bankProof: _controller('bankProof').text.trim(),
        gstCertificates: _controller('gstCertificates').text.trim(),
        shopAct: _controller('shopAct').text.trim(),
        email: _controller('email').text.trim(),
        emailId: _controller('emailId').text.trim(),
        mobileNumber: _controller('mobileNumber').text.trim(),
        contactNumber: _controller('mobileNumber').text.trim(),
        directorName: _controller('directorName').text.trim(),
        directorEmail: _controller('directorEmail').text.trim(),
        directorMobile: _controller('directorMobile').text.trim(),
        ceoName: _controller('ceoName').text.trim(),
        ceoEmail: _controller('ceoEmail').text.trim(),
        ceoMobile: _controller('ceoMobile').text.trim(),
        joinDate: GetDateFormat.getCurrentDate(),
        status: "PENDING",
      );

      final mhProvider =
          Provider.of<MediaHouseProvider>(context, listen: false);
      final result =
          await mhProvider.createMediaHouseWithModel(request, context);

      if (!mounted) return;
      final success = result['success'] == true;

      CustomToast.show(
        result['message']?.toString() ??
            (success
                ? 'Production house created successfully'
                : 'Failed to add media house'),
        isSuccess: success,
      );

      if (success) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show('Error submitting form: $e', isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  String? _findMissingUploadInStep(int step) {
    List<String> fields;
    if (step == 0)
      fields = _stepOneFields;
    else if (step == 1)
      fields = _stepTwoFields;
    else if (step == 2)
      fields = _stepThreeFields;
    else if (step == 3)
      fields = _stepFourFields;
    else
      fields = _stepFiveFields;

    for (var key in fields) {
      if (_requiredUploadFields.contains(key)) {
        final val = _controller(key).text.trim();
        if (val.isEmpty) return key;
      }
    }
    return null;
  }

  String? _findFirstInvalidField() {
    for (final key in _stepOneFields) {
      if (_validateFieldByKey(key) != null) return key;
    }
    for (final key in _stepTwoFields) {
      if (_validateFieldByKey(key) != null) return key;
    }
    for (final key in _stepThreeFields) {
      if (_validateFieldByKey(key) != null) return key;
    }
    for (final key in _stepFourFields) {
      if (_validateFieldByKey(key) != null) return key;
    }
    for (final key in _stepFiveFields) {
      if (_validateFieldByKey(key) != null) return key;
    }
    return null;
  }

  int? _stepIndexForField(String key) {
    if (_stepOneFields.contains(key)) return 0;
    if (_stepTwoFields.contains(key)) return 1;
    if (_stepThreeFields.contains(key)) return 2;
    if (_stepFourFields.contains(key)) return 3;
    if (_stepFiveFields.contains(key)) return 4;
    return null;
  }

  String? _validateFieldByKey(String key) {
    final value = _controller(key).text.trim();

    if (_requiredUploadFields.contains(key)) {
      return value.isEmpty ? '${_labels[key] ?? key} is required' : null;
    }

    if (key == 'firmType' || key == 'country' || key == 'state') {
      return value.isEmpty ? '${_labels[key] ?? key} is required' : null;
    }

    final isRequired = _requiredFields.contains(key);
    if (_emailFields.contains(key)) {
      return _validateEmail(value, key, isRequired, force: true);
    }
    if (_contactPhoneFields.contains(key)) {
      return _validatePhone(value, key, isRequired, force: true);
    }

    final isDigitsOnly = key == 'pincode' || key == 'bankAccountNumber';
    return _validateTextField(
      value,
      key,
      isRequired,
      isDigitsOnly,
      force: true,
    );
  }

  Widget _buildFirmTypeField(ThemeData themeData) {
    final controller = _controller('firmType');
    final selectedValue = controller.text.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeData.canvasColor,
                ),
                children: const [
                  TextSpan(text: 'Firm Type'),
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedValue.isEmpty ? null : selectedValue,
            items: _firmTypeOptions
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(color: themeData.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              controller.text = value ?? '';
            },
            validator: (value) {
              if (!_shouldValidateCurrentStep) return null;
              if ((value ?? '').trim().isEmpty) {
                return 'Firm Type is required';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: themeData.inputDecorationTheme.fillColor ??
                  themeData.cardColor.withValues(alpha: 0.05),
              hintText: 'Select Firm Type',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeData.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeData.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeData.primaryColor,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.2,
                ),
              ),
            ),
            dropdownColor: themeData.cardColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDesignationField(ThemeData themeData) {
    final controller = _controller('designation');
    final selectedValue = controller.text.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Designation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeData.canvasColor,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedValue.isEmpty ? null : selectedValue,
            items: _designationOptions
                .map(
                  (designation) => DropdownMenuItem<String>(
                    value: designation,
                    child: Text(
                      designation,
                      style: TextStyle(color: themeData.canvasColor),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              controller.text = value ?? '';
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: themeData.inputDecorationTheme.fillColor ??
                  themeData.cardColor.withValues(alpha: 0.05),
              hintText: 'Select Designation',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeData.dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeData.dividerColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeData.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            dropdownColor: themeData.cardColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCountryField(ThemeData themeData) {
    return FormField<String>(
      validator: (selected) {
        if (!_shouldValidateCurrentStep) return null;
        final val = (selected ?? _controller('country').text).trim();
        if (val.isEmpty) {
          return 'Country is required';
        }
        return null;
      },
      builder: (field) {
        final currentValue = _controller('country').text.trim();
        return _buildSearchableSelectField(
          label: 'Country',
          value: currentValue,
          hint: 'Select Country',
          enabled: true,
          themeData: themeData,
          errorText: field.errorText,
          onTap: () async {
            final selected = await _showSearchableSelectionDialog(
              title: 'Select Country',
              options: _countryOptions,
              initialValue: currentValue,
            );
            if (selected == null || selected == currentValue) return;
            setState(() {
              _controller('country').text = selected;
              if (selected != 'India') {
                _controller('state').clear();
              }
            });
            field.didChange(selected);
          },
        );
      },
    );
  }

  Widget _buildStateField(ThemeData themeData) {
    final country = _controller('country').text.trim();
    final enabled = country.isNotEmpty;

    return FormField<String>(
      validator: (selected) {
        if (!_shouldValidateCurrentStep) return null;
        final val = (selected ?? _controller('state').text).trim();
        if (val.isEmpty) {
          return 'State is required';
        }
        return null;
      },
      builder: (field) {
        final currentValue = _controller('state').text.trim();
        return _buildSearchableSelectField(
          label: 'State',
          value: currentValue,
          hint: !enabled ? 'Select Country First' : 'Select State',
          enabled: enabled,
          themeData: themeData,
          errorText: field.errorText,
          onTap: () async {
            if (!enabled) return;
            final selected = await _showSearchableSelectionDialog(
              title: 'Select State',
              options: country == 'India' ? _indiaStates : _indiaStates,
              initialValue: currentValue,
            );
            if (selected == null || selected == currentValue) return;
            setState(() {
              _controller('state').text = selected;
            });
            field.didChange(selected);
          },
        );
      },
    );
  }

  Widget _buildSearchableSelectField({
    required String label,
    required String value,
    required String hint,
    required bool enabled,
    required ThemeData themeData,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeData.canvasColor,
                ),
                children: [
                  TextSpan(text: label),
                  if (label == 'Country' || label == 'State')
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: themeData.inputDecorationTheme.fillColor ??
                    themeData.cardColor.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeData.dividerColor,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeData.dividerColor.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeData.primaryColor,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeData.dividerColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                errorText: errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? hint : value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value.isEmpty
                            ? themeData.hintColor
                            : themeData.canvasColor,
                        fontWeight:
                            value.isEmpty ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: themeData.primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: themeData.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showSearchableSelectionDialog({
    required String title,
    required List<String> options,
    required String initialValue,
  }) async {
    final themeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final searchController = TextEditingController();
        String query = '';
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filtered = options
                .where((option) =>
                    option.toLowerCase().contains(query.toLowerCase()))
                .toList(growable: false);
            return AlertDialog(
              backgroundColor: themeData.cardColor,
              surfaceTintColor: Colors.transparent,
              title: Text(
                title,
                style: TextStyle(color: themeData.canvasColor),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      style: TextStyle(color: themeData.canvasColor),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: themeData.hintColor),
                        prefixIcon:
                            Icon(Icons.search, color: themeData.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          query = value.trim();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(color: themeData.canvasColor),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final item = filtered[index];
                                final isSelected = item == initialValue;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    item,
                                    style:
                                        TextStyle(color: themeData.canvasColor),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check,
                                          size: 18,
                                          color: themeData.primaryColor)
                                      : null,
                                  onTap: () {
                                    Navigator.of(dialogContext).pop(item);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: themeData.primaryColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

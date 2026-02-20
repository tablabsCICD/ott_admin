import 'package:admin_ott/app/core/constant/image_constant.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../core/utils/sharepreferences.dart';
import '../../../provider/userProvider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
  }

  Future<void> getData() async {
    final localSharePreferences = LocalSharePreferences();
    final user = await localSharePreferences.getUser();
    if (user != null && mounted) {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(user.id!);
    }
  }

  Future<void> _saveProfile(UserProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      CustomToast.show('Please enter valid details', isSuccess: false);
      return;
    }

    if (provider.profileController.text.isEmpty) {
      provider.profileController.text = provider.userObj.profilePhoto ?? '';
    }
    if (provider.emailController.text.isEmpty) {
      provider.emailController.text = provider.userObj.emailId ?? '';
    }
    if (provider.firstNameController.text.isEmpty) {
      provider.firstNameController.text = provider.userObj.firstName ?? '';
    }
    if (provider.lastNameController.text.isEmpty) {
      provider.lastNameController.text = provider.userObj.lastName ?? '';
    }
    if (provider.mobileController.text.isEmpty) {
      provider.mobileController.text = provider.userObj.mobileNumber ?? '';
    }

    final result = await provider.updateUser();
    if (!mounted) return;
    if (result['success'] == true) {
      CustomToast.show("Profile updated successfully!", isSuccess: true);
      Navigator.of(context).pop();
    } else {
      CustomToast.show("${result['message']}", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeData = themeProvider.getTheme;

    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: selectedThemeData.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: selectedThemeData.primaryColor,
            title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
              onPressed: () => _confirmDiscard(provider, selectedThemeData),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: ResponsiveWidget.isMobile(context) ? double.infinity : 430,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Hero(
                              tag: 'profile',
                              child: _profileImage(provider, selectedThemeData),
                            ),
                            InkWell(
                              onTap: () => provider.pickImage(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedThemeData.cardColor,
                                  border: Border.all(
                                    color: selectedThemeData.canvasColor,
                                    width: 0.6,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: provider.isUploading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: selectedThemeData.primaryColor,
                                        ),
                                      )
                                    : Icon(
                                        Icons.edit_outlined,
                                        color: selectedThemeData.canvasColor,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: provider.firstNameController,
                          label: 'First Name',
                          isName: true,
                          hintText: provider.userObj.firstName ?? 'Enter first name',
                          isValidator: true,
                          textInputType: TextInputType.name,
                        ),
                        CustomTextField(
                          controller: provider.lastNameController,
                          label: 'Last Name',
                          isName: true,
                          hintText: provider.userObj.lastName ?? 'Enter last name',
                          isValidator: true,
                          textInputType: TextInputType.name,
                        ),
                        CustomTextField(
                          controller: provider.emailController,
                          label: 'Email',
                          isEmail: true,
                          hintText: provider.userObj.emailId ?? 'Enter email',
                          isValidator: true,
                          textInputType: TextInputType.emailAddress,
                        ),
                        CustomTextField(
                          controller: provider.mobileController,
                          label: 'Mobile Number',
                          isPhoneNumber: true,
                          hintText:
                              provider.userObj.mobileNumber ?? 'Enter mobile number',
                          isValidator: true,
                          textInputType: TextInputType.number,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedThemeData.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _saveProfile(provider),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDiscard(UserProvider provider, ThemeData theme) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Discard Changes?"),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text("Are you sure you want to go back?"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel", style: TextStyle(color: theme.canvasColor)),
          ),
          TextButton(
            onPressed: () {
              provider.profileController.clear();
              Navigator.of(context).pop(true);
            },
            child: Text("Discard", style: TextStyle(color: theme.primaryColor)),
          ),
        ],
      ),
    );

    if ((shouldPop ?? false) && mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _profileImage(UserProvider provider, ThemeData theme) {
    final imageUrl = provider.profileController.text.isNotEmpty
        ? provider.profileController.text
        : (provider.userObj.profilePhoto ?? '');
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.primaryColor, width: 2),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset(ImageConstant.profile, fit: BoxFit.cover),
              )
            : Image.asset(ImageConstant.profile, fit: BoxFit.cover),
      ),
    );
  }
}

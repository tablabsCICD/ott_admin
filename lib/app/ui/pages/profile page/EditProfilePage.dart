import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    final localSharePreferences = LocalSharePreferences();
    final user = await localSharePreferences.getUser();

    if (user != null) {
      if (mounted) {
        await Provider.of<UserProvider>(context, listen: false).getUserById(user.id!);
      }
    }
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var result = await userProvider.updateUser();
      if (result['success'] == true) {
        CustomToast.show("Profile updated successfully!",isSuccess:true);
        Navigator.of(context).pop();
      } else {
        CustomToast.show("${result['message']}",isSuccess:false);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fill all data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var selectedThemeData = themeProvider.getTheme;
    return Consumer<UserProvider>(
        builder: (context, provider, child) {
      final user = provider.user;

      if (user == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: selectedThemeData.primaryColor,
          title: Text(provider.user.firstName??'-'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: Column(
                  children: [
                  SizedBox(
                    height: 150,
                    child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Circular image
                      CircleAvatar(
                        radius: 50, // Adjust the radius as needed
                        backgroundImage: NetworkImage(provider.user.profilePhoto??""),
                      ),
                      // Edit icon
                      InkWell(

                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue, // Background color of the icon
                          ),
                          padding: EdgeInsets.all(8.0), // Adjust padding as needed
                          child: Icon(
                            Icons.edit,
                            color: Colors.white, // Color of the icon
                            size: 20, // Adjust the size as needed
                          ),
                        ),
                      ),
                    ],
                                    ),
                  ),

                    CustomTextField(
                      controller: provider.firstNameController,
                      label: 'Enter Name',
                      isName: true,
                      hintText: 'Enter a valid name',
                      isValidator: true,
                      textInputType: TextInputType.name,
                      //decoration: const InputDecoration(labelText: 'Name'),
                      //validator: (value) =>
                      //  value!.isEmpty ? 'Enter a valid name' : null,
                    ),
                    CustomTextField(
                      controller: provider.emailController,
                      label: 'Email',
                      isEmail: true,
                      isValidator: true,
                      hintText: 'Enter a valid Email',
                      textInputType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: provider.mobileController,
                      label: 'Contact Number',
                      isPhoneNumber: true,
                      isValidator: true,
                      hintText: 'Enter a valid Mobile Number',
                      textInputType: TextInputType.number,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: ResponsiveWidget.isMobile(context)
                            ? double.infinity
                            : 400,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedThemeData.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: _saveProfile,
                          child: Center(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );}
    );
  }
}

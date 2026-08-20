import 'package:admin_ott/data/models/request/user_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/language_provider.dart';
import '../../../provider/themeProvider.dart';
import '../../../provider/userProvider.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/show_toast.dart';
import 'SelectLanguage.dart';



class SignUpPage extends StatefulWidget {
  final void Function(UserRequest) onAdd;

  const SignUpPage({required this.onAdd, super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  @override
  void initState() {
    super.initState();
    fetchLanguage();
  }

  Future<void> fetchLanguage() async {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: true);
    await languageProvider.fetchLanguages();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    var userProvider = Provider.of<UserProvider>(context, listen: true);
    var selectedThemeData = themeProvider.getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
    /*  appBar: AppBar(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: ResponsiveWidget.isMobile(context) ? 60 : 100,
        title: SizedBox(
          height: ResponsiveWidget.isMobile(context) ? 50 : 80,
          child: Image.asset('assets/images/URMEE.png'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: selectedThemeData.canvasColor,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),*/
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                width:
                    ResponsiveWidget.isMobile(context) ? double.infinity : 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CustomTextField(
                      controller: userProvider.firstNameController,
                      hintText: "Enter your first name",
                      label: "First Name",
                      textInputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                      isValidator: true,
                    ),
                    CustomTextField(
                      controller: userProvider.lastNameController,
                      hintText: "Enter your last name",
                      label: "Last Name",
                      textInputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                      isValidator: true,
                    ),
                    CustomTextField(
                      controller: userProvider.emailController,
                      hintText: "Enter your email",
                      label: "Email",
                      textInputType: TextInputType.emailAddress,
                      isEmail: true,
                      capitalization: TextCapitalization.none,
                      isValidator: true,
                    ),
                    CustomTextField(
                      controller: userProvider.mobileController,
                      hintText: "Enter your Contact Number",
                      label: "Contact Number",
                      textInputType: TextInputType.number,
                      isEmail: true,
                      capitalization: TextCapitalization.none,
                      isValidator: true,
                    ),
                    CustomTextField(
                      controller: userProvider.passwordController,
                      hintText: "Enter your password",
                      label: "Password",
                      textInputType: TextInputType.text,
                      isPassword: true,
                      isValidator: true,
                    ),
                    CustomTextField(
                      controller: userProvider.confirmPasswordController,
                      hintText: "Confirm your password",
                      label: "Confirm Password",
                      textInputType: TextInputType.text,
                      isPassword: true,
                      isValidator: true,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGenderButton("Male", selectedThemeData,userProvider),
                        _buildGenderButton("Female", selectedThemeData,userProvider),
                        _buildGenderButton("Other", selectedThemeData,userProvider),
                      ],
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedThemeData.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: (){
                        _handleSignUp(userProvider);
                      },
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderButton(String gender, ThemeData selectedThemeData,UserProvider userProvider) {
    return GestureDetector(
      onTap: () => setState(() => userProvider.selectedGender = gender),
      child: Container(
        height: 35,
        width: 90,
        decoration: BoxDecoration(
          color: selectedThemeData.cardColor,
          border: Border.all(
            width: userProvider.selectedGender == gender ? 2 : 0.5,
            color: userProvider.selectedGender == gender
                ? selectedThemeData.primaryColor
                : selectedThemeData.canvasColor,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: userProvider.selectedGender == gender
                  ? selectedThemeData.primaryColor
                  : selectedThemeData.canvasColor,
              fontWeight: userProvider.selectedGender == gender
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp(UserProvider provider) async {
    final firstName = provider.firstNameController.text.trim();
    final lastName = provider.lastNameController.text.trim();
    final email = provider.emailController.text.trim();
    final mobile = provider.mobileController.text.trim();
    final password = provider.passwordController.text.trim();
    final confirmPassword = provider.confirmPasswordController.text.trim();
    final name = "$firstName $lastName".trim();

    if (firstName.isEmpty) {
      CustomToast.show('First Name is required', isSuccess: false);
      return;
    }
    if (lastName.isEmpty) {
      CustomToast.show('Last Name is required', isSuccess: false);
      return;
    }
    if (email.isEmpty) {
      CustomToast.show('Email is required', isSuccess: false);
      return;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      CustomToast.show('Enter a valid Email address', isSuccess: false);
      return;
    }
    if (mobile.isEmpty) {
      CustomToast.show('Contact Number is required', isSuccess: false);
      return;
    }
    if (mobile.length < 10) {
      CustomToast.show('Contact Number must be at least 10 digits', isSuccess: false);
      return;
    }
    if (password.isEmpty) {
      CustomToast.show('Password is required', isSuccess: false);
      return;
    }
    if (confirmPassword.isEmpty) {
      CustomToast.show('Confirm Password is required', isSuccess: false);
      return;
    }
    if (password != confirmPassword) {
      CustomToast.show('Passwords do not match', isSuccess: false);
      return;
    }
    if (provider.selectedGender == null || provider.selectedGender!.isEmpty) {
      CustomToast.show('Gender selection is required', isSuccess: false);
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SelectLanguagePage()));
    await Future.delayed(Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('userEmail', email);
    await prefs.setString('Name', name);
    await prefs.setString('Mobile', mobile);
    await prefs.setString('gender', provider.selectedGender!);
  }


}

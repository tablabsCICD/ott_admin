import 'dart:convert';

import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/constant/image_constant.dart';
import 'package:admin_ott/app/ui/NavigationPage.dart';
import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/response/addUserResponse.dart';
import 'package:admin_ott/device/utils/ResponsiveWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/constants/api_constant.dart';
import '../../../core/network/api_helper.dart';
import '../../../provider/userProvider.dart';
import 'otp_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController mobileController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool isforgotPassword = false;

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: ResponsiveWidget.isMobile(context) ? 35 : 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: ResponsiveWidget.isMobile(context) ? 120 : 150,
                      child: Hero(
                        tag: "logo",
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(25),
                          child: Image.asset(
                            ImageConstant.logo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: ResponsiveWidget.isMobile(context)
                        ? double.infinity
                        : 400,
                    child:
                        isforgotPassword ? forgotPasswordCard() : loginCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginCard() {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Card(
      elevation: 4,
      color: selectedThemeData.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login',
              style: TextStyle(
                color: selectedThemeData.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: mobileController,
              hintText: 'Enter your email',
              textInputType: TextInputType.emailAddress,
              isEmail: true,
              label: 'Email',
            ),
            CustomTextField(
              controller: passwordController,
              hintText: 'Enter your password',
              textInputType: TextInputType.text,
              isPassword: true,
              label: 'Password',
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading
                    ? selectedThemeData.cardColor
                    : selectedThemeData.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _isLoading ? null : _handleLogin(context);
              },
              child: _isLoading
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        color: selectedThemeData.primaryColor,
                      ),
                    )
                  : Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedThemeData.canvasColor),
                    ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  isforgotPassword = true;
                });
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: selectedThemeData.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = mobileController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomToast.show('Please fill out all fields', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var result = await Provider.of<UserProvider>(context, listen: false)
          .login(email, password);
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        CustomToast.show('Welcome back, $email!', isSuccess: true);
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationPage(),
          ),
        );
      } else {
        print('Failure: ${result['message']}');
        CustomToast.show('Failure: ${result['message']}', isSuccess: false);
      }
    } catch (e) {
      CustomToast.show('Failure: $e', isSuccess: false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget forgotPasswordCard() {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Card(
      elevation: 4,
      color: selectedThemeData.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // Handle "Back" logic
                    setState(() {
                      isforgotPassword = false;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                  ),
                ),
                Text(
                  'Reset Password',
                  style: TextStyle(
                    color: selectedThemeData.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: mobileController,
              hintText: 'Enter your mobile number',
              textInputType: TextInputType.number,
              isPhoneNumber: true,
              label: 'Mobile NUmber',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedThemeData.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final mobile = mobileController.text.trim();

                if (mobile.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mobile Number required!')),
                  );
                  return;
                }
                sendOptApiCall(mobile);
              },
              child: Text(
                'Send Otp',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedThemeData.canvasColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendOptApiCall(String mobile) async {
    String apiUrl = ApiConstant.forgotPassword(mobile);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.postApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse searchResponse = AddUserResponse.fromJson(responseBody);
        if (searchResponse.success == true) {
          CustomToast.show('${searchResponse.message}');
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (builder) => OtpScreen(mobile)));
        } else {
          CustomToast.show('Error: ${searchResponse.message}');
          debugPrint("Error: ${searchResponse.message}");
        }
      } else {
        CustomToast.show(
            'Failed to send otp. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to send otp. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }
}

import 'dart:convert';

import 'package:admin_ott/app/ui/pages/login%20page/new_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/response/addUserResponse.dart';
import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../core/constant/api_constant.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/network/api_helper.dart';
import '../../../provider/themeProvider.dart';
import '../../../widgets/show_toast.dart';

class OtpScreen extends StatefulWidget {
  String mobile;
  OtpScreen(this.mobile);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {

    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return  Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body:
      Column(
        children: [
          SizedBox(
            height: 60,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Image.asset(
                  ImageConstant.logo,
                  width: 200,
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Center(
            child: SizedBox(
              width: ResponsiveWidget.isMobile(context) ? double.infinity : 450,
              child: VerifyOtpCard(selectedThemeData),
            ),
          ),
        ],
      ),


    );
  }

  _handleVerifyCode(BuildContext context, String mobile, String otp,) async {
    String apiUrl = ApiConstant.verifyOtp(mobile,otp);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        AddUserResponse searchResponse = AddUserResponse.fromJson(responseBody);
        if (searchResponse.success == true) {
          CustomToast.show('${searchResponse.message}');
          Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>NewPasswordScreen(widget.mobile)));
        } else {
          CustomToast.show('Error: ${searchResponse.message}');
          debugPrint("Error: ${searchResponse.message}");
        }
      } else {
        CustomToast.show('Failed to send otp. Status code: ${response.statusCode}');
        throw Exception('Failed to send otp. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }

  VerifyOtpCard(ThemeData selectedThemeData) {
    return  Padding(
      padding: ResponsiveWidget.isMobile(context) ? EdgeInsets.all(0.0):EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        color: selectedThemeData.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Verify Otp',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter OTP sent on ',
                    style: TextStyle(
                      color: selectedThemeData.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.mobile,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: otpController,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: selectedThemeData.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: selectedThemeData.primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: selectedThemeData.colorScheme.secondary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }),
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
                onPressed: (){
                  if(otpController.text.isNotEmpty) {
                    _isLoading ? null : _handleVerifyCode(context,widget.mobile,otpController.text);
                  }else{

                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    :
                Text(
                  'Verify Otp',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedThemeData.canvasColor),
                ),
              ),

              const SizedBox(height: 20),
              // Resend OTP
              TextButton(
                onPressed: () {
                  sendOptApiCall(widget.mobile);
                },
                child: Text("Resend OTP", style: selectedThemeData.textTheme.bodyLarge?.copyWith(color: selectedThemeData.primaryColor)),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                 Navigator.of(context).pop();
                },
                child: Text(
                  'Go Back To Login',
                  style: TextStyle(color: selectedThemeData.primaryColor),
                ),
              ),
            ],
          ),
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
          Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>OtpScreen(mobile)));
        } else {
          CustomToast.show('Error: ${searchResponse.message}');
          debugPrint("Error: ${searchResponse.message}");
        }
      } else {
        CustomToast.show('Failed to send otp. Status code: ${response.statusCode}');
        throw Exception('Failed to send otp. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }
}

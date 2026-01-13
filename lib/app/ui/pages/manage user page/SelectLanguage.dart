import 'package:admin_ott/app/ui/NavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../core/constant/app_constant.dart';
import '../../../provider/language_provider.dart';
import '../../../provider/themeProvider.dart';
import '../../../provider/userProvider.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/show_toast.dart';


class SelectLanguagePage extends StatefulWidget {
  const SelectLanguagePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectLanguagePageState createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {

  List<String> countries = [];
  List<String> states = [];
  List<String> districts = [];
  List<String> talukas = [];

  String? selectedCountry ="India";
  String? selectedState;
  String? selectedDistrict;
  String? selectedTaluka;

  @override
  void initState() {
    super.initState();
    fetchLanguage();
   selectedCountry ="India";
    selectedState="Maharashtra";
     selectedDistrict = "Pune";
    selectedTaluka = "Haveli";
  }


  Future<void> fetchLanguage() async {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: true);
    await languageProvider.fetchLanguages();
  }

  Future<void> _selectDate(UserProvider userProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      /*setState(() => userProvider.dobController.text =
          pickedDate.toLocal().toString().split(' ')[0]);*/
      userProvider.setDate(pickedDate,true);
    }
  }


  Future<void> _selectJoinDate(UserProvider userProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      /*setState(() => userProvider.dobController.text =
          pickedDate.toLocal().toString().split(' ')[0]);*/
      userProvider.setDate(pickedDate,false);
    }
  }
  void _toggleSelection(String language,UserProvider userProvider) {
    setState(() {
      userProvider.selectedLanguages.contains(language)
          ? userProvider.selectedLanguages.remove(language)
          : userProvider.selectedLanguages.add(language);
    });
    // Update Provider
    Provider.of<LanguageProvider>(context, listen: false)
        .updateLanguages(userProvider.selectedLanguages);
  }

  Future<void> _saveLanguages(UserProvider userProvider) async {
    final birthDate = userProvider.dobController.text.trim();

    if (birthDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Select valid Birth Date.')));
      return;
    }
    if (userProvider.selectedLanguages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least 3 languages.')),
      );
      return;
    }

    var result = await userProvider.createUser();
    if (result['success'] == true) {
      print(result['message']);
      CustomToast.show(result['message'],isSuccess: true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pop(context);
      Navigator.pop(context, true);
    } else {
      print('Failure: ${result['message']}');
      CustomToast.show('Failure: ${result['message']}',isSuccess: false);

    }


  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: true);

    var themeProvider = Provider.of<ThemeProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    var selectedThemeData = themeProvider.getTheme;
    bool isDark = selectedThemeData.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      //   elevation: 0,
      //   toolbarHeight: ResponsiveWidget.isMobile(context) ? 60 : 100,
      //   title: Image.asset('assets/images/URMEE.png',
      //       height: ResponsiveWidget.isMobile(context) ? 50 : 80),
      //   actions: [
      // IconButton(
      //   icon: Icon(
      //       isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
      //       color: selectedThemeData.canvasColor),
      //   onPressed: themeProvider.toggleTheme,
      // ),
      //   ],
      // ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                width:
                    ResponsiveWidget.isDesktop(context) ? 400 : double.infinity,
                child: Column(
                  children: [
                /*    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                              isDark
                                  ? Icons.wb_sunny_outlined
                                  : Icons.nightlight_round,
                              color: selectedThemeData.canvasColor),
                          onPressed: themeProvider.toggleTheme,
                        ),
                      ],
                    ),*/
                    GestureDetector(
                      onTap: () async {
                       await userProvider.pickImage();
                      },
                      child:CircleAvatar(
                        radius: 50,
                        backgroundImage: userProvider.profileController.text.isNotEmpty
                            ? NetworkImage(userProvider.profileController.text)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: userProvider.profileController.text.isEmpty
                            ? Icon(Icons.add_a_photo, color: Colors.grey[600], size: 50)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Birth Date",
                            style: TextStyle(
                                color: selectedThemeData.canvasColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                    SizedBox(height: 5),
                    TextFormField(
                      cursorColor: const Color(0xFFE50914),
                      controller: userProvider.dobController,
                      readOnly: true,
                      onTap: (){
                        _selectDate(userProvider);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: selectedThemeData.cardColor,
                        hintText: "Enter Birth Date",
                        hintStyle: TextStyle(
                          color: selectedThemeData.canvasColor,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: selectedThemeData.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: userProvider.countryController,
                      hintText: "Enter Country",
                      label: "Country",
                      textInputType: TextInputType.text,
                      capitalization: TextCapitalization.characters,
                      isValidator: true,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: userProvider.stateController,
                      hintText: "Enter State",
                      label: "State",
                      textInputType: TextInputType.text,
                      capitalization: TextCapitalization.characters,
                      isValidator: true,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: userProvider.districtController,
                      hintText: "Enter District",
                      label: "District",
                      textInputType: TextInputType.text,
                      capitalization: TextCapitalization.characters,
                      isValidator: true,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: userProvider.talukaController,
                      hintText: "Enter Taluka",
                      label: "Taluka",
                      textInputType: TextInputType.text,
                      capitalization: TextCapitalization.characters,
                      isValidator: true,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: userProvider.refferedByController,
                      hintText: "Enter referral code",
                      label: "Referral Code (optional)",
                      textInputType: TextInputType.text,
                      capitalization: TextCapitalization.characters,
                      isValidator: false,
                    ),
                    SizedBox(height: 10),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Join Date",
                            style: TextStyle(
                                color: selectedThemeData.canvasColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                    SizedBox(height: 5),
                    TextFormField(
                      cursorColor: const Color(0xFFE50914),
                      controller: userProvider.joinDateController,
                      readOnly: true,
                      onTap: (){
                        _selectJoinDate(userProvider);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: selectedThemeData.cardColor,
                        hintText: "Enter Join Date",
                        hintStyle: TextStyle(
                          color: selectedThemeData.canvasColor,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                          const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: selectedThemeData.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    SizedBox(height: 10),
                    //
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Preferred Languages (at least 3)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: GridView.builder(
                        itemCount: languageProvider.allLanguages.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          ResponsiveWidget.isMobile(context) ? 2 : 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 5 / 1.5,
                        ),
                        itemBuilder: (context, index) {
                          final language = languageProvider.allLanguages[index];
                          return ElevatedButton(
                            onPressed: () => _toggleSelection(language,userProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              userProvider.selectedLanguages.contains(language)
                                  ? selectedThemeData.primaryColor
                                  : selectedThemeData.cardColor,
                              foregroundColor:
                              userProvider.selectedLanguages.contains(language)
                                  ? Colors.white
                                  : selectedThemeData.canvasColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(language,
                                overflow: TextOverflow.ellipsis),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedThemeData.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: (){
                        _saveLanguages(userProvider);
                      },
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
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

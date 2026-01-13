import 'package:admin_ott/app/provider/mediaHouseProvider.dart';
import 'package:admin_ott/app/provider/userProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../widgets/show_toast.dart';

class AddMediaHouseWidget extends StatefulWidget {
  const AddMediaHouseWidget({super.key});

  @override
  State<AddMediaHouseWidget> createState() => _AddMediaHouseWidgetState();
}

class _AddMediaHouseWidgetState extends State<AddMediaHouseWidget> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  getUserData() async {
    MediaHouseProvider userProvider =
    Provider.of<MediaHouseProvider>(context, listen: false);
   await  userProvider.fetchUsers();
    if (userProvider.users.isNotEmpty) {
      _selectedUser =
          userProvider.users.first; // Optional: Set default to the first user
    }
  }
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);

    var selectedThemeData = themeProvider.getTheme;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedThemeData.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Consumer<MediaHouseProvider>(
            builder: (context, mediaHouseProvider, child) {
          return SizedBox(
            width: ResponsiveWidget.isMobile(context)?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width-700,
            child: Column(
              children: [
                // Header with navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.remove_circle_outline_sharp,
                            color: selectedThemeData.canvasColor)),
                    if (_currentPage > 0)
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: selectedThemeData.canvasColor),
                        onPressed: _previousPage,
                      ),
                    Text(
                      "Add Video - Step ${_currentPage + 1} of 3",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: selectedThemeData.canvasColor,
                      ),
                    ),
                    if (_currentPage < 2)
                      IconButton(
                        icon: Icon(Icons.arrow_forward,
                            color: selectedThemeData.canvasColor),
                        onPressed: _nextPage,
                      ),
                  ],
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildBasicInfoSlide(selectedThemeData),
                      _buildUploadFilesSlide(selectedThemeData),
                      _buildPricingSlide(selectedThemeData),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == 2) {
                      print("On click method called");
                      print(mediaHouseProvider.gstController.text +
                          mediaHouseProvider.panCardController.text +
                          mediaHouseProvider.adharCardController.text);
                      _handleAdd(mediaHouseProvider);
                    } else {
                      _nextPage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    _currentPage == 2 ? "Submit" : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _handleAdd(MediaHouseProvider provider) async {

    var result = await provider.createMediaHouse(_selectedUser!.id!,context);
    if (result['success'] == true) {
      print(result['message']);
      CustomToast.show(result['message'].toString());
      provider.fetchMediaHouse();
      Navigator.of(context).pop();
    } else {
      print('Failure: ${result['message']}');
      CustomToast.show(result['message'].toString());
    }
  }

  Widget _buildBasicInfoSlide(ThemeData themeData) {
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {

      return ListView(
        children: [
          CustomTextField(
            controller: provider.mediaHouseNameController,
            hintText: "Media House Name",
            textInputType: TextInputType.text,
          ),
          CustomTextField(
            controller: provider.descriptionController,
            hintText: "Description",
            textInputType: TextInputType.text,
          ),
          CustomTextField(
            controller: provider.emailController,
            hintText: "Email id",
            textInputType: TextInputType.emailAddress,
          ),
          CustomTextField(
            controller: provider.mobileController,
            hintText: "Mobile Number",
            textInputType: TextInputType.number,
          ),
          _buildUserDropdownField('Contact Person', context, provider.users,themeData),
        ],
      );
    });
  }

  Widget _buildUploadFilesSlide(ThemeData themeData) {
    return ListView(
      children: [
        _buildUploadSection("Media House Logo", themeData),
        _buildUploadSection("Aadhaar Card", themeData),
        _buildUploadSection("Pan Card", themeData),
        _buildUploadSection("Shop Act", themeData),
        _buildUploadSection("GST Certificate", themeData),
        _buildUploadSection("Registration Certificate", themeData),
        /*  ...List.generate(3, (index) {
          return _buildUploadSection("Poster ${index + 1}", themeData);
        }),*/
      ],
    );
  }

  Widget _buildPricingSlide(ThemeData themeData) {
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      return ListView(
        children: [
          CustomTextField(
            controller: provider.officeBuildingController,
            hintText: "Address Area",
            textInputType: TextInputType.text,
          ),
          CustomTextField(
            controller: provider.countryController,
            hintText: "Country",
            textInputType: TextInputType.text,
          ),
          CustomTextField(
            controller: provider.stateController,
            hintText: "State",
            textInputType: TextInputType.emailAddress,
          ),
          CustomTextField(
            controller: provider.districtController,
            hintText: "District",
            textInputType: TextInputType.number,
          ),
          CustomTextField(
            controller: provider.talukaController,
            hintText: "Taluka",
            textInputType: TextInputType.number,
          ),
        ],
      );
    });
  }

  User? _selectedUser;

  Widget _buildUserDropdownField(
      String label,
      BuildContext context,
      List<User> users,
      ThemeData themeData,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<User>(
          value: _selectedUser,
          items: users.map((User user) {
            return DropdownMenuItem<User>(
              value: user,
              child: Text(
                "${user.firstName} ${user.lastName}",
                style: themeData.textTheme.bodyMedium, // Apply theme's text style
              ),
            );
          }).toList(),
          onChanged: (User? selectedUser) {
            setState(() {
              _selectedUser = selectedUser; // Update the selected user
            });
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: themeData.textTheme.bodyMedium, // Theme's label text style
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              borderSide: BorderSide(color: themeData.dividerColor), // Theme divider color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeData.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeData.primaryColor, width: 2), // Highlight color
            ),
          ),
          dropdownColor: themeData.cardColor, // Apply theme's card color
          hint: Text(
            "Select a user",
            style: themeData.textTheme.bodySmall, // Theme's hint text style
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUploadSection(String label, ThemeData selectedThemeData) {
    return Consumer<MediaHouseProvider>(builder: (context, provider, child) {
      // Determine the container color based on the file upload status
      Color containerColor =  selectedThemeData.primaryColor.withOpacity(0.5); // Default color
      if("Media House Logo"== label){
        if(provider.profileController.text.isEmpty || provider.profileController.text=='')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else
      if("Aadhaar Card"== label){
        if(provider.adharCardController.text.isEmpty || provider.adharCardController.text=='')
            containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else if("Pan Card"==label){
        if(provider.panCardController.text.isEmpty || provider.panCardController.text=='')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else if("Shop Act"==label){
        if(provider.shopActController.text.isEmpty || provider.shopActController.text=='')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else if("GST Certificate"==label){
        if(provider.gstController.text.isEmpty || provider.gstController.text=='')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else if("Registration Certificate"==label){
        if(provider.registrationCertificateController.text.isEmpty || provider.registrationCertificateController.text=='')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else if("Registration Certificate"==label){
        if(provider.registrationCertificateController.text.isEmpty || provider.registrationCertificateController.text=='')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      }else{
          containerColor = Colors.green.shade500;
      }


      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () async {
            await provider.pickImage(label);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: selectedThemeData.canvasColor),
                ),
                child: Center(
                  child: provider.isUploading
                      ? CircularProgressIndicator()
                      : Text(
                    "Upload $label",
                    style: TextStyle(
                      color: selectedThemeData.canvasColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
             /* if (kIsWeb && provider.webFile != null)
                Text('$label: ${provider.webFile!.name}'),*/
            ],
          ),
        ),
      );
    });
  }

}

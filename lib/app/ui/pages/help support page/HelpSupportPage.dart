import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import '../../../../device/utils/ResponsiveWidget.dart';
import '../../../provider/userProvider.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _selectedImage;
  List<Map<String, dynamic>> _queryHistory = [];

  @override
  void initState() {
    super.initState();
    _loadQueryHistory();
  }

  Future<void> _loadQueryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('query_history');
    if (historyString != null) {
      setState(() {
        _queryHistory =
            List<Map<String, dynamic>>.from(json.decode(historyString));
      });
    }
  }

  Future<void> _saveQuery() async {
    if (_queryController.text.isEmpty) return;
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(now);

    final newQuery = {
      'text': _queryController.text,
      'image': _selectedImage?.path,
      'mobile number': _contactNumberController.text,
      'email': _emailController.text,
      'date': formattedDate,
    };
    setState(() {
      _queryHistory.insert(0, newQuery);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('query_history', json.encode(_queryHistory));
    _queryController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _deleteQuery(int index) async {
    setState(() {
      _queryHistory.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('query_history', json.encode(_queryHistory));
  }

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Help & Support',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: selectedThemeData.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            width: ResponsiveWidget.isMobile(context) ? double.infinity : 500,
            child: Column(
              children: [
                //Text(),
                CustomTextField(
                  controller: _contactNumberController,
                  hintText: userProvider.user.mobileNumber??"",
                  textInputType: TextInputType.number,
                  readOnly: true,
                ),
                CustomTextField(
                  controller: _emailController,
                  hintText: userProvider.user.emailId??"",
                  textInputType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                CustomTextField(
                  controller: _queryController,
                  hintText: 'Enter your query',
                  textInputType: TextInputType.multiline,
                  maxLine: 3,
                ),
                SizedBox(height: 10),
                _selectedImage != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_selectedImage!, height: 100),
                          ),
                          TextButton.icon(
                            onPressed: _removeImage,
                            icon: Icon(
                              Icons.delete,
                              color: selectedThemeData.primaryColor,
                            ),
                            label: Text(
                              'Remove',
                              style: TextStyle(
                                color: selectedThemeData.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedThemeData.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                          ),
                          child: Center(child: Text('Attach Image')),
                        ),
                      ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveQuery,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _queryHistory.length,
                    itemBuilder: (context, index) {
                      final query = _queryHistory[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return _displayDetails(context, query);
                                },
                              );
                            },
                            child: Card(
                              color: selectedThemeData.cardColor,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: query['image'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(File(query['image']),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover),
                                      )
                                    : Icon(Icons.help_outline,
                                        color: selectedThemeData.primaryColor),
                                title: Text(query['text'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      query['date'],
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_outlined,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'sent',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                // SizedBox(
                                //   width: 1,
                                // ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: selectedThemeData.primaryColor,
                                    size: 18,
                                  ),
                                  onPressed: () => _deleteQuery(index),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _displayDetails(BuildContext context, Map<String, dynamic> query) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    int selectedRating = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        final userProvider = Provider.of<UserProvider>(context);
        return AlertDialog(
          backgroundColor: selectedThemeData.cardColor,
          title: Column(
            children: [
              Text(userProvider.user.mobileNumber??""),
              Text(userProvider.user.emailId??''),
              // Text(query['mobile number']),
              // Text(query['email']),
            ],
          ),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          content: ListTile(
            leading: query['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(query['image']),
                        width: 50, height: 50, fit: BoxFit.cover),
                  )
                : Icon(Icons.help_outline,
                    color: selectedThemeData.primaryColor),
            title: Text(query['text'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  query['date'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedThemeData.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop(selectedRating); // Return the rating
              },
              child: Text(
                "Close",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

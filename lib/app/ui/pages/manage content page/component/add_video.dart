import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/setPercentageDialog.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../widgets/show_toast.dart';
import 'multi_select_dailog.dart';

class AddDataWidget extends StatefulWidget {
  const AddDataWidget({super.key});

  @override
  State<AddDataWidget> createState() => _AddDataWidgetState();
}

class _AddDataWidgetState extends State<AddDataWidget> {
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
    getMediaHouse();
  }

  void getMediaHouse() async {
    VideoProvider videoProvider =
        Provider.of<VideoProvider>(context, listen: false);
    await videoProvider.fetchMediaHouse();
    if (videoProvider.mediaHouseList.isNotEmpty) {
      _selectedMediaHouse = videoProvider
          .mediaHouseList.first; // Optional: Set default to the first user
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
        child: Consumer<VideoProvider>(builder: (context, provider, child) {
          return SizedBox(
            width: ResponsiveWidget.isMobile(context)
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width - 700,
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
                      _handleAdd(
                          provider, selectedThemeData, _selectedMediaHouse);
                    } else {
                      // Validate title, price, and release date
                      String releaseDate =
                          provider.releaseDateController.text.trim();
                      String title = provider.titleController.text.trim();
                      String movieUrl = provider.movieUrlController.text.trim();
                      String trailerUrl =
                          provider.trailerUrlController.text.trim();
                      String priceText = provider.priceController.text.trim();
                      double? price = double.tryParse(priceText);

                      /*  if (releaseDate.isEmpty || title.isEmpty || price == null || price <= 0) {
                        CustomToast.show(
                          "Please enter valid title, price, and release date.",
                          isSuccess: false,
                        );
                        return;
                      }
*/
                      if (_currentPage == 1) {
                        if (movieUrl.isEmpty || trailerUrl.isEmpty) {
                          CustomToast.show(
                            "Please upload movie url and trailer url",
                            isSuccess: false,
                          );
                          return;
                        }
                      }
                      // Parse and compare the release date
                      try {
                        DateTime currentDate = DateTime.now();
                        DateTime targetDate = DateTime.parse(releaseDate);

                        if (targetDate.isAfter(currentDate)) {
                          provider.toggleFeatured(true);
                        } else {
                          provider.toggleFeatured(false);
                        }
                        _nextPage();
                      } catch (e) {
                        CustomToast.show(
                          "Invalid release date format. Please correct it.",
                          isSuccess: false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 30),
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

  Widget _buildBasicInfoSlide(ThemeData themeData) {
    return Consumer<VideoProvider>(builder: (context, provider, child) {
      return ListView(
        children: [
          CustomTextField(
            controller: provider.titleController,
            hintText: "Video Name",
            textInputType: TextInputType.text,
          ),
          CustomTextField(
            controller: provider.descriptionController,
            hintText: "Description",
            textInputType: TextInputType.text,
          ),
          CustomTextField(
            controller: provider.releaseDateController,
            hintText: "Release Date (e.g., 2019-04-26)",
            textInputType: TextInputType.datetime,
          ),
          CustomTextField(
            controller: provider.runTimeController,
            hintText: "Runtime (e.g., 181 minutes)",
            textInputType: TextInputType.number,
          ),
          CustomTextField(
            controller: provider.priceController,
            hintText: "Price (e.g., 300)",
            textInputType: TextInputType.text,
          ),
          _buildDropdownField(
              'Age Rating',
              [
                'U (Universal)',
                'U/A (Parental Guidance for Children Below 12)',
                'A (Adults Only)',
                'S (Restricted to a Special Class of Persons)'
              ],
              context,
              provider,
              themeData),
          _buildDropdownField(
              'Type', ['MOVIE', 'SERIES', 'SHORT_FILM'], context, provider, themeData),
          _buildDropdownField(
              'Rental Duration',
              [
                "One Time",
                "One Day",
                "Two Day",
                "Three Day",
                "One Week",
                "Two Week",
                "One Month",
                "Three Month",
                "Six Month",
                "One Year",
                "Lifetime",
              ],
              context,
              provider,
              themeData),
        ],
      );
    });
  }

  Widget _buildUploadFilesSlide(ThemeData themeData) {
    return ListView(
      children: [
        _builtMultiValueTextField("Cast", themeData),
        _builtMultiValueTextField("Director", themeData),
        _buildUploadSection("Trailer File", themeData),
        _buildUploadSection("Movie File", themeData),
        _buildUploadSection("Censor Certificate", themeData),
        ...List.generate(3, (index) {
          return _buildUploadSection("Poster ${index + 1}", themeData);
        }),
      ],
    );
  }

  Widget _buildPricingSlide(ThemeData themeData) {
    return Consumer<VideoProvider>(builder: (context, provider, child) {
      return ListView(
        children: [
          _buildMultiSelectDropdownField(
              'Genres',
              [
                'Action',
                'Drama',
                'Comedy',
                'Thriller',
                'Horror',
                'Romance',
                'Sci-Fi',
                'Fantasy',
                'Mystery',
                'Documentary',
                'Animation',
                'Adventure',
                'Musical',
                'Historical',
                'Crime'
              ],
              context,
              themeData),
          _buildMultiSelectDropdownField(
              'Audio Formats',
              [
                'Stereo',
                'Dolby',
                'Mono',
                'Surround Sound',
                'Dolby Atmos',
                'Dolby Digital (AC-3)'
              ],
              context,
              themeData),
          _buildMultiSelectDropdownField(
              'Subtitle Languages',
              [
                'Hindi',
                'English',
                'Bengali',
                'Marathi',
                'Telugu',
                'Tamil',
                'Gujarati',
                'Urdu',
                'Kannada',
                'Odia',
                'Malayalam',
                'Punjabi',
                'Assamese',
                'Rajasthani',
                'Bhojpuri',
                'Sindhi',
                'Konkani',
                'Maithili',
                'Santali',
                'Manipuri',
                'Kashmiri',
                'Dogri',
                'Tulu',
                'Mizo',
                'Bodo'
              ],
              context,
              themeData),
          _buildMultiSelectDropdownField(
              'Languages',
              [
                'Hindi',
                'English',
                'Bengali',
                'Marathi',
                'Telugu',
                'Tamil',
                'Gujarati',
                'Urdu',
                'Kannada',
                'Odia',
                'Malayalam',
                'Punjabi',
                'Assamese',
                'Rajasthani',
                'Bhojpuri',
                'Sindhi',
                'Konkani',
                'Maithili',
                'Santali',
                'Manipuri',
                'Kashmiri',
                'Dogri',
                'Tulu',
                'Mizo',
                'Bodo'
              ],
              context,
              themeData),
          const SizedBox(height: 16),
          _buildUserDropdownField(
              'Contact Person', context, provider.mediaHouseList, themeData),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Is Downloadable'),
              const Spacer(),
              Switch(
                value: provider.isDownloadable,
                onChanged: (value) {
                  provider.toggleDownloadable(value);
                },
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade300,
              )
            ],
          ),
          Row(
            children: [
              const Text('Is Featured'),
              const Spacer(),
              Switch(
                value: provider.isFeatured,
                onChanged: (value) {
                  provider.toggleFeatured(value);
                },
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade300,
              )
            ],
          ),
        ],
      );
    });
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    BuildContext context,
    VideoProvider provider,
    ThemeData themeData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label for the dropdown
        Text(
          label,
          style: themeData.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          hint: Text(
            "Select $label",
            style: themeData.textTheme.bodySmall?.copyWith(fontSize: 14),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: themeData.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: themeData.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            provider.dropDownSelection(value!, label);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: themeData.dividerColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: themeData.primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: themeData.colorScheme.surface,
          ),
          dropdownColor: themeData.colorScheme.background,
          icon: Icon(
            Icons.arrow_drop_down,
            color: themeData.iconTheme.color,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMultiSelectDropdownField(
    String label,
    List<String> items,
    BuildContext context,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add label for the dropdown
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            // Show the multi-select dialog
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return MultiSelectDialog(
                  label: label,
                  items: items,
                  theme: theme,
                );
              },
            );
          },
          child: Consumer<VideoProvider>(
            builder: (context, provider, child) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                  color: theme.colorScheme.surface,
                ),
                child: Text(
                  _getDisplayText(label, provider),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getDisplayText(String label, VideoProvider provider) {
    if (label == "Genres") {
      return provider.selectedGeners.isNotEmpty
          ? provider.selectedGeners.join(', ')
          : 'Select $label';
    } else if (label == "Audio Formats") {
      return provider.selectedAudioFormat.isNotEmpty
          ? provider.selectedAudioFormat.join(', ')
          : 'Select $label';
    } else if (label == "Subtitle Languages") {
      return provider.selectedSubLanguages.isNotEmpty
          ? provider.selectedSubLanguages.join(', ')
          : 'Select $label';
    } else {
      return provider.selectedLanguages.isNotEmpty
          ? provider.selectedLanguages.join(', ')
          : 'Select $label';
    }
  }

  Widget _builtMultiValueTextField(String label, ThemeData selectedThemeData) {
    return Consumer<VideoProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: label == "Cast"
                  ? provider.castController
                  : provider.directorController,
              decoration: InputDecoration(
                labelText: "Enter $label names separated by commas",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    provider.addValuesToList(label);
                  },
                ),
              ),
              onChanged: (value) {
                if (value.contains(',')) {
                  provider.addValuesToList(label);
                }
              },
              onSubmitted: (_) => provider.addValuesToList(label),
            ),
            const SizedBox(height: 8),
            // Display the list
            if (label == "Cast" && provider.castList.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: provider.castList
                    .map(
                      (item) => Chip(
                        label: Text(
                          item,
                          style:
                              selectedThemeData.textTheme.bodyMedium?.copyWith(
                            color: selectedThemeData.colorScheme.onPrimary,
                          ),
                        ),
                        backgroundColor: selectedThemeData.colorScheme.primary,
                        deleteIconColor:
                            selectedThemeData.colorScheme.onPrimary,
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          provider.castList.remove(item);
                          provider.notifyListeners();
                        },
                      ),
                    )
                    .toList(),
              ),
            if (label == "Director" && provider.directorList.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: provider.directorList
                    .map(
                      (item) => Chip(
                        label: Text(
                          item,
                          style:
                              selectedThemeData.textTheme.bodyMedium?.copyWith(
                            color: selectedThemeData.colorScheme.onPrimary,
                          ),
                        ),
                        backgroundColor: selectedThemeData.colorScheme.primary,
                        deleteIconColor:
                            selectedThemeData.colorScheme.onPrimary,
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          provider.directorList.remove(item);
                          provider.notifyListeners();
                        },
                      ),
                    )
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUploadSection(String label, ThemeData selectedThemeData) {
    return Consumer<VideoProvider>(builder: (context, provider, child) {
      Color containerColor =
          selectedThemeData.primaryColor.withOpacity(0.5); // Default color

      if ("Trailer File" == label) {
        if (provider.trailerUrlController.text.isEmpty ||
            provider.trailerUrlController.text == '')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      } else if ("Movie File" == label) {
        if (provider.movieUrlController.text.isEmpty ||
            provider.movieUrlController.text == '')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      } else if ("Censor Certificate" == label) {
        if (provider.censorCertificateController.text.isEmpty ||
            provider.censorCertificateController.text == '')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      } else if ("Poster 1" == label) {
        if (provider.poster1Controller.text.isEmpty ||
            provider.poster1Controller.text == '')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      } else if ("Poster 2" == label) {
        if (provider.poster2Controller.text.isEmpty ||
            provider.poster2Controller.text == '')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      } else if ("Poster 3" == label) {
        if (provider.poster3Controller.text.isEmpty ||
            provider.poster3Controller.text == '')
          containerColor = containerColor;
        else
          containerColor = Colors.green.shade500;
      } else {
        containerColor = Colors.green.shade500;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () async {
            if (label == "Movie File" || label == "Trailer File") {
              provider.uploadVideo(label == "Trailer File" ? true : false);
            } else {
              await provider.pickImage(label);
            }
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
                      ? const AppSpinner()
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

  MediaHouse? _selectedMediaHouse;

  Widget _buildUserDropdownField(
    String label,
    BuildContext context,
    List<MediaHouse> mediaHouseList,
    ThemeData themeData,
  ) {
    print("${mediaHouseList.length} Length");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<MediaHouse>(
          value: _selectedMediaHouse,
          items: mediaHouseList.map((MediaHouse mediaHouse) {
            return DropdownMenuItem<MediaHouse>(
              value: mediaHouse,
              child: Text(
                mediaHouse.mediaHouseName!,
                style:
                    themeData.textTheme.bodyMedium, // Apply theme's text style
              ),
            );
          }).toList(),
          onChanged: (MediaHouse? selectedMediaHouse) {
            setState(() {
              _selectedMediaHouse =
                  selectedMediaHouse; // Update the selected Production house
            });
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: themeData
                .textTheme.bodyMedium, // Apply theme's label text style
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8), // Rounded corners for input field
              borderSide: BorderSide(
                  color: themeData.dividerColor), // Theme's divider color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeData.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: themeData.primaryColor, width: 2), // Highlight color
            ),
          ),
          dropdownColor: themeData.cardColor, // Apply theme's card color
          hint: Text(
            "Select MediaHouse",
            style:
                themeData.textTheme.bodySmall, // Apply theme's hint text style
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleAdd(VideoProvider provider, ThemeData selectedThemeData,
      MediaHouse? selectedMediaHouse) async {
    Content? content =
        await provider.uploadContent(selectedMediaHouse!, context);
    if (content != null) {
      await showSetPercentageDialog(context, content, selectedMediaHouse!);
    } else {
      CustomToast.show("Failed to add content.");
    }
  }

  showSetPercentageDialog(
      BuildContext context, Content content, MediaHouse mediaHouse) async {
    final double? result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return SetPercentageDialog(content: content, mediaHouse: mediaHouse);
      },
    );

    if (result != null) {
      debugPrint("Selected Percentage: ${result.toInt()}%");
      // Handle the selected percentage as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected Percentage: ${result.toInt()}%")),
      );
    }
  }
}

import 'dart:typed_data';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/setPercentageDialog.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/data/repositories/cast_repository.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../widgets/show_toast.dart';
import 'multi_select_dailog.dart';

class AddDataWidget extends StatefulWidget {
  final Content? editingContent;

  const AddDataWidget({super.key, this.editingContent});

  @override
  State<AddDataWidget> createState() => _AddDataWidgetState();
}

class _AddDataWidgetState extends State<AddDataWidget> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _castNameController = TextEditingController();
  final TextEditingController _castRoleController = TextEditingController();

  int _currentPage = 0;
  bool _isSaving = false;
  MediaHouse? _selectedMediaHouse;

  bool get _isEditing => widget.editingContent != null;

  String get _contentTypeLabel {
    final rawType = widget.editingContent?.type ??
        Provider.of<VideoProvider>(context, listen: false).typeController.text;
    switch (rawType.toUpperCase()) {
      case 'SERIES':
        return 'Series';
      case 'MINI_SERIES':
      case 'MINISERIES':
        return 'Mini Series';
      case 'SHORT_FILM':
      case 'SHORTFILM':
        return 'Short Film';
      case 'MOVIE':
      default:
        return 'Movie';
    }
  }

  String get _stepTitle {
    switch (_currentPage) {
      case 0:
        return 'Language, Details & Cast';
      case 1:
        return 'Video & Pricing Details';
      case 2:
      default:
        return 'Upload Files & Settings';
    }
  }

  @override
  void initState() {
    super.initState();
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    if (widget.editingContent != null) {
      videoProvider.populateContentForm(widget.editingContent!);
      _loadCastIfEmpty(widget.editingContent!);
    } else {
      videoProvider.resetContentForm();
    }
    _fetchMediaHouses();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _castNameController.dispose();
    _castRoleController.dispose();
    super.dispose();
  }

  void _loadCastIfEmpty(Content content) async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    if (videoProvider.castList.isEmpty && content.id != null) {
      try {
        final castRepo = CastRepository();
        final list = await castRepo.getCastForContent(
          contentType: content.type ?? 'MOVIE',
          contentId: content.id!,
        );
        if (list.isNotEmpty && mounted) {
          for (final c in list) {
            final name = c.name ?? '';
            final role = c.role ?? '';
            if (name.isNotEmpty) {
              final entry = role.isNotEmpty ? "$name ($role)" : name;
              if (!videoProvider.castList.contains(entry)) {
                videoProvider.castList.add(entry);
              }
            }
          }
          videoProvider.notifyListeners();
          setState(() {});
        }
      } catch (e) {
        debugPrint("Error fetching additional cast: $e");
      }
    }
  }

  void _fetchMediaHouses() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    await videoProvider.fetchMediaHouse();
    if (videoProvider.mediaHouseList.isNotEmpty) {
      final editingMediaHouseId = widget.editingContent?.mediaHouseId;
      final editingMediaHouseName = widget.editingContent?.mediaHouseName;
      _selectedMediaHouse = videoProvider.mediaHouseList.firstWhere(
        (mediaHouse) =>
            (editingMediaHouseId != null && mediaHouse.id == editingMediaHouseId) ||
            (editingMediaHouseName != null &&
                mediaHouse.mediaHouseName?.toLowerCase() == editingMediaHouseName.toLowerCase()),
        orElse: () => videoProvider.mediaHouseList.first,
      );
      if (mounted) setState(() {});
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  void _handleClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeData = themeProvider.getTheme;
    final isMobile = ResponsiveWidget.isMobile(context);

    return Scaffold(
      backgroundColor: selectedThemeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 960),
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 8.0 : 24.0,
              vertical: isMobile ? 8.0 : 16.0,
            ),
            decoration: BoxDecoration(
              color: selectedThemeData.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Consumer<VideoProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      _buildHeader(selectedThemeData),
                      _buildProgressBar(selectedThemeData),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStep1LanguageDetailsCast(selectedThemeData, provider),
                            _buildStep2VideoPricing(selectedThemeData, provider),
                            _buildStep3UploadFiles(selectedThemeData, provider),
                          ],
                        ),
                      ),
                      _buildBottomActionBar(selectedThemeData, provider),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final redColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: _handleClose,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                child: Icon(Icons.close, size: 18, color: theme.canvasColor),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEditing ? "Edit $_contentTypeLabel" : "Add Content",
                style: TextStyle(
                  color: redColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _stepTitle,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Step ${_currentPage + 1}/3",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final redColor = theme.primaryColor;
    final inactiveColor = theme.dividerColor.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: List.generate(3, (index) {
          final isPassedOrCurrent = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
              decoration: BoxDecoration(
                color: isPassedOrCurrent ? redColor : inactiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCardContainer({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, ThemeData theme, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: theme.canvasColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: theme.canvasColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor.withValues(alpha: 0.7), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSingleDropdown({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
    required ThemeData theme,
  }) {
    final effectiveItems = List<String>.from(items);
    String? matchedValue;

    if (selectedValue != null && selectedValue.trim().isNotEmpty) {
      final trimmed = selectedValue.trim();
      final index = effectiveItems.indexWhere(
        (item) => item.toLowerCase() == trimmed.toLowerCase(),
      );
      if (index >= 0) {
        matchedValue = effectiveItems[index];
      } else {
        effectiveItems.insert(0, trimmed);
        matchedValue = trimmed;
      }
    } else if (effectiveItems.isNotEmpty) {
      matchedValue = effectiveItems.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, theme),
        DropdownButtonFormField<String>(
          value: matchedValue,
          items: effectiveItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: theme.canvasColor, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: theme.cardColor,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> allItems,
    required List<String> selectedItems,
    required BuildContext context,
    required ThemeData theme,
  }) {
    final displayText = selectedItems.isNotEmpty ? selectedItems.join(', ') : 'Select $label';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, theme),
        InkWell(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (_) => MultiSelectDialog(
                label: label,
                items: allItems,
                theme: theme,
              ),
            );
            setState(() {});
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedItems.isNotEmpty ? theme.canvasColor : theme.hintColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 1: Language, Details & Cast
  Widget _buildStep1LanguageDetailsCast(ThemeData theme, VideoProvider provider) {
    final availableLanguages = [
      'Marathi',
      'Hindi',
      'English',
      'Bengali',
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
    ];

    final ageRatings = [
      'U (Universal)',
      'U/A (Parental Guidance for Children Below 12)',
      'A (Adults Only)',
      'S (Restricted to a Special Class of Persons)'
    ];

    final availableGenres = [
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
    ];

    String? currentLanguage;
    if (provider.selectedLanguages.isNotEmpty) {
      currentLanguage = provider.selectedLanguages.first;
    } else if (widget.editingContent?.languageList?.isNotEmpty == true) {
      currentLanguage = widget.editingContent!.languageList!.first;
    } else {
      currentLanguage = 'Marathi';
    }

    String? currentAgeRating;
    if (provider.ageRatingController.text.trim().isNotEmpty) {
      currentAgeRating = provider.ageRatingController.text.trim();
    } else if (widget.editingContent?.ageRating != null &&
        widget.editingContent!.ageRating!.trim().isNotEmpty) {
      currentAgeRating = widget.editingContent!.ageRating!.trim();
    } else {
      currentAgeRating = ageRatings.first;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildCardContainer(
          theme: theme,
          title: "Language & Basic Details",
          children: [
            _buildSingleDropdown(
              label: "Languages",
              items: availableLanguages,
              selectedValue: currentLanguage,
              onChanged: (val) {
                if (val != null) {
                  provider.selectedLanguages
                    ..clear()
                    ..add(val);
                  provider.notifyListeners();
                }
              },
              theme: theme,
            ),
            const SizedBox(height: 14),
            _buildFieldLabel("Title", theme, isRequired: true),
            _buildInputField(
              controller: provider.titleController,
              hintText: "Enter title",
              theme: theme,
            ),
            const SizedBox(height: 14),
            _buildFieldLabel("Description", theme),
            _buildInputField(
              controller: provider.descriptionController,
              hintText: "Enter description",
              theme: theme,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel("Release Date", theme),
                      _buildInputField(
                        controller: provider.releaseDateController,
                        hintText: "e.g. 2026-04-24",
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel("Runtime (minutes)", theme),
                      _buildInputField(
                        controller: provider.runTimeController,
                        hintText: "e.g. 120",
                        theme: theme,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildCardContainer(
          theme: theme,
          title: "Cast And Crew",
          children: [
            Text(
              "Cast",
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildFieldLabel("Cast Name", theme, isRequired: true),
            _buildInputField(
              controller: _castNameController,
              hintText: "Enter cast name",
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildFieldLabel("Cast Role", theme),
            _buildInputField(
              controller: _castRoleController,
              hintText: "Enter cast role",
              theme: theme,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = _castNameController.text.trim();
                  final role = _castRoleController.text.trim();
                  if (name.isNotEmpty) {
                    final entry = role.isNotEmpty ? "$name ($role)" : name;
                    provider.castList.add(entry);
                    _castNameController.clear();
                    _castRoleController.clear();
                    provider.notifyListeners();
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text("Add Cast", style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
            if (provider.castList.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: provider.castList.map((cast) {
                  return Chip(
                    label: Text(cast, style: const TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.9),
                    deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                    onDeleted: () {
                      provider.castList.remove(cast);
                      provider.notifyListeners();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              "Director",
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFieldLabel("Director Name(s)", theme),
            TextField(
              controller: provider.directorController,
              decoration: InputDecoration(
                hintText: "Enter director names separated by commas",
                hintStyle: TextStyle(color: theme.hintColor.withValues(alpha: 0.7), fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    provider.addValuesToList("Director");
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                if (value.contains(',')) {
                  provider.addValuesToList("Director");
                  setState(() {});
                }
              },
              onSubmitted: (_) {
                provider.addValuesToList("Director");
                setState(() {});
              },
            ),
            if (provider.directorList.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: provider.directorList.map((director) {
                  return Chip(
                    label: Text(director, style: const TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.9),
                    deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                    onDeleted: () {
                      provider.directorList.remove(director);
                      provider.notifyListeners();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        _buildCardContainer(
          theme: theme,
          title: "Classification",
          children: [
            _buildSingleDropdown(
              label: "Age Rating",
              items: ageRatings,
              selectedValue: currentAgeRating,
              onChanged: (val) {
                if (val != null) {
                  provider.ageRatingController.text = val;
                  provider.notifyListeners();
                }
              },
              theme: theme,
            ),
            const SizedBox(height: 14),
            _buildMultiSelectField(
              label: "Genres",
              allItems: availableGenres,
              selectedItems: provider.selectedGeners,
              context: context,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  // STEP 2: Video & Pricing Details
  Widget _buildStep2VideoPricing(ThemeData theme, VideoProvider provider) {
    final rentalDurations = [
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
    ];

    final contentTypes = [
      'MOVIE',
      'SERIES',
      'MINI_SERIES',
      'SHORT_FILM',
    ];

    final audioFormats = [
      'Stereo',
      'Dolby',
      'Mono',
      'Surround Sound',
      'Dolby Atmos',
      'Dolby Digital (AC-3)'
    ];

    final subtitleLanguages = [
      'English',
      'Hindi',
      'Marathi',
      'Bengali',
      'Telugu',
      'Tamil',
      'Gujarati',
      'Urdu',
      'Kannada',
      'Malayalam',
      'Punjabi',
    ];

    String? currentRentalDuration;
    if (provider.rentalDurationController.text.trim().isNotEmpty) {
      currentRentalDuration = provider.rentalDurationController.text.trim();
    } else if (widget.editingContent?.rentlDuration != null &&
        widget.editingContent!.rentlDuration!.trim().isNotEmpty) {
      currentRentalDuration = widget.editingContent!.rentlDuration!.trim();
    } else {
      currentRentalDuration = "Lifetime";
    }

    String? currentType;
    if (provider.typeController.text.trim().isNotEmpty) {
      currentType = provider.typeController.text.trim().toUpperCase();
    } else if (widget.editingContent?.type != null &&
        widget.editingContent!.type!.trim().isNotEmpty) {
      currentType = widget.editingContent!.type!.trim().toUpperCase();
    } else {
      currentType = 'MOVIE';
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildCardContainer(
          theme: theme,
          title: "Pricing & Media House",
          children: [
            _buildFieldLabel("Price (INR)", theme, isRequired: true),
            _buildInputField(
              controller: provider.priceController,
              hintText: "e.g. 300",
              theme: theme,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildSingleDropdown(
              label: "Rental Duration",
              items: rentalDurations,
              selectedValue: currentRentalDuration,
              onChanged: (val) {
                if (val != null) {
                  provider.rentalDurationController.text = val;
                  provider.notifyListeners();
                }
              },
              theme: theme,
            ),
            const SizedBox(height: 14),
            _buildFieldLabel("Contact Person / Media House", theme),
            DropdownButtonFormField<MediaHouse>(
              value: _selectedMediaHouse,
              items: provider.mediaHouseList.map((MediaHouse mediaHouse) {
                return DropdownMenuItem<MediaHouse>(
                  value: mediaHouse,
                  child: Text(
                    mediaHouse.mediaHouseName ?? "Unknown Media House",
                    style: TextStyle(color: theme.canvasColor, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (MediaHouse? selected) {
                setState(() {
                  _selectedMediaHouse = selected;
                });
              },
              dropdownColor: theme.cardColor,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor),
            ),
          ],
        ),
        _buildCardContainer(
          theme: theme,
          title: "Content Formats & Configuration",
          children: [
            _buildSingleDropdown(
              label: "Content Type",
              items: contentTypes,
              selectedValue: currentType,
              onChanged: (val) {
                if (val != null) {
                  provider.typeController.text = val;
                  provider.notifyListeners();
                  setState(() {});
                }
              },
              theme: theme,
            ),
            const SizedBox(height: 14),
            _buildMultiSelectField(
              label: "Audio Formats",
              allItems: audioFormats,
              selectedItems: provider.selectedAudioFormat,
              context: context,
              theme: theme,
            ),
            const SizedBox(height: 14),
            _buildMultiSelectField(
              label: "Subtitle Languages",
              allItems: subtitleLanguages,
              selectedItems: provider.selectedSubLanguages,
              context: context,
              theme: theme,
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Is Downloadable", style: TextStyle(color: theme.canvasColor, fontSize: 14)),
              value: provider.isDownloadable,
              activeThumbColor: theme.primaryColor,
              onChanged: (val) => provider.toggleDownloadable(val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Is Featured", style: TextStyle(color: theme.canvasColor, fontSize: 14)),
              value: provider.isFeatured,
              activeThumbColor: theme.primaryColor,
              onChanged: (val) => provider.toggleFeatured(val),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: Upload Files & Settings
  Widget _buildStep3UploadFiles(ThemeData theme, VideoProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildCardContainer(
          theme: theme,
          title: "Upload Files",
          children: [
            _buildFileUploadItem(
              label: "Censor Certificate",
              subLabel: "Recommended: 1080 x 1620 px",
              currentUrl: provider.censorCertificateController.text,
              isImage: true,
              theme: theme,
              provider: provider,
              onPick: () => provider.pickImage("Censor Certificate"),
              onClear: () => provider.clearUploadedFile("Censor Certificate"),
            ),
            _buildFileUploadItem(
              label: "Poster 1",
              subLabel: "Recommended: 1080 x 1620 px",
              currentUrl: provider.poster1Controller.text,
              isImage: true,
              theme: theme,
              provider: provider,
              onPick: () => provider.pickImage("Poster 1"),
              onClear: () => provider.clearUploadedFile("Poster 1"),
            ),
            _buildFileUploadItem(
              label: "Poster 2",
              subLabel: "Recommended: 1080 x 1620 px",
              currentUrl: provider.poster2Controller.text,
              isImage: true,
              theme: theme,
              provider: provider,
              onPick: () => provider.pickImage("Poster 2"),
              onClear: () => provider.clearUploadedFile("Poster 2"),
            ),
            _buildFileUploadItem(
              label: "Poster 3",
              subLabel: "Recommended: 1080 x 1620 px",
              currentUrl: provider.poster3Controller.text,
              isImage: true,
              theme: theme,
              provider: provider,
              onPick: () => provider.pickImage("Poster 3"),
              onClear: () => provider.clearUploadedFile("Poster 3"),
            ),
            _buildFileUploadItem(
              label: "Teaser File",
              subLabel: "Recommended: Short teaser video (MP4 / HLS)",
              currentUrl: provider.teaserUrlController.text,
              isImage: false,
              theme: theme,
              provider: provider,
              onPick: () => provider.uploadVideo(false, isTeaser: true),
              onClear: () => provider.clearUploadedFile("Teaser File"),
            ),
            _buildFileUploadItem(
              label: "Trailer File",
              subLabel: "Recommended: Full trailer video (MP4 / HLS)",
              currentUrl: provider.trailerUrlController.text,
              isImage: false,
              theme: theme,
              provider: provider,
              onPick: () => provider.uploadVideo(true, isTeaser: false),
              onClear: () => provider.clearUploadedFile("Trailer File"),
            ),
            _buildFileUploadItem(
              label: "Movie File",
              subLabel: "Recommended: Full video content (MP4 / HLS)",
              currentUrl: provider.movieUrlController.text,
              isImage: false,
              theme: theme,
              provider: provider,
              onPick: () => provider.uploadVideo(false, isTeaser: false),
              onClear: () => provider.clearUploadedFile("Movie File"),
            ),
          ],
        ),
        if (provider.selectedLanguages.isNotEmpty)
          _buildCardContainer(
            theme: theme,
            title: "Audio Track Files",
            children: [
              ...provider.selectedLanguages.map((lang) {
                final audioUrl = provider.languageAudioUrls[lang] ?? '';
                return _buildFileUploadItem(
                  label: "$lang Audio Track",
                  subLabel: "Upload audio file for $lang (MP3 / AAC / MP4)",
                  currentUrl: audioUrl,
                  isImage: false,
                  theme: theme,
                  provider: provider,
                  onPick: () => provider.pickAndUploadAudioTrack(lang),
                  onClear: () {
                    provider.languageAudioUrls.remove(lang);
                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                    provider.notifyListeners();
                  },
                );
              }),
            ],
          ),
        Builder(
          builder: (context) {
            final languagesForSubtitles = <String>{
              ...provider.selectedSubLanguages,
              ...provider.selectedLanguages,
            }.where((l) => l.trim().isNotEmpty).toList();

            if (languagesForSubtitles.isEmpty) return const SizedBox.shrink();

            return _buildCardContainer(
              theme: theme,
              title: "Subtitle Files",
              children: [
                ...languagesForSubtitles.map((subLang) {
                  final subtitleUrl = provider.subtitleLanguageUrls[subLang] ?? '';
                  return _buildFileUploadItem(
                    label: "$subLang Subtitle",
                    subLabel: "Upload subtitle file for $subLang (VTT / SRT / SUB / TXT)",
                    currentUrl: subtitleUrl,
                    isImage: false,
                    theme: theme,
                    provider: provider,
                    onPick: () => provider.pickAndUploadSubtitleFile(subLang),
                    onClear: () {
                      provider.subtitleLanguageUrls.remove(subLang);
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      provider.notifyListeners();
                    },
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFileUploadItem({
    required String label,
    required String subLabel,
    required String currentUrl,
    required bool isImage,
    required ThemeData theme,
    required VideoProvider provider,
    required VoidCallback onPick,
    VoidCallback? onClear,
  }) {
    final hasFile = currentUrl.trim().isNotEmpty;
    final localBytes = provider.getPreviewBytes(label);
    final fileName = currentUrl.trim().isNotEmpty ? currentUrl.split('/').last : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              if (hasFile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade600, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "Uploaded",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subLabel,
            style: TextStyle(
              color: theme.hintColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          if (hasFile)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green.shade600.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dedicated Thumbnail Container for Image or File icon
                  if (isImage)
                    GestureDetector(
                      onTap: () => _previewMedia(
                        currentUrl,
                        isImage,
                        label,
                        bytes: localBytes,
                      ),
                      child: Tooltip(
                        message: "Click to preview full image",
                        child: Container(
                          width: 68,
                          height: 92,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.scaffoldBackgroundColor,
                            border: Border.all(
                              color: theme.canvasColor.withValues(alpha: 0.15),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (localBytes != null)
                                Image.memory(
                                  localBytes,
                                  fit: BoxFit.cover,
                                )
                              else
                                Image.network(
                                  currentUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_outlined,
                                            size: 24, color: theme.hintColor),
                                        const SizedBox(height: 2),
                                        Text('Preview',
                                            style: TextStyle(
                                                fontSize: 9, color: theme.hintColor)),
                                      ],
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.video_collection_outlined,
                          color: theme.primaryColor,
                          size: 32,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$label Attached",
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          fileName.isNotEmpty ? fileName : currentUrl,
                          maxLines: 1,
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.link, size: 13, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                currentUrl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Actions
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                            color: theme.primaryColor,
                            tooltip: "View Preview",
                            onPressed: () => _previewMedia(
                              currentUrl,
                              isImage,
                              label,
                              bytes: localBytes,
                            ),
                          ),
                          if (onClear != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.redAccent,
                              tooltip: "Remove File",
                              onPressed: onClear,
                            ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: provider.isUploading ? null : onPick,
                        icon: const Icon(Icons.sync, size: 14),
                        label: const Text(
                          "Replace",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: theme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: provider.isUploading ? null : onPick,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.8),
                    style: BorderStyle.solid,
                  ),
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: provider.isUploading
                      ? const AppSpinner()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                color: theme.primaryColor, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              "Click to upload $label",
                              style: TextStyle(
                                color: theme.canvasColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _previewMedia(String url, bool isImage, String label, {Uint8List? bytes}) {
    if (url.trim().isEmpty && bytes == null) return;
    if (isImage) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, right: 30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "$label Preview",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: bytes != null
                              ? Image.memory(
                                  bytes,
                                  fit: BoxFit.contain,
                                )
                              : Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    padding: const EdgeInsets.all(32),
                                    color: Colors.white12,
                                    child: const Text(
                                      "Failed to load preview image from network.",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black87,
                      radius: 16,
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrailerPage(trailerUrl: url),
        ),
      );
    }
  }

  Widget _buildBottomActionBar(ThemeData theme, VideoProvider provider) {
    final redColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: _currentPage == 0
          ? SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => _validateAndProceed(provider, 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: redColor, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "Previous",
                        style: TextStyle(color: redColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (_currentPage == 1) {
                                _validateAndProceed(provider, 1);
                              } else {
                                _submitForm(provider, theme);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ),
                                SizedBox(width: 10),
                                Text("Saving...", style: TextStyle(color: Colors.white, fontSize: 14)),
                              ],
                            )
                          : Text(
                              _currentPage == 2 ? (_isEditing ? "Save Changes" : "Submit") : "Next",
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _validateAndProceed(VideoProvider provider, int currentStep) {
    if (currentStep == 0) {
      final title = provider.titleController.text.trim();
      if (title.isEmpty) {
        CustomToast.show("Please enter a valid title.", isSuccess: false);
        return;
      }
      _nextPage();
    } else if (currentStep == 1) {
      final priceText = provider.priceController.text.trim();
      final price = double.tryParse(priceText);
      if (priceText.isEmpty || price == null || price < 0) {
        CustomToast.show("Please enter a valid price.", isSuccess: false);
        return;
      }
      _nextPage();
    }
  }

  Future<void> _submitForm(VideoProvider provider, ThemeData theme) async {
    final title = provider.titleController.text.trim();
    final priceText = provider.priceController.text.trim();
    final price = double.tryParse(priceText);

    if (title.isEmpty || price == null) {
      CustomToast.show("Please check title and price before submitting.", isSuccess: false);
      return;
    }

    if (_isEditing) {
      final existing = widget.editingContent;
      if (existing == null) return;
      setState(() => _isSaving = true);
      try {
        final updated = await provider.updateContent(context, existing);
        if (updated != null && mounted) {
          Navigator.of(context).pop(updated);
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      if (_selectedMediaHouse == null) {
        CustomToast.show("Please select a media house.", isSuccess: false);
        return;
      }
      setState(() => _isSaving = true);
      try {
        final Content? content = await provider.uploadContent(_selectedMediaHouse!, context);
        if (content != null && mounted) {
          await showSetPercentageDialog(content, _selectedMediaHouse!);
          if (mounted) Navigator.of(context).pop(content);
        } else {
          CustomToast.show("Failed to add content.", isSuccess: false);
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> showSetPercentageDialog(
      Content content, MediaHouse mediaHouse) async {
    final double? result = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SetPercentageDialog(content: content, mediaHouse: mediaHouse);
      },
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected Percentage: ${result.toInt()}%")),
      );
    }
  }
}

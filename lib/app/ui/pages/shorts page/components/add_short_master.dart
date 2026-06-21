import 'dart:io' as io;

import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class AddShortMaster {
  static void show(BuildContext rootContext) {
    final theme = Theme.of(rootContext);
    final provider = rootContext.read<ShortsProvider>();

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final creatorCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final partsCtrl = TextEditingController();
    final coinsCtrl = TextEditingController();
    final mediaHouseCtrl = TextEditingController();
    final rentalCtrl = TextEditingController(text: 'One Time');
    final languageCtrl = TextEditingController(text: 'English');
    final langFileCtrl = TextEditingController();

    bool isTrending = false;
    bool isSubmitting = false;
    String? uploadedImageUrl;
    io.File? imageFile;
    html.File? webFile;

    Future<void> pickAndUploadImage(StateSetter setState) async {
      if (kIsWeb) {
        final input = html.FileUploadInputElement()..accept = 'image/*';
        input.click();
        await input.onChange.first;
        if (input.files == null || input.files!.isEmpty) return;
        webFile = input.files!.first;
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(source: ImageSource.gallery);
        if (file == null) return;
        imageFile = io.File(file.path);
      }

      setState(() => isSubmitting = true);
      uploadedImageUrl = await provider.uploadThumbnail(imageFile, webFile);
      setState(() => isSubmitting = false);
    }

    String? validate() {
      if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
        return "Poster image required";
      }
      if (titleCtrl.text.trim().length < 3) return "Title too short";
      if (descCtrl.text.trim().length < 10) return "Description too short";
      if (int.tryParse(partsCtrl.text) == null) return "Invalid total parts";
      if (int.tryParse(coinsCtrl.text) == null) return "Invalid coins per part";
      if (int.tryParse(mediaHouseCtrl.text) == null) return "Invalid mediaHouseId";
      return null;
    }

    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Container(
                width: 460,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Add New Short",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: isSubmitting ? null : () => pickAndUploadImage(setState),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.dividerColor),
                            image: uploadedImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(uploadedImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: uploadedImageUrl == null
                              ? const Center(child: Text("Upload Poster"))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                          controller: titleCtrl,
                          hintText: "Title",
                          textInputType: TextInputType.text),
                      CustomTextField(
                          controller: descCtrl,
                          hintText: "Description",
                          textInputType: TextInputType.text,
                          maxLine: 3),
                      CustomTextField(
                          controller: creatorCtrl,
                          hintText: "Creator Name",
                          textInputType: TextInputType.text),
                      CustomTextField(
                          controller: categoryCtrl,
                          hintText: "Category",
                          textInputType: TextInputType.text),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                                controller: partsCtrl,
                                hintText: "Total Parts",
                                textInputType: TextInputType.number),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                                controller: coinsCtrl,
                                hintText: "Coins/Part",
                                textInputType: TextInputType.number),
                          ),
                        ],
                      ),
                      CustomTextField(
                          controller: mediaHouseCtrl,
                          hintText: "MediaHouse ID",
                          textInputType: TextInputType.number),
                      CustomTextField(
                          controller: rentalCtrl,
                          hintText: "Rental Duration",
                          textInputType: TextInputType.text),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: languageCtrl,
                              hintText: "Language",
                              textInputType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: langFileCtrl,
                              hintText: "Language File URL",
                              textInputType: TextInputType.text,
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        value: isTrending,
                        onChanged: (v) => setState(() => isTrending = v),
                        title: const Text("Trending"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final error = validate();
                                if (error != null) {
                                  ScaffoldMessenger.of(rootContext).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                  return;
                                }
                                setState(() => isSubmitting = true);
                                final body = {
                                  "category": categoryCtrl.text.trim(),
                                  "coinsPerPart": int.parse(coinsCtrl.text),
                                  "creatorName": creatorCtrl.text.trim(),
                                  "description": descCtrl.text.trim(),
                                  "id": 0,
                                  "isTrending": isTrending,
                                  "languageList": [
                                    {
                                      "language": languageCtrl.text.trim(),
                                      "fileUrl": langFileCtrl.text.trim(),
                                    }
                                  ],
                                  "likeCount": 0,
                                  "mediaHouseId": int.parse(mediaHouseCtrl.text),
                                  "posterUrl": uploadedImageUrl,
                                  "rentlDuration": rentalCtrl.text.trim(),
                                  "title": titleCtrl.text.trim(),
                                  "totalParts": int.parse(partsCtrl.text),
                                  "uploadDateTime":
                                      DateTime.now().toUtc().toIso8601String(),
                                  "viewCount": 0
                                };
                                final success = await provider.addShortMaster(body);
                                setState(() => isSubmitting = false);
                                if (success && rootContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              },
                        child: isSubmitting
                            ? const AppButtonLoader(label: 'Submitting')
                            : const Text("Submit",
                                style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

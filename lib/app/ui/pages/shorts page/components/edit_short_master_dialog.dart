import 'dart:io' as io;

import 'package:admin_ott/app/provider/shortsProvider.dart';

import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/domain/entities/shorts_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class EditShortMasterDialog extends StatefulWidget {
  final int shortId;
  final ShortMaster shortDetail;

  const EditShortMasterDialog({
    super.key,
    required this.shortId,
    required this.shortDetail,
  });

  @override
  State<EditShortMasterDialog> createState() => _EditShortMasterDialogState();
}

class _EditShortMasterDialogState extends State<EditShortMasterDialog> {
  late final TextEditingController titleCtrl;
  late final TextEditingController totalPartsCtrl;
  late final TextEditingController categoryCtrl;
  late final TextEditingController creatorNameCtrl;
  late final TextEditingController coinsPerPartCtrl;
  late final TextEditingController descriptionCtrl;
  late final TextEditingController mediaHouseIdCtrl;
  late final TextEditingController rentalCtrl;
  bool isTrending = false;
  String? uploadedImageUrl;
  io.File? imageFile;
  html.File? webFile;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.shortDetail.title ?? '');
    totalPartsCtrl =
        TextEditingController(text: '${widget.shortDetail.totalParts ?? 0}');
    categoryCtrl =
        TextEditingController(text: widget.shortDetail.category ?? '');
    creatorNameCtrl =
        TextEditingController(text: widget.shortDetail.creatorName ?? '');
    coinsPerPartCtrl =
        TextEditingController(text: '${widget.shortDetail.coinsPerPart ?? 0}');
    descriptionCtrl =
        TextEditingController(text: widget.shortDetail.description ?? '');
    mediaHouseIdCtrl = TextEditingController(text: '0');
    rentalCtrl = TextEditingController(
        text: widget.shortDetail.rentlDuration ?? 'One Time');
    isTrending = widget.shortDetail.isTrending ?? false;
    uploadedImageUrl = widget.shortDetail.poster;
  }

  Future<void> pickImage() async {
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
    final url = await context
        .read<ShortsProvider>()
        .uploadThumbnail(imageFile, webFile);
    if (mounted && url != null) setState(() => uploadedImageUrl = url);
  }

  Future<void> _submit() async {
    final provider = context.read<ShortsProvider>();
    final body = {
      "id": widget.shortId,
      "title": titleCtrl.text.trim(),
      "category": categoryCtrl.text.trim(),
      "creatorName": creatorNameCtrl.text.trim(),
      "description": descriptionCtrl.text.trim(),
      "coinsPerPart": int.tryParse(coinsPerPartCtrl.text.trim()) ?? 0,
      "totalParts": int.tryParse(totalPartsCtrl.text.trim()) ?? 0,
      "isTrending": isTrending,
      "posterUrl": uploadedImageUrl ?? '',
      "likeCount": widget.shortDetail.likeCount ?? 0,
      "viewCount": widget.shortDetail.viewCount ?? 0,
      "mediaHouseId": int.tryParse(mediaHouseIdCtrl.text.trim()) ?? 0,
      "rentlDuration": rentalCtrl.text.trim(),
      "languageList":
          widget.shortDetail.languageList.map((e) => e.toJson()).toList(),
    };

    final success = await provider.updateShortMaster(body, '${widget.shortId}');
    if (!mounted) return;
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShortsProvider>();
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 680,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ListTile(
              title: const Text("Edit Short Master"),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: categoryCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Category')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: creatorNameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Creator Name')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: totalPartsCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Total Parts')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: coinsPerPartCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Coins Per Part')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: mediaHouseIdCtrl,
                        decoration:
                            const InputDecoration(labelText: 'MediaHouse ID')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: rentalCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Rental Duration')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionCtrl,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    if (uploadedImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(uploadedImageUrl!, height: 120),
                      ),
                    TextButton(
                      onPressed: pickImage,
                      child: Text(uploadedImageUrl == null
                          ? 'Upload Poster'
                          : 'Replace Poster'),
                    ),
                    SwitchListTile(
                      value: isTrending,
                      title: const Text('Trending'),
                      onChanged: (v) => setState(() => isTrending = v),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor),
                  onPressed: provider.isSubmitting ? null : _submit,
                  child: provider.isSubmitting
                      ? const AppButtonLoader(label: 'Updating')
                      : const Text('Update Short Master',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

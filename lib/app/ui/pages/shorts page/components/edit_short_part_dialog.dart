import 'dart:io' as io;

import 'package:admin_ott/app/provider/shortsProvider.dart';

import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/domain/entities/short_part.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class EditShortPartDialog extends StatefulWidget {
  final int shortId;
  final ShortPartDTO part;

  const EditShortPartDialog({
    super.key,
    required this.shortId,
    required this.part,
  });

  @override
  State<EditShortPartDialog> createState() => _EditShortPartDialogState();
}

class _EditShortPartDialogState extends State<EditShortPartDialog> {
  late final TextEditingController titleCtrl;
  late final TextEditingController videoUrlCtrl;
  late final TextEditingController coinsCtrl;
  bool isFreePreview = false;
  String? uploadedImageUrl;
  io.File? imageFile;
  html.File? webFile;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.part.title ?? '');
    videoUrlCtrl = TextEditingController(text: widget.part.videoUrl ?? '');
    coinsCtrl = TextEditingController(text: '${widget.part.coins ?? 0}');
    isFreePreview = widget.part.isFreePreview ?? false;
    uploadedImageUrl = widget.part.thumbnail;
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
      "coins": int.tryParse(coinsCtrl.text.trim()) ?? 0,
      "durationSec": widget.part.durationSec ?? 0,
      "id": int.tryParse(widget.part.partId ?? '0') ?? 0,
      "isFreePreview": isFreePreview,
      "likes": widget.part.likes ?? 0,
      "partNumber": widget.part.partNumber ?? 0,
      "shortId": widget.shortId,
      "thumbnail": uploadedImageUrl,
      "title": titleCtrl.text.trim(),
      "videoUrl": videoUrlCtrl.text.trim(),
      "views": widget.part.views ?? 0
    };
    final success =
        await provider.updateShortPart(body, widget.part.partId ?? '0');
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
        constraints: const BoxConstraints(maxHeight: 620),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ListTile(
              title: const Text("Edit Short Part"),
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
                        controller: coinsCtrl,
                        decoration: const InputDecoration(labelText: 'Coins')),
                    const SizedBox(height: 10),
                    TextField(
                        controller: videoUrlCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Video URL')),
                    const SizedBox(height: 10),
                    if (uploadedImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(uploadedImageUrl!, height: 120),
                      ),
                    TextButton(
                      onPressed: pickImage,
                      child: Text(uploadedImageUrl == null
                          ? 'Upload Thumbnail'
                          : 'Replace Thumbnail'),
                    ),
                    SwitchListTile(
                      value: isFreePreview,
                      title: const Text('Free Preview'),
                      onChanged: (v) => setState(() => isFreePreview = v),
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
                      : const Text('Update Part',
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

import 'dart:io' as io;

import 'package:admin_ott/app/provider/shortsProvider.dart';
import 'package:admin_ott/app/ui/pages/manage%20content%20page/component/DisplayTrailer.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class CreateShortPartsDialog extends StatefulWidget {
  final int shortId;
  final int totalParts;

  const CreateShortPartsDialog({
    super.key,
    required this.shortId,
    required this.totalParts,
  });

  @override
  State<CreateShortPartsDialog> createState() => _CreateShortPartsDialogState();
}

class _CreateShortPartsDialogState extends State<CreateShortPartsDialog> {
  int currentPart = 1;
  final titleCtrl = TextEditingController();
  final coinsCtrl = TextEditingController();
  final videoUrlCtrl = TextEditingController();
  String? uploadedImageUrl;
  bool isFreePreview = false;
  io.File? imageFile;
  html.File? webFile;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ShortsProvider>();
    provider.movieUrlController.addListener(() {
      final url = provider.movieUrlController.text;
      if (url.isNotEmpty && mounted) {
        setState(() => videoUrlCtrl.text = url);
      }
    });
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

    final provider = context.read<ShortsProvider>();
    final url = await provider.uploadThumbnail(imageFile, webFile);
    if (mounted && url != null) setState(() => uploadedImageUrl = url);
  }

  Future<void> _submit(ShortsProvider provider) async {
    final body = {
      "coins": int.tryParse(coinsCtrl.text.trim()) ?? 0,
      "durationSec": 0,
      "isFreePreview": isFreePreview,
      "likes": 0,
      "partNumber": currentPart,
      "shortId": widget.shortId,
      "thumbnail": uploadedImageUrl ?? "",
      "title": titleCtrl.text.trim(),
      "videoUrl": videoUrlCtrl.text.trim(),
      "views": 0
    };
    final success = await provider.createShortPart(body);
    if (!mounted) return;
    if (!success) return;
    if (currentPart >= widget.totalParts) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      currentPart++;
      titleCtrl.clear();
      coinsCtrl.clear();
      videoUrlCtrl.clear();
      uploadedImageUrl = null;
      isFreePreview = false;
      provider.movieUrlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShortsProvider>();
    final theme = Theme.of(context);
    final canSubmit = videoUrlCtrl.text.isNotEmpty &&
        !provider.isMovieUploading &&
        !provider.isSubmitting;

    return Container(
      width: 720,
      constraints: const BoxConstraints(maxHeight: 640),
      color: theme.cardColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  "Upload Video Content",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: theme.canvasColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Part $currentPart of ${widget.totalParts}",
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: titleCtrl,
                    hintText: "Title",
                    textInputType: TextInputType.text,
                  ),
                  CustomTextField(
                    controller: coinsCtrl,
                    hintText: "Coins",
                    textInputType: TextInputType.number,
                  ),
                  _uploadCard(
                    theme,
                    title: "Short File",
                    child: provider.isMovieUploading
                        ? LinearProgressIndicator(
                            value: provider.movieUploadProgress)
                        : videoUrlCtrl.text.isNotEmpty
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          videoUrlCtrl.text,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => provider.uploadVideo(),
                                        child: const Text("Replace"),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          provider.movieUrlController.clear();
                                          videoUrlCtrl.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child: AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: TrailerPage(
                                                  trailerUrl: videoUrlCtrl.text,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.visibility),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () => provider.uploadVideo(),
                                child: const Text("Upload Video"),
                              ),
                  ),
                  _uploadCard(
                    theme,
                    title: "Short Poster",
                    child: uploadedImageUrl == null
                        ? ElevatedButton(
                            onPressed: pickImage,
                            child: const Text("Upload Thumbnail"),
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  uploadedImageUrl!,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                      onPressed: pickImage,
                                      child: const Text("Replace")),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => uploadedImageUrl = null),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  )
                                ],
                              )
                            ],
                          ),
                  ),
                  SwitchListTile(
                    value: isFreePreview,
                    title: const Text("Free Preview"),
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
                  backgroundColor: canSubmit ? theme.primaryColor : Colors.grey,
                ),
                onPressed: canSubmit ? () => _submit(provider) : null,
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save & Continue",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _uploadCard(ThemeData theme,
      {required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

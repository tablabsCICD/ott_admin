import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:admin_ott/app/widgets/app_loaders.dart';
import 'package:admin_ott/app/widgets/ott_media_player.dart';
import 'package:admin_ott/domain/entities/content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A dedicated dialog specifically for previewing, uploading, and editing
/// the Teaser File and Trailer File for a content item without altering other content fields.
class EditTeaserDialog extends StatefulWidget {
  final Content content;
  final int initialTabIndex;

  const EditTeaserDialog({
    super.key,
    required this.content,
    this.initialTabIndex = 0,
  });

  @override
  State<EditTeaserDialog> createState() => _EditTeaserDialogState();
}

class _EditTeaserDialogState extends State<EditTeaserDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _teaserUrlController;
  late final TextEditingController _trailerUrlController;
  String? _teaserPreviewUrl;
  String? _trailerPreviewUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );

    final initialTeaser = widget.content.teaserUrl?.trim() ?? '';
    final initialTrailer = widget.content.trailerUrl?.trim() ?? '';

    _teaserPreviewUrl = initialTeaser.isNotEmpty ? initialTeaser : null;
    _trailerPreviewUrl = initialTrailer.isNotEmpty ? initialTrailer : null;

    _teaserUrlController = TextEditingController(text: initialTeaser);
    _trailerUrlController = TextEditingController(text: initialTrailer);

    // Sync controllers in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<VideoProvider>();
        provider.teaserUrlController.text = initialTeaser;
        provider.trailerUrlController.text = initialTrailer;
        provider.resetVideoUploadProgress(false, isTeaser: true);
        provider.resetVideoUploadProgress(true, isTeaser: false);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teaserUrlController.dispose();
    _trailerUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleUploadTeaser() async {
    final provider = context.read<VideoProvider>();
    await provider.uploadVideo(false, isTeaser: true);
    if (!mounted) return;
    final uploadedUrl = provider.teaserUrlController.text.trim();
    if (uploadedUrl.isNotEmpty) {
      setState(() {
        _teaserUrlController.text = uploadedUrl;
        _teaserPreviewUrl = uploadedUrl;
      });
    }
  }

  Future<void> _handleUploadTrailer() async {
    final provider = context.read<VideoProvider>();
    await provider.uploadVideo(true, isTeaser: false);
    if (!mounted) return;
    final uploadedUrl = provider.trailerUrlController.text.trim();
    if (uploadedUrl.isNotEmpty) {
      setState(() {
        _trailerUrlController.text = uploadedUrl;
        _trailerPreviewUrl = uploadedUrl;
      });
    }
  }

  Future<void> _save() async {
    final newTeaserUrl = _teaserUrlController.text.trim();
    final newTrailerUrl = _trailerUrlController.text.trim();
    final provider = context.read<VideoProvider>();
    setState(() => _isSaving = true);
    try {
      final updated = await provider.updateContentTrailerAndTeaser(
        context,
        widget.content,
        newTeaserUrl: newTeaserUrl,
        newTrailerUrl: newTrailerUrl,
      );
      if (!mounted) return;
      if (updated != null) {
        Navigator.of(context).pop(updated);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;
    final provider = context.watch<VideoProvider>();

    final isTeaserUploading =
        provider.isSpecificVideoUploading(false, isTeaser: true);
    final isTrailerUploading =
        provider.isSpecificVideoUploading(true, isTeaser: false);

    final teaserProgress =
        provider.getVideoUploadProgress(false, isTeaser: true);
    final trailerProgress =
        provider.getVideoUploadProgress(true, isTeaser: false);

    // Sync from provider if finished in background
    final currentProvTeaser = provider.teaserUrlController.text.trim();
    if (!isTeaserUploading &&
        currentProvTeaser.isNotEmpty &&
        currentProvTeaser != _teaserUrlController.text.trim()) {
      _teaserUrlController.text = currentProvTeaser;
      _teaserPreviewUrl = currentProvTeaser;
    }

    final currentProvTrailer = provider.trailerUrlController.text.trim();
    if (!isTrailerUploading &&
        currentProvTrailer.isNotEmpty &&
        currentProvTrailer != _trailerUrlController.text.trim()) {
      _trailerUrlController.text = currentProvTrailer;
      _trailerPreviewUrl = currentProvTrailer;
    }

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.movie_creation_outlined,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Teaser & Trailer Files",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.canvasColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.content.title ?? "Untitled Content",
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: theme.hintColor),
                    tooltip: "Close",
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: theme.hintColor,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.movie_outlined, size: 16),
                      text: "Teaser File",
                    ),
                    Tab(
                      icon: Icon(Icons.ondemand_video_outlined, size: 16),
                      text: "Trailer File",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Teaser
                    _buildVideoEditorTab(
                      title: "Teaser Video",
                      subTitle: "Recommended: Short promotional teaser (MP4 / HLS)",
                      urlController: _teaserUrlController,
                      previewUrl: _teaserPreviewUrl,
                      isUploading: isTeaserUploading,
                      uploadProgress: teaserProgress,
                      onUpload: _handleUploadTeaser,
                      onUrlChanged: (val) {
                        setState(() {
                          _teaserPreviewUrl =
                              val.trim().isNotEmpty ? val.trim() : null;
                        });
                      },
                      theme: theme,
                    ),

                    // Tab 2: Trailer
                    _buildVideoEditorTab(
                      title: "Trailer Video",
                      subTitle: "Recommended: Official full trailer (MP4 / HLS)",
                      urlController: _trailerUrlController,
                      previewUrl: _trailerPreviewUrl,
                      isUploading: isTrailerUploading,
                      uploadProgress: trailerProgress,
                      onUpload: _handleUploadTrailer,
                      onUrlChanged: (val) {
                        setState(() {
                          _trailerPreviewUrl =
                              val.trim().isNotEmpty ? val.trim() : null;
                        });
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.hintColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: (_isSaving || isTeaserUploading || isTrailerUploading)
                        ? null
                        : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: AppSpinner(size: 18, strokeWidth: 2),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoEditorTab({
    required String title,
    required String subTitle,
    required TextEditingController urlController,
    required String? previewUrl,
    required bool isUploading,
    required double uploadProgress,
    required VoidCallback onUpload,
    required ValueChanged<String> onUrlChanged,
    required ThemeData theme,
  }) {
    final hasPreview = previewUrl != null && previewUrl.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Card
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPreview
                    ? theme.primaryColor.withValues(alpha: 0.35)
                    : theme.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasPreview
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: OttMediaPlayer(
                            key: ValueKey(previewUrl),
                            url: previewUrl,
                            autoPlay: false,
                            fit: BoxFit.contain,
                            errorBuilder: (_, msg) => Center(
                              child: Text(
                                msg,
                                style:
                                    TextStyle(color: theme.colorScheme.error),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.greenAccent, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Preview Ready",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_off_outlined,
                            color: theme.hintColor.withValues(alpha: 0.5),
                            size: 44,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No $title Attached",
                            style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Upload a video file or enter direct URL below",
                            style: TextStyle(
                              color: theme.hintColor.withValues(alpha: 0.7),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Upload File Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upload $title File",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.canvasColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 10),
                if (isUploading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Uploading $title...",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            "${(uploadProgress * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.canvasColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: uploadProgress > 0 ? uploadProgress : null,
                          backgroundColor:
                              theme.dividerColor.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : onUpload,
                      icon: Icon(
                        hasPreview
                            ? Icons.refresh_rounded
                            : Icons.cloud_upload_outlined,
                        size: 18,
                      ),
                      label: Text(
                        hasPreview
                            ? "Replace $title File"
                            : "Select $title File to Upload",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(
                            color: theme.primaryColor.withValues(alpha: 0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Direct URL Input
          Text(
            "$title URL",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: theme.canvasColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: urlController,
            style: TextStyle(color: theme.canvasColor, fontSize: 13),
            decoration: InputDecoration(
              hintText: "https://... (or upload using button above)",
              hintStyle: TextStyle(
                color: theme.hintColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              filled: true,
              fillColor:
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.3),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: theme.primaryColor, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                tooltip: "Preview URL",
                onPressed: () {
                  onUrlChanged(urlController.text);
                },
              ),
            ),
            onChanged: onUrlChanged,
          ),
        ],
      ),
    );
  }
}

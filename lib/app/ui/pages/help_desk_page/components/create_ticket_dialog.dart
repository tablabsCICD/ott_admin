import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:admin_ott/app/provider/ticketProvider.dart';
import 'package:admin_ott/app/widgets/custom_textfield.dart';

void showCreateTicketDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const CreateTicketDialog(),
  );
}

class CreateTicketDialog extends StatefulWidget {
  const CreateTicketDialog({super.key});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().getTheme;
    final provider = context.watch<TicketProvider>();

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.support_agent_rounded,
                      color: theme.primaryColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    "Create Support Ticket",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.canvasColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Topic / Subject
              Text(
                "Topic / Subject *",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.canvasColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                textInputType: TextInputType.text,
                controller: provider.topicController,
                hintText: "e.g. Video playback issue, Billing query",
              ),
              const SizedBox(height: 14),

              // Description
              Text(
                "Description *",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.canvasColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: provider.descController,
                maxLine: 3,
                textInputType: TextInputType.multiline,
                hintText: "Describe the task or issue in detail...",
              ),
              const SizedBox(height: 14),

              // Attachment Uploader
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: provider.isUploading
                        ? null
                        : () => provider.pickImage(),
                    icon: const Icon(Icons.attach_file_rounded, size: 16),
                    label: Text(
                      provider.isUploading
                          ? "Uploading..."
                          : (provider.imgUrl.isNotEmpty
                              ? "Change Attachment"
                              : "Add Attachment"),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (provider.imgUrl.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    const Text("Image attached",
                        style: TextStyle(fontSize: 12)),
                  ],
                ],
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Create Ticket",
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

  Future<void> _submitTicket() async {
    final provider = context.read<TicketProvider>();
    if (provider.topicController.text.trim().isEmpty ||
        provider.descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Please fill in both topic and description."),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await provider.raiseTicket();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text(
              result['message']?.toString() ?? "Ticket created successfully!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content:
              Text(result['message']?.toString() ?? "Failed to create ticket"),
        ),
      );
    }
  }
}

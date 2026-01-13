import 'package:admin_ott/app/provider/videoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiSelectDialog extends StatelessWidget {
  final String label;
  final List<String> items;
  final ThemeData theme;

  const MultiSelectDialog({
    Key? key,
    required this.label,
    required this.items,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: Text(
        'Select $label',
        style: TextStyle(color: theme.textTheme.headlineSmall?.color),
      ),
      content: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: items.map((item) {
                return CheckboxListTile(
                  value: label=="Genres"
                      ? provider.selectedGeners.contains(item)
                      :label=="Audio Formats"
                      ?provider.selectedAudioFormat.contains(item)
                      :label=="Subtitle Languages"
                      ? provider.selectedSubLanguages.contains(item)
                      :provider.selectedLanguages.contains(item),
                  activeColor: theme.colorScheme.primary,
                  checkColor: theme.colorScheme.onPrimary,
                  title: Text(
                    item,
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                  ),
                  onChanged: (isChecked) {
                    provider.toggleSelection(item,label);
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

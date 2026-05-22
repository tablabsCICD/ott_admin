import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminSettingsDropdown<T> extends StatelessWidget {
  const AdminSettingsDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: _inputDecoration(theme, label),
      dropdownColor: theme.cardColor,
      style: TextStyle(color: theme.canvasColor),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? '$label is required' : null,
    );
  }
}

class AdminSettingsTextField extends StatelessWidget {
  const AdminSettingsTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String? value)? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: theme.canvasColor),
      decoration: _inputDecoration(theme, label).copyWith(
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: theme.primaryColor, size: 20),
      ),
      validator: validator,
    );
  }
}

class AdminSettingsDateField extends StatelessWidget {
  const AdminSettingsDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(theme, label).copyWith(
          prefixIcon: Icon(Icons.event, color: theme.primaryColor, size: 20),
        ),
        child: Text(
          value == null ? 'Select date' : formatAdminDate(value!),
          style: TextStyle(
            color: value == null
                ? theme.canvasColor.withValues(alpha: 0.55)
                : theme.canvasColor,
          ),
        ),
      ),
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AdminSettingsEmptyState extends StatelessWidget {
  const AdminSettingsEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rule_folder_outlined,
              size: 46,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.canvasColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: theme.canvasColor.withValues(alpha: 0.65)),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSettingsShimmer extends StatelessWidget {
  const AdminSettingsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.canvasColor.withValues(alpha: 0.08);
    final highlight = theme.canvasColor.withValues(alpha: 0.16);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            height: 82,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(ThemeData theme, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: theme.canvasColor.withValues(alpha: 0.7)),
    filled: true,
    fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.canvasColor.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.primaryColor, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}

String formatAdminDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')} '
      '${months[local.month - 1]} ${local.year}';
}

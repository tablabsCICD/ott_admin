import 'package:admin_ott/app/provider/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToggleButtonWidget extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onToggle;

  const ToggleButtonWidget({
    Key? key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onToggle(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 40,
        width: 60,
        decoration: BoxDecoration(
          color:
              isSelected ? selectedThemeData.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : selectedThemeData.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

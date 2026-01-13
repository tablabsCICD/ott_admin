import 'package:admin_ott/domain/entities/mediaHouse.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/content.dart';
import '../../../../provider/themeProvider.dart';
import '../../../../provider/videoProvider.dart';

class SetPercentageDialog extends StatefulWidget {
  final Content content;
  final MediaHouse mediaHouse;
  const SetPercentageDialog({
    super.key,
    required this.content, required this.mediaHouse,
  });

  @override
  _SetPercentageDialogState createState() => _SetPercentageDialogState();
}

class _SetPercentageDialogState extends State<SetPercentageDialog> {
  double _percentage = 50.00;
  final TextEditingController _textController =
  TextEditingController(text: "50.00");

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoProvider = Provider.of<VideoProvider>(context);
    final selectedThemeData = themeProvider.getTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "Select Percentage Split",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Slider
            Slider(
              activeColor: selectedThemeData.primaryColor,
              value: _percentage,
              min: 0,
              max: 100,
              divisions: 10000, // Allows finer control (0.01 steps)
              label: "${_percentage.toStringAsFixed(2)}%",
              onChanged: (value) {
                setState(() {
                  _percentage = double.parse(
                      value.toStringAsFixed(2)); // Ensure 2 decimal places
                  _textController.text =
                      _percentage.toStringAsFixed(2); // Sync with text field
                });
              },
            ),

            const SizedBox(height: 10),

            // Media House and Platform percentage display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Media House: ${_percentage.toStringAsFixed(2)}%"),
                Text("Platform: ${(100 - _percentage).toStringAsFixed(2)}%"),
              ],
            ),

            const SizedBox(height: 20),

            // TextField to input percentage manually
            SizedBox(
              width: 150,
              child: TextField(
                controller: _textController,
                cursorColor: selectedThemeData.primaryColor,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Media House %",
                  labelStyle: TextStyle(
                    color: selectedThemeData.canvasColor,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: selectedThemeData.cardColor,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: selectedThemeData.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  double? newValue = double.tryParse(value);
                  if (newValue != null) {
                    setState(() {
                      _percentage = newValue.clamp(0, 100); // Ensure within range
                      _textController.text =
                          _percentage.toStringAsFixed(2); // Prevent invalid inputs
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedThemeData.primaryColor,
                  ),
                  onPressed: () async {
                   await videoProvider.setMoviePercentage(context, widget.content,_percentage,(100 - _percentage),widget.mediaHouse);
                    Navigator.pop(context, _percentage);
                  },
                  child: const Text("Set"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

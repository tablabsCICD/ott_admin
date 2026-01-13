import 'package:flutter/material.dart';

class SetPromoterPercentageScreen extends StatefulWidget {
  const SetPromoterPercentageScreen({Key? key}) : super(key: key);

  @override
  State<SetPromoterPercentageScreen> createState() =>
      _SetPromoterPercentageScreenState();
}

class _SetPromoterPercentageScreenState
    extends State<SetPromoterPercentageScreen> {
  final TextEditingController _percentageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedPromoter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: const Text('Set Promoter Percentage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // DropdownButtonFormField<String>(
              //   decoration: InputDecoration(
              //     labelText: 'Select Promoter',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   value: selectedPromoter,
              //   items: promoters
              //       .map((p) => DropdownMenuItem(
              //     value: p,
              //     child: Text(p),
              //   ))
              //       .toList(),
              //   onChanged: (val) => setState(() => selectedPromoter = val),
              //   validator: (value) =>
              //   value == null ? 'Please select a promoter' : null,
              // ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _percentageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Percentage',
                  suffixText: '%',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0 || val > 100) {
                    return 'Enter valid percentage (0–100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Percentage updated successfully'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BinTypeDropdown extends StatelessWidget {
  final List<String> binTypes;
  final String selectedType;
  final Function(String) onTypeSelected;

  BinTypeDropdown({
    required this.binTypes,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Bin Type',
        border: OutlineInputBorder(),
      ),
      value: selectedType.isEmpty ? null : selectedType,
      items: binTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onTypeSelected(newValue);
        }
      },
    );
  }
}

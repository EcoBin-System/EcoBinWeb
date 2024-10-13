import 'package:flutter/material.dart';

class BinTypeDropdown extends StatelessWidget {
  final List<String> binTypes;
  final String selectedType;
  final Function(String) onTypeSelected;

  const BinTypeDropdown({
    Key? key,
    required this.binTypes,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Bin Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      value: selectedType.isEmpty ? null : selectedType,
      items: binTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onTypeSelected(newValue);
        }
      },
      style: TextStyle(color: Colors.black87, fontSize: 16),
      icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
      isExpanded: true,
      dropdownColor: Colors.white,
    );
  }
}

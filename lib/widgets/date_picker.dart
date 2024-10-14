import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: _buildDatePickerUI(),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF5FAD46),
            colorScheme: const ColorScheme.light(primary: Color(0xFF5FAD46)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Widget _buildDatePickerUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup Date',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(221, 80, 79, 79),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: _inputDecoration(),
          child: Text(
            selectedDate == null
                ? ''
                : DateFormat('yyyy-MM-dd').format(selectedDate!),
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(221, 51, 51, 51),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: Color.fromARGB(255, 236, 236, 236), width: 2.0),
      ),
      filled: true,
      fillColor: Color.fromARGB(255, 255, 255, 255),
      suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF5FAD46)),
    );
  }
}

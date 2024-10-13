import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePicker({
    Key? key,
    required this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: _buildTimePickerUI(context),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
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
      onTimeSelected(picked);
    }
  }

  Widget _buildTimePickerUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup Time', // Label for the time picker
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(221, 80, 79, 79),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6), // Space between label and input field
        InputDecorator(
          decoration: _inputDecoration(),
          child: Text(
            selectedTime == null
                ? ''
                : selectedTime!.format(context), // Display selected time
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
      suffixIcon: Icon(Icons.access_time, color: Color(0xFF5FAD46)),
    );
  }
}

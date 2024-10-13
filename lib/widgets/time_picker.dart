import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  TimePicker({required this.selectedTime, required this.onTimeSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Pickup Time',
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedTime == null ? 'Select Time' : selectedTime!.format(context),
        ),
      ),
    );
  }
}

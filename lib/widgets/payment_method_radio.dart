import 'package:flutter/material.dart';

class PaymentMethodRadio extends StatelessWidget {
  final List<String> paymentMethods;
  final String selectedMethod;
  final Function(String) onMethodSelected;

  PaymentMethodRadio({
    required this.paymentMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method'),
        ...(paymentMethods.map((String method) {
          return RadioListTile<String>(
            title: Text(method),
            value: method,
            groupValue: selectedMethod,
            onChanged: (String? value) {
              if (value != null) {
                onMethodSelected(value);
              }
            },
          );
        }).toList()),
      ],
    );
  }
}

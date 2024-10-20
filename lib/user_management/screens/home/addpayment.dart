import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPaymentMethodPage extends StatefulWidget {
  @override
  _AddPaymentMethodPageState createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  String? cardType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _storeForFuturePayments = false;

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Function to save card details to Firestore
  Future<void> _saveCardDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar('User not logged in. Please log in.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (cardType == null) {
      _showSnackBar('Please select a card type.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('carddetails')
          .add({
        'cardType': cardType,
        'name': _nameController.text,
        'cardNumber': _cardNumberController.text,
        'expiryDate': _expiryDateController.text,
        'cvv': _cvvController.text,
        'storeForFuture': _storeForFuturePayments,
      });

      _showSnackBar('Card details saved successfully.');
      _clearForm();
    } catch (e) {
      _showSnackBar('Failed to save card details: $e');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    setState(() {
      cardType = null;
      _storeForFuturePayments = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Card Number Validation
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter the card number';
    if (value.length != 16) return 'Card number must be 16 digits';
    if (!RegExp(r'^\d+$').hasMatch(value))
      return 'Card number must be digits only';
    return null;
  }

  // CVV Validation
  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'Please enter the CVV';
    if (value.length != 3) return 'CVV must be 3 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'CVV must be digits only';
    return null;
  }

  // Expiry Date Validation
  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) return 'Please enter the expiry date';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(value)) {
      return 'Expiry date must be in MM/YY format';
    }
    return null;
  }

  // Name on Card Validation
  String? _validateName(String? value) {
    if (value == null || value.isEmpty)
      return 'Please enter the name on the card';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name must contain only letters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text('Add Payment Method',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0Xff27AE60),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add new Payment Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ///text field for card name
              _buildCardTypeSelection(),
              const SizedBox(height: 20),
              _buildTextField(
                labelText: 'Name on the Card',
                controller: _nameController,
                validator: _validateName,
              ),
              const SizedBox(height: 20),

              ///text field for card number
              _buildTextField(
                labelText: 'Card Number',
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                validator: _validateCardNumber,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      ///text field for card expire date
                      labelText: 'Expiry Date (MM/YY)',
                      controller: _expiryDateController,
                      keyboardType: TextInputType.datetime,
                      validator: _validateExpiryDate,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(
                      ///text field for card expire CVV
                      labelText: 'CVV',
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      validator: _validateCVV,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Store credit card for future payments'),
                value: _storeForFuturePayments,
                onChanged: (value) {
                  setState(() {
                    _storeForFuturePayments = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveCardDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0Xff27AE60),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Details',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build TextFormFields
  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  // Helper method for card type selection
  Widget _buildCardTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Card Type:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            _buildRadioOption('Visa', 'assets/images/visa.png'),
            const SizedBox(width: 20),
            _buildRadioOption('MasterCard', 'assets/images/mastercard.png'),
          ],
        ),
      ],
    );
  }

  // Helper method to build Radio buttons for card types
  Widget _buildRadioOption(String type, String imagePath) {
    return Row(
      children: [
        Radio<String>(
          value: type,
          groupValue: cardType,
          onChanged: (value) {
            setState(() {
              cardType = value;
            });
          },
        ),
        Image.asset(imagePath, width: 40),
        const SizedBox(width: 10),
        Text(type),
      ],
    );
  }
}

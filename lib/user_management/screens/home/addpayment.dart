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
    // Get the current user from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If user is not authenticated, show a message or handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in. Please log in.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      // If form is not valid, return
      return;
    }

    if (cardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a card type.')),
      );
      return;
    }

    try {
      // Save to Firestore inside the current user's carddetails subcollection
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card details saved successfully.')),
      );

      // Clear the form
      _nameController.clear();
      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvvController.clear();
      setState(() {
        cardType = null;
        _storeForFuturePayments = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save card details: $e')),
      );
    }
  }

  // Function to validate card number
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the card number';
    }
    if (value.length != 16) {
      return 'Card number must be 12 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Card number must contain only digits';
    }
    return null;
  }

  // Function to validate CVV
  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the CVV';
    }
    if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'CVV must contain only digits';
    }
    return null;
  }

  // Function to validate expiry date
  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the expiry date';
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(value)) {
      return 'Expiry date must be in MM/YY format';
    }
    return null;
  }

  // Function to validate name on the card
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the name on the card';
    }
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
              const Text(
                'Select Card Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Visa',
                    groupValue: cardType,
                    onChanged: (value) {
                      setState(() {
                        cardType = value;
                      });
                    },
                  ),
                  Image.asset('assets/images/visa.png', width: 40),
                  const SizedBox(width: 10),
                  const Text('Visa'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'MasterCard',
                    groupValue: cardType,
                    onChanged: (value) {
                      setState(() {
                        cardType = value;
                      });
                    },
                  ),
                  Image.asset('assets/images/mastercard.png', width: 40),
                  const SizedBox(width: 10),
                  const Text('MasterCard'),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name on the Card',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                validator: _validateCardNumber,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateExpiryDate,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
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
                  child: const Text('Save Details',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

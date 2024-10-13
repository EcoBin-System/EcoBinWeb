import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';
import '../widgets/payment_method_radio.dart';

class GarbagePickupFormPage extends StatefulWidget {
  @override
  _GarbagePickupFormPageState createState() => _GarbagePickupFormPageState();
}

class _GarbagePickupFormPageState extends State<GarbagePickupFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  final TextEditingController _totalPaymentController = TextEditingController();
  String _paymentMethod = '';

  final List<String> _paymentMethods = ['Credit Card'];

  List<Map<String, dynamic>> _garbageBinDetails = [
    {'type': '', 'percentage': ''}
  ];

  final List<String> _allGarbageTypes = [
    'Organic',
    'Plastic',
    'Recyclable',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotalPayment();
  }

  @override
  void dispose() {
    _totalPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garbage Pickup Schedule Form')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatePicker(
                  selectedDate: _pickupDate,
                  onDateSelected: (date) => setState(() => _pickupDate = date),
                ),
                SizedBox(height: 16),
                TimePicker(
                  selectedTime: _pickupTime,
                  onTimeSelected: (time) => setState(() => _pickupTime = time),
                ),
                SizedBox(height: 16),
                Text('Garbage Bin Details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ..._buildGarbageBinDetailsFields(),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addGarbageBinDetail,
                  child: Text('Add Garbage Bin Detail'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _totalPaymentController,
                  decoration: InputDecoration(
                    labelText: 'Total Payment',
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16),
                PaymentMethodRadio(
                  paymentMethods: _paymentMethods,
                  selectedMethod: _paymentMethod,
                  onMethodSelected: (method) =>
                      setState(() => _paymentMethod = method),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGarbageBinDetailsFields() {
    return _garbageBinDetails.asMap().entries.map((entry) {
      int idx = entry.key;
      var detail = entry.value;
      List<String> availableTypes = _getAvailableGarbageTypes(idx);

      // Ensure the current value is in the available types
      String currentValue = detail['type'];
      if (currentValue.isNotEmpty && !availableTypes.contains(currentValue)) {
        availableTypes.add(currentValue);
      }

      return Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: currentValue.isNotEmpty ? currentValue : null,
              decoration: InputDecoration(labelText: 'Type'),
              items: availableTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _garbageBinDetails[idx]['type'] = newValue ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a bin type';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: detail['percentage'],
              decoration: InputDecoration(labelText: 'Percentage'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _garbageBinDetails[idx]['percentage'] = value;
                  _calculateTotalPayment();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the percentage';
                }
                double? percentage = double.tryParse(value);
                if (percentage == null || percentage < 0 || percentage > 100) {
                  return 'Enter a valid percentage (0-100)';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _removeGarbageBinDetail(idx),
          ),
        ],
      );
    }).toList();
  }

  List<String> _getAvailableGarbageTypes(int currentIndex) {
    List<String> selectedTypes = _garbageBinDetails
        .asMap()
        .entries
        .where((entry) =>
            entry.key != currentIndex && entry.value['type'].isNotEmpty)
        .map((entry) => entry.value['type'] as String)
        .toList();

    return _allGarbageTypes
        .where((type) => !selectedTypes.contains(type))
        .toList();
  }

  void _addGarbageBinDetail() {
    setState(() {
      _garbageBinDetails.add({'type': '', 'percentage': ''});
    });
  }

  void _removeGarbageBinDetail(int index) {
    setState(() {
      _garbageBinDetails.removeAt(index);
      _calculateTotalPayment();
    });
  }

  void _calculateTotalPayment() {
    double totalPayment = 0;
    for (var detail in _garbageBinDetails) {
      double percentage = double.tryParse(detail['percentage'] ?? '0') ?? 0;
      totalPayment += (percentage / 100) * 50;
    }
    _totalPaymentController.text = totalPayment.toStringAsFixed(2);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(currentUser.uid).get();

          if (!userDoc.exists) {
            throw Exception('User document does not exist');
          }

          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          if (_pickupDate == null || _pickupTime == null) {
            throw Exception('Pickup date or time is not selected');
          }

          PickupRequest request = PickupRequest(
            userId: currentUser.uid,
            userName: userData['name'],
            userAddress:
                '${userData['addressNo']}, ${userData['street']}, ${userData['city']}',
            pickupDate: _pickupDate!,
            pickupTime:
                '${_pickupTime!.hour}:${_pickupTime!.minute.toString().padLeft(2, '0')}',
            garbageBinDetails: _garbageBinDetails,
            totalPayment: double.parse(_totalPaymentController.text),
            paymentMethod: _paymentMethod,
            createdAt: DateTime.now(),
          );

          await _firestore.collection('pickupRequests').add(request.toMap());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pickup request submitted successfully!')),
          );
        } else {
          throw Exception('No authenticated user found');
        }
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

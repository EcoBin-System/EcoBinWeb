import 'package:ecobin_app/pages/pickup_records.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';
import '../widgets/payment_method_radio.dart';
import 'package:logger/logger.dart';

class GarbagePickupFormPage extends StatefulWidget {
  @override
  _GarbagePickupFormPageState createState() => _GarbagePickupFormPageState();
}

class _GarbagePickupFormPageState extends State<GarbagePickupFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  final TextEditingController _totalPaymentController = TextEditingController();
  String _paymentMethod = '';
  List<Map<String, dynamic>> _garbageBinDetails = [
    {'type': '', 'percentage': ''}
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserBins();
    _logger.i('Initialized GarbagePickupFormPage');
  }

  Future<void> _fetchUserBins() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final binsSnapshot = await _firestore
            .collection('bins')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        final fetchedBins = binsSnapshot.docs.map((doc) {
          final binData = doc.data() as Map<String, dynamic>;
          final usedPercentage =
              _calculateUsedPercentage(binData['availability']);
          return {
            'type': binData['binType'] ?? '',
            'percentage': usedPercentage
          };
        }).toList();

        setState(() {
          _garbageBinDetails = fetchedBins.isNotEmpty
              ? fetchedBins
              : [
                  {'type': '', 'percentage': ''}
                ];
        });
        _calculateTotalPayment();
      } catch (e) {
        _logger.e('Error fetching bins: $e');
      }
    }
  }

  String _calculateUsedPercentage(String? availabilityString) {
    final availability =
        double.tryParse(availabilityString?.replaceAll('%', '') ?? '0') ?? 0;
    return (100 - availability).toStringAsFixed(0);
  }

  void _calculateTotalPayment() {
    double totalPayment = 0;
    for (var detail in _garbageBinDetails) {
      totalPayment +=
          (double.tryParse(detail['percentage'] ?? '0') ?? 0) / 100 * 150;
    }
    _totalPaymentController.text = totalPayment.toStringAsFixed(2);
    _logger.i('Calculated total payment: $totalPayment');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final userDoc =
              await _firestore.collection('users').doc(currentUser.uid).get();
          if (!userDoc.exists) throw Exception('User document does not exist');

          final userData = userDoc.data() as Map<String, dynamic>;
          if (_pickupDate == null || _pickupTime == null) {
            throw Exception('Pickup date or time is not selected');
          }

          final request = PickupRequest(
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
          _navigateToPickupRecordsPage();
        } else {
          throw Exception('No authenticated user found');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to submit request: $e');
      }
    } else {
      _logger.w('Form validation failed');
    }
  }

  void _navigateToPickupRecordsPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => UserPickupRequestsPage()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _totalPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF27AE60),
        title: const Text("Pickup Form",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatePicker(
                  selectedDate: _pickupDate,
                  onDateSelected: (date) => setState(() => _pickupDate = date),
                ),
                const SizedBox(height: 16),
                TimePicker(
                  selectedTime: _pickupTime,
                  onTimeSelected: (time) => setState(() => _pickupTime = time),
                ),
                const SizedBox(height: 16),
                Column(
                  children: _buildGarbageBinDetailsFields(),
                ),
                const SizedBox(height: 16),
                _buildTotalPaymentField(),
                const SizedBox(height: 16),
                _buildPaymentMethodField(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5FAD46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPaymentField() {
    return _buildInputContainer(
      label: 'Total Amount(LKR)',
      input: Text(_totalPaymentController.text),
      icon: Icons.money,
    );
  }

  Widget _buildPaymentMethodField() {
    return _buildInputContainer(
      label: 'Payment Method',
      input: PaymentMethodRadio(
        paymentMethods: const ['Credit Card'],
        selectedMethod: _paymentMethod,
        onMethodSelected: (method) => setState(() => _paymentMethod = method),
      ),
    );
  }

  Widget _buildInputContainer(
      {required String label, required Widget input, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            suffixIcon:
                icon != null ? Icon(icon, color: Color(0xFF5FAD46)) : null,
            filled: true,
            fillColor: Colors.white,
          ),
          child: input,
        ),
      ],
    );
  }

  List<Widget> _buildGarbageBinDetailsFields() {
    return _garbageBinDetails.map((detail) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFECECEC), width: 1.0),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text('${detail['type']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 1,
                child: Text('${detail['percentage']}%',
                    textAlign: TextAlign.right)),
          ],
        ),
      );
    }).toList();
  }
}

import 'package:ecobin_app/pages/pickup_records.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';
import '../widgets/payment_method_radio.dart';

class GarbagePickupFormPage extends StatefulWidget {
  final FirebaseAuth? auth; //FirebaseAuth instance
  final FirebaseFirestore? firestore; //FirebaseFirestore instance

  const GarbagePickupFormPage({Key? key, this.auth, this.firestore})
      : super(key: key);

  @override
  GarbagePickupFormPageState createState() => GarbagePickupFormPageState();
}

class GarbagePickupFormPageState extends State<GarbagePickupFormPage> {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late TextEditingController totalPaymentController;
  String _paymentMethod = '';
  List<Map<String, dynamic>> garbageBinDetails = [
    {'type': '', 'percentage': ''}
  ];
  final _formKey = GlobalKey<FormState>();
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;

  @override
  void initState() {
    super.initState();

    // Initialize FirebaseAuth, FirebaseFirestore
    _auth = widget.auth ?? FirebaseAuth.instance;
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    totalPaymentController = TextEditingController();
    _fetchUserBins();
  }

  Future<void> _fetchUserBins() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Fetch bins
        final binsSnapshot = await _firestore
            .collection('bins')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        final fetchedBins = binsSnapshot.docs.map((doc) {
          final binData = doc.data() as Map<String, dynamic>;
          final usedPercentage =
              calculateUsedPercentage(binData['availability']);
          return {
            'type': binData['binType'] ?? '',
            'percentage': usedPercentage
          };
        }).toList();

        setState(() {
          garbageBinDetails = fetchedBins.isNotEmpty
              ? fetchedBins
              : [
                  {'type': '', 'percentage': ''}
                ];
        });
        calculateTotalPayment();
      } catch (e) {
        print('Error fetching bins: $e'); // Minimal error logging for debugging
      }
    }
  }

  String calculateUsedPercentage(String? availabilityString) {
    final availability =
        double.tryParse(availabilityString?.replaceAll('%', '') ?? '0') ?? 0;
    return (100 - availability).toStringAsFixed(0);
  }

  void calculateTotalPayment() {
    double totalPayment = 0;
    for (var detail in garbageBinDetails) {
      double percentage = double.tryParse(detail['percentage'] ?? '0') ?? 0;

      if (percentage < 0 || percentage > 100) {
        throw ArgumentError('Percentage must be between 0 and 100.');
      }

      totalPayment += (percentage / 100) * 150;
    }

    totalPaymentController.text = totalPayment.toStringAsFixed(2);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_pickupDate == null) {
        _showErrorSnackBar('Please select a pickup date.');
        return;
      }
      if (_pickupTime == null) {
        _showErrorSnackBar('Please select a pickup time.');
        return;
      }
      if (_paymentMethod.isEmpty) {
        _showErrorSnackBar('Please select a payment method.');
        return;
      }

      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final userDoc =
              await _firestore.collection('users').doc(currentUser.uid).get();
          if (!userDoc.exists) throw Exception('User document does not exist');

          final userData = userDoc.data() as Map<String, dynamic>;

          final request = PickupRequest(
            userId: currentUser.uid,
            userName: userData['name'],
            userAddress:
                '${userData['addressNo']}, ${userData['street']}, ${userData['city']}',
            pickupDate: _pickupDate!,
            pickupTime:
                '${_pickupTime!.hour}:${_pickupTime!.minute.toString().padLeft(2, '0')}',
            garbageBinDetails: garbageBinDetails,
            totalPayment: double.parse(totalPaymentController.text),
            paymentMethod: _paymentMethod,
            createdAt: DateTime.now(),
          );

          await _firestore.collection('pickupRequests').add(request.toMap());

          _showSuccessSnackBar('Pickup request submitted successfully!');

          _navigateToPickupRecordsPage();
        } else {
          throw Exception('No authenticated user found');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to submit request: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
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
    totalPaymentController.dispose();
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
                  onDateSelected: (date) {
                    setState(() => _pickupDate = date);
                  },
                ),
                const SizedBox(height: 16),
                TimePicker(
                  selectedTime: _pickupTime,
                  onTimeSelected: (time) {
                    setState(() => _pickupTime = time);
                  },
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

//total payment input field
  Widget _buildTotalPaymentField() {
    return _buildInputContainer(
      label: 'Total Amount(LKR)',
      input: Text(totalPaymentController.text),
      icon: Icons.money,
    );
  }

//payment method radio buttons
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

//input container- text fields
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

//garbage bin detail
  List<Widget> _buildGarbageBinDetailsFields() {
    return garbageBinDetails.map((detail) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE3E6E6)),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Garbage Type: ${detail['type']}, '
              'Filled Percentage: ${detail['percentage']}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }).toList();
  }
}

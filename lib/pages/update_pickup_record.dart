import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';

class UpdatePickupRequestPage extends StatefulWidget {
  final PickupRequest request;

  const UpdatePickupRequestPage({Key? key, required this.request})
      : super(key: key);

  @override
  _UpdatePickupRequestPageState createState() =>
      _UpdatePickupRequestPageState();
}

class _UpdatePickupRequestPageState extends State<UpdatePickupRequestPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _pickupDate;
  late TimeOfDay _pickupTime;

  @override
  void initState() {
    super.initState();
    _pickupDate = widget.request.pickupDate;
    _pickupTime = TimeOfDay(
      hour: int.parse(widget.request.pickupTime.split(':')[0]),
      minute: int.parse(widget.request.pickupTime.split(':')[1]),
    );
  }

  Future<void> _updateRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedRequest = _createUpdatedRequest();

        await _updateFirestore(updatedRequest);

        _showSuccessMessage();
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage();
      }
    }
  }

  PickupRequest _createUpdatedRequest() {
    return PickupRequest(
      id: widget.request.id,
      userId: widget.request.userId,
      userName: widget.request.userName,
      userAddress: widget.request.userAddress,
      pickupDate: _pickupDate,
      pickupTime:
          '${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}',
      garbageBinDetails: widget.request.garbageBinDetails,
      totalPayment: widget.request.totalPayment,
      paymentMethod: widget.request.paymentMethod,
      status: widget.request.status,
      createdAt: widget.request.createdAt,
    );
  }

  Future<void> _updateFirestore(PickupRequest updatedRequest) async {
    await FirebaseFirestore.instance
        .collection('pickupRequests')
        .doc(widget.request.id)
        .update({
      'pickupDate': _pickupDate,
      'pickupTime':
          '${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}',
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pickup date and time updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating request. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF27AE60),
        title: const Text("Update Pickup Request",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Current Pickup Date and Time:'),
                SizedBox(height: 8),
                _buildCurrentDateTime(),
                SizedBox(height: 24),
                _buildSectionTitle('Update Pickup Date and Time:'),
                SizedBox(height: 16),
                _buildDatePicker(),
                SizedBox(height: 16),
                _buildTimePicker(),
                SizedBox(height: 32),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCurrentDateTime() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              '${widget.request.pickupDate.toString().split(' ')[0]} at ${widget.request.pickupTime}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return DatePicker(
      selectedDate: _pickupDate,
      onDateSelected: (date) {
        setState(() => _pickupDate = date);
      },
    );
  }

  Widget _buildTimePicker() {
    return TimePicker(
      selectedTime: _pickupTime,
      onTimeSelected: (time) {
        setState(() => _pickupTime = time);
      },
    );
  }

  Widget _buildUpdateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _updateRequest,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            'Update Pickup Date and Time',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5FAD46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

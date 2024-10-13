import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';
import '../widgets/date_picker.dart';
import '../widgets/time_picker.dart';
import 'package:logger/logger.dart'; // Import logger package

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
  final Logger _logger = Logger(); // Create a logger instance

  @override
  void initState() {
    super.initState();
    _pickupDate = widget.request.pickupDate;
    _pickupTime = TimeOfDay(
      hour: int.parse(widget.request.pickupTime.split(':')[0]),
      minute: int.parse(widget.request.pickupTime.split(':')[1]),
    );
  }

  void _updateRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedRequest = PickupRequest(
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

        // Logging the update request details
        _logger.i('Updating pickup request: ${updatedRequest.id}');

        await FirebaseFirestore.instance
            .collection('pickupRequests')
            .doc(widget.request.id)
            .update({
          'pickupDate': _pickupDate,
          'pickupTime':
              '${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}',
        });

        _logger.i(
            'Pickup date and time updated successfully for request: ${widget.request.id}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pickup date and time updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        _logger.e('Error updating request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating request. Please try again.')),
        );
      }
    } else {
      _logger.w('Form validation failed. Please check your inputs.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Pickup Date and Time')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Pickup Date and Time:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    '${widget.request.pickupDate.toString().split(' ')[0]} at ${widget.request.pickupTime}'),
                SizedBox(height: 16),
                Text('Update Pickup Date and Time:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                DatePicker(
                  selectedDate: _pickupDate,
                  onDateSelected: (date) => setState(() => _pickupDate = date),
                ),
                SizedBox(height: 16),
                TimePicker(
                  selectedTime: _pickupTime,
                  onTimeSelected: (time) => setState(() => _pickupTime = time),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateRequest,
                    child: Text('Update Pickup Date and Time'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

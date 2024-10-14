import 'package:flutter/material.dart';
import '../models/pickup_request.dart';

class DeleteRecordPage extends StatelessWidget {
  final PickupRequest request;

  const DeleteRecordPage({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Record')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'Are you sure you want to delete the request ID: ${request.id}?',
                  textAlign: TextAlign.center),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Implement delete logic here
                      // After deleting, you might want to pop back to the previous page
                      Navigator.pop(context);
                    },
                    child: Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel deletion
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

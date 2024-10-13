import 'package:ecobin_app/pages/update_pickup_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../models/pickup_request.dart';

class PickupRecordCard extends StatelessWidget {
  final PickupRequest request;

  const PickupRecordCard({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Constants for styling
    const double cardMargin = 8.0;
    const double paddingValue = 16.0;

    // Format the pickup date
    String formattedDate =
        DateFormat.yMMMd().format(request.pickupDate.toLocal());
    String formattedTime = request.pickupTime ?? "N/A";

    return Card(
      margin: EdgeInsets.all(cardMargin),
      child: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Request ID
            Text(
              'Request ID: ${request.id ?? "N/A"}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Display Date and Time in one row
            Row(
              children: [
                Text('Date: $formattedDate'),
                SizedBox(width: 16),
                Text('Time: $formattedTime'),
              ],
            ),
            SizedBox(height: 8),

            // Display Garbage Bin Details
            Text('Garbage Bin Details:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...request.garbageBinDetails.map((detail) {
              return Text('  - ${detail['type']}: ${detail['percentage']}%');
            }).toList(),
            SizedBox(height: 8),

            // Display Total Payment
            Text(
              'Total Payment: \$${request.totalPayment.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Display Request Status
            Text('Status: ${request.status}'),
            SizedBox(height: 16),

            // Add Edit button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdatePickupRequestPage(request: request),
                    ),
                  );
                },
                child: Text('Edit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

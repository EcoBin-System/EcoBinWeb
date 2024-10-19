import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecobin_app/models/pickup_request.dart';
import 'package:ecobin_app/pages/update_pickup_record.dart';

class PickupRecordCard extends StatelessWidget {
  final PickupRequest request;

  const PickupRecordCard({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildDateTimeRow(),
            const SizedBox(height: 16),
            _buildGarbageBinDetails(),
            const SizedBox(height: 16),
            _buildPaymentAndStatus(),
            const SizedBox(height: 16),
            if (request.status.toLowerCase() == 'pending')
              _buildEditButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Request ID: ${request.id ?? "N/A"}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        request.status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: _getStatusColor(),
    );
  }

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'completed':
        return const Color.fromARGB(255, 96, 112, 169);
      case 'pending':
        return const Color.fromARGB(255, 156, 208, 131);
      case 'cancelled':
        return const Color.fromARGB(255, 208, 128, 122);
      default:
        return const Color.fromARGB(255, 174, 174, 174);
    }
  }

  Widget _buildDateTimeRow() {
    String formattedDate =
        DateFormat.yMMMd().format(request.pickupDate.toLocal());
    String formattedTime = request.pickupTime ?? "N/A";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(Icons.calendar_today, 'Date', formattedDate),
        _buildInfoItem(Icons.access_time, 'Time', formattedTime),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('$label: $value', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildGarbageBinDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Garbage Bins',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...request.garbageBinDetails.map((detail) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(detail['type']),
                Text('${detail['percentage']}%',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Payment:',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          '\LKR ${request.totalPayment.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdatePickupRequestPage(request: request),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5FAD46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          'Edit Request',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:ecobin_app/widgets/pickup_record_card.dart';
import 'package:flutter/material.dart';
import '../models/pickup_request.dart';
import '../services/firebase_service.dart';
import 'package:logger/logger.dart'; // Import logger package

class UserPickupRequestsPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final Logger _logger = Logger(); // Create a logger instance

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Three tabs for Completed, Pending, and Cancelled
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Pickup Records'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Completed'),
              Tab(text: 'Pending'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Completed Tab
            _buildPickupRecordsTab(status: 'completed'),
            // Pending Tab
            _buildPickupRecordsTab(status: 'pending'),
            // Cancelled Tab
            _buildPickupRecordsTab(status: 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupRecordsTab({required String status}) {
    return StreamBuilder<List<PickupRequest>>(
      stream: _firebaseService.getUserPickupRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _logger.i('Waiting for pickup requests data...');
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          _logger.e('Error fetching pickup requests: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          _logger.w('No pickup requests found for the user.');
          return Center(child: Text('No pickup requests found.'));
        }

        // Filter pickup requests based on the specified status
        final filteredRequests = snapshot.data!
            .where((request) => request.status.toLowerCase() == status)
            .toList();

        if (filteredRequests.isEmpty) {
          _logger.w('No $status pickup requests found.');
          return Center(child: Text('No $status pickup requests found.'));
        }

        _logger.i(
            '$status pickup requests retrieved: ${filteredRequests.length} found.');

        return ListView.builder(
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            return PickupRecordCard(request: filteredRequests[index]);
          },
        );
      },
    );
  }
}

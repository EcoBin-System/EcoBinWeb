import 'package:ecobin_app/widgets/pickup_record_card.dart';
import 'package:flutter/material.dart';
import '../models/pickup_request.dart';
import '../services/firebase_service.dart';

class UserPickupRequestsPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

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
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No pickup requests found.'));
        }

        // Filter pickup requests based on the specified status
        final filteredRequests = snapshot.data!
            .where((request) => request.status.toLowerCase() == status)
            .toList();

        if (filteredRequests.isEmpty) {
          return Center(child: Text('No $status pickup requests found.'));
        }

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

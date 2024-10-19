import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ecobin_app/widgets/pickup_record_card.dart';
import 'package:ecobin_app/models/pickup_request.dart';
import 'package:ecobin_app/services/firebase_service.dart';

class UserPickupRequestsPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final Logger _logger = Logger();

  UserPickupRequestsPage({Key? key}) : super(key: key);

//main UI-tab interface
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pickups and status",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              _buildTab('Completed'),
              _buildTab('Pending'),
              _buildTab('Cancelled'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
          backgroundColor: Color(0xFF27AE60),
        ),
        body: TabBarView(
          children: [
            _buildPickupRecordsTab(status: 'completed'),
            _buildPickupRecordsTab(status: 'pending'),
            _buildPickupRecordsTab(status: 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

//tab displaying pickup requests based on status
  Widget _buildPickupRecordsTab({required String status}) {
    return StreamBuilder<List<PickupRequest>>(
      stream: _firebaseService.getUserPickupRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _logger.i('Waiting for pickup requests data...');
          return _buildLoadingIndicator();
        }
        if (snapshot.hasError) {
          _logger.e('Error fetching pickup requests: ${snapshot.error}');
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          _logger.w('No pickup requests found for the user.');
          return _buildEmptyStateWidget('No pickup requests found.');
        }

        final filteredRequests = snapshot.data!
            .where((request) => request.status.toLowerCase() == status)
            .toList();

        if (filteredRequests.isEmpty) {
          _logger.w('No $status pickup requests found.');
          return _buildEmptyStateWidget('No $status pickup requests found.');
        }

        _logger.i(
            '$status pickup requests retrieved: ${filteredRequests.length} found.');
        return _buildPickupRequestsList(filteredRequests);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

//error message
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $error',
          style: TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

//No request error message
  Widget _buildEmptyStateWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

//List view for pickup request cards
  Widget _buildPickupRequestsList(List<PickupRequest> requests) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: PickupRecordCard(request: requests[index]),
        );
      },
    );
  }
}

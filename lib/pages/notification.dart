import 'package:flutter/material.dart';
import 'package:ecobin_app/services/notification_service.dart';
import 'package:ecobin_app/models/notification_model.dart';
import 'package:ecobin_app/pages/monitor_bin.dart';

class NotificationPage extends StatelessWidget {
  final NotificationService notificationService;

  NotificationPage({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Row(
        children: [
          // Sidebar menu
          Container(
            width: 250,
            color: Colors.green[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Monitoring'),
                  onTap: () {
                    // Navigate to monitoring section
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MonitorBin()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Alerts'),
                  onTap: () {
                    // Navigation to alerts page.
                  },
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Fixed at the top)
                Container(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 40.0,
                    right: 20.0,
                    bottom: 5.0,
                  ),
                  width: double.infinity,
                  child: const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 40.0,
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  child: Text(
                    'Check you notifications frequently.Here are your recent notifications regarding bin availability.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),

                // Notification list (this is where the notifications will be displayed)
                Expanded(
                  child: FutureBuilder<List<NotificationModel>>(
                    future: notificationService.checkBinAvailability(), // Corrected future type
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No notifications available.'));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var notification = snapshot.data![index];
                          return Card(
                            margin: const EdgeInsets.only(left: 40.0,right: 40.0,bottom: 10.0),
                            color: Colors.green[100],
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(notification.message),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

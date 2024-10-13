import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecobin_app/services/database.dart';
import 'package:ecobin_app/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final DatabaseService _databaseService = DatabaseService();
  List<NotificationModel> notifications = [];

  Future<List<NotificationModel>> checkBinAvailability() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

    // Retrieve bins for the current user
    List<DocumentSnapshot> bins = await _databaseService.getBinsByUserId(currentUserId);

    notifications.clear(); // Clear old notifications
    for (var bin in bins) {
      var data = bin.data() as Map<String, dynamic>;
      int availability = int.parse(data['availability'].replaceAll('%', ''));

      if (availability <= 10) {
        notifications.add(NotificationModel(
          binType: data['binType'],
          message: 'Your ${data['binType']} bin is full. Only ${data['availability']} space available.',
        ));
      }
    }

    return notifications; // Return the list of notifications
  }

  Future<void> clearNotificationsForBin(String binType) async {
    notifications.removeWhere((notification) => notification.binType == binType);
    await _databaseService.updateBinAvailability(binType, '100%'); // Reset availability to 100%
  }
}

class NotificationModel {
  final String binType; // Type of the bin (e.g., plastic, paper, glass)
  final String message;  // Notification message

  // Constructor to initialize the NotificationModel
  NotificationModel({
    required this.binType,
    required this.message,
  });
}
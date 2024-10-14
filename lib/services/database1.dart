import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  //Adding goals to firebase
  Future<void> addGoalDetails(
      Map<String, dynamic> goalInfoMap, String id) async {
    try {
      goalInfoMap['created_at'] =
          FieldValue.serverTimestamp(); // Add server timestamp
      await FirebaseFirestore.instance
          .collection("Goals")
          .doc(id)
          .set(goalInfoMap);
    } catch (e) {
      print("Error adding goal details: $e");
      throw e;
    }
  }

  //Retrieving goals from firebase based on user UID
  Future<Stream<QuerySnapshot>> getGoalDetails(String uid) async {
    try {
      return FirebaseFirestore.instance
          .collection('Goals')
          .where("UserID", isEqualTo: uid)
          .where('created_at',
              isNotEqualTo: null) // Only fetch goals with a created_at field
          .orderBy('created_at', descending: true) // Order by creation date
          .snapshots();
    } catch (e) {
      print("Error fetching goal details: $e");
      throw e;
    }
  }

  //Updating goals in firebase
  Future<void> updateGoalDetails(
      String id, Map<String, dynamic> updateInfo) async {
    try {
      await FirebaseFirestore.instance
          .collection("Goals")
          .doc(id)
          .update(updateInfo);
    } catch (e) {
      print("Error updating goal details: $e");
      throw e;
    }
  }

  //Deleting goals from firebase
  Future<void> deleteGoal(String id) async {
    try {
      await FirebaseFirestore.instance.collection("Goals").doc(id).delete();
    } catch (e) {
      print("Error deleting goal: $e");
      throw e;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get user bin updates
  Stream<QuerySnapshot> getUserBinUpdates(String userId) {
    return _firestore
        .collection('binUpdates') // Your Firestore collection name
        .where('userId', isEqualTo: userId) // Filter by userId
        .snapshots(); // Return a stream
  }
}

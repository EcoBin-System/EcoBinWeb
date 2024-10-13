import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add bin details to Firestore and return the document ID
  Future<String> addBinDetails({
    required String name,
    required String address,
    required String binType,
    required String binHeight,
    required String userId, // Add this parameter
    String availability = '100%', // Default value
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('bins').add({
        'name': name,
        'address': address,
        'binType': binType,
        'binHeight': binHeight,
        'userId': userId, // Store userId in Firestore
        'availability': availability,
      });
      return docRef.id; // Return the document ID for QR code generation
    } catch (e) {
      print('Error adding bin details: $e');
      throw Exception('Failed to add bin details');
    }
  }

  // Method to retrieve all bin details
  // Future<List<DocumentSnapshot>> getBins() async {
  //   try {
  //     QuerySnapshot querySnapshot = await _firestore.collection('bins').get();
  //     return querySnapshot.docs; // Return list of all bin documents
  //   } catch (e) {
  //     print('Error retrieving bin details: $e');
  //     throw Exception('Failed to retrieve bin details');
  //   }
  // }

  // Method to get bins by specific user ID for display alerts for user
  Future<List<DocumentSnapshot>> getBinsByUserId(String? userId) async {
    if (userId == null) {
      return []; // Return an empty list if no user ID is provided
    }
    QuerySnapshot snapshot = await _firestore
        .collection('bins')
        .where('userId', isEqualTo: userId) // Assuming 'userId' is the field that stores the owner's ID
        .get();
    return snapshot.docs;
  }

  // Method to retrieve bin details by binID for generate QR code
  Future<DocumentSnapshot> getBinDetailsById(String binId) async {
    try {
      DocumentSnapshot binDoc =
          await _firestore.collection('bins').doc(binId).get();
      return binDoc;
    } catch (e) {
      print('Error retrieving bin details: $e');
      throw Exception('Failed to retrieve bin details');
    }
  }

  // Method to update bin availability
  Future<void> updateBinAvailability(
      String binType, String newAvailability) async {
    try {
      // You might want to specify which bin to update based on binType
      QuerySnapshot querySnapshot = await _firestore
          .collection('bins')
          .where('binType', isEqualTo: binType)
          .get();

      for (var binDoc in querySnapshot.docs) {
        await binDoc.reference.update({
          'availability': newAvailability,
        });
      }
    } catch (e) {
      print('Error updating bin availability: $e');
      throw Exception('Failed to update bin availability');
    }
  }

  // Method to update bin details
  Future<void> updateBinDetails({
    required String binId,
    required String binType,
    required String binHeight,
    required String address,
  }) async {
    try {
      await _firestore.collection('bins').doc(binId).update({
        'binType': binType,
        'binHeight': binHeight,
        'address': address,
      });
    } catch (e) {
      print('Error updating bin details: $e');
      throw Exception('Failed to update bin details');
    }
  }

  // Method to delete bin
  Future<void> deleteBin(String binId) async {
    try {
      await _firestore.collection('bins').doc(binId).delete();
    } catch (e) {
      print('Error deleting bin: $e');
      throw Exception('Failed to delete bin');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecobin_app/models/pickup_request.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Submit a new pickup request
  Future<void> submitPickupRequest(Map<String, dynamic> requestData) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (!userDoc.exists) {
          throw Exception('User document does not exist');
        }

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        requestData['userId'] = currentUser.uid;
        requestData['userName'] = userData['name'];
        requestData['userAddress'] =
            '${userData['addressNo']}, ${userData['street']}, ${userData['city']}';
        requestData['status'] = 'pending';
        requestData['createdAt'] = FieldValue.serverTimestamp();
        requestData['garbageBinDetails'] =
            requestData['garbageBinDetails'] ?? [];

        await _firestore.collection('pickupRequests').add(requestData);
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('Error submitting pickup request: $e');
      throw e;
    }
  }

  // Fetch user's pickup requests
  Stream<List<PickupRequest>> getUserPickupRequests() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('pickupRequests')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PickupRequest.fromFirestore(doc))
              .toList());
    }
    return Stream.value([]);
  }

  // Function to update the waste data in Firestore
  Future<void> updateWasteData({
    required String requestId,
    required String userId,
    required String pickupDate,
    required String pickupTime,
    required List<Map<String, dynamic>> garbageBinDetails,
    required double totalPayment,
  }) async {
    try {
      // Create the document reference for the specific request
      DocumentReference documentReference =
          _firestore.collection('pickup_requests').doc(requestId);

      // Data to be updated in Firestore
      Map<String, dynamic> updatedData = {
        'pickupDate': Timestamp.fromDate(DateTime.parse(pickupDate)),
        'pickupTime': pickupTime,
        'garbageBinDetails': garbageBinDetails,
        'totalPayment': totalPayment,
      };

      // Update the document in Firestore
      await documentReference.update(updatedData);
    } catch (e) {
      throw Exception("Failed to update waste data: $e");
    }
  }
}

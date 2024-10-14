import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequest {
  final String? id;
  final String userId;
  final String userName;
  final String userAddress;
  final DateTime pickupDate;
  final String pickupTime;
  final List<Map<String, dynamic>> garbageBinDetails;
  final double totalPayment;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  PickupRequest({
    this.id,
    required this.userId,
    required this.userName,
    required this.userAddress,
    required this.pickupDate,
    required this.pickupTime,
    required this.garbageBinDetails,
    required this.totalPayment,
    required this.paymentMethod,
    this.status = 'pending', // Default status
    required this.createdAt,
  });

  factory PickupRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PickupRequest(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      userAddress: data['userAddress'],
      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      pickupTime: data['pickupTime'],
      garbageBinDetails: data['garbageBinDetails'] != null
          ? List<Map<String, dynamic>>.from(data['garbageBinDetails'])
          : [], // Default to an empty list if garbageBinDetails is null
      totalPayment: data['totalPayment'],
      paymentMethod: data['paymentMethod'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  get date => null;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAddress': userAddress,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'pickupTime': pickupTime,
      'garbageBinDetails': garbageBinDetails,
      'totalPayment': totalPayment,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

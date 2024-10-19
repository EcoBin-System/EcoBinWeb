import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ecobin_app/pages/garbage_pickup_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

void main() {
  group('GarbagePickupFormPageState', () {
    late GarbagePickupFormPageState state;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();

      final widget =
          GarbagePickupFormPage(auth: mockAuth, firestore: mockFirestore);
      state = GarbagePickupFormPageState();

      // Initialize the state with the mocked dependencies
      state.initState();

      // Initialize totalPaymentController
      state.totalPaymentController = TextEditingController();
    });

    test('calculateTotalPayment calculates correct amount', () {
      state.garbageBinDetails = [
        {'type': 'Organic', 'percentage': '50'},
        {'type': 'Plastic', 'percentage': '75'},
      ];

      state.calculateTotalPayment();

      expect(state.totalPaymentController.text, '187.50');
    });

    test('calculateTotalPayment handles empty list', () {
      state.garbageBinDetails = [];

      state.calculateTotalPayment();

      expect(state.totalPaymentController.text, '0.00');
    });

    test('calculateTotalPayment handles invalid percentages', () {
      state.garbageBinDetails = [
        {'type': 'Organic', 'percentage': 'invalid'},
        {'type': 'Plastic', 'percentage': '50'},
      ];

      state.calculateTotalPayment();

      expect(state.totalPaymentController.text, '75.00');
    });
  });
}

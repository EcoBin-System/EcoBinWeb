import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecobin_app/pages/binupdate.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
])
import 'binupdate_unit_test.mocks.dart';

// Custom mock for QueryDocumentSnapshot
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  MockQueryDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late QueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot;
  late Widget updateBinPage;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot('mockBinId', {
      'name': 'Test Bin',
      'binType': 'Plastic',
      'availability': '75%',
      'binHeight': '100',
      'address': 'Test Address',
      'userId': 'testUserId',
    });

    updateBinPage = MaterialApp(home: UpdateBinPage(firestore: mockFirestore));

    // Setup the mock chain
    when(mockFirestore.collection('bins')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockCollectionReference.get())
        .thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

    // Ensure that the document reference is also set up to return correct data
    when(mockDocumentReference.get())
        .thenAnswer((_) async => mockQueryDocumentSnapshot);
  });

  group('UpdateBinPage Tests', () {
    testWidgets(
      'Form Validation - Should validate availability field correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: updateBinPage,
          ),
        );
        await tester.pumpAndSettle();

        // Check if the dropdown is available
        expect(find.byType(DropdownButton), findsOneWidget);

        // Simulate selecting a bin
        await tester.tap(find.byType(DropdownButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Bin').first);
        await tester.pumpAndSettle();

        // Enter an invalid value
        await tester.enterText(find.byType(TextField).at(4), 'Invalid%');
        await tester.tap(find.text('Update Bin'));
        await tester.pumpAndSettle();

        // Check for an error dialog
        expect(find.text('Invalid input'), findsOneWidget);
        expect(
            find.text(
                'Please enter a valid availability percentage (e.g., "20%").'),
            findsOneWidget);
      },
    );

    // Repeat similar adjustments for the other tests...
    // Make sure to validate that your DropdownButton is receiving the expected data.

    testWidgets('Form Validation - Should accept valid availability percentage',
        (WidgetTester tester) async {
      await tester.pumpWidget(updateBinPage);
      await tester.pumpAndSettle();

      // Simulate selecting a bin
      await tester.tap(find
          .byType(DropdownButton<QueryDocumentSnapshot<Map<String, dynamic>>>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Bin').first);
      await tester.pumpAndSettle();

      // Enter a valid value for availability percentage
      await tester.enterText(find.byType(TextField).at(4), '30%');

      // Mock successful update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      await tester.tap(find.text('Update Bin'));
      await tester.pumpAndSettle();

      // No error should be displayed
      expect(find.text('Invalid input'), findsNothing);
    });

    testWidgets('User Interactions - Should allow selecting and updating a bin',
        (WidgetTester tester) async {
      await tester.pumpWidget(updateBinPage);
      await tester.pumpAndSettle();

      // Simulate selecting a bin from the dropdown
      await tester.tap(find
          .byType(DropdownButton<QueryDocumentSnapshot<Map<String, dynamic>>>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Bin').first);
      await tester.pumpAndSettle();

      // The selected bin details should populate
      expect(find.text('Test Bin'), findsOneWidget);
      expect(find.text('Plastic'), findsOneWidget);

      // Change availability percentage
      await tester.enterText(find.byType(TextField).at(4), '50%');

      // Mock successful update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      await tester.tap(find.text('Update Bin'));
      await tester.pumpAndSettle();

      // Verify that the update function was called
      verify(mockDocumentReference.update({
        'availability': '50%',
      })).called(1);
    });

    testWidgets(
        'Error Handling - Should show an error dialog when Firestore update fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(updateBinPage);
      await tester.pumpAndSettle();

      // Simulate selecting a bin
      await tester.tap(find
          .byType(DropdownButton<QueryDocumentSnapshot<Map<String, dynamic>>>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Bin').first);
      await tester.pumpAndSettle();

      // Enter valid availability
      await tester.enterText(find.byType(TextField).at(4), '30%');

      // Simulate Firestore update failure
      when(mockDocumentReference.update(any))
          .thenThrow(Exception('Update failed'));

      // Tap the Update button
      await tester.tap(find.text('Update Bin'));
      await tester.pumpAndSettle();

      // Verify error dialog is shown
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to update the bin. Please try again later.'),
          findsOneWidget);
    });

    testWidgets(
        'Error Handling - No error dialog on successful Firestore update',
        (WidgetTester tester) async {
      await tester.pumpWidget(updateBinPage);
      await tester.pumpAndSettle();

      // Simulate selecting a bin
      await tester.tap(find
          .byType(DropdownButton<QueryDocumentSnapshot<Map<String, dynamic>>>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Bin').first);
      await tester.pumpAndSettle();

      // Enter valid availability
      await tester.enterText(find.byType(TextField).at(4), '40%');

      // Simulate successful Firestore update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      // Tap the Update button
      await tester.tap(find.text('Update Bin'));
      await tester.pumpAndSettle();

      // Verify no error dialog is shown
      expect(find.text('Error'), findsNothing);
    });
  });
}

import 'package:ecobin_app/models/pickup_request.dart';
import 'package:ecobin_app/widgets/pickup_record_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  group('PickupRecordCard', () {
    testWidgets('renders correctly with PickupRequest data',
        (WidgetTester tester) async {
      final request = PickupRequest(
        id: 'awgvVw34MD7JqmjaYoC6',
        userId: 'jTD4Q7rk5cVMBufqrnCY9oDrmkk1',
        userName: 'sahan kavishka',
        status: 'pending',
        userAddress: '32, valivita road, malmbe',
        pickupDate: DateTime(2024, 10, 21, 0, 0),
        pickupTime: '8:00',
        garbageBinDetails: [
          {'type': 'Plastic', 'percentage': '80'},
          {'type': 'Recyclable', 'percentage': '90'},
          {'type': 'Organic', 'percentage': '50'},
        ],
        totalPayment: 330.00,
        paymentMethod: 'Credit Card',
        createdAt: DateTime.now(),
      );

      await tester
          .pumpWidget(MaterialApp(home: PickupRecordCard(request: request)));
      await tester.pumpAndSettle();

      expect(find.text('Request ID: awgvVw34MD7JqmjaYoC6'), findsOneWidget);
      expect(find.text('pending'), findsOneWidget);

      final dateFormat = DateFormat.yMMMd();
      final formattedDate = dateFormat.format(request.pickupDate.toLocal());
      expect(find.text(formattedDate), findsOneWidget);
      expect(find.text(request.pickupTime), findsOneWidget);

      expect(find.text('Plastic'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Recyclable'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Organic'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('LKR 330.00'), findsOneWidget);
    });
  });
}

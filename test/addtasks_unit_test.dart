import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ecobin_app/pages/addtasks.dart';
import 'package:ecobin_app/services/database1.dart';
import 'package:intl/intl.dart';

// Generate a Mock class for DatabaseMethods
@GenerateMocks([DatabaseMethods])
import 'addtasks_unit_test.mocks.dart';

void main() {
  late MockDatabaseMethods mockDatabase;

  setUp(() {
    mockDatabase = MockDatabaseMethods();
  });

  Widget createWidgetForTesting({required Map<String, dynamic> task}) {
    return MaterialApp(
      home: TaskFormPage(task: task),
    );
  }

  group('TaskFormPage Tests', () {
    testWidgets('form validation works correctly', (WidgetTester tester) async {
      final testTask = {
        "Task Name": "Test Task",
        "Task": "This is a test task",
        "Task Type": "Weekly",
      };

      await tester.pumpWidget(createWidgetForTesting(task: testTask));

      // Try submitting the form without entering any date
      await tester.tap(find.text('Start Task'));
      await tester.pump();

      // Check that the validation error appears
      expect(find.text('Please enter the start date'), findsOneWidget);
    });

    testWidgets('end date is calculated correctly for weekly task',
        (WidgetTester tester) async {
      final testTask = {
        "Task Name": "Test Task",
        "Task": "This is a test task",
        "Task Type": "Weekly",
      };

      await tester.pumpWidget(createWidgetForTesting(task: testTask));

      // Select a start date
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Simulate selecting the current date
      await tester.pump();

      // Verify that the end date is set to one week later
      final expectedEndDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: 7)));
      expect(find.text(expectedEndDate), findsOneWidget);
    });

    testWidgets('should call DatabaseMethods to add a task',
        (WidgetTester tester) async {
      final testTask = {
        "Task Name": "Test Task",
        "Task": "This is a test task",
        "Task Type": "Weekly",
      };

      // Update the mock setup to return a Future<void> instead of null
      when(mockDatabase.addUserTask(any))
          .thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(createWidgetForTesting(task: testTask));

      // Set the start date
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Simulate selecting the current date
      await tester.pump();

      // Tap the button to start the task
      await tester.tap(find.text('Start Task'));
      await tester.pumpAndSettle();

      // Check that the database method was called
      verify(mockDatabase.addUserTask(any)).called(1);
    });
  });
}

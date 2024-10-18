import 'package:flutter_test/flutter_test.dart';
import 'package:ecobin_app/services/database1.dart'; 
import 'package:ecobin_app/pages/viewtasks.dart'; 
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate a Mock class for DatabaseMethods
@GenerateMocks([DatabaseMethods])
import 'viewtasks_unit_test.mocks.dart';

// Define the parseProgress function in the test file
double parseProgress(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    // Remove '%' if present and try to parse
    return double.tryParse(value.replaceAll('%', '')) ?? 0.0;
  }
  return 0.0;
}

void main() {
  // Define a mock instance
  late MockDatabaseMethods mockDatabase;

  setUp(() {
    mockDatabase = MockDatabaseMethods();
  });

  group('parseProgress function test', () {
    test('Positive Test: should return correct progress value for valid input',
        () {
      expect(parseProgress('75%'), 75.0); // Valid percentage string
      expect(parseProgress('75'), 75.0); // Valid number string
      expect(parseProgress(85), 85.0); // Valid integer
      expect(parseProgress(50.5), 50.5); // Valid double
    });

    test('Negative Test: should return 0.0 for invalid or null input', () {
      expect(parseProgress(null), 0.0); // Null input
      expect(parseProgress('invalid'), 0.0); // Invalid string input
    });
  });

  group('User task fetching test', () {
    const userId = 'testUserId'; // Ensure userId is a valid non-null string

    // Positive Test Case: Successfully fetch user tasks from the mock database
    test('Positive Test: should return user tasks list', () async {
      // Simulate a successful response from the mock database method
      when(mockDatabase.getUserTasks(any)).thenAnswer((_) async => [
            {'id': 'task1', 'title': 'Test Task'}
          ]);

      // Call the function and check for the expected result
      final tasks = await mockDatabase.getUserTasks(userId);
      expect(tasks.isNotEmpty, true);
      expect(tasks[0]['title'], 'Test Task');
    });

    // Negative Test Case: Handle when no tasks are found
    test('Negative Test: should return an empty list when no tasks found',
        () async {
      // Simulate an empty task list returned from the mock database
      when(mockDatabase.getUserTasks(any)).thenAnswer((_) async => []);

      // Call the function and check for the expected empty result
      final tasks = await mockDatabase.getUserTasks(userId);
      expect(tasks.isEmpty, true);
    });
  });
}

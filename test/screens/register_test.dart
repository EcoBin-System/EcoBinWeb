// test/register_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Register Form Validation', () {
    // Test 1: Name validation - negative test case
    test('Name validation should fail for an empty name', () {
      String? result = validateName('');
      expect(result, 'Please Enter your name');
    });
    // positive test case
    test('Name validation should pass for a non-empty name', () {
      String? result = validateName('John Doe');
      expect(result, null);
    });

    // Test 2: NIC validation - negaitve test case
    test('NIC validation should fail for an empty NIC', () {
      String? result = validateNIC('');
      expect(result, 'Enter a valid NIC');
    });

    /// negative test case = validate nic format
    test('NIC validation should fail for an invalid NIC format', () {
      String? result = validateNIC('123');
      expect(result, 'Enter a valid NIC (e.g., 123456789V or 199023456789)');
    });

    /// positive test case
    test('NIC validation should pass for a valid NIC format', () {
      String? result = validateNIC('123456789V');
      expect(result, null);
    });

    // Test 3: Phone number validation - negative test case
    test('Phone validation should fail for an empty phone number', () {
      String? result = validatePhone('');
      expect(result, 'Enter a valid phone number');
    });

    /// negative test case  = validate num of digits
    test(
        'Phone validation should fail for a phone number with incorrect length',
        () {
      String? result = validatePhone('12345');
      expect(result, 'Phone number must be 10 digits');
    });

    // negative test case = validate phone number with non-digits
    test('Phone validation should fail for a phone number with non-digits', () {
      String? result = validatePhone('12345abcde');
      expect(result, 'Enter only digits');
    });

    // positive test case
    test('Phone validation should pass for a valid 10-digit phone number', () {
      String? result = validatePhone('0123456789');
      expect(result, null);
    });
  });
}

// Helper validation methods
String? validateName(String val) {
  return val.isEmpty ? "Please Enter your name" : null;
}

String? validateNIC(String val) {
  if (val.isEmpty) {
    return "Enter a valid NIC";
  } else if (!RegExp(r'^[0-9]{9}[VXvx]$').hasMatch(val) &&
      !RegExp(r'^[0-9]{12}$').hasMatch(val)) {
    return "Enter a valid NIC (e.g., 123456789V or 199023456789)";
  }
  return null;
}

String? validatePhone(String val) {
  if (val.isEmpty) {
    return "Enter a valid phone number";
  } else if (val.length != 10) {
    return "Phone number must be 10 digits";
  } else if (!RegExp(r'^[0-9]{10}$').hasMatch(val)) {
    return "Enter only digits";
  }
  return null;
}

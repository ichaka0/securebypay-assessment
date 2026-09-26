import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts a valid address', () {
      expect(Validators.email('user@example.com'), isNull);
    });
    test('rejects empty and malformed input', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('user@'), 'Enter a valid email address');
    });
  });

  group('Validators.nigerianPhone', () {
    test('accepts local, 0-prefixed and +234 formats', () {
      expect(Validators.nigerianPhone('9012345678'), isNull);
      expect(Validators.nigerianPhone('09012345678'), isNull);
      expect(Validators.nigerianPhone('+234 901 234 5678'), isNull);
    });
    test('rejects short or non-mobile numbers', () {
      expect(Validators.nigerianPhone('12345'), isNotNull);
      expect(Validators.nigerianPhone('5012345678'), isNotNull);
    });
  });

  group('Validators.newPassword', () {
    test('requires 8+ chars with a letter and a digit', () {
      expect(Validators.newPassword('short1'), contains('at least 8'));
      expect(Validators.newPassword('abcdefgh'),
          contains('letter and one number'));
      expect(Validators.newPassword('12345678'),
          contains('letter and one number'));
      expect(Validators.newPassword('Secret123'), isNull);
    });
  });
}

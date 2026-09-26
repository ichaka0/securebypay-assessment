/// Client-side form validators. Rules mirror the backend DTOs
/// (`backend/src/auth/dto/register.dto.ts`) so users see errors before submit.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _nigerianPhone = RegExp(r'^(?:\+?234|0)?[789][01]\d{8}$');
  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');

  static String? required(String? value, String fieldName) =>
      (value == null || value.trim().isEmpty) ? '$fieldName is required' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_email.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? nigerianPhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'Phone number is required';
    if (!_nigerianPhone.hasMatch(digits)) {
      return 'Enter a valid Nigerian phone number';
    }
    return null;
  }

  /// Sign-up password rule: 8+ characters with a letter and a number.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!_hasLetter.hasMatch(v) || !_hasDigit.hasMatch(v)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }
}

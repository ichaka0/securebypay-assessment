/// Body for `POST /auth/register`.
class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'password': password,
      };
}


class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() =>
      {'email': email.trim(), 'password': password};
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email.trim()};
}

class PasswordResetToken {
  const PasswordResetToken({required this.token, required this.expiresInSeconds});

  final String token;
  final int expiresInSeconds;

  factory PasswordResetToken.fromJson(Map<String, dynamic> json) =>
      PasswordResetToken(
        token: json['resetToken'] as String,
        expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
      );
}


class ResetPasswordRequest {
  const ResetPasswordRequest({required this.token, required this.password});

  final String token;
  final String password;

  Map<String, dynamic> toJson() => {'token': token, 'password': password};
}

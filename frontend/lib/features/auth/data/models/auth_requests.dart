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

/// Body for `POST /auth/login`.
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() =>
      {'email': email.trim(), 'password': password};
}

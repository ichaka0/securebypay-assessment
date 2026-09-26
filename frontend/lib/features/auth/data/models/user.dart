/// Authenticated user profile returned by the API.
class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.walletBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        walletBalance: (json['walletBalance'] as num).toDouble(),
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final double walletBalance;

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}
